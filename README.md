# Callabo CLI

Callabo CLI는 Callabo 인증과 record 조회, 업로드, 다운로드를 터미널에서 실행하기 위한 도구입니다.

이 저장소는 배포용 저장소입니다. CLI 소스 코드는 `rtzr/callabo-server`의 `cli/` 디렉터리를 기준으로 관리하고, 이 저장소에는 최신 설치 스크립트와 wheel artifact만 배포합니다.

## 설치

### macOS 또는 Linux

```bash
curl -LsSf https://raw.githubusercontent.com/rtzr/callabo-cli/main/dist/install.sh | sh
```

### Windows

PowerShell에서 아래 명령을 실행합니다.

```powershell
irm https://raw.githubusercontent.com/rtzr/callabo-cli/main/dist/install.ps1 | iex
```

설치 스크립트는 `uv`가 없으면 먼저 `uv`를 설치한 뒤, GitHub Release에 업로드된 Callabo CLI wheel을 설치합니다.

설치 후 아래 명령으로 `callabo` 명령이 실행되는지 확인합니다.

```bash
callabo --help
```

`callabo` 명령을 찾을 수 없으면 아래 명령을 실행한 뒤 새 터미널을 엽니다.

```bash
uv tool update-shell
```

## 특정 버전 설치

기본 설치 스크립트는 GitHub Release의 최신 버전을 확인한 뒤 해당 wheel을 설치합니다.

다른 버전을 설치하려면 `CALLABO_CLI_VERSION`을 지정합니다.

```bash
curl -LsSf https://raw.githubusercontent.com/rtzr/callabo-cli/main/dist/install.sh | CALLABO_CLI_VERSION=0.1.10 sh
```

특정 wheel URL을 직접 지정할 수도 있습니다.

```bash
curl -LsSf https://raw.githubusercontent.com/rtzr/callabo-cli/main/dist/install.sh | CALLABO_CLI_WHEEL_URL=https://github.com/rtzr/callabo-cli/releases/download/v0.1.10/callabo_cli-0.1.10-py3-none-any.whl sh
```

Windows에서는 설치 파일 실행 전에 환경 변수를 지정합니다.

```powershell
$env:CALLABO_CLI_VERSION = "0.1.10"
irm https://raw.githubusercontent.com/rtzr/callabo-cli/main/dist/install.ps1 | iex
```

## 최초 구성

### 1. 로그인

기본 로그인은 브라우저에서 진행합니다. Google, Apple, email/password 로그인을 완료하면 CLI가 로컬 callback으로 인증을 완료하고 토큰을 저장합니다.
로그인 성공 시 접근 가능한 workspace 목록의 첫 번째 workspace를 기본 workspace로 저장합니다. 이미 저장된 기본 workspace가 있으면 기존 값을 유지합니다.

```bash
callabo auth login
```

브라우저가 열리지 않는 서버나 headless 환경에서는 로그인 페이지에 표시되는 magic token을 터미널에서 입력합니다.

```bash
callabo auth complete
```

터미널에서 이메일과 비밀번호를 직접 입력해야 하면 `--email-password` 옵션을 사용합니다.

```bash
callabo auth login --email-password
```

기본 API base URL은 `https://api.callabo.ai`입니다. 다른 서버를 사용해야 하면 로그인 시 `--base-url`을 지정합니다.

```bash
callabo auth login --base-url https://api.callabo.ai
```

### 2. Workspace 확인

로그인 후 접근 가능한 workspace 목록을 확인합니다.

```bash
callabo workspace ls
```

JSON 출력이 필요하면 `--format json`을 사용합니다.

```bash
callabo workspace ls --format json
```

### 3. 기본 Workspace 저장

반복해서 사용할 workspace slug를 기본값으로 저장합니다.

```bash
callabo workspace default <workspace_slug>
```

저장된 기본 workspace를 확인하거나 삭제할 수 있습니다.

```bash
callabo workspace default
callabo workspace default --clear
```

기본 workspace를 저장하면 `records` 명령에서 `--workspace` 옵션을 생략할 수 있습니다.

```bash
callabo records ls
```

기본 workspace를 저장하지 않은 경우에는 명령마다 `--workspace`를 지정합니다.

```bash
callabo records ls --workspace <workspace_slug>
```

## 주요 명령

아래 목록은 `callabo, version 0.1.10`의 `--help` 출력 기준이며, command별 대표 옵션만 정리합니다.

```text
callabo
├── auth
│   ├── login
│   ├── complete
│   ├── refresh
│   ├── resend-link
│   └── logout
├── workspace
│   ├── ls
│   └── default
├── labels
│   └── ls
├── records
│   ├── ls
│   ├── search
│   ├── show
│   ├── transcript
│   ├── insights
│   ├── dialogs
│   ├── upload
│   ├── download
│   └── labels
│       ├── add
│       └── remove
└── skill
    └── setup
```

### Auth

| 명령 | 대표 옵션 |
| --- | --- |
| `callabo auth login` | `--email-password`, `--base-url`, `--login-url` |
| `callabo auth complete` | `[TOKEN]`, `--base-url` |
| `callabo auth refresh` | 없음 |
| `callabo auth resend-link` | 없음 |
| `callabo auth logout` | 없음 |

### Workspace와 Labels

| 명령 | 대표 옵션 |
| --- | --- |
| `callabo workspace ls` | `--format text/json` |
| `callabo workspace default` | `[workspace_slug]`, `--clear`, `--format text/json` |
| `callabo labels ls` | `--workspace`, `--format text/json` |

### Records

| 명령 | 대표 옵션 |
| --- | --- |
| `callabo records ls` | `--workspace`, `--team-id`, `--label-id`, `--label-filter and/or`, `--format text/json` |
| `callabo records search` | `--query`, `--workspace`, `--team-id`, `--label-id`, `--label-filter and/or`, `--format text/json` |
| `callabo records show` | `--record-id`, `--session-id`, `--workspace`, `--format text/json` |
| `callabo records transcript` | `--record-id`, `--session-id`, `--workspace`, `--format text/json` |
| `callabo records insights` | `--record-id`, `--session-id`, `--workspace`, `--format text/json` |
| `callabo records dialogs` | `--record-id`, `--session-id`, `--workspace`, `--format text/json` |
| `callabo records upload` | `<file_path>`, `--workspace`, `--title`, `--scope workspace/team/private`, `--team-id`, `--label-id`, `--language`, `--format text/json` |
| `callabo records download` | `--record-id`, `--workspace`, `--output`, `--force` |

### Record Labels

| 명령 | 대표 옵션 |
| --- | --- |
| `callabo records labels add` | `--record-id`, `--session-id`, `--label-id`, `--workspace` |
| `callabo records labels remove` | `--record-id`, `--session-id`, `--label-id`, `--workspace` |

### Skill

| 명령 | 대표 옵션 |
| --- | --- |
| `callabo skill setup` | `--agent codex/claude/gemini`, `--scope user/project`, `--force` |

각 명령의 전체 옵션은 `--help`로 확인합니다.

```bash
callabo <command_path> --help
```

## 저장 위치

인증 토큰과 device id는 시스템 keychain에 저장합니다. Windows에서는 Windows Credential Locker를 사용합니다.

Linux에서 keyring backend를 사용할 수 없으면 인증 정보는 `~/.config/callabo/credentials.json`에 저장합니다. 기본 workspace 설정은 `~/.config/callabo/default-workspace.json`에 저장합니다.

## 로그아웃

현재 세션을 종료하고 로컬 인증 정보를 삭제합니다.

```bash
callabo auth logout
```
