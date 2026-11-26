# Date    : 2026-11-25
# Purpose : Verify the 2nd revision of chapter 4 against a snapshot of the
#           working file taken at the start of the task (not git HEAD, because
#           the 1st revision is uncommitted and must be kept).
#           Checks:
#             1. line endings stay pure CRLF
#             2. number of "## " slides and "::: notes" blocks is unchanged
#             3. no two consecutive H2 titles are identical
#             4. the two moved likelihood slides are identical to the originals
#                apart from the title wording (unified diff printed otherwise)
#             5. math segments ($...$, $$...$$) and numbers: multiset difference
#                between snapshot and current file, so every added or removed
#                token can be traced to an intended edit
#             6. "우도" (excluding the word "경우도") count in the current file
#             7. register: polite endings (습니다 etc.) in slide body lines, and
#                plain/noun endings in changed speaker-note paragraphs
# File    : verify-ch4-revision2.py
# Usage   : python verify-ch4-revision2.py <snapshot.qmd> <current.qmd>

import difflib
import re
import sys
from collections import Counter

sys.stdout.reconfigure(encoding="utf-8")
before = open(sys.argv[1], encoding="utf-8", newline="").read()
after = open(sys.argv[2], encoding="utf-8", newline="").read()

# 1. line endings -----------------------------------------------------------
for name, t in (("snapshot", before), ("current", after)):
    print(f"[1] {name}: CRLF={t.count(chr(13) + chr(10))} LF={t.count(chr(10))}")
B, A = before.replace("\r\n", "\n"), after.replace("\r\n", "\n")


def h2_titles(t):
    # Title text without the trailing {.class} attribute block
    return [re.sub(r"\s*\{[^}]*\}\s*$", "", ln) for ln in t.split("\n") if ln.startswith("## ")]


# 2. counts -----------------------------------------------------------------
for name, t in (("snapshot", B), ("current", A)):
    print(f"[2] {name}: '## ' = {len(h2_titles(t))}, '::: notes' = "
          f"{len(re.findall(r'(?m)^::: notes\s*$', t))}")

# 3. consecutive repeated H2 -------------------------------------------------
titles = h2_titles(A)
rep = [(a, b) for a, b in zip(titles, titles[1:]) if a == b]
print(f"[3] consecutive repeated H2 in current: {len(rep)} {rep}")


# 4. moved blocks -------------------------------------------------------------
def blocks(t):
    # Each block = from one "## " line up to (not including) the next one
    parts = re.split(r"(?m)^(?=## )", t)
    return {p.split("\n", 1)[0]: p for p in parts[1:]}


bb, ab = blocks(B), blocks(A)
pairs = [("## 우도함수를 이용한 추정: 유도 {.smaller .stepped}",
          "## 최대가능도 추정: 유도 {.smaller .stepped}"),
         ("## 우도함수를 이용한 추정: $\\sigma^2$ 의 차이 {.smaller}",
          "## 최대가능도 추정: $\\sigma^2$ 의 차이 {.smaller}")]
for old, new in pairs:
    o = bb[old].replace(old, new, 1)  # apply only the intended title change
    n = ab[new]
    if o == n:
        print(f"[4] identical except title: {new}")
    else:
        print(f"[4] DIFFERS beyond title: {new}")
        for d in difflib.unified_diff(o.split("\n"), n.split("\n"), lineterm="", n=0):
            print("     ", d)

# Slide order around the move
i = titles.index("## 최소제곱 해가 존재할 조건")
print("[4] order:", " -> ".join(t[3:] for t in titles[i:i + 4]))

# 5. math segments and numbers ------------------------------------------------
math_re = re.compile(r"\$\$.+?\$\$|\$[^$\n]+?\$", re.S)
num_re = re.compile(r"(?<![A-Za-z_\\])\d+(?:\.\d+)?")


def tokens(t):
    maths = Counter(m.group().replace("\n", " ") for m in math_re.finditer(t))
    nums = Counter(num_re.findall(math_re.sub(" ", t)))  # numbers outside math
    return maths, nums


(mb, nb), (ma, na) = tokens(B), tokens(A)
print("[5] math segments removed:")
for k, v in (mb - ma).items():
    print("      -", v, "x", k)
print("[5] math segments added:")
for k, v in (ma - mb).items():
    print("      +", v, "x", k)
print("[5] numbers (outside math) removed:", dict(nb - na))
print("[5] numbers (outside math) added  :", dict(na - nb))

# 6. 우도 -------------------------------------------------------------------
print("[6] '우도' (not '경우도') in current:", len(re.findall(r"(?<!경)우도", A)))

# 7. register ---------------------------------------------------------------
def split_body_notes(t):
    body, notes, inside = [], [], False
    for ln in t.split("\n"):
        if re.match(r"^::: notes\s*$", ln):
            inside = True
            continue
        if inside and ln.strip() == ":::":
            inside = False
            continue
        (notes if inside else body).append(ln)
    return body, notes


polite = re.compile(r"(습니다|입니다|합니다|됩니다|십시오|세요)[.?!]?\s*$|(습니다|입니다|합니다)[.?!]\s")
bb_, bn_ = split_body_notes(B)
ab_, an_ = split_body_notes(A)
print("[7] body lines with polite endings: snapshot",
      sum(bool(polite.search(l)) for l in bb_), "current", sum(bool(polite.search(l)) for l in ab_))
changed_notes = [l for l in an_ if l.strip() and l not in set(bn_)]
end_ok = re.compile(r"(니다|까요|세요|시오|요)[.?!]?$")
for l in changed_notes:
    sents = [s.strip() for s in re.split(r"(?<=[.?!])\s+", l.strip()) if s.strip()]
    bad = [s for s in sents if not end_ok.search(s)]
    print(f"[7] changed note paragraph: {len(sents)} sentences, non-polite endings: {bad}")
