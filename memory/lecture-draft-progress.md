---
name: lecture-draft-progress
description: 회귀분석 특강 슬라이드 현황과 산출물 위치 (2026-08-23 문체·연결 정비본)
type: progress
date: 2026-08-23
---

**현행본(2026-08-23 문체·연결 정비)**: 원본 `quarto/agent/2026-08-13/regression-lecture-note.qmd` (268 KB), 렌더본 `presentation/regression-lecture-note.html` (6.0 MB). 정비 직전 백업은 같은 폴더의 `regression-lecture-note.qmd.bak-before-style-pass`.

- **구성**: 총 **141 슬라이드**(각 장 마무리 슬라이드 추가로 139 → 141). Introduction 20 / Preliminary Knowledge 16 / Simple Linear Regression 20 / Multiple Linear Regression 28 / Diagnosis & Variable Selection 18 / Weighted Regression 17 / Dummy Variable 13 / Summary 9. 렌더 HTML 기준 151장(장 표지 8 + 타이틀 2 포함). 관련: [[lecture-chapter-structure]]
- **강의 대본**: `::: notes` 149건(장 표지 포함, 전 슬라이드 수록).
- **2026-08-23 정비 내용**: (1) 본문 산문을 개조식으로 전환, 정의·정리 blockquote만 완결 문장 유지, (2) 노트의 `죠.` 238건 → 0건 등 어투 리듬 재작성, (3) 반복 H2 36그룹(80장)을 부제로 분화해 연속 반복 0, (4) 전 장에 브리지 callout·`이 장의 정리`·다음 장 예고 추가. 규칙은 [[slide-register-rule]], [[slide-flow-devices]].
- **함께 고친 사실 오류**: 5장 첫 슬라이드(Anscombe)에 변수선택 결과인 축소 모형식 `-0.113 + 0.00353 income + 0.00354 temp`가 잘못 들어가 있어 제거. 이 식은 같은 장의 "선택 후 재진단" 슬라이드에만 있어야 한다.
- **줄바꿈**: CRLF 2,529 + LF 1,331 혼재였던 것을 **LF로 통일**(정확 일치 치환이 계속 깨져서). 내용 변화 없음.
- **개념적 중심**: 회귀 = 조건부 기댓값 $E(Y\mid X=x)$. 절차 축은 회귀분석 8단계이며 대응표는 Introduction에 한 장. 관련: [[eight-step-chapter-mapping]]
- **R 코드**: 정적 R 코드블록 16건. **실행형 `{r}` 청크 0건**이며 수치는 별도 스크립트로 미리 계산해 본문에 확정 기재. 렌더에 R 실행이 불필요한 대신, 수치를 고치려면 스크립트 재실행 후 본문을 직접 고쳐야 한다.
- **그림**: 참조 18건 전부 존재. `output/agent/2026-08-11/` fig01~08, `output/agent/2026-08-13/` fig-i01~i05, fig-p01~p05. 생성 스크립트는 `code/agent/` 아래 날짜 폴더.
- **오프라인 안전**: 렌더본의 외부 http 참조 **0건** 재확인(2026-08-23). 폐쇄망에서도 수식·아이콘·그림 정상 표시.
- **남은 일**: (1) 사용자 검토, (2) 141장 기준 강의 시간 배분 점검. 관련: [[slide-level-feedback]], [[ice-data-year-variable]]
