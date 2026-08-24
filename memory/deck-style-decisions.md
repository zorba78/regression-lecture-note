---
name: deck-style-decisions
description: 슬라이드 스타일 구성 — 어떤 파일이 무엇을 담당하며, 참조 덱에서 무엇을 가져오고 무엇을 버렸는지
type: project
date: 2026-08-24
---

**파일 역할** (`quarto/agent/2026-08-13/assets/css/`)

- `monash.scss` — 테마 변수(배경·본문색·링크색)만. `theme: [simple, assets/css/monash.scss]`
- `lecture.css` — 이 덱 전용 오버라이드. 제목 스케일, 표, 수식, callout, aside. **가장 마지막에 로드되므로 여기 쓴 규칙이 이긴다**
- `custom.css` — 타이틀 슬라이드 타입 스케일과 미사용 유틸(.box/.info-box/.circle/.story)
- `syntax-highlight.css` — 코드 하이라이트(현재 코드블록 0건이므로 실질 미사용)

**2026-08-24: `references/obesity-pulse-presentation/custom.scss` 부분 이식**

가져온 것 (모두 `lecture.css` 하단, 주석으로 출처 명시):
- 한글 폰트 스택 `"Noto Sans KR", "Malgun Gothic", "Apple SD Gothic Neo", sans-serif`
- H2: 색 `#14324a` + 아래 3px `#3b9ab2` 밑줄
- 표: 헤더 진남색 배경/흰 글자, 셀 hairline 테두리, 짝수행 `#f4f7f9` 줄무늬
- `.reveal .columns { gap: 1.2em }`, `figcaption { font-style: italic }`

**버린 것과 이유** (다시 가져오지 말 것):
- `$presentation-font-size-root: 26px` 및 h1/h2/h3 크기 — 참조 덱은 1280×720, 이 덱은 **1280×1024**이며 타입 스케일은 `lecture.css` 상단에서 이미 조정됨
- `.reveal table { font-size: 0.66em; width: 100% }` — 이 덱의 넓은 결과표용 설정이 이미 있음
- `.small / .smaller / .muted / .center-text` — **`.smaller`는 Quarto 내장 클래스이고 이 덱에서 61회 사용**. 0.68em으로 재정의하면 61장이 한꺼번에 축소됨
- 연구 전용 클래스 15종(`.ctrl/.gyn/.andr`, `.badge`, `.banner`, `.card`, `.tone-*`, `.chip`, `.phenotype-card`, `.body-fig`, `.col-head`, `.sig/.nonsig` 등) — 이 덱에서 사용처 0

**주의 1 — 폰트는 SCSS 변수로 안 먹는다.** 참조 덱은 `theme: [default, custom.scss]`라 `$font-family-sans-serif`가 통하지만, 이 덱의 `simple` 테마는 `'Source Sans Pro'`를 고정한다. 반드시 `lecture.css`에 일반 CSS 규칙으로 쓸 것. 웹폰트 `@import`는 절대 넣지 말 것(폐쇄망).

**주의 2 — 스타일 변경은 레이아웃을 깨뜨린다.** H2 밑줄로 상단이 약 12px 늘고 한글 폰트가 넓어져, 이식 후 2장이 깨졌다. `일반화최소제곱(GLS): WLS와의 관계`(세로 빠듯), `예제 physics 자료: 추정 결과`(WLS 식 가로 잘림). 둘 다 제목에 `{.smaller}`를 붙여 해결. 앞으로 전역 스타일을 건드리면 `{.smaller}` 없는 장문 슬라이드부터 캡처해 확인할 것. 관련: [[slide-overflow-check]]

**외부 참조**: 로드되는 외부 리소스는 0. 다만 타이틀 슬라이드에 YAML `orcid:` 에서 생성된 하이퍼링크 `https://orcid.org/...` 가 1건 있다. 클릭할 때만 나가는 링크라 폐쇄망 표시에는 영향 없음. 완전히 0으로 만들려면 YAML의 `orcid:` 를 지울 것.
