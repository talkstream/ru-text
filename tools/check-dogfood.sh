#!/bin/sh
# check-dogfood.sh — the numbers this product states about itself must be true.
#
#     tools/check-dogfood.sh            # verify
#     tools/check-dogfood.sh --print    # what it measured, and every place that claims it
#
# check-version.sh proves the version agrees with itself. This proves the claims agree with
# the corpus: the size of the stop-word catalogue, and the number of its categories. Both
# are measured from `info-style.md` by the same parser check-frozen.sh uses — itself a port
# of the paid MCP's — and then compared with every file that states them.
#
# ── why it is built this way ─────────────────────────────────────────────────────────
#
# The first version scanned for claims with patterns like «(\d+) записей» and immediately
# reported twenty-two false ones: `anti-patterns.md` counts its own sections in the same
# words. Guessing which number in a sentence is a claim about the catalogue is not a
# solvable problem in a shell script, and a checker that cries wolf is one people disable.
#
# So the list of consumers is EXPLICIT, and a second check guarantees the list is complete:
# the current value must not appear anywhere outside it. Move the catalogue to 93 and the
# stale «92» left in some file is still a «92» — the guard finds it, names the file, and
# the list gets a new row. A fixed list alone would have the failure mode that put four
# consumers out of date last time; a fixed list WITH a completeness guard does not.
#
# Deliberately unread: CHANGELOG.md, which records what the numbers WERE and must keep
# saying 97 where 97 was once wrong; and tools/, whose comments describe past parser bugs
# by their numbers. A checker that fails on an accurate history teaches people to skip it.

set -eu
export LC_ALL=C

cd "$(dirname "$0")/.."

INFO=skills/ru-text/references/info-style.md

fail=0
ok()  { printf '  ok    %s\n' "$1"; }
bad() { fail=$((fail + 1)); printf '  FAIL  %s\n' "$1"; }

catalog_size() {
  awk '
    /^## B\. Каталог стоп-слов/ { inb = 1; next }
    !inb { next }
    /^## / { exit }
    /^### / { next }
    /^слово\|замена$/ { next }
    /^[^|#]+\|.+$/ { print }
  ' "$INFO" | wc -l | tr -d ' '
}

category_count() {
  awk '
    /^## B\. Каталог стоп-слов/ { inb = 1; next }
    !inb { next }
    /^## / { exit }
    /^### / { n++ }
    END { print n + 0 }
  ' "$INFO"
}

# Every place that states the catalogue size, and the phrase it states it in. A file is
# listed once per claim. Adding a claim to the product means adding a row here — and if you
# forget, the completeness guard below says so by name.
CATALOG_CLAIMS='skills/ru-text/SKILL.md|Full stop-word catalog (%s entries)
README.md|каталог из %s стоп-слов
README.en.md|the catalogue of %s stop-words
notion/README.md|- %s stop-words across
notion/README.md|- %s стоп-слова в
skills/ru-text/references/editorial-grammar.md|%s in §B
tools/frozen.sha256|catalog_entries=%s'

CATEGORY_CLAIMS='notion/README.md|across %s categories
notion/README.md|в %s категориях'

# Words the product says about its own corpus that must exist IN that corpus. Numbers are
# checked above; this checks names, and it exists because one name got it wrong twice.
#
# «онбординг» was written into the README's description of ux-writing.md, corrected on
# 28.07 when a check found the file has no such section (its thirteen run A to M, and I is
# «Диалоги подтверждения»), and then written back in during a rewrite two days later. A
# defect that returns is a defect nobody is guarding.
#
# Format: claiming file <TAB> phrase <TAB> file the phrase claims to describe.
NAME_CLAIMS='README.md	онбординг	skills/ru-text/references/ux-writing.md
README.en.md	onboarding	skills/ru-text/references/ux-writing.md'

verify_names() {
  bad=''
  while IFS='	' read -r claimant phrase target; do
    [ -n "$claimant" ] || continue
    [ -f "$claimant" ] || continue
    grep -qiF -- "$phrase" "$claimant" || continue          # not claimed: nothing to check
    grep -qiF -- "$phrase" "$target" && continue            # claimed and present: fine
    bad="$bad${bad:+
}$claimant says «$phrase» about $target, which does not contain it"
  done <<EOF
$NAME_CLAIMS
EOF
  if [ -z "$bad" ]; then
    ok "no file is credited with a section it does not have"
  else
    bad "a file is credited with a section it does not have:"
    printf '%s\n' "$bad" | sed 's/^/        /'
  fi
}

claim_present() { # $1=phrase  $2=file — true when the file states the phrase
  WANT="$1" python3 - "$2" <<'PYC'
import io, os, re, sys
# `[^\S\n]` — every kind of space EXCEPT the newline. Collapsing newlines too was the
# defect: `grep -qF` was line-scoped, and dropping that scope let a deleted claim be
# satisfied by two unrelated paragraphs standing next to each other. The tell matcher
# 120 lines below treats a blank line as a hard boundary for exactly this reason; these
# two must not disagree about what a claim is.
# ONE arm, not two. Excluding the newline from the class is what keeps the match inside a
# line; iterating over lines as well was a second, redundant guard, and a redundant guard is
# a mutation that survives and reads like coverage.
flat = lambda t: re.sub(r'[^\S\n]+', ' ', t)
want = flat(os.environ['WANT']).strip()
try:
    body = io.open(sys.argv[1], encoding='utf-8').read()
except OSError:
    sys.exit(1)
sys.exit(0 if want in flat(body) else 1)
PYC
}

verify_claims() { # $1=label  $2=value  $3=claim list
  missing=''
  n=0
  printf '%s\n' "$3" | while IFS='|' read -r f tmpl; do
    [ -n "$f" ] || continue
    # sed, not printf: a template beginning with «- » is parsed as an option by the
    # shell builtin, and two of the claims below are markdown list items.
    want=$(printf '%s' "$tmpl" | sed "s/%s/$2/")
    if [ ! -f "$f" ]; then
      printf 'MISSING-FILE\t%s\n' "$f"
    # Spaces compared as spaces, whatever their codepoint. `notion/README.md` states «в 8
    # категориях», and the typography gate binds that single-letter preposition with U+00A0
    # — so a byte-exact search for the claim stopped finding a sentence that had just been
    # made MORE correct. Two gates on one line, disagreeing about a space: the claim is about
    # the words, so the words are what it compares.
    elif claim_present "$want" "$f"; then
      printf 'OK\t%s\n' "$f"
    else
      printf 'STALE\t%s\t%s\n' "$f" "$want"
    fi
  done > "$TMP/claims.$$"
  n=$(grep -c '^OK' "$TMP/claims.$$" || true)
  wrong=$(grep -v '^OK' "$TMP/claims.$$" || true)
  if [ -z "$wrong" ]; then
    ok "$1: $n place(s) state $2, and the corpus agrees"
  else
    bad "$1: the corpus says $2, and these do not:"
    printf '%s\n' "$wrong" | sed 's/^/        /'
  fi
  rm -f "$TMP/claims.$$"
}

# The completeness guard. Any occurrence of the current value outside the listed places is
# either a claim nobody registered or a coincidence — and the checker cannot tell them
# apart, which is the point: it names the line and a person decides once.
guard_complete() { # $1=label  $2=value  $3=claim list
  listed=$(printf '%s\n' "$3" | cut -d'|' -f1 | sort -u)
  hits=$(git ls-files -z \
    | tr '\0' '\n' \
    | grep -vE '^(CHANGELOG\.md|tools/|docs/|\.github/)' \
    | while IFS= read -r f; do
        # NOT a `case` with alternation: bash 3.2 — which is /bin/sh on macOS — fails to
        # parse one inside a command substitution, and `sh -n` does not catch it. The
        # error surfaces only when the line runs. Measured 28.07.2026.
        printf '%s' "$f" | grep -qE '\.(md|json|ya?ml|sha256)$' || continue
        printf '%s\n' "$listed" | grep -qxF "$f" && continue
        [ -f "$f" ] || continue
        # A letter before the digits means an identifier, not a count: typography.md
        # carries rule R92, and a guard that reads it as a stale claim about the
        # catalogue is the crying-wolf failure this design exists to avoid.
        grep -nE "(^|[^0-9A-Za-zА-Яа-яЁё])$2([^0-9]|$)" "$f" 2>/dev/null | sed "s|^|$f:|"
      done)
  if [ -z "$hits" ]; then
    ok "$1: no unregistered occurrence of $2 outside the listed places"
  else
    bad "$1: $2 appears where no claim is registered — add a row or rephrase the line:"
    printf '%s\n' "$hits" | sed 's/^/        /'
  fi
}

# The two install guides, and nothing compared them until now. `62a164f` corrected «re-running
# the same command updates it» — a claim that is false, and false in the direction that leaves
# people on an old corpus — in `INSTALL.md` alone. `INSTALL.en.md` carried the disproved
# instruction for ELEVEN more days, while the English README had already begun telling readers
# the file was fixed.
#
# Prose translates and must differ; COMMANDS do not. So the invariant is the set of commands
# each guide quotes, compared as sets: a command present in one and absent from the other is a
# correction applied to half the audience. Trailing comments are stripped before comparing —
# they are prose and are supposed to differ.
guides_agree() {
  python3 - <<'PYG'
import io, re, sys

FILES = ('INSTALL.md', 'INSTALL.en.md')

def commands(path):
    try:
        lines = io.open(path, encoding='utf-8').read().split('\n')
    except OSError:
        return None
    out, fence = [], False
    for line in lines:
        if line.lstrip().startswith('```'):
            fence = not fence
            continue
        if fence:
            stripped = re.sub(r'\s*#.*$', '', line).strip()
            if stripped:
                out.append(stripped)
    return out

sets = {}
for path in FILES:
    got = commands(path)
    if got is None:
        sys.stdout.write('  FAIL  %s is missing, and its pair quotes commands it must match\n' % path)
        sys.exit(1)
    sets[path] = set(got)

only_ru = sorted(sets['INSTALL.md'] - sets['INSTALL.en.md'])
only_en = sorted(sets['INSTALL.en.md'] - sets['INSTALL.md'])
if only_ru or only_en:
    sys.stdout.write('  FAIL  the install guides quote different commands — a correction '
                     'applied to one half:\n')
    for c in only_ru:
        sys.stdout.write('        only in INSTALL.md:    %s\n' % c[:110])
    for c in only_en:
        sys.stdout.write('        only in INSTALL.en.md: %s\n' % c[:110])
    sys.exit(1)

sys.stdout.write('  ok    both install guides quote the same %d command(s)\n'
                 % len(sets['INSTALL.md']))
PYG
}

# The Notion template states its own size four times, in two languages, and none of it was
# measured. Three of the four were accurate; the fourth was not, and it overstated in the
# direction that flatters — «9 признаков ИИ-текста в 4 категориях» over a section holding
# FOUR tells with nine example rows. A reader counting tells would have found less than half
# of what the line promised. The unit is stated here rather than inferred: typography and
# anti-patterns are counted as table rows, because there each row IS the rule; tells are
# counted as sections, because there a row is an EXAMPLE of a tell, not a tell.
#
# No completeness sweep, and the reason is not «it seemed like enough»: these numbers
# describe one artefact and are quoted in one file, its own README, twice — once per
# language. The «<n> признаков» form, the one that actually went wrong, is swept by the
# tell guard above across the whole tree.
notion_report() {
  python3 - <<'PYN'
import io, re, sys

TEMPLATE = 'notion/ru-text-notion-skill.md'
README = 'notion/README.md'

def die(msg, detail=()):
    sys.stdout.write('  FAIL  %s\n' % msg)
    for line in detail:
        sys.stdout.write('        %s\n' % line)
    sys.exit(1)

try:
    lines = io.open(TEMPLATE, encoding='utf-8').read().split('\n')
except OSError:
    die('%s is missing, and notion/README.md states its size' % TEMPLATE)

def section(head):
    for i, line in enumerate(lines):
        if line.startswith(head):
            end = next((j for j in range(i + 1, len(lines)) if lines[j].startswith('## ')),
                       len(lines))
            return lines[i + 1:end]
    die('%s no longer has a section «%s»' % (TEMPLATE, head))

def rows(body):
    """Table data rows: a header line followed by a separator, then rows until the table ends."""
    n, i = 0, 0
    while i < len(body):
        if re.match(r'^\|', body[i]) and i + 1 < len(body) and re.match(r'^\|[\s:|-]+\|$',
                                                                       body[i + 1]):
            i += 2
            while i < len(body) and re.match(r'^\|', body[i]):
                n += 1
                i += 1
        else:
            i += 1
    return n

typo = rows(section('## Typography Rules'))
anti = rows(section('## Anti-Patterns'))
tells_body = section('## AI-Text Tells')
tell_cats = len([l for l in tells_body if l.startswith('### ')])
tell_rows = rows(tells_body)

CLAIMS = [
    '- %d typography rules' % typo,
    '- %d правил типографики' % typo,
    '- %d anti-patterns' % anti,
    '- %d антипаттернов' % anti,
    'AI-text tells (neuroslop): %d categories, %d examples' % (tell_cats, tell_rows),
    'Признаки ИИ-текста (нейрослоп): %d категории, %d примеров' % (tell_cats, tell_rows),
]

try:
    body = io.open(README, encoding='utf-8').read()
except OSError:
    die('%s is missing, and it is the only place the template states its size' % README)

def says(text, phrase):
    # Spaces compared as spaces here too. This reader was left byte-exact when its sibling
    # stopped being so, and one non-breaking space in the Notion README turned it red — a
    # second reader of the same file, disagreeing with the first about what a space is.
    flat = lambda t: re.sub(r'[^\S\n]+', ' ', t)
    pat = re.compile(r'(?<![0-9A-Za-zА-Яа-яЁё])%s(?![0-9A-Za-zА-Яа-яЁё])' % re.escape(flat(phrase)),
                     re.UNICODE)
    return pat.search(flat(text)) is not None

stale = ['%s does not say «%s»' % (README, c) for c in CLAIMS if not says(body, c)]
# The template describes its own size in a heading, and that heading is a consumer like any
# other: «## Anti-Patterns: Top 30» over thirty-one rows is the same defect one level in.
selfhead = '## Anti-Patterns: Top %d' % anti
if not says('\n'.join(lines), selfhead):
    stale.append('%s does not head its section «%s»' % (TEMPLATE, selfhead))
if stale:
    die('the Notion template holds %d typography rows, %d anti-pattern rows and %d tells '
        'in %d examples, and these do not say so:' % (typo, anti, tell_cats, tell_rows),
        stale)

sys.stdout.write('  ok    the Notion template states its true size (%d / %d / %d tells in %d)\n'
                 % (typo, anti, tell_cats, tell_rows))
PYN
}

tells_report() { # $1 = verify | print
  python3 - "$1" <<'PYT'
import bisect, io, re, subprocess, sys

ADDENDA = 'skills/ru-text/references/addenda.md'
EXCLUDES = 'Not a neuroslop tell'
MODE = sys.argv[1]

RU = ['ноль', 'один', 'два', 'три', 'четыре', 'пять', 'шесть', 'семь', 'восемь', 'девять',
      'десять', 'одиннадцать', 'двенадцать', 'тринадцать', 'четырнадцать', 'пятнадцать',
      'шестнадцать', 'семнадцать', 'восемнадцать', 'девятнадцать', 'двадцать']
EN = ['zero', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine',
      'ten', 'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen', 'sixteen',
      'seventeen', 'eighteen', 'nineteen', 'twenty']

# Six claims, five of them spelled out. A checker that only knew the numeral would have to
# ask the prose to change, and the prose is right: Russian editorial practice spells small
# numbers in running text. So the checker learns the word forms instead.
#
# The table stops at twenty ON PURPOSE. Past it Russian agreement changes — «двадцать один
# признак», not «признаков» — and a checker that demanded «двадцать один признаков» would
# be requiring an ungrammatical sentence in the repository whose subject is grammar. Past
# twenty it refuses and says a person must choose the wording.
CLAIMS = [
    ('README.md',    '{RU} признаков машинного текста'),
    ('README.md',    'справочнике {RU} таких признаков'),
    ('README.md',    '{N} признаков машинного текста'),
    ('README.en.md', '{EN} tells of machine-written text'),
    ('README.en.md', 'holds {EN} such tells in all'),
    ('README.en.md', '{EN} tells of machine writing'),
    # The roadmaps describe the corpus in the present tense — «Those are v2.0 and they are
    # finished» — so they are consumers, not history, and the wholesale `docs/` exemption
    # was hiding three of them at the previous count.
    ('docs/roadmap-v3-formative.md', '{EN} tells of machine-written prose:'),
    ('docs/roadmap-v3-formative.md', 'The {EN} tells of machine-written prose,'),
    ('docs/roadmap-v3-grammar.md', '{EN} tells of machine prose'),
]

def die(msg, detail=()):
    sys.stdout.write('  FAIL  %s\n' % msg)
    for line in detail:
        sys.stdout.write('        %s\n' % line)
    sys.exit(1)

try:
    text = io.open(ADDENDA, encoding='utf-8').read()
except OSError:
    die('%s is missing — the tell count cannot be read' % ADDENDA)

# `\b` after the number, not a literal dot: `## AD-19 Uppercase` with the dot forgotten
# used to be silently uncounted, which is a wrong PASS produced by a typo.
parts = re.split(r'(?m)^(## AD-\d+\b[^\n]*)$', text)
rules = [(parts[i].strip(), parts[i + 1]) for i in range(1, len(parts), 2)]
if not rules:
    die('%s no longer holds any AD- rule headings — the tell count cannot be read' % ADDENDA)

excluded = [h for h, b in rules if EXCLUDES in b]
n = len(rules) - len(excluded)
if not 0 <= n <= 20:
    die('the reference holds %d tells, and this checker knows no word form it can demand '
        'for that number — extend the table by hand, minding Russian agreement' % n)
ru, en = RU[n], EN[n]

wants = [(path, tmpl.replace('{RU}', ru).replace('{EN}', en).replace('{N}', str(n)))
         for path, tmpl in CLAIMS]

if MODE == 'print':
    sys.stdout.write('machine-text tells: %d (%d rules less %d not a tell)\n\n'
                     % (n, len(rules), len(excluded)))
    sys.stdout.write('— places that state the tell count —\n')
    for path, want in wants:
        sys.stdout.write('  %-46s %s\n' % (path, want))
    sys.exit(0)

# Bounded on both ends, and this is not decoration: «восемнадцать» CONTAINS «семнадцать»
# letter for letter, so a plain substring test passed a README claiming eighteen over a
# reference holding seventeen — a silent wrong PASS, measured. The same collision runs all
# through the table: восемь⊃семь, одиннадцать⊃один, тринадцать⊃три, двадцать⊃два.
# Case-insensitive, because a stale count most often opens a sentence: «Двадцать признаков…»
# went straight past a case-sensitive net, and a net that only catches mid-sentence claims
# catches the easy half.
def bounded(phrase):
    return re.compile(r'(?<![0-9A-Za-zА-Яа-яЁё])%s(?![0-9A-Za-zА-Яа-яЁё])' % re.escape(phrase),
                      re.UNICODE | re.IGNORECASE)

def flatten(text):
    """Runs of whitespace to one space, keeping an offset back into the original.

    Claims are PROSE, and prose wraps: «seventeen tells\nof machine prose» is one claim
    written across two lines, and a checker reading line by line calls it missing. Matching
    on the flattened text finds it; the offset map is what still lets the sweep name a line.
    """
    out, offsets, prev_space = [], [], False
    for i, ch in enumerate(text):
        if ch.isspace() or ch == '\u00a0':
            if not prev_space:
                out.append(' ')
                offsets.append(i)
            elif text[i] == '\n' and out and out[-1] == ' ' \
                    and text.count('\n', offsets[-1], i + 1) >= 2:
                # A blank line is a hard boundary, not a space: without it a claim deleted
                # outright is satisfied by two unrelated paragraphs standing next to each
                # other, and the gate goes green over a claim nobody makes any more. The
                # upgrade happens HERE, on seeing the second newline, and not on a lookahead
                # from the first: a lookahead of three characters also fires on a one-character
                # line, marking a boundary where no blank line exists. No case can pin that
                # difference — a one-character line breaks every pattern here anyway, so the
                # divergence is unreachable — which is exactly why the condition had to go
                # rather than be kept «just in case».
                out[-1] = '\x00'
            prev_space = True
        else:
            out.append(ch)
            offsets.append(i)
            prev_space = False
    return ''.join(out), offsets

stale = []
for path, want in wants:
    try:
        body = io.open(path, encoding='utf-8').read()
    except OSError:
        stale.append('%s is missing, and it states the tell count' % path)
        continue
    if not bounded(want).search(flatten(body)[0]):
        stale.append('%s does not say «%s»' % (path, want))
if stale:
    die('machine-text tells: the corpus holds %d (%d rules less %d not a tell), '
        'and these do not say so:' % (n, len(rules), len(excluded)), stale)

# The sweep looks for EVERY number the checker can spell, not only the current one. Sweeping
# for the current value alone leaves the failure that actually happens uncaught: the corpus
# moves, most sites are updated, and one is left behind saying the OLD number — which the
# current value's patterns cannot see. It is scoped to number+noun, never a bare numeral or
# a bare word: both READMEs cite «17 USC §102(b)», and both count thirteen platforms and
# nine reference files in ordinary prose.
# EVERY number the checker can spell, not a window around today's. A window of five was
# tried and is wrong on this repository's own history: the tell count ran 1 -> 5 -> 7 -> 9
# -> 17 -> 18 across the tags, so the last real movement was EIGHT. Worse, the only find
# this sweep has ever made — «9 признаков ИИ-текста» in the Notion README over four tells —
# sits at a distance of eight and a window of five silences it. The ordinary prose a full
# sweep catches is not silenced by narrowing the net; it is named once, below.
patterns = []
for k in range(21):
    patterns.append(re.compile(r'(?<![^\W\d_])%s\s+(?:таких\s+)?призна' % re.escape(RU[k]),
                               re.UNICODE | re.IGNORECASE))
    patterns.append(re.compile(r'(?<![^\W\d_])%s\s+(?:such\s+)?tells?(?![^\W\d_])'
                               % re.escape(EN[k]), re.UNICODE | re.IGNORECASE))
    patterns.append(re.compile(r'(?<![0-9A-Za-zА-Яа-яЁё])%d\s+(?:таких\s+)?призна' % k,
                               re.UNICODE | re.IGNORECASE))
    patterns.append(re.compile(r'(?<![0-9A-Za-zА-Яа-яЁё])%d\s+(?:such\s+)?tells?(?![^\W\d_])'
                               % k, re.UNICODE | re.IGNORECASE))

# Registered claims are subtracted from the LINE, not exempted by file. Skipping the two
# claimant files wholesale is what let a stale sentence rot inside the very README the
# checker was reading — the substring test said the phrase was present somewhere, and
# nothing looked at the rest of the file.
# Lines that put a numeral beside «признак» and are claims about nothing this checker
# measures. Named ONE AT A TIME, with the reason, because a wholesale skip runs in both
# directions: `docs/` was exempt for a season and hid three real stale claims while it
# hid these two. Each entry is checked for still being there, so the list cannot rot.
EXEMPT = [
    ('docs/damage-disposition-proposal.md', 'различает их один признак',
     'inside a verbatim quotation of the author — rewriting it would falsify the quote'),
    ('skills/ru-text/references/info-style.md', 'Три признака слабого текста',
     'corpus content: §C counts weaknesses of a text, not tells of a machine'),
]

registered = {}
for path, want in wants:
    registered.setdefault(path, []).append(want)
gone = []
for path, phrase, _why in EXEMPT:
    try:
        # EXACTLY one. The comment above says «named one at a time», and a substitution that
        # blanks every occurrence does not keep that promise: one two-word entry would silence
        # three unrelated stale sentences, and removing two of them would leave the gate quiet.
        # Both entries occur once today, so this is the promise made enforceable while it is
        # still true rather than after it stops being.
        hits = len(bounded(phrase).findall(flatten(io.open(path, encoding='utf-8').read())[0]))
        if hits == 0:
            gone.append('%s no longer says «%s» — drop the exemption' % (path, phrase))
        elif hits > 1:
            gone.append('%s says «%s» %d times — an exemption names one line, not a phrase'
                        % (path, phrase, hits))
    except OSError:
        gone.append('%s is gone, and an exemption still names it' % path)
    registered.setdefault(path, []).append(phrase)
if gone:
    die('machine-text tells: an exemption names a line that is no longer there:', gone)

try:
    tracked = subprocess.check_output(['git', 'ls-files']).decode('utf-8').split('\n')
except (subprocess.CalledProcessError, OSError):
    die('this is not a git checkout, so the sweep for unregistered claims cannot run')

# CHANGELOG.md records what the numbers WERE and must keep saying them; tools/ describes past
# parser bugs by their numbers. Both are accounts of the past, and a checker that fails on an
# accurate history gets switched off.
#
# `docs/` used to be here and no longer is. It was exempted wholesale for the same reason, and
# the exemption ran in both directions: it hid three present-tense sentences in the roadmaps
# saying «sixteen tells» over a reference that holds seventeen. A directory is not evidence
# about the tense of the sentences inside it.
SKIP = re.compile(r'^(CHANGELOG\.md|tools/|\.github/)')
loose = []
for path in tracked:
    if not path or SKIP.match(path) or not re.search(r'\.(md|json|ya?ml|sha256)$', path):
        continue
    try:
        body = io.open(path, encoding='utf-8').read()
    except (OSError, UnicodeDecodeError):
        continue
    flat, offsets = flatten(body)
    for want in registered.get(path, []):
        # Same width, so the offset map stays aligned: a claim is blanked, never removed.
        flat = bounded(want).sub(lambda m: ' ' * (m.end() - m.start()), flat)
    starts = [0]
    for i, ch in enumerate(body):
        if ch == '\n':
            starts.append(i + 1)
    for pat in patterns:
        for m in pat.finditer(flat):
            at = offsets[m.start()] if m.start() < len(offsets) else len(body)
            line_no = bisect.bisect_right(starts, at)
            loose.append('%s:%d: %s' % (path, line_no,
                                        body.split('\n')[line_no - 1].strip()[:100]))
if loose:
    die('machine-text tells: a count of tells appears where no claim is registered — '
        'add a row or rephrase the line:', loose)

sys.stdout.write('  ok    machine-text tells: %d place(s) state %d, and the reference agrees\n'
                 % (len(CLAIMS), n))
PYT
}

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT INT TERM

CAT=$(catalog_size)
CATEG=$(category_count)

if [ "${1:-}" = "--print" ]; then
  printf 'catalogue entries: %s\ncategories: %s\n\n' "$CAT" "$CATEG"
  echo '— places that state the size —'
  printf '%s\n' "$CATALOG_CLAIMS" | while IFS='|' read -r f tmpl; do
    printf '  %-46s %s\n' "$f" "$(printf '%s' "$tmpl" | sed "s/%s/$CAT/")"
  done
  printf '\n'
  tells_report print
  exit 0
fi

printf 'check-dogfood: the numbers the product states about itself\n'

verify_claims "stop-word catalogue" "$CAT" "$CATALOG_CLAIMS"
guard_complete "stop-word catalogue" "$CAT" "$CATALOG_CLAIMS"
verify_claims "catalogue categories" "$CATEG" "$CATEGORY_CLAIMS"
verify_names

# The install prompt is quoted in three places: both READMEs and the sandbox probe. A probe that
# feeds an agent a different string than the one we publish tests nothing, and the divergence is
# invisible — it was two non-breaking spaces, put there by a typography normaliser that could not
# tell a copyable command from prose. Compared on exact bytes, because that is what the reader
# copies and what the probe sends.
# The golden set states its own size in prose, and prose does not count directories. Two cases
# for AD-17 landed and the figure stayed at 22 — the same hand-maintained-number defect this
# release spent two days removing from the READMEs, reappearing in the file that documents the
# measurement. Counted, not remembered.
golden_cases=$(find tools/golden -maxdepth 1 -type d -name '[0-9]*' | wc -l | tr -d ' ')
# The noun agrees with the numeral, so the pattern cannot hard-code one form: 24 takes
# «текста», 28 takes «текстов», 21 would take «текст». The first version fixed «текста»
# and reported «no longer states how many cases the set holds» the moment the set grew
# past 24 — a guard failing on correct Russian, which is a poor look in this repository.
stated=$(grep -oE 'Все [0-9]+ текст(а|ов)?' tools/golden/README.md | grep -oE '[0-9]+' | head -1)
if [ -z "$stated" ]; then
  bad "tools/golden/README.md no longer states how many cases the set holds"
elif [ "$stated" = "$golden_cases" ]; then
  ok "the golden set states its true size ($golden_cases cases)"
else
  bad "the golden set says $stated cases and holds $golden_cases"
fi

# The one file loaded on every turn, so its size is a per-turn cost and the only claim in this
# repository that was BOTH stated twice and checked nowhere. It read «under 600 words» while the
# file stood at 615, and the always-on dash fix of 01.08.2026 took it to 640 — a budget nobody
# could bust because nobody could fail it. The number is read out of the convention file rather
# than repeated here: two copies of a budget drift, and this checker exists because one already did.
skill_words=$(LC_ALL=C wc -w < skills/ru-text/SKILL.md | tr -d ' ')
skill_budget=$(grep -oE 'at most \*\*[0-9]+ words\*\*' .claude/CLAUDE.md | grep -oE '[0-9]+' | head -1)
if [ -z "$skill_budget" ]; then
  bad ".claude/CLAUDE.md no longer states a word budget for SKILL.md"
elif [ "$skill_words" -le "$skill_budget" ]; then
  ok "SKILL.md is $skill_words words, within the stated budget of $skill_budget"
else
  bad "SKILL.md is $skill_words words, over the stated budget of $skill_budget — trim it, or move the budget on purpose"
fi

if tells_report verify; then :; else fail=$((fail + 1)); fi
if guides_agree; then :; else fail=$((fail + 1)); fi
if notion_report; then :; else fail=$((fail + 1)); fi

prompt_of() { # $1=file — the install prompt as one line, or empty
  python3 - "$1" <<'PYX'
import io, re, sys
try:
    t = io.open(sys.argv[1], encoding='utf-8').read()
except OSError:
    sys.exit(0)
m = re.search(r'Установи навык.*?ru-text\.', t, re.S)
if m:
    print(re.sub(r'[ \t\n]+', ' ', m.group(0)))
PYX
}

pr_ru=$(prompt_of README.md)
pr_en=$(prompt_of README.en.md)
pr_probe=$(prompt_of tools/probe-install.sh)
if [ -z "$pr_ru" ]; then
  bad "the install prompt is missing from README.md"
elif [ "$pr_ru" = "$pr_en" ] && [ "$pr_ru" = "$pr_probe" ]; then
  ok "the install prompt is byte-identical in both READMEs and the probe"
else
  bad "the install prompt differs between the files that must quote it identically:"
  printf '        README.md     %s\n' "$pr_ru" | sed 's/$//'
  printf '        README.en.md  %s\n' "$pr_en"
  printf '        probe-install %s\n' "$pr_probe"
fi

[ "$fail" -eq 0 ] && { echo "check-dogfood: PASS"; exit 0; }
echo "check-dogfood: FAIL — $fail check(s)"
exit 1
