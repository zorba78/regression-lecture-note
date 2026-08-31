---
name: fig-led-caption-maxheight-trap
description: .fig-led 슬라이드에서 그림에 인라인 max-height를 주면 캡션이 아래 콜아웃 위로 겹쳐 그려진다
metadata:
  type: project
date: 2026-08-31
---

`.fig-led` 슬라이드의 그림에 `![...](...){width=100% .nostretch style="max-height: 520px"}` 처럼 인라인 스타일을 주면, Quarto는 그 `style` 을 **`<img>` 가 아니라 감싸는 `<div class="quarto-figure">` 에 붙인다.** 그 div에는 `overflow` 설정이 없으므로 레이아웃 높이만 520px로 잘리고, 실제로 그려지는 `img`(CSS `.fig-led img { max-height: 512px }`) + `figcaption` 은 그 밖으로 삐져나온다. 결과적으로 **캡션이 바로 아래 콜아웃 박스 위에 겹쳐 인쇄된다.** slidecheck의 clipped/overflow 판정에는 잡히지 않으므로 스크린샷을 봐야 발견된다.

- 그림 크기는 `lecture.css` 의 `.reveal .slides section.fig-led img { width:100%; height:auto; max-height:512px }` 가 이미 정한다. **인라인 `style` 을 쓰지 말 것.**
- 굳이 wrapper에 값을 준다면 `512px + 캡션 높이` 보다 커야 한다(기존 `최소제곱법: 해의 성질` 슬라이드의 `max-height: 620px` 가 그래서 무사하다).
- `.fig-led` 를 빼면 기본 규칙 `.reveal .slide img { max-height: 614px }` 가 적용되어 그림이 약 20% 커지지만, 제목 + 소제목 + 캡션 + 콜아웃이 함께 있는 슬라이드에서는 **clipped 판정이 난다**(2026-08-31 deck 03 `상관계수: 값과 산점도` 에서 실측: last_row=1020).

## 614px 상한을 넘겨 그림을 키우는 법

그림만 있는 슬라이드를 화면에 꽉 채우려면 `.reveal .slide img { max-height: 614px }` 를 넘어서야 하는데, 마크다운 `![](...){...}` 로는 안 된다. **인라인 `style` 은 감싸는 div로 가고, `{height=NNN}` 로 준 `height` 는 스타일시트의 `max-height` 에 다시 걸린다.** 공용 CSS를 건드리지 않는 방법은 그 슬라이드에서만 **raw `<img>`** 를 쓰는 것이다(덱은 이미 `<ul>`·`<li>`·`<i>` 를 본문에 직접 쓴다).

```html
<img src="../../../output/agent/2026-08-31/fig-p08-correlation-types.png" class="nostretch"
     style="display: block; width: 100%; max-height: 780px; margin: 0 auto">
```

- `max-height` 를 **명시해야** 한다. 빼면 스타일시트의 614px가 다시 적용된다.
- 제목 + 소제목이 약 190px를 쓰므로 **780px가 실용 상한**이다(2026-08-31 deck 03 `상관계수: 산점도와 상관계수` 에서 clipped 0으로 확인). 그 이상 키워도 콘텐츠 폭 1152px가 걸려 `object-fit: contain` 이 letterbox 처리하므로 실익이 없다.
- raw `<img>` 는 `<figure>`/`<figcaption>` 을 만들지 않으므로 캡션이 필요 없는 슬라이드에만 쓸 것.

관련: [[slide-layout-system]], [[slide-overflow-check]]
