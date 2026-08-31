# -----------------------------------------------------------------------------
# Created : 2026-08-31
# File    : code/agent/2026-08-31/make-pdfs.py
# Purpose : Print each chapter deck to PDF for the download links on the site.
#
#           revealjs exposes a print layout at `?print-pdf`; Chrome headless
#           renders that to paper. Three details matter:
#           - MathJax must finish before the print, so a virtual time budget is
#             given rather than printing immediately.
#           - Every shot gets a hard timeout. A headless browser that never
#             exits will otherwise stall the whole run (this cost 3h15m once,
#             see memory/slide-overflow-check).
#           - The print is NOT reliable on the first go: the same deck and the
#             same command produce "[Math Processing Error]" in some runs and
#             not others. Every PDF is therefore read back and re-printed
#             until it verifies; see verify().
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
ATTEMPTS = 4           # a print is retried until it verifies; see verify()


def page_count(pdf: Path) -> int:
    """Approximate page count by counting page objects in the raw PDF."""
    return len(re.findall(rb"/Type\s*/Page[^s]", pdf.read_bytes()))


def slide_count(src: Path) -> int:
    """Number of <section> elements reveal puts inside .slides.

    The printed page count is this number or one less: the title slide is
    counted here but is not always printed as a page of its own. Anything
    outside that pair means the print ran before reveal finished the layout
    and slides spilled onto extra sheets.
    """
    text = src.read_text(encoding="utf-8", errors="replace")
    body = text[text.find('<div class="slides">'):text.rfind("</section>") + 10]
    return len(re.findall(r"<section", body))


def pdf_text(pdf: Path) -> str:
    """Extract the text layer. Needed because the raw bytes are compressed."""
    r = subprocess.run(["pdftotext", str(pdf), "-"], capture_output=True)
    return r.stdout.decode("utf-8", "replace")


def verify(pdf: Path, expected: int) -> str:
    """Return "" when the print is good, otherwise why it is not.

    Two failures are possible and both are races inside Chrome's print
    pipeline rather than faults in the deck:
      - MathJax re-typesets when the print layout is applied and some
        expressions come out as "[Math Processing Error]". Verified on
        2026-09-01: the same deck and the same command print cleanly on one
        run and with 7 errors on the next, and the rendered DOM never
        contains the error, so it appears only during printing.
      - reveal has not finished the print layout, so slides overflow onto
        extra sheets (deck 03 printed 47 pages instead of 43).
    """
    text = pdf_text(pdf)
    bad = text.count("Math Processing Error")
    pages = text.count("\f")
    if bad:
        return f"{bad} [Math Processing Error]"
    if pages not in (expected, expected - 1):
        return f"{pages} pages, expected {expected - 1} or {expected}"
    return ""


def render(stem: str) -> tuple[bool, str]:
    src = DECKS / f"{stem}.html"
    if not src.exists():
        return False, "deck html missing"
    dst = OUT / f"{stem}.pdf"
    url = src.resolve().as_uri() + "?print-pdf"
    expected = slide_count(src)
    cmd = [
        CHROME, "--headless=new", "--disable-gpu", "--no-sandbox",
        "--no-pdf-header-footer", "--run-all-compositor-stages-before-draw",
        f"--virtual-time-budget={BUDGET}",
        f"--print-to-pdf={dst}", url,
    ]
    why = ""
    for attempt in range(1, ATTEMPTS + 1):
        try:
            subprocess.run(cmd, capture_output=True, timeout=TIMEOUT)
        except subprocess.TimeoutExpired:
            return False, f"timeout after {TIMEOUT}s"
        if not dst.exists() or dst.stat().st_size == 0:
            return False, "no output"
        why = verify(dst, expected)
        if not why:
            tries = "" if attempt == 1 else f", {attempt} tries"
            return True, f"{dst.stat().st_size/1048576:.1f} MB, {page_count(dst)} pages{tries}"
    return False, f"{why} after {ATTEMPTS} tries"


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
