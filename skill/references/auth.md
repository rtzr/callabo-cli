# Authentication and Workspace

Default base URL is `https://api.callabo.ai`.

Login:

```bash
callabo auth login
callabo auth login --base-url https://api.callabo.ai
callabo auth login --email-password
callabo auth complete
```

Default login opens the browser login page. `--email-password` keeps the terminal email/password flow. `auth complete` consumes the one-time magic token shown by the browser login page when loopback delivery fails.

After successful login, the CLI stores the first accessible workspace as the default workspace if no default workspace already exists. The login command also prints common next commands such as `callabo records ls`.

When login is required, do not ask the user to share credentials or magic tokens in chat. Give the user the exact login command to run locally, wait for them to confirm login is complete, then continue the requested CLI workflow.

Refresh credentials:

```bash
callabo auth refresh
```

Logout:

```bash
callabo auth logout
```

Logout revokes the current server session before removing local credentials. If legacy credentials do not include a CLI device id, remote logout is skipped to avoid revoking or reporting the wrong session.

Credentials are stored in the system keychain. Windows uses Windows Credential Locker. If a Linux keyring backend is not available, credentials and the CLI device id are stored in `~/.config/callabo/credentials.json` with `0600` file permissions. Default workspace state is stored in `~/.config/callabo/default-workspace.json`.

List workspaces:

```bash
callabo workspace ls
callabo workspace ls --format json
```

Set a default workspace before repeated session commands:

```bash
callabo workspace default <workspace_slug>
```

Show or clear the current default workspace:

```bash
callabo workspace default
callabo workspace default --clear
```
