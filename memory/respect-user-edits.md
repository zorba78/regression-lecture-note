---
name: respect-user-edits
description: 사용자가 직접 손댄 부분은 명시적 요청이 없으면 건드리지 않는다
metadata:
  type: feedback
date: 2026-08-26
---

사용자가 직접 수정한 파일·블록은 **특별히 요청하지 않는 한 수정하지 않는다.** 스타일이 마음에 들지 않거나 더 나은 방식이 보여도 그대로 둔다. 실제로 `code/agent/2026-08-25/make-eight-step-flowchart.R`(사용자가 밴드 제목과 포매팅을 직접 고침), 마스터 qmd의 사용자 편집 슬라이드가 이에 해당한다.

**Why:** CLAUDE.md의 "외과적 변경" 규칙이 인접 코드 일반을 다룬다면, 이 규칙은 그중에서도 **사용자 자신의 손이 닿은 영역**을 따로 못 박은 것이다. 사용자가 의도를 담아 고친 것을 되돌리면 같은 수정을 반복하게 만든다.

**How to apply:** 편집 대상 파일이 최근 사용자 손을 탄 것인지 `git diff`/`git status`로 먼저 확인한다. 요청받은 지점만 고치고, 그 옆에서 개선하고 싶은 것이 보이면 **말로만 보고**한다. 요청 범위가 사용자 편집 영역과 겹치면 무엇을 덮어쓰게 되는지 먼저 알린다.

**사용자는 메인 체크아웃에서 직접 편집한다(2026-08-30 실제 사례).** agent가 `.claude/worktrees/` 아래 별도 worktree에서 작업하는 경우, 사용자 수정은 **worktree가 아니라 `G:\Projects\regression-lecture-note`에 있다.** worktree만 보고 "사용자 편집 없음"이라고 판단하면 그 편집을 덮어쓰게 된다. 작업 시작 전에 양쪽을 모두 확인할 것:

```bash
git -C "G:/Projects/regression-lecture-note" status --short
stat -c '%y %n' G:/Projects/regression-lecture-note/quarto/agent/2026-08-26/*.qmd
```

**사용자 편집 블록을 특정하는 법**: HEAD 버전과 내가 만든 산출물 양쪽에 대조해 **둘 다와 다른 블록**을 고른다. 그 블록이 사용자가 손댄 곳이다. 실제 구현은 커밋 9cd249f의 `output/agent/2026-08-30/user-edits-01.txt` 생성 코드 참고. 옮길 때는 손으로 옮겨 적지 말고 **스크립트로 원문을 그대로 복사**한다. 관련: [[deck-style-decisions]], [[chapter-split-decks]], [[notes-style-exemplar-user]]
