# Date        : 2026-08-26
# Description : Move the "신뢰구간" slide of 02-preliminary-knowledge.qmd so that
#               it precedes "가설검정의 논리".  The deck currently runs
#               distributions -> testing -> p-value -> confidence interval, but a
#               course normally covers estimation (point, then interval) before
#               testing.  The confidence-interval formula uses t_{0.975, nu}, so
#               the slide must still come after the t slide; it is therefore
#               inserted directly after the F slide, keeping the three
#               normal-derived distributions together as one group.
#
#               Only the slide ORDER changes here.  The cross references between
#               the two slides were rewritten beforehand with the editor, so this
#               script must not touch slide text.  It asserts that the slide count
#               and the total character count are unchanged, which is the check
#               that nothing but the order moved.
#
#               Run from the project root:
#                 python code/agent/2026-08-26/reorder-ci-before-testing.py
# File        : reorder-ci-before-testing.py

import io
import sys

PATH = "quarto/agent/2026-08-26/02-preliminary-knowledge.qmd"

with io.open(PATH, encoding="utf-8") as fh:
    text = fh.read()


def split_slides(t):
    """Return (preamble, [(title, block), ...]) split on level-2 headings."""
    parts = t.split("\n## ")
    pre = parts[0]
    slides = []
    for chunk in parts[1:]:
        title = chunk.split("\n", 1)[0]
        slides.append((title, "## " + chunk))
    return pre, slides


def find(slides, prefix):
    hits = [k for k, (t, _) in enumerate(slides) if t.startswith(prefix)]
    assert len(hits) == 1, "%r matched %d slides" % (prefix, len(hits))
    return hits[0]


pre, slides = split_slides(text)
n_before = len(slides)
chars_before = len(text)

src = find(slides, "신뢰구간")
dst = find(slides, "가설검정의 논리")
assert src > dst, "신뢰구간 is already before 가설검정의 논리"

block = slides.pop(src)
slides.insert(dst, block)

# rstrip + explicit blank line: joining the raw blocks would fuse the trailing
# ":::" of the preamble onto the first "## " heading
out = pre.rstrip("\n") + "\n\n" + "\n".join(s for _, s in slides)

assert len(slides) == n_before, "slide count changed"
assert len(out) == chars_before, "character count changed: %d -> %d" % (
    chars_before, len(out))

with io.open(PATH, "w", encoding="utf-8", newline="") as fh:
    fh.write(out)

order = [t.split(" {")[0] for t, _ in slides]
sys.stdout.write("moved %s: index %d -> %d\n" % (block[0], src, dst))
sys.stdout.write("order now: %s\n" % " | ".join(order[dst - 4:dst + 4]))
