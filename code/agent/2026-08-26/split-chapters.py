# Date        : 2026-08-26
# Description : Split the single-file lecture deck into one Quarto deck per
#               chapter, and append a chapter-specific reference slide to each.
#               The master file quarto/agent/2026-08-13/regression-lecture-note.qmd
#               is never modified; the chapter decks are derived from it, so the
#               master stays the single source of truth and this script can be
#               re-run after any edit to it.
#
#               References are assigned to chapters from where they are actually
#               cited in the master (aside blocks, table captions, inline
#               "(Author, year)" markers).  Lecture-note sources (DSSI, CNU) are
#               deliberately omitted, as requested.
#
#               Asset paths: the chapter decks live one date-folder away from the
#               master, so theme/css are rewritten to point back at the master's
#               assets directory.  Figure paths are ../../../output/... and stay
#               valid because the new folder sits at the same depth.
#
#               Run from the project root:
#                 python code/agent/2026-08-26/split-chapters.py
# File        : split-chapters.py

import io
import os
import re

SRC = "quarto/agent/2026-08-13/regression-lecture-note.qmd"
DST = "quarto/agent/2026-08-26"
ASSETS = "../2026-08-13/assets"

# ---------------------------------------------------------------- references

TEXTBOOKS = [
    "Kutner, M. H., Nachtsheim, C. J., Neter, J., &amp; Li, W. (2005). "
    "<em>Applied Linear Statistical Models</em>, 5th ed. McGraw-Hill.",
    "Faraway, J. J. (2015). <em>Linear Models with R</em>, 2nd ed. CRC Press.",
]

# per chapter: list of (subsection heading, [entries])  -- textbooks are added
# to every deck separately so each chapter deck stands on its own
REFS = {
    "Introduction": [
        ("회귀라는 이름의 출발점", [
            "Galton, F. (1877). Typical laws of heredity. "
            "<em>Proceedings of the Royal Institution</em>, 8, 282-301. "
            "(완두콩 실험, 용어는 아직 <em>reversion</em>)",
            "Galton, F. (1885). Presidential address, Section H (Anthropology). "
            "British Association for the Advancement of Science. "
            "(<em>regression</em> 이 처음 등장, 중간부모 기울기 2/3)",
            "Galton, F. (1886). Regression towards mediocrity in hereditary stature. "
            "<em>Journal of the Anthropological Institute</em>, 15, 246-263. "
            "(성인 자녀 928명, 205가족)",
            "Pearson, K., &amp; Lee, A. (1903). On the laws of inheritance in man. "
            "<em>Biometrika</em>, 2, 357-462.",
            "Gorroochurn, P. (2016). On Galton's change from \"reversion\" to "
            "\"regression\". <em>The American Statistician</em>, 70(2), 227-231. "
            "doi:10.1080/00031305.2015.1087876",
            "Stanton, J. M. (2001). Galton, Pearson, and the peas. "
            "<em>Journal of Statistics Education</em>, 9(3).",
        ]),
        ("현장 사례의 출처", [
            "ASTM E900-21e1. <em>Standard Guide for Predicting Radiation-Induced "
            "Transition Temperature Shift in Reactor Vessel Materials</em>. "
            "ASTM International.",
            "<em>Metals</em>, 12(3), 481 (2022). doi:10.3390/met12030481",
            "<em>Analytical Chemistry</em>, 91(7) (2019). "
            "doi:10.1021/acs.analchem.9b00119",
            "INMM Annual Meeting Proceedings. Weighted least squares fitting of "
            "gamma spectroscopy efficiency functions.",
            "Summary of radiation effects on incidence of solid cancers in the "
            "Life Span Study of atomic bomb survivors: 1958-2009. "
            "<em>Carcinogenesis</em> (2025).",
        ]),
    ],
    "Preliminary Knowledge": [
        ("이 장에서 인용한 문헌", [
            "Kutner, M. H., Nachtsheim, C. J., Neter, J., &amp; Li, W. (2005). "
            "<em>Applied Linear Statistical Models</em>, 5th ed. McGraw-Hill. "
            "(행렬 표기)",
            "American Statistical Association (2016). Statement on statistical "
            "significance and p-values. <em>The American Statistician</em>, "
            "70(2), 129-133.",
        ]),
    ],
    "Simple Linear Regression": [],
    "Multiple Linear Regression": [
        ("이 장에서 인용한 문헌", [
            "Hoaglin, D. C., &amp; Welsch, R. E. (1978). The hat matrix in "
            "regression and ANOVA. <em>The American Statistician</em>, 32(1), 17-22.",
            "Kutner, M. H., et al. (2005). <em>Applied Linear Statistical Models</em>, "
            "5th ed. McGraw-Hill. (계수 해석, 추론에 필요한 가정)",
            "Faraway, J. J. (2015). <em>Linear Models with R</em>, 2nd ed. CRC Press. "
            "(결론별 필요 가정)",
        ]),
    ],
    "Diagnosis & Variable Selection": [
        ("이 장에서 인용한 문헌", [
            "Anscombe, F. J. (1973). Graphs in statistical analysis. "
            "<em>The American Statistician</em>, 27(1), 17-21.",
            "Cook, R. D. (1977). Detection of influential observation in linear "
            "regression. <em>Technometrics</em>, 19(1), 15-18.",
            "Akaike, H. (1974). A new look at the statistical model identification. "
            "<em>IEEE Transactions on Automatic Control</em>, 19(6), 716-723.",
            "Kutner, M. H., et al. (2005). <em>Applied Linear Statistical Models</em>, "
            "5th ed. McGraw-Hill. (진단 기준값, 과적합)",
        ]),
    ],
    "Weighted Regression": [
        ("이 장에서 인용한 문헌", [
            "Kutner, M. H., et al. (2005). <em>Applied Linear Statistical Models</em>, "
            "5th ed. McGraw-Hill. (이분산의 결과, 가중치 선택 규칙)",
            "<em>Analytical Chemistry</em>, 91(7) (2019). "
            "doi:10.1021/acs.analchem.9b00119",
            "INMM Annual Meeting Proceedings. Weighted least squares fitting of "
            "gamma spectroscopy efficiency functions.",
        ]),
    ],
    "Dummy Variable": [
        ("이 장에서 인용한 문헌", [
            "ASTM E900-21e1. <em>Standard Guide for Predicting Radiation-Induced "
            "Transition Temperature Shift in Reactor Vessel Materials</em>. "
            "ASTM International.",
            "<em>Metals</em>, 12(3), 481 (2022). doi:10.3390/met12030481",
            "Kutner, M. H., et al. (2005). <em>Applied Linear Statistical Models</em>, "
            "5th ed. McGraw-Hill. (가변수 코딩)",
        ]),
    ],
    "Summary": [
        ("원전과 이름의 유래", [
            "Galton, F. (1877, 1885, 1886). 완두콩 실험, regression 의 첫 등장, "
            "<em>Journal of the Anthropological Institute</em>, 15, 246-263.",
            "Pearson, K., &amp; Lee, A. (1903). <em>Biometrika</em>, 2, 357-462.",
            "Gorroochurn, P. (2016). <em>The American Statistician</em>, 70(2), 227-231.",
            "Stanton, J. M. (2001). <em>Journal of Statistics Education</em>, 9(3).",
        ]),
        ("방법론", [
            "Akaike, H. (1974). <em>IEEE Trans. Automatic Control</em>, 19(6), 716-723.",
            "Anscombe, F. J. (1973). <em>The American Statistician</em>, 27(1), 17-21.",
            "Cook, R. D. (1977). <em>Technometrics</em>, 19(1), 15-18.",
            "Hoaglin, D. C., &amp; Welsch, R. E. (1978). "
            "<em>The American Statistician</em>, 32(1), 17-22.",
        ]),
        ("현장 사례", [
            "ASTM E900-21e1. ASTM International. / <em>Metals</em>, 12(3), 481 (2022).",
            "<em>Analytical Chemistry</em>, 91(7) (2019). / INMM Annual Meeting Proceedings.",
            "<em>Carcinogenesis</em> (2025). Life Span Study, 1958-2009.",
        ]),
    ],
}

# short slug used for the output file name
SLUG = {
    "Introduction": "introduction",
    "Preliminary Knowledge": "preliminary-knowledge",
    "Simple Linear Regression": "simple-linear-regression",
    "Multiple Linear Regression": "multiple-linear-regression",
    "Diagnosis & Variable Selection": "diagnosis-variable-selection",
    "Weighted Regression": "weighted-regression",
    "Dummy Variable": "dummy-variable",
    "Summary": "summary",
}

ICONS = ["fa-book", "fa-atom", "fa-lightbulb"]


def ref_slide(chapter):
    """Build the reference slide markdown for one chapter."""
    blocks = list(REFS[chapter])
    blocks.append(("교과서", TEXTBOOKS))
    out = ["## 참고문헌 {.smaller}", ""]
    for k, (head, entries) in enumerate(blocks):
        out.append('### <i class="fa-solid %s"></i> %s' % (ICONS[k % len(ICONS)], head))
        out.append("")
        out.append('::: {.callout-tip appearance="minimal"}')
        out.append("<ul>")
        out += ["<li>%s</li>" % e for e in entries]
        out.append("</ul>")
        out.append(":::")
        out.append("")
    return "\n".join(out)


def main():
    text = io.open(SRC, encoding="utf-8").read()
    lines = text.split("\n")

    # yaml header runs from the first '---' to the next one
    close = lines.index("---", 1)
    yaml = lines[1:close]

    # chapter boundaries: level-1 headings
    heads = [(i, s[2:].strip())
             for i, s in enumerate(lines)
             if s.startswith("# ") and not s.startswith("## ")]

    os.makedirs(DST, exist_ok=True)
    for k, (start, name) in enumerate(heads):
        end = heads[k + 1][0] if k + 1 < len(heads) else len(lines)
        body = lines[start:end]

        # the master's reference slides belong to the split decks, not to Summary
        cut = next((j for j, s in enumerate(body)
                    if s.startswith("## 참고문헌")), None)
        if cut is not None:
            body = body[:cut]

        head = []
        for s in yaml:
            s = s.replace("assets/", ASSETS + "/")
            if s.startswith("subtitle:"):
                s = 'subtitle: "%d. %s | Special Lecture for KINS"' % (k + 1, name)
            head.append(s)

        doc = (["---"] + head + ["---", ""]
               + ["<!-- Date: 2026-08-26 | Purpose: chapter %d of the KINS "
                  "regression lecture, split from regression-lecture-note.qmd. "
                  "Generated by code/agent/2026-08-26/split-chapters.py - edit "
                  "the master, not this file. | File: %02d-%s.qmd -->"
                  % (k + 1, k + 1, SLUG[name]), ""]
               + body
               + [ref_slide(name), ""])

        path = os.path.join(DST, "%02d-%s.qmd" % (k + 1, SLUG[name]))
        io.open(path, "w", encoding="utf-8", newline="").write("\n".join(doc))
        n_slides = sum(1 for s in body if s.startswith("## ")) + 1
        print("%-34s -> %-40s %3d slides" % (name, os.path.basename(path), n_slides))


if __name__ == "__main__":
    main()
