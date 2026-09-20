# Fantasy Sandbox incremental updater v1.0.0
# Windows PowerShell 5.1+ / PowerShell 7+

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
$UpdaterVersion = [version]"1.0.0"

try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
} catch {}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Root = Split-Path -Parent $ScriptDir
$ConfigPath = Join-Path $Root "update_config.json"
$VersionPath = Join-Path $Root "version.json"
$WorkRoot = Join-Path $Root ".update_work"
$StageRoot = Join-Path $WorkRoot "stage"
$BackupRoot = Join-Path $WorkRoot "backup"

function Write-Step([string]$Text) {
    Write-Host "[Fantasy Sandbox] $Text" -ForegroundColor Cyan
}

function Write-Ok([string]$Text) {
    Write-Host "[OK] $Text" -ForegroundColor Green
}

function Assert-SafeRelativePath([string]$RelativePath) {
    if ([string]::IsNullOrWhiteSpace($RelativePath)) {
        throw "O manifesto contem um caminho vazio."
    }
    if ([IO.Path]::IsPathRooted($RelativePath)) {
        throw "Caminho absoluto bloqueado: $RelativePath"
    }

    $sep = [IO.Path]::DirectorySeparatorChar
    $normalized = $RelativePath.Replace('/', $sep)
    $parts = $normalized.Split($sep)
    foreach ($part in $parts) {
        if ($part -eq "..") {
            throw "Caminho inseguro bloqueado: $RelativePath"
        }
    }

    $fullRoot = [IO.Path]::GetFullPath($Root)
    if (-not $fullRoot.EndsWith([string]$sep)) {
        $fullRoot += $sep
    }
    $fullTarget = [IO.Path]::GetFullPath((Join-Path $Root $normalized))
    if (-not $fullTarget.StartsWith($fullRoot, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Caminho fora da pasta do jogo bloqueado: $RelativePath"
    }
}

function Get-LocalSha256([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return $null
    }
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Download-File([string]$Url, [string]$Destination) {
    $parent = Split-Path -Parent $Destination
    if (-not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    Invoke-WebRequest -Uri $Url -OutFile $Destination -UseBasicParsing -Headers @{"Cache-Control"="no-cache"; "User-Agent"="FantasySandboxUpdater/1.0"}
}

function Read-JsonFile([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return $null
    }
    return Get-Content -LiteralPath $Path -Raw -Encoding UTF8 | ConvertFrom-Json
}

function Write-VersionFile([string]$Version) {
    $obj = [ordered]@{
        version = $Version
        updater_version = $UpdaterVersion.ToString()
    }
    $json = $obj | ConvertTo-Json -Depth 4
    [IO.File]::WriteAllText($VersionPath, $json + [Environment]::NewLine, (New-Object Text.UTF8Encoding($false)))
}

try {
    Write-Host ""
    Write-Host "==============================================" -ForegroundColor DarkRed
    Write-Host "       FANTASY SANDBOX - ATUALIZADOR" -ForegroundColor White
    Write-Host "==============================================" -ForegroundColor DarkRed
    Write-Host ""

    $config = Read-JsonFile $ConfigPath
    if ($null -eq $config -or [string]::IsNullOrWhiteSpace([string]$config.manifest_url)) {
        throw "update_config.json ausente ou invalido."
    }

    $localVersionObj = Read-JsonFile $VersionPath
    $localVersion = if ($null -ne $localVersionObj -and $localVersionObj.version) { [string]$localVersionObj.version } else { "desconhecida" }

    Write-Step "Versao local: $localVersion"
    Write-Step "Consultando atualizacoes..."

    $headers = @{"Cache-Control"="no-cache"; "Pragma"="no-cache"; "User-Agent"="FantasySandboxUpdater/1.0"}
    $manifestUrl = [string]$config.manifest_url
    $separator = if ($manifestUrl.Contains("?")) { "&" } else { "?" }
    $cacheBust = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
    $manifestRequestUrl = "$manifestUrl$separator" + "cb=$cacheBust"
    $manifestText = (Invoke-WebRequest -Uri $manifestRequestUrl -UseBasicParsing -Headers $headers).Content
    $manifest = $manifestText | ConvertFrom-Json

    if ($null -eq $manifest -or [int]$manifest.schema -ne 1) {
        throw "Manifesto invalido ou versao de schema nao suportada."
    }
    if ([string]$manifest.app -ne "Fantasy Sandbox") {
        throw "O manifesto recebido nao pertence ao Fantasy Sandbox."
    }
    if ($manifest.channel -and $config.channel -and ([string]$manifest.channel -ne [string]$config.channel)) {
        throw "Canal de atualizacao inesperado: $($manifest.channel)"
    }
    if ([string]::IsNullOrWhiteSpace([string]$manifest.version)) {
        throw "O manifesto nao informa a versao."
    }
    if ($manifest.minimum_updater) {
        $minimumUpdater = [version]([string]$manifest.minimum_updater)
        if ($UpdaterVersion -lt $minimumUpdater) {
            throw "Este update exige atualizador $minimumUpdater ou superior."
        }
    }

    $remoteVersion = [string]$manifest.version
    Write-Step "Versao publicada: $remoteVersion"

    if (Test-Path -LiteralPath $WorkRoot) {
        Remove-Item -LiteralPath $WorkRoot -Recurse -Force
    }
    New-Item -ItemType Directory -Path $StageRoot -Force | Out-Null
    New-Item -ItemType Directory -Path $BackupRoot -Force | Out-Null

    $needed = New-Object System.Collections.Generic.List[object]
    $deleteList = New-Object System.Collections.Generic.List[string]

    foreach ($file in @($manifest.files)) {
        $relative = [string]$file.path
        $expected = ([string]$file.sha256).ToLowerInvariant()
        $url = [string]$file.url

        Assert-SafeRelativePath $relative
        if ($expected -notmatch '^[0-9a-f]{64}$') {
            throw "SHA-256 invalido para $relative"
        }
        if ($url -notmatch '^https://raw\.githubusercontent\.com/') {
            throw "URL de arquivo nao permitida para $relative"
        }

        $target = Join-Path $Root ($relative.Replace('/', [IO.Path]::DirectorySeparatorChar))
        $current = Get-LocalSha256 $target
        if ($current -ne $expected) {
            $needed.Add($file)
        }
    }

    foreach ($item in @($manifest.delete)) {
        $relative = [string]$item
        Assert-SafeRelativePath $relative
        $target = Join-Path $Root ($relative.Replace('/', [IO.Path]::DirectorySeparatorChar))
        if (Test-Path -LiteralPath $target) {
            $deleteList.Add($relative)
        }
    }

    if ($needed.Count -eq 0 -and $deleteList.Count -eq 0) {
        Write-VersionFile $remoteVersion
        Remove-Item -LiteralPath $WorkRoot -Recurse -Force -ErrorAction SilentlyContinue
        Write-Ok "Seu projeto ja esta atualizado na versao $remoteVersion."
        exit 0
    }

    Write-Step "Arquivos para baixar: $($needed.Count)"
    if ($deleteList.Count -gt 0) {
        Write-Step "Arquivos obsoletos para remover: $($deleteList.Count)"
    }

    # 1) Baixa tudo para staging e valida todos os hashes antes de alterar o projeto.
    $index = 0
    foreach ($file in $needed) {
        $index++
        $relative = [string]$file.path
        $expected = ([string]$file.sha256).ToLowerInvariant()
        $stage = Join-Path $StageRoot ($relative.Replace('/', [IO.Path]::DirectorySeparatorChar))

        Write-Step "Baixando [$index/$($needed.Count)] $relative"
        Download-File ([string]$file.url) $stage

        $downloaded = Get-LocalSha256 $stage
        if ($downloaded -ne $expected) {
            throw "Falha de integridade em $relative. Esperado $expected, recebido $downloaded"
        }
    }

    Write-Ok "Todos os downloads passaram na verificacao SHA-256."

    # 2) Faz backup dos arquivos que serao alterados/removidos.
    foreach ($file in $needed) {
        $relative = [string]$file.path
        $target = Join-Path $Root ($relative.Replace('/', [IO.Path]::DirectorySeparatorChar))
        if (Test-Path -LiteralPath $target -PathType Leaf) {
            $backup = Join-Path $BackupRoot ($relative.Replace('/', [IO.Path]::DirectorySeparatorChar))
            $backupParent = Split-Path -Parent $backup
            New-Item -ItemType Directory -Path $backupParent -Force | Out-Null
            Copy-Item -LiteralPath $target -Destination $backup -Force
        }
    }
    foreach ($relative in $deleteList) {
        $target = Join-Path $Root ($relative.Replace('/', [IO.Path]::DirectorySeparatorChar))
        if (Test-Path -LiteralPath $target -PathType Leaf) {
            $backup = Join-Path $BackupRoot ($relative.Replace('/', [IO.Path]::DirectorySeparatorChar))
            $backupParent = Split-Path -Parent $backup
            New-Item -ItemType Directory -Path $backupParent -Force | Out-Null
            Copy-Item -LiteralPath $target -Destination $backup -Force
        }
    }

    # 3) Aplica os arquivos verificados.
    $applied = New-Object System.Collections.Generic.List[string]
    try {
        foreach ($file in $needed) {
            $relative = [string]$file.path
            $stage = Join-Path $StageRoot ($relative.Replace('/', [IO.Path]::DirectorySeparatorChar))
            $target = Join-Path $Root ($relative.Replace('/', [IO.Path]::DirectorySeparatorChar))
            $targetParent = Split-Path -Parent $target
            if (-not (Test-Path -LiteralPath $targetParent)) {
                New-Item -ItemType Directory -Path $targetParent -Force | Out-Null
            }
            Copy-Item -LiteralPath $stage -Destination $target -Force
            $applied.Add($relative)
        }

        foreach ($relative in $deleteList) {
            $target = Join-Path $Root ($relative.Replace('/', [IO.Path]::DirectorySeparatorChar))
            if (Test-Path -LiteralPath $target) {
                Remove-Item -LiteralPath $target -Force
            }
        }

        Write-VersionFile $remoteVersion
    }
    catch {
        Write-Host "Falha ao aplicar a atualizacao. Restaurando backup..." -ForegroundColor Yellow

        foreach ($relative in $applied) {
            $target = Join-Path $Root ($relative.Replace('/', [IO.Path]::DirectorySeparatorChar))
            $backup = Join-Path $BackupRoot ($relative.Replace('/', [IO.Path]::DirectorySeparatorChar))
            if (Test-Path -LiteralPath $backup -PathType Leaf) {
                $parent = Split-Path -Parent $target
                New-Item -ItemType Directory -Path $parent -Force | Out-Null
                Copy-Item -LiteralPath $backup -Destination $target -Force
            } elseif (Test-Path -LiteralPath $target) {
                Remove-Item -LiteralPath $target -Force
            }
        }

        foreach ($relative in $deleteList) {
            $target = Join-Path $Root ($relative.Replace('/', [IO.Path]::DirectorySeparatorChar))
            $backup = Join-Path $BackupRoot ($relative.Replace('/', [IO.Path]::DirectorySeparatorChar))
            if (Test-Path -LiteralPath $backup -PathType Leaf) {
                $parent = Split-Path -Parent $target
                New-Item -ItemType Directory -Path $parent -Force | Out-Null
                Copy-Item -LiteralPath $backup -Destination $target -Force
            }
        }

        throw
    }

    Remove-Item -LiteralPath $WorkRoot -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host ""
    Write-Ok "Atualizacao concluida: $localVersion -> $remoteVersion"
    Write-Host "Agora voce pode abrir o projeto no Godot." -ForegroundColor White
    exit 0
}
catch {
    Write-Host ""
    Write-Host "[ERRO] $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "O projeto nao foi atualizado." -ForegroundColor Yellow
    if (Test-Path -LiteralPath $WorkRoot) {
        Remove-Item -LiteralPath $WorkRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
    exit 1
}
