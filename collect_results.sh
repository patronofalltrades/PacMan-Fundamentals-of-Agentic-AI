#!/usr/bin/env bash
# Copy the evidence from the newest run in pacman_runs/ into results/ for publishing.
# Model checkpoints (*.pt) are left behind on purpose; they stay in the local ZIP.
set -euo pipefail
RUN="${1:-$(ls -d pacman_runs/*/ 2>/dev/null | sort | tail -1)}"
[ -n "$RUN" ] && [ -d "$RUN" ] || { echo "No run folder found. Pass one as an argument."; exit 1; }
echo "Collecting from: $RUN"
rm -rf results && mkdir -p results/demos
for f in config.json comparison.json training.csv training_summary.json demo_scores.json training_dashboard.png; do
  [ -f "$RUN$f" ] && cp "$RUN$f" results/ && echo "  + $f"
done
cp "$RUN"demos/*.gif results/demos/ 2>/dev/null && echo "  + $(ls results/demos | wc -l | tr -d ' ') GIFs"
echo "Kept out of results/ (large): $(ls "$RUN"*.pt 2>/dev/null | wc -l | tr -d ' ') checkpoints and the run ZIP."
du -sh results
