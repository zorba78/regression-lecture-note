---
name: eight-step-chapter-mapping
description: 회귀분석 8단계와 현행 7개 장의 대응표 (2026-08-13 7장 재편 반영)
type: project
date: 2026-08-13
---

DSSI 소개자료의 **회귀분석 8단계**(1 문제의 진술 / 2 관련 변수 선택 / 3 자료 수집 / 4 모형 설정 / 5 적합 방법 선택 / 6 모형 적합 / 7 모형 검증과 비판 / 8 모형의 사용)를 강의 전체를 꿰는 축으로 삼았다.

**대응이 놓인 자리**: 이전 설계처럼 장마다 callout으로 흩어 두지 않고, Introduction의 슬라이드 "회귀분석의 8단계 / 8단계와 이 강의의 구성" 표 **한 곳**에 모아 두었다(`quarto/agent/2026-08-13/regression-lecture-note.qmd` 306~320행). 장을 고칠 때 이 표를 함께 고쳐야 한다.

| Step | 단계 | 다루는 장 |
|:--:|:--|:--|
| 1~3 | 문제의 진술, 관련 변수의 선택, 자료 수집 | Introduction |
| 4 | 모형 설정 | Preliminary Knowledge (행렬 표현), Simple Linear Regression, Multiple Linear Regression, Dummy Variable |
| 5 | 적합 방법의 선택 | Simple Linear Regression (최소제곱), Weighted Regression (가중최소제곱) |
| 6 | 모형 적합 | Simple Linear Regression, Multiple Linear Regression |
| 7 | 모형 검증과 비판 | Diagnosis & Variable Selection |
| 8 | 선택된 모형의 사용 | Simple Linear Regression (구간추정), Multiple Linear Regression (예측) |

한 방향으로 흐르는 절차가 아니라 고리라는 점을 8단계 슬라이드와 "선택 후 재진단" 슬라이드에서 두 번 짚는다(7단계에서 문제가 드러나면 4단계로 되돌아간다).

**Why:** 사용자가 "슬라이드 맥락이 잡히지 않는다"고 지적했고 원인이 장들을 꿰는 서사 축의 부재였다. 장별 callout 방식은 2026-08-13 7장 재편(관련: [[lecture-chapter-structure]]) 때 표 한 장으로 통합되었다.

**주의:** Diagnosis & Variable Selection 장은 완전모형 진단 → AIC 변수선택 → 축소모형 재진단을 **한 장 안에서** 처리한다(축소모형 `IC ~ income + temp`, $R^2=0.702$, adj. $R^2=0.680$). 진단 대상이 완전모형뿐이라고 적혀 있던 이전 기록은 폐기했다. 관련: [[lecture-draft-progress]]
