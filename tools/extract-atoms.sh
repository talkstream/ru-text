#!/bin/sh
# extract-atoms.sh <dir> [more dirs…]
#
# Emits one line per ATOM — one rule-bearing unit of the corpus:
#
#     sha1 <TAB> file:line <TAB> normalised text
#
# Run it over the old corpus and over the new one; diff-atoms.sh then proves that every
# old atom is accounted for. Eight of the ten reference files carry no rule IDs, so the
# no-loss gate cannot compare identifiers — it compares content, and this script defines
# what "content" means.
#
# **Recall is the whole gate.** A shape this script fails to recognise is a rule that can
# be deleted with nothing noticing. Over-inclusion is harmless: noise appears in both
# snapshots and cancels. So the selection is a BLACKLIST — every non-blank line is an atom
# unless it is provably not one. A whitelist of known shapes was the first design and it
# was rejected: it cannot see a shape v2 introduces, and v2 is precisely what it must police.
#
# ── what the corpus actually looks like, measured rather than assumed ────────────────
#
# Table syntax splits the corpus in two. Five files use bare `a|b` rows with no leading
# pipe and no `---|---` separator (anti-patterns, editorial-grammar, editorial-punctuation,
# info-style, typography); four use ordinary markdown tables with a leading pipe (addenda,
# business-writing, scoring, ux-writing). Reproduce:
#   for f in skills/ru-text/references/*.md; do printf '%s %s %s\n' "$f" \
#     "$(/usr/bin/grep -cE '^[^|# ][^|]*\|' "$f")" "$(/usr/bin/grep -cE '^\|' "$f")"; done
# Anything keyed on one style silently drops half the corpus. The blacklist sidesteps it.
#
# Some rules span two lines: in info-style §C the numbered line is only a LABEL
# ("1. Удаление воды") and the rule lives in the "До:" / "После:" pair beneath it. Some
# exist only in a heading: the eight `### ` category names in §B are the sole place the
# stop-word taxonomy is written down. Both are covered for free by taking every line.
#
# ── normalisation, each step justified by a measurement ─────────────────────────────
#
# On this corpus the pipeline below produces ZERO collisions: no two distinct source lines
# normalise to the same string. Two steps from the original design were dropped:
#
#   NFC normalisation — the corpus is already NFC (0 of 2085 lines change), and no POSIX
#   tool does it. Pinned by a selftest case so the day that stops being true is loud.
#
#   case folding — REJECTED, and this one matters. Lowercasing collapses five groups, and
#   four of them are the same rule living in two files: anti-patterns.md:38 with
#   editorial-grammar.md:298, anti-patterns.md:40 with info-style.md:37, and two more.
#   Those duplicates are exactly what a later stage is meant to merge DELIBERATELY. Fold
#   case and the merged-away copy still matches its surviving twin, the diff shows nothing
#   unmatched, and a deletion is approved in silence — the failure this gate exists to
#   prevent. Case-sensitive comparison keeps both copies visible until someone writes down
#   what happened to each.
#
# ⚠ LC_ALL=C everywhere. Byte-wise is what we want: sort order becomes machine-independent,
# and the multibyte literals below match exact byte sequences, which UTF-8 makes
# unambiguous. It is also a hard requirement — under a UTF-8 locale the BSD awk on macOS
# reports different Cyrillic strings as equal. See check-frozen.sh for the reproduction.

set -eu
export LC_ALL=C

if [ "$#" -eq 0 ]; then
  echo "usage: extract-atoms.sh <dir> [more dirs…]" >&2
  exit 2
fi

# sha1: coreutils on Linux, perl's shasum on macOS. Resolved once, not per line.
if command -v sha1sum >/dev/null 2>&1; then
  SHA1='sha1sum'
elif command -v shasum >/dev/null 2>&1; then
  SHA1='shasum -a 1'
else
  echo "extract-atoms: no sha1sum or shasum on PATH" >&2
  exit 2
fi

# ── 1. select ─────────────────────────────────────────────────────────────────
# One awk pass per file, but the whole file is buffered first. A streaming version with
# a one-line lookahead buffer was written and thrown away: a markdown table header is
# identifiable only by the separator row BENEATH it, so streaming needs a held line, and
# the held line then has to be flushed correctly at four different exits. Buffering makes
# the lookahead ordinary array indexing and the logic checkable by reading it. The files
# are 42 to 475 lines; there is nothing to optimise.
select_atoms() {
  awk -v fname="$2" '
    { line[NR] = $0 }
    END {
      for (i = 1; i <= NR; i++) {
        s = line[i]

        # YAML frontmatter delimiters, and only the delimiters — the fields between them
        # are kept. SKILL.md carries its activation description there, and a description
        # that quietly changed is exactly the class of loss this snapshot should show.
        if (i == 1 && s == "---") { fm = 1; continue }
        if (fm && s == "---")     { fm = 0; continue }

        # Fenced code blocks: illustrations of output, not statements of rule.
        if (s ~ /^ *(```|~~~)/) { fence = !fence; continue }
        if (fence) continue

        # "## Contents" through the next "## " — navigation.
        if (s ~ /^## Contents/) { toc = 1; continue }
        if (toc && s ~ /^## /)  { toc = 0 }
        if (toc) continue

        # "## Sources" to end of file — attribution. So is an H1 title anywhere.
        if (s ~ /^## Sources/) break
        if (s ~ /^# /) continue

        # A markdown separator row, and the header row directly above it.
        if (s ~ /^\|[ :|-]+\|? *$/) continue
        if (i < NR && line[i + 1] ~ /^\|[ :|-]+\|? *$/) continue

        # Bare-syntax table headers. Listed literally rather than pattern-matched: these
        # three are what exist, and a genuine rule row that happened to resemble a header
        # would be lost to anything looser.
        if (s ~ /^слово\|замена$/) continue
        if (s ~ /^уровень\|когда\|признаки$/) continue
        if (s ~ /^[Ww]rong\|[Cc]orrect$/) continue

        if (s ~ /[^ ]/) print fname ":" i "\t" s
      }
    }
  ' "$1"
}

for dir in "$@"; do
  [ -d "$dir" ] || { echo "extract-atoms: not a directory: $dir" >&2; exit 2; }
  find "$dir" -name '*.md' -type f | sort | while IFS= read -r f; do
    base=$(basename "$f")
    select_atoms "$f" "$base"
  done
done |
  # text field: fold characters, drop a leading rule identifier or ordinal, drop
  # emphasis and quotes, drop ASCII punctuation except the pipe and the hyphen, then
  # collapse whitespace. The tr sets are pure ASCII, which UTF-8 guarantees cannot
  # collide with any byte of a multibyte character.
  sed -e 's/ё/е/g' -e 's/Ё/Е/g' \
      -e 's/—/-/g' -e 's/–/-/g' -e 's/−/-/g' -e 's/‒/-/g' -e 's/―/-/g' \
      -e 's/ / /g' -e 's/ / /g' -e 's/ / /g' \
      -e 's/«//g' -e 's/»//g' -e 's/“//g' -e 's/”//g' -e 's/„//g' |
  awk -F'\t' -v OFS='\t' '{
    t = $2
    sub(/^\|/, "", t)                                  # markdown table leading pipe
    sub(/^ *[-*+] +/, "", t)                           # list bullet
    sub(/^ *#+ +/, "", t)                              # heading marker
    sub(/^ *(R[0-9]+|AD-[0-9]+(\.[0-9]+)?|[0-9]+)[.:)]? +/, "", t)   # rule id or ordinal
    gsub(/[*_`]/, "", t)                               # emphasis
    gsub(/[!"#$%&()+,.\/:;<=>?@\[\]^{}~]/, "", t)      # ascii punctuation, keeping | and -
    gsub(/ +/, " ", t)
    sub(/^ +/, "", t); sub(/ +$/, "", t)
    # A line left with nothing but pipes, hyphens and spaces states no rule — it is a
    # separator or a frontmatter delimiter that survived the filters above. A real rule
    # has words in it, so this cannot drop one.
    probe = t; gsub(/[-| ]/, "", probe)
    if (probe != "") print $1, t
  }' |
  while IFS='	' read -r loc text; do
    printf '%s\t%s\t%s\n' "$(printf '%s' "$text" | $SHA1 | cut -d' ' -f1)" "$loc" "$text"
  done
