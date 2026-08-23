---
name: regression-uncertainty-content
description: 특강에 회귀계수 불확도(표준오차, Gauss-Markov 정리 등) 이론을 상세히 포함하라는 요청
type: feedback
date: 2026-08-12
---

사용자 요청(2026-08-12): 특강에 이론적 내용을 더 넣을 것. 특히 **회귀계수의 불확도 정량화**를 상세히: 회귀계수의 표집분포, $\mathrm{Var}(\hat\beta)=\sigma^2(\mathbf X^\top\mathbf X)^{-1}$, 표준오차, Gauss-Markov 정리(BLUE), 신뢰구간, (가중회귀 연계로) 이분산 하에서 OLS가 BLUE가 아님(Aitken 정리) 등.

**How to apply:** 제3~4장 사이에 불확도 전용 섹션을 두거나 제3장을 대폭 확장. `references/ust-lecture-note/07-sampling-distribution.qmd`(본인 제작 표집분포 강의)와 연결되는 전개 사용. 관련: [[slide-level-feedback]]
