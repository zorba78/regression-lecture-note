# Date    : 2026-11-26
# Purpose : Text checks on the revised chapter-6 deck (06-weighted-regression.qmd):
#           (1) H2 count vs speaker-note count, (2) old physics-example wording
#           (0.255, 1/w, "proportional to variance", old estimates), (3) body lines
#           that end in the declarative "-da." or use "-seumnida" (the body must use
#           noun endings), (4) R code / function / package names in the body,
#           (5) $$ parity per slide, (6) number and formula tokens of the speaker
#           notes compared with the pre-revision snapshot, slide by slide (matched
#           by title) and for the GLS slides as one group (three were merged).
# Usage   : python code/agent/2026-11-26/check-ch06-text.py <snapshot.qmd>
# File    : check-ch06-text.py
import re
import sys
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8")
ROOT = Path(__file__).resolve().parents[3]
NEW = ROOT / "quarto/agent/2026-08-26/06-weighted-regression.qmd"
OLD = Path(sys.argv[1])

NOTE = re.compile(r"(?ms)^::: notes\n(.*?)^:::\s*$")

def load(p):
    return p.read_bytes().decode("utf-8").replace("\r\n", "\n")

def body_only(t):
    """Slide body: drop speaker notes, YAML header and HTML comments."""
    b = NOTE.sub("", t)
    b = re.sub(r"(?s)\A---\n.*?\n---\n", "", b)
    return re.sub(r"(?s)<!--.*?-->", "", b)

new, old = load(NEW), load(OLD)
body = body_only(new)

# (1) counts
print(f"(1) H2 = {len(re.findall(r'(?m)^## ', new))}, notes = {len(NOTE.findall(new))}"
      "  (the H1 slide has notes, the reference slide has none)")

# (2) old wording
old_terms = ["0.255", "1/w", "분산에 비례", "측정분산", "양자충돌",
             "549.5", "602.4", "144.8", "136.6", "0.929", "w$ 는 분산", "가중치가 아니라"]
hits = {k: new.count(k) for k in old_terms if new.count(k)}
print("(2) old wording hits:", hits if hits else 0)

# (3) declarative endings in the body
da = [l for l in body.split("\n")
      if re.search(r"다\.\s*(</li>|</b>)?\s*$", l) or re.search(r"(습니다|합니다)", l)]
print("(3) body lines ending in '다.' or using -seumnida:", len(da))
for l in da:
    print("    ", l[:120])

# (4) R names in the body; '::' only when not part of a ':::' fence
r_pat = re.compile(r"\blm\(|\bglm\(|summary\(|weights\s*=|\bnlme\b|\balr4\b"
                   r"|(?<!:)::(?!:)|```|anova\(|predict\(")
rhits = [l.strip()[:150] for l in body.split("\n") if r_pat.search(l)]
print("(4) body lines with R code/function/package names:", len(rhits))
for l in rhits:
    print("    ", l)

# (5) $$ parity per H2 slide
bad = [b.split("\n", 1)[0] for b in re.split(r"(?m)^(?=## )", body)[1:] if b.count("$$") % 2]
print("(5) slides with odd $$ count:", bad if bad else 0)

# (6) note tokens by slide title
TOK = re.compile(r"\$[^$]+\$|\d+(?:\.\d+)?")

def notes_by_title(t):
    out = {}
    for part in re.split(r"(?m)^(?=#{1,2} )", t):
        m = re.match(r"#{1,2} (.*)", part)
        if not m:
            continue
        title = re.sub(r"\s*\{[^}]*\}\s*$", "", m.group(1)).strip()
        n = NOTE.findall(part)
        out[title] = n[0] if n else ""
    return out

def diff(a_txt, b_txt):
    a, b = TOK.findall(a_txt), TOK.findall(b_txt)
    return (sorted({x for x in a if a.count(x) > b.count(x)}),
            sorted({x for x in b if b.count(x) > a.count(x)}))

on, nn = notes_by_title(old), notes_by_title(new)
print("(6) note tokens by slide title (snapshot -> revised):")
for t in on:
    if t in nn:
        lost, added = diff(on[t], nn[t])
        state = "identical" if on[t] == nn[t] else "edited"
        print(f"    {state:9s} {t[:36]:36s} lost={lost} added={added}")
    else:
        print(f"    gone      {t[:36]:36s} (slide removed or retitled)")
g_old = [k for k in on if "GLS" in k]
g_new = [k for k in nn if "GLS" in k]
lost, added = diff("\n".join(on[k] for k in g_old), "\n".join(nn[k] for k in g_new))
print(f"    GLS group: {len(g_old)} old -> {len(g_new)} new note blocks; lost={lost} added={added}")
