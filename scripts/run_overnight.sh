#!/bin/zsh
# Run the whole experiment unattended. No browser and no Jupyter server.
#
# Usage:  ./run_overnight.sh [START] [STOP] [NOTEBOOK]
#   ./run_overnight.sh 00:00 06:00
#
# It waits until START, executes the notebook headless, sends one interrupt at
# STOP, and lets the remaining cells finish. The notebook catches the interrupt,
# records the run as "interrupted", and saves the model, metrics and plot.
# The Mac is held awake from the moment this starts until the script exits.

set -eu

# The project root is one level above this script.
PROJECT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT"

START_AT="${1:-00:00}"
STOP_AT="${2:-06:00}"
NOTEBOOK="${3:-pacman_dqn.ipynb}"
PY="$PROJECT/.venv/bin/python"

LOG_DIR="$PROJECT/logs"
mkdir -p "$LOG_DIR"
STAMP="$(date +%Y%m%d_%H%M%S)"
LOG="$LOG_DIR/overnight_$STAMP.log"

exec >>"$LOG" 2>&1

say() { echo "$(date '+%F %T') | $*"; }

# Seconds from now until the next occurrence of HH:MM.
seconds_until() {
  local now target
  now=$(date +%s)
  target=$(date -j -f "%Y-%m-%d %H:%M" "$(date +%Y-%m-%d) $1" +%s)
  [ "$target" -le "$now" ] && target=$((target + 86400))
  echo $((target - now))
}

# The run folder this execution created, if any. Folders from earlier runs
# also contain training_summary.json, so match on creation time, not on order.
# Compare against a marker file: BSD find has no -newermt, only -newer.
# Call /usr/bin/find directly, so no shell shim on PATH can change the syntax.
this_run_dir() {
  [ -f "$MARKER" ] || return 0
  /usr/bin/find pacman_runs -mindepth 1 -maxdepth 1 -type d \
       -newer "$MARKER" 2>/dev/null | sort | tail -1
}

# Hold the machine awake for the lifetime of this script.
caffeinate -dims -w $$ &
say "caffeinate armed (pid $!)"

say "notebook: $NOTEBOOK"
say "log: $LOG"
df -h . | tail -1

WAIT_START=$(seconds_until "$START_AT")
say "waiting ${WAIT_START}s until $START_AT"
sleep "$WAIT_START"

# nbconvert --inplace rewrites the notebook. Keep the pristine copy.
cp "$NOTEBOOK" "$LOG_DIR/${NOTEBOOK%.ipynb}.pre_$STAMP.ipynb"
say "backup: $LOG_DIR/${NOTEBOOK%.ipynb}.pre_$STAMP.ipynb"

# Mark the moment. Only a run folder created after this belongs to this run.
MARKER="$LOG_DIR/.run_marker_$STAMP"
touch "$MARKER"

say "executing $NOTEBOOK"
"$PY" -m nbconvert --to notebook --execute --inplace \
      --ExecutePreprocessor.timeout=-1 "$NOTEBOOK" &
NB=$!
say "nbconvert pid $NB"

# The kernel is a child of nbconvert. Match on the child first, so another
# open notebook elsewhere on the machine cannot be signalled by mistake.
KERNEL=""
for _ in $(seq 1 180); do
  KERNEL=$(pgrep -P "$NB" -f ipykernel_launcher || true)
  [ -n "$KERNEL" ] && break
  kill -0 "$NB" 2>/dev/null || { say "FAILED: nbconvert exited during startup"; wait "$NB"; exit 1; }
  sleep 1
done
[ -z "$KERNEL" ] && { say "FAILED: no kernel found"; kill "$NB" 2>/dev/null || true; exit 1; }
say "kernel pid $KERNEL"

WAIT_STOP=$(seconds_until "$STOP_AT")
say "training until $STOP_AT, ${WAIT_STOP}s"
sleep "$WAIT_STOP"

# training_summary.json is written only when the training loop ends. If it is
# there, training is over and an interrupt now would break the evaluation.
RUN_DIR=$(this_run_dir)
if [ -n "$RUN_DIR" ] && [ -f "$RUN_DIR/training_summary.json" ]; then
  say "training already ended in $RUN_DIR. No interrupt sent"
elif kill -0 "$KERNEL" 2>/dev/null; then
  kill -INT "$KERNEL"
  say "sent one interrupt to kernel $KERNEL"
else
  say "kernel $KERNEL already gone"
fi

say "waiting for evaluation and saving to finish"
wait "$NB" && RC=0 || RC=$?
say "nbconvert exit code $RC"

RUN_DIR=$(this_run_dir)
if [ -n "$RUN_DIR" ] && [ -f "$RUN_DIR/training_summary.json" ]; then
  say "summary: $(tr -d '\n ' < "$RUN_DIR/training_summary.json")"
  say "run folder: $RUN_DIR"
else
  say "WARNING: no training_summary.json found"
fi
say "done"
