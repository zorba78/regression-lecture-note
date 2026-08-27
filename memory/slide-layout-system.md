---
name: slide-layout-system
description: 8개 덱의 슬라이드 배치는 lecture.css로 정한다. A는 정의 밴드뿐이고 바닥 고정은 선택형 .pin. vh 단위 금지
type: project
date: 2026-08-27
---

**배치는 `quarto/agent/2026-08-13/assets/css/lecture.css` 한 곳에서 결정된다.** 8개 덱이 모두 이 파일을 YAML `css:` 로 불러오므로, 여기를 고치면 168장 전부에 즉시 반영된다.

| | 클래스 | 하는 일 | 적용 |
|:--|:--|:--|:--|
| A | 없음(기본) | 정의 인용구를 틴트 밴드로. **그게 전부** — 슬라이드는 브라우저 기본 블록 배치 | 전부 |
| A' | `.pin` | 전체 높이 flex 열 + 마지막 콜아웃을 바닥에 고정 | **선택형.** 02장 직교벡터·멱등행렬·신뢰구간 3장 |
| B | `.rail` | 좌측 레일(정의) / 우측(확인)을 전체 높이로 | 전치, 대각합 |
| C | `.fig-led` | 그림이 콘텐츠 폭 전부를 차지 | 그림이 단독인 8장 |
| D | `.stepped` | `<ol>`에 번호 레일 + 마지막 콜아웃을 짙은 결론 띠로 | 03장 최대가능도 유도 |

**A'는 2026-08-27에 덱 전체 기본값으로 넣었다가 같은 날 철회했다.** 사용자가 실제 화면에서 "레이아웃이 엉망"이라고 지적했고, 측정해 보니 지적된 5건 중 4건의 원인이었다. 기본으로 되돌리지 말 것.

## 절대 다시 밟지 말 것

**1. 슬라이드 안에서 `vh`를 쓰지 말 것.** 가장 비싸게 배운 것. reveal은 YAML의 1280×1024 캔버스에 그린 뒤 창 크기에 맞춰 transform으로 확대하므로, 슬라이드 안의 `vh`는 캔버스가 아니라 **브라우저 창**을 기준으로 계산된다. 02 대각합의 `min-height: 72vh` 레일 실측: 창 1280×1024에서 슬라이드의 69.8%, 1600×1280에서 85.7%, 2400×1920에서 86.4% — 큰 모니터에서는 화면 밖으로 흘러넘친다. **1024px 캔버스 기준 px로 쓸 것**(60vh→614px, 50vh→512px, 46vh→471px, 72vh→737px). 이 때문에 **1280×1024 한 크기로만 검사하면 안 된다** — 하필 그 크기가 vh가 우연히 맞는 유일한 지점이다. [[slide-overflow-check]]

**2. flex 컨테이너는 자식 간 세로 여백을 상쇄하지 않는다.** A'의 근본 비용. 인라인 `margin-top: 1em; margin-bottom: 1em`을 단 콜아웃이 연달아 있으면 블록에서는 경계마다 1em, flex에서는 2em. 결과는 두 가지로 나타난다 — 이미 꽉 찬 슬라이드는 **잘리고**(01 Galton 자료 적합: 바닥 잉크 0→6072, flex만 끄면 다시 0), 여유 있는 슬라이드는 **블록 간격이 벌어져** 엉성해 보인다(01 변수의 유형). flex 안에서 여백 상쇄를 요구하는 CSS 방법은 없다.

**3. `margin-top: auto`는 남는 공간을 전부 먹는다.** `flex-grow`보다 먼저다. 두 가지 사고를 냈다 — `.rail`에서 기둥이 바닥까지 자라지 못했고(그래서 `min-height`로 직접 지정), 고정된 콜아웃이 **절대위치로 놓인 출처 `<aside>` 위에 올라탔다**(02 회귀모형의 행렬 표현). Quarto의 `::: aside`는 `<aside>` 태그로 나오며 슬라이드 하단에 절대위치로 붙는다. 그래서 `.pin`은 `:not(:has(> aside:not(.notes)))`로 그런 슬라이드를 아예 제외한다.

**4. `.present`로 한정해야 한다.** reveal은 `section.present { display: block }`으로 슬라이드를 보이고 감춘다. 그냥 `display: flex`를 주면 `display: none`을 이기면서 **모든 슬라이드가 한꺼번에 보인다.** PDF는 `html.print-pdf`로 따로 한 벌.

**5. `r-stretch`가 CSS를 이긴다.** Quarto는 그림이 하나뿐이면 `class="r-stretch"`를 붙이고 reveal이 JS로 인라인 `height`를 박는다. `.fig-led` 그림에는 `{... .nostretch}`를 반드시 같이 쓸 것.

**6. 폭은 서두를 줄여야 넓어진다.** 최대가능도 슬라이드에서 제목+정의+도입문이 440px를 먹어 그림에 429px만 남았고, 그 높이로는 폭이 948px — 원래 940px과 차이가 없었다. `.fig-led`가 h3·인용구·문단 여백을 줄이는 규칙을 함께 갖는 이유다.

**7. Quarto는 `.callout-body-container` 를 만들지 않는다.** `.stepped` 결론 띠의 글자 크기·여백 규칙이 그 클래스를 겨냥해 계속 무시되고 있었다(렌더 결과에서 0회, `.callout-body` 는 30회). 콜아웃 내부 구조는 `div.callout > div.callout-body > div.callout-content > p`.

**8. 콜아웃 안에서 `text-align: center` 가 안 먹는 이유는 flex 아이템이 안 늘어나기 때문이다.** `div.callout` 과 `.callout-body` 가 **둘 다 `display: flex`** 라서 `.callout-body` 와 `.callout-content` 는 flex 아이템이고, grow 계수가 없으면 각각 자기 내용 폭까지만 줄어든다(2026-08-28 측정: 1045.1px 띠 안에서 265.7px). `text-align: center` 는 내내 적용되어 있었지만 그 좁은 상자 안에서 가운데 정렬 중이었고, 상자 자체가 띠 왼쪽에 붙어 있었다. 해법은 **두 단계 모두**에 `flex: 1 1 auto`. MathJax와는 무관하다 — 2026-08-27에 "MathJax가 자체 컨테이너로 조판해서"라고 적었던 진단은 틀렸다. 이런 증상은 추측하지 말고 렌더된 페이지에 측정 스크립트를 주입해 `getComputedStyle` + `getBoundingClientRect` 를 직접 읽을 것([[slide-overflow-check]]).

**`.pin` 후보**: 여유 200px 이상 + 콜아웃으로 끝남 + 출처 aside 없음 = 56장. 목록은 스크래치패드 `profile-*.csv`로 재생성 가능. 지금은 승인 근거에 명시된 3장에만 붙였다.

**tabset 전면 폐지(2026-08-27)**: revealjs tabset은 활성 탭만 보이므로 **PDF로 내보내면 나머지 탭이 사라진다.** 발표 요청자가 PDF를 요구할 수 있다는 이유로 16개를 모두 해제했다. 다시 넣지 말 것. 해제 방법과 결과는 [[tabset-removed-for-pdf]].

**되돌리기**: `lecture.css.bak-2026-08-27`(레이아웃 도입 직전), `lecture.css.layout-2026-08-27`(A' 기본값 시절), `lecture.css.pxfix`(vh 수정 직후). 아트보드는 `output/agent/2026-08-27/design/`.

관련: [[slide-overflow-check]], [[chapter-split-decks]], [[respect-user-edits]]
