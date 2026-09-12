#!/bin/zsh
# Stop the notebook's training loop at a wall-clock time, and keep the Mac awake until then.
#
# Usage:  ./stop_training_at.sh 06:00
#
# Start the notebook and choose Run All first, then run this. It finds the
# notebook kernel, waits until the given time, and sends one interrupt.
# The notebook catches that interrupt, records the run as "interrupted",
# saves the model, metrics and plot, and continues to the evaluation section.

set -eu

STOP_AT="${1:-06:00}"
# Work from the project root, one level above this script.
cd "$(dirname "$0")/.."

echo "Waiting for the notebook kernel..."
while true; do
  PIDS=$(pgrep -f ipykernel_launcher || true)
  [ -n "$PIDS" ] && break
  sleep 5
done

COUNT=$(echo "$PIDS" | wc -l | tr -d ' ')
if [ "$COUNT" -ne 1 ]; then
  echo "Found $COUNT kernels:"
  echo "$PIDS"
  echo "Close the other notebooks, then run this again."
  exit 1
fi
KERNEL="$PIDS"

# Mark the moment, so a run folder from an earlier night cannot match.
MARKER="$(mktemp -t pacman_marker)"

NOW=$(date +%s)
TARGET=$(date -j -f "%Y-%m-%d %H:%M" "$(date +%Y-%m-%d) $STOP_AT" +%s)
[ "$TARGET" -le "$NOW" ] && TARGET=$((TARGET + 86400))
WAIT=$((TARGET - NOW))

echo "Kernel PID $KERNEL."
echo "Interrupt at $STOP_AT, in $((WAIT / 3600))h $(((WAIT % 3600) / 60))m."
echo "Keeping the Mac awake until then. Leave the lid open."

caffeinate -dims sleep "$WAIT"

# training_summary.json is written only when the training loop ends.
# If it exists, training is already over and an interrupt would break evaluation.
# Only this run's folder counts. Earlier run folders also hold that file, so
# compare against the marker touched when this script started. BSD find has no
# -newermt, only -newer, so a marker file is the portable test.
RUN_DIR=$(/usr/bin/find pacman_runs -mindepth 1 -maxdepth 1 -type d \
          -newer "$MARKER" 2>/dev/null | sort | tail -1)
rm -f "$MARKER"
if [ -n "$RUN_DIR" ] && [ -f "$RUN_DIR/training_summary.json" ]; then
  echo "$(date '+%H:%M:%S') Training already ended in $RUN_DIR. No interrupt sent."
  exit 0
fi

if kill -0 "$KERNEL" 2>/dev/null; then
  kill -INT "$KERNEL"
  echo "$(date '+%H:%M:%S') Sent one interrupt to PID $KERNEL."
  echo "Check the notebook: it saves the run, then continues to section 6."
else
  echo "$(date '+%H:%M:%S') Kernel $KERNEL is gone. Check the notebook."
fi
