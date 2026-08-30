---
name: worktree-divergence-2026-08-30
description: 메인 체크아웃과 agent worktree가 갈라져 있다. 병합 전 덮어쓰기 주의
metadata:
  type: project
---

2026-08-30 현재 **같은 파일의 두 버전이 서로 다른 체크아웃에 따로 있다.** 어느 쪽이든 그냥 복사하면 상대 쪽 작업이 사라진다.

| 위치 | 브랜치 | 내용 |
|:--|:--|:--|
| `G:\Projects\regression-lecture-note` (메인) | main @ 70adf9c | HEAD + **사용자가 직접 쓴 01장 노트 IDX 0·1** + 재렌더된 `01-introduction.html` |
| `...\.claude\worktrees\bridge-cse_01AiYierDUiBsJLb7yAU1KN7` | worktree 브랜치 | 8개 덱 노트 1차 윤문 + 사용자 IDX 0·1 반영 + **01장 전체 문체 재작성** + memory·CLAUDE.md 수정 |

**agent worktree 쪽이 상위집합**이다. 사용자 편집분(IDX 0·1)을 스크립트로 그대로 옮겨 왔으므로 worktree에는 양쪽 내용이 모두 들어 있다. 다만 메인의 `01-introduction.html` 은 사용자가 따로 렌더한 것이라 worktree 것과 다르다.

**사용자가 앞으로도 메인 체크아웃에서 직접 편집할 가능성이 높다.** 작업 시작 전에 **양쪽 mtime과 diff를 먼저 확인**할 것:

```bash
git -C "G:/Projects/regression-lecture-note" status --short
stat -c '%y %n' G:/Projects/regression-lecture-note/quarto/agent/2026-08-26/*.qmd
```

사용자 편집 블록을 찾는 법은 `output/agent/2026-08-30/user-edits-01.txt` 를 만든 방식(HEAD·내 산출물 양쪽과 대조해 둘 다와 다른 블록을 고름)을 재사용한다. 관련: [[respect-user-edits]], [[notes-style-exemplar-user]], [[chapter-split-decks]]
