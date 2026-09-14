#!/bin/zsh
# Collect the evidence for one run, and measure it against run 1.
#
# Usage:  analyse_run.sh DEST RUN_DIR [LABEL]
#   ./scripts/analyse_run.sh results3 pacman_runs/20260913_103052_091454 "run3_clip_0.10"
#
# It copies the published evidence, counts the reward the game paid at every
# decision of the five test games, and tests this run's network against run 1's
# at the same game number. It never writes into results/, which holds run 1.
set -eu
cd "$(dirname "$0")/.."
DEST="$1"; RUN="${2%/}"; LABEL="${3:-$(basename "$RUN")}"
PY=".venv/bin/python"
RUN1_CKPT="pacman_runs/20260912_004744_000546/episode_7625.pt"

[ -d "$RUN" ] || { echo "No such run folder: $RUN"; exit 1; }
[ "$DEST" = "results" ] && { echo "Refusing to overwrite results/, which holds run 1."; exit 1; }
mkdir -p "$DEST"

echo "== collecting from $RUN into $DEST"
for f in config.json comparison.json training.csv training_summary.json \
         demo_scores.json training_dashboard.png baseline.json; do
  [ -f "$RUN/$f" ] && cp "$RUN/$f" "$DEST/" && echo "   + $f"
done

if [ -f "$RUN/trained.pt" ]; then
  echo "== counting the reward paid at every decision of the five test games"
  $PY scripts/reward_events.py "$LABEL=$RUN/trained.pt" 2>/dev/null \
    | grep -vE '^A\.L\.E|^\[Powered|^Your experiment|^Python 3|^\{' > "$DEST/reward_events.txt"
  cat "$DEST/reward_events.txt"
else
  echo "!! no trained.pt; the run did not reach the save step"
fi

if [ -f "$RUN/episode_7625.pt" ] && [ -f "$RUN1_CKPT" ]; then
  echo "== testing both networks at game 7625, so the runs match on experience"
  $PY scripts/matched_eval.py "run1_clip_0.15=$RUN1_CKPT" "$LABEL=$RUN/episode_7625.pt" 2>/dev/null \
    | grep -E '^run|^matched' | tee "$DEST/matched_eval.txt"
  [ -f matched_eval.json ] && mv matched_eval.json "$DEST/matched_eval.json"
else
  echo "!! no episode_7625.pt in this run; the matched test is not possible"
fi

echo "== summary"
$PY - "$DEST" <<'PY'
import json, sys, pathlib
d = pathlib.Path(sys.argv[1])
c = json.loads((d / "comparison.json").read_text())
s = json.loads((d / "training_summary.json").read_text())
print(f"   status {s['status']}, {s['completed_episodes']} games, {s['total_decisions']:,} decisions")
print(f"   before {c['before']['mean']:.0f}  after {c['after']['mean']:.0f}  "
      f"scores {[int(x) for x in c['after']['scores']]}")
print(f"   run 1 after was 2578, scores [2790, 2330, 2610, 3110, 2050]")
PY
