# -----------------------------------------------------------------------------
# Created : 2026-08-31
# File    : code/agent/2026-08-31/make-pdfs.py
# Purpose : Print each chapter deck to PDF for the download links on the site.
#
#           revealjs exposes a print layout at `?print-pdf`; Chrome headless
#           renders that to paper. Two details matter:
#           - MathJax must finish before the print, so a virtual time budget is
#             given rather than printing immediately.
#           - Every shot gets a hard timeout. A headless browser that never
#             exits will otherwise stall the whole run (this cost 3h15m once,
#             see memory/slide-overflow-check).
#
#           Usage: python code/agent/2026-08-31/make-pdfs.py [deck-stem ...]
# -----------------------------------------------------------------------------

import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
DECKS = ROOT / "quarto/agent/2026-08-26"
OUT = ROOT / "docs/pdf"
CHROME = r"C:\Program Files\Google\Chrome\Application\chrome.exe"
TIMEOUT = 240          # seconds per deck
BUDGET = 90000         # ms of virtual time for MathJax and image decoding


def page_count(pdf: Path) -> int:
    """Approximate page count by counting page objects in the raw PDF."""
    return len(re.findall(rb"/Type\s*/Page[^s]", pdf.read_bytes()))


def render(stem: str) -> tuple[bool, str]:
    src = DECKS / f"{stem}.html"
    if not src.exists():
        return False, "deck html missing"
    dst = OUT / f"{stem}.pdf"
    url = src.resolve().as_uri() + "?print-pdf"
    cmd = [
        CHROME, "--headless=new", "--disable-gpu", "--no-sandbox",
        "--no-pdf-header-footer", "--run-all-compositor-stages-before-draw",
        f"--virtual-time-budget={BUDGET}",
        f"--print-to-pdf={dst}", url,
    ]
    try:
        subprocess.run(cmd, capture_output=True, timeout=TIMEOUT)
    except subprocess.TimeoutExpired:
        return False, f"timeout after {TIMEOUT}s"
    if not dst.exists() or dst.stat().st_size == 0:
        return False, "no output"
    return True, f"{dst.stat().st_size/1048576:.1f} MB, {page_count(dst)} pages"


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    stems = sys.argv[1:] or [p.stem for p in sorted(DECKS.glob("*.qmd"))]
    ok = 0
    for stem in stems:
        good, msg = render(stem)
        print(f"{'OK  ' if good else 'FAIL'} {stem:38s} {msg}", flush=True)
        ok += good
    print(f"\n{ok}/{len(stems)} rendered")
    return 0 if ok == len(stems) else 1


if __name__ == "__main__":
    sys.exit(main())
