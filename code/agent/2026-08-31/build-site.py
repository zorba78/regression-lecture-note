# -----------------------------------------------------------------------------
# Created : 2026-08-31
# File    : code/agent/2026-08-31/build-site.py
# Purpose : Build the GitHub Pages landing site for the KINS regression lecture.
#
#           Chapter metadata is DERIVED from the decks on every build -- number
#           and English name from the qmd subtitle, slide count from the H2
#           headings, file size from the rendered HTML. Nothing about the
#           chapters is written down twice, so adding or splitting a chapter
#           needs no edit here.
#
#           Order matters: Quarto renders first, then the decks/data/PDFs are
#           copied in. Rendering into a directory that already holds them risks
#           the site build pruning files it does not know about.
#
#           Usage: python code/agent/2026-08-31/build-site.py [--skip-render]
# -----------------------------------------------------------------------------

import html
import re
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
DECKS = ROOT / "quarto/agent/2026-08-26"
SITE = ROOT / "quarto/site"
DOCS = ROOT / "docs"
QUARTO = r"C:\Program Files\RStudio\resources\app\bin\quarto\bin\quarto.exe"

# Korean gloss for each English chapter name. The English names are the user's
# fixed wording (memory: lecture-chapter-structure) and are not translated on
# the cards; this is only the one-line subtitle underneath.
KO = {
    "Introduction": "회귀가 무엇이며 어떤 절차로 수행하는가",
    "Preliminary Knowledge": "행렬 표기와 확률분포, 검정의 기초",
    "Simple Linear Regression": "설명변수 하나로 직선을 긋고 검정하기",
    "Multiple Linear Regression": "설명변수를 여럿 넣고 계수를 읽는 법",
    "Diagnosis & Variable Selection": "모형이 자료와 맞는지 보고 변수를 고르기",
    "Weighted Regression": "관측마다 신뢰도가 다를 때의 가중회귀와 GLS",
    "Dummy Variable": "숫자가 아닌 범주를 모형에 넣는 법",
    "Summary": "핵심 공식과 실무 체크리스트",
}

# Which chapters use which datasets, for the card footer. Keyed by chapter number.
DATA_BY_CH = {3: "ice.csv", 4: "ice.csv", 7: "ice.csv"}


def chapters():
    """Read every deck and derive its card metadata from the file itself."""
    out = []
    for qmd in sorted(DECKS.glob("*.qmd")):
        text = qmd.read_text(encoding="utf-8")
        m = re.search(r'^subtitle:\s*"(\d+)\.\s*([^|"]+?)\s*\|', text, re.M)
        if not m:
            sys.exit(f"{qmd.name}: could not read chapter number/name from subtitle")
        num, name = int(m.group(1)), m.group(2).strip()
        n_slides = len(re.findall(r"^## ", text, re.M))
        deck_html = qmd.with_suffix(".html")
        pdf = DOCS / "pdf" / f"{qmd.stem}.pdf"
        out.append({
            "num": num,
            "name": name,
            "stem": qmd.stem,
            "slides": n_slides,
            "html_mb": deck_html.stat().st_size / 1048576 if deck_html.exists() else 0,
            "pdf_mb": pdf.stat().st_size / 1048576 if pdf.exists() else 0,
        })
    return out


def card(c):
    ko = KO.get(c["name"], "")
    data = DATA_BY_CH.get(c["num"])
    stat = f'{c["slides"]}개 슬라이드 · {c["html_mb"]:.1f} MB'
    if data:
        stat += f' · 자료 {data}'
    if c["pdf_mb"]:
        pdf = f'<a class="pdf" href="pdf/{c["stem"]}.pdf">PDF {c["pdf_mb"]:.1f} MB</a>'
    else:
        pdf = '<a class="pdf disabled" href="#" tabindex="-1">PDF 준비 중</a>'
    # Emit the block without indentation. Pandoc reads a line indented by four
    # spaces as a code block even inside a raw HTML block, which turns the
    # anchors into visible source text instead of links.
    return (
        '<div class="chapter-card">\n'
        f'<div class="num">CHAPTER {c["num"]:02d}</div>\n'
        f'<div class="name">{html.escape(c["name"])}</div>\n'
        f'<div class="ko">{html.escape(ko)}</div>\n'
        f'<div class="stat">{html.escape(stat)}</div>\n'
        '<div class="links">\n'
        f'<a class="view" href="slides/{c["stem"]}.html">슬라이드</a>\n'
        f'{pdf}\n'
        '</div>\n'
        '</div>'
    )


def strip_notes(page: str) -> tuple[str, int]:
    """Remove every <aside class="notes"> element, nesting included.

    Scans forward counting <aside ...> opens against </aside> closes rather
    than matching a non-greedy pair, so a nested aside inside a note cannot
    truncate the removal and leave half the script on the page.
    """
    out, i, removed = [], 0, 0
    while True:
        start = page.find('<aside class="notes"', i)
        if start == -1:
            out.append(page[i:])
            return "".join(out), removed
        out.append(page[i:start])
        depth, j = 0, start
        while j < len(page):
            nxt_open = page.find("<aside", j)
            nxt_close = page.find("</aside>", j)
            if nxt_close == -1:
                return "".join(out) + page[start:], removed   # malformed: keep as-is
            if nxt_open != -1 and nxt_open < nxt_close:
                depth += 1
                j = nxt_open + 6
            else:
                depth -= 1
                j = nxt_close + 8
                if depth == 0:
                    break
        i, removed = j, removed + 1


def main():
    chs = chapters()
    (SITE / "_chapters.md").write_text(
        '<div class="chapter-grid">\n' + "\n".join(card(c) for c in chs) + "\n</div>\n",
        encoding="utf-8")
    total = sum(c["slides"] for c in chs)
    (SITE / "_totals.md").write_text(
        f"전체 {len(chs)}개 장, 슬라이드 {total}장\n", encoding="utf-8")
    print(f"chapters={len(chs)} slides={total}")

    if "--skip-render" not in sys.argv:
        r = subprocess.run([QUARTO, "render"], cwd=SITE)
        print(f"quarto render exit={r.returncode}")

    # Copy after rendering, never before. Speaker notes are the presenter's
    # script and are not published, so they are removed on the way out.
    (DOCS / "slides").mkdir(parents=True, exist_ok=True)
    for c in chs:
        src = DECKS / f'{c["stem"]}.html'
        if not src.exists():
            continue
        page = src.read_text(encoding="utf-8")
        page, removed = strip_notes(page)
        dst = DOCS / "slides" / src.name
        dst.write_text(page, encoding="utf-8")
        left = page.count('class="notes"')
        print(f'  {c["stem"]:38s} notes removed={removed} remaining={left}')
        if left:
            sys.exit(f'{src.name}: {left} notes block(s) survived the strip')

    # docs/data is written by export-data.R; this only checks it is there.
    expected = ["ice.csv", "galton.csv", "trees.csv", "lake-huron.csv",
                "gala.csv", "physical-measurement.csv"]
    missing = [f for f in expected if not (DOCS / "data" / f).exists()]
    if missing:
        print(f"  WARNING missing data files: {missing} — run export-data.R")

    # GitHub Pages runs Jekyll by default, which drops files and folders whose
    # names begin with an underscore -- exactly what Quarto emits.
    (DOCS / ".nojekyll").write_text("", encoding="utf-8")

    print(f"slides={len(list((DOCS/'slides').glob('*.html')))} "
          f"pdf={len(list((DOCS/'pdf').glob('*.pdf'))) if (DOCS/'pdf').exists() else 0} "
          f"data={len(list((DOCS/'data').iterdir()))}")


if __name__ == "__main__":
    main()
