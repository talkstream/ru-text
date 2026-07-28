#!/bin/sh
# build-release.sh — the two assets a release ships, built from tracked files only.
#
#     tools/build-release.sh            # build into dist/
#     tools/build-release.sh --check    # build, verify, then delete — proves it still works
#
# Two archives, because hosts disagree about what a "skill" is:
#
#   ru-text-skills.zip   three folders at the top — ru-text/, ru-check/, ru-score/ — for a
#                        host that installs a directory of skills.
#   ru-text-skill.zip    one folder, ru-text/, for a host that takes exactly one skill and
#                        would treat the other two as strays.
#
# Both carry the same corpus. Neither carries the tools, the golden set, the manifests or
# the docs: a user installing a skill has no use for the machinery that verifies it.
#
# ── the rules this script exists to enforce ──────────────────────────────────────────
#
# **Tracked files only.** `git ls-files`, never the working tree. An asset built from the
# tree ships whatever happens to be lying in it — a scratch file, a half-finished rule, an
# editor backup — and the difference is invisible in the archive.
#
# **A clean checkout, or nothing.** Building from a dirty tree produces an artefact whose
# contents no commit describes, and the version inside it is then a lie about which code it
# is. The paid-MCP refresh learned this the same way and refuses for the same reason.
#
# **Verified by unpacking.** A zip that lists the right names can still unpack wrong. Every
# build extracts into a clean directory and compares the result with the source, file by
# file, before the archive is allowed to exist.

set -eu
export LC_ALL=C

cd "$(dirname "$0")/.."

CHECK=0
[ "${1:-}" = "--check" ] && CHECK=1

fail() { printf 'build-release: FAIL — %s\n' "$1" >&2; exit 1; }

command -v zip >/dev/null 2>&1 || fail "zip is not installed"

# ── 1. The checkout must be clean ────────────────────────────────────────────────────
# --check does not require it: that mode proves the build still works and writes nothing,
# so it can run inside a gate on a tree someone is in the middle of editing. Warning about
# dirtiness on every local run would be noise, and noise is how a gate teaches people to
# stop reading it.
if [ "$CHECK" -eq 0 ] && [ -n "$(git status --porcelain 2>/dev/null)" ]; then
  git status --porcelain >&2
  fail "the working tree is dirty; an asset built from it matches no commit"
fi

# ── 2. The version must agree with itself ────────────────────────────────────────────
tools/check-version.sh >/dev/null || fail "check-version — the version disagrees with itself"
VERSION=$(python3 -c "import io,json;print(json.load(io.open('.claude-plugin/plugin.json',encoding='utf-8'))['version'])")
printf 'build-release: version %s\n' "$VERSION"

DIST=dist
rm -rf "$DIST"
mkdir -p "$DIST"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT INT TERM

# Tracked skill files, copied preserving their paths under skills/.
git ls-files -z skills \
  | tr '\0' '\n' \
  | while IFS= read -r f; do
      [ -n "$f" ] || continue
      mkdir -p "$STAGE/all/$(dirname "${f#skills/}")"
      cp "$f" "$STAGE/all/${f#skills/}"
    done

[ -f "$STAGE/all/ru-text/SKILL.md" ] || fail "the staged tree has no ru-text/SKILL.md"

# ── 3. Asset one: three skills ───────────────────────────────────────────────────────
( cd "$STAGE/all" && zip -q -r -X "$STAGE/ru-text-skills.zip" ru-text ru-check ru-score )

# ── 4. Asset two: one skill ──────────────────────────────────────────────────────────
( cd "$STAGE/all" && zip -q -r -X "$STAGE/ru-text-skill.zip" ru-text )

# ── 5. Unpack each and compare, because a listing is not a proof ─────────────────────
verify() { # $1=archive  $2=expected top-level dirs (space separated)
  a=$1; want=$2
  out="$STAGE/verify-$(basename "$a" .zip)"
  mkdir -p "$out"
  unzip -q "$a" -d "$out" || fail "$a does not unpack"
  got=$(cd "$out" && ls -1 | sort | tr '\n' ' ')
  exp=$(printf '%s\n' $want | sort | tr '\n' ' ')
  [ "$got" = "$exp" ] || fail "$a unpacks to [$got], expected [$exp]"
  for d in $want; do
    diff -r "$STAGE/all/$d" "$out/$d" >/dev/null || fail "$a: $d differs from the source after a round trip"
  done
  n=$(find "$out" -type f | wc -l | tr -d ' ')
  printf 'build-release: ok    %-22s %s files, round-trip identical\n' "$(basename "$a")" "$n"
}

verify "$STAGE/ru-text-skills.zip" "ru-text ru-check ru-score"
verify "$STAGE/ru-text-skill.zip" "ru-text"

# ── 6. The corpus inside the asset must be the corpus ────────────────────────────────
# A build that quietly drops a reference file is the failure mode with no symptom: the
# skill installs, activates, and answers from whatever it still has.
# Two comparisons, and the second is the one that matters. Tracked-versus-staged catches a
# path bug in the copy loop. But both sides read `git ls-files`, so a file dropped from the
# INDEX moves both numbers together and the equality stays true — which is exactly what a
# selftest case proved. The floor is the answer: the paid-MCP contract fixes references/ at
# ten files (tools/frozen.sha256, files=10), and an asset with fewer is not this product.
MIN_REFS=10
want_refs=$(git ls-files skills/ru-text/references | wc -l | tr -d ' ')
got_refs=$(find "$STAGE/all/ru-text/references" -name '*.md' | wc -l | tr -d ' ')
[ "$want_refs" = "$got_refs" ] || fail "references/: $got_refs in the asset, $want_refs tracked"
[ "$got_refs" -ge "$MIN_REFS" ] || fail "references/: $got_refs in the asset, the contract fixes it at $MIN_REFS"
printf 'build-release: ok    references/ complete (%s files)\n' "$got_refs"

if [ "$CHECK" -eq 1 ]; then
  rm -rf "$DIST"
  echo "build-release: PASS (--check: nothing written)"
  exit 0
fi

mv "$STAGE/ru-text-skills.zip" "$STAGE/ru-text-skill.zip" "$DIST/"
printf 'build-release: wrote %s/ru-text-skills.zip and %s/ru-text-skill.zip\n' "$DIST" "$DIST"
echo "build-release: PASS"
