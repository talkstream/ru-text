#!/bin/sh
# check-private.sh [corpus-root]
#
# Guards the one-way boundary: nothing that identifies the private commercial contour may
# exist in the tracked tree of this public repository.
#
#     tools/check-private.sh          # verify this repository
#     tools/check-private.sh DIR      # verify a copy (the selftest passes a throwaway)
#
# ── why ──────────────────────────────────────────────────────────────────────────────
#
# The boundary itself is stated in .claude/CLAUDE.md: paid is whatever deterministically
# fixes arbitrary user text, public is the corpus and the detectors whose input is
# hard-wired here. That predicate is read by a reviewer and cannot be automated — telling a
# detector from a transformer is judgement.
#
# This gate does the half that CAN be automated, and it is the half with the sharper edge:
# an identifier of the private contour reaching a public commit is irreversible, whereas a
# misplaced tool is merely a mistake. Measured 16.08.2026 across all 144 commits of every
# branch and tag: not one such string has ever been committed. There was no mechanism
# holding that — only luck and attention.
#
# ── the deny-list is IDENTIFIERS, never topics ───────────────────────────────────────
#
# The public repository legitimately discusses the paid service: tools/check-frozen.sh
# names the contract it guards, and the corpus explains to a reader why §B is frozen.
# Banning the subject would red the tree today over seven tracked files —
#   git grep -liE 'paid.{0,15}MCP' -- '*.sh' '*.md'   # → 6 files, 7 lines
# — and a gate that reds without a cause is a gate its author learns to disable. So the
# list holds only strings that NAME the private contour and can carry no innocent reading.
#
# Scope is TRACKED FILES AT HEAD (`git grep` walks what `git ls-files` lists). An ignored
# scratchpad or a local .env is not this gate's business, and scanning them would red the
# gate on every machine that happens to hold one.
#
# ⚠ Two limits of that scope, stated because a green line must not be read as more than it is.
#
# 1. A push publishes HISTORY, not HEAD. Commit an identifier, fix it in the next commit,
#    push both — this gate is green and the string is public forever. That is not
#    hypothetical: on 16.08.2026 the first draft of this very file carried real ones, and
#    what saved it was rebuilding the commit before the push, not any check. Guarding the
#    range would take a CI scan of the pushed revisions; until that exists, the rule is
#    a human one — never push over a commit you have not read.
# 2. Commit MESSAGES are outside `git grep` entirely, and the repository already carries an
#    identifier in one (`git log --all -i --grep='ru-text-mcp'` → 94b99ec, 01.08.2026). It
#    predates this gate, main is protected, and the string is mild — the service is named
#    in the public offer — but no mechanism holds that line either.

set -eu
export LC_ALL=C

ROOT=${1:-$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)}
cd "$ROOT"

MARK="${TMPDIR:-/tmp}/check-private.$$"
# A marker left behind by a run that died mid-way would fail the NEXT run with no cause.
# Cleared up front, and released on INT/TERM as well as EXIT: dash skips an EXIT trap when
# the shell dies on a signal — measured in this repository's other gates, not assumed.
: > "$MARK"
trap 'test -f "$MARK" && mv -f "$MARK" "$MARK.done" 2>/dev/null || true' EXIT INT TERM

echo "check-private: no private-contour identifiers in tracked files"

# One pattern per line: <label>|<extended-regex>. Kept as data, so widening the boundary is
# a visible edit in review rather than a change to the matcher.
# ⚠ The patterns are deliberately GENERIC, and that is a correction of this file's own first
# draft. A deny-list naming what it protects publishes it: the first version spelled out the
# private repository, the service hostname and the server's subnet, and a background security
# review flagged the selftest — correctly — as infrastructure disclosure, in a commit built to
# prevent exactly that. Nothing had been pushed, but the lesson stands: a guard whose rules
# must be read by everyone cannot hold a secret in its rules.
#
# So each pattern was widened until it names a SHAPE rather than a value. Measured before
# widening, so that the wider net cannot red on honest content: this tree holds zero IPv4
# literals (`git grep -nE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b'`), and `ru-text.org` appears five
# times bare with no sub-domain anywhere.
#
# No look-ahead and no `\b`: git grep speaks POSIX ERE, rejects `(?!…)` outright and silently
# matches NOTHING on a word boundary — both verified against a throwaway repository, not
# assumed. The IP pattern therefore fences itself with explicit non-digit neighbours, which
# fences it from matching inside a longer digit chain. ⚠ It does NOT keep the pattern off
# a four-part version string — `echo 'version 1.2.3.4' | grep -cE …` → 1, measured. The
# tree holds no such string today, and if one appears the gate will red honestly and be
# told so; claiming a protection it lacks would be worse.
#
# The sibling repository is named by a SHAPE instead: this owner's public repository
# is `ru-text` exactly, so any `talkstream/ru-text-<suffix>` is by construction another one.
# Measured: 72 bare `talkstream/ru-text` and 4 `.git` forms in the tree, none with a suffix.
PATTERNS='sibling repository under this owner|talkstream/ru-text-
service sub-domain|[a-z0-9-]+\.ru-text\.org
any IP address literal|(^|[^0-9.])([0-9]{1,3}\.){3}[0-9]{1,3}([^0-9.]|$)
payment provider|yookassa|ЮKassa|ЮКасса
hosting provider|[Ss]electel|[Сс]електел
admin token variable|ADMIN_TOKEN
deploy key material|BEGIN (OPENSSH|RSA|EC) PRIVATE KEY'

found=0
printf '%s\n' "$PATTERNS" | while IFS='|' read -r label regex; do
  [ -n "$label" ] || continue
  # ⚠ This file and its selftest are excluded, and the exclusion is unavoidable rather than
  # convenient: a deny-list is made of the very strings it forbids, so once this script is
  # tracked it matches itself on every pattern. Caught by the selftest before the first
  # commit — the live tree passed only because the file was still untracked.
  #
  # The hole this opens is named, not hidden: an identifier planted INSIDE these two files
  # would not be seen by the gate. What closes it is that both are pure pattern lists, so
  # any addition is a one-line diff whose whole content is the suspect string — the review
  # surface is two files, not the whole repository.
  #
  # -I skips binary files: a font or a PNG matching a hex pattern is noise, not a leak.
  # -i: the latin patterns were case-sensitive, so «YooKassa» — the brand's own spelling —
  # and «SELECTEL» walked through. Cyrillic variants stay listed explicitly: case folding
  # for Cyrillic is not something to rely on across grep builds.
  hits=$(git grep -niIE "$regex" -- . ':!tools/check-private.sh' ':!tools/selftest-check-private.sh' 2>/dev/null || true)
  if [ -n "$hits" ]; then
    printf '  FAIL  %s\n' "$label"
    printf '%s\n' "$hits" | sed 's/^/          /'
    # The loop runs in a subshell (pipeline), so a variable set here dies with it. The
    # marker file carries the verdict across that boundary.
    printf 'LEAK\n' >> "$MARK"
  else
    printf '  ok    %s absent\n' "$label"
  fi
done

found=$(wc -l < "$MARK" | tr -d ' ')
if [ "$found" != "0" ]; then
  echo "check-private: FAIL — $found identifier class(es) present in tracked files" >&2
  exit 1
fi

echo "check-private: PASS"
