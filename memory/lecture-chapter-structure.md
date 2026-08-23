---
name: lecture-chapter-structure
description: 사용자가 지정한 최종 장 구성(영문 장 제목)과 배치 원칙
type: feedback
date: 2026-08-13
---

사용자 지시(2026-08-13): 슬라이드가 일반적인 회귀분석 강의 구성을 따르지 않아 가독성이 떨어진다. 장을 아래 영문 제목으로 나눌 것.

1. **Introduction**
2. **Preliminary Knowledge** — 행렬 표기는 여기로 분리. 정규분포·t분포·p-value 설명도 여기.
3. **Simple Linear Regression** — 공분산, 상관계수, 회귀계수의 관계 슬라이드 필수.
4. **Multiple Linear Regression** — 모자행렬(hat matrix, projection 행렬) 개념 슬라이드 필수.
5. **Diagnosis & Variable Selection** (진단과 변수선택을 한 장으로)
6. **Weighted Regression**
7. **Dummy Variable**

**추가 지시:**
- 사례분석(구 제7장)은 별도 장을 두지 않고 **각 장에 예제로 흡수**한다.
- 예제 데이터를 소개할 때 **데이터 구조를 테이블로** 보인다(전체가 아니라 앞 몇 행만).
- **출처 표기 제거**: 그림·표 아래의 "Computed by code/agent/..." 줄을 없앤다. **R 코드 블록은 유지**한다.
- em dash 사용 자제. 표의 결측 자리표시자 `--` 는 pandoc이 en dash로 바꾸므로 쓰지 말 것.
- "강의의 척추" 같은 어색한 조어 금지.
- **청중은 통계 지식이 거의 없다고 가정**한다. p-value, t분포, 정규분포를 설명 없이 쓰지 말 것.

참고자료: 공분산·상관계수는 `[회귀분석]2.단순선형회귀모형.pdf`와 `제3장. 단순선형회귀분석.pdf`. 관련: [[slide-register-rule]], [[lecture-draft-progress]]
