#!/bin/sh
# check-assets.sh — the images a manifest points at must exist, be square, and fit the limit.
#
#     tools/check-assets.sh
#
# Three assertions, each bought with a real failure:
#
# 1. The path resolves. A manifest may name an icon the repository does not have, and nothing
#    downstream complains: awesome-codex-plugins' generator reads `interface.composerIcon`,
#    fails to fetch it, and publishes the listing with no icon at all. Silence, not an error.
#
# 2. The image is square. On 30.07.2026 the OpenAI plugin portal rejected our upload with
#    «Image must be square; provided image is 981x993» — logo-round.png had been that shape
#    since the day it was drawn, through five releases, because no gate ever looked. Padded
#    to 993x993 in the same commit as this file.
#
# 3. An icon is at most 50 KB. That is awesome-codex-plugins' own hard gate
#    (scripts/validate-plugin-pr.py); over it, the mirror PR fails CI.
#
# Deliberately dependency-free: PNG dimensions come out of the IHDR chunk, which is the first
# chunk of every PNG by specification, so this runs identically on macOS and on the ubuntu
# runner without Pillow installed. A non-PNG referenced from a manifest is a hard failure
# rather than a skip — a skip is how an unchecked file gets in.
#
# One wrinkle the first version of this file got wrong, caught by running it: the two vendors
# resolve a relative path from different places. Codex documents the PLUGIN ROOT as the base
# (developers.openai.com/plugins/build/plugins.md, read 30.07.2026 — «Keep skills/, hooks/,
# assets/ … at the plugin root»), which is why its manifest writes `./assets/icon.png` while
# sitting one directory down. Cursor's writes `../logo-round.png`, which only reaches the
# repository root if the base is the manifest's own directory. Both land on the same file;
# they spell it differently, and a checker that assumes one convention reports the other's
# images as missing. Resolving from both bases and accepting either was rejected — that turns
# a genuinely missing file into a pass. The base is stated per manifest, with its source.

set -eu
export LC_ALL=C

cd "$(dirname "$0")/.."

ICON_MAX=51200 # 50 KB, awesome-codex-plugins

python3 - "$ICON_MAX" <<'PY'
import io, json, os, struct, sys

icon_max = int(sys.argv[1])
IMAGE_EXT = ('.png', '.jpg', '.jpeg', '.webp', '.svg')
problems = []
checked = 0


def png_size(path):
    """Width and height from the IHDR chunk. Raises on anything that is not a PNG."""
    with open(path, 'rb') as fh:
        head = fh.read(24)
    if head[:8] != b'\x89PNG\r\n\x1a\n':
        raise ValueError('not a PNG')
    if head[12:16] != b'IHDR':
        raise ValueError('no IHDR chunk where the specification puts it')
    return struct.unpack('>II', head[16:24])


def walk(node, path):
    """Yield (json-pointer, value) for every string value under node."""
    if isinstance(node, dict):
        for k, v in node.items():
            for r in walk(v, path + '.' + k):
                yield r
    elif isinstance(node, list):
        for i, v in enumerate(node):
            for r in walk(v, '%s[%d]' % (path, i)):
                yield r
    elif isinstance(node, str):
        yield path, node


# Where each manifest's relative paths start from. Absent = the manifest's own directory,
# which is plain filesystem behaviour. Present = the vendor documents something else.
BASE_IS_PLUGIN_ROOT = {
    '.codex-plugin/plugin.json': 'developers.openai.com/plugins/build/plugins.md, 30.07.2026',
}

manifests = []
for root, dirs, files in os.walk('.'):
    dirs[:] = [d for d in dirs if d not in ('node_modules', '.git')]
    for f in files:
        if f.endswith('.json'):
            manifests.append(os.path.join(root, f))

for m in sorted(manifests):
    try:
        doc = json.load(io.open(m, encoding='utf-8'))
    except ValueError:
        continue  # a non-manifest .json is not this checker's business
    rel = os.path.relpath(m, '.')
    # The plugin root of a manifest in `.<vendor>-plugin/` is that directory's parent.
    base = '.' if rel in BASE_IS_PLUGIN_ROOT else os.path.dirname(m)
    for pointer, value in walk(doc, ''):
        if not value.lower().endswith(IMAGE_EXT):
            continue
        if value.startswith(('http://', 'https://')):
            continue  # a remote URL is not ours to measure
        target = os.path.normpath(os.path.join(base, value))
        label = '%s%s -> %s' % (rel, pointer, value)
        checked += 1

        if not os.path.exists(target):
            problems.append('missing file: %s' % label)
            continue

        size = os.path.getsize(target)
        if 'icon' in pointer.lower() and size > icon_max:
            problems.append('icon over %d bytes (%d): %s' % (icon_max, size, label))

        if target.lower().endswith('.svg'):
            continue  # an SVG scales; squareness is a viewBox question, not a pixel one
        try:
            w, h = png_size(target)
        except (ValueError, OSError) as e:
            problems.append('unreadable as PNG (%s): %s' % (e, label))
            continue
        if w != h:
            problems.append('not square (%dx%d): %s' % (w, h, label))

if problems:
    for p in problems:
        sys.stderr.write('check-assets: %s\n' % p)
    sys.stderr.write('check-assets: FAIL — %d problem(s)\n' % len(problems))
    sys.exit(1)

if checked == 0:
    sys.stderr.write('check-assets: FAIL — no manifest image references found at all; '
                     'the checker is looking in the wrong place\n')
    sys.exit(1)

print('gates: ok    %d manifest image reference(s): present, square, within size' % checked)
PY
