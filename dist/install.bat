@echo off
setlocal

if not defined CALLABO_CLI_REPO set "CALLABO_CLI_REPO=https://github.com/rtzr/callabo-cli"
if "%CALLABO_CLI_REPO:~-1%"=="/" set "CALLABO_CLI_REPO=%CALLABO_CLI_REPO:~0,-1%"
if not defined CALLABO_CLI_VERSION set "CALLABO_CLI_VERSION=0.1.6"
if not defined CALLABO_CLI_WHEEL_URL set "CALLABO_CLI_WHEEL_URL=%CALLABO_CLI_REPO%/releases/download/v%CALLABO_CLI_VERSION%/callabo_cli-%CALLABO_CLI_VERSION%-py3-none-any.whl"

where uv >nul 2>nul
if errorlevel 1 (
    echo Installing uv...
    powershell -NoProfile -ExecutionPolicy ByPass -Command "irm https://astral.sh/uv/install.ps1 | iex"
    if errorlevel 1 exit /b
)

set "PATH=%USERPROFILE%\.local\bin;%PATH%"

where uv >nul 2>nul
if errorlevel 1 (
    echo uv was installed, but it is not available on PATH. 1>&2
    echo Open a new terminal or run uv tool update-shell, then rerun this script. 1>&2
    exit /b 1
)

echo Installing Callabo CLI from %CALLABO_CLI_WHEEL_URL%...
uv tool install --force --reinstall --python 3.13 "%CALLABO_CLI_WHEEL_URL%"
if errorlevel 1 exit /b %errorlevel%

for /f "usebackq delims=" %%I in (`uv tool dir --bin 2^>nul`) do set "CALLABO_UV_TOOL_BIN=%%I"
if defined CALLABO_UV_TOOL_BIN set "PATH=%CALLABO_UV_TOOL_BIN%;%PATH%"

where callabo >nul 2>nul
if errorlevel 1 (
    echo Callabo CLI was installed, but the callabo command is not available on PATH. 1>&2
    echo Run uv tool update-shell and open a new terminal. 1>&2
    exit /b 1
)

callabo --help >nul
if errorlevel 1 exit /b %errorlevel%

echo Callabo CLI installed successfully.
