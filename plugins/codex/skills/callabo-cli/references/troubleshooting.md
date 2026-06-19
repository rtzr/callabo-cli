# Troubleshooting

If `callabo` is not found after installation, update the shell configuration and open a new terminal:

```bash
uv tool update-shell
```

To inspect the executable directory directly:

```bash
uv tool dir --bin
```

On Windows, rerun the command in a new Command Prompt or PowerShell window after `uv tool update-shell`.

If a `records` command fails without `--workspace`, check the default workspace:

```bash
callabo workspace default
```

If needed, set it again:

```bash
callabo workspace default <workspace_slug>
```

If search or dialogs return unexpected formatting, compare text and JSON output:

```bash
callabo records dialogs --record-id <record_id> --format text
callabo records dialogs --record-id <record_id> --format json
```

If output is garbled in Windows PowerShell, ask the user to update to the latest CLI first. Current CLI versions configure stdout and stderr as UTF-8 on Windows.

```powershell
irm https://raw.githubusercontent.com/rtzr/callabo-cli/main/dist/install.ps1 | iex
callabo --help
```

If output is still garbled after updating, set the current PowerShell session output encoding to UTF-8 and retry the command:

```powershell
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [System.Text.UTF8Encoding]::new($false)
callabo records ls
```

This PowerShell setting applies only to the current shell session. It must be set again in a new PowerShell window unless the user adds it to their PowerShell profile.

If behavior differs between local source and the installed CLI, compare:

```bash
uv run --project cli callabo ...
callabo ...
```

To check the installed CLI version:

```bash
callabo --version
```

To update the installed CLI, rerun the install script.

If authentication appears stale, refresh credentials:

```bash
callabo auth refresh
```

If auth fails with `No recommended backend was available`, update the CLI and retry login. Current CLI versions use `~/.config/callabo/credentials.json` when a Linux keyring backend is unavailable.

To use the Linux system keyring instead of the fallback credentials file, install and run a Freedesktop Secret Service backend such as GNOME Keyring.

On Debian or Ubuntu desktop environments:

```bash
sudo apt install gnome-keyring dbus-user-session
```

Log out and log back in so the D-Bus user session and keyring daemon are available to terminal processes. Then verify that Python keyring can detect a usable backend:

```bash
uv run --project cli python -m keyring diagnose
uv run --project cli python -m keyring --list-backends
```

A usable GNOME Keyring setup should expose `keyring.backends.SecretService.Keyring`. Headless Linux, containers, and WSL require an active D-Bus session and an unlocked keyring; otherwise Python keyring will continue to report that no recommended backend is available.

On Windows, Python keyring should use Windows Credential Locker. If auth storage fails on Windows, verify the detected backend:

```bat
python -m keyring --list-backends
```

If the install script fails while installing from GitHub, override the release version or wheel URL and rerun it:

```bash
CALLABO_CLI_VERSION=x.y.z sh cli/install.sh
CALLABO_CLI_WHEEL_URL=https://github.com/rtzr/callabo-cli/releases/download/vx.y.z/callabo_cli-x.y.z-py3-none-any.whl sh cli/install.sh
```

On Windows:

```powershell
$env:CALLABO_CLI_VERSION = "x.y.z"
.\cli\install.ps1
```

If the user asks to install or refresh the skill into local agents:

```bash
callabo skill setup
callabo skill setup --agent codex --scope user
callabo skill setup --agent claude --scope project --force
```
