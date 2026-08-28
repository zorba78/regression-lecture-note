---
name: gls-example-lakehuron
description: 06장 GLS 예제는 Lake Huron 수위 자료. 아이스크림 자료는 자기상관이 약해 기각됨
metadata:
  type: project
---

06장(Weighted Regression)의 GLS 예제는 **`datasets::LakeHuron`**(1875–1972 연간 수위, n=98)이다. `level ~ year` 추세 추정에서:

- DW = 0.4395, exact $p$ = 1.0e-22, 잔차 ACF lag 1–3 = 0.762 / 0.464 / 0.261
- $\hat\rho$ 세 방법이 일치: Cochrane-Orcutt 0.768, ML 0.783, REML 0.825 (폭 0.056)
- OLS 기울기 −0.024201 (SE 0.004036, $p$ = 3.5e-8) → GLS −0.019435 (SE 0.012664, $p$ = 0.128). **SE 3.14배, 결론이 뒤집힘**
- $\rho=0$ 가능도비 $\chi^2_1$ = 89.6, $p$ < 0.0001

**아이스크림 자료로 먼저 만들었다가 사용자가 기각했다(2026-08-28).** 이유: 자기상관이 약하고($\hat\rho$ CO 0.406 vs ML 0.723) 추정 방법에 따라 답이 갈려 GLS가 억지스러워 보임. 후보 6종을 실측 비교한 결과 LakeHuron이 DW·$\rho$ 일치도·SE 증가폭 모두에서 가장 명확했다. 다른 후보: faraway::globwarm(DW 0.817, SE 1.7~1.8배), wooldridge::phillips(계수 부호 반전), prminwge, longley(SE 오히려 감소).

**교훈**: 예제는 효과가 뚜렷하고 추정 방법이 달라도 같은 답을 주는 자료로 고를 것. 후보를 여러 개 실측해 비교한 뒤 고르는 편이 빠르다.

스크립트: `code/agent/2026-08-28/gls-lakehuron-autocorrelation.R`(손계산 GLS = `nlme::gls` 2.7e-10 이내 대조 포함). 그림: `output/agent/2026-08-28/fig-m06-gls-lakehuron.png`. 기각된 아이스크림 분석은 `code/agent/2026-08-28/gls-icecream-autocorrelation.R` 에 남겨 둠(기각 근거). 관련 [[ice-data-year-variable]], [[slide-layout-system]].
