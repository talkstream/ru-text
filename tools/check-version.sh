#!/bin/sh
# check-version.sh — one version, one description budget, one set of triggers.
#
#     tools/check-version.sh            # verify
#     tools/check-version.sh --print    # what it found, for eyes only
#
# Exit 0 only when every place that states the version states the same one, the skill
# description fits the budget, and every trigger phrase the product depends on is present.
#
# Why it exists. Nothing here is clever; all of it is arithmetic a person was doing by hand
# and getting wrong. The v1.10.1 gate found both READMEs advertising the previous release,
# then found .claude/CLAUDE.md doing the same. On 2026-07-28 the corpus-size figure turned
# out to have drifted across eleven files at once, and correcting it by hand is what makes
# it drift again. A number repeated in N places has N chances to be wrong and one script to
# be right.
#
# The three checks are deliberately unlike each other:
#   version      — an equality: every point must agree, and it does not matter what it is.
#   description  — a budget: OUR style budget of 250 characters, not a platform limit. The
#                  spec allows 1024 and the Claude Code listing is softer still; we keep the
#                  shorter one because the string is read by humans in a picker. Calling it
#                  a platform limit would be a lie that outlives whoever wrote it.
#   triggers     — a presence test, and the reason this file matters most. On the Claude
#                  apps and on ChatGPT there is no instruction file: the description IS the
#                  whole trigger. Lose a Russian phrase there and the skill stops
#                  activating for the people it was written for, silently, with every gate
#                  still green.

set -eu
export LC_ALL=C

cd "$(dirname "$0")/.."

SKILL=skills/ru-text/SKILL.md
BUDGET=250          # our own style budget, see the note above
FIRST_N=100         # the Russian phrases must sit inside the first this-many characters

fail=0
ok()  { printf '  ok    %s\n' "$1"; }
bad() { fail=$((fail + 1)); printf '  FAIL  %s\n' "$1"; }

# Every place that hardcodes the version. Seven JSON points across six manifests — the
# marketplace carries two — plus three lines of prose that a release has to remember.
version_points() {
  python3 - <<'PY'
import io, json, re

MANIFESTS = ['.claude-plugin/plugin.json', '.claude-plugin/marketplace.json',
             '.codex-plugin/plugin.json', '.cursor-plugin/plugin.json',
             'gemini-extension.json', 'openclaw.plugin.json']

def walk(o, path=''):
    if isinstance(o, dict):
        for k, v in o.items():
            yield from walk(v, path + '/' + k)
    elif isinstance(o, list):
        for i, v in enumerate(o):
            yield from walk(v, path + '/%d' % i)
    else:
        yield path, o

for m in MANIFESTS:
    d = json.load(io.open(m, encoding='utf-8'))
    for p, v in walk(d):
        if p.rsplit('/', 1)[-1] == 'version' and isinstance(v, str):
            print('%s%s\t%s' % (m, p, v))

# Prose. Each pattern must match exactly once: a second copy is where the first goes stale.
# Both READMEs used to state the version in prose, and both are gone from this list on
# purpose. The version badge at the top of each renders live from the releases API, so the
# page states the current version without anyone maintaining a number by hand — and a fact
# with two sources, one of which decays, is the defect this whole file exists to prevent.
# The v1.10.1 gate caught exactly that: manifests current, prose advertising the release
# before. Removing the second source removes the class.
# The capture admits a semver pre-release suffix. The v2.0.0-rc.1 bump found the bare
# triple truncating it: the file said 2.0.0-rc.1, the pattern read 2.0.0, and a correct
# tree failed as an eight-way disagreement.
PROSE = [
    ('.claude/CLAUDE.md', r'\*\*Version:\*\*\s*([0-9]+\.[0-9]+\.[0-9]+(?:-[0-9A-Za-z.-]+)?)'),
]
for path, pat in PROSE:
    s = io.open(path, encoding='utf-8').read()
    hits = re.findall(pat, s)
    if len(hits) != 1:
        print('%s\tMISSING-OR-DUPLICATE(%d)' % (path, len(hits)))
    else:
        print('%s\t%s' % (path, hits[0]))
PY
}

# The skill description, unfolded from the YAML block scalar into the one line a host shows.
description() {
  python3 - "$SKILL" <<'PY'
import io, re, sys
s = io.open(sys.argv[1], encoding='utf-8').read()
fm = re.search(r'\A---\n(.*?)\n---', s, re.S)
if not fm:
    sys.exit('no frontmatter in ' + sys.argv[1])
m = re.search(r'^description:[ \t]*(?:>-?|\|-?)?[ \t]*\n((?:[ \t]+\S.*\n)+)|^description:[ \t]*(.+)$',
              fm.group(1), re.M)
if not m:
    sys.exit('no description in ' + sys.argv[1])
body = m.group(1) or m.group(2) or ''
text = ' '.join(l.strip() for l in body.strip().split('\n'))
# Длина — в СИМВОЛАХ. `wc -m` под LC_ALL=C считает байты, а кириллица в UTF-8 двухбайтовая:
# на бюджете 250 это давало 255 «символов» для строки из 210 и роняло проверку впустую.
print('%d\t%s' % (len(text), text))
PY
}

# The phrases a Russian-speaking user actually types. Losing one is invisible everywhere
# except in whether the skill fires, so they are listed here and nowhere else.
TRIGGERS='вычитай
проверь текст
поправь
отредактируй
причеши
ru-text'

if [ "${1:-}" = "--print" ]; then
  echo "— version points —"; version_points
  d=$(description)
  printf -- '— description (%s chars, budget %s) —\n%s\n' "$(printf '%s' "$d" | cut -f1)" "$BUDGET" "$(printf '%s' "$d" | cut -f2-)"
  exit 0
fi

printf 'check-version: one version, one budget, one set of triggers\n'

# ── 1. Every version point agrees ────────────────────────────────────────────────────
points=$(version_points)
distinct=$(printf '%s\n' "$points" | cut -f2 | sort -u | wc -l | tr -d ' ')
count=$(printf '%s\n' "$points" | grep -c . | tr -d ' ')
if printf '%s\n' "$points" | grep -q 'MISSING-OR-DUPLICATE'; then
  bad "a version line is missing or duplicated:"
  printf '%s\n' "$points" | grep 'MISSING-OR-DUPLICATE' | sed 's/^/        /'
elif [ "$distinct" -eq 1 ]; then
  ok "all $count version points agree on $(printf '%s\n' "$points" | head -1 | cut -f2)"
else
  bad "$count version points disagree:"
  printf '%s\n' "$points" | sed 's/^/        /'
fi

# ── 2. The description fits our budget ───────────────────────────────────────────────
raw=$(description)
len=$(printf '%s' "$raw" | cut -f1)
desc=$(printf '%s' "$raw" | cut -f2-)
if [ "$len" -le "$BUDGET" ]; then
  ok "skill description is $len characters (our budget: $BUDGET)"
else
  bad "skill description is $len characters, over our budget of $BUDGET"
fi

# ── 3. Every trigger phrase is present, and the Russian ones come early ──────────────
head_chunk=$(printf '%s' "$desc" | cut -c1-$((FIRST_N * 3)))   # cut counts bytes; UTF-8 RU is 2
missing=''
late=''
printf '%s\n' "$TRIGGERS" | while read -r t; do
  [ -n "$t" ] || continue
  case "$desc" in
    *"$t"*) ;;
    *) printf 'MISSING\t%s\n' "$t" ;;
  esac
done > /tmp/.check-version-triggers.$$
missing=$(cat /tmp/.check-version-triggers.$$); rm -f /tmp/.check-version-triggers.$$
if [ -n "$missing" ]; then
  bad "the description has lost a trigger phrase — on the Claude apps and ChatGPT that is the whole trigger:"
  printf '%s\n' "$missing" | sed 's/^/        /'
else
  ok "all trigger phrases present"
fi

# Position matters only for the Russian ones: a host that truncates shows the head.
early=$(python3 - "$FIRST_N" <<PY
import sys
desc = """$desc"""
n = int(sys.argv[1])
ru = ['вычитай', 'проверь текст', 'поправь', 'отредактируй', 'причеши']
late = [t for t in ru if t in desc and desc.index(t) >= n]
print('\n'.join(late))
PY
)
if [ -n "$early" ]; then
  bad "Russian trigger phrases sit past character $FIRST_N, where a truncating host will not show them:"
  printf '%s\n' "$early" | sed 's/^/        /'
elif [ -n "$missing" ]; then
  # Not «ok»: with the phrases absent there is nothing for a position test to be true about,
  # and a green line here would read as though the placement had been verified.
  printf '  --    position of the Russian phrases not checked: they are missing\n'
else
  ok "Russian trigger phrases are inside the first $FIRST_N characters"
fi

# ── 4. Both READMEs state the true size of SKILL.md ────────────────────────────────────
# «Техническое качество» quotes the word and line count as evidence that the always-on half
# of the skill is small. Nobody re-measured it: the line said 587 words for three releases
# while the file held 583. A claim offered as proof has to be measured, or it is the exact
# opposite of what it claims to be.
#
# The numbers are compared, not the sentence. Russian inflects the noun with the numeral --
# 583 slova, 587 slov, 581 slovo -- so a literal-string check would fail on a correct line
# whenever the count crossed a declension boundary, and the fix would be to edit the checker.
# Reading the numbers off the line is form-agnostic and survives translation; the trailing
# budget figures are ignored because only the first two are the claim.
#
# Exactly ONE line per README may state the size, which is the rule section 1 above already
# lives by: a second copy is where the first goes stale. A review proved the cost of not
# applying it here -- with two "SKILL.md:" lines the checker read the first, vouched for it,
# and passed while both files were wrong.
#
# Grouped thousands are glued before the digits are read. re.findall for digit runs never
# matches a separator, so replacing one cannot change the result: an earlier version replaced
# NBSP and comma and was a provable no-op, which read "1 083 words" as the pair (1, 083) and
# failed a correct README with a nonsense diagnostic.
skill_size_ok=$(python3 - "$SKILL" README.md README.en.md <<'PY'
import io, re, sys

path, readmes = sys.argv[1], sys.argv[2:]
text = io.open(path, encoding='utf-8').read()
# Defined to match `LC_ALL=C wc -w` and `wc -l`, which is what a maintainer checking this by
# hand will run -- and this script exports LC_ALL=C. NOT text.split(): python treats U+00A0 as
# whitespace and byte-wise wc does not, so on a file carrying the non-breaking spaces R16/R44
# require the two would disagree, and the README would be "corrected" into a false failure.
words = len(re.findall(r'[^ \t\n\r\f\v]+', text))
lines = text.count('\n')

bad = []
for r in readmes:
    try:
        content = io.open(r, encoding='utf-8').read()
    except OSError as e:
        bad.append('%s: unreadable (%s)' % (r, e))
        continue
    hit = [ln for ln in content.split('\n') if 'SKILL.md:' in ln]
    # Nought is allowed and one is allowed; two is not. The size claim is optional — the
    # rewritten Russian README drops it, because a manifest's word count answers «did the
    # author follow the spec», which is not a question any reader has. What this section
    # forbids is stating it WRONGLY, and a file that says nothing states nothing wrongly.
    # Two lines is still a defect: that is where the first goes stale unnoticed.
    if len(hit) == 0:
        continue
    if len(hit) > 1:
        bad.append('%s: %d lines state the size of SKILL.md, want at most 1' % (r, len(hit)))
        continue
    glued = re.sub(r'(?<=\d)[ \t  ,](?=\d\d\d(?!\d))', '', hit[0])
    nums = re.findall(r'\d+', glued)
    if len(nums) < 2:
        bad.append('%s: %r carries no pair of numbers to check' % (r, hit[0].strip()))
        continue
    got_w, got_l = int(nums[0]), int(nums[1])
    if (got_w, got_l) != (words, lines):
        bad.append('%s: says %d words / %d lines, file has %d / %d'
                   % (r, got_w, got_l, words, lines))

# US (unit separator), not "; ": a README line quoted back into a diagnostic can contain a
# semicolon, and splitting on one tore a message in half mid-quote.
print('%d\t%d\t%s' % (words, lines, '\x1f'.join(bad)))
PY
)
sz_words=$(printf '%s' "$skill_size_ok" | cut -f1)
sz_lines=$(printf '%s' "$skill_size_ok" | cut -f2)
sz_bad=$(printf '%s' "$skill_size_ok" | cut -f3-)
# An empty measurement must not read as agreement. The heredoc always reaches its print, so
# this needs a broken interpreter -- but the ok branch below is keyed on "no complaints", and
# "no output at all" is indistinguishable from it without this line.
case "$sz_words$sz_lines" in
  ''|*[!0-9]*) sz_bad="the SKILL.md measurement produced nothing -- is python3 usable?" ;;
esac
if [ -z "$sz_bad" ]; then
  ok "both READMEs state the size of SKILL.md correctly ($sz_words words, $sz_lines lines)"
else
  bad "a README states the size of SKILL.md wrongly:"
  printf '%s\n' "$sz_bad" | tr '\037' '\n' | sed 's/^ */        /'
fi

[ "$fail" -eq 0 ] && { echo "check-version: PASS"; exit 0; }
echo "check-version: FAIL — $fail check(s)"
exit 1
