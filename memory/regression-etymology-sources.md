---
name: regression-etymology-sources
description: 회귀(regression) 명칭의 유래 — reversion에서 regression으로 바뀐 경위와 검증된 출처
type: reference
date: 2026-08-24
---

사용자가 2026-08-24에 유튜브 영상 <https://www.youtube.com/watch?v=7dSeRugfxj8> (채널 @data_chopsticks, "근데 도대체 '회귀'는 무슨 뜻일까?")을 유래 설명 자료로 지목. **자막·설명 추출은 불가**(WebFetch는 제목만, `api/timedtext`는 빈 응답). 그래서 아래 사료로 대체해 Introduction 장 노트 3곳에 반영했다.

**확인된 사실 (Gorroochurn 2016, Stanton 2001 기준)**

- **1877** Galton, "Typical laws of heredity": 완두콩 씨앗을 무게 7등급으로 나눠 친구 7명에게 등급별 10알씩 봉지 7개 발송. 용어는 **reversion**(=격세유전/atavism, 다윈이 먼저 제안한 유전 개념). 기호 `r` 는 원래 "coefficient of reversion". 이때 골턴은 이를 **한 방향의 유전 과정**으로 이해. 발견한 것은 그 과정이 **선형**이라는 점.
- **1885** British Association 인류학 분과 회장 강연: **여기서 regression 이 처음 등장.** 자녀→부모 방향으로도 같은 효과가 일어남을 발견해 대칭·비유전 현상임을 깨닫고 용어를 갈아치움. 골턴 본인 회고 "I was then [in 1877] blind to what I now perceive to be the simple explanation". 205가족, 어머니 키×1.08 후 평균해 mid-parent 생성, mid-parent와 자녀 중앙값 모두 68.25 inch, probable error 1.2(부모)·1.7(자녀), 눈대중 적합 기울기 **2/3**. 법칙: "the height-deviate of the offspring is, on the average, two-thirds of the height-deviate of its mid-parentage". 포도주에 물 붓기 비유(원 도수와 무관하게 같은 비율로 묽어짐).
- **1886** "Regression towards mediocrity in hereditary stature", J. Anthropological Institute 15, 246-263: 성인 자녀 928명 / 205가족. **제목에 regression이 있어 흔히 출발점으로 소개되나 용어는 1885년이 먼저다** — 덱의 기존 노트가 "1886년에 처음 썼다"고 잘못 적어 있어 수정했다.
- **1896** Pearson의 첫 엄밀한 상관·회귀 처리(적률 방식). 이때부터 `r` 이 상관계수를 뜻하게 됨. "standard deviation" 은 Pearson(1894)의 조어.
- mediocrity = 비하가 아니라 **모집단 평균**.

**강의에서 쓰는 논점**: 회귀라는 이름은 골턴이 **스스로 폐기한 가설**(유전이 한 방향으로 미는 힘)의 흔적일 뿐이며, 현대 회귀분석에서 평균으로 되돌아가는 것은 없다. 하는 일은 $E(Y\mid X=x)$ 추정. 덱의 핵심 프레이밍과 직결.

**골턴 2/3 vs 덱의 0.51**: 서로 다른 회귀다. 2/3은 mid-parent를 설명변수로, 0.51은 아버지 한 명만. 상관으로 환산하면 $(2/3)\times(1.2/1.7)=0.471$ 대 0.51 로 비슷함(정규분포에서 probable error = 0.675 SD 이므로 비율이 SD 비율과 같다).

**출처 URL**
- Gorroochurn (2016) *The American Statistician* 70(2), 227-231, doi:10.1080/00031305.2015.1087876 — PDF 본문은 <http://www.columbia.edu/~pg2113/index_files/Gorroochurn-On%20Galton's%20Change.pdf> 에서 `pdftotext` 로 추출 성공. 관련: [[tooling-paths-windows]]
- Stanton (2001) *Journal of Statistics Education* 9(3) — <https://jse.amstat.org/v9n3/stanton.html>

관련: [[lecture-draft-progress]], [[no-r-code-theory-first]]
