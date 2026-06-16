#!/usr/bin/env sh
set -eu

CALLABO_CLI_REPO="${CALLABO_CLI_REPO:-https://github.com/rtzr/callabo-cli}"
CALLABO_CLI_REPO="${CALLABO_CLI_REPO%/}"
CALLABO_CLI_VERSION="${CALLABO_CLI_VERSION:-0.1.6}"
CALLABO_CLI_WHEEL_URL="${CALLABO_CLI_WHEEL_URL:-${CALLABO_CLI_REPO}/releases/download/v${CALLABO_CLI_VERSION}/callabo_cli-${CALLABO_CLI_VERSION}-py3-none-any.whl}"

install_uv() {
  if command -v curl >/dev/null 2>&1; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
    return
  fi

  if command -v wget >/dev/null 2>&1; then
    wget -qO- https://astral.sh/uv/install.sh | sh
    return
  fi

  echo "curl or wget is required to install uv." >&2
  exit 1
}

if ! command -v uv >/dev/null 2>&1; then
  echo "Installing uv..."
  install_uv
fi

export PATH="$HOME/.local/bin:$PATH"

if ! command -v uv >/dev/null 2>&1; then
  echo "uv was installed, but it is not available on PATH." >&2
  echo "Open a new terminal or add ~/.local/bin to PATH, then rerun this script." >&2
  exit 1
fi

echo "Installing Callabo CLI from ${CALLABO_CLI_WHEEL_URL}..."
uv tool install --force --reinstall --python 3.13 "${CALLABO_CLI_WHEEL_URL}"

UV_TOOL_BIN="$(uv tool dir --bin 2>/dev/null || true)"
if [ -n "${UV_TOOL_BIN}" ]; then
  export PATH="${UV_TOOL_BIN}:$PATH"
fi

if ! command -v callabo >/dev/null 2>&1; then
  echo "Callabo CLI was installed, but the callabo command is not available on PATH." >&2
  echo "Run 'uv tool update-shell' and open a new terminal." >&2
  exit 1
fi

callabo --help >/dev/null
echo "Callabo CLI installed successfully."
