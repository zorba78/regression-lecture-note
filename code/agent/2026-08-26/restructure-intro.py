# Date        : 2026-08-26
# Description : One-off restructure of the Introduction chapter of the master
#               deck, following the DSSI introduction note: the eight steps are
#               walked through on the ice cream data, starting from a research
#               question, and the step-to-chapter mapping table comes after.
#
#               The three field cases are removed from Introduction and folded
#               into the chapters that teach the corresponding tool; the
#               one-screen summary of the three cases stays, reframed as a
#               forward pointer.
#
#               Operates on the master in place.  Every edit asserts its anchor,
#               so a second run fails loudly instead of corrupting the file.
#               Afterwards regenerate the chapter decks:
#                 python code/agent/2026-08-26/split-chapters.py
#
#               Run from the project root:
#                 python code/agent/2026-08-26/restructure-intro.py
# File        : restructure-intro.py

import io

QMD = "quarto/agent/2026-08-13/regression-lecture-note.qmd"

# --------------------------------------------------------------- new slides

STEP_12 = r"""## 1·2단계: 연구 질문과 변수 선택 {.smaller}

### <i class="fa-solid fa-circle-question"></i> 날씨가 더워지면 아이스크림이 정말 더 팔릴까

::: {.callout-note appearance="minimal"}
**1단계 · 문제의 진술**

<ul>
<li>답해야 할 질문을 한 문장으로 확정: <b>기온이 오르면 1인당 소비량의 평균이 올라가는가</b></li>
<li>묻는 대상은 개별 소비량이 아니라 <b>평균</b>. 같은 기온의 기간이 여러 번 있어도 소비량은 매번 다름</li>
</ul>
:::

<i class="fa-solid fa-list-check"></i> **2단계 · 관련 변수의 선택** : 기온만으로 충분한가. 소비량을 바꿀 만한 요인을 먼저 나열하고, 그것을 수집 대상으로 삼음

| 요인 | 변수 | 유형 | 함께 재는 이유 |
|:--|:--|:--|:--|
| 날씨 | `temp` 평균기온 | 양적 | 질문의 주인공 |
| 가격 | `price` 아이스크림 가격 | 양적 | 비싸지면 덜 사 먹을 것 |
| 소득 | `income` 가족 월수입 | 양적 | 여유가 있으면 더 사 먹을 것 |
| 시기 | `year` 관측 연차 | 질적 | 해가 바뀌며 생긴 전반적 변화 |

: Candidate drivers of ice cream consumption, and the reason each one was collected

::: notes
여덟 단계를 말로만 들으면 손에 잡히지 않습니다. 자료 하나를 골라 끝까지 끌고 가 보겠습니다. 오늘 강의 내내 따라다닐 아이스크림 소비량 자료입니다.

1단계, 무엇을 알고 싶은가. 질문은 이렇습니다. 날씨가 더워지면 아이스크림이 정말 더 팔릴까. 소박해 보이지만 이 한 문장을 정확히 적는 일이 가장 중요합니다. 여기서 한 가지만 짚고 가겠습니다. 우리가 묻는 것은 개별 소비량이 아니라 평균입니다. 기온이 똑같이 20도인 기간이 여러 번 있어도 소비량은 매번 다르게 나옵니다. 그러니 20도일 때 얼마나 팔리느냐가 아니라, 20도일 때 평균 얼마나 팔리느냐를 묻는 것입니다. 앞에서 정의한 조건부 기댓값이 바로 이 질문의 형태입니다.

2단계입니다. 기온만 재면 될까요. 잠깐만 생각해 봐도 아닙니다. 아이스크림 값이 오르면 덜 사 먹을 것이고, 주머니 사정이 넉넉하면 더 사 먹을 것입니다. 해가 바뀌면서 입맛이나 유행이 달라졌을 수도 있습니다. 그래서 표에 있는 네 가지를 함께 재기로 했습니다. 기온, 가격, 소득, 그리고 몇 년째인지. 여기서 중요한 것은 순서입니다. 자료를 먼저 모아 놓고 무엇을 넣을까 고민한 것이 아니라, 무엇이 소비량을 바꿀 만한지 먼저 따져 보고 그것을 재러 나간 것입니다. 마지막 연차는 성격이 다릅니다. 0, 1, 2라는 숫자가 붙어 있지만 크기를 재는 값이 아니라 종류를 나누는 값입니다. 이런 변수를 어떻게 다루는지는 가변수 장에서 따로 배웁니다.
:::

"""

STEP_48 = r"""## 4~8단계: 모형 설정에서 사용까지 {.smaller}

### <i class="fa-solid fa-diagram-project"></i> 남은 다섯 단계를 이 자료에서 미리 보면

| Step | 단계 | 아이스크림 자료에서는 |
|:--:|:--|:--|
| 4 | 모형 설정 | $E(\text{IC}\mid x_1,x_2,x_3)=\beta_0+\beta_1x_1+\beta_2x_2+\beta_3x_3$ |
| 5 | 적합 방법의 선택 | 관측별 신뢰도에 차이가 없으므로 **통상최소제곱** |
| 6 | 모형 적합 | $\hat{\boldsymbol\beta}=(\mathbf X^\top\mathbf X)^{-1}\mathbf X^\top\mathbf y$ 로 계수 4개 추정 |
| 7 | 모형 검증과 비판 | 잔차 진단 후 `price` 제외($p=0.226$) $\to$ `IC ~ income + temp` |
| 8 | 선택된 모형의 사용 | 온도 65°F 에서 평균 소비량의 구간 추정 |

: The remaining five steps, previewed on the ice cream data

::: {.callout-important appearance="minimal"}
<ul>
<li>7단계에서 <code>price</code> 를 뺀 뒤 <b>4단계로 되돌아가</b> 모형을 다시 세움. 앞 그림의 <b>되먹임 고리</b>가 실제로 도는 자리</li>
<li>여기까지가 오늘 강의의 예고편. 각 단계에 필요한 도구를 하나씩 익히는 것이 남은 일곱 장의 일</li>
</ul>
:::

::: notes
자료를 확보했으니 남은 다섯 단계를 미리 훑어보겠습니다. 지금 이해하실 필요는 없습니다. 오늘 어디로 가는지 지도만 그려 두는 자리입니다.

4단계, 모형 설정입니다. 소비량의 평균을 기온과 가격과 소득의 일차식으로 적겠다고 정하는 일입니다. 표의 첫 줄이 그것입니다. 왼쪽이 조건부 기댓값, 오른쪽이 일차식. 앞에서 정의한 회귀를 이 자료에 맞춰 구체적으로 쓴 것뿐입니다.

5단계, 어떤 방법으로 맞출 것인가. 이 자료는 관측마다 신뢰도에 차이가 없습니다. 그래서 통상최소제곱을 씁니다. 만약 측정마다 정밀도가 다르다면 가중최소제곱을 쓰고, 그것이 가중회귀 장의 주제입니다.

6단계, 실제로 계수를 뽑습니다. 저 행렬식이 지금은 낯설겠지만 두 장 뒤면 익숙해지실 겁니다.

7단계가 오늘 강조하고 싶은 대목입니다. 만든 모형을 그대로 믿지 않고 뜯어봅니다. 이 자료에서는 가격의 유의확률이 0.226으로 나왔습니다. 가격이 소비량을 설명한다는 증거가 부족하다는 뜻입니다. 그래서 결국 가격을 뺐습니다. 그런데 변수를 뺐다는 것은 모형이 바뀌었다는 뜻이니, 4단계로 되돌아가 다시 세워야 합니다. 앞 그림에서 보신 주황 점선, 그 되먹임 고리가 실제로 도는 자리가 여기입니다.

8단계, 완성된 모형을 씁니다. 기온이 65도일 때 평균 소비량이 얼마쯤인지를 구간으로 답하는 일입니다. 하나의 숫자가 아니라 구간으로 답한다는 점을 기억해 두십시오.

정리하면 오늘 배울 모든 기법은 이 표의 어느 한 줄을 채우는 도구입니다. 길을 잃으셨다 싶으면 이 표로 돌아오시면 됩니다.
:::

"""

LSS_SLIDE = r"""## 실무 적용: 방사선 선량-반응 모형 선택 {.smaller}

### <i class="fa-solid fa-radiation"></i> 원폭 생존자 수명연구(LSS)

::: {.callout-tip appearance="minimal"}
<ul>
<li>포아송 회귀로 1 Gy당 <b>초과상대위험</b>(excess relative risk, ERR)을 추정. 방사선방호 선량한도의 근거 자료</li>
<li>고형암 발생 1958~2009년 자료: 대상 105,444명, 고형암 22,538건, 3.1백만 인년</li>
</ul>
:::

| 집단 | 가장 잘 맞는 모형 | 1 Gy 에서의 ERR | 95% 신뢰구간 |
|:--|:--|--:|:--|
| 여성 | 선형 | 0.64 /Gy | 0.52 ~ 0.77 |
| 남성 | 선형-이차 | 0.20 | 0.12 ~ 0.28 |

: Dose-response model selected for each sex in the Life Span Study

::: {.callout-important appearance="minimal"}
<ul>
<li><b>같은 자료, 같은 반응변수인데 집단을 나누면 세워야 할 모형이 달라짐</b></li>
<li>어느 모형을 고를 것인가가 이 장의 주제. 적합도만으로 정할 수 없고 진단과 정보기준을 함께 봄</li>
<li>선량한도라는 규제 값이 이 선택에 걸려 있음. 모형 선택이 행정 결정으로 이어지는 사례</li>
</ul>
:::

::: {.aside}
*Carcinogenesis* (2025), "Summary of radiation effects on incidence of solid cancers in the Life Span Study of atomic bomb survivors: 1958-2009".
:::

::: notes
이 장에서 배운 모형 선택이 현장에서 어떤 모습으로 나타나는지 한 가지만 보여 드리겠습니다. 원폭 생존자 수명연구입니다. 방사선방호에서 쓰는 선량한도의 근거가 이 자료입니다. 10만 5천 명을 1958년부터 2009년까지 추적해 고형암 2만 2천여 건을 관찰했습니다.

표를 보십시오. 여성은 선량과 위험이 직선 관계로 가장 잘 맞습니다. 1 그레이당 초과상대위험이 0.64, 신뢰구간은 0.52에서 0.77입니다. 그런데 남성은 직선이 아니라 선형-이차 모형이 더 잘 맞습니다. 1 그레이에서 0.20입니다. 같은 자료, 같은 반응변수인데 집단을 나누면 세워야 할 모형이 달라집니다.

여기서 오늘 배운 것이 필요해집니다. 어느 모형을 고를 것인가. 결정계수가 큰 쪽을 고르면 되는 것이 아니라는 점은 이미 보셨습니다. 잔차 진단으로 가정이 맞는지 보고, 정보기준으로 복잡도에 벌점을 물려 비교합니다. 마지막 줄이 무거운 대목입니다. 이 선택의 결과가 선량한도라는 규제 값으로 이어집니다. 모형을 고르는 일이 논문 안에서 끝나지 않는다는 뜻입니다.
:::

"""

# --------------------------------------------------------------- edits


def split_slides(text):
    """Return (preamble, [(title, block)]) split on level-2 headings."""
    lines = text.split("\n")
    idx = [i for i, s in enumerate(lines) if s.startswith("## ")]
    pre = "\n".join(lines[:idx[0]])
    out = []
    for k, i in enumerate(idx):
        j = idx[k + 1] if k + 1 < len(idx) else len(lines)
        out.append((lines[i][3:].strip(), "\n".join(lines[i:j])))
    return pre, out


def find(slides, prefix, expect=1):
    """Index of the slide whose title starts with prefix.

    `예제 자료: 아이스크림 소비량` appears twice (Introduction and Simple
    Linear Regression), so callers that mean the first one pass expect=2.
    """
    hits = [k for k, (t, _) in enumerate(slides) if t.startswith(prefix)]
    assert len(hits) == expect, "%r matched %d slides" % (prefix, len(hits))
    return hits[0]


def main():
    text = io.open(QMD, encoding="utf-8").read()
    pre, slides = split_slides(text)
    n0 = len(slides)

    # 1) drop the two field-case slides from Introduction
    for prefix in ["연구 현장의 사례 1", "연구 현장의 사례 2·3"]:
        del slides[find(slides, prefix)]

    # 2) replace the interim table slide with the two narrative step slides
    k = find(slides, "8단계의 적용: 아이스크림 자료")
    del slides[k]

    # 3) retitle the example-data slide as step 3 and move the walkthrough
    #    around it:  8단계 flowchart / 1·2단계 / 3단계 자료 / 4~8단계 / 구성표
    k = find(slides, "예제 자료: 아이스크림 소비량", expect=2)  # first = Introduction
    title, block = slides[k]
    block = block.replace(
        "## 예제 자료: 아이스크림 소비량 {.smaller}",
        "## 3단계 자료 수집: 아이스크림 자료 {.smaller}", 1)
    block = block.replace(
        "### <i class=\"fa-solid fa-table\"></i> 이 강의에서 반복해 쓰는 자료",
        "### <i class=\"fa-solid fa-table\"></i> 앞의 네 변수를 4주 단위로 30개 기간 수집", 1)
    slides[k] = ("3단계 자료 수집: 아이스크림 자료", block)

    # pull the mapping table out, then rebuild the run in the intended order
    m = find(slides, "8단계와 이 강의의 구성")
    mapping = slides.pop(m)
    k = find(slides, "3단계 자료 수집")            # index shifts after the pop
    slides[k:k] = [("1·2단계: 연구 질문과 변수 선택", STEP_12.rstrip("\n"))]
    slides[k + 2:k + 2] = [("4~8단계: 모형 설정에서 사용까지", STEP_48.rstrip("\n")),
                           mapping]

    # 4) the surviving three-case summary becomes a forward pointer
    k = find(slides, "세 사례의 공통 구조")
    t, b = slides[k]
    b = b.replace(
        "> 세 사례는 재료, 계측, 역학으로 분야가 다르지만 모두 설명변수가 주어졌을 때 "
        "반응변수의 조건부 기댓값 $E(Y \\mid X = x)$ 를 추정하는 문제이다.",
        "> 세 사례는 재료, 계측, 역학으로 분야가 다르지만 모두 설명변수가 주어졌을 때 "
        "반응변수의 조건부 기댓값 $E(Y \\mid X = x)$ 를 추정하는 문제이다.\n\n"
        "::: {.callout-tip appearance=\"minimal\"}\n"
        "세 사례는 해당 도구를 배우는 장의 **실무 적용** 슬라이드에서 자료와 수치를 갖추어 다시 다룸\n"
        ":::", 1)
    slides[k] = (t, b)

    # 5) the embrittlement case now lives only in Dummy Variable: carry over the
    #    two facts that the chapter slide did not yet state
    k = find(slides, "실무 적용: 원자로압력용기 조사취화 예측식")
    t, b = slides[k]
    b = b.replace(
        "<li>자료: 상용 원전 감시시험 1878건, 결정계수 $R^2 = 0.875$</li>",
        "<li>자료: 상용 원전 감시시험 1878건(13개국 감시시험 프로그램)</li>\n"
        "<li>방법: 최대가능도로 26개 모수를 적합. 적합도 RMSE 13.3 °C, "
        "결정계수 $R^2 = 0.875$</li>", 1)
    slides[k] = (t, b)

    # 6) the dose-response case moves into Diagnosis & Variable Selection,
    #    just before that chapter's closing slide
    k = find(slides, "자동 선택의 한계")
    slides[k + 1:k + 1] = [("실무 적용: 방사선 선량-반응 모형 선택",
                            LSS_SLIDE.rstrip("\n"))]

    out = pre + "\n" + "\n\n".join(b for _, b in slides) + "\n"
    io.open(QMD, "w", encoding="utf-8", newline="").write(out)
    print("slides %d -> %d" % (n0, len(slides)))
    for t, _ in slides[8:16]:
        print("   ", t)


if __name__ == "__main__":
    main()
