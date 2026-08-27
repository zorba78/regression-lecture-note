# Date        : 2026-08-26
# Description : Introduction chapter, second pass.
#               (1) Move the variable-type slide so that it directly follows
#                   step 2 (variable selection) and step 3 (data collection),
#                   where the quantitative / qualitative distinction is first
#                   needed -- the ice cream columns temp/price/income are
#                   quantitative while `year` is qualitative.
#               (2) Retitle it.  The old title "변수의 유형과 특수한 명칭" was
#                   ambiguous: the special names (ANOVA / ANCOVA / logistic)
#                   are names of *regression models*, not of variables.  The
#                   slide is now titled after its main subject (variable
#                   types) and the model-name table is explicitly demoted to
#                   a reference block.
#               (3) Repair the forward pointer on the chapter-map slide, which
#                   still announced the ice cream data as if it came later.
#                   That pointer was made stale by restructure-intro.py.
#
#               The master file is edited in place.  Every edit asserts a
#               unique match, so a second run fails loudly instead of
#               corrupting the deck.
#
#               Run from the project root:
#                 python code/agent/2026-08-26/move-variable-type-slide.py
# File        : move-variable-type-slide.py

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


# ------------------------------------------------------- new slide content

# the whole slide is rewritten: title, both section headings, the reference
# marker under the table, and the speaker notes (which now start from the
# ice cream columns the audience has just seen)
VAR_SLIDE = r"""## 변수의 유형

### <i class="fa-solid fa-bullseye"></i> 양적 변수와 질적 변수

::: {.callout-tip appearance="minimal"}
<ul>
<li>양적 변수(quantitative): 가격, 소득, 기온, 조사량과 같이 수치로 측정되는 변수. 아이스크림 자료의 <code>price</code>, <code>income</code>, <code>temp</code></li>
<li>질적 변수(qualitative): 제품 형태(용접재/판재/단조재), 성별(남/여)과 같이 범주로 측정되는 변수. 아이스크림 자료의 <code>year</code>. 지시변수(indicator) 또는 가변수(dummy variable)로 코딩하여 모형에 넣는다</li>
</ul>
:::

> 회귀분석에서 **반응변수는 양적** 이고, **설명변수는 양적 또는 질적** 모두 가능하다.

### <i class="fa-solid fa-circle-info"></i> 참고 · 변수의 유형에 따라 달라지는 회귀모형의 이름

| Method | 반응변수 | 설명변수 |
|:---|:---|:---|
| 분산분석 (analysis of variance) | 양적 | 질적 |
| 공분산분석 (analysis of covariance) | 양적 | 양적, 질적 혼합 |
| 로지스틱회귀 (logistic regression) | 질적 (보통 이항) | 양적, 질적 |

: Special names for regression models by the type of the response and the predictors.

::: notes
방금 본 아이스크림 자료의 열을 다시 떠올려 보십시오. 기온, 가격, 소득은 숫자로 재는 값입니다. 그런데 마지막 year는 0, 1, 2라는 숫자가 붙어 있어도 크기를 재는 값이 아닙니다. 1년째와 2년째 사이의 간격이 얼마라고 말할 수 없으니까요. 종류를 나누는 값일 뿐입니다.

변수는 이렇게 두 종류로 나뉩니다. 숫자로 재는 양적 변수, 종류를 나누는 질적 변수. 기온이나 가격은 양적이고, 제품 형태나 합격 여부는 질적입니다. 질적 변수도 회귀에 넣을 수 있습니다. 다만 그대로는 못 넣고 0과 1로 바꿔서 넣습니다. 이것을 가변수라고 부르고, 뒤에서 따로 한 장을 씁니다.

기억해 두실 것은 한 줄입니다. 회귀분석에서 반응변수는 양적이어야 합니다. 설명변수 쪽은 양적이든 질적이든 상관없습니다.

아래 표는 참고로만 보십시오. 오늘 다루는 내용은 아닙니다. 다만 통계학에서 다른 이름으로 배웠던 방법들이 알고 보면 변수의 유형을 어떻게 조합하느냐에 따라 붙은 이름일 뿐이라는 점은 알아 두시면 좋습니다. 설명변수가 전부 질적이면 분산분석, 섞여 있으면 공분산분석이라고 부릅니다. 반응변수가 질적이면 로지스틱 회귀가 됩니다. 이름은 달라 보여도 뿌리는 하나입니다.
:::
"""


def main():
    text = io.open(SRC, encoding="utf-8").read()
    pre, slides = split_slides(text)

    # (1)+(2) pull the variable-type slide out, replace it, reinsert it right
    #         after the data-collection slide
    src = find(slides, "변수의 유형과 특수한 명칭")
    slides.pop(src)
    dst = find(slides, "3단계 자료 수집") + 1
    slides.insert(dst, ("변수의 유형", VAR_SLIDE + "\n"))

    # (3) the chapter-map slide no longer precedes the worked example
    k = find(slides, "8단계와 이 강의의 구성")
    t, s = slides[k]
    s = sub(
        s,
        "**표만으로는 절차가 손에 잡히지 않음** · 다음 슬라이드에서 예제 "
        "자료를 하나 소개하고, 그 자료에 여덟 단계를 그대로 얹어 봄",
        "**방금 아이스크림 자료로 훑은 여덟 단계가 각각 어느 장의 주제인가** "
        "· 1~3단계는 이 장에서 마무리, 4~8단계가 남은 일곱 장의 내용",
    )
    s = sub(
        s,
        "길을 잃었다 싶으시면 이 표로 돌아오십시오. 그런데 이런 표는 아무리 "
        "봐도 절차가 손에 잡히지 않습니다. 여덟 단계라는 말이 무엇을 하라는 "
        "뜻인지는 실제 자료 하나를 끝까지 끌고 가 봐야 압니다. 그래서 다음 두 "
        "장을 준비했습니다. 먼저 오늘 계속 쓸 예제 자료를 소개하고, 그다음 그 "
        "자료에 여덟 단계를 하나씩 얹어 보겠습니다.",
        "길을 잃었다 싶으시면 이 표로 돌아오십시오. 방금 아이스크림 자료로 "
        "여덟 단계를 한 바퀴 돌아 봤으니, 어느 단계가 어느 장에 들어 있는지가 "
        "이제 눈에 들어오실 겁니다. 오늘 남은 시간은 이 표의 오른쪽 칸을 위에서 "
        "아래로 하나씩 채워 나가는 일입니다.",
    )
    slides[k] = (t, s)

    out = pre + "\n".join(s for _, s in slides)
    io.open(SRC, "w", encoding="utf-8", newline="").write(out)

    print("slides: %d" % len(slides))
    for t, _ in slides[:20]:
        print("  " + t)


if __name__ == "__main__":
    main()
