# -----------------------------------------------------------------------------
# Created : 2026-08-30
# File    : code/agent/2026-08-30/notes_lib.py
# Purpose : Shared parser for `::: notes` speaker-script blocks in the chapter
#           decks. Both the diagnostic pass and the splice/verify pass must
#           agree on block boundaries exactly -- if they disagree, an index in
#           the revision file points at a different block than the one that was
#           reviewed, so the parsing lives here once.
#
#           Two subtleties this handles:
#           1. HTML-commented regions are masked out. 01-introduction.qmd has a
#              whole slide commented with `<!-- ## ... ::: -->`, and its closing
#              fence `::: -->` is not a bare `:::`. Without masking, the block
#              never closes and swallows every slide after it.
#           2. Nested divs inside a note (callouts, columns) are tracked by
#              depth so the first inner `:::` does not close the note early.
# -----------------------------------------------------------------------------

import re
from pathlib import Path

DECK_DIR = Path("quarto/agent/2026-08-26")

OPEN_NOTES = re.compile(r"^:::+ *\{?\.?notes\}?\s*$")
# `[^\s:]`, not `[^ :]`: a bare fence read from a CRLF file ends in "\r", which a
# class that excludes only the literal space would accept as div content. The
# fence would then be counted as an opener, the block would never close, and it
# would swallow the rest of the file -- the same asymmetry that HTML comments
# caused. Open and close patterns have to stay exact mirrors.
OPEN_DIV = re.compile(r"^:::+ *[^\s:]")
CLOSE_DIV = re.compile(r"^:::+\s*$")


def comment_mask(lines):
    """Return a bool list: True where the line sits inside an HTML comment."""
    mask, inside = [], False
    for line in lines:
        starts = "<!--" in line
        ends = "-->" in line
        # A line that both opens and closes stays a comment line; a line that
        # only opens turns the region on from here down.
        mask.append(inside or starts)
        if starts and not ends:
            inside = True
        elif ends:
            inside = False
    return mask


def extract_notes(lines):
    """Return [(title, open_idx, close_idx)], 0-based, commented notes skipped."""
    masked = comment_mask(lines)
    out, title, i = [], "(deck preamble)", 0
    while i < len(lines):
        if masked[i]:
            i += 1
            continue
        line = lines[i]
        if line.startswith("## "):
            title = line[3:].strip()
        if OPEN_NOTES.match(line):
            depth, j = 1, i + 1
            while j < len(lines) and depth > 0:
                if masked[j]:
                    j += 1
                    continue
                if OPEN_DIV.match(lines[j]):
                    depth += 1
                elif CLOSE_DIV.match(lines[j]):
                    depth -= 1
                    if depth == 0:
                        break
                j += 1
            out.append((title, i, j))
            i = j
        i += 1
    return out


def read_deck(path):
    return path.read_text(encoding="utf-8").split("\n")


def notes_of(path):
    """Convenience: [(title, body_text, open_idx, close_idx)] for one deck."""
    lines = read_deck(path)
    return [(t, "\n".join(lines[o + 1:c]), o, c) for t, o, c in extract_notes(lines)]
