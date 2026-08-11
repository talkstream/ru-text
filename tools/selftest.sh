#!/bin/sh
# selftest.sh — proves every tool in this directory can FAIL.
#
# A checker nobody has watched fail is a checker nobody has tested. Each case below
# corrupts a throwaway copy of the corpus in one specific way and asserts two things:
# that the tool exits non-zero, and that the SPECIFIC check it should have caught is the
# one that reported. Exit code alone is not enough — a mutation that happens to break a
# different check would pass a weaker test and leave the intended one unpinned.
#
# Corruption always happens in a copy under a temporary directory — the corpus and the
# baseline both. Several cases DO read the real corpus, read-only, to check assumptions
# the tools rest on (that it is still NFC, that the frozen section still parses). The real
# tree is a measurement subject and never a mutation subject; an earlier version of this
# header said it was never a test subject at all, which was not true of those cases.
#
# Run: tools/selftest.sh

set -eu
export LC_ALL=C

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TMPROOT=$(mktemp -d "${TMPDIR:-/tmp}/ru-text-selftest.XXXXXX")
# The trap does two jobs, and the second exists because the first one hid a disaster: an EXIT
# handler RESETS the status, so a suite that aborted mid-run — `set -eu` on an unset name, a
# syntax error, a killed child — exited ZERO and every caller read it as a pass. `finished` is
# set on the last line of this file, so anything that stops the run short is reported here and
# exits non-zero. gates.sh ALSO requires the summary line, and that is not redundant: CI does
# not call gates.sh (.github/workflows/gates.yml runs this file directly), so a guard living
# only there would protect the local path and leave CI on the old footing.
finished=0
trap 'st=$?; rm -rf "$TMPROOT"; if [ "$finished" -ne 1 ]; then printf "selftest: ABORTED before the summary — the run did not finish\\n" >&2; exit 1; fi; exit $st' EXIT
trap 'rm -rf "$TMPROOT"; exit 130' INT TERM

pass=0
fail=0
# Initialised, and it was not. Under `set -eu` an unset name in $(( )) aborts bash 3.2 —
# which IS /bin/sh on macOS — and the EXIT trap then resets the status, so the suite died
# at case 145 printing no summary and exiting ZERO. gates.sh read that as a pass. The trigger
# is any `skip`, and the only live one fires when build-og --check fails: an OG rebuild would
# have turned the whole verification chain green-while-dead. Measured 10.08.2026.
#
# HELD BY: `gates.sh` requiring a summary line, which covers the CLASS — any abort, any
# cause — and has its own case. This initialisation itself is a latent arm: no `skip` fires
# on this tree locally (0 today), so removing the line changes nothing a case can see. It
# fires on CI, where dash tolerates the unset name anyway. Written down rather than left to
# be rediscovered by mutation.
skipped=0
note() { printf '  %s\n' "$1"; }
ok()   { pass=$((pass + 1)); printf '  ok    %s\n' "$1"; }
bad()  { fail=$((fail + 1)); printf '  FAIL  %s\n' "$1"; }
# Counted separately and printed in the summary: a skipped case must never read
# as a passing one, and must never be invisible. §No silent caps.
skip() { skipped=$((skipped + 1)); printf '  skip  %s\n' "$1"; }

# fresh_copy — a self-contained repository slice: corpus, tools and baseline, all writable
fresh_copy() {
  d=$(mktemp -d "$TMPROOT/case.XXXXXX")
  # The WHOLE skills tree, not just references/ and SKILL.md. The baseline counts atoms in
  # skills/ru-text/agents/*.yaml too, so a copy missing them starts eight atoms short and
  # any no-loss gate run against it fails for a reason that has nothing to do with the case.
  cp -R "$ROOT/skills" "$d/skills"
  cp -R "$ROOT/tools" "$d/tools"
  # Everything a checker reads has to be in the copy, or gates.sh fails inside a case for a
  # reason the case is not about. This list grows when a checker learns to read a new file:
  # check-version.sh added the manifests and the two READMEs. Missing files are copied
  # silently rather than fatally — a case may deliberately be run against a partial tree.
  cp -R "$ROOT/.claude-plugin" "$ROOT/.codex-plugin" "$ROOT/.cursor-plugin" "$d/" 2>/dev/null || true
  mkdir -p "$d/.claude"
  for f in gemini-extension.json openclaw.plugin.json README.md README.en.md INSTALL.md INSTALL.en.md .claude/CLAUDE.md; do
    [ -f "$ROOT/$f" ] && cp "$ROOT/$f" "$d/$f" 2>/dev/null
  done
  cp -R "$ROOT/notion" "$d/notion" 2>/dev/null || true
  # docs/ joined the list when the roadmaps stopped being exempt from the tell sweep: two of
  # them state the count in the present tense, so they are consumers, and a copy without them
  # fails every case with «does not say» — a failure about the fixture, not about the case.
  cp -R "$ROOT/docs" "$d/docs" 2>/dev/null || true
  # The images the manifests point at. check-assets.sh reads them, and a copy without them
  # reports every reference as missing — a failure about the fixture, not about the case.
  cp -R "$ROOT/assets" "$d/assets" 2>/dev/null || true
  cp "$ROOT/logo-round.png" "$d/logo-round.png" 2>/dev/null || true
  # A repository, not just a directory: check-dogfood walks `git ls-files`, so a copy that
  # is not one fails inside every case for a reason no case is about.
  ( cd "$d" && git init -q . && git add -A ) >/dev/null 2>&1 || true
  printf '%s' "$d"
}

# expect_fail <case-name> <substring the output must contain> <dir>
# Runs check-frozen against the prepared copy and asserts it fails FOR THAT REASON.
expect_fail() {
  name=$1; needle=$2; d=$3
  out=$("$d/tools/check-frozen.sh" "$d" 2>&1) && status=0 || status=$?
  if [ "$status" -eq 0 ]; then
    bad "$name — check-frozen PASSED on corrupted input"
    return
  fi
  if printf '%s' "$out" | grep -qF "$needle"; then
    ok "$name"
  else
    bad "$name — failed, but not for the stated reason (wanted: $needle)"
    printf '%s\n' "$out" | sed 's/^/        /'
  fi
}

printf 'selftest: check-frozen.sh\n'

# ── the control: an untouched copy must pass ──────────────────────────────────
# Without this the whole file could be passing because every case fails for some
# incidental reason, such as a broken copy step.
d=$(fresh_copy)
if "$d/tools/check-frozen.sh" "$d" >/dev/null 2>&1; then
  ok "an untouched copy passes"
else
  bad "an untouched copy FAILS — the harness itself is broken, ignore everything below"
  "$d/tools/check-frozen.sh" "$d" 2>&1 | sed 's/^/        /'
fi

# ── 1. file count ─────────────────────────────────────────────────────────────
d=$(fresh_copy)
rm "$d/skills/ru-text/references/sources.md"
expect_fail "a deleted reference file is caught" "references/ holds 9 .md files" "$d"

# ── 2. §B byte identity ───────────────────────────────────────────────────────
# A replacement reworded inside the frozen section. The paid MCP serves this string
# verbatim, so a silent edit here is a silent change to what customers are told.
d=$(fresh_copy)
sed 's/^осуществлять|.*/осуществлять|делать/' "$d/skills/ru-text/references/info-style.md" > "$d/t" \
  && mv "$d/t" "$d/skills/ru-text/references/info-style.md"
expect_fail "a byte changed inside §B is caught" "§B changed" "$d"

# ── 3. table header count ─────────────────────────────────────────────────────
# Drop one category's header row. The rows beneath it still parse, so the entry count
# is unchanged and only this check notices — which is exactly why it exists separately.
d=$(fresh_copy)
awk 'BEGIN { done = 0 } /^слово\|замена$/ && !done { done = 1; next } { print }' \
  "$d/skills/ru-text/references/info-style.md" > "$d/t" \
  && mv "$d/t" "$d/skills/ru-text/references/info-style.md"
expect_fail "a missing слово|замена header is caught" "7 table headers" "$d"

# ── 4. entry count ────────────────────────────────────────────────────────────
d=$(fresh_copy)
grep -v '^впрочем|' "$d/skills/ru-text/references/info-style.md" > "$d/t" \
  && mv "$d/t" "$d/skills/ru-text/references/info-style.md"
expect_fail "a deleted catalog row is caught" "91 catalog entries" "$d"

# ── 5. the probe row ──────────────────────────────────────────────────────────
# perl, not sed: the pattern and the replacement both contain the pipe that sed would
# need as its delimiter, and BSD sed's -i wants an explicit backup suffix.
d=$(fresh_copy)
perl -i -pe 's{^является\|тире / перестроить$}{является|тире}' \
  "$d/skills/ru-text/references/info-style.md"
expect_fail "a reworded probe row is caught" "probe row is" "$d"

# ── 5b. the root SKILL.md guard ───────────────────────────────────────────────
# The check added in v2.0 when the duplicate root file was removed. Without a case it is
# a check nobody has watched fire, which is how the DOC credit shipped dead.
d=$(fresh_copy)
cp "$d/skills/ru-text/SKILL.md" "$d/SKILL.md"
expect_fail "a returning root SKILL.md is caught" "registers ru-text twice" "$d"

# ── 6. the baseline itself ────────────────────────────────────────────────────
# A checker that reads its expectations from a file must fail loudly when the file has
# lost one, rather than quietly skipping the check it can no longer make.
d=$(fresh_copy)
grep -v '^catalog_entries=' "$d/tools/frozen.sha256" > "$d/t" && mv "$d/t" "$d/tools/frozen.sha256"
expect_fail "a baseline key gone missing is caught" "catalog_entries is not recorded" "$d"

# ── 7. the locale trap: a canary, reported per platform ───────────────────────
# Why LC_ALL=C is exported everywhere. Under a UTF-8 locale the BSD awk on macOS reports
# distinct Cyrillic strings as equal, and the catalog parser silently returns 84 of its 92
# entries. Reproduce there with:
#   printf 'ну|убрать\n' | awk '$0 == "слово|замена" { print "EQ" }'
#
# The first version of this case asserted the trap exists, full stop — and CI failed on
# its very first run, because gawk on the Linux runner is not affected. That was a
# property of one machine's awk stated as a property of every awk: the same
# over-quantification this project keeps having to correct, this time caught by a second
# platform instead of a reviewer. So the canary now reports what it finds and fails only
# on the outcome that would actually mislead someone — the trap having quietly vanished on
# a platform that used to have it, which is the day LC_ALL=C could be reconsidered.
# The probe needs a UTF-8 locale to be MEANINGFUL: with none installed the C locale is
# used silently, no match occurs, and "this awk is unaffected" is indistinguishable from
# "the experiment never ran". So the locale is checked first and an absent one is reported
# as what it is — an inconclusive probe — rather than as a clean bill of health.
utf8_locale=$(locale -a 2>/dev/null | /usr/bin/grep -iE '^(en_US|C)\.(utf-?8)$' | head -1 || true)
if [ -z "$utf8_locale" ]; then
  ok "no UTF-8 locale on this machine — the awk trap probe is inconclusive, LC_ALL=C stays"
  trap_probe=SKIP
else
  trap_probe=$(printf 'ну|убрать\n' | LC_ALL="$utf8_locale" awk '$0 == "слово|замена" { print "EQ" }' 2>/dev/null || true)
fi
case "$(uname -s)" in
  Darwin)
    if [ "$trap_probe" = "SKIP" ]; then
      :
    elif [ "$trap_probe" = "EQ" ]; then
      ok "the awk multibyte == trap is present on this platform, as expected (LC_ALL=C required)"
    else
      bad "the awk multibyte == trap is GONE on macOS — re-examine why LC_ALL=C is set, then update this case"
    fi
    ;;
  *)
    if [ "$trap_probe" = "SKIP" ]; then
      :
    elif [ "$trap_probe" = "EQ" ]; then
      bad "this platform's awk has the multibyte == trap too — widen the note in check-frozen.sh"
    else
      ok "no awk multibyte == trap on $(uname -s); LC_ALL=C stays for the platforms that have it"
    fi
    ;;
esac


printf 'selftest: extract-atoms.sh + diff-atoms.sh\n'

# expect_diff <case> <expected exit: 0|1> <needle or -> <old> <new> [map]
# The default map is EMPTY, not the repository's own. These cases compare snapshots of the
# current corpus against each other, and every row of the real map names an atom the
# current corpus no longer has — so in such a comparison every real row is legitimately
# STALE, and «identical snapshots pass» started failing the moment the map stopped being
# empty. What is under test here is diff-atoms on a synthetic pair; the real map is
# exercised for real by gates.sh, and by the cases below that pass their own fixture.
expect_diff() {
  name=$1; want=$2; needle=$3; o=$4; n=$5; m=${6:-$EMPTY_MAP}
  out=$("$ROOT/tools/diff-atoms.sh" "$o" "$n" "$m" 2>&1) && st=0 || st=$?
  if [ "$st" -ne "$want" ]; then
    bad "$name — exit $st, wanted $want"
    printf '%s\n' "$out" | sed 's/^/        /'
    return
  fi
  if [ "$needle" != "-" ] && ! printf '%s' "$out" | grep -qF "$needle"; then
    bad "$name — right exit, wrong reason (wanted: $needle)"
    printf '%s\n' "$out" | sed 's/^/        /'
    return
  fi
  ok "$name"
}

W=$(mktemp -d "$TMPROOT/atoms.XXXXXX")
EMPTY_MAP="$W/empty-map.tsv"
printf '# no rows: see the note above expect_diff\n' > "$EMPTY_MAP"
"$ROOT/tools/extract-atoms.sh" "$ROOT/skills/ru-text" > "$W/a.tsv"
"$ROOT/tools/extract-atoms.sh" "$ROOT/skills/ru-text" > "$W/b.tsv"

# Determinism. Hashes, ordering and text must not depend on the machine or the run —
# otherwise every future comparison is noise and the gate is unreadable.
if cmp -s "$W/a.tsv" "$W/b.tsv"; then
  ok "extract-atoms is deterministic across runs"
else
  bad "extract-atoms output differs between two runs of the same corpus"
fi

# ── the golden fixture ────────────────────────────────────────────────────────
# tools/testdata/corpus is a small corpus carrying one instance of every shape and every
# exclusion: frontmatter, an H1, both spellings of a table of contents, a Sources section,
# a bare a|b table with its header, a markdown table with its separator, a heading that IS
# a rule, a two-line До/После rule, a fenced specification, a --- separator, and a .yaml
# manifest. Its expected output is committed beside it.
#
# This is what pins ORDERING and the file:line column. Running the extractor twice on one
# machine cannot see a machine-dependent construct, and comparing against the live corpus
# would start failing legitimately at the first stage that moves a rule. A fixture keeps
# working forever, and two corruptions of extract-atoms that previously passed 22/22 are
# caught here.
if "$ROOT/tools/extract-atoms.sh" "$ROOT/tools/testdata/corpus" > "$W/fixture.tsv" 2>"$W/fixture.err"; then
  if cmp -s "$W/fixture.tsv" "$ROOT/tools/testdata/expected-atoms.tsv"; then
    ok "the fixture corpus extracts exactly as recorded ($(wc -l < "$W/fixture.tsv" | tr -d ' ') atoms)"
  else
    bad "the fixture corpus no longer extracts as recorded"
    diff "$ROOT/tools/testdata/expected-atoms.tsv" "$W/fixture.tsv" | head -12 | sed 's/^/        /'
  fi
else
  bad "extract-atoms failed on the fixture corpus"
  sed 's/^/        /' < "$W/fixture.err"
fi

# ── proof that extract-atoms itself can fail ──────────────────────────────────
# Every other extract-atoms case reads the pristine corpus and asserts a string is
# present, so none of them had ever been seen to fire — the probes could have been passing
# because grep matches, not because the control works. This removes one rule from a copy
# of the fixture and requires the extractor to notice.
FX=$(mktemp -d "$TMPROOT/fx.XXXXXX")
cp -R "$ROOT/tools/testdata/corpus" "$FX/corpus"
/usr/bin/grep -v '^осуществлять|делать$' "$FX/corpus/references/rules.md" > "$FX/t" \
  && mv "$FX/t" "$FX/corpus/references/rules.md"
"$ROOT/tools/extract-atoms.sh" "$FX/corpus" > "$FX/cut.tsv"
if cmp -s "$FX/cut.tsv" "$ROOT/tools/testdata/expected-atoms.tsv"; then
  bad "extract-atoms produced identical output after a rule was deleted — it cannot fail"
else
  ok "extract-atoms notices a deleted rule"
fi
expect_diff "the gate catches a rule deleted from the fixture" 1 "UNACCOUNTED" \
  "$ROOT/tools/testdata/expected-atoms.tsv" "$FX/cut.tsv"

# ── the exclusions are exclusions, and the inclusions are inclusions ──────────
# Named against the fixture rather than the live corpus so these stay meaningful when the
# corpus changes. Each line here was, at some point, wrong in the extractor.
fixture_has()    { if /usr/bin/grep -qF "$2" "$W/fixture.tsv"; then ok "fixture keeps $1"; else bad "fixture LOST $1 — wanted: $2"; fi; }
fixture_lacks()  { if /usr/bin/grep -qF "$2" "$W/fixture.tsv"; then bad "fixture leaked $1 — found: $2"; else ok "fixture drops $1"; fi; }
fixture_has   "a fenced specification"        "Оценка XX 10"
fixture_has   "a fenced table header"         "Измерение | Балл |"
fixture_has   "the SKILL.md description"      "это триггер активации"
fixture_has   "a yaml manifest descriptor"    "fixture descriptor"
fixture_has   "a heading that is a rule"      "Канцелярит bureaucratic"
fixture_has   "both halves of a two-line rule" "До Наша компания"
fixture_lacks "a table of contents"           "[A](#a)"
fixture_lacks "the other table of contents"   "Разметка](#"
fixture_lacks "a Sources section"             "атрибуция"
fixture_lacks "an H1 title"                   "Заголовок первого уровня"
fixture_lacks "a bare table header"           "слово|замена"
fixture_lacks "a markdown table header"       "Условие | Действие"


# Recall on the four shapes the reconnaissance flagged as easiest to lose. The probes are
# written in POST-normalisation form — punctuation is gone by then, so the frozen row
# «является|тире / перестроить» is stored as «является|тире перестроить». A first draft
# compared against the raw source lines and reported four losses that were not losses.
# Testing a tool against what it actually emits is the only version of this that means
# anything; testing it against what you assumed it emits reports on your assumptions.
probe_recall() {
  # cut's stderr is discarded: grep -q exits on the first match, cut takes SIGPIPE, and
  # GNU cut prints "write error: Broken pipe" where BSD cut is silent. The message is
  # noise either way, but noise in a gate's output teaches people to skim it.
  if cut -f3 "$W/a.tsv" 2>/dev/null | /usr/bin/grep -qF "$2"; then
    ok "extract-atoms keeps $1"
  else
    bad "extract-atoms LOST $1 — wanted a line containing: $2"
  fi
}
# a bare a|b row — the syntax five of the ten files use, which no markdown table parser sees
probe_recall "a bare-syntax table row"     "является|тире перестроить"
# a rule that exists ONLY as a heading: the stop-word taxonomy is written nowhere else
probe_recall "a heading-only rule"         "Канцелярит bureaucratic"
# the content half of a two-line rule, whose numbered line above it is only a label
probe_recall "a multi-line rule's content" "До Наша компания на протяжении долгих лет"
# a leading-pipe markdown row — the syntax the other four files use
probe_recall "a markdown table row"        "Форма обращения"

# Exclusions actually exclude.
if cut -f3 "$W/a.tsv" | grep -qE '^-+$'; then
  bad "extract-atoms emits bare separator lines"
else
  ok "extract-atoms drops separators and frontmatter delimiters"
fi

# A snapshot compared with itself must pass. This is the control that caught the tool
# reporting the entire corpus as lost: awk matched both arguments to the first pass when
# the two paths were identical.
expect_diff "identical snapshots pass" 0 "PASS" "$W/a.tsv" "$W/a.tsv"

# One rule gone, no map row: the whole point.
sed '$d' "$W/a.tsv" > "$W/short.tsv"
expect_diff "a deleted atom is caught" 1 "UNACCOUNTED" "$W/a.tsv" "$W/short.tsv"

# Reworded: fails unmapped, passes once someone writes down what happened.
H=$(head -1 "$W/a.tsv" | cut -f1)
{ sed '1d' "$W/a.tsv"; printf 'f00d000000000000000000000000000000000000\tSKILL.md:2\treworded\n'; } > "$W/re.tsv"
expect_diff "a reworded atom is caught with no map row" 1 "UNACCOUNTED" "$W/a.tsv" "$W/re.tsv"
printf '%s\tNORMALISED\tf00d000000000000000000000000000000000000\tselftest\n' "$H" > "$W/map-ok.tsv"
expect_diff "a mapped rewording passes" 0 "PASS" "$W/a.tsv" "$W/re.tsv" "$W/map-ok.tsv"

# A map row pointing at an atom that is not in the new snapshot is worse than none: it
# reads as accounted for.
printf '%s\tNORMALISED\t0000000000000000000000000000000000000000\tselftest\n' "$H" > "$W/map-broken.tsv"
expect_diff "a map row pointing nowhere is caught" 1 "BROKEN TARGET" "$W/a.tsv" "$W/re.tsv" "$W/map-broken.tsv"

# There is no DELETED disposition, and a map that tries to use one must say so out loud
# rather than silently ignoring the row.
printf '%s\tDELETED\tf00d000000000000000000000000000000000000\tselftest\n' "$H" > "$W/map-del.tsv"
expect_diff "a DELETED disposition is rejected" 1 "BAD DISPOSITION" "$W/a.tsv" "$W/re.tsv" "$W/map-del.tsv"

# A row that accounts for nothing means the map and the corpus have drifted apart.
printf 'abcabcabcabcabcabcabcabcabcabcabcabcabca\tMOVED\tf00d000000000000000000000000000000000000\tselftest\n' > "$W/map-stale.tsv"
expect_diff "a stale map row is caught" 1 "STALE MAP ROW" "$W/a.tsv" "$W/a.tsv" "$W/map-stale.tsv"

# The corpus is already NFC, which is why the extractor does not normalise it. If that
# ever stops being true the comparison starts depending on how a file was saved.
# ── every diagnostic diff-atoms can print, exercised ─────────────────────────
# None of the checks added after the panel had a case: not the DOC branches, not
# OVERSUBSCRIBED, not DUPLICATE MAP ROW. That is how a DOC fix shipped as dead code with
# the suite at 37/37 and the commit body announcing it closed. One case per diagnostic.
DG=$(mktemp -d "$TMPROOT/diag.XXXXXX")
printf 'a1b2c3\tf.md:1\tправило уехало в доки\nd4e5f6\tf.md:2\tостаётся\n' > "$DG/old.tsv"
printf 'd4e5f6\tf.md:2\tостаётся\n' > "$DG/new.tsv"
mkdir -p "$DG/docs"
# the documentation must carry the NORMALISED text, which is what UNACCOUNTED prints
printf '# перенесённые правила\n\nправило уехало в доки\n' > "$DG/docs/moved.md"

printf 'a1b2c3\tDOC\t%s/docs/moved.md\tпереехало в документацию\n' "$DG" > "$DG/map-doc.tsv"
expect_diff "a clean DOC row passes" 0 "PASS" "$DG/old.tsv" "$DG/new.tsv" "$DG/map-doc.tsv"

printf 'a1b2c3\tDOC\t%s/tools/testdata/expected-atoms.tsv\tотмычка\n' "$ROOT" > "$DG/map-snap.tsv"
expect_diff "a DOC row aimed at an atom snapshot is refused" 1 "DOC TARGET IS AN ATOM SNAPSHOT" \
  "$DG/old.tsv" "$DG/new.tsv" "$DG/map-snap.tsv"

printf 'a1b2c3\tf.md:1\tдубль\na1b2c3\tf.md:2\tдубль\na1b2c3\tf.md:3\tдубль\nd4e5f6\tf.md:9\tживой\n' > "$DG/many.tsv"
printf 'd4e5f6\tf.md:9\tживой\n' > "$DG/one.tsv"
printf 'a1b2c3\tMOVED\td4e5f6\tодна строка на три потери\n' > "$DG/map-over.tsv"
expect_diff "one map row cannot absorb three lost copies" 1 "TARGET OVERSUBSCRIBED" \
  "$DG/many.tsv" "$DG/one.tsv" "$DG/map-over.tsv"

printf 'a1b2c3\tMERGED\td4e5f6\tраз\na1b2c3\tMOVED\td4e5f6\tдва\n' > "$DG/map-dup.tsv"
expect_diff "two map rows for one hash are refused" 1 "DUPLICATE MAP ROW" \
  "$DG/many.tsv" "$DG/one.tsv" "$DG/map-dup.tsv"

# ── check-frozen --print, round trip and refusal ─────────────────────────────
# --print is documented as the only supported way to regenerate the baseline, and until
# now nothing ran it. Both directions: it reproduces the committed values exactly, and it
# refuses rather than recording an absence as the new truth.
d=$(fresh_copy)
if "$d/tools/check-frozen.sh" --print "$d" > "$d/printed" 2>"$d/printed.err"; then
  # a temp file rather than <(…): this script is /bin/sh, and process substitution is a
  # bash extension that dash on the CI runner does not have
  /usr/bin/grep -v '^#' "$ROOT/tools/frozen.sha256" | /usr/bin/grep . > "$d/committed"
  if diff -q "$d/committed" "$d/printed" >/dev/null; then
    ok "--print reproduces the committed baseline exactly"
  else
    bad "--print disagrees with tools/frozen.sha256"
    diff "$d/committed" "$d/printed" | sed 's/^/        /'
  fi
else
  bad "--print failed on an untouched copy"
  sed 's/^/        /' < "$d/printed.err"
fi

d=$(fresh_copy)
perl -i -pe 's{^является\|тире / перестроить$}{}' "$d/skills/ru-text/references/info-style.md"
if "$d/tools/check-frozen.sh" --print "$d" >"$d/out" 2>"$d/err"; then
  bad "--print emitted a baseline from a corpus missing the probe row"
elif /usr/bin/grep -q 'refusing to emit' "$d/err"; then
  ok "--print refuses a corpus that has lost the probe row"
else
  bad "--print failed, but not with the refusal message"
  sed 's/^/        /' < "$d/err"
fi

# ── the case-folding measurement, pinned ─────────────────────────────────────
# extract-atoms.sh states a number — six collapsed groups, five of them one rule in two
# files — as the reason case is not folded. A measured number in a comment is a promise;
# this is the case that keeps it honest. The arbiter made that the rule after two
# successive commits shipped a different wrong count in this very sentence.
if command -v python3 >/dev/null 2>&1; then
  folded=$(python3 - "$ROOT" <<'PYEOF'
import sys, glob, io, re, collections
R = sys.argv[1]
DASH = {'\u2014':'-','\u2013':'-','\u2212':'-','\u2012':'-','\u2015':'-'}
SP = {'\u00a0':' ','\u202f':' ','\u2009':' ','\t':' '}
def norm(s):
    s = s.replace('\u0451','\u0435').replace('\u0401','\u0415')
    s = ''.join(DASH.get(c, c) for c in s)
    s = ''.join(SP.get(c, c) for c in s)
    s = re.sub(r'[\u00ab\u00bb\u201c\u201d\u201e]', '', s)
    s = re.sub(r'^\|', '', s)
    s = re.sub(r'^ *[-*+] +', '', s)
    s = re.sub(r'^ *#+ +', '', s)
    s = re.sub(r'^ *(R[0-9]+|AD-[0-9]+(\.[0-9]+)?|[0-9]+)[.:)]? +', '', s)
    s = re.sub(r'[*_`]', '', s)
    s = re.sub(r'[!"#$%&()+,./:;<=>?@\[\]^{}~]', '', s)
    return re.sub(r' +', ' ', s).strip()
groups = collections.defaultdict(set)
files = sorted(glob.glob(R + '/skills/ru-text/references/*.md')) + [R + '/skills/ru-text/SKILL.md']
for f in files:
    for line in io.open(f, encoding='utf-8').read().split('\n'):
        if line.strip():
            n = norm(line)
            groups[n.lower()].add(n)
print(sum(1 for v in groups.values() if len(v) > 1))
PYEOF
)
  if [ "$folded" = "6" ]; then
    ok "case folding still collapses exactly 6 groups, as extract-atoms.sh states"
  else
    bad "case folding now collapses $folded groups, not the 6 extract-atoms.sh claims"
  fi
else
  bad "python3 is absent, so the folding figure in extract-atoms.sh is unverified here"
fi

# The interpreter is checked separately from the claim. Folded together, a machine with no
# python3 exited 127, landed in the else branch, and announced that the CORPUS had changed
# — a true-sounding sentence about the wrong file, with 2>/dev/null hiding the one line
# that would have said otherwise.
if ! command -v python3 >/dev/null 2>&1; then
  bad "python3 is absent, so the NFC assumption behind extract-atoms is unverified here"
# $ROOT arrives through argv, never interpolated into the source. Spliced in, a repository
# checked out into a directory whose name contains an apostrophe closes the string literal
# and runs whatever follows it — and the milder half is worse to debug: the interpreter
# raises, the else branch fires, and the selftest announces that THE CORPUS is no longer
# NFC. A true-sounding sentence about the wrong file. The folding check above already
# passes ROOT this way; this one did not.
elif python3 - "$ROOT" <<'PYEOF'; then
import unicodedata, glob, io, sys
R = sys.argv[1]
bad = [(f, i + 1)
       for f in glob.glob(R + '/skills/ru-text/references/*.md') + [R + '/skills/ru-text/SKILL.md']
       for i, l in enumerate(io.open(f, encoding='utf-8').read().split(chr(10)))
       if unicodedata.normalize('NFC', l) != l]
sys.exit(1 if bad else 0)
PYEOF
  ok "the corpus is still NFC (no normalisation step needed)"
else
  bad "the corpus is no longer NFC — extract-atoms must normalise, or comparisons will drift"
fi

printf 'selftest: check-version.sh\n'

# expect_version <case-name> <substring the output must contain> <dir>
expect_version() {
  name=$1; needle=$2; d=$3
  out=$("$d/tools/check-version.sh" 2>&1) && status=0 || status=$?
  if [ "$status" -eq 0 ]; then
    bad "$name — check-version PASSED on corrupted input"
  elif printf '%s' "$out" | grep -qF "$needle"; then
    ok "$name"
  else
    bad "$name — failed, but not for the stated reason (wanted: $needle)"
    printf '%s\n' "$out" | sed 's/^/        /'
  fi
}

d=$(fresh_copy)
if "$d/tools/check-version.sh" >/dev/null 2>&1; then
  ok "an untouched copy passes check-version"
else
  bad "an untouched copy FAILS check-version — the cases below mean nothing"
  "$d/tools/check-version.sh" 2>&1 | sed 's/^/        /'
fi

# One manifest moved and the rest did not: the exact shape of the v1.10.1 slip, where both
# READMEs advertised the previous release while the manifests were current.
d=$(fresh_copy)
# [^"]*, not [0-9.]*: on a pre-release tree the narrow class matches nothing, the sed
# no-ops, and this case passes or fails on whatever else is wrong with the copy.
sed 's/"version": "[^"]*"/"version": "9.9.9"/' "$d/gemini-extension.json" > "$d/v" && mv "$d/v" "$d/gemini-extension.json"
expect_version "one manifest out of step is caught" "version points disagree" "$d"

# A pre-release is a version like any other. The v2.0.0-rc.1 bump caught the prose pattern
# truncating the suffix — 2.0.0-rc.1 read as 2.0.0 — so a correct tree failed as an
# eight-way disagreement. This copy pins the fix after the release strips the suffix from
# the tree itself.
d=$(fresh_copy)
for m in .claude-plugin/plugin.json .claude-plugin/marketplace.json .codex-plugin/plugin.json \
         .cursor-plugin/plugin.json gemini-extension.json openclaw.plugin.json; do
  sed 's/"version": "[^"]*"/"version": "9.9.9-rc.1"/' "$d/$m" > "$d/v" && mv "$d/v" "$d/$m"
done
sed 's/\*\*Version:\*\* [^ ]*/**Version:** 9.9.9-rc.1/' "$d/.claude/CLAUDE.md" > "$d/v" && mv "$d/v" "$d/.claude/CLAUDE.md"
# The social image carries the major.minor line as a literal, and a real version bump moves
# it too — build-og.sh re-renders from this source. Leaving it behind would make this case
# fail for a reason it is not about, and would model a bump nobody should perform.
sed 's|class="ver">[0-9.]*<|class="ver">9.9<|' "$d/assets/og/og.html" > "$d/v" && mv "$d/v" "$d/assets/og/og.html"
if "$d/tools/check-version.sh" >/dev/null 2>&1; then
  ok "a pre-release version agreeing at every point passes"
else
  bad "a pre-release version agreeing at every point FAILS — the prose pattern is truncating the suffix again"
  "$d/tools/check-version.sh" 2>&1 | grep -A9 'FAIL' | sed 's/^/        /'
fi

# The prose copy is the half that actually went stale last time. Both READMEs dropped their
# prose version in favour of a badge that renders live from the releases API, so the one
# prose point left is the convention file — which is the one that went stale SECOND, after
# the READMEs were fixed.
d=$(fresh_copy)
sed 's/\*\*Version:\*\*/**Versionn:**/' "$d/.claude/CLAUDE.md" > "$d/v" && mv "$d/v" "$d/.claude/CLAUDE.md"
expect_version "a version line missing from the convention file is caught" "missing or duplicated" "$d"

# A trigger phrase dropped from the description. This is the failure the file exists for:
# on a host with no instruction file the description IS the trigger, so losing a phrase
# stops the skill firing for Russian-speaking users while every other gate stays green.
d=$(fresh_copy)
sed 's/вычитай, //' "$d/skills/ru-text/SKILL.md" > "$d/v" && mv "$d/v" "$d/skills/ru-text/SKILL.md"
expect_version "a lost trigger phrase is caught" "lost a trigger phrase" "$d"

# Present but pushed out of the head, where a truncating picker stops showing them.
d=$(fresh_copy)
python3 - "$d/skills/ru-text/SKILL.md" <<'PY'
import io, sys
p = sys.argv[1]
s = io.open(p, encoding='utf-8').read()
s = s.replace('  Russian text quality. Triggers: ',
              '  Russian text quality for typography, info-style, editorial, UX writing and\n'
              '  business correspondence, plus AI-text cleanup. Triggers: ')
io.open(p, 'w', encoding='utf-8').write(s)
PY
expect_version "Russian phrases pushed past the head are caught" "past character" "$d"

# Over our own style budget.
d=$(fresh_copy)
python3 - "$d/skills/ru-text/SKILL.md" <<'PY'
import io, sys
p = sys.argv[1]
s = io.open(p, encoding='utf-8').read()
s = s.replace('  причеши, ru-text.', '  причеши, ru-text. ' + ('padding words to overflow the budget ' * 3))
io.open(p, 'w', encoding='utf-8').write(s)
PY
expect_version "a description over the budget is caught" "over our budget" "$d"

# Neither README states the size of SKILL.md any more: the rewrite dropped it, because a
# manifest's word count answers «did the author follow the spec», which is not a question a
# reader has. §4 of check-version stays and is self-activating — if a size claim ever returns,
# it is checked — so these cases BUILD the claim in the sandbox before corrupting it. Testing
# a checker against a claim the product no longer makes would be testing nothing at all.
add_size_claim() { # $1=dir  $2=words  $3=lines
  python3 - "$1/README.md" "$2" "$3" <<'PY'
import io, sys
p, w, l = sys.argv[1], sys.argv[2], sys.argv[3]
s = io.open(p, encoding='utf-8').read()
anchor = '## Обновление'
assert s.count(anchor) == 1, 'anchor moved; fix the fixture'
s = s.replace(anchor, '## Технические детали\n\n- SKILL.md: %s слов, %s строк\n\n' % (w, l) + anchor, 1)
io.open(p, 'w', encoding='utf-8').write(s)
PY
}

skill_words() { python3 -c "import io,re,sys;print(len(re.findall(r'[^ \t\n\r\f\v]+', io.open(sys.argv[1], encoding='utf-8').read())))" "$1/skills/ru-text/SKILL.md"; }
skill_lines() { grep -c '' "$1/skills/ru-text/SKILL.md"; }

# Word count wrong, line count right.
d=$(fresh_copy)
add_size_claim "$d" 999 "$(skill_lines "$d")"
expect_version "a stale SKILL.md word count is caught" "states the size of SKILL.md wrongly" "$d"

# Line count wrong, word count right — pinned separately, because a comparison that looked
# only at words passed this and left the selftest green.
d=$(fresh_copy)
add_size_claim "$d" "$(skill_words "$d")" 42
expect_version "a stale SKILL.md line count is caught" "states the size of SKILL.md wrongly" "$d"

# Two lines stating the size. §1 of this file has lived by «exactly once» since v1.10.1 and
# §4 did not inherit it; it now allows none or one and refuses two.
d=$(fresh_copy)
add_size_claim "$d" 999 42
add_size_claim "$d" 888 41
expect_version "a second line stating the size is caught, not silently ignored" "want at most 1" "$d"

# The file grows and a claim that was correct when written stops being true. This is the
# failure that will actually happen: SKILL.md is edited far more often than the sentence.
d=$(fresh_copy)
add_size_claim "$d" "$(skill_words "$d")" "$(skill_lines "$d")"
printf '\n- A line added to SKILL.md long after the README stopped being re-read.\n' >> "$d/skills/ru-text/SKILL.md"
expect_version "SKILL.md growing past its stated size is caught" "states the size of SKILL.md wrongly" "$d"


printf 'selftest: check-dogfood.sh\n'

expect_dogfood() { # $1=case-name $2=needle $3=dir
  name=$1; needle=$2; d=$3
  out=$(cd "$d" && ./tools/check-dogfood.sh 2>&1) && status=0 || status=$?
  if [ "$status" -eq 0 ]; then
    bad "$name — check-dogfood PASSED on corrupted input"
  elif printf '%s' "$out" | grep -qF "$needle"; then
    ok "$name"
  else
    bad "$name — failed, but not for the stated reason (wanted: $needle)"
    printf '%s\n' "$out" | sed 's/^/        /'
  fi
}

# The word guard, and it exists because the word came back. «онбординг» was written into the
# README's description of ux-writing.md, corrected when a check found the file has no such
# section, and written back in during a rewrite two days later. Numbers had a guard; names did
# not.
d=$(fresh_copy)
python3 - "$d/README.md" <<'PYEOF'
import io, sys
p = sys.argv[1]
s = io.open(p, encoding='utf-8').read()
old = 'уведомления, диалоги подтверждения'
assert s.count(old) == 1, 'anchor moved; fix the fixture'
io.open(p, 'w', encoding='utf-8').write(s.replace(old, 'уведомления, онбординг'))
PYEOF
expect_dogfood "a file credited with a section it does not have is caught" "does not contain it" "$d"

# The install prompt, quoted in three files. The divergence this catches was invisible: a
# typography normaliser put two non-breaking spaces inside the copyable command, so the README
# stopped matching the string tools/probe-install.sh hands a fresh agent — and the probe began
# testing a string we do not publish. Two non-breaking spaces are exactly the mutation.
d=$(fresh_copy)
python3 - "$d/README.md" <<'PYEOF'
import io, re, sys
p = sys.argv[1]
s = io.open(p, encoding='utf-8').read()
m = re.search(r'Установи навык.*?ru-text\.', s, re.S)
assert m, 'anchor moved; fix the fixture'
io.open(p, 'w', encoding='utf-8').write(
    s.replace(m.group(0), m.group(0).replace('\u00a0вызывай', '\u00a0\u00a0вызывай', 1), 1))
PYEOF
expect_dogfood "an install prompt that drifted between files is caught" "must quote it identically" "$d"

# The two install guides, which nothing compared. `62a164f` corrected «re-running the command
# updates it» in INSTALL.md and not in INSTALL.en.md, and the English half carried the
# disproved instruction for eleven days while the English README began asserting it was fixed.
# Prose translates; COMMANDS do not, so the set of commands each file quotes must be the same,
# and a command that exists in one guide and not the other is a half-applied correction.
d=$(fresh_copy)
python3 - "$d/INSTALL.en.md" <<'PYEOF'
import io, sys
p = sys.argv[1]
s = io.open(p, encoding='utf-8').read()
old = 'rsync -a --delete ru-text/skills/ru-text/ ~/.agents/skills/ru-text/'
assert s.count(old) == 1, 'anchor moved; fix the fixture'
io.open(p, 'w', encoding='utf-8').write(s.replace(old, 'cp -r ru-text/skills/ru-text ~/.agents/skills/'))
PYEOF
expect_dogfood "a command that exists in one install guide and not the other is caught" \
  "the install guides quote different commands" "$d"


# The golden set's own size, stated in prose. Two AD-17 cases landed and the figure stayed at
# 22 — a hand-maintained number in the file that documents the measurement, which is the defect
# this release spent two days removing from the READMEs.
d=$(fresh_copy)
mkdir -p "$d/tools/golden/99-a-case-nobody-counted"
: > "$d/tools/golden/99-a-case-nobody-counted/text.md"
expect_dogfood "a golden case the README did not count is caught" "cases and holds" "$d"

# The noun agrees with the numeral, and the guard used to hard-code one form. At 28 the file
# correctly says «текстов», the pattern wanted «текста», and the guard reported «no longer
# states how many cases the set holds» — failing on correct Russian, in the repository whose
# subject is correct Russian. The case pins the READING, not the agreement: whatever form the
# prose takes, the guard must come back with the NUMBER and compare it.
d=$(fresh_copy)
python3 - "$d/tools/golden/README.md" <<'PYEOF'
import io, re, sys
p = sys.argv[1]
s = io.open(p, encoding='utf-8').read()
# «Все 21 текст» — the singular form, which no fixed «текста» pattern can see.
io.open(p, 'w', encoding='utf-8').write(re.sub(r'Все[\s\u00a0]+[0-9]+[\s\u00a0]+текст(а|ов)?',
                                               'Все 21 текст', s, count=1))
PYEOF
expect_dogfood "a size stated in another numeral agreement is still read" "says 21 cases" "$d"

# The word budget for the one file loaded on every turn. It was stated twice in the convention
# file and checked nowhere, and it was FALSE while it stood: «under 600 words» over a file of
# 615. A budget nobody can fail is not a budget. Two cases, one per direction: the count must
# be read against the stated number, and a missing statement must not read as «within budget».
d=$(fresh_copy)
python3 - "$d/skills/ru-text/SKILL.md" <<'PYEOF'
import io, sys
p = sys.argv[1]
s = io.open(p, encoding='utf-8').read()
io.open(p, 'w', encoding='utf-8').write(s + '\n' + ('padding word ' * 200) + '\n')
PYEOF
expect_dogfood "a SKILL.md over its stated budget is caught" "over the stated budget" "$d"

d=$(fresh_copy)
python3 - "$d/.claude/CLAUDE.md" <<'PYEOF'
import io, re, sys
p = sys.argv[1]
s = io.open(p, encoding='utf-8').read()
io.open(p, 'w', encoding='utf-8').write(re.sub(r'at most \*\*[0-9]+ words\*\*', 'as small as it can be', s, count=1))
PYEOF
expect_dogfood "a budget removed from the convention file is caught" "no longer states a word budget" "$d"

d=$(fresh_copy)
if (cd "$d" && ./tools/check-dogfood.sh >/dev/null 2>&1); then
  ok "an untouched copy passes check-dogfood"
else
  bad "an untouched copy FAILS check-dogfood — the cases below mean nothing"
  (cd "$d" && ./tools/check-dogfood.sh 2>&1) | sed 's/^/        /'
fi

# A consumer left behind when the catalogue moves. This is the defect the checker exists
# for: four files went stale unnoticed the last time the number changed.
d=$(fresh_copy)
sed 's/Full stop-word catalog (92 entries)/Full stop-word catalog (91 entries)/' \
  "$d/skills/ru-text/SKILL.md" > "$d/v" && mv "$d/v" "$d/skills/ru-text/SKILL.md"
expect_dogfood "a consumer left behind is caught" "and these do not" "$d"

# A claim nobody registered. The explicit list is only safe because this guard exists.
d=$(fresh_copy)
# A file NOT on the list: appending to README.md would prove nothing, because the guard
# skips listed files by design.
printf 'The catalogue holds 92 entries.\n' > "$d/CONTRIBUTING.md"
( cd "$d" && git add -A ) >/dev/null 2>&1
expect_dogfood "an unregistered claim is caught" "no claim is registered" "$d"

# The corpus itself moving, with every claim left at the old number.
d=$(fresh_copy)
python3 - "$d/skills/ru-text/references/info-style.md" <<'PY'
import io, re, sys
p = sys.argv[1]
s = io.open(p, encoding='utf-8').read()
s = re.sub(r'(?m)^(## B\. Каталог стоп-слов.*\n)', r'\1\nвыдуманное|заменённое\n', s, count=1)
io.open(p, 'w', encoding='utf-8').write(s)
PY
expect_dogfood "the corpus growing past its claims is caught" "and these do not" "$d"

# The number of machine-text tells, stated six times across two READMEs and measured nowhere.
# The count is not the number of rules in the file: AD-18 is a rule about human emphasis and
# says so in its own body, so «eighteen rules, seventeen tells» are both true and a reader
# counting headings gets the other number. A handoff note spent a session calling this a
# contradiction. Three mutations: the corpus moving, one claim left behind, and a statement
# nobody registered.
d=$(fresh_copy)
python3 - "$d/skills/ru-text/references/addenda.md" <<'PYEOF'
import io, sys
p = sys.argv[1]
s = io.open(p, encoding='utf-8').read()
old = '**Not a neuroslop tell, deliberately.**'
assert s.count(old) == 1, 'anchor moved; fix the fixture'
io.open(p, 'w', encoding='utf-8').write(s.replace(old, '**A tell like any other.**'))
PYEOF
expect_dogfood "a rule that stopped excluding itself is counted" "the corpus holds 18" "$d"

d=$(fresh_copy)
python3 - "$d/README.md" <<'PYEOF'
import io, sys
p = sys.argv[1]
s = io.open(p, encoding='utf-8').read()
old = 'Всего таких признаков 17'
assert s.count(old) == 1, 'anchor moved; fix the fixture'
io.open(p, 'w', encoding='utf-8').write(s.replace(old, 'Всего таких признаков 16'))
PYEOF
expect_dogfood "one README left behind when the tells move is caught" "the corpus holds 17" "$d"

d=$(fresh_copy)
printf 'Навык знает семнадцать признаков машинного текста.\n' > "$d/CONTRIBUTING.md"
( cd "$d" && git add -A ) >/dev/null 2>&1
expect_dogfood "an unregistered statement of the tell count is caught" "no claim is registered" "$d"

# The minimal pair for the hole a reviewer opened: the SAME sentence, inside a file that is
# on the claim list. The first version skipped claimant files wholesale, so a claim could rot
# inside the very README the checker was reading — the substring test found the phrase
# somewhere in the file and nothing looked at the rest of it. Registered claims are now
# subtracted from the LINE, and the sweep knows every number it can spell, not just today's:
# a site left behind states the OLD count, which the current value's patterns cannot see.
d=$(fresh_copy)
printf '\nВ справочнике шестнадцать признаков машинного текста.\n' >> "$d/README.md"
expect_dogfood "a stale count left inside a claimant README is caught" "no claim is registered" "$d"

# Every claim row, one at a time. Mutating all six at once proves nothing: a checker holding
# one row would still fail. A reviewer showed the list could be cut from six rows to two and
# the fixtures stayed green — four of the six sites were pinned by nothing.
for claim in '17 признаков машинного текста (нейрослоп)|17 признаков письма машины (нейрослоп)' \
             'Всего таких признаков 17|Всего таких признаков ровно столько' \
             '17 признаков машинного текста с|17 признаков письма машины с' \
             'seventeen tells of machine-written text|seventeen marks of machine-written text' \
             'There are seventeen such tells in all|There are seventeen such items in all' \
             'seventeen tells of machine writing, with|seventeen tells of machine prose, with'; do
  old=${claim%%|*}
  new=${claim#*|}
  d=$(fresh_copy)
  for f in README.md README.en.md; do
    python3 - "$d/$f" "$old" "$new" <<'PYEOF'
import io, sys
p, old, new = sys.argv[1], sys.argv[2], sys.argv[3]
s = io.open(p, encoding='utf-8').read()
if old in s:
    io.open(p, 'w', encoding='utf-8').write(s.replace(old, new, 1))
PYEOF
  done
  expect_dogfood "a tell claim rephrased away is caught: ${old}" "the corpus holds 17" "$d"
done

# Every form the sweep must see, one at a time, in a file no claim list mentions. The pattern
# set could be cut from four to one and the fixtures stayed green.
for form in 'Навык знает семнадцать признаков.' \
            'The skill knows seventeen tells.' \
            'Всего 17 признаков машинного письма.' \
            'It carries 17 tells.'; do
  d=$(fresh_copy)
  printf '%s\n' "$form" > "$d/CONTRIBUTING.md"
  ( cd "$d" && git add -A ) >/dev/null 2>&1
  expect_dogfood "an unregistered count in the form «$form» is caught" "no claim is registered" "$d"
done

# A heading whose dot was forgotten. `## AD-19 Foo` used to be invisible to the parser, so a
# rule added with a typo was silently uncounted — a wrong PASS produced by a slip of the hand.
d=$(fresh_copy)
printf '\n## AD-19 A rule added with the dot forgotten\n\nBody.\n' \
  >> "$d/skills/ru-text/references/addenda.md"
expect_dogfood "an AD heading missing its dot is still counted" "the corpus holds 18" "$d"

# The Notion template's own size, which was stated four times in two languages and measured
# nowhere. One of the four overstated by more than double: «9 признаков в 4 категориях» over
# a section holding four tells and nine examples.
d=$(fresh_copy)
python3 - "$d/notion/ru-text-notion-skill.md" <<'PYEOF'
import io, sys
p = sys.argv[1]
s = io.open(p, encoding='utf-8').read()
old = '### Пустой зачин'
assert s.count(old) == 1, 'anchor moved; fix the fixture'
io.open(p, 'w', encoding='utf-8').write(s.replace(old, '### Пустой зачин\n\nA fifth tell.\n\n### Ещё один признак'))
PYEOF
expect_dogfood "a tell added to the Notion template its README did not count is caught" "does not say" "$d"

d=$(fresh_copy)
python3 - "$d/notion/README.md" <<'PYEOF'
import io, sys
p = sys.argv[1]
s = io.open(p, encoding='utf-8').read()
old = '- 30 anti-patterns'
assert s.count(old) == 1, 'anchor moved; fix the fixture'
io.open(p, 'w', encoding='utf-8').write(s.replace(old, '- 31 anti-patterns'))
PYEOF
expect_dogfood "a Notion count left behind in the English half is caught" "does not say" "$d"

# A claim whose numeral CONTAINS the true one. The collision was found on the word forms —
# «восемнадцать» holds «семнадцать» letter for letter, and a substring test passed a README
# claiming EIGHTEEN over a reference holding seventeen. The Russian sites state the count in
# digits now (§G.1 of editorial-grammar: ten and up are digits), so the case is pinned on the
# digit form, where the same collision lives: «117» contains «17». The word forms `bounded()`
# still knows are what catches a stale claim that arrives spelled out.
d=$(fresh_copy)
python3 - "$d/README.md" <<'PYEOF'
import io, sys
p = sys.argv[1]
s = io.open(p, encoding='utf-8').read()
old = 'Всего таких признаков 17'
assert s.count(old) == 1, 'anchor moved; fix the fixture'
io.open(p, 'w', encoding='utf-8').write(s.replace(old, 'Всего таких признаков 117'))
PYEOF
expect_dogfood "a claim whose numeral CONTAINS the true one is caught" "the corpus holds 17" "$d"

# A claim written across a line break. Claims are prose and prose wraps: the roadmap says
# «seventeen tells\nof machine prose», and a checker reading line by line calls it missing.
d=$(fresh_copy)
python3 - "$d/docs/roadmap-v3-grammar.md" <<'PYEOF'
import io, sys
p = sys.argv[1]
s = io.open(p, encoding='utf-8').read()
old = 'seventeen tells'
assert s.count(old) == 1, 'anchor moved; fix the fixture'
io.open(p, 'w', encoding='utf-8').write(s.replace(old, 'a good number of tells'))
PYEOF
expect_dogfood "a wrapped claim rephrased away is caught" "the corpus holds 17" "$d"

# The rest of the sweep's forms, and the rest of the window. The pattern set was pinned at
# two values out of the eleven it covers, and the «таких» / «such» alternative at none.
for form in 'Навык знает семнадцать таких признаков.' \
            'The skill holds seventeen such tells.' \
            'Раньше их было пятнадцать признаков.' \
            'Двадцать признаков — потолок.' \
            'Навык знает девять признаков ИИ-текста.' \
            'Once there were five tells.'; do
  d=$(fresh_copy)
  printf '%s\n' "$form" > "$d/CONTRIBUTING.md"
  ( cd "$d" && git add -A ) >/dev/null 2>&1
  expect_dogfood "an unregistered count in the form «$form» is caught" "no claim is registered" "$d"
done

# A claim is about the words, not about which codepoint separates them. `notion/README.md`
# states «в 8 категориях», and the typography gate binds that single-letter preposition with
# U+00A0 — so a byte-exact search stopped finding a sentence that had just been made MORE
# correct. Two gates on one line, disagreeing about a space. Both directions, because the
# live file carries the non-breaking one and a case that only reads it proves nothing.
d=$(fresh_copy)
python3 - "$d/notion/README.md" <<'PYEOF'
import io, sys
p = sys.argv[1]
s = io.open(p, encoding='utf-8').read()
old = '- 92 stop-words across'
assert s.count(old) == 1, 'anchor moved; fix the fixture'
# The claim list writes an ordinary space here, so putting a NON-breaking one in the file
# is what a byte-exact reader cannot survive. The first draft did the reverse and left file
# and template byte-identical — a fixture written for the scenario, not for the contract.
io.open(p, 'w', encoding='utf-8').write(
    s.replace(old, '- 92' + chr(0xA0) + 'stop-words across'))
PYEOF
if (cd "$d" && ./tools/check-dogfood.sh >/dev/null 2>&1); then
  ok "a claim separated by an ordinary space is still found"
else
  bad "a claim stops being found when its space changes codepoint"
  (cd "$d" && ./tools/check-dogfood.sh 2>&1) | grep -F FAIL | sed 's/^/        /'
fi

# A claim deleted outright, then reassembled by two unrelated paragraphs standing next to
# each other. The codepoint-agnostic reader collapsed newlines too, so it read the whole file
# as one line and called the claim present — the very failure its sibling matcher documents
# a hundred lines below.
d=$(fresh_copy)
python3 - "$d/notion/README.md" <<'PYEOF'
import io, sys
p = sys.argv[1]
s = io.open(p, encoding='utf-8').read()
old = '- 92 stop-words across 8 categories with replacements'
assert s.count(old) == 1, 'anchor moved; fix the fixture'
# ONLY the catalogue claim is broken. The first draft split the line in a way that destroyed
# the CATEGORY claim too, and `verify_claims` words both failures identically — so the case
# passed on the collateral damage and would have reported success forever while the arm it
# was written for stayed unheld. `across 8 categories` is left contiguous on purpose.
io.open(p, 'w', encoding='utf-8').write(
    s.replace(old, 'Ends in - 92\n\nstop-words across 8 categories with replacements'))
PYEOF
# The needle names the family, not the number: writing today's 92 into it would plant the
# hand-maintained figure this very checker exists to remove.
expect_dogfood "a claim reassembled across a paragraph break is not counted as present" \
  "stop-word catalogue: the corpus says" "$d"


# The blank line as a hard boundary. Flattening the file lets a claim be found across a line
# wrap — and, without this, lets a claim DELETED outright be satisfied by two unrelated
# paragraphs happening to end and begin with the right words.
d=$(fresh_copy)
python3 - "$d/README.en.md" <<'PYEOF'
import io, sys
p = sys.argv[1]
s = io.open(p, encoding='utf-8').read()
old = 'There are seventeen such tells in all.'
assert s.count(old) == 1, 'anchor moved; fix the fixture'
io.open(p, 'w', encoding='utf-8').write(
    s.replace(old, 'There are seventeen such\n\ntells in all.'))
PYEOF
expect_dogfood "a claim split by a blank line is not counted as present" "the corpus holds 17" "$d"

# The offset map. Both writing fixtures above are one line long, so nothing proved the sweep
# reports the line a wrapped hit actually sits on rather than the first line of the file.
d=$(fresh_copy)
printf 'Первая строка ни о чём.\n\nВторая строка ни о чём.\n\nЗдесь их семнадцать\nпризнаков.\n' \
  > "$d/CONTRIBUTING.md"
( cd "$d" && git add -A ) >/dev/null 2>&1
out=$(cd "$d" && ./tools/check-dogfood.sh 2>&1) && status=0 || status=$?
if [ "$status" -eq 0 ]; then
  bad "a wrapped unregistered count is not caught at all"
elif printf '%s' "$out" | grep -qF 'CONTRIBUTING.md:5'; then
  ok "a wrapped unregistered count is reported on the line it starts at"
else
  bad "a wrapped unregistered count is reported on the wrong line"
  printf '%s\n' "$out" | grep -F 'CONTRIBUTING.md' | sed 's/^/        /'
fi

# The exemption list names two lines of ordinary prose that put a numeral beside «признак».
# A list of exceptions that is not itself checked becomes a list of lies.
d=$(fresh_copy)
python3 - "$d/skills/ru-text/references/info-style.md" <<'PYEOF'
import io, sys
p = sys.argv[1]
s = io.open(p, encoding='utf-8').read()
old = 'Три признака слабого текста'
assert s.count(old) == 1, 'anchor moved; fix the fixture'
io.open(p, 'w', encoding='utf-8').write(s.replace(old, 'Признаки слабого текста'))
PYEOF
expect_dogfood "an exemption naming a line that is gone is caught" "drop the exemption" "$d"

# The other direction, and the one that makes an exemption dangerous: a phrase that occurs
# twice silences two lines while the checker only ever needed one silenced. One entry could
# then hide a real stale claim that happened to be worded the same way.
d=$(fresh_copy)
printf '\nТри признака слабого текста: повтор той же формулировки ниже по файлу.\n' \
  >> "$d/skills/ru-text/references/info-style.md"
expect_dogfood "an exemption that silences more than one line is caught" "not a phrase" "$d"

# The skip list and the extension filter, each of which could be widened or narrowed with the
# suite green. One case per boundary, in a file no claim mentions.
d=$(fresh_copy)
printf '\nЗдесь семнадцать признаков.\n' >> "$d/INSTALL.md"
expect_dogfood "an unregistered count in a top-level file outside the skip list is caught" \
  "no claim is registered" "$d"

d=$(fresh_copy)
printf '\n# seventeen tells are described here\n' >> "$d/skills/ru-text/agents/openai.yaml"
expect_dogfood "an unregistered count in a YAML file is caught" "no claim is registered" "$d"

# Past twenty the checker refuses instead of demanding «двадцать один признаков», which is
# ungrammatical — in the repository whose subject is grammar.
d=$(fresh_copy)
python3 - "$d/skills/ru-text/references/addenda.md" <<'PYEOF'
import io, sys
p = sys.argv[1]
s = io.open(p, encoding='utf-8').read()
s += ''.join('\n## AD-%d. Filler\n\nBody.\n' % k for k in range(20, 24))
io.open(p, 'w', encoding='utf-8').write(s)
PYEOF
expect_dogfood "a count past the word table is refused, not guessed" "knows no word form" "$d"

# Outside a git checkout the sweep cannot run, and must say so rather than emit a traceback.
d=$(fresh_copy)
mv "$d/.git" "$d/.git-disabled"
expect_dogfood "a copy that is not a git checkout is named, not crashed on" "not a git checkout" "$d"

# --print is advertised as «what it measured, and every place that claims it», and no case
# ever ran it. A branch nobody executes is a branch nobody maintains.
d=$(fresh_copy)
out=$(cd "$d" && ./tools/check-dogfood.sh --print 2>&1) && status=0 || status=$?
if [ "$status" -ne 0 ]; then
  bad "--print exits non-zero"
elif printf '%s' "$out" | grep -qF 'machine-text tells: 17' \
  && printf '%s' "$out" | grep -qF 'seventeen tells of machine writing'; then
  ok "--print lists the tell count and every place that states it"
else
  bad "--print does not list the tell claims it advertises"
  printf '%s\n' "$out" | sed 's/^/        /'
fi

# The Notion gate measures four numbers, and three of them could be replaced by the constant
# they were measuring with the suite green. One case per number: change the TEMPLATE and the
# README's figure must stop matching — which a constant cannot notice.
d=$(fresh_copy)
python3 - "$d/notion/ru-text-notion-skill.md" <<'PYEOF'
import io, sys
p = sys.argv[1]
s = io.open(p, encoding='utf-8').read()
old = '| Ruble symbol after number | 1500 руб | 1 500 ₽ |'
assert s.count(old) == 1, 'anchor moved; fix the fixture'
io.open(p, 'w', encoding='utf-8').write(
    s.replace(old, old + '\n| Degree sign | 20 C | 20 °C |'))
PYEOF
expect_dogfood "a typography row the Notion README did not count is caught" "does not say" "$d"

d=$(fresh_copy)
python3 - "$d/notion/ru-text-notion-skill.md" <<'PYEOF'
import io, re, sys
p = sys.argv[1]
s = io.open(p, encoding='utf-8').read()
head = '### Плеоназмы (убрать лишнее слово)'
assert s.count(head) == 1, 'anchor moved; fix the fixture'
i = s.index(head)
j = s.index('\n\n', s.index('|---', i))
io.open(p, 'w', encoding='utf-8').write(s[:j] + '\n| совместное сотрудничество | сотрудничество |' + s[j:])
PYEOF
expect_dogfood "an anti-pattern row the Notion README did not count is caught" "does not say" "$d"

d=$(fresh_copy)
python3 - "$d/notion/ru-text-notion-skill.md" <<'PYEOF'
import io, sys
p = sys.argv[1]
s = io.open(p, encoding='utf-8').read()
old = '| Объясню чётко, по делу. | Объясню. |'
assert s.count(old) == 1, 'anchor moved; fix the fixture'
io.open(p, 'w', encoding='utf-8').write(
    s.replace(old, old + '\n| Скажу коротко и ясно. | Скажу. |'))
PYEOF
expect_dogfood "a tell example the Notion README did not count is caught" "does not say" "$d"

# The template's own heading is a consumer too: «Top 30» over thirty-one rows is the same
# defect one level in, and it sits inside the file the gate measures.
d=$(fresh_copy)
python3 - "$d/notion/ru-text-notion-skill.md" <<'PYEOF'
import io, sys
p = sys.argv[1]
s = io.open(p, encoding='utf-8').read()
old = '## Anti-Patterns: Top 30'
assert s.count(old) == 1, 'anchor moved; fix the fixture'
io.open(p, 'w', encoding='utf-8').write(s.replace(old, '## Anti-Patterns: Top 29'))
PYEOF
expect_dogfood "a template heading that miscounts its own section is caught" "does not head its section" "$d"

# The Russian half of the Notion README was held by nothing: «сверяет с обеими половинами»
# was true of the code and false of the cases.
d=$(fresh_copy)
python3 - "$d/notion/README.md" <<'PYEOF'
import io, sys
p = sys.argv[1]
s = io.open(p, encoding='utf-8').read()
old = '- 12 правил типографики'
assert s.count(old) == 1, 'anchor moved; fix the fixture'
io.open(p, 'w', encoding='utf-8').write(s.replace(old, '- 13 правил типографики'))
PYEOF
expect_dogfood "a Notion count left behind in the Russian half is caught" "does not say" "$d"

# The Notion gate's own reader, both directions. It was left byte-exact when its sibling
# stopped being so — two readers of one file disagreeing about what a space is — and then
# both had to learn that a newline is NOT one.
d=$(fresh_copy)
python3 - "$d/notion/README.md" <<'PYEOF'
import io, sys
p = sys.argv[1]
s = io.open(p, encoding='utf-8').read()
old = '- 30 anti-patterns'
assert s.count(old) == 1, 'anchor moved; fix the fixture'
io.open(p, 'w', encoding='utf-8').write(s.replace(old, '- 30' + chr(0xA0) + 'anti-patterns'))
PYEOF
if (cd "$d" && ./tools/check-dogfood.sh >/dev/null 2>&1); then
  ok "a Notion claim separated by a non-breaking space is still found"
else
  bad "the Notion reader still compares spaces by codepoint"
  (cd "$d" && ./tools/check-dogfood.sh 2>&1) | grep -F FAIL | sed 's/^/        /'
fi

d=$(fresh_copy)
python3 - "$d/notion/README.md" <<'PYEOF'
import io, sys
p = sys.argv[1]
s = io.open(p, encoding='utf-8').read()
old = '- 12 typography rules (always applied)'
assert s.count(old) == 1, 'anchor moved; fix the fixture'
io.open(p, 'w', encoding='utf-8').write(
    s.replace(old, '- 12\n\ntypography rules (always applied)'))
PYEOF
expect_dogfood "a Notion claim reassembled across a paragraph break is not counted as present" \
  "does not say" "$d"

printf 'selftest: build-release.sh\n'

expect_build() { # $1=case-name $2=needle $3=dir [$4=mode: check|build]
  # NOT `${4:---check}`: that substitutes the default for an EMPTY fourth argument too, so
  # the «dirty tree» case silently ran in --check mode and passed. A named mode cannot do
  # that, and the mistake is invisible in the output when it happens.
  name=$1; needle=$2; d=$3
  if [ "${4:-check}" = "build" ]; then flag=""; else flag="--check"; fi
  out=$(cd "$d" && ./tools/build-release.sh $flag 2>&1) && status=0 || status=$?
  if [ "$status" -eq 0 ]; then
    bad "$name — build-release PASSED on corrupted input"
  elif printf '%s' "$out" | grep -qF "$needle"; then
    ok "$name"
  else
    bad "$name — failed, but not for the stated reason (wanted: $needle)"
    printf '%s\n' "$out" | tail -3 | sed 's/^/        /'
  fi
}

d=$(fresh_copy)
if (cd "$d" && ./tools/build-release.sh --check >/dev/null 2>&1); then
  ok "an untouched copy builds both assets and round-trips"
else
  bad "an untouched copy FAILS build-release — the cases below mean nothing"
  (cd "$d" && ./tools/build-release.sh --check 2>&1) | tail -4 | sed 's/^/        /'
fi

# A reference file dropped from the index. This is the failure with no symptom: the skill
# still installs, still activates, and answers from whatever corpus it has left.
d=$(fresh_copy)
( cd "$d" && git rm -q --cached skills/ru-text/references/ux-writing.md ) >/dev/null 2>&1
expect_build "a reference file missing from the asset is caught" "in the asset" "$d"

# The build must not run at all without the skill it is named after.
d=$(fresh_copy)
( cd "$d" && git rm -q --cached skills/ru-text/SKILL.md ) >/dev/null 2>&1
expect_build "a staged tree with no ru-text/SKILL.md is caught" "no ru-text/SKILL.md" "$d"

# Without --check the tree must be clean: an artefact built from a dirty tree matches no
# commit, and the version inside it is then a claim about code that does not exist.
d=$(fresh_copy)
printf 'scratch\n' > "$d/skills/ru-text/references/scratch.md"
expect_build "a dirty tree refuses a real build" "working tree is dirty" "$d" build

printf 'selftest: gates.sh\n'

# gates.sh calls this file, so a case that ran it unmodified would re-enter the selftest
# forever. The copy's selftest is replaced by a stub whose exit code the case chooses:
# what is under test here is the ORCHESTRATION — that a red checker stops the run, that a
# green tree does not — never the checker being stubbed.
# The stub prints a summary line as well as choosing an exit code, because gates.sh now
# requires one: a run that printed no summary did not finish, whatever it exited with.
stub_selftest() {
  printf '#!/bin/sh\nprintf "selftest: 1 passed, %s failed\\n"\nexit %s\n' "$2" "$2" \
    > "$1/tools/selftest.sh"
  chmod +x "$1/tools/selftest.sh"
}

d=$(fresh_copy); stub_selftest "$d" 0
if "$d/tools/gates.sh" >/dev/null 2>&1; then
  ok "gates.sh passes on an untouched copy"
else
  bad "gates.sh FAILS on an untouched copy — every case below means nothing"
  "$d/tools/gates.sh" 2>&1 | sed 's/^/        /'
fi

d=$(fresh_copy); stub_selftest "$d" 1
if "$d/tools/gates.sh" >/dev/null 2>&1; then
  bad "gates.sh passed although a checker exited non-zero"
else
  ok "a red checker stops gates.sh"
fi

# A suite that DIED mid-run: status 0, no summary. Not hypothetical — an uninitialised
# counter aborted this very file under `set -eu`, and its EXIT trap turned the abort into
# a zero. gates.sh read it as a pass, and every gate below it ran on a lie.
d=$(fresh_copy)
printf '#!/bin/sh\nprintf "  ok    one case\\n"\nexit 0\n' > "$d/tools/selftest.sh"
chmod +x "$d/tools/selftest.sh"
if "$d/tools/gates.sh" >/dev/null 2>&1; then
  bad "gates.sh passed although the selftest exited 0 without finishing"
else
  ok "a selftest that exits 0 without a summary stops gates.sh"
fi

# The no-loss gate is the LAST step, so a script that quietly stopped earlier would still
# pass the case above. Losing a corpus line must reach it.
#
# The line is taken from typography.md, which has not changed since v1.10.1, and NOT from
# addenda.md. The gate compares against the pinned baseline, so it can only miss an atom
# the baseline HAS: trimming a line added after v1.10.1 is invisible to it by design, and
# this case silently stopped testing anything the day addenda.md grew a new last line.
#
# A named rule, not `sed '$d'`. The last LINE of a reference file is not necessarily the
# last ATOM of it — typography.md ends on blank lines, so deleting the last line deleted
# nothing the gate could miss, and the case passed the corpus as intact while asserting the
# opposite. R1 is the first typography rule and has been in the corpus since long before
# the pinned baseline.
d=$(fresh_copy); stub_selftest "$d" 0
sed '/^R1\. Основные кавычки/d' "$d/skills/ru-text/references/typography.md" > "$d/trimmed" \
  && mv "$d/trimmed" "$d/skills/ru-text/references/typography.md"
grep -q '^R1\. Основные кавычки' "$d/skills/ru-text/references/typography.md" \
  && bad "the fixture did not remove R1 — the case below proves nothing"
if "$d/tools/gates.sh" >/dev/null 2>&1; then
  bad "gates.sh passed on a corpus that lost a line — it never reached the no-loss gate"
else
  ok "a corpus that lost a line stops gates.sh"
fi

# gates.sh and the CI workflow are two copies of one sequence, kept in step by hand. Two
# copies drift; this is the case that says so out loud. Comments are stripped first, so
# naming a checker in prose does not count as running it.
CI=$ROOT/.github/workflows/gates.yml
# The character class covers what a checker may actually be named. It was `[a-z0-9-]+`,
# which cannot see `tools/check_new.sh`, `tools/checkNew.sh`, or anything in a subdirectory
# — three ways to add a checker to one file and not the other with this case still green.
checkers() { sed 's/#.*//' "$1" | grep -oE 'tools/[A-Za-z0-9._/-]+\.sh' | sort -u; }
if [ ! -f "$CI" ]; then
  bad "the CI workflow is missing — gates.sh has nothing to be in step with"
elif [ "$(checkers "$ROOT/tools/gates.sh")" = "$(checkers "$CI")" ]; then
  ok "gates.sh invokes exactly the checkers CI invokes"
else
  bad "gates.sh and CI disagree about which checkers run"
  printf '        gates.sh: %s\n' "$(checkers "$ROOT/tools/gates.sh" | tr '\n' ' ')"
  printf '        CI:       %s\n' "$(checkers "$CI" | tr '\n' ' ')"
fi

# Naming a checker is not running it. A checker whose failure is swallowed — `|| true`,
# or the line replaced by an `echo` that still mentions it — leaves the case above green,
# because that case compares NAMES. This one compares the shape of the invocation: every
# line in gates.sh that runs a checker must hand its failure to `fail`, and there must be
# as many such lines as there are checkers, so that deleting one is not a way to pass.
# `if ! tools/x.sh; then :; fi` runs a checker too, and the anchor used to miss it — a
# swallowed failure in that shape was invisible to both arms of this case.
guarded_invocations() { sed 's/#.*//' "$1" | grep -E '^[[:space:]]*(if[[:space:]]+!?[[:space:]]*)?tools/[A-Za-z0-9._/-]+\.sh' || true; }
inv=$(guarded_invocations "$ROOT/tools/gates.sh")
inv_n=$(printf '%s\n' "$inv" | grep -c . || true)
unguarded=$(printf '%s\n' "$inv" | grep -c -v '|| fail' || true)
[ -z "$inv" ] && inv_n=0 && unguarded=0
if [ "$inv_n" -ge 4 ] && [ "$unguarded" -eq 0 ]; then
  ok "every checker gates.sh runs hands its failure to fail (${inv_n} invocations)"
else
  bad "gates.sh: ${inv_n} checker invocations, ${unguarded} of them unguarded (want >=4 and 0)"
  printf '%s\n' "$inv" | sed 's/^/        /'
fi

# The executable-and-parseable gate is the one step of gates.sh no name comparison can see:
# it is written as the glob `tools/*.sh`, which matches no checker path. It was removable
# with every case still green. Tested by behaviour rather than by grep — a checker that
# cannot be parsed, in a subdirectory, must stop the run.
d=$(fresh_copy); stub_selftest "$d" 0
mkdir -p "$d/tools/sub"
printf '#!/bin/sh\nif then fi\n' > "$d/tools/sub/broken.sh"; chmod +x "$d/tools/sub/broken.sh"
out=$("$d/tools/gates.sh" 2>&1) && st=0 || st=$?
if [ "$st" -eq 0 ]; then
  bad "an unparseable checker did not stop gates.sh — the syntax gate is gone or shallow"
elif printf '%s' "$out" | grep -qF 'syntax error: tools/sub/broken.sh'; then
  ok "an unparseable checker in a subdirectory stops gates.sh, and says which one"
else
  bad "gates.sh failed, but not on the syntax gate — the case proves nothing"
  printf '%s\n' "$out" | tail -3 | sed 's/^/        /'
fi

# The syntax gate must speak the runner's shell. /bin/sh is bash 3.2 on macOS and dash on
# the ubuntu runner, so a bashism passed locally and failed in CI — the divergence a local
# gate exists to catch first. Skipped, loudly, where dash is absent: a case that cannot run
# must not report as a case that passed.
if command -v dash >/dev/null 2>&1; then
  d=$(fresh_copy); stub_selftest "$d" 0
  printf '#!/bin/sh\narr=(a b)\necho "$arr"\n' > "$d/tools/bashism.sh"; chmod +x "$d/tools/bashism.sh"
  if "$d/tools/gates.sh" >/dev/null 2>&1; then
    bad "a bashism in a checker passed the syntax gate — sh -n instead of dash -n?"
  else
    ok "a bashism in a checker is caught locally, as it would be on the runner"
  fi
else
  note "dash absent — the bashism case did not run (the runner's /bin/sh is dash)"
fi

# Static, and said to be static: $ROOT must reach python through argv, never spliced into
# the source. A repository checked out into a directory whose name contains an apostrophe
# closes the string literal and runs what follows; the milder half is a false «the corpus
# is no longer NFC» about a file that is fine.
spliced=$(grep -cE "glob\.glob\('\\\$ROOT|open\('\\\$ROOT|'\\\$ROOT/" "$ROOT/tools/selftest.sh" || true)
viaargv=$(grep -cE "^(elif )?python3 - \"\\\$ROOT\"|^ *folded=\\\$\(python3 - \"\\\$ROOT\"" "$ROOT/tools/selftest.sh" || true)
if [ "$spliced" -eq 0 ] && [ "$viaargv" -ge 2 ]; then
  ok "both python blocks take \$ROOT through argv, none splices it into the source"
else
  bad "\$ROOT spliced into python source (${spliced} sites) or argv form lost (${viaargv} of 2)"
fi

# The parity case compares two sets built by ONE regex, so narrowing that regex blinds both
# sides at once and the case cannot notice. Pin its breadth directly, on the names that
# broke it: an underscore, a camel hump, a subdirectory.
probe=$(printf 'tools/check_new.sh\ntools/checkNew.sh\ntools/sub/deep.sh\n' \
        | grep -cE 'tools/[A-Za-z0-9._/-]+\.sh' || true)
[ "$probe" -eq 3 ] && ok "the checker-name pattern covers _, camelCase and subdirectories" \
                   || bad "the checker-name pattern matched $probe of 3 — divergence would go unseen"

# CI can stop RUNNING a checker while still naming it, and the name comparison would stay
# green. Every checker named in the workflow must sit on a line that runs it.
if [ -f "$CI" ]; then
  badline=$(sed 's/#.*//' "$CI" | grep -E 'tools/[A-Za-z0-9._/-]+\.sh' \
            | grep -vE '^[[:space:]]*(run:[[:space:]]*)?(\$\()?(sha256sum|for|\[|tools/)' | grep -c . || true)
  [ "$badline" -eq 0 ] && ok "every checker the CI workflow names is on a line that runs it" \
                       || bad "CI names $badline checker(s) outside a running line"
fi

# The baseline pin is written out twice for the same reason, and a stale copy is worse
# than none: the local gate would keep vouching for a baseline the repository no longer has.
#
# Comments are stripped from BOTH sides. Stripping only the local one meant a CI pin block
# commented out — the check gone, the text still there — compared equal and stayed green.
if [ -f "$CI" ]; then
  hashes() { sed 's/#.*//' "$1" | grep -oE '[0-9a-f]{64}' | sort -u; }
  pinpath() { sed 's/#.*//' "$1" | grep -oE 'tools/baseline/[A-Za-z0-9.-]+' | sort -u; }
  pin_local=$(hashes "$ROOT/tools/gates.sh"); pin_ci=$(hashes "$CI")
  path_local=$(pinpath "$ROOT/tools/gates.sh"); path_ci=$(pinpath "$CI")
  if [ -n "$pin_local" ] && [ -n "$path_local" ] &&
     [ "$pin_local" = "$pin_ci" ] && [ "$path_local" = "$path_ci" ]; then
    ok "the baseline pin in gates.sh matches CI, file and hash"
  else
    bad "baseline pin differs: gates.sh $path_local $pin_local / CI $path_ci $pin_ci"
  fi
fi

printf 'selftest: check-typography.sh\n'

# The checker shipped green over eight real defects, because both halves of its R30 pattern
# were narrower than the rule: the letter set held lowercase only, and the follower class
# demanded a Cyrillic letter or a digit next.
#
# The two cases below pin one half EACH, and their shapes are chosen for that and nothing else.
# The first pair written here failed this requirement — «В WSL-сессиях» and «В [README]» both
# combine a capital preposition with a non-Cyrillic follower, so either mutation killed both
# and neither hand was actually guarded. Verified by mutation: restoring the lowercase-only set
# must break the FIRST case only, and restoring the narrow follower class the SECOND only.
#   capital + Cyrillic follower  -> isolates the letter set
#   lowercase + non-letter       -> isolates the follower class
expect_typo() { # $1=case-name  $2=needle  $3=dir
  name=$1; needle=$2; d=$3
  out=$(cd "$d" && ./tools/check-typography.sh 2>&1) && st=0 || st=$?
  if [ "$st" -eq 0 ]; then
    bad "$name — check-typography PASSED on corrupted input"
  elif printf '%s' "$out" | grep -qF "$needle"; then
    ok "$name"
  else
    bad "$name — failed, but not for the stated reason (wanted: $needle)"
    printf '%s\n' "$out" | sed 's/^/        /'
  fi
}

# The Notion setup guide joined the checked list, and it is the only bilingual page there.
# Two cases, one per direction: a defect on its Russian half is caught, and correct English
# on its English half is not — «2,000+ linguistic atoms» is a comma between digit groups
# that R32/R53 forbids in Russian and English style requires.
d=$(fresh_copy)
python3 - "$d/notion/README.md" <<'PYEOF'
import io, sys
p = sys.argv[1]
s = io.open(p, encoding='utf-8').read()
old = 'Шаблон навыка' + chr(0xA0) + '— сжатая'
assert s.count(old) == 1, 'anchor moved; fix the fixture'
io.open(p, 'w', encoding='utf-8').write(s.replace(old, 'Шаблон навыка — сжатая'))
PYEOF
expect_typo "a defect on the Notion guide's Russian half is caught" "R16/R44" "$d"

# The tilde carve-out. The only tilde case plants into README.md — monolingual, and on a line
# carrying Cyrillic — a path the bilingual skip can never reach, so nothing distinguished
# «checked before the skip» from «checked after it». Here it sits on the English half.
d=$(fresh_copy)
python3 - "$d/notion/README.md" <<'PYEOF'
import io, sys
p = sys.argv[1]
s = io.open(p, encoding='utf-8').read()
anchor = '## Setup'
assert s.count(anchor) >= 1, 'anchor moved; fix the fixture'
io.open(p, 'w', encoding='utf-8').write(
    s.replace(anchor, 'A placeholder that outlived a tool round-trip: 5~000 atoms.\n\n' + anchor, 1))
PYEOF
expect_typo "a stray tilde on the English half is still caught" "stray-tilde" "$d"

# The per-file conjunct. Drop `path in BILINGUAL` and the skip goes GLOBAL: every Cyrillic-free
# line of README.md and INSTALL.md silently loses R32/R53, R16/R44 and the ellipsis rule. The
# header states that contract in words — «on a monolingual Russian page a line without Cyrillic
# can still be a digit group that R32/R53 governs» — and a sentence is not a mechanism.
d=$(fresh_copy)
printf '\n| MCP | 2,000 | 5 000 |\n' >> "$d/README.md"
expect_typo "a digit group on a Cyrillic-free line of a monolingual page is still checked" \
  "R32/R53" "$d"

# A tilde that is a home directory is followed by a slash, and the carve-out now runs on both
# halves of a bilingual page — so the one thing keeping `~/.agents/skills` out of the report is
# a single lookahead nothing exercised.
d=$(fresh_copy)
python3 - "$d/README.md" <<'PYEOF'
import io, sys
# Written by codepoint: the first draft of this fixture broke R30 twice on its own single-letter
# prepositions, so the case failed on the fixture rather than on the thing it tests.
nb = chr(0xA0)
line = '\nНавык лежит в' + nb + 'каталоге ~/.agents/skills и' + nb + 'читается оттуда.\n'
io.open(sys.argv[1], 'a', encoding='utf-8').write(line)
PYEOF
if (cd "$d" && ./tools/check-typography.sh >/dev/null 2>&1); then
  ok "a tilde that opens a home directory is not reported as a mangled space"
else
  bad "a home directory is reported as a stray tilde"
  (cd "$d" && ./tools/check-typography.sh 2>&1) | sed 's/^/        /'
fi

# --print is the scope contract in machine-readable form, and nothing ran it. The bilingual
# list was added to it in the same session that found the file missing from the checked list.
d=$(fresh_copy)
out=$(cd "$d" && ./tools/check-typography.sh --print 2>&1) && status=0 || status=$?
if [ "$status" -ne 0 ]; then
  bad "check-typography --print exits non-zero"
# INSTALL.md, not notion/README.md: the latter appears in BOTH blocks, so the bilingual
# list alone satisfied it and the checked-files half was held by nothing.
elif printf '%s' "$out" | grep -qF 'INSTALL.md' \
  && printf '%s' "$out" | grep -qF 'bilingual'; then
  ok "check-typography --print discloses the checked files and the bilingual ones"
else
  bad "check-typography --print does not disclose the scope it advertises"
  printf '%s\n' "$out" | sed 's/^/        /'
fi

d=$(fresh_copy)
python3 - "$d/notion/README.md" <<'PYEOF'
import io, sys
p = sys.argv[1]
s = io.open(p, encoding='utf-8').read()
anchor = '## Setup'
assert s.count(anchor) >= 1, 'anchor moved; fix the fixture'
io.open(p, 'w', encoding='utf-8').write(
    s.replace(anchor, 'A set of 3,000+ atoms is described below - see the guide.\n\n' + anchor, 1))
PYEOF
if (cd "$d" && ./tools/check-typography.sh >/dev/null 2>&1); then
  ok "correct English on the Notion guide's English half is not flagged"
else
  bad "English prose on a bilingual page is measured by Russian rules"
  (cd "$d" && ./tools/check-typography.sh 2>&1) | sed 's/^/        /'
fi

d=$(fresh_copy)
if (cd "$d" && ./tools/check-typography.sh >/dev/null 2>&1); then
  ok "an untouched copy passes check-typography"
else
  bad "an untouched copy FAILS check-typography — the cases below mean nothing"
  (cd "$d" && ./tools/check-typography.sh 2>&1) | sed 's/^/        /'
fi

# A CAPITAL preposition, which the first pattern never tested — and which is where a Russian
# sentence most often starts one.
d=$(fresh_copy)
python3 - "$d/INSTALL.md" <<'PYEOF'
import io, sys
p = sys.argv[1]
s = io.open(p, encoding='utf-8').read()
io.open(p, 'w', encoding='utf-8').write(s.replace('В\u00a0приложении', 'В приложении', 1))
PYEOF
expect_typo "a capital single-letter preposition is caught" "single-letter «В»" "$d"

# A preposition followed by something that is not a Cyrillic letter — a markdown link. The
# first pattern required a letter or digit next and let every one of these through.
d=$(fresh_copy)
python3 - "$d/INSTALL.md" <<'PYEOF'
import io, sys
p = sys.argv[1]
s = io.open(p, encoding='utf-8').read()
io.open(p, 'w', encoding='utf-8').write(s.replace('и\u00a0**`.agents/skills/`**', 'и **`.agents/skills/`**', 1))
PYEOF
expect_typo "a preposition before a non-letter is caught" "single-letter «и»" "$d"

# The two defects that actually shipped, kept as regression cases.
d=$(fresh_copy)
python3 - "$d/README.md" <<'PYEOF'
import io, sys
p = sys.argv[1]
s = io.open(p, encoding='utf-8').read()
s = s.replace('машинного текста', 'машинного~текста', 1)
io.open(p, 'w', encoding='utf-8').write(s)
PYEOF
expect_typo "a literal tilde standing in for a non-breaking space is caught" "literal ~" "$d"

d=$(fresh_copy)
python3 - "$d/README.md" <<'PYEOF'
import io, sys
p = sys.argv[1]
s = io.open(p, encoding='utf-8').read()
io.open(p, 'w', encoding='utf-8').write(s.replace('\u00a0\u2014', ' \u2014', 1))
PYEOF
expect_typo "an ordinary space before an em dash is caught" "before an em dash" "$d"

# Digit grouping. This case exists because it ESCAPED: the checker was green over «более
# 2 000 атомов» set with an ordinary space, since nothing looked at digit groups at all, and
# a judge found it by reading the file rather than by running the gate.
d=$(fresh_copy)
python3 - "$d/README.md" <<'PY'
import io, sys
p = sys.argv[1]
s = io.open(p, encoding='utf-8').read()
io.open(p, 'w', encoding='utf-8').write(s.replace('2\u00a0000', '2 000', 1))
PY
expect_typo "an ordinary space between digit groups is caught" "between digit groups" "$d"

printf 'selftest: check-assets.sh\n'

# The checker was written the day the OpenAI portal refused our upload \u2014 \u00abImage must be
# square; provided image is 981x993\u00bb \u2014 on a file that had been that shape since it was drawn.
# Its three assertions are mutated one at a time below, because a fixture that breaks two at
# once proves neither.
expect_assets() { # $1=case-name  $2=needle  $3=dir
  name=$1; needle=$2; d=$3
  out=$(cd "$d" && ./tools/check-assets.sh 2>&1) && st=0 || st=$?
  if [ "$st" -eq 0 ]; then
    bad "$name \u2014 check-assets PASSED on corrupted input"
  elif printf '%s' "$out" | grep -qF "$needle"; then
    ok "$name"
  else
    bad "$name \u2014 failed, but not for the stated reason (wanted: $needle)"
    printf '%s\n' "$out" | sed 's/^/        /'
  fi
}

d=$(fresh_copy)
if (cd "$d" && ./tools/check-assets.sh >/dev/null 2>&1); then
  ok "an untouched copy passes check-assets"
else
  bad "an untouched copy FAILS check-assets \u2014 the cases below mean nothing"
  (cd "$d" && ./tools/check-assets.sh 2>&1) | sed 's/^/        /'
fi

# 1. Not square. One pixel column is enough; the portal measures, it does not eyeball.
d=$(fresh_copy)
python3 - "$d/logo-round.png" <<'PY'
import struct, sys, zlib
# Rewrite the IHDR width, and its CRC with it, without decoding the image: this keeps the
# case about squareness rather than about whatever an encoder would change on a round-trip.
p = sys.argv[1]
b = bytearray(open(p, 'rb').read())
w, h = struct.unpack('>II', bytes(b[16:24]))
b[16:20] = struct.pack('>I', w - 1)
b[29:33] = struct.pack('>I', zlib.crc32(bytes(b[12:29])) & 0xffffffff)
open(p, 'wb').write(bytes(b))
PY
expect_assets "an image that is one pixel off square is caught" "not square" "$d"

# 2. A reference to a file that is not there. This is the silent one: awesome-codex-plugins
# fetches the icon, fails, and publishes the listing without it \u2014 no error anywhere.
d=$(fresh_copy)
mv "$d/assets/icon.png" "$d/assets/icon-renamed.png"
expect_assets "a manifest pointing at a file that is not there is caught" "missing file" "$d"

# 3. Over the 50 KB icon ceiling that awesome-codex-plugins enforces in its own CI.
d=$(fresh_copy)
cp "$d/logo-round.png" "$d/assets/icon.png"
expect_assets "an icon over the 50 KB ceiling is caught" "icon over" "$d"

# The base a relative path resolves from differs by vendor, and the first version of the
# checker assumed one convention for both \u2014 reporting Codex's images as missing while its
# own bundle resolved them fine. This pins that the Cursor manifest's `../` form is still
# understood: break the file it reaches, and the checker must say so.
d=$(fresh_copy)
python3 - "$d/logo-round.png" <<'PY'
import struct, sys, zlib
p = sys.argv[1]
b = bytearray(open(p, 'rb').read())
w, h = struct.unpack('>II', bytes(b[16:24]))
b[20:24] = struct.pack('>I', h - 1)
b[29:33] = struct.pack('>I', zlib.crc32(bytes(b[12:29])) & 0xffffffff)
open(p, 'wb').write(bytes(b))
PY
expect_assets "a path written relative to the manifest's own directory still resolves" \
  ".cursor-plugin/plugin.json" "$d"

# Initials. Found by a judge reading the sources list after three green gates had run over
# it — the fourth rule this checker did not name. The pattern of the misses is worth stating:
# every one was a rule the corpus has and the checker did not, never a rule it got wrong.
d=$(fresh_copy)
python3 - "$d/README.md" <<'PYEOF'
import io, sys
p = sys.argv[1]
s = io.open(p, encoding='utf-8').read()
io.open(p, 'w', encoding='utf-8').write(s.replace('А.\u00a0Э.\u00a0Мильчин', 'А. Э. Мильчин', 1))
PYEOF
expect_typo "an ordinary space after an initial is caught" "after an initial" "$d"

printf 'selftest: measure-prose-shape.py\n'

# The instrument that will decide whether the flattening is real
# (docs/roadmap-v2.1-conservation.md). If it cannot tell a flat text from a varied one, the
# measurement it produces is worthless and every rule built on it is built on nothing.
#
# Two synthetic texts of the SAME word count, differing only in shape: one is eight
# eight-word declaratives, the other is the same content in sentences of 3 to 22 words with
# subordination. The instrument must separate them on the coefficient of variation, and it
# must NOT separate them on total words — a checker that merely counts words would pass a
# CV assertion by accident, so both directions are asserted.
d=$(mktemp -d "$TMPROOT/shape.XXXXXX")
cat > "$d/flat.md" <<'FLATEOF'
Система замедляется под нагрузкой. Очередь растёт линейно до предела. Дальше начинаются
отказы на каждом запросе. Мы сняли замеры на трёх стендах. Результат совпал во всех трёх
случаях. Порог держится около восьмисот запросов в секунду. Ниже порога задержка почти не
меняется. Выше порога задержка растёт очень быстро.
FLATEOF
cat > "$d/varied.md" <<'VARIEDEOF'
Система замедляется. Очередь растёт линейно до предела, за которым начинаются отказы, и
происходит это не постепенно, а сразу на всех запросах разом. Мы сняли замеры. Результат
совпал на трёх стендах, хотя стенды собирали разные люди и в разное время. Порог держится
около восьмисот запросов в секунду. Ниже него задержка почти не меняется, выше растёт так
быстро, что пользователь замечает это раньше любого монитора.
VARIEDEOF

flat_cv=$(python3 tools/measure-prose-shape.py "$d/flat.md" \
  | awk '/^  длина предложения/ {print $5}')
var_cv=$(python3 tools/measure-prose-shape.py "$d/varied.md" \
  | awk '/^  длина предложения/ {print $5}')
if [ -z "$flat_cv" ] || [ -z "$var_cv" ]; then
  bad "measure-prose-shape printed no CV for sentence length"
elif awk -v a="$flat_cv" -v b="$var_cv" 'BEGIN{exit !(b > a * 1.5)}'; then
  ok "a varied text measures a visibly higher CV than a flat one ($var_cv vs $flat_cv)"
else
  bad "measure-prose-shape cannot separate flat from varied prose: CV $flat_cv vs $var_cv"
fi

# The two full-stop guards, mutated SEPARATELY, because a fixture that exercises both at
# once proves neither. The first version of this case failed exactly that test: it put «т. д.»
# before a comma and «т. е.» before a lowercase word, where the splitter would not have cut
# anyway — so it passed with the ABBREV list emptied, and guarded nothing. Verified by
# mutation: emptying ABBREV must break the FIRST case only, and removing the initials regex
# the SECOND only. Both need a full stop followed by space + CAPITAL, which is the one shape
# the splitter acts on.
cat > "$d/abbr.md" <<'ABBREOF'
Полный список расхождений см. Приложение 2 в конце документа.
ABBREOF
n=$(python3 tools/measure-prose-shape.py "$d/abbr.md" | awk '/^  слов / {print $4}')
if [ "$n" = "1" ]; then
  ok "an abbreviation before a capital does not invent a sentence boundary"
else
  bad "ABBREV guard failed: counted $n sentences where there is 1"
fi

cat > "$d/initials.md" <<'INITEOF'
Справочники Д. Э. Розенталя лежат на той же полке.
INITEOF
n=$(python3 tools/measure-prose-shape.py "$d/initials.md" | awk '/^  слов / {print $4}')
if [ "$n" = "1" ]; then
  ok "initials do not invent a sentence boundary"
else
  bad "initials guard failed: counted $n sentences where there is 1"
fi

printf 'selftest: build-og.sh\n'

# The social images are a generated artefact whose generator is committed, which is this
# project's own standard for anything generated. These cases guard the two claims that make
# the arrangement worth anything: that --check actually notices when the render stops
# matching the source, and that a missing input fails loudly rather than rendering a card
# with a hole in it.
#
# Skipped, not failed, where no browser exists: the ubuntu runner has no Chrome, and a green
# suite that reddens over a missing renderer teaches people to ignore it. The skip is
# counted and printed.
if ! (cd "$ROOT" && ./tools/build-og.sh --check >/dev/null 2>&1); then
  skip "build-og cases — no renderer here, or the committed images already differ"
else
  d=$(fresh_copy)
  # fresh_copy stages but never commits, and --check reads the blob out of HEAD. Without a
  # commit every case here would report MISSING instead of exercising the comparison.
  ( cd "$d" && git -c user.email=t@t -c user.name=t commit -qm baseline ) >/dev/null 2>&1
  # A two-pixel change to the accent rule. Small enough that only a real comparison finds it.
  python3 - "$d/assets/og/og.html" <<'PYEOF'
import io, sys
p = sys.argv[1]
s = io.open(p, encoding='utf-8').read()
io.open(p, 'w', encoding='utf-8').write(
    s.replace('width: 58px; height: 2px', 'width: 60px; height: 2px', 1))
PYEOF
  out=$(cd "$d" && ./tools/build-og.sh --check 2>&1) && st=0 || st=$?
  if [ "$st" -eq 0 ]; then
    bad "build-og --check PASSED after the source changed"
  elif printf '%s' "$out" | grep -q 'DIFFERS'; then
    ok "build-og --check notices when the render stops matching its source"
  else
    bad "build-og --check failed, but not for the stated reason"
    printf '%s\n' "$out" | sed 's/^/        /'
  fi

  d=$(fresh_copy)
  mv "$d/assets/mark.png" "$d/assets/mark-hidden.png"
  out=$(cd "$d" && ./tools/build-og.sh 2>&1) && st=0 || st=$?
  if [ "$st" -eq 0 ]; then
    bad "build-og rendered a card with its mark missing"
  elif printf '%s' "$out" | grep -q 'assets/mark.png'; then
    ok "a missing input is named, not silently drawn around"
  else
    bad "build-og failed on a missing mark, but did not name the file"
  fi
fi

printf 'selftest: probe-install.sh\n'

# The probe judges what an agent did to a sandbox. These cases judge the probe, by building
# the three outcomes by hand — because the one thing a gate must never do is pass on an
# install that did not happen, and that is exactly what an «is there a SKILL.md anywhere»
# check would do.
probe_case() { # $1=case-name  $2=want(PASS|FAIL)  $3=needle  $4=sandbox
  name=$1; want=$2; needle=$3; sb=$4
  out=$("$ROOT/tools/probe-install.sh" check "$sb" 'Codex CLI' 2>&1) && st=PASS || st=FAIL
  if [ "$st" != "$want" ]; then
    bad "$name — probe said $st, wanted $want"
    printf '%s\n' "$out" | sed 's/^/        /'
  elif [ -z "$needle" ] || printf '%s' "$out" | grep -qF "$needle"; then
    ok "$name"
  else
    bad "$name — $st, but not for the stated reason (wanted: $needle)"
    printf '%s\n' "$out" | sed 's/^/        /'
  fi
}

PB=$(mktemp -d)

# Nobody ran the agent. An empty sandbox must never read as a clean install.
"$ROOT/tools/probe-install.sh" setup "$PB/empty" 'Codex CLI' >/dev/null 2>&1
probe_case "an empty sandbox is not a pass" FAIL "holds no SKILL.md" "$PB/empty"

# The documented user path. This is the only shape that may pass.
"$ROOT/tools/probe-install.sh" setup "$PB/good" 'Codex CLI' >/dev/null 2>&1
mkdir -p "$PB/good/home/.agents/skills"
cp -R "$ROOT/skills/ru-text" "$PB/good/home/.agents/skills/ru-text"
probe_case "an install at the documented path passes" PASS "documented path" "$PB/good"

# The failure this file was written from: a real agent installed Codex's copy into
# ~/.codex/skills on the strength of a December-2025 blog post. The path exists, the skill
# is intact, and Codex never looks there.
"$ROOT/tools/probe-install.sh" setup "$PB/stray" 'Codex CLI' >/dev/null 2>&1
mkdir -p "$PB/stray/home/.codex/skills"
cp -R "$ROOT/skills/ru-text" "$PB/stray/home/.codex/skills/ru-text"
probe_case "an install at an undocumented path is caught" FAIL "does not look" "$PB/stray"

# Right path, wrong corpus. An agent that fetched an old tag or a fork passes every path
# test above; only the bytes catch it.
"$ROOT/tools/probe-install.sh" setup "$PB/stale" 'Codex CLI' >/dev/null 2>&1
mkdir -p "$PB/stale/home/.agents/skills"
cp -R "$ROOT/skills/ru-text" "$PB/stale/home/.agents/skills/ru-text"
printf '\nA line no released ru-text ever carried.\n' >> "$PB/stale/home/.agents/skills/ru-text/SKILL.md"
probe_case "a stale or forked copy at the right path is caught" FAIL "differs from this checkout" "$PB/stale"

# Right path, right SKILL.md, half the corpus. The reference files are the product; a probe
# that stopped at SKILL.md would bless a skill with no rules in it.
"$ROOT/tools/probe-install.sh" setup "$PB/partial" 'Codex CLI' >/dev/null 2>&1
mkdir -p "$PB/partial/home/.agents/skills"
cp -R "$ROOT/skills/ru-text" "$PB/partial/home/.agents/skills/ru-text"
rm -f "$PB/partial/home/.agents/skills/ru-text/references/typography.md"
probe_case "a truncated corpus at the right path is caught" FAIL "truncated" "$PB/partial"

# A symlinked install. The first version of the probe called this «a different thing from an
# installed one» and would have failed it; a live run refuted that in one shot, with OpenAI's
# own page: «Codex supports symlinked skill folders and follows the symlink target». The agent
# had linked deliberately, so that a pull on the clone updates the install.
"$ROOT/tools/probe-install.sh" setup "$PB/link" 'Codex CLI' >/dev/null 2>&1
mkdir -p "$PB/link/home/src" "$PB/link/home/.agents/skills"
cp -R "$ROOT/skills/ru-text" "$PB/link/home/src/ru-text"
ln -s "$PB/link/home/src/ru-text" "$PB/link/home/.agents/skills/ru-text"
probe_case "a symlinked install at the documented path passes" PASS "documented path" "$PB/link"

# The clone an agent makes before linking or copying. It is an intermediate, not a rogue
# install, and the same live run had the probe report the source tree as four of them.
"$ROOT/tools/probe-install.sh" setup "$PB/clone" 'Codex CLI' >/dev/null 2>&1
mkdir -p "$PB/clone/home/src/ru-text/.claude-plugin" "$PB/clone/home/.agents/skills"
cp -R "$ROOT/skills" "$PB/clone/home/src/ru-text/skills"
# The manifest is what makes a tree this repository rather than any directory with a .git —
# see the decoy case below, which is why the marker had to become this specific.
cp "$ROOT/.claude-plugin/plugin.json" "$PB/clone/home/src/ru-text/.claude-plugin/plugin.json"
( cd "$PB/clone/home/src/ru-text" && git init -q . ) >/dev/null 2>&1
cp -R "$ROOT/skills/ru-text" "$PB/clone/home/.agents/skills/ru-text"
probe_case "the source clone is not reported as a rogue install" PASS "no copy landed outside" "$PB/clone"

# The bypass a security review found and reproduced in one command: an empty `.git` beside a
# rogue install disarmed the clone exclusion, and the probe printed PASS over an install at
# the stale-blog path. A gate that a `mkdir` switches off is worse than no gate.
#
# The decoy is built exactly as the review built it, at ~/.codex/skills — which also pins the
# SECOND attempt at the fix. That one required the tree to hold `skills/ru-text/SKILL.md`, and
# `~/.codex/skills/ru-text` has that shape with no decoy at all, so any platform whose skills
# directory is named `skills` would have excused itself. Only the plugin manifest separates a
# checkout from an install.
"$ROOT/tools/probe-install.sh" setup "$PB/decoy" 'Codex CLI' >/dev/null 2>&1
mkdir -p "$PB/decoy/home/.agents/skills" "$PB/decoy/home/.codex/skills/.git"
cp -R "$ROOT/skills/ru-text" "$PB/decoy/home/.agents/skills/ru-text"
cp -R "$ROOT/skills/ru-text" "$PB/decoy/home/.codex/skills/ru-text"
mkdir -p "$PB/decoy/home/.codex/.git"
probe_case "a decoy .git does not excuse an install at an undocumented path" FAIL "does not look" "$PB/decoy"

# The repository's own test fixture lives at tools/testdata/corpus/SKILL.md, outside skills/.
# The first clone rule excused only files under the root's `skills/`, so a genuine clone was
# reported as a rogue install on the strength of a fixture. Everything under a verified root
# is source.
"$ROOT/tools/probe-install.sh" setup "$PB/fixture" 'Codex CLI' >/dev/null 2>&1
mkdir -p "$PB/fixture/home/src/ru-text/.claude-plugin" "$PB/fixture/home/.agents/skills"
cp -R "$ROOT/skills" "$PB/fixture/home/src/ru-text/skills"
cp -R "$ROOT/tools" "$PB/fixture/home/src/ru-text/tools"
cp "$ROOT/.claude-plugin/plugin.json" "$PB/fixture/home/src/ru-text/.claude-plugin/plugin.json"
( cd "$PB/fixture/home/src/ru-text" && git init -q . ) >/dev/null 2>&1
cp -R "$ROOT/skills/ru-text" "$PB/fixture/home/.agents/skills/ru-text"
probe_case "a fixture outside skills/ does not make a clone look rogue" PASS "no copy landed outside" "$PB/fixture"

# Every platform named in the table is either given paths or declared to own its installer.
# A row typo silently produces a platform this probe can never judge.
missing=$(awk -F'\t' '!/^#/ && $1 != "platform" && NF > 1 { print $1 "\t" $3 }' "$ROOT/tools/install-paths.tsv" \
  | awk -F'\t' '{ if ($2 == "-") own[$1]=1; else has[$1]=1 }
                END { for (p in own) if (p in has) print p }')
if [ -z "$missing" ]; then
  ok "no platform is both path-served and self-installing"
else
  bad "a platform claims both a path and its own installer: $missing"
fi

rm -rf "$PB"

if [ "${skipped:-0}" -gt 0 ]; then
  printf 'selftest: %d passed, %d failed, %d skipped\n' "$pass" "$fail" "$skipped"
else
  printf 'selftest: %d passed, %d failed\n' "$pass" "$fail"
fi
finished=1
[ "$fail" -eq 0 ]
