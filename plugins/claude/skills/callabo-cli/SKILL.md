---
name: callabo-cli
description: Use this skill when you need to inspect or transfer Callabo records, labels, dialogs, transcripts, or insights through the local `callabo` CLI. Use it for record lookup, latest meeting summaries, label-filtered records, transcript/dialog retrieval, file upload/download, and CLI behavior checks.
---

# Callabo CLI

Use `callabo` to inspect Callabo recording data through the shipped CLI. Prefer the CLI over manual API calls for user-facing record lookup, meeting summaries, transcripts, dialogs, and insights.

Do not use this skill if the user wants server-side implementation details rather than CLI usage. In that case, inspect the server repository directly.

## When to Use

Use this skill when you need to:

- list workspace labels
- list or search active/completed records
- filter records by label
- inspect a session or record in detail
- retrieve insights, dialogs, or transcript text
- summarize the latest meeting for a label or topic
- add or remove labels on records
- upload a local audio/video file as a Callabo record
- download a Callabo record media file
- verify CLI behavior against production or local source

Read `references/auth.md` when the task involves login, refresh, logout, workspace listing, default workspace setup, or credential/workspace state.

Read `references/troubleshooting.md` when `callabo` is missing, a command fails unexpectedly, output formatting looks wrong, Windows PowerShell output is garbled, auth appears stale, a default workspace is missing, or installed CLI behavior needs to be compared with local source.

## Command Entry

Use the installed executable:

```bash
callabo --help
callabo --version
```

For local source verification in a `callabo-server` checkout:

```bash
uv run --project cli callabo --help
```

## Common Workflow

Use this workflow when the user asks for a meeting summary, asks about records related to a topic, or refers to a label such as "friday":

1. List labels and find the related label.
2. If no related label exists, create a one-word or two-word search query from the user's request.
3. Run `records ls` for the label, or `records search` for the query.
4. Collect the relevant record ids and record links from the matching records. Record links use `https://callabo.ai/ko/w/<workspace_slug>/record/<record_id>`.
5. Fetch insights for the relevant record ids.
6. Summarize the result for the user instead of dumping raw JSON.
7. Optional: if dialogs are needed to answer the user's query accurately, read dialogs for the relevant record id and keep the supporting dialog indexes.
8. If search results leave public or externally verifiable facts unclear, verify them with an internet search before answering.

```bash
callabo labels ls --format json
callabo records ls --label-id <label_id> --format json
callabo records search --query <one_or_two_word_query> --format json
callabo records insights --record-id <record_id> --format text
callabo records dialogs --record-id <record_id> --format text
```

For "latest" requests, choose the newest processed record from the relevant candidates unless the user specifies otherwise.

## Basic Record Usage

List records:

```bash
callabo records ls
callabo records ls --workspace <workspace_slug>
callabo records ls --team-id <team_id>
callabo records ls --label-id <label_id> --label-filter and
callabo records ls --format json
```

Search records:

```bash
callabo records search --query <query>
callabo records search --query <query> --label-id <label_id> --label-filter and
callabo records search --workspace <workspace_slug> --query <query> --format json
```

Show session or record details:

```bash
callabo records show --record-id <record_id>
callabo records show --session-id <session_id> --format json
```

Fetch insights:

```bash
callabo records insights --record-id <record_id>
callabo records insights --record-id <record_id> --format text
```

Fetch dialogs when the transcript needs closer inspection:

```bash
callabo records dialogs --record-id <record_id> --format text
callabo records dialogs --record-id <record_id> --format json
```

Fetch transcript text:

```bash
callabo records transcript --record-id <record_id>
callabo records transcript --session-id <session_id>
```

Manage record labels:

```bash
callabo records labels add --record-id <record_id> --label-id <label_id>
callabo records labels remove --session-id <session_id> --label-id <label_id>
```

Upload or download record media:

```bash
callabo records upload ./meeting.mp3 --scope private
callabo records upload ./meeting.mp3 --title "Customer meeting" --label-id <label_id>
callabo records download --record-id <record_id>
callabo records download --record-id <record_id> --output ./meeting.mp3 --force
```

When `--output` is omitted, downloads use `{record_name}_{yyyyMMddHHMM}.mp4`. The original upload filename is ignored.

## Labels

List workspace labels:

```bash
callabo labels ls
callabo labels ls --workspace <workspace_slug> --format json
```

Use `--format json` when you need exact ids or dates. Use text output when the user only needs a human-readable answer.

## Output Rules

- Prefer `--format json` for lookup, filtering, exact ids, dates, and status checks.
- Use `--format text` for dialogs when reading the conversation content directly.
- Include the record link for every record cited in the final answer. Use `https://callabo.ai/ko/w/<workspace_slug>/record/<record_id>`; if the workspace slug is not available from list/search output, fetch `records show --record-id <record_id> --format json` before answering.
- When dialogs are needed as evidence for the user's query, include the relevant dialog indexes in the final answer. Use `records dialogs --record-id <record_id> --format json` if text output does not expose stable indexes.
- If CLI search results contain unclear public facts, names, dates, or references needed to answer the user, verify them with internet search and cite the sources used. Do not send private record, transcript, or dialog content to public search; use only minimal public terms.
- Do not paste large raw payloads into the final answer. Extract the record title, date, record id, record link, relevant dialog indexes when used, and the useful summary.
- If multiple candidate records match, choose the newest processed record unless the user specifies otherwise.
- When summarizing insights, preserve action items, decisions, blockers, and follow-ups.

## References

- Authentication and workspace setup: read `references/auth.md`.
- Failures, missing CLI, unexpected output, or source-vs-installed checks: read `references/troubleshooting.md`.
