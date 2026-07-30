#!/bin/sh
# build-og.sh — every social image this project ships, from one committed source.
#
#     tools/build-og.sh            build into assets/og/
#     tools/build-og.sh --check    render and compare against the committed images
#
# The source is assets/og/og.html. This script only sets a canvas and a variant and asks a
# browser to draw it, so the design lives in a file a reviewer can read and diff rather than
# in a binary nobody can open.
#
# Four assets, each size a consumer's requirement rather than a preference:
#   1200x628  Open Graph — what a link preview shows in a chat or a feed
#   1280x640  GitHub's social preview, whose own minimum is 1280x640 at 2:1
# times two variants, dark and light.
#
# Deliberately not a dependency of the plugin. ru-text still has no build step and no runtime
# dependency — this is a maintainer's tool, in the same class as build-release.sh, and the
# images it produces are committed so nobody else ever has to run it.
#
# ── What the first version of this file got wrong, and how each is fixed ────────────────
# An arbiter falsified four of its own comments on 31.07.2026. They are listed because the
# lesson is the file's real subject: a guard that was never run against the failure it names
# is decoration, and prose about a mechanism is not the mechanism.
#
#  * The font check called `--dump-dom` and grepped for «ru-text». That re-serialises the
#    markup's own text, so it passed with no font present at all. Replaced by a real
#    measurement — see assert_font. It also probed only the Latin subset; the Cyrillic file
#    that carries the subtitle was never exercised, and now is.
#  * The renderer loop had no `break`, so the LAST candidate won and the comment claiming a
#    preference order described the opposite of the code.
#  * `--check` compared against the working tree, so a regenerated-but-uncommitted image
#    passed as «matches what is committed». It now reads the blob out of HEAD.
#  * Nothing asserted the light variant had engaged. One broken line of JS in og.html would
#    have rendered four dark images and committed them in silence.

set -eu
export LC_ALL=C

cd "$(dirname "$0")/.."

SRC=assets/og/og.html
OUT=assets/og
CHECK=0
[ "${1-}" = "--check" ] && CHECK=1

[ -f "$SRC" ] || { echo "build-og: FAIL — no $SRC" >&2; exit 1; }
[ -f assets/mark.png ] || { echo "build-og: FAIL — $SRC needs assets/mark.png and it is missing" >&2; exit 1; }

# The font files come from the source, not from a second list here. Two hand-kept lists of
# the same paths is how a rename passes one and fails the other.
FONTS=$(sed -n "s|.*url('\.\./\([^']*\.woff2\)').*|assets/\1|p" "$SRC" | sort -u)
[ -n "$FONTS" ] || { echo "build-og: FAIL — no @font-face url found in $SRC" >&2; exit 1; }
for f in $FONTS; do
  [ -f "$f" ] || { echo "build-og: FAIL — $SRC references $f and it is missing" >&2; exit 1; }
done

# A renderer, in order of preference: Playwright's bundled shell first because it is pinned
# and headless by design, a desktop Chrome second because most machines that have one have
# no Playwright. The `break` is the whole point — without it the last match wins and this
# comment describes the opposite of what happens.
CHROME=""
for c in "$HOME"/Library/Caches/ms-playwright/chromium_headless_shell-*/chrome-*/headless_shell \
         "$HOME"/.cache/ms-playwright/chromium_headless_shell-*/chrome-*/headless_shell \
         "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
         "/Applications/Chromium.app/Contents/MacOS/Chromium" \
         /usr/bin/chromium /usr/bin/chromium-browser /usr/bin/google-chrome; do
  if [ -x "$c" ]; then CHROME="$c"; break; fi
done
[ -n "$CHROME" ] || {
  echo "build-og: FAIL — no Chrome or Chromium found." >&2
  echo "  Install one, or run: npx playwright install chromium-headless-shell" >&2
  exit 1
}

WORK=$(mktemp -d)
PROBE="$OUT/.probe.html"
trap 'rm -rf "$WORK"; rm -f "$PROBE"' EXIT INT TERM
ABS=$(cd "$OUT" && pwd)/$(basename "$SRC")

# ── The font must be the one actually drawn ─────────────────────────────────────────────
# Ink widths of one Latin and one Cyrillic string at 700/100px, measured off a real render.
# Pinned because the face is vendored: these move only when the .woff2 files move, and then
# they are meant to be re-measured deliberately. Measured 31.07.2026 with the committed
# subsets; the same strings in a system fallback come out 400 and 405, so the margin between
# «loaded» and «not loaded» is 16-17px and the tolerance below cannot swallow it.
INK_LAT=417
INK_CYR=421
INK_TOL=6

assert_font() {
  faces=$(sed -n '/@font-face/,/^}/p' "$SRC")
  cat > "$PROBE" <<HTMLEOF
<!doctype html><meta charset="utf-8"><style>
$faces
html,body{margin:0;background:#fff}
div{font-family:'Golos Text';font-weight:700;font-size:100px;line-height:1.4;color:#000;
    white-space:nowrap;width:2000px}
</style>
<div>ru-text</div>
<div>Вычитка</div>
HTMLEOF
  "$CHROME" --headless --disable-gpu --hide-scrollbars --window-size=2000,400 \
    --screenshot="$WORK/probe.png" "file://$(cd "$OUT" && pwd)/.probe.html" >/dev/null 2>&1
  [ -s "$WORK/probe.png" ] || { echo "build-og: FAIL — the font probe rendered nothing" >&2; exit 1; }

  python3 - "$WORK/probe.png" "$INK_LAT" "$INK_CYR" "$INK_TOL" <<'PY'
import sys
from PIL import Image
img, lat, cyr, tol = sys.argv[1], int(sys.argv[2]), int(sys.argv[3]), int(sys.argv[4])
im = Image.open(img).convert('L')
w, h = im.size
px = im.load()


def ink(y0, y1):
    xs = [x for x in range(w) for y in range(y0, y1, 3) if px[x, y] < 128]
    return (max(xs) - min(xs) + 1) if xs else 0


got = (ink(0, h // 2), ink(h // 2, h))
# Both lines are reported before exiting. Measured 31.07.2026: corrupting the CYRILLIC
# subset moves the LATIN measurement too, because a broken @font-face changes how the whole
# family resolves — so a message that names only the first line that failed would send the
# reader to the wrong file.
bad = [(name, g, want) for name, g, want in
       (('Latin', got[0], lat), ('Cyrillic', got[1], cyr)) if abs(g - want) > tol]
if bad:
    sys.stderr.write('build-og: FAIL — the vendored face is not what was drawn.\n')
    for name, g, want in bad:
        sys.stderr.write('  %-8s probe measured %d px of ink, expected %d +-%d\n'
                         % (name, g, want, tol))
    sys.stderr.write(
        '  Either the .woff2 files changed (re-measure and move the pin in build-og.sh)\n'
        '  or the browser fell back to a system font (check the @font-face paths).\n'
        '  A break in ONE subset moves both numbers — check both files, not just the one\n'
        '  named first.\n')
    sys.exit(1)
print('build-og: ok      vendored face verified by ink width (%d / %d px)' % got)
PY
  rm -f "$PROBE"
}

render() { # $1=variant  $2=width  $3=height  $4=destination
  # --force-device-scale-factor=2 renders at true double resolution: glyphs are rasterised
  # at 2x rather than a 1x bitmap being scaled up afterwards. That is what makes the small
  # meta lines survive the downsample.
  "$CHROME" --headless --disable-gpu --hide-scrollbars \
    --force-device-scale-factor=2 \
    --window-size="$2,$3" \
    --screenshot="$WORK/raw.png" \
    "file://$ABS?v=$1" >/dev/null 2>&1

  [ -s "$WORK/raw.png" ] || { echo "build-og: FAIL — renderer produced nothing" >&2; exit 1; }

  python3 - "$WORK/raw.png" "$4" "$2" "$3" "$1" <<'PY'
import sys
from PIL import Image
raw, dest, w, h, variant = sys.argv[1], sys.argv[2], int(sys.argv[3]), int(sys.argv[4]), sys.argv[5]
im = Image.open(raw).convert('RGB')
# The renderer was asked for 2x. If it silently gave 1x, the downsample is a no-op and the
# asset ships soft — the exact defect that shipped once from an html{zoom:2} hack.
if im.size != (w * 2, h * 2):
    sys.stderr.write('build-og: FAIL — expected a %dx%d render, got %dx%d\n'
                     % (w * 2, h * 2, im.size[0], im.size[1]))
    sys.exit(1)
# The variant switch is one line of JavaScript in og.html. If it ever breaks, every image
# renders dark and gets committed in silence, so the ground colour is checked, not assumed.
corner = im.getpixel((4, 4))
want = (255, 255, 255) if variant == 'light' else (13, 17, 23)
if max(abs(a - b) for a, b in zip(corner, want)) > 6:
    sys.stderr.write('build-og: FAIL — the %s variant did not engage: corner is %s, expected %s\n'
                     % (variant, corner, want))
    sys.exit(1)
im.resize((w, h), Image.LANCZOS).save(dest, 'JPEG', quality=100, subsampling=0, optimize=True)
PY
}

# What --check compares against. HEAD, not the working tree: the first version read the
# files on disk, so a regenerated-but-uncommitted image reported «matches what is
# committed» — and did, for the whole window before the images were first added to git.
committed() { # $1=name  -> writes the committed blob to $2, or returns 1
  git show "HEAD:$OUT/$1" > "$2" 2>/dev/null
}

assert_font

STATUS=0
for v in dark light; do
  for size in 1200x628 1280x640; do
    w=${size%x*}; h=${size#*x}
    name="og-$v-$size.jpg"
    if [ "$CHECK" -eq 1 ]; then
      render "$v" "$w" "$h" "$WORK/$name"
      if ! committed "$name" "$WORK/head-$name"; then
        echo "build-og: MISSING — $OUT/$name is not committed"; STATUS=1
      elif cmp -s "$WORK/$name" "$WORK/head-$name"; then
        echo "build-og: ok      $name matches the source, and HEAD matches both"
      else
        echo "build-og: DIFFERS — $name in HEAD is not what $SRC renders"; STATUS=1
      fi
    else
      render "$v" "$w" "$h" "$OUT/$name"
      printf 'build-og: wrote  %-24s %s KB\n' "$name" "$(( $(wc -c < "$OUT/$name") / 1024 ))"
    fi
  done
done

if [ "$CHECK" -eq 1 ] && [ "$STATUS" -ne 0 ]; then
  echo "build-og: what is committed differs from what the source renders." >&2
  echo "  A browser upgrade can change the bytes without changing the design; look before" >&2
  echo "  you re-commit. If the design did change, run tools/build-og.sh and commit." >&2
  exit 1
fi
echo "build-og: PASS"
