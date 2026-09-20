# Fantasy Sandbox - Atualizador incremental v1.1.0
# Compatível com Windows PowerShell 5.1+

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$UpdaterVersion = [version]"1.1.0"
$Repository = "janduyankiingles-ops/Fantasy-Sandbox"

try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
} catch {}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Root = Split-Path -Parent $ScriptDir
$ProjectPath = Join-Path $Root "project.godot"
$VersionPath = Join-Path $Root "version.json"
$WorkRoot = Join-Path $Root ".update_work"
$StageRoot = Join-Path $WorkRoot "stage"
$BackupRoot = Join-Path $WorkRoot "backup"

function Info([string]$Text) {
    Write-Host "[INFO] $Text" -ForegroundColor Cyan
}

function Ok([string]$Text) {
    Write-Host "[OK] $Text" -ForegroundColor Green
}

function Warn([string]$Text) {
    Write-Host "[AVISO] $Text" -ForegroundColor Yellow
}

function Get-Sha256([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return $null
    }
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Get-SafeRelativePath([string]$RelativePath) {
    if ([string]::IsNullOrWhiteSpace($RelativePath)) {
        throw "O manifesto contem um caminho vazio."
    }

    $clean = $RelativePath.Replace("\", "/").TrimStart("/")
    if ([IO.Path]::IsPathRooted($clean)) {
        throw "Caminho absoluto bloqueado: $RelativePath"
    }

    $segments = $clean.Split("/")
    foreach ($segment in $segments) {
        if ($segment -eq ".." -or [string]::IsNullOrWhiteSpace($segment)) {
            throw "Caminho inseguro bloqueado: $RelativePath"
        }
    }

    $platformPath = $clean.Replace("/", [IO.Path]::DirectorySeparatorChar)
    $fullRoot = [IO.Path]::GetFullPath($Root)
    if (-not $fullRoot.EndsWith([string][IO.Path]::DirectorySeparatorChar)) {
        $fullRoot += [IO.Path]::DirectorySeparatorChar
    }

    $fullTarget = [IO.Path]::GetFullPath((Join-Path $Root $platformPath))
    if (-not $fullTarget.StartsWith($fullRoot, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Caminho fora da pasta do projeto bloqueado: $RelativePath"
    }

    return $clean
}

function Get-RemoteFileUrl([string]$SourceCommit, [string]$RelativePath) {
    if ($SourceCommit -notmatch '^[0-9a-fA-F]{40}$') {
        throw "Commit-fonte invalido no manifesto."
    }

    $segments = $RelativePath.Split("/")
    $encoded = New-Object System.Collections.Generic.List[string]
    foreach ($segment in $segments) {
        $encoded.Add([Uri]::EscapeDataString($segment))
    }

    $encodedPath = [string]::Join("/", $encoded.ToArray())
    return "https://raw.githubusercontent.com/$Repository/$SourceCommit/$encodedPath"
}

function Download-File([string]$Url, [string]$Destination) {
    $parent = Split-Path -Parent $Destination
    if (-not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    Invoke-WebRequest -Uri $Url -OutFile $Destination -UseBasicParsing -Headers @{
        "User-Agent" = "FantasySandboxUpdater/1.1.0"
        "Cache-Control" = "no-cache"
        "Pragma" = "no-cache"
    }
}

function Get-LiveManifest {
    # O manifesto e obtido pela API do GitHub para nao depender do cache de raw/main.
    $apiUrl = "https://api.github.com/repos/$Repository/contents/update_manifest.json?ref=main"
    $response = Invoke-RestMethod -Uri $apiUrl -Method Get -Headers @{
        "User-Agent" = "FantasySandboxUpdater/1.1.0"
        "Accept" = "application/vnd.github+json"
        "Cache-Control" = "no-cache"
        "Pragma" = "no-cache"
    }

    if ([string]$response.encoding -ne "base64") {
        throw "A API do GitHub retornou o manifesto em formato inesperado."
    }

    $base64 = ([string]$response.content) -replace "\s", ""
    $bytes = [Convert]::FromBase64String($base64)
    $json = [Text.Encoding]::UTF8.GetString($bytes)
    return $json | ConvertFrom-Json
}

function Write-Version([string]$Version, [string]$SourceCommit) {
    $data = [ordered]@{
        version = $Version
        source_commit = $SourceCommit
        updater_version = $UpdaterVersion.ToString()
    }

    $json = $data | ConvertTo-Json -Depth 4
    [IO.File]::WriteAllText(
        $VersionPath,
        $json + [Environment]::NewLine,
        (New-Object Text.UTF8Encoding($false))
    )
}

try {
    Write-Host ""
    Write-Host "================================================" -ForegroundColor DarkRed
    Write-Host "       FANTASY SANDBOX - ATUALIZADOR V1.1" -ForegroundColor White
    Write-Host "================================================" -ForegroundColor DarkRed
    Write-Host ""

    Info "Pasta do projeto:"
    Write-Host "       $Root" -ForegroundColor White

    if (-not (Test-Path -LiteralPath $ProjectPath -PathType Leaf)) {
        throw "project.godot nao foi encontrado. Coloque o atualizador dentro da pasta correta do jogo."
    }

    Info "Buscando manifesto pela API do GitHub..."
    $manifest = Get-LiveManifest

    $schema = [int]$manifest.schema
    if ($schema -ne 2) {
        throw "Schema de manifesto nao suportado: $schema"
    }

    if ([string]$manifest.app -ne "Fantasy Sandbox") {
        throw "O manifesto recebido nao pertence ao Fantasy Sandbox."
    }

    $sourceCommit = ([string]$manifest.source_commit).ToLowerInvariant()
    if ($sourceCommit -notmatch '^[0-9a-f]{40}$') {
        throw "source_commit invalido no manifesto."
    }

    if ($manifest.minimum_updater) {
        $minimumUpdater = [version]([string]$manifest.minimum_updater)
        if ($UpdaterVersion -lt $minimumUpdater) {
            throw "Este update exige o atualizador $minimumUpdater ou superior."
        }
    }

    $remoteVersion = [string]$manifest.version
    Info "Versao do jogo publicada: $remoteVersion"
    Info "Commit-fonte: $sourceCommit"

    if (Test-Path -LiteralPath $WorkRoot) {
        Remove-Item -LiteralPath $WorkRoot -Recurse -Force
    }
    New-Item -ItemType Directory -Path $StageRoot -Force | Out-Null
    New-Item -ItemType Directory -Path $BackupRoot -Force | Out-Null

    $needed = New-Object System.Collections.Generic.List[object]
    $deleteList = New-Object System.Collections.Generic.List[string]

    foreach ($file in @($manifest.files)) {
        $relative = Get-SafeRelativePath ([string]$file.path)
        $expected = ([string]$file.sha256).ToLowerInvariant()

        if ($expected -notmatch '^[0-9a-f]{64}$') {
            throw "SHA-256 invalido no manifesto para $relative"
        }

        $target = Join-Path $Root ($relative.Replace("/", [IO.Path]::DirectorySeparatorChar))
        $current = Get-Sha256 $target

        if ($current -ne $expected) {
            Write-Host "[ALTERAR] $relative" -ForegroundColor Yellow
            $needed.Add($file)
        }
    }

    foreach ($item in @($manifest.delete)) {
        $relative = Get-SafeRelativePath ([string]$item)
        $target = Join-Path $Root ($relative.Replace("/", [IO.Path]::DirectorySeparatorChar))
        if (Test-Path -LiteralPath $target) {
            Write-Host "[REMOVER] $relative" -ForegroundColor Yellow
            $deleteList.Add($relative)
        }
    }

    if ($needed.Count -eq 0 -and $deleteList.Count -eq 0) {
        Write-Version $remoteVersion $sourceCommit
        Remove-Item -LiteralPath $WorkRoot -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host ""
        Ok "Todos os arquivos ja correspondem ao manifesto."
        Ok "Projeto verificado: $ProjectPath"
        exit 0
    }

    Info "Arquivos para baixar: $($needed.Count)"

    # 1. Download para staging. Nada do projeto e alterado nesta fase.
    $index = 0
    foreach ($file in $needed) {
        $index++
        $relative = Get-SafeRelativePath ([string]$file.path)
        $expected = ([string]$file.sha256).ToLowerInvariant()
        $stage = Join-Path $StageRoot ($relative.Replace("/", [IO.Path]::DirectorySeparatorChar))
        $url = Get-RemoteFileUrl $sourceCommit $relative

        Write-Host "[BAIXAR $index/$($needed.Count)] $relative" -ForegroundColor Cyan
        Download-File $url $stage

        $downloaded = Get-Sha256 $stage
        if ($downloaded -ne $expected) {
            throw "Falha de integridade em $relative. Esperado: $expected | Recebido: $downloaded"
        }
    }

    Ok "Downloads validados por SHA-256."

    # 2. Backup de tudo que sera substituido ou removido.
    foreach ($file in $needed) {
        $relative = Get-SafeRelativePath ([string]$file.path)
        $target = Join-Path $Root ($relative.Replace("/", [IO.Path]::DirectorySeparatorChar))

        if (Test-Path -LiteralPath $target -PathType Leaf) {
            $backup = Join-Path $BackupRoot ($relative.Replace("/", [IO.Path]::DirectorySeparatorChar))
            $parent = Split-Path -Parent $backup
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
            Copy-Item -LiteralPath $target -Destination $backup -Force
        }
    }

    foreach ($relative in $deleteList) {
        $target = Join-Path $Root ($relative.Replace("/", [IO.Path]::DirectorySeparatorChar))
        if (Test-Path -LiteralPath $target -PathType Leaf) {
            $backup = Join-Path $BackupRoot ($relative.Replace("/", [IO.Path]::DirectorySeparatorChar))
            $parent = Split-Path -Parent $backup
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
            Copy-Item -LiteralPath $target -Destination $backup -Force
        }
    }

    # 3. Aplicacao transacional.
    $applied = New-Object System.Collections.Generic.List[string]
    try {
        foreach ($file in $needed) {
            $relative = Get-SafeRelativePath ([string]$file.path)
            $stage = Join-Path $StageRoot ($relative.Replace("/", [IO.Path]::DirectorySeparatorChar))
            $target = Join-Path $Root ($relative.Replace("/", [IO.Path]::DirectorySeparatorChar))
            $parent = Split-Path -Parent $target

            if (-not (Test-Path -LiteralPath $parent)) {
                New-Item -ItemType Directory -Path $parent -Force | Out-Null
            }

            Copy-Item -LiteralPath $stage -Destination $target -Force

            $expected = ([string]$file.sha256).ToLowerInvariant()
            $actual = Get-Sha256 $target
            if ($actual -ne $expected) {
                throw "O arquivo $relative nao ficou com o hash esperado apos a copia."
            }

            $applied.Add($relative)
            Write-Host "[OK] $relative" -ForegroundColor Green
        }

        foreach ($relative in $deleteList) {
            $target = Join-Path $Root ($relative.Replace("/", [IO.Path]::DirectorySeparatorChar))
            if (Test-Path -LiteralPath $target) {
                Remove-Item -LiteralPath $target -Force
            }
        }

        # 4. Verificacao final de TODOS os arquivos controlados.
        foreach ($file in @($manifest.files)) {
            $relative = Get-SafeRelativePath ([string]$file.path)
            $target = Join-Path $Root ($relative.Replace("/", [IO.Path]::DirectorySeparatorChar))
            $expected = ([string]$file.sha256).ToLowerInvariant()
            $actual = Get-Sha256 $target

            if ($actual -ne $expected) {
                throw "Verificacao final falhou em $relative."
            }
        }

        Write-Version $remoteVersion $sourceCommit
    }
    catch {
        Warn "Falha durante a aplicacao. Restaurando os arquivos anteriores..."

        foreach ($relative in $applied) {
            $target = Join-Path $Root ($relative.Replace("/", [IO.Path]::DirectorySeparatorChar))
            $backup = Join-Path $BackupRoot ($relative.Replace("/", [IO.Path]::DirectorySeparatorChar))

            if (Test-Path -LiteralPath $backup -PathType Leaf) {
                Copy-Item -LiteralPath $backup -Destination $target -Force
            } elseif (Test-Path -LiteralPath $target) {
                Remove-Item -LiteralPath $target -Force
            }
        }

        foreach ($relative in $deleteList) {
            $target = Join-Path $Root ($relative.Replace("/", [IO.Path]::DirectorySeparatorChar))
            $backup = Join-Path $BackupRoot ($relative.Replace("/", [IO.Path]::DirectorySeparatorChar))

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
    Ok "ATUALIZACAO CONCLUIDA E VERIFICADA."
    Ok "Versao: $remoteVersion"
    Ok "Abra este projeto no Godot:"
    Write-Host "     $ProjectPath" -ForegroundColor White
    exit 0
}
catch {
    Write-Host ""
    Write-Host "[ERRO] $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "[INFO] Pasta usada pelo atualizador: $Root" -ForegroundColor Yellow

    if (Test-Path -LiteralPath $WorkRoot) {
        Remove-Item -LiteralPath $WorkRoot -Recurse -Force -ErrorAction SilentlyContinue
    }

    exit 1
}
