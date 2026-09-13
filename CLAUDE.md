# pacman-dqn — working notes for Claude

Class 3 assignment for Fundamentals of Agentic AI. The brief is
[docs/BRIEF.md](docs/BRIEF.md) — read it before changing the notebook or README.
It is checked against the notebook code, so prefer it over the upstream README.

## AI use is logged

Prompts, actions, and replies are recorded automatically to `docs/ai-log/` by
hooks registered in `~/.claude/settings.json`, which run
`.claude/hooks/log_ai_activity.py`. **Run Claude Code from this directory**, or
the script gates itself off and nothing is recorded. Do not disable the hooks,
and do not edit `AI-LOG.md` or `raw.jsonl` by hand — they are the audit trail.

**When a choice is made, append it to [docs/ai-log/DECISIONS.md](docs/ai-log/DECISIONS.md)**:
what was decided, what else was considered, why, and what it produced. The hooks
cannot capture reasoning; this file is how it gets recorded.

## Ground rules from the brief

- The evaluation settings are fixed: seeds 101/202/303/404/505, 5% exploration,
  3,000-decision cap, applied identically before and after training. Never touch them.
- Report all five before and after scores, never only the means. If the change in
  mean is smaller than the spread across seeds, say the result is within noise.
- A falling loss is not evidence of better play. If the run does not improve, say so.
- Episodes must be a multiple of 25, or there is no intermediate GIF evidence.
- Record the prediction *before* the run, not after.

## Writing style

Plain English, per ASD-STE100: short active sentences, literal wording, no idioms.
The README is the grading entry point — a grader must reproduce the run from it alone.
