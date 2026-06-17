#!/usr/bin/env sh
set -eu

CALLABO_CLI_REPO="${CALLABO_CLI_REPO:-https://github.com/rtzr/callabo-cli}"
CALLABO_CLI_REPO="${CALLABO_CLI_REPO%/}"

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

fetch_url() {
  url="$1"

  if command -v curl >/dev/null 2>&1; then
    curl -LsSf "$url"
    return
  fi

  if command -v wget >/dev/null 2>&1; then
    wget -qO- "$url"
    return
  fi

  echo "curl or wget is required to fetch Callabo CLI release metadata." >&2
  exit 1
}

latest_release_version() {
  repo_path="${CALLABO_CLI_REPO#https://github.com/}"
  api_url="https://api.github.com/repos/${repo_path}/releases/latest"
  tag_name="$(fetch_url "$api_url" | sed -n 's/.*"tag_name"[[:space:]]*:[[:space:]]*"v\{0,1\}\([^"]*\)".*/\1/p' | head -n 1)"

  if [ -z "$tag_name" ]; then
    echo "Failed to resolve the latest Callabo CLI release version." >&2
    exit 1
  fi

  printf "%s" "$tag_name"
}

callabo_cli_wheel_url() {
  if [ -n "${CALLABO_CLI_WHEEL_URL:-}" ]; then
    printf "%s" "$CALLABO_CLI_WHEEL_URL"
    return
  fi

  if [ -n "${CALLABO_CLI_VERSION:-}" ]; then
    version="$CALLABO_CLI_VERSION"
  else
    version="$(latest_release_version)"
  fi

  printf "%s/releases/download/v%s/callabo_cli-%s-py3-none-any.whl" "$CALLABO_CLI_REPO" "$version" "$version"
}

CALLABO_CLI_WHEEL_URL="$(callabo_cli_wheel_url)"

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
