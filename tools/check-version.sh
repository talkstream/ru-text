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
PROSE = [
    ('.claude/CLAUDE.md', r'\*\*Version:\*\*\s*([0-9]+\.[0-9]+\.[0-9]+)'),
    # The space before the em dash is a NON-BREAKING one — this repository obeys its own
    # R16/R44 — so the pattern has to accept either, or it reports the line as missing.
    ('README.md',         r'Свежая версия[\s\u00a0]*—[\s\u00a0]*\*\*v([0-9]+\.[0-9]+\.[0-9]+)\*\*'),
    ('README.en.md',      r'Latest version[\s\u00a0]*—[\s\u00a0]*\*\*v([0-9]+\.[0-9]+\.[0-9]+)\*\*'),
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

[ "$fail" -eq 0 ] && { echo "check-version: PASS"; exit 0; }
echo "check-version: FAIL — $fail check(s)"
exit 1
