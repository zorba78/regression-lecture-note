---
name: split-script-destroys-user-edits
description: split-chapters.py는 장별 덱을 통째로 덮어쓴다. 실행 전 사용자 편집 여부를 반드시 확인할 것
metadata:
  type: feedback
date: 2026-08-26
---

`code/agent/2026-08-26/split-chapters.py` 는 `quarto/agent/2026-08-26/0*.qmd` 8개를 마스터에서 **통째로 다시 써서** 그 파일에 있던 손편집을 조용히 지운다. 2026-08-26 실제로 사용자가 `01-introduction.qmd` 의 `1·2단계: 연구 질문과 변수 선택` 슬라이드를 직접 고쳤는데, 이어서 돌린 split 이 그 내용을 덮어써 **복구 불가**가 되었다(장별 덱은 git 미추적, VS Code local history 없음).

**Why:** 사용자는 IDE에서 장별 덱을 열어 놓고 그 파일을 고친다. 스크립트 헤더의 "edit the master, not this file" 주석은 사용자에게 강제력이 없다. 편집 손실은 되돌릴 수 없는 손해이고, 사용자가 같은 수정을 반복하게 만든다.

**How to apply:** **split-chapters.py 를 다시 돌리지 않는다.** 2026-08-26 사용자 지시로 장별 덱이 정본이 되었고 분할은 이미 끝난 1회성 작업이다. 장 수정 요청은 그 장의 `quarto/agent/2026-08-26/0*.qmd` 를 직접 고쳐서 처리한다. 마스터는 동결.

**더 넓은 교훈:** 사용자가 요청한 것은 A(1회 분할)인데 A를 지원하려고 만든 도구를 이후 매번 돌리면, 요청 범위 밖에서 사용자 작업을 파괴할 수 있다. 생성 스크립트를 재실행하기 전에 "이번에도 돌리라고 한 적이 있는가"를 먼저 물을 것.

관련: [[respect-user-edits]], [[chapter-split-decks]]
