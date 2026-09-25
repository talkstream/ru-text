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
# pins a snapshot of the corpus and parses two sections of it byte-for-byte: §B, the
# stop-word catalog of info-style.md, and §E.1, the pleonasm table of editorial-grammar.md
# (since 2.8.0). selftest.sh holds the count: one `*_sha256` key per `section_*` extraction. Break any
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
GRAMMAR="$REF/editorial-grammar.md"
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

# §E.1 the same way, heading to the next heading of ANY level: §E.2 follows as `###`, and its
# rows carry one separator, so reading past the heading would count tautologies as pleonasms.
# Carve-out prose between the heading and the table is INSIDE the section on purpose — it
# moves the checksum by design, and the baseline is re-stamped with --print in the same
# commit that returns it.
section_e1() {
  awk '
    /^### E\.1\. Pleonasms/ { ine = 1; print; next }
    ine && /^#/ { exit }
    ine { print }
  ' "$GRAMMAR"
}

# Rows of §E.1 that pass the table predicate — exactly two separators and three non-empty
# parts — header included. The MCP parser reports this number as `windowRows`, and the gap
# to the accepted entries must be exactly the header.
pleonasm_window() {
  section_e1 | awk -F'|' 'NF == 3 && $1 != "" && $2 != "" && $3 != ""'
}

# The accepted entries: the same predicate without the header `wrong|correct|why`. A port of
# the MCP's parsePleonasms, for the same reason parse_catalog ports its catalog parser.
parse_pleonasms() {
  pleonasm_window | awk '!/^wrong\|correct\|why$/'
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
  se=$(section_e1 | $SHA256 | cut -d' ' -f1)
  pe=$(parse_pleonasms | wc -l | tr -d ' ')
  pw=$(pleonasm_window | wc -l | tr -d ' ')
  pp=$(parse_pleonasms | grep '^свободная вакансия|' || true)
  if [ -z "$pr" ] || [ "$ce" -eq 0 ] || [ -z "$sb" ] || [ -z "$se" ] || [ "$pe" -eq 0 ] || [ -z "$pp" ]; then
    echo "check-frozen --print: refusing to emit a baseline from a corpus that is missing pieces" >&2
    [ -z "$pr" ] && echo "  the probe row (является|…) is not in §B" >&2
    [ "$ce" -eq 0 ] && echo "  §B parses to zero entries" >&2
    [ -z "$sb" ] && echo "  §B produced no checksum — is a sha256 tool on PATH?" >&2
    [ -z "$se" ] && echo "  §E.1 produced no checksum" >&2
    [ "$pe" -eq 0 ] && echo "  §E.1 parses to zero entries" >&2
    [ -z "$pp" ] && echo "  the probe row (свободная вакансия|…) is not in §E.1" >&2
    exit 1
  fi
  printf 'files=%s\n' "$(find "$REF" -name '*.md' -type f | wc -l | tr -d ' ')"
  printf 'section_b_sha256=%s\n' "$sb"
  printf 'table_headers=%s\n' "$(grep -c '^слово|замена$' "$INFO" | tr -d ' ')"
  printf 'catalog_entries=%s\n' "$ce"
  printf 'probe_row=%s\n' "$pr"
  printf 'section_e1_sha256=%s\n' "$se"
  printf 'pleonasm_entries=%s\n' "$pe"
  printf 'pleonasm_window_rows=%s\n' "$pw"
  printf 'pleonasm_probe_row=%s\n' "$pp"
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

# ── 7. §E.1 byte identity ─────────────────────────────────────────────────────
# Moves on every carve-out returned as prose — by design, re-stamped in the same commit. It is
# NOT the guard against a substituted row: 8–10 are, and they do not move on prose.
if want=$(expect section_e1_sha256); then
  have=$(section_e1 | $SHA256 | cut -d' ' -f1)
  if [ "$have" = "$want" ]; then
    ok "§E.1 «Pleonasms» byte-identical ($(section_e1 | wc -l | tr -d ' ') lines)"
  else
    bad "§E.1 changed: $have, expected $want"
  fi
else
  fail=1
fi

# ── 8. §E.1 entries, the parse reimplemented ──────────────────────────────────
if want=$(expect pleonasm_entries); then
  have=$(parse_pleonasms | wc -l | tr -d ' ')
  [ "$have" = "$want" ] && ok "$have pleonasm entries parse out of §E.1" \
                        || bad "$have pleonasm entries parse out of §E.1, expected $want"
else
  fail=1
fi

# ── 9. §E.1 window rows: the header and nothing else ──────────────────────────
# Carve-out prose with two pipes would pass the predicate and raise BOTH this and 8 by one,
# so the gap alone cannot see it; the absolute count and 8 together can.
if want=$(expect pleonasm_window_rows); then
  have=$(pleonasm_window | wc -l | tr -d ' ')
  [ "$have" = "$want" ] && ok "$have rows of §E.1 pass the table predicate" \
                        || bad "$have rows of §E.1 pass the table predicate, expected $want"
else
  fail=1
fi

# ── 10. one exact §E.1 row ────────────────────────────────────────────────────
if want=$(expect pleonasm_probe_row); then
  have=$(parse_pleonasms | grep '^свободная вакансия|' || true)
  [ "$have" = "$want" ] && ok "pleonasm probe row unchanged: $have" \
                        || bad "pleonasm probe row is '$have', expected '$want'"
else
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  printf 'check-frozen: PASS\n'
else
  printf 'check-frozen: FAIL — the MCP contract is broken; see ~/.claude/plans for the contract table\n'
fi
exit "$fail"
