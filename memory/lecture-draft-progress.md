---
name: lecture-draft-progress
description: 회귀분석 특강 슬라이드의 내용 이력과 산출물 위치 (정본·슬라이드 수는 chapter-split-decks 참조)
type: progress
date: 2026-08-24
---

**정본은 장별 덱 8개** `quarto/agent/2026-08-26/01-introduction.qmd` ~ `08-summary.qmd` 이며 렌더본은 같은 폴더의 `.html` 이다. 아래 기록은 **2026-08-26 분할 이전의 통합본 기준**이므로, 슬라이드 위치·개수는 현재와 다르다. 내용 이력으로만 읽을 것. 분할 규칙은 [[chapter-split-decks]].

**분할 이전 통합본(2026-08-24 R 제거·이론 강화, 동결)**: 원본 `quarto/agent/2026-08-13/regression-lecture-note.qmd` (276 KB), 렌더본 `presentation/regression-lecture-note.html` (5.7 MB). 정비 직전 백업은 같은 폴더의 `regression-lecture-note.qmd.bak-before-style-pass`.

- **구성**: 8개 장 순서는 [[lecture-chapter-structure]]. **슬라이드 수는 적어 두지 말고 셀 것** — 세는 명령과 실측 이력은 [[chapter-split-decks]]. (분할 이전 통합본의 마지막 값은 152였고, 2026-08-29 장별 덱 합계는 211이다.)
- **강의 대본**: 전 슬라이드에 `::: notes` 수록(2026-08-29 장별 덱 212건 확인).
- **2026-08-24 추가 2**: (1) Weighted Regression에 **감쇠 곡선 예제 4장** 신설(기관 관심사). Beer-Lambert 로그선형화 + Poisson 델타법으로 $w_i=N_i$ 유도, 분산 143배 확대, OLS 대비 WLS 분산 4.3배 감소, 저계수에서 Poisson GLM으로 넘어가는 경계. 그림·수치는 `code/agent/2026-08-24/make-attenuation-figures.R`. (2) Galton 그림 4종을 실제 자료로 교체 — [[galton-real-data]].
- **2026-08-25 추가**: Simple Linear Regression에 **최소제곱법의 타당성 2장** 신설(DSSI 강의노트 2장 25쪽 `Comparison of Lines` 요청). `후보 직선 비교: 어떤 직선이 최적인가`(무수한 후보 + 임의 직선의 잔차 $r_i$ 정의 + 기준의 필요성), `기준의 비교: 왜 제곱합인가`(네 직선 × 세 기준 채점표). 그림·수치는 `code/agent/2026-08-25/make-ls-rationale-figures.R`, 그림은 `output/agent/2026-08-25/fig-ls01`, `fig-ls02`. 자료는 기존 `최소제곱 기준` 슬라이드와 같은 CNU 3장 예제 3.1(n=10)이라 같은 산점도가 세 장에 이어짐. 검증 수치: 평균점을 지나는 직선은 $\sum r_i=0$ 이 항등적으로 성립(직선 B와 OLS가 동점), $\sum\lvert r_i\rvert$ 최소는 L1 직선 6.25(전 점쌍 완전탐색 + 격자탐색 이중 확인), $\sum r_i^2$ 최소는 OLS 9.38. **기준이 바뀌면 최적 직선도 바뀐다**가 이 두 장의 결론.
- **함께 고친 기존 결함(2026-08-25)**: `최소제곱 기준` 슬라이드의 핵심 수식 $\min\sum(y_i-eta_0-eta_1x_i)^2$ 이 오른쪽으로 잘려 **제곱 지수가 안 보이던 문제**를 제목에 `{.smaller}` 를 붙여 해결. 내 변경이 만든 문제가 아니라 이전부터 있던 것이며, 캡처 확인 중 발견.
- **2026-08-24 정비 내용**: R 코드 제거 자리에 이론을 채움 — 모자행렬 3성질(대칭·멱등·대각합)의 대수적 증명, 잔차의 대수적 성질(X'e = 0, Var(e_i) = sigma^2 (1 - h_ii), 잔차 자유도 26), 단순회귀 손계산 사슬(S_xx 에서 t = 6.50 까지), 신뢰·예측구간 수치 비교(temp = 65에서 반너비 0.0222 대 0.0893), VIF 유도표, AIC 정규오차 전개, AIC와 AIC*의 상수차 87.136, WLS/GLS 행렬식, AR(1) 오차 공분산행렬, 2×2 역행렬 검산, 상호작용 모형식.
- **2026-08-23 정비 내용**: (1) 본문 산문을 개조식으로 전환, 정의·정리 blockquote만 완결 문장 유지, (2) 노트의 `죠.` 238건 → 0건 등 어투 리듬 재작성, (3) 반복 H2 36그룹(80장)을 부제로 분화해 연속 반복 0, (4) 전 장에 브리지 callout·`이 장의 정리`·다음 장 예고 추가. 규칙은 [[slide-register-rule]], [[slide-flow-devices]].
- **함께 고친 사실 오류**: 5장 첫 슬라이드(Anscombe)에 변수선택 결과인 축소 모형식 `-0.113 + 0.00353 income + 0.00354 temp`가 잘못 들어가 있어 제거. 이 식은 같은 장의 "선택 후 재진단" 슬라이드에만 있어야 한다.
- **줄바꿈**: CRLF 2,529 + LF 1,331 혼재였던 것을 **LF로 통일**(정확 일치 치환이 계속 깨져서). 내용 변화 없음.
- **개념적 중심**: 회귀 = 조건부 기댓값 $E(Y\mid X=x)$. 절차 축은 회귀분석 8단계이며 대응표는 Introduction에 한 장. 관련: [[eight-step-chapter-mapping]]
- **R 코드 없음(2026-08-24)**: 코드블록 17건과 R 흔적(함수명·물결표 문법·출력 열 이름·패키지명)을 **전부 제거**하고 그 자리를 수식 유도로 대체. 규칙은 [[no-r-code-theory-first]]. 렌더본의 `sourceCode` 블록 0건으로 확인. 수치는 원자료(`references/.../7장/ice.csv.csv`, n=30)로 전량 검산 완료.
- **그림**: 참조 18건 전부 존재. `output/agent/2026-08-11/` fig01~08, `output/agent/2026-08-13/` fig-i01~i05, fig-p01~p05. 생성 스크립트는 `code/agent/` 아래 날짜 폴더.
- **오프라인 안전**: 렌더본의 외부 http 참조 **0건** 재확인(2026-08-23). 폐쇄망에서도 수식·아이콘·그림 정상 표시.
- **2026-08-24 추가**: (1) Preliminary Knowledge에 `카이제곱분포`·`F분포` 2장 신설 — 정규분포에서 세 분포가 파생되는 계보를 명시. 그림은 `output/agent/2026-08-24/fig-p06-chisq.png`, `fig-p07-f-distribution.png`(생성 스크립트 `code/agent/2026-08-24/make-chisq-f-figures.R`). (2) Multiple Linear Regression에 `제곱합의 분해`(교차항이 0이 되는 유도 + 자유도 분해)·`회귀분산분석표` 2장 신설. `모형 전체의 유의성: F 통계량`에 F의 분포와 R^2 표현 추가. 검증 수치: SST 0.126 = SSR 0.0902 + SSE 0.0353, df 3+26=29, MSR 0.0301, MSE 0.00136, F 22.1, p 2.5e-07, F(3,26) 5% 임계값 2.98, 단순회귀 t 6.50의 제곱 42.3 = F.
- **남은 일**: (1) 사용자 검토, (2) 현재 슬라이드 수 기준 강의 시간 배분 점검. 관련: [[slide-level-feedback]], [[ice-data-year-variable]]
