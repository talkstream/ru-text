#!/bin/sh
# check-frozen.sh [--print] [corpus-root]
#
# With --print, emits the CURRENT values in tools/frozen.sha256 format and exits 0. That
# is the only supported way to regenerate the baseline, because it uses this script's own
# extraction: the first draft of frozen.sha256 was written by a separate one-liner that
# round-tripped the section through a shell variable, and command substitution ate the
# trailing newlines, so the recorded hash disagreed with the checker on identical bytes.
# One definition, two callers — the same rule the MCP refresh script is held to.
#
# Guards the contract between this repository and the paid ru-text MCP service, which
# pins a snapshot of the corpus and parses one section of it byte-for-byte. Break any
# check here and the paid service either mis-parses the catalog or silently serves a
# corpus that no longer matches what it claims.
#
# corpus-root defaults to the repository this script lives in. Passing a path is how
# selftest.sh runs the checks against a throwaway copy it is free to corrupt — the real
# corpus is never a test subject.
#
# Expected values live in tools/frozen.sha256, not in this file, so changing the contract
# is a visible edit to a data file rather than an edit to the checker that enforces it.
#
# ⚠ LC_ALL=C is load-bearing, not habit. Under a UTF-8 locale, BSD awk (20200816, the awk
# shipped with macOS) reports DIFFERENT Cyrillic strings as equal: with LANG=en_NZ.UTF-8,
# `$0 == "слово|замена"` matches EIGHT rows of §B — функционировать, задействовать,
# крайне, реально, конечно, разумеется, скажем and ну. Eight, which is why the catalog
# parser silently returned 84 pairs instead of 92 before this line existed; an earlier
# version of this note listed four and left the arithmetic not adding up. Reproduce:
#   printf 'ну|убрать\n' | awk '$0 == "слово|замена" { print "EQ" }'
# Every tool in this directory sets it, and comparisons on Russian text use regex anchors
# rather than `==` as a second line of defence.

set -eu
export LC_ALL=C

# sha256: coreutils on Linux, perl's shasum on macOS. Resolved once and checked, because
# the first version hardcoded `shasum` inside a pipeline whose exit status came from
# `cut` — on a machine without it the §B check compared an empty string and reported the
# CORPUS as changed, sending the reader to the wrong file entirely.
if command -v sha256sum >/dev/null 2>&1; then
  SHA256='sha256sum'
elif command -v shasum >/dev/null 2>&1; then
  SHA256='shasum -a 256'
else
  echo "check-frozen: no sha256sum or shasum on PATH" >&2
  exit 2
fi

PRINT=0
if [ "${1:-}" = "--print" ]; then PRINT=1; shift; fi
ROOT=${1:-$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)}
REF="$ROOT/skills/ru-text/references"
INFO="$REF/info-style.md"
EXPECT="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/frozen.sha256"

fail=0
ok()   { printf '  ok    %s\n' "$1"; }
bad()  { printf '  FAIL  %s\n' "$1"; fail=1; }

expect() {
  # expect <key> — print a value from tools/frozen.sha256, or report and return 1.
  #
  # It CANNOT raise the failure flag itself: every caller invokes it inside a command
  # substitution, which runs in a subshell, so `fail=1` here would be set in a process
  # that then exits. The first draft did exactly that, and a baseline missing a key made
  # the run skip that check and report PASS — a checker that had quietly stopped checking.
  # selftest.sh case 6 exists because of it. Callers must set fail themselves, in `else`.
  v=$(sed -n "s/^$1=//p" "$EXPECT")
  if [ -z "$v" ]; then
    # stderr, not stdout: the caller's command substitution would capture this into the
    # variable it is trying to fill, and the operator would see a failing exit code with
    # no line saying why.
    printf '  FAIL  %s is not recorded in tools/frozen.sha256\n' "$1" >&2
    return 1
  fi
  printf '%s' "$v"
}

# ── the two extractions, defined once and used by both the checks and --print ────
# §B is found by heading rather than by line number: the MCP parser also finds it by
# heading, so a section moved intact is not a contract break, while a byte changed
# inside it is. Runs from the heading through the line before the next `## `.
section_b() {
  awk '
    /^## B\. Каталог стоп-слов/ { inb = 1 }
    inb && /^## / && !/^## B\. Каталог стоп-слов/ { exit }
    inb { print }
  ' "$INFO"
}

# A port of the MCP's parse.ts, so this repository can prove the catalog still parses to
# the same size without installing that project. If the two ever disagree, one of them
# has drifted and the mismatch is the finding.
parse_catalog() {
  awk '
    /^## B\. Каталог стоп-слов/ { inb = 1; next }
    !inb { next }
    /^## / { exit }
    /^### / { next }
    /^слово\|замена$/ { next }
    /^[^|#]+\|.+$/ { print }
  ' "$INFO"
}

if [ "$PRINT" -eq 1 ]; then
  # Each value is checked before it is printed. The first version piped straight into
  # printf, and because printf itself succeeds, a corpus that had LOST the pinned row
  # emitted `probe_row=` and exited 0 — the documented way to regenerate the baseline
  # would have quietly recorded the absence as the new truth.
  pr=$(parse_catalog | grep '^является|' || true)
  ce=$(parse_catalog | wc -l | tr -d ' ')
  sb=$(section_b | $SHA256 | cut -d' ' -f1)
  if [ -z "$pr" ] || [ "$ce" -eq 0 ] || [ -z "$sb" ]; then
    echo "check-frozen --print: refusing to emit a baseline from a corpus that is missing pieces" >&2
    [ -z "$pr" ] && echo "  the probe row (является|…) is not in §B" >&2
    [ "$ce" -eq 0 ] && echo "  §B parses to zero entries" >&2
    [ -z "$sb" ] && echo "  §B produced no checksum — is a sha256 tool on PATH?" >&2
    exit 1
  fi
  printf 'files=%s\n' "$(find "$REF" -name '*.md' -type f | wc -l | tr -d ' ')"
  printf 'section_b_sha256=%s\n' "$sb"
  printf 'table_headers=%s\n' "$(grep -c '^слово|замена$' "$INFO" | tr -d ' ')"
  printf 'catalog_entries=%s\n' "$ce"
  printf 'probe_row=%s\n' "$pr"
  exit 0
fi

printf 'check-frozen: MCP corpus contract\n'

# ── 1. file count ─────────────────────────────────────────────────────────────
# The MCP snapshot manifest asserts an exact file count. Adding or removing a
# reference file is a deliberate act that has to be made on both sides at once.
if want=$(expect files); then
  have=$(find "$REF" -name '*.md' -type f | wc -l | tr -d ' ')
  [ "$have" = "$want" ] && ok "references/ holds $have .md files" \
                        || bad "references/ holds $have .md files, expected $want"
else
  fail=1
fi

# ── 2. §B byte identity ───────────────────────────────────────────────────────
if want=$(expect section_b_sha256); then
  have=$(section_b | $SHA256 | cut -d' ' -f1)
  if [ "$have" = "$want" ]; then
    ok "§B «Каталог стоп-слов» byte-identical ($(section_b | wc -l | tr -d ' ') lines)"
  else
    bad "§B changed: $have, expected $want"
  fi
else
  fail=1
fi

# ── 3. table header count ─────────────────────────────────────────────────────
# One `слово|замена` header per category subsection. A missing one means the rows
# under it parse as a stop-word whose replacement is the word «замена».
if want=$(expect table_headers); then
  have=$(grep -c '^слово|замена$' "$INFO" | tr -d ' ')
  [ "$have" = "$want" ] && ok "$have table headers in §B" \
                        || bad "$have table headers in §B, expected $want"
else
  fail=1
fi

# ── 4. the parse, reimplemented ───────────────────────────────────────────────
if want=$(expect catalog_entries); then
  have=$(parse_catalog | wc -l | tr -d ' ')
  [ "$have" = "$want" ] && ok "$have catalog entries parse out of §B" \
                        || bad "$have catalog entries parse out of §B, expected $want"
else
  fail=1
fi

# ── 5. no duplicate skill registration at the repository root ─────────────────
# A root SKILL.md registers the SAME skill name a second time, and it does worse than
# that: `npx skills` parses the root file first and sets the payload to
# dirname(SKILL.md) — the entire repository. That is how .github/, notion/, the logo and
# CHANGELOG.md ended up inside ~/.agents/skills/ru-text/. Removed in v2.0; this check
# exists so it cannot come back by habit.
if [ -f "$ROOT/SKILL.md" ]; then
  bad "a SKILL.md at the repository root registers ru-text twice and makes the whole repo the payload"
else
  ok "no duplicate SKILL.md at the repository root"
fi

# ── 6. one exact row ──────────────────────────────────────────────────────────
# The MCP's own test asserts this precise replacement string. Pinning it here means a
# reworded replacement fails in this repository first, where the change was made.
if want=$(expect probe_row); then
  have=$(parse_catalog | grep '^является|' || true)
  [ "$have" = "$want" ] && ok "probe row unchanged: $have" \
                        || bad "probe row is '$have', expected '$want'"
else
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  printf 'check-frozen: PASS\n'
else
  printf 'check-frozen: FAIL — the MCP contract is broken; see ~/.claude/plans for the contract table\n'
fi
exit "$fail"
