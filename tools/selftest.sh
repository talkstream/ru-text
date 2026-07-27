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
trap 'rm -rf "$TMPROOT"' EXIT INT TERM

pass=0
fail=0
note() { printf '  %s\n' "$1"; }
ok()   { pass=$((pass + 1)); printf '  ok    %s\n' "$1"; }
bad()  { fail=$((fail + 1)); printf '  FAIL  %s\n' "$1"; }

# fresh_copy — a self-contained repository slice: corpus, tools and baseline, all writable
fresh_copy() {
  d=$(mktemp -d "$TMPROOT/case.XXXXXX")
  mkdir -p "$d/skills/ru-text"
  cp -R "$ROOT/skills/ru-text/references" "$d/skills/ru-text/references"
  cp "$ROOT/skills/ru-text/SKILL.md" "$d/skills/ru-text/SKILL.md"
  cp -R "$ROOT/tools" "$d/tools"
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
expect_diff() {
  name=$1; want=$2; needle=$3; o=$4; n=$5; m=${6:-$ROOT/tools/atom-map.tsv}
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
elif python3 -c "
import unicodedata,glob,io,sys
bad=[(f,i+1) for f in glob.glob('$ROOT/skills/ru-text/references/*.md')+['$ROOT/skills/ru-text/SKILL.md']
     for i,l in enumerate(io.open(f,encoding='utf-8').read().split(chr(10)))
     if unicodedata.normalize('NFC',l)!=l]
sys.exit(1 if bad else 0)"; then
  ok "the corpus is still NFC (no normalisation step needed)"
else
  bad "the corpus is no longer NFC — extract-atoms must normalise, or comparisons will drift"
fi

printf 'selftest: %d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
