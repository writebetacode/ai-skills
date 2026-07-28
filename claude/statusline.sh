#!/usr/bin/env bash
# Claude Code statusline. Input: JSON on stdin (see `code.claude.com/docs/en/statusline`).
set -uo pipefail

input=$(cat)

# Single jq pass: emit shell-quoted assignments so values with spaces survive.
# @sh quoting is what makes the eval safe -- a display name or branch containing
# shell metacharacters is passed through as a literal, never interpreted.
#
# A jq failure (malformed stdin, or jq missing) would otherwise eval to nothing
# and leave every variable unset, which under `set -u` aborts with an "unbound
# variable" message rendered into the status line. Fail quiet instead: a status
# line is decoration, and a blank one beats an error smeared across the prompt.
if ! vars=$(printf '%s' "$input" | jq -r '
  def q: tostring | @sh;
  @text "
    MODEL=\(.model.display_name // "?" | q)
    CWD=\(.workspace.current_dir // .cwd // "" | q)
    BRANCH=\(.workspace.git_worktree // "" | q)
    CTX=\(.context_window.used_percentage // "" | q)
    CTX_TOK=\(if .context_window.current_usage
              then (.context_window.current_usage
                    | (.input_tokens // 0) + (.cache_read_input_tokens // 0)
                      + (.cache_creation_input_tokens // 0))
              else "" end | q)
    FIVEH=\(.rate_limits.five_hour.used_percentage // "" | q)
    FIVEH_AT=\(.rate_limits.five_hour.resets_at // "" | q)
    EFFORT=\(.effort.level // "" | q)
  "' 2>/dev/null) || [ -z "$vars" ]; then
  # jq failed, or succeeded with no output -- empty stdin parses cleanly to
  # nothing, which would leave every variable unset and abort under `set -u`.
  exit 0
fi
eval "$vars"

NOW=$(date +%s)

# A UTF-8 locale for character-accurate `wc -m` (see vlen). C.UTF-8 exists on most
# Linux; macOS ships en_US.UTF-8. Falls back to the inherited locale if neither is
# present, in which case the width count degrades to bytes but nothing breaks.
if locale -a 2>/dev/null | grep -qix 'C.UTF-8'; then UTF8_LOCALE=C.UTF-8
elif locale -a 2>/dev/null | grep -qix 'en_US.UTF-8'; then UTF8_LOCALE=en_US.UTF-8
else UTF8_LOCALE=${LC_ALL:-${LANG:-C}}
fi

DIM=$'\033[2m'; RESET=$'\033[0m'
CYAN=$'\033[36m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; RED=$'\033[31m'

# Green under 50%, yellow under 80%, red above. Rounds like the displayed value
# so the colour never disagrees with the number next to it.
heat() {
  local pct
  pct=$(printf '%.0f' "$1" 2>/dev/null) || pct=${1%%.*}
  if   [ "$pct" -ge 80 ] 2>/dev/null; then printf '%s' "$RED"
  elif [ "$pct" -ge 50 ] 2>/dev/null; then printf '%s' "$YELLOW"
  else printf '%s' "$GREEN"
  fi
}

# Time until a Unix timestamp, coarsest useful unit only (6.5d / 5.2h / 12m / <1m).
# Empty for absent or already-past timestamps.
#
# Always rounds up, so the countdown never claims less time than actually
# remains — under-reporting a rate-limit reset is the costly direction. Units
# switch at a full 1.0 (86400s / 3600s), so a value below 1.0 of the larger
# unit renders in the smaller one: 23h, not 0.9d.
countdown() {
  local at=$1 secs
  [ -n "$at" ] || return 0
  [ "$at" -gt 0 ] 2>/dev/null || return 0
  secs=$(( at - NOW ))
  [ "$secs" -gt 0 ] || return 0
  # Round up to the next whole minute first, so the unit is chosen from the
  # value actually displayed. Picking the unit from raw seconds instead would
  # let the rounding spill past the boundary and render 23h59m59s as "24h".
  # Under a minute is the one place rounding up misleads — "1m" would imply a
  # full minute of headroom that isn't there — so it keeps its own label.
  [ "$secs" -ge 60 ] || { printf '<1m'; return 0; }
  local mins=$(( (secs + 59) / 60 ))
  # Tenths, rounded up: (mins*10 + unit-1) / unit. Integer math throughout —
  # printf '%.1f' would round to nearest and re-introduce under-reporting.
  if   [ "$mins" -ge 1440 ]; then tenths $(( (mins * 10 + 1439) / 1440 )) d
  elif [ "$mins" -ge 60 ];   then tenths $(( (mins * 10 + 59) / 60 )) h
  else printf '%dm' "$mins"
  fi
}

# Render tenths as N.Nd/N.Nh, dropping a trailing ".0" so exact values stay compact.
tenths() {
  local t=$1 unit=$2
  if [ $(( t % 10 )) -eq 0 ]; then printf '%d%s' $(( t / 10 )) "$unit"
  else printf '%d.%d%s' $(( t / 10 )) $(( t % 10 )) "$unit"
  fi
}

# Target width. The line is built to fit COLUMNS (or 80), counting only visible
# characters -- colour escapes are zero-width on screen but bytes in the string.
#
# COLUMNS is validated rather than trusted: `${COLUMNS:-80}` substitutes only when
# unset or empty, so an exported COLUMNS=0 -- which some non-interactive shells
# set -- would make WIDTH 0 and put every line permanently over budget, silently
# dropping the branch on even the widest terminal.
WIDTH=${COLUMNS:-80}
case "$WIDTH" in
  ''|*[!0-9]*) WIDTH=80 ;;
  *) [ "$WIDTH" -ge 20 ] || WIDTH=80 ;;
esac

# Visible length: strip ANSI SGR sequences, then count characters (not bytes, so
# the multi-byte glyphs each count as the single column they occupy). The locale
# is forced because the harness may invoke this with LC_CTYPE unset, and under
# the C locale `wc -m` counts bytes -- every glyph would score 3 and the trim
# below would work from a width ~10 too large.
#
# Characters, not display columns: a CJK or emoji character occupies two columns
# but counts as one here, so a branch name in such a script can still overflow by
# a few columns. Accepted deliberately -- portable column measurement needs a
# wcwidth table no POSIX tool exposes, and the failure mode is a slightly long
# line rather than a wrong one. The non-numeric guard keeps an empty measurement
# (wc prints nothing for empty input) out of the -gt tests below, where it would
# make the comparison error instead of returning a usable width.
vlen() {
  local n
  n=$(printf '%s' "$1" | sed $'s/\033\\[[0-9;]*m//g' \
      | LC_ALL=${UTF8_LOCALE} wc -m | tr -d ' ')
  case "$n" in
    ''|*[!0-9]*) printf 0 ;;
    *) printf '%s' "$n" ;;
  esac
}

parts=()

# Path relative to $HOME, so long absolute paths don't dominate the line.
dir_idx=-1
DIRNAME=""
if [ -n "$CWD" ]; then
  short=${CWD/#$HOME/\~}
  DIRNAME=${short##*/}
  dir_idx=${#parts[@]}
  parts+=("${CYAN}${DIRNAME}${RESET}")
fi

# Branch is the one variable-width segment left, so it carries its own index --
# the trim pass below shortens this entry when the whole line overruns WIDTH.
branch_idx=-1
if [ -n "$BRANCH" ]; then
  branch_idx=${#parts[@]}
  parts+=("${DIM}⎇ ${BRANCH}${RESET}")
fi

# "Opus 5 (high)" -> "Opus5·hi". Effort collapses to two letters; the model keeps
# its name minus the space, which stays readable at a glance.
model_seg="${MODEL// /}"
if [ -n "$EFFORT" ]; then
  case "$EFFORT" in
    low)   eff=lo ;;
    medium) eff=md ;;
    high)  eff=hi ;;
    xhigh) eff=xh ;;
    *)     eff=${EFFORT:0:2} ;;
  esac
  model_seg+="${DIM}·${eff}${RESET}"
fi
parts+=("$model_seg")

if [ -n "$CTX" ]; then
  ctx_seg="$(heat "$CTX")$(printf 'ctx %.0f%%' "$CTX")${RESET}"
  if [ -n "$CTX_TOK" ] && [ "$CTX_TOK" -gt 0 ] 2>/dev/null; then
    ctx_seg+="${DIM} $(awk -v t="$CTX_TOK" 'BEGIN{printf "%.0fk", t/1000}')${RESET}"
  fi
  parts+=("$ctx_seg")
fi

# rate_limits is absent until the first API response, and for non-subscription auth.
limit_seg() {
  local label=$1 pct=$2 at=$3 seg left
  [ -n "$pct" ] || return 0
  seg="$(heat "$pct")$(printf '%s %.0f%%' "$label" "$pct")${RESET}"
  left=$(countdown "$at")
  [ -n "$left" ] && seg+="${DIM} ↻${left}${RESET}"
  parts+=("$seg")
}

limit_seg 5h "$FIVEH" "$FIVEH_AT"

join() {
  local out="" p
  for p in "${parts[@]}"; do
    [ -n "$out" ] && out+="${DIM} · ${RESET}"
    out+="$p"
  done
  printf '%s' "$out"
}

out=$(join)

# Still over budget? Shorten the branch until it fits, ellipsis included. Every
# other segment is near-fixed width, so the branch is the only one worth giving
# up -- and a truncated branch still identifies the work better than none at all.
if [ "$branch_idx" -ge 0 ] && [ "$(vlen "$out")" -gt "$WIDTH" ]; then
  over=$(( $(vlen "$out") - WIDTH ))
  keep=$(( $(vlen "$BRANCH") - over - 1 ))   # -1 for the ellipsis
  if [ "$keep" -ge 3 ]; then
    parts[$branch_idx]="${DIM}⎇ ${BRANCH:0:$keep}…${RESET}"
  else
    # Nothing legible would survive; drop the branch rather than show "⎇f…".
    # Rebuild without the element so join does not emit a doubled separator.
    rebuilt=()
    for i in "${!parts[@]}"; do
      [ "$i" -eq "$branch_idx" ] && continue
      rebuilt+=("${parts[$i]}")
    done
    parts=("${rebuilt[@]}")
  fi
  out=$(join)
fi

# Branch gone and still over? The directory is the last variable-width segment.
# Trimmed to a floor of 8 characters -- below that the name stops identifying
# anything, and a line slightly over budget beats an unrecognisable one.
if [ "$dir_idx" -ge 0 ] && [ "$(vlen "$out")" -gt "$WIDTH" ]; then
  over=$(( $(vlen "$out") - WIDTH ))
  keep=$(( $(vlen "$DIRNAME") - over - 1 ))
  if [ "$keep" -ge 8 ]; then
    parts[$dir_idx]="${CYAN}${DIRNAME:0:$keep}…${RESET}"
    out=$(join)
  fi
fi

printf '%s\n' "$out"
