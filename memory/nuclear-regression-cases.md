---
name: nuclear-regression-cases
description: 특강에 인용한 원자력·방사선 분야 회귀분석 실사례 3건과 출처
type: reference
date: 2026-08-13
---

제1장 "연구 현장으로" 슬라이드에 인용한 사례. 모두 웹 검색으로 확인했고 수치를 임의로 바꾸지 말 것.

**1. 원자로압력용기 조사취화 예측식 (ASTM E900-15)** — 반응변수는 중성자 조사에 따른 샤르피 41 J 천이온도 변화량(TTS). 양적 설명변수는 Cu·Ni·P·Mn 함량, 중성자 조사량(fluence)과 조사율(flux), 조사 온도. **질적 설명변수로 제품 형태(용접재·판재·단조재)를 지시변수 투입.** 상용 원전 감시시험 1878건(13개국, PLOTTER-BASELINE)에 최대가능도로 26개 모수 적합. RMSE 13.32 °C, $R^2=0.875$. → 제4장 다중회귀, 제9장 가변수, 제3장 $R^2$와 연결.
출처: ASTM E900-21e1; Metals 12(3), 481 (2022), doi:10.3390/met12030481

**2. 감마선 분광 효율 검교정** — 각 측정점의 분산이 계수 통계로 이미 알려져 있어 가중치를 추정하지 않고 $w_i=1/\sigma_i^2$로 계산. 분산이 알려져 있을 때 역분산 가중만이 최소분산 추정을 준다. → 제8장 가중회귀의 실제 근거.
출처: Analytical Chemistry 91(7) (2019), doi:10.1021/acs.analchem.9b00119; INMM Annual Meeting Proceedings

**3. 방사선 선량-반응 (원폭 생존자 수명연구 LSS)** — 포아송 회귀로 1 Gy당 초과상대위험(ERR) 추정, 방사선방호 선량한도의 근거. 고형암 1958~2009: 105,444명, 22,538건, 3.1백만 인년. 여성은 선형 모형 ERR 0.64/Gy (95% CI 0.52~0.77), 남성은 선형-이차 모형이 더 적합해 1 Gy에서 ERR 0.20 (95% CI 0.12~0.28). 같은 자료라도 집단에 따라 설정할 모형이 달라짐. → 제6장 모형 선택, 제3장 신뢰구간과 연결.
출처: Carcinogenesis (2025), "Summary of radiation effects on incidence of solid cancers in the Life Span Study of atomic bomb survivors: 1958-2009"

**Why:** 기존 "연구 현장" 슬라이드가 일반론(검교정·용량반응·성능저하)뿐이라 작위적이라는 지적을 받았다. 관련: [[lecture-draft-progress]]
