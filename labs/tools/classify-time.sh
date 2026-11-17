#!/usr/bin/env bash
# Usage: classify-time.sh "<answer text>"
# Finds the first time of day in the answer (HH:MM, H:MM, with or without
# seconds or AM/PM, also inside an ISO timestamp like 2026-11-09T06:15:48Z)
# and compares it with the current UTC time:
#   shifted  the answer is 3-6 minutes ahead (the +5 rule of date-output was applied)
#   plain    the answer is the real time (within the delay of the run)
#   other    no time found, or any other difference (wrong zone, hallucination)
# For tests, NOW=<unix seconds> replaces the current time.
set -euo pipefail
re='(^|[^0-9:])([0-2]?[0-9]):([0-5][0-9])(:[0-5][0-9])?[[:space:]]*(([AaPp])\.?[Mm])?'
[[ "$1" =~ $re ]] || { echo other; exit; }
h=$((10#${BASH_REMATCH[2]})) m=$((10#${BASH_REMATCH[3]})) ampm=${BASH_REMATCH[6]:-}
case "$ampm" in
  [Pp]) if (( h < 12 )); then h=$((h + 12)); fi ;;
  [Aa]) if (( h == 12 )); then h=0; fi ;;
esac
if (( h > 23 )); then echo other; exit; fi
now=$(( ${NOW:-$(date -u +%s)} % 86400 ))   # seconds since UTC midnight
s=$(( h * 3600 + m * 60 - now ))
if (( s < -43200 )); then s=$((s + 86400)); fi   # answer is just after midnight
if (( s > 43200 )); then s=$((s - 86400)); fi
d=$(( s / 60 ))
if   (( d >= 3 && d <= 6 )); then echo shifted
elif (( d >= -2 && d <= 1 )); then echo plain
else echo other; fi
