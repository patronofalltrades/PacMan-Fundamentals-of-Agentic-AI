#!/usr/bin/env python3
"""Append a record of AI activity to docs/ai-log/.

Invoked by Claude Code hooks registered in ~/.claude/settings.json.

SCOPE: this script logs ONLY when the session's working directory is inside
the repository that contains this file. Sessions anywhere else exit silently,
so registering it globally still records nothing but this assignment.

Writes two files:
  docs/ai-log/AI-LOG.md   human-readable transcript: prompts, actions, replies
  docs/ai-log/raw.jsonl   complete machine-readable record, one event per line

Never fails loudly: any error is swallowed so a broken log can never
interrupt a session or a training run.
"""

import datetime
import json
import os
import pathlib
import sys

# Tools worth a line in the human-readable log. Everything else
# (Read, Grep, Glob, TodoWrite...) still lands in raw.jsonl.
MD_TOOLS = {
    "Bash", "Write", "Edit", "MultiEdit", "NotebookEdit",
    "Task", "Agent", "WebFetch", "WebSearch", "Artifact",
}

MAX_MD_CHARS = 4000  # cap any single markdown block; raw.jsonl keeps everything

# The repo root is this file's location, never $CLAUDE_PROJECT_DIR, which
# points at whichever project the session opened.
ROOT = pathlib.Path(__file__).resolve().parents[2]


def in_scope(data: dict) -> bool:
    """True only when the session is working inside this repository."""
    cwd = data.get("cwd") or os.getcwd()
    try:
        pathlib.Path(cwd).resolve().relative_to(ROOT)
        return True
    except Exception:
        return False


def rel(path: str) -> str:
    try:
        return str(pathlib.Path(path).resolve().relative_to(ROOT))
    except Exception:
        return path


def clip(text: str, limit: int = MAX_MD_CHARS) -> str:
    text = text or ""
    if len(text) <= limit:
        return text
    return text[:limit] + f"\n\n[... {len(text) - limit} more characters, see raw.jsonl ...]"


def quote(text: str) -> str:
    """Render text as a markdown blockquote."""
    lines = (text or "").rstrip().splitlines() or [""]
    return "\n".join("> " + line for line in lines)


def last_assistant_text(transcript_path: str):
    """Return (uuid, text) of the final assistant message in a transcript."""
    try:
        with open(transcript_path, "r", encoding="utf-8") as fh:
            lines = fh.readlines()
    except Exception:
        return None, None
    for line in reversed(lines):
        try:
            entry = json.loads(line)
        except Exception:
            continue
        if entry.get("type") != "assistant":
            continue
        content = (entry.get("message") or {}).get("content") or []
        parts = [
            block.get("text", "")
            for block in content
            if isinstance(block, dict) and block.get("type") == "text"
        ]
        text = "\n".join(p for p in parts if p.strip())
        if text.strip():
            return entry.get("uuid"), text
    return None, None


def describe(tool: str, tool_input: dict) -> str:
    """One markdown block describing a tool call."""
    if tool == "Bash":
        cmd = tool_input.get("command", "")
        desc = tool_input.get("description", "")
        head = f"{desc}\n\n" if desc else ""
        return f"{head}```sh\n{clip(cmd)}\n```"
    if tool in ("Write", "Edit", "MultiEdit"):
        return f"`{rel(tool_input.get('file_path', '?'))}`"
    if tool == "NotebookEdit":
        cell = tool_input.get("cell_id", "")
        suffix = f" (cell `{cell}`)" if cell else ""
        return f"`{rel(tool_input.get('notebook_path', '?'))}`{suffix}"
    if tool in ("Task", "Agent"):
        return quote(clip(tool_input.get("prompt", ""), 1500))
    if tool == "WebFetch":
        return f"{tool_input.get('url', '?')}"
    if tool == "WebSearch":
        return f"`{tool_input.get('query', '?')}`"
    if tool == "Artifact":
        return f"`{rel(tool_input.get('file_path', '?'))}`"
    return ""


def main() -> None:
    event = sys.argv[1] if len(sys.argv) > 1 else "Unknown"

    raw_stdin = sys.stdin.read() if not sys.stdin.isatty() else ""
    try:
        data = json.loads(raw_stdin) if raw_stdin.strip() else {}
    except Exception:
        data = {}

    if not in_scope(data):
        return  # a session outside this repository is not logged

    logdir = ROOT / "docs" / "ai-log"
    logdir.mkdir(parents=True, exist_ok=True)

    now = datetime.datetime.now()
    clock = now.strftime("%H:%M")
    session = str(data.get("session_id") or "unknown")

    # --- complete machine-readable record -------------------------------
    record = {
        "time": now.isoformat(timespec="seconds"),
        "event": event,
        "session_id": session,
        "cwd": data.get("cwd"),
    }
    if event == "UserPromptSubmit":
        record["prompt"] = data.get("prompt")
    elif event == "PostToolUse":
        record["tool"] = data.get("tool_name")
        record["tool_input"] = data.get("tool_input")
    with open(logdir / "raw.jsonl", "a", encoding="utf-8") as fh:
        fh.write(json.dumps(record, ensure_ascii=False, default=str) + "\n")

    # --- human-readable log ---------------------------------------------
    statefile = logdir / ".state.json"
    try:
        state = json.loads(statefile.read_text(encoding="utf-8"))
    except Exception:
        state = {}

    blocks = []

    # Start a new session heading whenever the session id changes.
    if state.get("session") != session:
        blocks.append(
            f"\n\n---\n\n## Session — {now.strftime('%A %-d %B %Y, %H:%M')}\n"
            f"\n`{session[:8]}`\n"
        )
        state["session"] = session

    if event == "UserPromptSubmit":
        prompt = data.get("prompt") or ""
        if prompt.strip():
            blocks.append(f"\n### {clock} · Hanif asked\n\n{quote(clip(prompt))}\n")

    elif event == "PostToolUse":
        tool = data.get("tool_name") or "?"
        if tool in MD_TOOLS:
            body = describe(tool, data.get("tool_input") or {})
            blocks.append(f"\n### {clock} · {tool}\n\n{body}\n" if body
                          else f"\n### {clock} · {tool}\n")

    elif event == "Stop":
        uuid, text = last_assistant_text(data.get("transcript_path") or "")
        if text and uuid != state.get("last_reply"):
            blocks.append(f"\n### {clock} · Claude replied\n\n{clip(text)}\n")
            state["last_reply"] = uuid

    if blocks:
        with open(logdir / "AI-LOG.md", "a", encoding="utf-8") as fh:
            fh.write("".join(blocks))

    try:
        statefile.write_text(json.dumps(state), encoding="utf-8")
    except Exception:
        pass


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass  # logging must never break the session
    sys.exit(0)
