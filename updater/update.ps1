# Fantasy Sandbox incremental updater v1.0.1
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
$UpdaterVersion = [version]"1.0.1"

try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Root = Split-Path -Parent $ScriptDir
$ConfigPath = Join-Path $Root "update_config.json"
$VersionPath = Join-Path $Root "version.json"
$WorkRoot = Join-Path $Root ".update_work"
$StageRoot = Join-Path $WorkRoot "stage"
$BackupRoot = Join-Path $WorkRoot "backup"

function Get-Sha256([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $null }
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Safe-RelativePath([string]$RelativePath) {
    if ([string]::IsNullOrWhiteSpace($RelativePath)) { throw "Caminho vazio no manifesto." }
    if ([IO.Path]::IsPathRooted($RelativePath)) { throw "Caminho absoluto bloqueado: $RelativePath" }

    $normalized = $RelativePath.Replace('/', [IO.Path]::DirectorySeparatorChar)
    foreach ($part in $normalized.Split([IO.Path]::DirectorySeparatorChar)) {
        if ($part -eq "..") { throw "Caminho inseguro bloqueado: $RelativePath" }
    }
    return $normalized
}

function Read-Json([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $null }
    return Get-Content -LiteralPath $Path -Raw -Encoding UTF8 | ConvertFrom-Json
}

function Download([string]$Url, [string]$Destination) {
    $parent = Split-Path -Parent $Destination
    if (-not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    Invoke-WebRequest -Uri $Url -OutFile $Destination -UseBasicParsing -Headers @{
        "Cache-Control" = "no-cache"
        "Pragma" = "no-cache"
        "User-Agent" = "FantasySandboxUpdater/1.0.1"
    }
}

function Write-Version([string]$Version) {
    $obj = [ordered]@{
        version = $Version
        updater_version = $UpdaterVersion.ToString()
    }
    $json = $obj | ConvertTo-Json
    [IO.File]::WriteAllText(
        $VersionPath,
        $json + [Environment]::NewLine,
        (New-Object Text.UTF8Encoding($false))
    )
}

try {
    Write-Host ""
    Write-Host "==============================================" -ForegroundColor DarkRed
    Write-Host "       FANTASY SANDBOX - ATUALIZADOR" -ForegroundColor White
    Write-Host "==============================================" -ForegroundColor DarkRed
    Write-Host ""

    $config = Read-Json $ConfigPath
    if ($null -eq $config -or [string]::IsNullOrWhiteSpace([string]$config.manifest_url)) {
        throw "update_config.json ausente ou invalido."
    }

    $localInfo = Read-Json $VersionPath
    $localVersion = if ($localInfo -and $localInfo.version) { [string]$localInfo.version } else { "desconhecida" }
    Write-Host "[Fantasy Sandbox] Versao local: $localVersion" -ForegroundColor Cyan
    Write-Host "[Fantasy Sandbox] Consultando atualizacoes..." -ForegroundColor Cyan

    # Cache-buster: cada consulta usa uma URL unica.
    $baseManifestUrl = [string]$config.manifest_url
    $separator = if ($baseManifestUrl.Contains("?")) { "&" } else { "?" }
    $cacheBust = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
    $manifestUrl = $baseManifestUrl + $separator + "cb=" + $cacheBust

    $manifestText = (Invoke-WebRequest -Uri $manifestUrl -UseBasicParsing -Headers @{
        "Cache-Control" = "no-cache"
        "Pragma" = "no-cache"
        "User-Agent" = "FantasySandboxUpdater/1.0.1"
    }).Content
    $manifest = $manifestText | ConvertFrom-Json

    if ([int]$manifest.schema -ne 1) { throw "Schema de manifesto nao suportado." }
    if ([string]$manifest.app -ne "Fantasy Sandbox") { throw "Manifesto de outro aplicativo." }

    $remoteVersion = [string]$manifest.version
    Write-Host "[Fantasy Sandbox] Versao publicada: $remoteVersion" -ForegroundColor Cyan

    if (Test-Path -LiteralPath $WorkRoot) {
        Remove-Item -LiteralPath $WorkRoot -Recurse -Force
    }
    New-Item -ItemType Directory -Path $StageRoot -Force | Out-Null
    New-Item -ItemType Directory -Path $BackupRoot -Force | Out-Null

    $needed = @()
    foreach ($file in @($manifest.files)) {
        $relative = Safe-RelativePath ([string]$file.path)
        $expected = ([string]$file.sha256).ToLowerInvariant()
        if ($expected -notmatch '^[0-9a-f]{64}$') { throw "SHA-256 invalido: $relative" }

        $target = Join-Path $Root $relative
        if ((Get-Sha256 $target) -ne $expected) {
            $needed += $file
        }
    }

    if ($needed.Count -eq 0) {
        Write-Version $remoteVersion
        Remove-Item -LiteralPath $WorkRoot -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "[OK] Projeto atualizado: $remoteVersion" -ForegroundColor Green
        exit 0
    }

    Write-Host "[Fantasy Sandbox] Arquivos para baixar: $($needed.Count)" -ForegroundColor Cyan

    # Baixa e valida tudo antes de substituir qualquer arquivo.
    foreach ($file in $needed) {
        $relative = Safe-RelativePath ([string]$file.path)
        $expected = ([string]$file.sha256).ToLowerInvariant()
        $stage = Join-Path $StageRoot $relative

        Write-Host "[Fantasy Sandbox] Baixando $relative" -ForegroundColor Cyan
        Download ([string]$file.url) $stage

        $downloaded = Get-Sha256 $stage
        if ($downloaded -ne $expected) {
            throw "Falha de integridade em $relative"
        }
    }

    # Backup.
    foreach ($file in $needed) {
        $relative = Safe-RelativePath ([string]$file.path)
        $target = Join-Path $Root $relative
        if (Test-Path -LiteralPath $target -PathType Leaf) {
            $backup = Join-Path $BackupRoot $relative
            $parent = Split-Path -Parent $backup
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
            Copy-Item -LiteralPath $target -Destination $backup -Force
        }
    }

    $applied = @()
    try {
        foreach ($file in $needed) {
            $relative = Safe-RelativePath ([string]$file.path)
            $stage = Join-Path $StageRoot $relative
            $target = Join-Path $Root $relative
            $parent = Split-Path -Parent $target
            if (-not (Test-Path -LiteralPath $parent)) {
                New-Item -ItemType Directory -Path $parent -Force | Out-Null
            }
            Copy-Item -LiteralPath $stage -Destination $target -Force
            $applied += $relative
        }
        Write-Version $remoteVersion
    }
    catch {
        foreach ($relative in $applied) {
            $target = Join-Path $Root $relative
            $backup = Join-Path $BackupRoot $relative
            if (Test-Path -LiteralPath $backup -PathType Leaf) {
                Copy-Item -LiteralPath $backup -Destination $target -Force
            }
        }
        throw
    }

    Remove-Item -LiteralPath $WorkRoot -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host ""
    Write-Host "[OK] Atualizacao concluida: $localVersion -> $remoteVersion" -ForegroundColor Green
    exit 0
}
catch {
    Write-Host ""
    Write-Host "[ERRO] $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Nenhuma atualizacao incompleta foi mantida." -ForegroundColor Yellow
    if (Test-Path -LiteralPath $WorkRoot) {
        Remove-Item -LiteralPath $WorkRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
    exit 1
}
