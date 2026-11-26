# Date        : 2026-08-29
# Description : Build-and-drive harness for the KINS regression lecture decks.
#               Renders the Quarto revealjs decks, screenshots every slide with
#               headless Edge at the deck's fixed canvas size, and measures each
#               shot for the two failure modes this project actually hits:
#               content clipped off the bottom edge, and content running past
#               the right edge. Also locates a slide by title so an agent can
#               look at the one it just edited.
# File        : slidecheck.py
#
# Usage (all paths relative to the repo root):
#   python .claude/skills/run-regression-lecture-note/slidecheck.py --render
#   python .claude/skills/run-regression-lecture-note/slidecheck.py --deck 05 --fresh
#   python .claude/skills/run-regression-lecture-note/slidecheck.py --find 잔차그림
#   python .claude/skills/run-regression-lecture-note/slidecheck.py --shot 05:16

import argparse
import io
import os
import re
import subprocess
import sys
import urllib.parse

# Quarto ships inside RStudio and is NOT on PATH. The 8.3 short path is
# mandatory: quarto.cmd splits on the space in "Program Files" and then looks
# for deno under a bogus ".../Files/RStudio/..." path. `--version` survives
# the long path, `render` does not, so do not "fix" this to the readable form.
QUARTO = os.environ.get(
    "QUARTO_CMD", r"C:\PROGRA~1\RStudio\RESOUR~1\app\bin\quarto\bin\quarto.cmd")
EDGE = os.environ.get(
    "EDGE_EXE", r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe")

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                    "..", "..", ".."))
OUTDIR = os.path.join(ROOT, ".slidecheck")

# The canvas is fixed in the deck YAML; measurement thresholds below are
# fractions of it, so changing this only makes sense alongside the YAML.
W, H = 1280, 1024


def say(msg):
    """print() that survives a closed stdout.

    Piping this script through `head` closes the pipe partway; a bare print()
    then raises BrokenPipeError and kills the process INSIDE the render loop,
    leaving some decks silently un-rendered while the run looks fine. Observed:
    `--render | head -6` rendered 01-07 and skipped 08.
    """
    try:
        print(msg, flush=True)
    except (BrokenPipeError, OSError):
        pass


def newest_deck_dir():
    """The dated deck folder under quarto/agent that holds the 0*.qmd set."""
    base = os.path.join(ROOT, "quarto", "agent")
    cands = [d for d in sorted(os.listdir(base), reverse=True)
             if re.match(r"\d{4}-\d{2}-\d{2}$", d)
             and any(re.match(r"0\d-.*\.qmd$", f)
                     for f in os.listdir(os.path.join(base, d)))]
    if not cands:
        sys.exit("no dated deck directory with 0*.qmd found under %s" % base)
    return os.path.join(base, cands[0])


def decks(deck_dir, only=None):
    """(prefix, qmd path, html path) for each deck, filtered by --deck."""
    out = []
    for f in sorted(os.listdir(deck_dir)):
        m = re.match(r"(0\d)-.*\.qmd$", f)
        if m and (only is None or m.group(1) == only):
            out.append((m.group(1), os.path.join(deck_dir, f),
                        os.path.join(deck_dir, f[:-4] + ".html")))
    return out


def render(deck_dir, only):
    """Quarto render, one deck at a time so a failure names the deck."""
    if not os.path.exists(QUARTO):
        sys.exit("quarto not found at %s (set QUARTO_CMD)" % QUARTO)
    for pre, qmd, _ in decks(deck_dir, only):
        r = subprocess.run([QUARTO, "render", os.path.basename(qmd)],
                           cwd=deck_dir, capture_output=True, text=True,
                           encoding="utf-8", errors="replace")
        tail = (r.stdout + r.stderr).strip().splitlines()
        ok = any("Output created" in l for l in tail)
        say("render %s  %s" % (pre, "ok" if ok else "FAILED"))
        if not ok:
            say("\n".join(tail[-15:]))
            sys.exit(1)


def slide_ids(html):
    """Section ids of every H2 slide, in deck order. Index into this is `idx`."""
    if not os.path.exists(html):
        sys.exit("%s not rendered yet - run with --render" % os.path.basename(html))
    return re.findall(r'<section id="([^"]+)" class="slide level2',
                      io.open(html, encoding="utf-8").read())


def shoot(html, sid, png):
    """One headless Edge screenshot. The per-shot timeout is load-bearing: an
    Edge that fails to exit otherwise blocks the whole run indefinitely."""
    try:
        subprocess.run(
            [EDGE, "--headless", "--disable-gpu",
             "--window-size=%d,%d" % (W, H), "--screenshot=" + png,
             "file:///%s#/%s" % (html.replace("\\", "/"),
                                 urllib.parse.quote(sid)),
             # MathJax typesets after load; without this budget the formula
             # slides screenshot blank or half-laid-out.
             "--virtual-time-budget=2500"],
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=45)
    except subprocess.TimeoutExpired:
        pass
    return os.path.exists(png)


def measure(png):
    """(ink, last_row, right_overflow) for one shot.

    ink        non-white pixels in the bottom band - content on the edge
    last_row   last row carrying content, ignoring reveal's progress bar
    right      non-white pixels past 95.5% of the width, excluding reveal's
               right nav arrow (vertically centred) and the slide number
    """
    from PIL import Image
    import numpy as np
    a = np.array(Image.open(png).convert("RGB")).astype(int)
    x0, x1 = int(W * 0.047), int(W * 0.922)
    prof = (a[:, x0:x1].sum(2) < 720).sum(1)          # 720 = non-white cutoff
    bar = int(H * 0.9971)                             # progress bar rows above
    ink = int(prof[int(H * 0.980):bar].sum())
    last = max([r for r in range(bar) if prof[r] > 0] or [-1])

    r0, r1 = int(H * 0.14), int(H * 0.96)
    arrow = range(int(H * 0.45), int(H * 0.55))
    mask = (a[r0:r1, int(W * 0.955):int(W * 0.999)].sum(2) < 720)
    for i, rr in enumerate(range(r0, r1)):
        if rr in arrow:
            mask[i, :] = False
    return ink, last, int(mask.sum())


def main():
    p = argparse.ArgumentParser(description="render + screenshot + measure the lecture decks")
    p.add_argument("--render", action="store_true", help="quarto render before shooting")
    p.add_argument("--deck", metavar="NN", help="limit to one deck, e.g. 05")
    p.add_argument("--fresh", action="store_true", help="discard cached shots first")
    p.add_argument("--find", metavar="TEXT", help="print deck:idx of slides whose id contains TEXT")
    p.add_argument("--shot", metavar="NN:IDX", help="print the png path for one slide")
    p.add_argument("--deck-dir", help="override the dated deck directory")
    a = p.parse_args()

    # Slide ids are Korean. Git Bash and cmd default to a legacy codepage and
    # would print mojibake, which makes --find useless for the thing it exists
    # for. Force UTF-8 on both streams.
    sys.stdout.reconfigure(encoding="utf-8")
    sys.stderr.reconfigure(encoding="utf-8")

    deck_dir = a.deck_dir or newest_deck_dir()
    shots = os.path.join(OUTDIR, "shots")

    if a.shot:
        d, i = a.shot.split(":")
        print(os.path.join(shots, d, "%03d.png" % int(i)))
        return

    if a.find:
        for pre, _, html in decks(deck_dir, a.deck):
            for k, sid in enumerate(slide_ids(html)):
                if a.find in sid:
                    print("%s:%03d  %s" % (pre, k, sid))
        return

    if a.render:
        render(deck_dir, a.deck)

    rows = []
    for pre, _, html in decks(deck_dir, a.deck):
        d = os.path.join(shots, pre)
        if a.fresh and os.path.isdir(d):
            for f in os.listdir(d):
                os.remove(os.path.join(d, f))
        os.makedirs(d, exist_ok=True)
        ids = slide_ids(html)
        for k, sid in enumerate(ids):
            png = os.path.join(d, "%03d.png" % k)
            if not os.path.exists(png):
                shoot(html, sid, png)
            sys.stderr.write("\r%s #%03d/%03d" % (pre, k, len(ids) - 1))
            sys.stderr.flush()
            rows.append((pre, k, sid) +
                        (measure(png) if os.path.exists(png) else (-1, -1, -1)))
    sys.stderr.write("\r" + " " * 30 + "\r")

    os.makedirs(OUTDIR, exist_ok=True)
    # The repo has no .gitignore; keep 200+ screenshots out of `git status`
    # without adding a root-level file the project did not ask for.
    ign = os.path.join(OUTDIR, ".gitignore")
    if not os.path.exists(ign):
        io.open(ign, "w", encoding="utf-8").write("*\n")
    with io.open(os.path.join(OUTDIR, "profile.csv"), "w", encoding="utf-8") as f:
        f.write("deck,idx,id,ink,last_row,right_overflow\n")
        for r in rows:
            f.write("%s,%d,%s,%d,%d,%d\n" % r)

    # A CLIPPED slide is cut mid-glyph: it has ink in the bottom band AND its
    # last content row is the very bottom. A slide that merely ends low is fine.
    clipped = [r for r in rows if r[3] > 40 and r[4] >= int(H * 0.994)]
    noshot = [r for r in rows if r[3] < 0]
    wide = [r for r in rows if r[5] > 30]

    print("slides   : %d" % len(rows))
    print("no shot  : %d%s" % (len(noshot), "  (re-run to retry)" if noshot else ""))
    for r in noshot:
        print("   %s #%03d  %s" % (r[0], r[1], r[2][:50]))
    print("clipped  : %d" % len(clipped))
    for r in clipped:
        print("   %s #%03d  ink=%d last_row=%d  %s" % (r[0], r[1], r[3], r[4], r[2][:40]))
    # Baseline is 0 as of 2026-08-29. It was 25 until then, and every one of
    # those 25 came from `.reveal blockquote {width:100%}` overhanging the
    # right edge with content-box padding. Converting the blockquotes to
    # .highlight-box removed the rule from the decks, so any hit is now real.
    print("overflow : %d%s" % (len(wide),
          "   (baseline 0 - any hit is a real defect)" if a.deck is None else ""))
    for r in wide:
        print("   %s #%03d  right=%d  %s" % (r[0], r[1], r[5], r[2][:40]))
    print("\nshots -> %s\ncsv   -> %s" % (shots, os.path.join(OUTDIR, "profile.csv")))
    sys.exit(1 if (clipped or noshot) else 0)


if __name__ == "__main__":
    try:
        main()
    except BrokenPipeError:
        # Reached only if the report tail is cut off by a pipe; the work is
        # already done by then, so this must not become a non-zero exit.
        os._exit(0)
