#!/bin/zsh
# Arm run 4 and its analysis. Safe to run after a restart.
#
# Usage:  ./scripts/arm_run4.sh [START] [STOP]
#   ./scripts/arm_run4.sh 00:00 06:00
#
# It refuses to arm a second copy if one is already running.
set -eu
cd "$(dirname "$0")/.."
START="${1:-00:00}"; STOP="${2:-06:00}"

if pgrep -f "run_overnight.sh .* pacman_dqn_explore25" >/dev/null; then
  echo "Run 4 is already armed. Nothing to do."
else
  nohup ./scripts/run_overnight.sh "$START" "$STOP" pacman_dqn_explore25.ipynb >/dev/null 2>&1 &
  echo "Armed the run: $START to $STOP."
fi

if pgrep -f "after_run4.sh" >/dev/null; then
  echo "The analysis watcher is already running. Nothing to do."
else
  nohup ./scripts/after_run4.sh >/dev/null 2>&1 &
  echo "Armed the analysis watcher."
fi

sleep 2
echo
echo "Running now:"
pgrep -fl "run_overnight|after_run4" | sed 's/^/  /'
echo
echo "The result will be in results4/ at about 06:25."
