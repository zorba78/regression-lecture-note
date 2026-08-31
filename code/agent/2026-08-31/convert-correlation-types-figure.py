# Date        : 2026-08-31
# Description : Rasterise the "types of correlation" figure that closes the
#               earlier UST lecture note (references/ust-lecture-note/
#               03-summary-data.Rmd, final slide, assets/imgs/
#               corr-scatterplot.svg) so it can be reused in deck 03 of this
#               course.  The source is a 3.1 MB Cairo SVG whose glyphs and
#               ~12,600 points are all paths; embedding it in a deck built
#               with `embed-resources: true` would add ~4.2 MB of base64 to
#               the HTML, so it is converted once to a 2100 x 1470 PNG
#               (~0.4 MB), which is the format every other figure in the
#               decks already uses.
#
#               No R package on this machine can rasterise SVG (rsvg and
#               magick are absent; only svglite is installed), so the
#               conversion uses the headless Edge browser that slidecheck.py
#               already relies on.  The SVG is 720pt x 504pt, i.e. an exact
#               10:7 canvas, and the wrapper below pins the <img> to
#               2100 x 1470 px so the aspect ratio is preserved and the
#               screenshot is a pure scale-up of the vector source.
#
#               Run from the project root:
#                 python code/agent/2026-08-31/convert-correlation-types-figure.py
# File        : convert-correlation-types-figure.py

import os
import subprocess

EDGE = os.environ.get(
    "EDGE_EXE", r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe")

W, H = 2100, 1470                    # 720pt x 504pt scaled by 2100/720 = 2.917
SRC = os.path.abspath("references/ust-lecture-note/assets/imgs/corr-scatterplot.svg")
OUT = os.path.abspath("output/agent/2026-08-31/fig-p08-correlation-types.png")
WRAP = os.path.abspath("output/agent/2026-08-31/_corr-wrap.html")

os.makedirs(os.path.dirname(OUT), exist_ok=True)

# A minimal wrapper: no margin, white background, the image at the exact
# output size.  Screenshotting the SVG directly would letterbox it inside the
# window, so the size has to be forced on an <img> instead.
with open(WRAP, "w", encoding="utf-8") as fh:
    fh.write(
        '<!doctype html><html><head><meta charset="utf-8"><style>'
        'html,body{margin:0;padding:0;background:#ffffff}'
        'img{display:block;width:%dpx;height:%dpx}</style></head>'
        '<body><img src="file:///%s"></body></html>'
        % (W, H, SRC.replace("\\", "/")))

subprocess.run(
    [EDGE, "--headless", "--disable-gpu", "--window-size=%d,%d" % (W, H),
     "--screenshot=" + OUT, "file:///" + WRAP.replace("\\", "/"),
     "--virtual-time-budget=8000"],
    stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=120)

os.remove(WRAP)
print("written: %s (%.0f KB)" % (OUT, os.path.getsize(OUT) / 1024))
