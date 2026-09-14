#!/bin/zsh
# Wait for run 4 to finish, then produce results4/ without anyone present.
#
# The analysis must not depend on a person or a chat session being awake at
# 06:15. This waits for the run folder to appear, waits for the notebook process
# to end, and then runs scripts/analyse_run.sh.
set -eu
cd "$(dirname "$0")/.."
LOG="logs/after_run4.log"
exec >>"$LOG" 2>&1
say() { echo "$(date '+%F %T') | $*"; }

# Hold the machine awake for as long as this script lives. run_overnight.sh
# releases its own hold when it exits, which is before this work is done.
caffeinate -dims -w $$ &
say "caffeinate armed (pid $!)"

say "waiting for the run 4 folder"
RUN=""
for _ in $(seq 1 720); do            # up to 12 hours, checked every minute
  RUN=$(/usr/bin/find pacman_runs -mindepth 1 -maxdepth 1 -type d -name '20260914_*' 2>/dev/null | sort | tail -1)
  [ -n "$RUN" ] && break
  sleep 60
done
[ -n "$RUN" ] || { say "FAILED: no run 4 folder appeared"; exit 1; }
say "run folder: $RUN"

say "waiting for the notebook process to end"
for _ in $(seq 1 900); do            # up to 15 hours
  pgrep -f "nbconvert.*explore25" >/dev/null || break
  sleep 60
done
if pgrep -f "nbconvert.*explore25" >/dev/null; then
  say "FAILED: the notebook is still running"; exit 1
fi
say "notebook finished"

# comparison.json is the last thing the notebook writes. Give it a moment.
for _ in $(seq 1 30); do
  [ -f "$RUN/comparison.json" ] && break
  sleep 10
done
[ -f "$RUN/comparison.json" ] || { say "WARNING: no comparison.json in $RUN"; }

say "running the analysis"
./scripts/analyse_run.sh results4 "$RUN" "run4_clip_0.25"
say "done. results4/ is ready"
