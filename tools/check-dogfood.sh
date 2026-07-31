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
    elif grep -qF -- "$want" "$f"; then
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

prompt_of() { # $1=file — the install prompt as one line, or empty
  python3 - "$1" <<'PYX'
import io, re, sys
try:
    t = io.open(sys.argv[1], encoding='utf-8').read()
except OSError:
    sys.exit(0)
m = re.search(r'Установи навык.*?переписка\.', t, re.S)
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
