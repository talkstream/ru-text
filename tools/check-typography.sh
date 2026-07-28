#!/bin/sh
# check-typography.sh — this product's own Russian prose must obey this product's own rules.
#
#     tools/check-typography.sh            # verify
#     tools/check-typography.sh --print    # what is checked, and where
#
# ── why ──────────────────────────────────────────────────────────────────────────────
#
# The README claims, in its own words, that «каждое тире, кавычка и пробел в этом документе
# соответствуют правилам самого плагина». Nothing enforced that. It was checked by asking a
# model, by hand, when someone remembered — and it fell out of step twice in one afternoon:
# a literal `~` reached the file from a placeholder for a non-breaking space, and a missing
# NBSP before an em dash shipped in prose written to explain non-breaking spaces.
#
# A model reads the whole corpus and judges meaning. This checks the mechanical subset that
# needs no judgement at all, on every run, for free. It does not replace the model; it stops
# the class of defect that should never have needed one.
#
# ── scope, and why it is an explicit list ────────────────────────────────────────────
#
# ONLY continuous Russian prose written in the project's own voice. The list is literal and
# short, because the alternative was measured and rejected: run the same patterns over the
# corpus files and `notion/ru-text-notion-skill.md` and they report 53 «violations» that are
# all correct content — the wrong-hand column of a «плохо → хорошо» table, and stop-word
# entries like `в настоящее время` that are dictionary keys rather than sentences. In a file
# that teaches typography by showing it broken, breakage is the point.
#
# Deliberately excluded, each for a stated reason:
#   skills/ru-text/references/*  — rule examples; a violation there is the specimen
#   notion/ru-text-notion-skill.md — same, condensed
#   tools/golden/*               — fixtures; several are broken on purpose
#   CHANGELOG.md                 — English prose quoting Russian fragments; an English em
#                                  dash takes an ordinary space, so the rule does not apply
#   README.en.md, INSTALL.en.md  — English; guillemets and NBSP are not its conventions
#
# ── what is checked ──────────────────────────────────────────────────────────────────
#
# R16/R44  the space before an em dash is non-breaking, so the dash cannot open a line
# R30      a single-letter preposition does not end a line
# R1/R2    guillemets, not straight quotes, around Russian text
# R-ellipsis a single … character, not three periods
# plus: a stray literal `~`, which is not a rule but the exact defect that shipped twice —
#       a placeholder for U+00A0 that survived into the file.
#
# Inline code and URLs are stripped before matching: `~/.agents/skills` is a home directory,
# not a mangled space, and a hyphen inside a command is not a dash.

set -eu
export LC_ALL=C

cd "$(dirname "$0")/.."

# Every file whose prose speaks as the project. Adding one is a deliberate act; see the scope
# note above before you do, because the wrong file here makes this checker cry wolf.
FILES='README.md
INSTALL.md'

fail=0
ok()  { printf '  ok    %s\n' "$1"; }
bad() { fail=$((fail + 1)); printf '  FAIL  %s\n' "$1"; }

if [ "${1:-}" = "--print" ]; then
  printf 'files checked, and why only these — see the header:\n'
  printf '%s\n' "$FILES" | sed 's/^/  /'
  exit 0
fi

printf 'check-typography: the product obeys its own typography\n'

report=$(python3 - $FILES <<'PY'
import io, re, sys

NB = '\u00a0'
# BOTH cases. The first version listed lowercase only, and a check that never tests «В» or
# «У» at the start of a sentence is not strict — it is blind exactly where a sentence most
# often begins. It reported INSTALL.md clean while the file held six of them.
PREP = 'вкосуиаяВКОСУИАЯ'
out = []

for path in sys.argv[1:]:
    try:
        lines = io.open(path, encoding='utf-8').read().split('\n')
    except OSError as e:
        out.append('%s\tMISSING\t%s' % (path, e))
        continue

    fence = False
    for n, raw in enumerate(lines, 1):
        if raw.lstrip().startswith('```'):
            fence = not fence
            continue
        if fence:
            continue
        # Inline code and link targets carry paths, flags and commands. `~/.agents/skills` is
        # a tilde that belongs; a hyphen in `-g` is not a dash. Blank them, keeping offsets so
        # the reported column still points at the real character.
        s = re.sub(r'`[^`]*`', lambda m: ' ' * len(m.group(0)), raw)
        s = re.sub(r'\]\([^)]*\)', lambda m: ' ' * len(m.group(0)), s)
        s = re.sub(r'https?://\S+', lambda m: ' ' * len(m.group(0)), s)

        for m in re.finditer('—', s):
            if m.start() > 0 and s[m.start() - 1] == ' ':
                out.append('%s\t%d\tR16/R44\tordinary space before an em dash\t%s'
                           % (path, n, s[max(0, m.start() - 40):m.start() + 20].strip()))

        # What may FOLLOW the space is deliberately broad. The first version required a
        # Cyrillic letter or a digit next, so «в [README]», «и **`.agents/skills/`**» and
        # «и /ru-score» all escaped — a preposition is no less stranded for being followed
        # by a bracket, an asterisk or a slash. Excluded: another space (already a break)
        # and end of line (nothing left to bind to).
        for m in re.finditer(r'(?<![^\s(«„])([' + PREP + r']) (?=[^\s])', s):
            out.append('%s\t%d\tR30\tordinary space after the single-letter «%s»\t%s'
                       % (path, n, m.group(1), s[max(0, m.start() - 30):m.start() + 30].strip()))

        for m in re.finditer(r'"[А-Яа-яЁё]|[А-Яа-яЁё]"', s):
            out.append('%s\t%d\tR1/R2\tstraight quote around Russian text\t%s'
                       % (path, n, s[max(0, m.start() - 30):m.start() + 30].strip()))

        for m in re.finditer(r'\.\.\.', s):
            out.append('%s\t%d\tellipsis\tthree periods instead of …\t%s'
                       % (path, n, s[max(0, m.start() - 30):m.start() + 20].strip()))

        # Not a corpus rule. The defect that shipped twice: a placeholder for U+00A0 that
        # survived a tool round-trip. A tilde that is a home directory is followed by a slash.
        for m in re.finditer(r'~(?!/)', s):
            out.append('%s\t%d\tstray-tilde\ta literal ~ where a non-breaking space belongs\t%s'
                       % (path, n, s[max(0, m.start() - 40):m.start() + 20].strip()))

print('\n'.join(out))
PY
)

if [ -z "$report" ]; then
  n=$(printf '%s\n' "$FILES" | grep -c .)
  ok "$n file(s) of Russian prose obey R16/R44, R30, R1/R2 and the ellipsis rule"
else
  count=$(printf '%s\n' "$report" | grep -c .)
  bad "$count typographic defect(s) in the project's own prose:"
  printf '%s\n' "$report" | awk -F'\t' '{ printf "        %s:%s  %s — %s\n        %s%s\n", $1, $2, $3, $4, "    …", $5 }'
fi

[ "$fail" -eq 0 ] && { echo "check-typography: PASS"; exit 0; }
echo "check-typography: FAIL — $fail check(s)"
exit 1
