# -----------------------------------------------------------------------------
# Created : 2026-08-30
# File    : code/agent/2026-08-30/revise-notes.py
# Purpose : Splice revised `::: notes` speaker scripts back into the chapter
#           decks, and verify the splice was surgical.
#
#           The revision is text-only and must not touch slide bodies, so the
#           script replaces ONLY the lines strictly between a `::: notes` opener
#           and its matching closer. Everything else is copied byte for byte.
#
#           Subcommands
#             splice <revision-file>   apply revisions listed in the file
#             verify                   compare working tree against git HEAD
#
#           Verification asserts four things:
#             1. slide bodies (all lines outside notes blocks) are unchanged
#             2. the number of notes blocks per deck is unchanged
#             3. every number and every inline formula present in an original
#                note still appears in the revised note (no silent fact drift)
#             4. no revised note introduces a line that opens or closes a div
# -----------------------------------------------------------------------------

import re
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from notes_lib import DECK_DIR, OPEN_DIV, CLOSE_DIV, extract_notes

MARKER = re.compile(r"^<<<DECK (?P<deck>[\w\-.]+) IDX (?P<idx>\d+)>>>\s*$")

def read_revisions(path):
    """Parse the revision file into {deck: {idx: [lines]}}."""
    rev, cur = {}, None
    for line in path.read_text(encoding="utf-8").split("\n"):
        m = MARKER.match(line)
        if m:
            cur = (m.group("deck"), int(m.group("idx")))
            rev.setdefault(cur[0], {})[cur[1]] = []
            continue
        if cur is not None:
            rev[cur[0]][cur[1]].append(line)
    # Trim leading/trailing blank lines each block accumulated from the layout
    # of the revision file itself.
    for deck in rev:
        for idx, body in rev[deck].items():
            while body and not body[0].strip():
                body.pop(0)
            while body and not body[-1].strip():
                body.pop()
    return rev


def cmd_splice(revision_file):
    rev = read_revisions(Path(revision_file))
    total = 0
    for deck_name, blocks in sorted(rev.items()):
        path = DECK_DIR / deck_name
        lines = path.read_text(encoding="utf-8").split("\n")
        notes = extract_notes(lines)
        # Replace from the bottom up so earlier line indices stay valid.
        for idx in sorted(blocks, reverse=True):
            if idx >= len(notes):
                sys.exit(f"{deck_name}: block index {idx} out of range ({len(notes)} notes)")
            body = blocks[idx]
            for b in body:
                if OPEN_DIV.match(b) or CLOSE_DIV.match(b):
                    sys.exit(f"{deck_name}[{idx}]: revised text contains a div fence: {b!r}")
            _, open_i, close_i = notes[idx]
            lines[open_i + 1:close_i] = body
            total += 1
        path.write_text("\n".join(lines), encoding="utf-8")
        print(f"{deck_name}: spliced {len(blocks)} blocks")
    print(f"total {total} blocks spliced")


def git_show(path):
    out = subprocess.run(["git", "show", f"HEAD:{path.as_posix()}"],
                         capture_output=True, check=True)
    return out.stdout.decode("utf-8").split("\n")


# Numbers, and inline/display math, are the facts that must survive a rewrite.
NUM = re.compile(r"\d+(?:[.,]\d+)*")
MATH = re.compile(r"\$[^$]+\$")


def tokens(text):
    return NUM.findall(text) + MATH.findall(text)


# Some numbers are rhetorical rather than factual ("3초 만에"), and removing the
# flourish removes the digit with it. Those drops are listed explicitly instead
# of loosening the check, so every dropped token stays reviewable.
ALLOWED_DROPS = Path("output/agent/2026-08-30/allowed-drops.txt")


def load_allowed():
    allowed = set()
    if ALLOWED_DROPS.exists():
        for line in ALLOWED_DROPS.read_text(encoding="utf-8").split("\n"):
            line = line.split("#")[0].strip()
            if line:
                deck, idx, tok = line.split(None, 2)
                allowed.add((deck, int(idx), tok))
    return allowed


def cmd_verify():
    failures = 0
    allowed = load_allowed()
    for path in sorted(DECK_DIR.glob("*.qmd")):
        old_lines = git_show(path)
        new_lines = path.read_text(encoding="utf-8").split("\n")
        old_notes, new_notes = extract_notes(old_lines), extract_notes(new_lines)

        if len(old_notes) != len(new_notes):
            print(f"FAIL {path.name}: note count {len(old_notes)} -> {len(new_notes)}")
            failures += 1
            continue

        # 1. bodies outside notes blocks must be identical
        def strip_notes(lines, notes):
            keep, drop = [], set()
            for _, o, c in notes:
                drop.update(range(o + 1, c))
            for i, l in enumerate(lines):
                if i not in drop:
                    keep.append(l)
            return keep

        ob, nb = strip_notes(old_lines, old_notes), strip_notes(new_lines, new_notes)
        if ob != nb:
            diff = [i for i, (a, b) in enumerate(zip(ob, nb)) if a != b]
            print(f"FAIL {path.name}: slide body changed at {len(diff)} line(s), first index {diff[:3]}")
            failures += 1

        # 2. facts inside each note must survive
        for k, ((t, oo, oc), (_, no, nc)) in enumerate(zip(old_notes, new_notes)):
            old_t = tokens("\n".join(old_lines[oo + 1:oc]))
            new_text = "\n".join(new_lines[no + 1:nc])
            missing = [tok for tok in set(old_t)
                       if tok not in new_text and (path.name, k, tok) not in allowed]
            if missing:
                print(f"FAIL {path.name}[{k}] {t}: dropped {sorted(missing)}")
                failures += 1

    print("VERIFY OK" if failures == 0 else f"VERIFY FAILED ({failures} problems)")
    return 1 if failures else 0


if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit("usage: revise-notes.py splice <file> | verify")
    if sys.argv[1] == "splice":
        cmd_splice(sys.argv[2])
    elif sys.argv[1] == "verify":
        sys.exit(cmd_verify())
    else:
        sys.exit(f"unknown subcommand {sys.argv[1]}")
