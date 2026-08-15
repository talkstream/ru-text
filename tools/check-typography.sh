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
#   tools/golden/[0-9]*         — fixtures; several are broken on purpose
#     ⚠ The exclusion used to read `tools/golden/*` and swallowed the set's README with
#     it — ordinary prose in the project's own voice, guarded by nothing. Found
#     16.08.2026 by a /ru-text:ru-check run, and it is the third time this file makes
#     the same mistake: `notion/README.md` was omitted the same way and held fifteen
#     violations of the rules it documents. A glob that covers a directory covers the
#     prose in it too — name the fixtures, not their parent.
#   CHANGELOG.md                 — English prose quoting Russian fragments; an English em
#                                  dash takes an ordinary space, so the rule does not apply
#   README.en.md, INSTALL.en.md  — English; guillemets and NBSP are not its conventions
#
# `notion/README.md` was not on either list, and that was an omission rather than a decision:
# the exclusion note above names `notion/ru-text-notion-skill.md`, the template full of
# deliberate breakage, and the setup guide beside it was never considered. It is ordinary
# prose in the project's voice and it held fifteen violations of the rules it documents. It
# is BILINGUAL — an English half, then a Russian one — so lines carrying no Cyrillic are
# skipped for it by name: «2,000+ linguistic atoms» is correct English and a comma between
# digit groups is only a defect in Russian. The skip is per-file and stated, not a global
# rule, because on a monolingual Russian page a line without Cyrillic can still be a digit
# group that R32/R53 governs. ONE check survives the skip: the stray literal `~`, which is
# not a rule of Russian but a placeholder for U+00A0 that outlived a tool round-trip, and is
# just as wrong in English.
#
# ── arms that are true today but held by nothing ─────────────────────────────────────
#
# Written down rather than rediscovered. Each was mutated and survived the suite, and each
# survived because the tree happens not to contain the input that would separate it — not
# because the arm is unnecessary. A count, not an opinion, and the count is what expires:
#
#   `Ёё` in CYRILLIC          — 0 lines where ё or Ё is the only Cyrillic
#   `english_half` on `raw`   — 0 lines where blanking code would flip the verdict
#   `.strip()` on a claim     — 0 of 9 claim templates carry edge whitespace
#   `flat(phrase)` in says()  — 0 of 6 Notion phrases are altered by it
#   claim_present's OSError   — unreachable: verify_claims tests `[ ! -f ]` first
#   filter(None, BILINGUAL)   — 0 empty entries in the list today
#   flat() applied to `want`  — 0 of 9 claim templates are altered by it
#
# This list is maintained BY MUTATION, not by proof: it holds what someone has actually
# mutated and watched survive. Five rows were written first and a sixth and seventh were
# found the same way an hour later. Read it as «these are known», never as «these are all».
#
# ── what is checked ──────────────────────────────────────────────────────────────────
#
# R16/R44  the space before an em dash is non-breaking, so the dash cannot open a line
# R32/R53  digit groups take a non-breaking space, never a comma, a period or a plain space
# R31      initials bind to the surname they belong to
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
INSTALL.md
notion/README.md
tools/golden/README.md'

# Files whose English half must not be measured by Russian rules. One name, one reason.
BILINGUAL='notion/README.md'

fail=0
ok()  { printf '  ok    %s\n' "$1"; }
bad() { fail=$((fail + 1)); printf '  FAIL  %s\n' "$1"; }

if [ "${1:-}" = "--print" ]; then
  printf 'files checked, and why only these — see the header:\n'
  printf '%s\n' "$FILES" | sed 's/^/  /'
  printf 'bilingual — lines with no Cyrillic are not measured by Russian rules:\n'
  printf '%s\n' "$BILINGUAL" | sed 's/^/  /'
  exit 0
fi

printf 'check-typography: the product obeys its own typography\n'

report=$(BILINGUAL="$BILINGUAL" python3 - $FILES <<'PY'
import io, os, re, sys

NB = '\u00a0'
BILINGUAL = set(filter(None, os.environ.get('BILINGUAL', '').split('\n')))
CYRILLIC = re.compile(r'[А-Яа-яЁё]')
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
        # A blockquote holding the install prompt is a string the reader COPIES and hands to
        # an agent, not prose we typeset. Russian typography applies to what we write; it does
        # not apply to a literal someone will paste. The rules were applied to it once, by a
        # normaliser that could not tell the difference, and put two non-breaking spaces inside
        # a command — so the string in the README stopped being byte-identical to the one
        # tools/probe-install.sh feeds a fresh agent, and the probe began testing a string we
        # do not publish. Skipping the line here is what lets those two stay identical.
        if raw.lstrip().startswith('> Установи навык'):
            continue
        # On a bilingual page a line with no Cyrillic is the English half, and RUSSIAN rules
        # do not govern it. Named files only — see the header. The stray tilde is exempt from
        # the exemption: it is not a Russian rule but a placeholder for U+00A0 that survived a
        # tool round-trip, and it is just as wrong on an English line — on this very file,
        # which a normaliser has just touched.
        english_half = path in BILINGUAL and not CYRILLIC.search(raw)

        # Inline code and link targets carry paths, flags and commands. `~/.agents/skills` is
        # a tilde that belongs; a hyphen in `-g` is not a dash. Blank them, keeping offsets so
        # the reported column still points at the real character.
        s = re.sub(r'`[^`]*`', lambda m: ' ' * len(m.group(0)), raw)
        s = re.sub(r'\]\([^)]*\)', lambda m: ' ' * len(m.group(0)), s)
        s = re.sub(r'https?://\S+', lambda m: ' ' * len(m.group(0)), s)

        # Not a corpus rule, and therefore NOT waived on an English line: a placeholder for
        # U+00A0 that survived a tool round-trip is wrong in either language, and this is the
        # file a normaliser has just touched. Checked before the bilingual skip, deliberately.
        for m in re.finditer(r'~(?!/)', s):
            out.append('%s\t%d\tstray-tilde\ta literal ~ where a non-breaking space belongs\t%s'
                       % (path, n, s[max(0, m.start() - 40):m.start() + 20].strip()))

        # Everything below is a rule of RUSSIAN typography and does not govern an English line.
        if english_half:
            continue

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

        # R31 — initials bind to the surname, so «А. С.» never ends a line away from
        # «Пушкин». Found by a judge reading the sources list, after three gates had passed
        # over it: the fourth rule this checker did not name. One initial is enough to match,
        # since «Д. Розенталь» is as breakable as «Д. Э. Розенталь».
        for m in re.finditer(r'\b[А-ЯЁ]\. (?=[А-ЯЁ])', s):
            out.append('%s\t%d\tR31\tordinary space after an initial\t%s'
                       % (path, n, s[max(0, m.start() - 30):m.start() + 30].strip()))

        for m in re.finditer(r'"[А-Яа-яЁё]|[А-Яа-яЁё]"', s):
            out.append('%s\t%d\tR1/R2\tstraight quote around Russian text\t%s'
                       % (path, n, s[max(0, m.start() - 30):m.start() + 30].strip()))

        # R32/R53 — digit groups are separated by a non-breaking space, thin or ordinary, and
        # never by a comma or a period. An ordinary space here is the defect that walked
        # straight through the first version of this checker: «более 2 000 атомов» read as
        # correct because nothing looked at digit grouping at all. R35 permits a bare
        # four-digit number, so a group is only sought where one already exists.
        for m in re.finditer(r'(?<![\d.,])(\d{1,3})([ .,])(\d{3})(?![\d])', s):
            sep = m.group(2)
            what = 'a comma' if sep == ',' else ('a period' if sep == '.' else 'an ordinary space')
            out.append('%s\t%d\tR32/R53\t%s between digit groups, not a non-breaking space\t%s'
                       % (path, n, what, s[max(0, m.start() - 30):m.start() + 30].strip()))

        for m in re.finditer(r'\.\.\.', s):
            out.append('%s\t%d\tellipsis\tthree periods instead of …\t%s'
                       % (path, n, s[max(0, m.start() - 30):m.start() + 20].strip()))


print('\n'.join(out))
PY
)

if [ -z "$report" ]; then
  n=$(printf '%s\n' "$FILES" | grep -c .)
  ok "$n file(s) of Russian prose obey R16/R44, R30, R31, R32/R53, R1/R2 and the ellipsis rule"
else
  count=$(printf '%s\n' "$report" | grep -c .)
  bad "$count typographic defect(s) in the project's own prose:"
  printf '%s\n' "$report" | awk -F'\t' '{ printf "        %s:%s  %s — %s\n        %s%s\n", $1, $2, $3, $4, "    …", $5 }'
fi

[ "$fail" -eq 0 ] && { echo "check-typography: PASS"; exit 0; }
echo "check-typography: FAIL — $fail check(s)"
exit 1
