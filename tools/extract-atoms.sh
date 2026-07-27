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
# be deleted with nothing noticing. So the selection is a BLACKLIST — every non-blank line
# is an atom unless it is provably not one. A whitelist of known shapes was written first
# and rejected: it cannot see a shape v2 introduces, and v2 is precisely what it must police.
#
# Over-inclusion is the cheap direction to be wrong in, but it is not free, and an earlier
# note here said it "cancels between snapshots" without qualification. It cancels for noise
# that survives verbatim. Noise that a v2 operation TOUCHES — a navigation line, a section
# label, a cross-reference — becomes an unaccounted atom needing a map row, and no
# disposition means "this was never a rule in the first place". The cost is paperwork on
# the day a heading is reworded; the cost of the other direction is a rule disappearing.
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
# On this corpus the pipeline below collapses exactly two groups of distinct source lines
# to one string: «в связи с тем, что|потому что, так как» (info-style.md:42) with its
# comma-free twin (editorial-grammar.md:294), and `### Rules` with the ten `**Rules:**`
# labels. An earlier version of this comment said ZERO, which was measured on whole raw
# lines rather than on normalised text — the wrong quantity. Neither group is a problem:
# diff-atoms counts occurrences, so losing one copy of a collided pair still shows a
# deficit of one. Two steps from the original design were dropped:
#
#   NFC normalisation — the corpus is already NFC (0 of 2085 lines change), and no POSIX
#   tool does it. Pinned by a selftest case so the day that stops being true is loud.
#
#   case folding — rejected, but not for the reason first written here. The original note
#   claimed a folded duplicate would let a deletion pass in silence. That describes a SET
#   difference; diff-atoms counts occurrences, so a folded pair losing one copy still has
#   a deficit of one and is reported. The claim was wrong and is withdrawn.
#
#   The reason that survives is weaker and about legibility, not safety. Folding merges
#   SIX groups. Five are the same rule living in two files — anti-patterns.md lines 38,
#   39, 40, 41 and 42 pairing with editorial-grammar.md:298, info-style.md:54,
#   info-style.md:37, editorial-grammar.md:302 and editorial-grammar.md:311. The sixth is
#   the table header «Wrong|Correct» in three places, which is not a rule at all.
#   (Earlier drafts of this note said five groups of which four were rule pairs; both
#   numbers were wrong. Reproduce with the folding probe in tools/selftest.sh.)
#   Merged, the deficit is still caught, but the report names one arbitrary home of the
#   pair and sends whoever must write the map row to the wrong file. Keeping case keeps
#   both homes distinguishable at the moment someone has to account for them.
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

        # Fence markers are dropped; what is INSIDE a fence is kept. The first version
        # skipped fenced content as "illustrations of output, not statements of rule",
        # and a reviewer showed that is false of this corpus twice over: the whole
        # /ru-score output contract lives in scoring.md 157-173 (the report heading, the
        # five Russian dimension labels, the weighted formula, the limit of 1-3 issues
        # with quoted fragments) and the entire structure of business-writing.md section
        # E lives in its template at 192-210. Deleting either passed the gate in silence.
        #
        # Worse than the other exclusions: a fenced line is absent from BOTH snapshots, so
        # its removal produces no difference at all, where a wrongly dropped heading at
        # least surfaces as UNACCOUNTED. Recall is the gate; example blocks becoming atoms
        # is the price, and it is the cheap direction to be wrong in.
        if (s ~ /^ *(```|~~~)/) { fence = !fence; continue }

        # A table of contents through to the next "## " — navigation. Both spellings the
        # corpus actually uses: seven files head it "## Contents", addenda.md and
        # scoring.md head it "## Table of Contents", and matching only the first let 24
        # anchor links into the snapshot as though they were rules.
        if (s ~ /^## (Table of )?Contents/) { toc = 1; continue }
        if (toc && s ~ /^## /)  { toc = 0 }
        if (toc) continue

        # "## Sources" to end of file — attribution. So is an H1 title anywhere.
        if (s ~ /^## Sources/) break
        if (s ~ /^# /) continue

        # A markdown separator row, and the header row directly above it — OUTSIDE a fence
        # only. Inside one, the column names are the specification: dropping the header of
        # scoring.md`s result table took «| Измерение | Балл | Замечания |» with it, and
        # business-writing.md`s «| # | Task | Owner | Deadline |» likewise. Inside a fence
        # nothing is excluded; that is the whole point of keeping fenced content.
        if (!fence && s ~ /^\|[ :|-]+\|? *$/) continue
        if (!fence && i < NR && line[i + 1] ~ /^\|[ :|-]+\|? *$/) continue

        # Bare-syntax table headers, listed literally rather than pattern-matched, because
        # anything looser would swallow a genuine rule row that happens to resemble one.
        #
        # These three are NOT all of them — editorial-grammar.md alone carries eleven more
        # (situation|upper/lower|example, condition|example, wrong|correct|why and so on),
        # and there are two elsewhere. The rest stay in as atoms, which is over-inclusion
        # in the harmless direction: they are stable text that survives verbatim, so they
        # cancel between snapshots. These three are named because they repeat across
        # sections, which would otherwise put eight identical phantom atoms in the count.
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
  # .yaml as well as .md: skills/ru-text/agents/{openai,gemini}.yaml carry the Codex and
  # Gemini activation descriptors, the exact analogue of the SKILL.md frontmatter
  # description this script goes out of its way to keep. Leaving them out meant the
  # per-platform advertisement of the whole skill could change with nothing noticing.
  find "$dir" \( -name '*.md' -o -name '*.yaml' \) -type f | sort | while IFS= read -r f; do
    base=$(basename "$f")
    select_atoms "$f" "$base"
  done
done |
  # text field: fold characters, drop a leading rule identifier or ordinal, drop emphasis
  # and quotes, drop ASCII punctuation except the pipe and the hyphen, then collapse
  # whitespace. Two mechanisms, and an earlier note here described a third that does not
  # exist ("the tr sets"): sed with literal multibyte patterns, which under LC_ALL=C match
  # exact byte sequences and cannot match half a character because UTF-8 is
  # self-synchronising; and awk gsub with genuinely ASCII-only classes, which for the same
  # reason cannot touch a byte of a multibyte character.
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
