# MEMORY.md — 프로젝트 메모리 색인

세션 시작 시 이 파일을 먼저 읽는다. 각 항목은 `memory/` 아래 파일 하나(사실 1건)를 가리킨다.
형식: `- [제목](파일명.md) — 한 줄 요약`

- [특강 진행 상황](lecture-draft-progress.md) — 내용 이력과 산출물 위치. 정본·슬라이드 수는 [장별 개별 덱](chapter-split-decks.md)을 볼 것
- [확정 장 구성](lecture-chapter-structure.md) — 사용자가 지정한 영문 7개 장과 배치·표기 지시
- [8단계와 각 장의 대응](eight-step-chapter-mapping.md) — 절차 축. Introduction의 대응표와 함께 유지할 것
- [슬라이드 눈높이 원칙](slide-level-feedback.md) — 본문은 전문적, 쉬운 설명은 노트에
- [R 코드 금지·이론 우선](no-r-code-theory-first.md) — 청강자가 R을 모름. 계산은 수식으로 제시
- [문체 규칙](slide-register-rule.md) — 본문 개조식(정의·정리는 문장 유지) / 노트 경어체, AI 어투는 노트를 먼저 볼 것
- [노트 문체 기준 원본](notes-style-exemplar-user.md) — 사용자가 쓴 01장 IDX 0·1이 기준. 매우·굉장히·즉은 정상 어휘
- [노트 대본 일괄 윤문](notes-revision-2026-08-30.md) — 2026-08-30 과장어·상투구 정비. 남긴 것과 검증 스크립트 포함
- [01장 정리 슬라이드 주석 처리](ch01-summary-slide-commented-out.md) — 01장에만 `이 장의 정리`가 렌더 안 됨. 확인 필요
- [연결감 장치](slide-flow-devices.md) — 제목 차별화 · 장 브리지 · 이 장의 정리 통일
- [장별 개별 덱](chapter-split-decks.md) — 장별 덱 8개가 정본. 마스터는 동결, split 스크립트는 다시 돌리지 않음
- [행렬 도구의 장 분업](matrix-toolbox-ch2-vs-ch4.md) — 정의는 02장, 적용은 04장. 양쪽에 같은 내용을 쓰지 않음
- [최대가능도 용어와 03장 MLE](likelihood-term-and-ch3-mle.md) — 덱 전체가 "최대가능도". 03장 유도가 05장 AIC의 근거
- [슬라이드 배치 시스템](slide-layout-system.md) — 배치는 lecture.css로 결정. A는 정의 밴드뿐, 바닥 고정은 선택형 .pin. vh 단위 금지
- [tabset 폐지](tabset-removed-for-pdf.md) — PDF에서 활성 탭만 남으므로 16개 전부 해제. 노트의 "탭" 지시도 함께 정리
- [슬라이드 스타일 구성](deck-style-decisions.md) — CSS 파일 역할, 참조 덱에서 가져온 것과 버린 것
- [레이아웃 초과 검출법](slide-overflow-check.md) — 검사는 커밋된 `/run-regression-lecture-note` 스킬로. 넘침 기준선은 0
- [회귀 명칭의 유래](regression-etymology-sources.md) — reversion→regression 경위. regression 첫 등장은 1886이 아니라 1885
- [원자력 분야 회귀 실사례](nuclear-regression-cases.md) — 검증된 인용 3건
- [불확도 이론 요청](regression-uncertainty-content.md) — 표준오차·Gauss-Markov 상세 포함 요청
- [Galton 실제 자료](galton-real-data.md) — 2026-08-24부터 모의자료 대신 실제 가족 기록(898명) 사용
- [ice 데이터 year 변수](ice-data-year-variable.md) — year는 계절이 아니라 관측 연차(사실 오류 주의)
- [06장 GLS 예제 = Lake Huron](gls-example-lakehuron.md) — 아이스크림은 자기상관이 약해 기각. 예제는 효과가 뚜렷한 자료로 고를 것
- [참고자료 PDF 잠김](reference-pdfs-locked.md) — CNU·DSSI PDF 암호 보호로 읽기 불가, R 예제만 가용
- [Quarto/R 실행 경로](tooling-paths-windows.md) — quarto는 8.3 단축 경로로 호출 필요
- [사용자 편집 영역 보존](respect-user-edits.md) — 요청 없이 손대지 않음. 사용자 편집은 메인 체크아웃에 있으니 양쪽 확인
- [split 스크립트의 편집 파괴](split-script-destroys-user-edits.md) — 장별 덱은 통째로 덮어써짐. 실행 전 mtime 확인 필수
- [.fig-led 캡션 겹침 함정](fig-led-caption-maxheight-trap.md) — 그림에 인라인 max-height 금지. 캡션이 콜아웃 위로 겹침
