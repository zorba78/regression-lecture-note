# -----------------------------------------------------------------------------
# Created : 2026-08-30
# File    : code/agent/2026-08-30/apply-word-fixes.py
# Purpose : Reviewer follow-up. The first revision pass replaced the author's own
#           word 핵심 with 요점 in four notes and introduced 뼈대 in one more.
#           The reviewer confirmed 핵심 is the appropriate term, so those five
#           substitutions are reverted.
#
#           Exact-string replacement rather than re-typing whole blocks: each
#           target must occur exactly once in its deck AND sit inside a notes
#           block, otherwise the script aborts without writing. This keeps the
#           edit provably inside the speaker notes.
# -----------------------------------------------------------------------------

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from notes_lib import DECK_DIR, extract_notes

FIXES = [
    ("02-preliminary-knowledge.qmd", "여기가 요점입니다.", "여기가 핵심입니다."),
    ("02-preliminary-knowledge.qmd", "이 구분이 요점입니다.", "이 구분이 핵심입니다."),
    ("04-multiple-linear-regression.qmd", "1단계가 이 유도의 뼈대입니다.", "1단계가 이 유도의 핵심입니다."),
    ("05-diagnosis-variable-selection.qmd", "요점은 두 번째 단계에 있습니다.", "핵심은 두 번째 단계에 있습니다."),
    ("05-diagnosis-variable-selection.qmd", "그 다음 줄이 요점입니다.", "그 다음 줄이 핵심입니다."),
    ("06-weighted-regression.qmd", "하지만 요점은 폭이 아닙니다.", "하지만 핵심은 폭이 아닙니다."),
]


def note_line_indices(lines):
    inside = set()
    for _, o, c in extract_notes(lines):
        inside.update(range(o + 1, c))
    return inside


def main():
    for deck_name, old, new in FIXES:
        path = DECK_DIR / deck_name
        lines = path.read_text(encoding="utf-8").split("\n")
        inside = note_line_indices(lines)
        hits = [i for i, l in enumerate(lines) if old in l]
        if len(hits) != 1:
            sys.exit(f"{deck_name}: {old!r} found {len(hits)} times, expected 1")
        if hits[0] not in inside:
            sys.exit(f"{deck_name}: {old!r} is outside a notes block (line {hits[0]+1})")
        lines[hits[0]] = lines[hits[0]].replace(old, new)
        path.write_text("\n".join(lines), encoding="utf-8")
        print(f"{deck_name}: {old} -> {new}")


if __name__ == "__main__":
    main()
