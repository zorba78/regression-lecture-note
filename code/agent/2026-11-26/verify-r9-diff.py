# Date        : 2026-11-26
# Description : Verification for revision round 9 of the chapter decks.
#               For every chapter qmd it compares the pre-edit snapshot with
#               the current file and prints
#                 (1) every changed line (snapshot line no. / current line no.,
#                     before / after), tagged BODY or NOTES;
#                 (2) H2 and ::: notes counts, line-ending counts;
#                 (3) whether any changed BODY line newly ends a sentence in
#                     "다." (forbidden in slide body);
#                 (4) residual counts of "IC ~", "full 모형", "전체 모형" in
#                     Korean body/notes and "적음" in body, excluding code
#                     chunks and English captions/table rows;
#                 (5) number and $...$ math tokens of each changed hunk,
#                     before vs after, so dropped or altered tokens are visible.
#               Usage (from the project root):
#                 python code/agent/2026-11-26/verify-r9-diff.py <snapshot-dir>
# File        : verify-r9-diff.py

import difflib
import re
import sys
from pathlib import Path

SNAP = Path(sys.argv[1])
DECK = Path("quarto/agent/2026-08-26")
HANGUL = re.compile(r"[가-힣]")
NUM = re.compile(r"\d+(?:\.\d+)?")
MATH = re.compile(r"\$\$?[^$]+\$\$?")

sys.stdout.reconfigure(encoding="utf-8")


def classify(lines):
    """Return a list of 'BODY' / 'NOTES' / 'CODE' / 'YAML' tags, one per line."""
    tags, in_notes, in_code, in_yaml = [], False, False, False
    for i, ln in enumerate(lines):
        s = ln.rstrip("\r\n")
        if i == 0 and s == "---":
            in_yaml = True
            tags.append("YAML")
            continue
        if in_yaml:
            tags.append("YAML")
            if s == "---":
                in_yaml = False
            continue
        if s.startswith("```"):
            tags.append("CODE")
            in_code = not in_code
            continue
        if in_code:
            tags.append("CODE")
            continue
        if s.startswith("::: notes"):
            in_notes = True
            tags.append("NOTES")
            continue
        if in_notes and s == ":::":
            tags.append("NOTES")
            in_notes = False
            continue
        tags.append("NOTES" if in_notes else "BODY")
    return tags


def korean_line(s):
    # English captions (": ...") and table rows without Hangul are excluded
    return bool(HANGUL.search(s))


for cur in sorted(DECK.glob("0[1-8]-*.qmd")):
    snap = SNAP / cur.name
    raw_new = cur.read_bytes()
    raw_old = snap.read_bytes()
    new = raw_new.decode("utf-8").splitlines(keepends=True)
    old = raw_old.decode("utf-8").splitlines(keepends=True)
    tags = classify(new)
    crlf_old, crlf_new = raw_old.count(b"\r\n"), raw_new.count(b"\r\n")
    bare_lf = raw_new.count(b"\n") - crlf_new
    print(f"===== {cur.name}")
    print(f"  H2 {sum(l.startswith('## ') for l in old)} -> {sum(l.startswith('## ') for l in new)}"
          f" | notes {sum(l.startswith('::: notes') for l in old)} -> {sum(l.startswith('::: notes') for l in new)}"
          f" | lines {len(old)} -> {len(new)}"
          f" | CRLF {crlf_old} -> {crlf_new} | bare LF {bare_lf}")
    sm = difflib.SequenceMatcher(a=old, b=new, autojunk=False)
    for op, a0, a1, b0, b1 in sm.get_opcodes():
        if op == "equal":
            continue
        before = "".join(old[a0:a1])
        after = "".join(new[b0:b1])
        tag = ",".join(sorted({tags[j] for j in range(b0, b1)})) or "DEL"
        print(f"  [{op}] snap {a0+1}-{a1} -> cur {b0+1}-{b1} ({tag})")
        for l in old[a0:a1]:
            print("    - " + l.rstrip())
        for l in new[b0:b1]:
            print("    + " + l.rstrip())
        nb, na = NUM.findall(before), NUM.findall(after)
        mb, ma = MATH.findall(before), MATH.findall(after)
        print(f"    numbers  before={nb}\n             after ={na}")
        print(f"    math     before={mb}\n             after ={ma}")
        new_da = [l for j, l in zip(range(b0, b1), new[b0:b1])
                  if tags[j] == "BODY" and re.search(r"다\.\s*(</li>)?\s*$", l.rstrip())]
        print(f"    new body lines ending in '다.': {len(new_da)}")
    # residual counts, Korean body/notes only
    cnt = {"IC ~": 0, "full 모형": 0, "전체 모형": 0, "full model(KR line)": 0, "적음(body)": 0}
    for j, l in enumerate(new):
        if tags[j] in ("CODE", "YAML") or not korean_line(l):
            continue
        for k in ("IC ~", "full 모형", "전체 모형"):
            cnt[k] += l.count(k)
        cnt["full model(KR line)"] += l.count("full model")
        if tags[j] == "BODY":
            cnt["적음(body)"] += len(re.findall(r"적음(?![에이은을])", l))
    print(f"  residual: {cnt}")
