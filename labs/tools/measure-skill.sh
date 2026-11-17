#!/usr/bin/env bash
# Usage: measure-skill.sh <plain-harness binary> <config> [runs] [skill tool name]
# Asks the agent for the current UTC time <runs> times (default 10) and records
# two things per run:
#   shifted / plain / other   was the +5 rule applied? (classify-time.sh)
#   loaded / -                did the model call the skill tool? Read from the
#                             harness log line "tool call: <skill tool name>"
#                             (default skills-mcp__date-output).
# The two are separate: the skill's description is always in the context, so a
# model can shift the time without loading the skill, and load it without shifting.
set -euo pipefail
harness=$1 config=$2 runs=${3:-10} skill=${4:-skills-mcp__date-output}
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
question="What is the current time in UTC? Reply with only the time as HH:MM."
declare -A count=([shifted]=0 [plain]=0 [other]=0)
declare -A cross=()
loaded_total=0
for i in $(seq "$runs"); do
  errlog=$(mktemp)
  if ! answer=$("$harness" --config "$config" "$question" 2>"$errlog"); then
    answer="run failed: $(grep -v '^\(scripts\|skills\)-mcp: serving' "$errlog" | tail -1)"
  fi
  loaded="-"
  if grep -qF "tool call: $skill" "$errlog"; then
    loaded=loaded
    loaded_total=$(( loaded_total + 1 ))
  fi
  rm -f "$errlog"
  result=$("$here/classify-time.sh" "$answer")
  count[$result]=$(( count[$result] + 1 ))
  cross[$result,$loaded]=$(( ${cross[$result,$loaded]:-0} + 1 ))
  printf '%2d  %-8s %-7s %s\n' "$i" "$result" "$loaded" "$(head -c 80 <<<"$answer" | tr '\n' ' ')"
done
echo "shifted=${count[shifted]} plain=${count[plain]} other=${count[other]} loaded=$loaded_total (runs=$runs)"
for r in shifted plain other; do
  echo "  $r: loaded=${cross[$r,loaded]:-0} not-loaded=${cross[$r,-]:-0}"
done
