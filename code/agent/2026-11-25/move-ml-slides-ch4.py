# Date    : 2026-11-25
# Purpose : One-off edit for the 2nd revision of chapter 4. Move the two
#           likelihood slides ("## 우도함수를 이용한 추정: 유도" and
#           "## 우도함수를 이용한 추정: $\sigma^2$ 의 차이", each with its notes)
#           so that they sit right after "## 최소제곱 해가 존재할 조건" and
#           right before "## 모자행렬: 정의" (same placement as chapter 3,
#           where maximum likelihood follows the least squares solution).
#           The file is handled as raw bytes so CRLF line endings survive.
#           Anchors are asserted, so a second run fails instead of moving twice.
# File    : move-ml-slides-ch4.py
# Usage   : python move-ml-slides-ch4.py <path to 04-multiple-linear-regression.qmd>

import sys

path = sys.argv[1]
raw = open(path, "rb").read()
assert b"\r\n" in raw and raw.count(b"\n") == raw.count(b"\r\n"), "expected pure CRLF"

# keepends=True keeps the b"\r\n" on every line, so joining restores the file exactly
lines = raw.splitlines(keepends=True)


def find_h2(prefix: str) -> int:
    """Return the index of the single line that starts with the given H2 text."""
    hits = [i for i, ln in enumerate(lines) if ln.startswith(prefix.encode("utf-8"))]
    assert len(hits) == 1, (prefix, hits)
    return hits[0]


i_hat = find_h2("## 모자행렬: 정의")          # insertion point (block goes before this)
i_ml1 = find_h2("## 우도함수를 이용한 추정: 유도")  # first line of the block to move
i_next = find_h2("## 회귀계수의 해석: 정의")     # first line after the block
i_cond = find_h2("## 최소제곱 해가 존재할 조건")

# Order check: the condition slide must come right before the hat-matrix slide,
# and the likelihood block must currently sit after the hat-matrix slides.
assert i_cond < i_hat < i_ml1 < i_next
assert all(ln.startswith(b"## ") is False for ln in lines[i_cond + 1:i_hat]), "slide between"

# Each block runs from its H2 line to the line before the next H2; the two blank
# lines that separate slides belong to the end of each block, so blank-line
# structure is preserved on both sides of the cut.
block = lines[i_ml1:i_next]
assert block[-1] == b"\r\n" and block[-2] == b"\r\n", "block must end with two blank lines"
assert lines[i_hat - 1] == b"\r\n" and lines[i_hat - 2] == b"\r\n"

new_lines = lines[:i_hat] + block + lines[i_hat:i_ml1] + lines[i_next:]
assert len(new_lines) == len(lines)

out = b"".join(new_lines)
assert sorted(out.splitlines()) == sorted(raw.splitlines()), "content must only be reordered"
open(path, "wb").write(out)

h2 = [ln.decode("utf-8").rstrip("\r\n") for ln in new_lines if ln.startswith(b"## ")]
print("H2 count:", len(h2))
for t in h2[6:12]:
    print("  ", t)
