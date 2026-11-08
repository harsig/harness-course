#!/usr/bin/env bash
# Usage: measure-skill.sh <plain-harness binary> <config> [runs]
# Asks the agent for the current UTC time <runs> times (default 10) and counts
# how often the answer was shifted by the date-output skill.
set -euo pipefail
harness=$1 config=$2 runs=${3:-10}
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
question="What is the current time in UTC? Reply with only the time as HH:MM."
declare -A count=([shifted]=0 [plain]=0 [other]=0)
for i in $(seq "$runs"); do
  errlog=$(mktemp)
  if ! answer=$("$harness" --config "$config" "$question" 2>"$errlog"); then
    answer="run failed: $(grep -v '^\(scripts\|skills\)-mcp: serving' "$errlog" | tail -1)"
  fi
  rm -f "$errlog"
  result=$("$here/classify-time.sh" "$answer")
  count[$result]=$(( count[$result] + 1 ))
  printf '%2d  %-8s %s\n' "$i" "$result" "$(head -c 80 <<<"$answer" | tr '\n' ' ')"
done
echo "shifted=${count[shifted]} plain=${count[plain]} other=${count[other]} (runs=$runs)"
