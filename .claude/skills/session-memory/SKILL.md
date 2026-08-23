---
name: session-memory
description: 세션에서 결정된 사실·방향을 프로젝트 memory/ 폴더에 정리. "기억해", "메모리 저장", "세션 정리" 요청 시 또는 중요한 결정 직후 사용.
---

# 프로젝트 메모리 저장

향후 세션의 연속 작업을 위해 이번 세션의 사실을 `memory/`에 기록한다.

## 규칙 (CLAUDE.md 생성 파일 저장 공간)

- **파일당 사실 1건.** 파일명은 kebab-case (예: `slide-format-decision.md`).
- 저장 후 `memory/MEMORY.md` 색인에 한 줄 추가: `- [제목](파일명.md) — 요약`
- 상대 날짜("어제", "다음 주")는 절대 날짜(YYYY-MM-DD)로 변환해 기록.
- 이미 repo가 기록하는 내용(코드 구조, CLAUDE.md 내용, 파일 목록)은 저장하지 않는다.
- 이미 같은 사실을 다루는 파일이 있으면 새 파일을 만들지 말고 그 파일을 갱신한다. 틀린 것으로 판명된 메모리는 삭제한다.

## 파일 형식

```markdown
---
name: <kebab-case-slug>
description: <한 줄 요약>
type: decision | progress | feedback | reference
date: YYYY-MM-DD
---

<사실 본문. 결정이면 이유(Why)도 함께 기록.>
```

## 저장 대상 예시

- 강의 구성에 대한 사용자 결정 (예: "가중회귀에 슬라이드 절반 할애")
- 사용자가 준 피드백·수정 지시 (다음 작업에도 적용해야 하는 것)
- 진행 상황 (어느 장까지 초안 완료, 다음 할 일)
- 외부 참고자료 링크
