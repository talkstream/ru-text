#!/bin/sh
# gates.sh — every gate CI runs, in CI's order, from one command.
#
#     tools/gates.sh
#
# Exit 0 only when all of them pass: a checker selftest, the corpus contract with the paid
# MCP, and the no-loss gate against the pinned v1.10.1 baseline.
#
# What it does NOT cover, said here so a green line is not read as more than it is:
# `tools/golden/` — the curated texts with their expected findings. Those are run by a
# model through `/ru-text:ru-check`, deliberately and permanently without a harness
# (tools/golden/README.md says why), so nothing here can execute them. A `gates: PASS`
# means the machinery is sound; whether the corpus still finds what it promises is a
# separate question this script does not ask.
#
# Why it exists. The three gates were three commands a person had to remember, listed in a
# handoff note and in .github/workflows/gates.yml, and nowhere the machine would read.
# The pre-push hook looks for a repository's declared suite — .claude/pre-push.sh, then
# tools/gates.sh, then tools/selftest.sh — so naming the file this way is what makes a red
# gate stop a push instead of reddening CI ten minutes later.
#
# Kept in step with .github/workflows/gates.yml by hand, and that is a real cost: two
# copies of a sequence drift. The alternative — CI calling this script — was rejected
# because then a broken script silently disables CI too, and the runner's own `set -eu`
# and step boundaries are the second opinion. Change one, change the other; the selftest
# case «gates.sh runs the same checkers CI does» fails when they diverge.

set -eu
export LC_ALL=C

cd "$(dirname "$0")/.."

BASELINE=tools/baseline/atoms-v1.10.1.tsv
# The baseline is pinned by content, not by policy: without this, deleting a rule from the
# corpus AND its line from the baseline passes every gate green, because the comparison is
# with a file the same commit is free to edit. This moves once, at the v2.0 release.
BASELINE_SHA=98b2e03bc771d7c0b3268f4eb406fbb3641bc8fdb01243ff3053a1790e2b3aa4

fail() { printf 'gates: FAIL — %s\n' "$1" >&2; exit 1; }

# ── 1. The checkers must be runnable ────────────────────────────────────────────────
# A syntax error in a checker reads as a passing checker to anything that only looks at
# whether the file exists.
#
# `find`, not the `tools/*.sh` glob: the glob stops at the top level, and a checker one
# directory down was invisible to this gate and to the CI-parity case both.
#
# `dash -n` when it exists, because `sh -n` checks a different language on each machine.
# On macOS /bin/sh is bash 3.2, which parses `arr=(a b)` happily; on the ubuntu runner
# /bin/sh is dash, which does not. A checker written with a bashism therefore passed here
# and failed in CI — the exact divergence a local gate exists to catch first.
SHCHECK=sh
command -v dash >/dev/null 2>&1 && SHCHECK=dash
for f in $(find tools -name '*.sh' -type f | sort); do
  [ -x "$f" ] || fail "not executable: $f"
  "$SHCHECK" -n "$f" || fail "syntax error: $f"
done
echo "gates: ok    tools/**.sh executable and POSIX-parseable (via $SHCHECK -n)"

# Same argument, other language. tools/ gained its first .py with measure-prose-shape.py,
# and the loop above cannot see it: a broken Python file would sit there reading as a
# passing tool to anything that only checks whether the file exists.
PYFILES=$(find tools -name '*.py' -type f | sort)
if [ -n "$PYFILES" ]; then
  for f in $PYFILES; do
    [ -x "$f" ] || fail "not executable: $f"
    python3 -c "import ast,io,sys; ast.parse(io.open(sys.argv[1],encoding='utf-8').read(), sys.argv[1])" "$f" \
      || fail "syntax error: $f"
  done
  echo "gates: ok    tools/**.py executable and parseable"
fi

# ── 2. Selftest — every checker must be able to fail ────────────────────────────────
# Runs first among the gates. If the checkers cannot fail, their passing below means
# nothing at all.
# The exit code is not enough, and that is not a hypothetical: an uninitialised counter made
# the suite abort mid-run under `set -eu`, and the EXIT trap turned the abort into status 0.
# A run that printed no summary line did not finish, whatever it exited with. The line is
# required by SHAPE, not by its numbers — a count baked in here would be one more
# hand-maintained figure.
selftest_out=$(tools/selftest.sh 2>&1) || { printf '%s\n' "$selftest_out"; fail "selftest"; }

printf '%s\n' "$selftest_out"
printf '%s\n' "$selftest_out" | grep -qE '^selftest: [0-9]+ passed' \
  || fail "selftest exited 0 without printing a summary — it did not finish"

# The boundary gate has its own selftest, kept separate because tools/selftest.sh needs a
# copy of the tree while this one needs a throwaway git repository. Until this line existed
# nobody called it, and «the selftest proves all nine cases» was a promise without a
# mechanism — the very class of defect the boundary work was written against. Found by the
# arbiter reviewing that work, which is the second time this repository has shipped the
# thing it was busy prohibiting.
private_out=$(tools/selftest-check-private.sh 2>&1) \
  || { printf '%s\n' "$private_out"; fail "selftest-check-private"; }
echo "gates: ok    boundary gate proves it can red (9 cases)"


# ── 3. The paid-MCP corpus contract ─────────────────────────────────────────────────
tools/check-frozen.sh || fail "check-frozen"

# ── 4. One version, one description budget, one set of triggers ─────────────────────
tools/check-version.sh || fail "check-version"

# ── 5. The numbers the product states about itself ──────────────────────────────────
tools/check-dogfood.sh || fail "check-dogfood"

# ── 5b. The product obeys its own typography ────────────────────────────────────────
# The mechanical subset only, over the two files that speak in the project's own voice.
# It exists because the README claims its every dash and space follows the plugin's rules,
# and that claim was checked by remembering to ask a model — which failed twice in one day.
tools/check-typography.sh || fail "check-typography"

# ── 5b2. The one-way boundary with the private contour ──────────────────────────────
# Runs before the slow gates because what it guards is irreversible: a hostname, a repo
# name or a token reaching a public commit cannot be recalled from 14 release tags and
# every clone. Measured across all 144 commits of every branch — never happened; until now
# nothing but attention was holding it.
tools/check-private.sh || fail "check-private"

# ── 5c. The images a manifest points at ─────────────────────────────────────────────
# Added the day the OpenAI plugin portal refused an upload over a 981x993 logo that had
# shipped in five releases. Nothing in the repository had ever looked at an image file.
tools/check-assets.sh || fail "check-assets"

# ── 6. No-loss gate against the pinned baseline ─────────────────────────────────────
# GNU coreutils names it sha256sum; macOS ships shasum and no sha256sum. Checking for
# both, rather than assuming either, is why this script runs on the author's machine and
# on the Linux runner.
if command -v sha256sum >/dev/null 2>&1; then
  printf '%s  %s\n' "$BASELINE_SHA" "$BASELINE" | sha256sum -c - >/dev/null \
    || fail "baseline pin moved: $BASELINE"
elif command -v shasum >/dev/null 2>&1; then
  printf '%s  %s\n' "$BASELINE_SHA" "$BASELINE" | shasum -a 256 -c - >/dev/null \
    || fail "baseline pin moved: $BASELINE"
else
  fail "no sha256 tool (sha256sum, shasum) — the baseline pin cannot be verified"
fi
echo "gates: ok    baseline pinned by content"

NOW=$(mktemp)
# INT and TERM as well as EXIT: dash does not run an EXIT trap when the shell dies on a
# signal, so on the Linux runner a Ctrl-C left the snapshot behind. Measured, not assumed.
trap 'rm -f "$NOW"' EXIT INT TERM
tools/extract-atoms.sh skills/ru-text > "$NOW" || fail "extract-atoms"
# Invoked exactly as CI invokes it. The map argument is the same file diff-atoms.sh falls
# back to, so passing it changed nothing — except to put a difference between the two
# copies of this sequence that the parity case cannot see.
tools/diff-atoms.sh "$BASELINE" "$NOW" || fail "no-loss gate"

# ── 7. The release assets can still be built ────────────────────────────────────────
# Writes nothing. Catches the failure with no symptom: a renamed or dropped reference
# file that leaves the skill installing, activating, and answering from what it still has.
tools/build-release.sh --check >/dev/null || fail "build-release"
echo "gates: ok    both release assets build and round-trip"

echo "gates: PASS"
