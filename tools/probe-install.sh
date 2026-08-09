#!/bin/sh
# probe-install.sh — does the one-line prompt actually put the skill where the vendor says?
#
#     tools/probe-install.sh --print                 # the documented paths, by platform
#     tools/probe-install.sh setup  <dir> [platform] # build a sandbox, print the prompt
#     tools/probe-install.sh check  <dir> <platform> # judge what the agent did
#
# ── why this exists, and why it replaces what came before ────────────────────────────
#
# Until today the install instructions were gated by reading them against each vendor's
# documentation. That gate was run once, on 28.07.2026, over 81 claims; 31 of them were
# wrong. It is expensive, it is manual, and — the part that matters — it gates the PROSE
# rather than the OUTCOME. A README can describe a directory perfectly and the skill can
# still end up somewhere else, because the thing that installs it is an agent, not a reader.
#
# So the gate moved. The product's promise is now one sentence — «install this skill
# globally» — and the only honest test of that promise is to hand the sentence to a fresh
# agent and look at the disk afterwards. That is what this script judges.
#
# The failure it was built from: an independent probe watched an agent install Codex's copy
# into ~/.codex/skills, sourced from a December-2025 blog post, while OpenAI's current
# documentation puts user skills in $HOME/.agents/skills. Nothing in the repository said
# otherwise, so nothing corrected it. A check that only asserted «a SKILL.md exists
# somewhere» would have called that a pass. This one fails it, by name.
#
# ── what this script does NOT do ─────────────────────────────────────────────────────
#
# It does not run the agent. A POSIX shell cannot start Cursor's agent or Cascade or Codex,
# and a script that pretended to would be a gate testing itself. `setup` prepares the
# sandbox and prints the exact prompt; a human or an orchestrator runs the agent against it;
# `check` reads the result. The seam is deliberate and is where the honesty lives: if nobody
# runs the middle step, `check` finds an empty sandbox and says so rather than passing.

set -eu
export LC_ALL=C

cd "$(dirname "$0")/.."
ROOT=$(pwd)
PATHS=tools/install-paths.tsv
SRC=skills/ru-text

fail=0
ok()  { printf '  ok    %s\n' "$1"; }
bad() { fail=$((fail + 1)); printf '  FAIL  %s\n' "$1"; }

usage() {
  sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'
  exit 2
}

# Documented paths for a platform, one per line, with the leading ~ left intact. Comment and
# header lines are dropped by the field test, not by a line count: a comment added to the top
# of the TSV must not shift anything.
paths_for() { # $1=platform
  awk -F'\t' -v p="$1" '
    /^#/ { next }
    $1 == "platform" { next }
    $1 == p && $3 != "-" { print $2 "\t" $3 }
  ' "$PATHS"
}

platforms() {
  awk -F'\t' '!/^#/ && $1 != "platform" && NF > 1 { print $1 }' "$PATHS" | sort -u
}

# ── --print ──────────────────────────────────────────────────────────────────────────
if [ "${1:-}" = "--print" ]; then
  printf 'documented install paths, from %s\n\n' "$PATHS"
  platforms | while IFS= read -r p; do
    printf '%s\n' "$p"
    rows=$(paths_for "$p")
    if [ -z "$rows" ]; then
      printf '    (own installer — no filesystem path is the interface)\n'
    else
      printf '%s\n' "$rows" | sed 's/^/    /'
    fi
  done
  exit 0
fi

cmd=${1:-}; [ -n "$cmd" ] || usage
dir=${2:-}; [ -n "$dir" ] || usage

case "$cmd" in
setup)
  platform=${3:-any}
  # A sandbox is a HOME and a project, both empty. Empty is the point: every directory the
  # agent creates is a decision it made, and `check` can therefore attribute it.
  mkdir -p "$dir/home" "$dir/project"
  cat > "$dir/PROMPT.txt" <<PROMPT
Установи навык https://github.com/talkstream/ru-text глобально и вызывай его, когда работа идёт
над качеством русского текста: вычитка, типографика, очистка от нейрослопа, редактура, UX-тексты,
деловая переписка — или по прямому упоминанию ru-text.
PROMPT
  cat > "$dir/RUN.md" <<RUN
# Probe sandbox — $platform

Run a FRESH agent (no context from this repository, no access to the local checkout) with
HOME set to \`$dir/home\` and its working directory \`$dir/project\`, and give it exactly
the contents of PROMPT.txt — nothing else. Then:

    tools/probe-install.sh check $dir $platform

The agent must be told which platform it is acting as, because the answer differs by
platform and that difference is the whole measurement.
RUN
  printf 'sandbox ready: %s\n  home:    %s/home\n  project: %s/project\n\n' "$dir" "$dir" "$dir"
  printf -- '--- prompt to hand to a fresh agent ---\n'
  cat "$dir/PROMPT.txt"
  printf -- '---\n'
  exit 0
  ;;
check) ;;
*) usage ;;
esac

platform=${3:-}; [ -n "$platform" ] || usage
[ -d "$dir" ] || { echo "probe-install: no sandbox at $dir" >&2; exit 2; }

printf 'probe-install: %s\n' "$platform"

rows=$(paths_for "$platform")
if [ -z "$rows" ]; then
  echo "probe-install: $platform installs through its own tool; this probe judges filesystem paths only" >&2
  exit 2
fi

TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT INT TERM

# Every SKILL.md the agent left anywhere in the sandbox.
#
# -L, so symlinks are followed. The first version did not, on the stated reasoning that «a
# symlinked skill is a different thing from an installed one». A live probe refuted that in
# one run: the agent symlinked ~/.agents/skills/ru-text at a clone under ~/src and cited
# OpenAI's own page for it — «Codex supports symlinked skill folders and follows the symlink
# target when scanning these locations» (learn.chatgpt.com/docs/build-skills.md). It is not
# merely allowed, it is the better install: git pull on the clone updates it. A gate that
# fails the vendor's documented shape is wrong about the product, not strict about it.
#
# The clone itself is then excluded below. Following symlinks without excluding it would
# report the source tree as four rogue installs, which is what the same live run did.
find -L "$dir" -type f -name SKILL.md 2>/dev/null | sort > "$TMP/all"

# A SKILL.md inside the SOURCE CLONE is a checkout, not an install. Agents clone first and
# link or copy second, so the clone is a normal intermediate and flagging it is noise of the
# crying-wolf kind this project keeps refusing to ship.
#
# ⚠ «Inside a git working tree» is NOT the test, though it was the first one written here. A
# security review reproduced the bypass in one command: drop an empty `.git` beside a rogue
# install — `mkdir ~/.codex/skills/../.git` — and the probe excused it and printed PASS. A
# gate that is disarmed by creating a directory is worse than no gate, because it reports
# success.
#
# So a clone must LOOK LIKE THIS REPOSITORY, and the marker has to be something an install
# directory cannot have. `skills/ru-text/SKILL.md` was tried and is NOT such a marker: the
# second attempt at this fix still passed the bypass, because `~/.codex/skills/ru-text` has
# exactly that shape — any platform whose skills directory is literally named `skills` looks
# like a repository root by that test, with no decoy needed. The marker used instead is
# `.claude-plugin/plugin.json`: the plugin manifest, which lives only at the root of this
# repository and has no reason to exist inside an installed skill.
#
# Two conditions, both required: a `.git` and the manifest beside it. Everything under such a
# root is source — including `tools/testdata/corpus/SKILL.md`, the fixture this repository
# ships, which an earlier `skills/`-only restriction reported as a rogue install.
#
# Cloning INTO a stale path is not excused by this, and does not need a special case: the
# repository has no SKILL.md at its root — check-frozen.sh enforces that — so a clone placed
# at `~/.codex/skills/ru-text` produces no skill the platform can load, and check 1 fails for
# the plain reason that nothing landed at a documented path.
#
# Walking stops at the sandbox root, so a `.git` above the sandbox cannot excuse anything.
: > "$TMP/found"
while IFS= read -r f; do
  [ -n "$f" ] || continue
  d=$(dirname "$f"); clone=0
  while [ "$d" != "$dir" ] && [ "$d" != "/" ]; do
    if [ -e "$d/.git" ] && [ -f "$d/.claude-plugin/plugin.json" ]; then clone=1; break; fi
    d=$(dirname "$d")
  done
  [ "$clone" -eq 0 ] && printf '%s\n' "$f" >> "$TMP/found"
done < "$TMP/all"
n=$(grep -c . "$TMP/found" || true)

if [ "$n" -eq 0 ]; then
  bad "the sandbox holds no SKILL.md — either the agent installed nothing, or nobody ran it"
  echo "probe-install: FAIL — $fail check(s)"
  exit 1
fi

# Expand the documented paths into absolute sandbox locations. `~` maps to the sandbox HOME,
# a bare relative path to the sandbox project.
: > "$TMP/expected"
printf '%s\n' "$rows" | while IFS='	' read -r scope path; do
  case "$path" in
    '~'/*) printf '%s/home/%s\n' "$dir" "${path#'~'/}" ;;
    *)     printf '%s/project/%s\n' "$dir" "$path" ;;
  esac
done >> "$TMP/expected"

# 1. It landed somewhere the vendor documents.
hit=''
while IFS= read -r want; do
  [ -n "$want" ] || continue
  if [ -f "$want/ru-text/SKILL.md" ]; then hit="$want/ru-text"; break; fi
done < "$TMP/expected"

if [ -n "$hit" ]; then
  ok "installed at a documented path: ${hit#"$dir"/}"
else
  bad "installed nowhere $platform reads. Found instead:"
  sed "s|^$dir/|    |" "$TMP/found" | sed 's/^/      /'
  echo "    documented for $platform:"
  sed "s|^$dir/|      |" "$TMP/expected" | sed 's/^/      /'
fi

# 2. Nothing landed at a path NOT documented for this platform. This is the check that
#    catches the real failure: an agent that took a path from a stale third-party post and
#    produced a directory the platform never scans. A probe that only looked for a hit
#    would have called that a pass, because the agent usually writes several copies.
stray=''
# The set of skill directories reachable THROUGH a documented path, as physical locations.
# Comparing directory names was not enough: an agent that links ~/.agents/skills/ru-text at a
# copy under ~/src has one install, reachable two ways, and a name comparison calls the target
# a second rogue copy. Resolving both sides collapses them into the one install they are.
: > "$TMP/legit"
while IFS= read -r want; do
  [ -n "$want" ] || continue
  [ -d "$want" ] || continue
  for entry in "$want"/*; do
    [ -e "$entry/SKILL.md" ] || continue
    (cd "$entry" 2>/dev/null && pwd -P) >> "$TMP/legit" || true
  done
done < "$TMP/expected"

while IFS= read -r got; do
  [ -n "$got" ] || continue
  sd=$(dirname "$got")
  sdreal=$(cd "$sd" 2>/dev/null && pwd -P || printf '%s' "$sd")
  if grep -qxF "$sdreal" "$TMP/legit" 2>/dev/null; then continue; fi
  stray="$stray${stray:+
}$got"
done < "$TMP/found"

if [ -z "$stray" ]; then
  ok "no copy landed outside the documented paths"
else
  bad "a copy landed where $platform does not look — this is the stale-docs failure:"
  printf '%s\n' "$stray" | sed "s|^$dir/|    |" | sed 's/^/      /'
fi

# 3. What arrived is this corpus, not a stale or partial one. Bytes, not names: an agent
#    that fetched a tag, a fork or a truncated copy passes every path test above.
if [ -n "$hit" ]; then
  if cmp -s "$hit/SKILL.md" "$SRC/SKILL.md"; then
    ok "SKILL.md is byte-identical to this checkout"
  else
    # Name what the agent actually fetched. Without it the line reads as a mystery, and the
    # commonest cause is not a fork at all — it is probing before the work is on the default
    # branch, so the agent clones an older release and the diff is correct and expected.
    at=''
    src_repo=$(find "$dir" -type d -name .git -maxdepth 6 2>/dev/null | head -1)
    if [ -n "$src_repo" ]; then
      at=$(git --git-dir="$src_repo" rev-parse --short HEAD 2>/dev/null || true)
      [ -n "$at" ] && at=" — it fetched $at"
    fi
    bad "SKILL.md differs from this checkout$at (a stale ref, a fork, or a partial copy; if you are probing before the branch is merged, this is expected)"
  fi
  want_refs=$(find "$SRC/references" -name '*.md' -type f | wc -l | tr -d ' ')
  got_refs=$(find "$hit/references" -name '*.md' -type f 2>/dev/null | wc -l | tr -d ' ')
  if [ "$got_refs" = "$want_refs" ]; then
    ok "all $want_refs reference files came with it"
  else
    bad "reference files: $got_refs arrived, $want_refs expected — the corpus is truncated"
  fi
fi

[ "$fail" -eq 0 ] && { echo "probe-install: PASS"; exit 0; }
echo "probe-install: FAIL — $fail check(s)"
exit 1
