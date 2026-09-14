#!/bin/zsh
# Quit the heavy applications, so a long run is not slowed by them.
#
# Usage:  quiet_machine.sh          quit now
#         quiet_machine.sh 23:50    wait until 23:50, then quit
#
# It quits only applications that hold no document state. Note and writing
# applications are left alone on purpose, so nothing unsaved is at risk.
set -eu
cd "$(dirname "$0")/.."
LOG="logs/quiet_machine.log"
mkdir -p logs
exec >>"$LOG" 2>&1
say() { echo "$(date '+%F %T') | $*"; }

# Browsers, chat and media. No editor, and no note application.
HEAVY=("Google Chrome" "Safari" "ChatGPT" "Claude" "zoom.us" "WhatsApp" "Music" "Spotify" "Grok Bot")
# Never touched: Obsidian, Notion, Bear, Terminal, cmux, Finder, Slack, Outlook, Messages.

if [ $# -ge 1 ]; then
  NOW=$(date +%s)
  TARGET=$(date -j -f "%Y-%m-%d %H:%M" "$(date +%Y-%m-%d) $1" +%s)
  [ "$TARGET" -le "$NOW" ] && TARGET=$((TARGET + 86400))
  say "waiting $((TARGET - NOW))s until $1"
  sleep $((TARGET - NOW))
fi

say "memory before:"
vm_stat | awk '/page size/{ps=$8} /Pages free/{gsub(/\./,"",$3); printf "  free %.2f GB\n", $3*ps/1073741824}'
sysctl -n vm.swapusage | sed 's/^/  swap /'

for app in "${HEAVY[@]}"; do
  if osascript -e "tell application \"System Events\" to (name of processes) contains \"$app\"" 2>/dev/null | grep -q true; then
    osascript -e "tell application \"$app\" to quit" >/dev/null 2>&1 || true
    say "asked $app to quit"
  fi
done

sleep 20
# Spotify has ignored a polite quit before. Give the stragglers a firm one.
for app in "${HEAVY[@]}"; do
  if pgrep -f "/Applications/$app.app" >/dev/null 2>&1; then
    pkill -9 -f "/Applications/$app.app" 2>/dev/null || true
    say "forced $app to close"
  fi
done

sleep 5
say "still open:"
osascript -e 'tell application "System Events" to get name of every process whose background only is false' 2>/dev/null \
  | tr ',' '\n' | sed 's/^ /  /'
say "memory after:"
vm_stat | awk '/page size/{ps=$8} /Pages free/{gsub(/\./,"",$3); printf "  free %.2f GB\n", $3*ps/1073741824}'
sysctl -n vm.swapusage | sed 's/^/  swap /'
say "done"
