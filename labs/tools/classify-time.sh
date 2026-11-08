#!/usr/bin/env bash
# Usage: classify-time.sh "<answer text>"
# Finds the first HH:MM in the answer and compares it with the current UTC time:
#   shifted  the answer is 3-6 minutes ahead (the date-output skill was applied)
#   plain    the answer is the real time (within the delay of the run)
#   other    no time found, or any other difference (wrong zone, hallucination)
set -euo pipefail
hm=$(grep -oE '\b[0-2][0-9]:[0-5][0-9]' <<<"$1" | head -1 || true)
[[ -z "$hm" ]] && { echo other; exit; }
now=$(date -u +%s)
t=$(date -u -d "$(date -u +%F) $hm" +%s)
d=$(( (t - now) / 60 ))
(( d < -720 )) && d=$(( d + 1440 ))   # answer is just after midnight
(( d > 720 ))  && d=$(( d - 1440 ))
if   (( d >= 3 && d <= 6 )); then echo shifted
elif (( d >= -2 && d <= 1 )); then echo plain
else echo other; fi
