---
name: lecture-draft-progress
description: 회귀분석 특강 슬라이드 현황과 산출물 위치 (2026-08-13 7장 재편본)
type: progress
date: 2026-08-13
---

**현행본(2026-08-13 7장 재편)**: 원본 `quarto/agent/2026-08-13/regression-lecture-note.qmd` (271 KB), 렌더본 `presentation/regression-lecture-note.html` (6.0 MB). 두 파일의 수정시각이 8초 차이(14:12:51 → 14:12:59)이므로 동기 상태. 2026-08-12 디자인본은 `presentation/regression-lecture-note_2026-08-12-previous-design.html` 로 보존.

- **구성**: 총 **139 슬라이드**. Introduction 19 / Preliminary Knowledge 15 / Simple Linear Regression 20 / Multiple Linear Regression 28 / Diagnosis & Variable Selection 18 / Weighted Regression 17 / Dummy Variable 13 / Summary 9. 장 제목은 영문, 사례분석 전용 장은 두지 않는다(각 장 예제로 흡수). 관련: [[lecture-chapter-structure]]
- **강의 대본**: `::: notes` 147건(장 표지 포함, 전 슬라이드 수록).
- **개념적 중심**: 회귀 = 조건부 기댓값 $E(Y\mid X=x)$. 절차 축은 회귀분석 8단계이며 대응표는 Introduction에 한 장으로 모아 두었다. 관련: [[eight-step-chapter-mapping]]
- **R 코드**: 정적 R 코드블록(r 펜스) 16건. **실행형 `{r}` 청크는 0건**이며 수치는 별도 스크립트로 미리 계산해 본문에 확정 기재했다. 따라서 렌더에 R 실행이 필요 없고, 수치를 고치려면 스크립트 재실행 후 본문을 직접 고쳐야 한다.
- **그림**: 참조 18건 전부 존재(결측 0). `output/agent/2026-08-11/` fig01~08, `output/agent/2026-08-13/` fig-i01~i05(서론·전체모형 진단), fig-p01~p05(사분면 부호, 무상관, 정규-t, p-값 꼬리, 사영). 생성 스크립트는 `code/agent/2026-08-11/`, `2026-08-12/`, `2026-08-13/`.
- **디자인**: `references/ust-lecture-note/07-sampling-distribution.qmd` 구조(H2 + 아이콘 H3 + blockquote/callout/panel-tabset). 에셋은 `quarto/agent/2026-08-13/assets/`.
- **오프라인 안전**: `self-contained-math: true` + `embed-resources: true` 로 외부 http 참조 0건. 폐쇄망에서도 수식·아이콘·그림 정상 표시.
- **제작 이력**: 9장 체제 초안(130장) → 2026-08-13 02:36 사용자의 7장 재편 지시 → 14:12 재편·렌더 완료(139장).
- **남은 일**: (1) 사용자 검토, (2) 139장 기준 강의 시간 배분 점검. 관련: [[slide-level-feedback]], [[ice-data-year-variable]]
