# Date        : 2026-08-26
# Description : Introduction chapter, third pass.
#               (1) Step 3 (data collection): show ten rows of the ice cream
#                   data instead of five.  Rows 6-10 are transcribed from
#                   references/cnu-regression-lecture-note/강의노트/R 예제/
#                   7장/ice.csv.csv; price is printed to three decimals to
#                   match the existing column formatting.
#               (2) Move the three model-classification slides so that they
#                   follow the 4~8단계 preview, where step 4 (model
#                   specification) is introduced, and reframe the first of
#                   them as the question "어떤 모형을 세울 수 있는가".  The
#                   classification criteria answer that question, so they
#                   belong next to step 4 rather than after the chapter map.
#
#               The master file is edited in place.  Every edit asserts a
#               unique match, so a second run fails loudly.
#
#               Run from the project root:
#                 python code/agent/2026-08-26/link-model-classification.py
# File        : link-model-classification.py

import io

SRC = "quarto/agent/2026-08-13/regression-lecture-note.qmd"


def split_slides(text):
    """Split into (preamble, [(title, block), ...]) on level-2 headings."""
    lines = text.split("\n")
    cuts = [i for i, s in enumerate(lines) if s.startswith("## ")]
    pre = "\n".join(lines[:cuts[0]])
    out = []
    for k, i in enumerate(cuts):
        j = cuts[k + 1] if k + 1 < len(cuts) else len(lines)
        out.append((lines[i][3:].strip(), "\n".join(lines[i:j])))
    return pre, out


def find(slides, prefix):
    hits = [k for k, (t, _) in enumerate(slides) if t.startswith(prefix)]
    assert len(hits) == 1, "%r matched %d slides" % (prefix, len(hits))
    return hits[0]


def sub(text, old, new):
    assert text.count(old) == 1, "anchor matched %d times: %r" % (
        text.count(old), old[:60])
    return text.replace(old, new)


# ------------------------------------------------------------------ task 1
# rows 6-10 of ice.csv.csv, verbatim; price padded to three decimals
ROWS_5 = """| 5 | 0.406 | 0.272 | 76 | 69 | 0 |
"""
ROWS_10 = """| 5 | 0.406 | 0.272 | 76 | 69 | 0 |
| 6 | 0.344 | 0.262 | 78 | 65 | 0 |
| 7 | 0.327 | 0.275 | 82 | 61 | 0 |
| 8 | 0.288 | 0.267 | 79 | 47 | 0 |
| 9 | 0.269 | 0.265 | 76 | 32 | 0 |
| 10 | 0.256 | 0.277 | 79 | 24 | 0 |
"""


# ------------------------------------------------------------------ task 2
# the classification block opens with the question that step 4 poses
NEW_HEAD = """## 4단계 모형 설정: 어떤 모형을 세울 수 있는가

### <i class="fa-solid fa-bullseye"></i> 모형을 나누는 세 가지 기준

4단계는 $E(Y \\mid X = x)$ 의 **형태를 정하는** 일. 아이스크림 자료에서는 일차식을 골랐지만, 고를 수 있는 형태는 다음 세 잣대로 나뉜다
"""

OLD_HEAD = """## 모형의 분류: 세 가지 기준

### <i class="fa-solid fa-bullseye"></i> 분류의 기준
"""


def main():
    text = io.open(SRC, encoding="utf-8").read()
    pre, slides = split_slides(text)

    # -------------------------------------------------------------- task 1
    k = find(slides, "3단계 자료 수집")
    t, s = slides[k]
    s = sub(s, ROWS_5, ROWS_10)
    s = sub(s,
            ": First five rows of the ice cream consumption data.",
            ": First ten rows of the ice cream consumption data.")
    slides[k] = (t, s)

    # -------------------------------------------------------------- task 2
    # reframe the first classification slide
    k = find(slides, "모형의 분류: 세 가지 기준")
    t, s = slides[k]
    s = sub(s, OLD_HEAD, NEW_HEAD)
    s = sub(s,
            "모형을 세 가지 잣대로 나눠 보겠습니다.",
            "4단계, 모형 설정이라고 했습니다. 그런데 모형을 세운다는 것이 "
            "구체적으로 무엇을 정하는 일일까요. 조건부 기댓값을 어떤 "
            "형태의 식으로 적을지 정하는 일입니다. 아이스크림 자료에서는 "
            "일차식을 골랐습니다만, 고를 수 있는 형태가 그것뿐일 리는 "
            "없습니다. 그래서 모형을 세 가지 잣대로 나눠 보겠습니다.")
    slides[k] = ("4단계 모형 설정: 어떤 모형을 세울 수 있는가", s)

    # pull the three slides out, keeping their order
    block = [slides.pop(find(slides, p))
             for p in ("4단계 모형 설정: 어떤 모형을 세울 수 있는가",
                       "모형의 분류: 연습",
                       "모형의 분류: 정답과 해설")]

    # reinsert them directly after the 4~8단계 preview
    at = find(slides, "4~8단계") + 1
    slides[at:at] = block

    # the preview slide now hands off to the classification slides
    k = find(slides, "4~8단계")
    t, s = slides[k]
    s = sub(s,
            "<li>여기까지가 오늘 강의의 예고편. 각 단계에 필요한 도구를 "
            "하나씩 익히는 것이 남은 일곱 장의 일</li>",
            "<li>이 가운데 <b>4단계</b>를 이어서 자세히 봄. 모형을 세운다고 "
            "할 때 <b>세울 수 있는 모형에 어떤 종류가 있는가</b></li>")
    s = sub(s,
            "정리하면 오늘 배울 모든 기법은 이 표의 어느 한 줄을 채우는 "
            "도구입니다. 길을 잃으셨다 싶으면 이 표로 돌아오시면 됩니다.",
            "정리하면 오늘 배울 모든 기법은 이 표의 어느 한 줄을 채우는 "
            "도구입니다. 이 가운데 4단계를 조금 더 들여다보고 가겠습니다. "
            "모형을 세운다고 했는데, 세울 수 있는 모형에는 어떤 종류가 "
            "있는지부터 알아야 고를 수 있습니다.")
    slides[k] = (t, s)

    # keep exactly one blank line between the preamble and the first slide;
    # a plain concatenation fuses ':::' onto the '## ' heading
    out = pre.rstrip("\n") + "\n\n" + "\n".join(s for _, s in slides)
    io.open(SRC, "w", encoding="utf-8", newline="").write(out)

    print("slides: %d" % len(slides))
    for t, _ in slides[:21]:
        print("  " + t)


if __name__ == "__main__":
    main()
