$ErrorActionPreference = "Stop"

$DefaultRepo = "https://github.com/rtzr/callabo-cli"
$DefaultVersion = "0.1.8"

$CallaboCliRepo = if ($env:CALLABO_CLI_REPO) { $env:CALLABO_CLI_REPO.TrimEnd([char]"/") } else { $DefaultRepo }
$CallaboCliVersion = if ($env:CALLABO_CLI_VERSION) { $env:CALLABO_CLI_VERSION } else { $DefaultVersion }
$CallaboCliWheelUrl = if ($env:CALLABO_CLI_WHEEL_URL) {
    $env:CALLABO_CLI_WHEEL_URL
} else {
    "$CallaboCliRepo/releases/download/v$CallaboCliVersion/callabo_cli-$CallaboCliVersion-py3-none-any.whl"
}

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
