# Fantasy Sandbox incremental updater v1.0.2
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
$UpdaterVersion = [version]"1.0.2"

try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Root = Split-Path -Parent $ScriptDir
$ConfigPath = Join-Path $Root "update_config.json"
$VersionPath = Join-Path $Root "version.json"
$ProjectPath = Join-Path $Root "project.godot"
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
        "User-Agent" = "FantasySandboxUpdater/1.0.2"
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
    Write-Host "[INFO] Pasta que sera atualizada:" -ForegroundColor Yellow
    Write-Host "       $Root" -ForegroundColor White
    Write-Host "[INFO] Projeto Godot esperado:" -ForegroundColor Yellow
    Write-Host "       $ProjectPath" -ForegroundColor White
    Write-Host ""

    if (-not (Test-Path -LiteralPath $ProjectPath -PathType Leaf)) {
        throw "project.godot nao foi encontrado nessa pasta. O atualizador esta no lugar errado."
    }

    $config = Read-Json $ConfigPath
    if ($null -eq $config -or [string]::IsNullOrWhiteSpace([string]$config.manifest_url)) {
        throw "update_config.json ausente ou invalido."
    }

    $localInfo = Read-Json $VersionPath
    $localVersion = if ($localInfo -and $localInfo.version) { [string]$localInfo.version } else { "desconhecida" }
    Write-Host "[INFO] Versao local registrada: $localVersion" -ForegroundColor Cyan
    Write-Host "[INFO] Consultando manifesto sem cache..." -ForegroundColor Cyan

    $baseManifestUrl = [string]$config.manifest_url
    $separator = if ($baseManifestUrl.Contains("?")) { "&" } else { "?" }
    $cacheBust = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
    $manifestUrl = $baseManifestUrl + $separator + "cb=" + $cacheBust

    $manifestText = (Invoke-WebRequest -Uri $manifestUrl -UseBasicParsing -Headers @{
        "Cache-Control" = "no-cache"
        "Pragma" = "no-cache"
        "User-Agent" = "FantasySandboxUpdater/1.0.2"
    }).Content
    $manifest = $manifestText | ConvertFrom-Json

    if ([int]$manifest.schema -ne 1) { throw "Schema de manifesto nao suportado." }
    if ([string]$manifest.app -ne "Fantasy Sandbox") { throw "Manifesto de outro aplicativo." }

    $remoteVersion = [string]$manifest.version
    Write-Host "[INFO] Versao publicada: $remoteVersion" -ForegroundColor Cyan
    Write-Host "[INFO] Commit-fonte: $($manifest.source_commit)" -ForegroundColor Cyan

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
        $localHash = Get-Sha256 $target

        if ($localHash -ne $expected) {
            Write-Host "[ALTERAR] $relative" -ForegroundColor Yellow
            Write-Host "          local : $localHash" -ForegroundColor DarkGray
            Write-Host "          remoto: $expected" -ForegroundColor DarkGray
            $needed += $file
        }
    }

    if ($needed.Count -eq 0) {
        Write-Version $remoteVersion
        Remove-Item -LiteralPath $WorkRoot -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host ""
        Write-Host "[OK] Todos os arquivos ja correspondem ao manifesto." -ForegroundColor Green
        Write-Host "[OK] Pasta verificada: $Root" -ForegroundColor Green
        exit 0
    }

    Write-Host ""
    Write-Host "[INFO] Total de arquivos a baixar: $($needed.Count)" -ForegroundColor Cyan

    foreach ($file in $needed) {
        $relative = Safe-RelativePath ([string]$file.path)
        $expected = ([string]$file.sha256).ToLowerInvariant()
        $stage = Join-Path $StageRoot $relative

        Write-Host "[BAIXAR] $relative" -ForegroundColor Cyan
        Download ([string]$file.url) $stage

        $downloaded = Get-Sha256 $stage
        if ($downloaded -ne $expected) {
            throw "Falha de integridade em $relative. Baixado: $downloaded Esperado: $expected"
        }
    }

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

            $afterHash = Get-Sha256 $target
            $expected = ([string]$file.sha256).ToLowerInvariant()
            if ($afterHash -ne $expected) {
                throw "Falha ao substituir $relative. Hash final incorreto."
            }
            Write-Host "[OK] Substituido e verificado: $relative" -ForegroundColor Green
        }

        Write-Version $remoteVersion
    }
    catch {
        Write-Host "[AVISO] Falha durante aplicacao. Restaurando backup..." -ForegroundColor Yellow
        foreach ($relative in $applied) {
            $target = Join-Path $Root $relative
            $backup = Join-Path $BackupRoot $relative
            if (Test-Path -LiteralPath $backup -PathType Leaf) {
                Copy-Item -LiteralPath $backup -Destination $target -Force
            }
        }
        throw
    }

    # Verificacao final de TODOS os arquivos do manifesto.
    $failed = @()
    foreach ($file in @($manifest.files)) {
        $relative = Safe-RelativePath ([string]$file.path)
        $target = Join-Path $Root $relative
        $expected = ([string]$file.sha256).ToLowerInvariant()
        $actual = Get-Sha256 $target
        if ($actual -ne $expected) {
            $failed += $relative
        }
    }

    if ($failed.Count -gt 0) {
        throw "Verificacao final falhou: $($failed -join ', ')"
    }

    Remove-Item -LiteralPath $WorkRoot -Recurse -Force -ErrorAction SilentlyContinue

    Write-Host ""
    Write-Host "[OK] ATUALIZACAO CONCLUIDA E VERIFICADA." -ForegroundColor Green
    Write-Host "[OK] Pasta do projeto: $Root" -ForegroundColor Green
    Write-Host "[OK] Abra exatamente este arquivo no Godot:" -ForegroundColor Green
    Write-Host "     $ProjectPath" -ForegroundColor White
    exit 0
}
catch {
    Write-Host ""
    Write-Host "[ERRO] $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "[INFO] Pasta que o atualizador tentou modificar: $Root" -ForegroundColor Yellow
    if (Test-Path -LiteralPath $WorkRoot) {
        Remove-Item -LiteralPath $WorkRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
    exit 1
}
