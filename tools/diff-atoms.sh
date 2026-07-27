#!/bin/sh
# diff-atoms.sh <old-snapshot> <new-snapshot> [atom-map.tsv]
#
# The no-loss gate. Proves that every atom present in the old corpus is still accounted
# for in the new one — either because it is still there, or because someone wrote down
# what happened to it.
#
# Exit 0 only when nothing is unaccounted for.
#
# ── multiset, not set ────────────────────────────────────────────────────────────────
# Atoms are NOT unique. Measured on the current corpus: 1818 atoms, 16 hashes appearing
# more than once. Three kinds, all legitimate:
#   • block labels repeated per section — "Rules" ×11, "Sources" ×9, "Примеры" ×4
#   • addenda metadata repeated per rule — severity lines, provenance lines
#   • the same rule genuinely living in two files — editorial-grammar.md:294 and
#     info-style.md:42 both carry «в связи с тем что|потому что так как»
# So the comparison counts occurrences. A set difference would report nothing when
# "Rules" drops from eleven blocks to nine, which is two whole rule blocks gone.
#
# ── what the map can and cannot wave through ─────────────────────────────────────────
# There is no DELETED disposition, but that is a speed bump, not a wall, and an earlier
# version of this comment claimed otherwise. A reviewer showed two data-file-only routes
# to deleting a rule: MERGED against any unrelated surviving hash, and DOC against a file
# that merely contains the text somewhere. Both are narrowed below — a target must now
# have the multiplicity to absorb what it claims, and a DOC target may not be a snapshot —
# but the honest statement is that the map raises the cost of a silent deletion and makes
# it attributable, not that it makes one impossible. The rationale field is written for a
# human reviewer, and it is a human reviewer who has to read it.
#
# ── map format: sha1 <TAB> disposition <TAB> target <TAB> rationale ─────────────────
#   MOVED       target = new sha1. For a relocation that also reworded the line. A pure
#               relocation needs no entry at all: the hash is unchanged, so the count is
#               unchanged, and only file:line moved.
#   RENUMBERED  target = new sha1. Identifier changed. Should be rare — the extractor
#               already strips a leading id or ordinal, so most renumbering is invisible.
#   NORMALISED  target = new sha1. Wording touched without changing what the rule says.
#   MERGED      target = new sha1 of the surviving atom. The one disposition where the
#               atom count legitimately falls.
#   DOC         target = path. The atom left the corpus for documentation. The file must
#               exist, must not itself be an atom snapshot, and must contain the atom
#               text AS NORMALISED — column three of the old snapshot, which is the exact
#               string the UNACCOUNTED line prints. Prose that says the same thing in the
#               source spelling will not match, and that is deliberate: a DOC row asserts
#               the rule was carried over verbatim, not paraphrased.

set -eu
export LC_ALL=C

if [ "$#" -lt 2 ]; then
  echo "usage: diff-atoms.sh <old-snapshot> <new-snapshot> [atom-map.tsv]" >&2
  exit 2
fi

OLD=$1
NEW=$2
MAP=${3:-$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/atom-map.tsv}

for f in "$OLD" "$NEW"; do
  [ -f "$f" ] || { echo "diff-atoms: no such snapshot: $f" >&2; exit 2; }
done
[ -f "$MAP" ] || { echo "diff-atoms: no such map: $MAP" >&2; exit 2; }

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

awk -F'\t' -v mapfile="$MAP" -v root="$ROOT" '
  # ── load ────────────────────────────────────────────────────────────────────
  # NR == FNR, not FILENAME == ARGV[1]. The first version compared filenames, and when
  # both arguments are the SAME path — which is how the identity control runs, and how
  # anyone would first sanity-check this tool — every record matched the first branch and
  # the tool reported the whole corpus as lost. Record counters tell the passes apart even
  # then: FNR restarts per file, NR does not.
  NR == FNR { oldn[$1]++; if (!($1 in oldwhere)) oldwhere[$1] = $2; oldtext[$1] = $3; next }
  { newn[$1]++ }

  END {
    # the map, read here rather than as a third input so comment and blank lines can be
    # skipped without polluting the snapshot parsing above
    while ((getline line < mapfile) > 0) {
      if (line ~ /^#/ || line !~ /[^ \t]/) continue
      n = split(line, f, "\t")
      if (n < 3) { printf "  BAD MAP ROW (needs at least sha1, disposition, target): %s\n", line; bad++; continue }
      h = f[1]
      # A second row for the same source hash used to overwrite the first without a word,
      # so a row that would have failed the run could be cancelled by appending another.
      if (h in disp) {
        printf "  DUPLICATE MAP ROW  %s (already %s -> %s)\n", h, disp[h], target[h]
        bad++
        continue
      }
      disp[h] = f[2]; target[h] = f[3]
      if (f[2] != "MOVED" && f[2] != "RENUMBERED" && f[2] != "NORMALISED" && f[2] != "MERGED" && f[2] != "DOC") {
        printf "  BAD DISPOSITION %s for %s — there is no DELETED, by design\n", f[2], h
        bad++
      }
      seen[h] = 1
    }
    close(mapfile)

    merged = 0
    for (h in oldn) {
      deficit = oldn[h] - (h in newn ? newn[h] : 0)
      if (deficit <= 0) continue

      if (!(h in disp)) {
        printf "  UNACCOUNTED  %s  %s\n      %s\n", h, oldwhere[h], oldtext[h]
        if (deficit > 1) printf "      (%d copies lost)\n", deficit
        unaccounted += deficit
        continue
      }

      d = disp[h]; t = target[h]
      if (d == "DOC") {
        # A DOC target may not be an atom snapshot. Column three of a snapshot IS the
        # normalised atom text, so pointing a DOC row at tools/baseline/atoms-v1.10.1.tsv
        # satisfied the containment test for EVERY atom in the corpus — the input file of
        # this very gate was a universal escape hatch. Refusing snapshots by shape rather than
        # by name, so a copy under another path does not slip through.
        path = (t ~ /^\//) ? t : root "/" t
        if ((getline probe < path) < 0) {
          printf "  BROKEN DOC TARGET  %s -> %s (no such file)\n", h, t
          broken++
        } else {
          close(path)
          snapshotish = 0; found = 0; scanned = 0
          while ((getline probe < path) > 0) {
            scanned++
            if (scanned <= 5 && probe ~ /^[0-9a-f]{40}\t[^\t]+\t/) snapshotish = 1
            if (index(probe, oldtext[h])) found = 1
          }
          close(path)
          if (snapshotish) {
            printf "  DOC TARGET IS AN ATOM SNAPSHOT  %s -> %s (it contains every atom by construction)\n", h, t
            broken++
          } else if (!found) {
            printf "  DOC TARGET LACKS THE TEXT  %s -> %s\n", h, t
            broken++
          } else {
            resolved++
            # The budget is credited HERE, in the branch that resolves DOC. The first
            # attempt put `|| d == "DOC"` in the final else, which DOC never reaches
            # because it returns from this branch — dead code that shipped while the
            # commit body announced the fix. A clean DOC row still tripped SHORTFALL.
            merged += deficit
          }
        }
      } else if (!(t in newn)) {
        printf "  BROKEN TARGET  %s --%s--> %s (not in the new snapshot)\n", h, d, t
        broken++
      } else if (used_target[t] + deficit > newn[t]) {
        # Multiplicity, not mere membership. The first version asked only whether the
        # target existed, so ONE row absorbed a deficit of any size: three copies of an
        # atom could vanish and a single MOVED row pointing at one surviving atom
        # accounted for all three. Targets are consumed here, so two rows cannot both
        # claim the same surviving atom either.
        printf "  TARGET OVERSUBSCRIBED  %s --%s--> %s (needs %d, %d available, %d already claimed)\n",
          h, d, t, deficit, newn[t], used_target[t]
        broken++
      } else {
        used_target[t] += deficit
        resolved++
        # MERGED is the only disposition that reaches here and legitimately shrinks the
        # corpus. DOC also shrinks it, but is credited in its own branch above.
        if (d == "MERGED") merged += deficit
      }
      used[h] = 1
    }

    for (h in seen) if (!(h in used)) { printf "  STALE MAP ROW  %s (%s) — nothing to account for\n", h, disp[h]; stale++ }

    for (h in oldn) oldtotal += oldn[h]
    for (h in newn) newtotal += newn[h]

    printf "\natoms: %d -> %d   accounted for by the map: %d   merged away: %d\n", oldtotal, newtotal, resolved, merged
    if (newtotal < oldtotal - merged) {
      printf "  SHORTFALL: %d atoms fewer than merges explain\n", (oldtotal - merged) - newtotal
      short = 1
    }

    if (unaccounted || broken || bad || stale || short) {
      printf "diff-atoms: FAIL — unaccounted %d, broken targets %d, bad map rows %d, stale rows %d\n",
        unaccounted + 0, broken + 0, bad + 0, stale + 0
      exit 1
    }
    printf "diff-atoms: PASS — every atom of the old corpus is accounted for\n"
  }
' "$OLD" "$NEW"
