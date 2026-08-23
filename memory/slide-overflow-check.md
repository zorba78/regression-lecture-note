---
name: slide-overflow-check
description: revealjs 슬라이드의 가로·세로 레이아웃 초과를 자동 검출하는 방법과 함정
type: reference
date: 2026-08-13
---

렌더된 revealjs HTML에서 내용이 슬라이드(1280×1024) 밖으로 넘치는 곳을 자동으로 찾는 법.

1. 렌더된 HTML을 복사하며 **마지막 `</body>` 앞에만** 측정 스크립트를 주입한다. `str.replace` 전체 치환은 reveal 번들 내부 문자열의 `</body>`에도 들어가 JS를 깨뜨리므로 `rpartition('</body>')`을 쓸 것.
2. CSS로 모든 section을 강제로 보이게 한다(`display:block !important; position:relative !important; height:1024px !important`). 비활성 슬라이드는 `display:none`이라 그냥은 0으로 측정된다.
3. **MathJax 조판이 끝난 뒤에 재야 한다.** `MathJax.Hub.Queue(측정함수)`로 걸고 `--virtual-time-budget=180000`. 동기 실행하면 수식이 원시 텍스트로 잡혀 **거짓 양성**이 대량 발생한다(실제로 9건 중 5건이 허위였음).
4. **세로만 재면 안 된다.** display 수식은 줄바꿈이 없어 가로로 잘려 나가는 사고가 더 흔하다. `getBoundingClientRect().right - section.left` 도 함께 잰다.
5. 가로 측정에는 **약 44~65px의 공통 기준선**이 있다(모든 슬라이드에 나타남). 그보다 큰 값만 실제 문제다.
6. 명령: `chrome --headless=new --no-sandbox --disable-gpu --window-size=1280,2000 --virtual-time-budget=180000 --dump-dom <file> > dom.html`

**2026-08-23 추가: 이 방식이 실패하는 지점.** 슬라이드가 151장으로 늘어난 뒤로는 위 1~3번(모든 section을 CSS로 강제 표시 + 타이머 측정) 방식이 **동작하지 않는다.** 측정 스크립트 자체는 실행되지만(단순 마커는 3초 타이머로 정상 삽입됨), 151개 section을 전부 `display:block; height:1024px`로 펼치면 레이아웃이 너무 무거워 Chrome이 콜백 완료 전에 `--dump-dom` 을 뱉는다. 6장씩 나눠 측정하는 청크 방식도 같은 결과였다. `getBoundingClientRect()` 전수 순회 대신 `document.createRange().selectNodeContents(section).getBoundingClientRect()` 로 section당 1회 호출로 줄여도 마찬가지.

**대안(실제로 쓴 방법):** 변경이 집중된 슬라이드만 골라 스크린샷으로 눈으로 확인한다. revealjs 세로 스택 구조이므로 URL 조각은 `#/h/v` 형식이고, **h = 장 번호 + 1**(예: `#/2/1` = Introduction 첫 슬라이드, `#/2/20` = Introduction 마지막). 명령은 [[tooling-paths-windows]]의 스크린샷 항목 참조. 전수 자동 검사가 필요하면 측정 스크립트를 페이지에 넣지 말고 CDP(Playwright 등)로 슬라이드를 실제 이동시키며 재는 방식을 검토할 것.

**해소 방법:** 슬라이드 분할(제목에 부제를 달아 분화. **H2를 그대로 반복하지 말 것** — [[slide-flow-devices]]), `## 제목 {.smaller}`, 긴 수식은 `\begin{aligned}` 으로 줄 나누기, 좁은 column 안에 display 수식을 넣지 않기.

**함정:** qmd에 `aligned` 줄바꿈을 쓸 때 **백슬래시 두 개가 실제로 파일에 들어갔는지 확인할 것.** Python 문자열 이스케이프로 하나만 들어가면 줄바꿈이 통째로 무시되어 한 줄로 붙어 버린다. `\\[2pt]` 같은 간격 지정은 pandoc을 거치며 깨지므로 쓰지 말 것. 관련: [[tooling-paths-windows]]
