$ErrorActionPreference = "Stop"

$DefaultRepo = "https://github.com/rtzr/callabo-cli"

$CallaboCliRepo = if ($env:CALLABO_CLI_REPO) { $env:CALLABO_CLI_REPO.TrimEnd([char]"/") } else { $DefaultRepo }

function Get-CallaboCliLatestVersion {
    $repoPath = $CallaboCliRepo -replace "^https://github.com/", ""
    $latestReleaseUrl = "https://api.github.com/repos/$repoPath/releases/latest"
    $latestRelease = Invoke-RestMethod -Uri $latestReleaseUrl -Headers @{ Accept = "application/vnd.github+json" }

    if ([string]::IsNullOrWhiteSpace($latestRelease.tag_name)) {
        [Console]::Error.WriteLine("Failed to resolve the latest Callabo CLI release version.")
        exit 1
    }

    return $latestRelease.tag_name.TrimStart("v")
}

function Get-CallaboCliWheelUrl {
    if (-not [string]::IsNullOrWhiteSpace($env:CALLABO_CLI_WHEEL_URL)) {
        return $env:CALLABO_CLI_WHEEL_URL
    }

    $version = if (-not [string]::IsNullOrWhiteSpace($env:CALLABO_CLI_VERSION)) {
        $env:CALLABO_CLI_VERSION
    } else {
        Get-CallaboCliLatestVersion
    }

    return "$CallaboCliRepo/releases/download/v$version/callabo_cli-$version-py3-none-any.whl"
}

$CallaboCliWheelUrl = Get-CallaboCliWheelUrl

function Add-PathForCurrentSession {
    param([string] $PathToAdd)

    if ([string]::IsNullOrWhiteSpace($PathToAdd)) {
        return
    }

    $existingPaths = @($env:Path -split ";" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    if ($existingPaths -notcontains $PathToAdd) {
        $env:Path = "$PathToAdd;$env:Path"
    }
}

function Invoke-CheckedNativeCommand {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Command,
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]] $Arguments
    )

    & $Command @Arguments
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}

if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
    Write-Host "Installing uv..."
    Invoke-RestMethod https://astral.sh/uv/install.ps1 | Invoke-Expression
}

Add-PathForCurrentSession "$env:USERPROFILE\.local\bin"

if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
    [Console]::Error.WriteLine("uv was installed, but it is not available on PATH. Open a new PowerShell session or run uv tool update-shell, then rerun this script.")
    exit 1
}

Write-Host "Installing Callabo CLI from $CallaboCliWheelUrl..."
Invoke-CheckedNativeCommand uv tool install --force --reinstall --python 3.13 $CallaboCliWheelUrl

$CallaboUvToolBin = (& uv tool dir --bin 2>$null)
if ($LASTEXITCODE -eq 0 -and -not [string]::IsNullOrWhiteSpace($CallaboUvToolBin)) {
    Add-PathForCurrentSession $CallaboUvToolBin.Trim()
}

if (-not (Get-Command callabo -ErrorAction SilentlyContinue)) {
    [Console]::Error.WriteLine("Callabo CLI was installed, but the callabo command is not available on PATH. Run uv tool update-shell and open a new PowerShell session.")
    exit 1
}

Invoke-CheckedNativeCommand callabo --help > $null
Write-Host "Callabo CLI installed successfully."
