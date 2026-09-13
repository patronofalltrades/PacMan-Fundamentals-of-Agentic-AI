# AI activity log

An automatic record of how this assignment was built with Claude Code.
Logging is scoped to this repository only — no other work on the machine is recorded.

| File | What it holds | Written by |
|---|---|---|
| [AI-LOG.md](AI-LOG.md) | Readable transcript: every prompt verbatim, every action that changed something, every Claude reply | hooks, automatically |
| [DECISIONS.md](DECISIONS.md) | Why choices were made, and what they produced | by hand |
| `raw.jsonl` | Complete machine-readable record, one JSON event per line, including reads and searches | hooks, automatically |

## How it works

Three hooks all run [`.claude/hooks/log_ai_activity.py`](../../.claude/hooks/log_ai_activity.py):

- **`UserPromptSubmit`** — appends the prompt, verbatim, before Claude sees it
- **`PostToolUse`** — appends every tool call after it succeeds
- **`Stop`** — appends Claude's reply at the end of each turn

`AI-LOG.md` keeps only actions that change something — writes, edits, notebook
edits, shell commands, searches, subagents. Reads and greps would bury the
signal, so they go to `raw.jsonl` only.

The script fails silently by design: a logging error can never interrupt a
session or a training run.

### Where the hooks are registered

They live in `~/.claude/settings.json`, **not** in this repository. Claude Code
only picks up a project's `.claude/settings.json` if that file exists when the
session starts, which made it unreliable here. Registering globally is
dependable, and the script gates itself: it resolves its own location to find
this repository, and exits silently unless the session's working directory is
inside it.

The practical consequence: **run Claude Code from this directory** for work on
this assignment. A session started elsewhere records nothing, even if it edits
these files.

The registered entries, for reference:

```json
{
  "hooks": {
    "UserPromptSubmit": [{ "hooks": [{ "type": "command", "timeout": 10,
      "command": "/usr/bin/python3 \"<repo>/.claude/hooks/log_ai_activity.py\" UserPromptSubmit" }] }],
    "PostToolUse":      [{ "hooks": [{ "type": "command", "timeout": 10,
      "command": "/usr/bin/python3 \"<repo>/.claude/hooks/log_ai_activity.py\" PostToolUse" }] }],
    "Stop":             [{ "hooks": [{ "type": "command", "timeout": 10,
      "command": "/usr/bin/python3 \"<repo>/.claude/hooks/log_ai_activity.py\" Stop" }] }]
  }
}
```

Do not also add these to a project-level `.claude/settings.json` — both copies
would fire and every event would be logged twice.

## Querying the raw log

```sh
# every prompt, in order
jq -r 'select(.event=="UserPromptSubmit") | "\(.time)  \(.prompt)"' raw.jsonl

# every shell command run
jq -r 'select(.tool=="Bash") | .tool_input.command' raw.jsonl

# count events by type
jq -r '.event' raw.jsonl | sort | uniq -c
```

## Before submitting

This log is **tracked by git** and will be public when the repository is.
It contains your prompts verbatim. Read it before pushing. To keep it local
instead, add to `.gitignore`:

```
docs/ai-log/
```
