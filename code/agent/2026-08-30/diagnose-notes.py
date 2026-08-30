# -----------------------------------------------------------------------------
# Created : 2026-08-30
# File    : code/agent/2026-08-30/diagnose-notes.py
# Purpose : Extract every `::: notes` speaker-script block from the eight
#           chapter decks and quantify the two problems the user reported:
#           (a) unnatural Korean (translationese / AI-tell phrasing),
#           (b) inflated intensifiers and evaluative modifiers.
#           Output is written to files (never printed) because this Windows
#           console mangles Korean on stdout -- see memory/tooling-paths-windows.
# -----------------------------------------------------------------------------

import re
import sys
from collections import Counter
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from notes_lib import DECK_DIR, notes_of

OUT_DIR = Path("output/agent/2026-08-30")

# Inflated intensifiers / evaluative modifiers the user called out as 과장 수식어.
INTENSIFIERS = [
    "매우", "아주", "굉장히", "대단히", "극도로", "엄청난", "엄청나게", "놀라운",
    "놀랍게도", "완벽한", "완벽히", "완벽하게", "결정적인", "결정적으로", "핵심적인",
    "절대적인", "절대적으로", "강력한", "강력하게", "획기적인", "필수적인", "궁극적인",
    "근본적으로", "근본적인", "정말", "진짜", "무려", "압도적", "탁월한", "뛰어난",
    "훌륭한", "심오한", "방대한", "무수한", "어마어마한", "지극히", "극히", "상당히",
    "훨씬", "가장 중요한", "매우 중요한", "특히 중요한", "반드시", "결코", "전혀",
]

# Stock AI/translationese connectives and constructions in Korean expository prose.
AI_PHRASES = [
    "결론적으로", "이를 통해", "이를 통하여", "다시 말해", "다시 말하면", "즉,",
    "라고 할 수 있습니다", "라고 볼 수 있습니다", "하는 것입니다", "인 것입니다",
    "시사합니다", "시사하는", "주목할 만한", "주목할 필요가", "기억하시기 바랍니다",
    "중요한 것은", "핵심은", "여기서 중요한", "살펴보겠습니다", "알아보겠습니다",
    "설명드리겠습니다", "말씀드리겠습니다", "확인할 수 있습니다", "볼 수 있습니다",
    "되어집니다", "지고 있습니다", "가지고 있습니다", "에 있어서", "에 대해서",
    "으로부터", "로부터", "에 다름 아닙니다", "라는 점입니다", "다는 점입니다",
    "하지 않으면 안", "할 수밖에 없습니다", "라고 생각하시면", "생각하시면 됩니다",
    "상상해 보십시오", "상상해 보세요", "떠올려 보십시오", "비유하자면", "비유하면",
    "마치", "처럼 생각하시면",
]

# Sentence-final endings: the 2026-08-23 pass found 니다 78% + 죠 18% = mechanical.
ENDING_PATTERNS = [
    ("습니다/ㅂ니다", r"(습니다|ㅂ니다|입니다|합니다|됩니다|립니다|봅니다|씁니다)\s*[.!?]"),
    ("죠", r"죠\s*[.!?]"),
    ("요", r"(?<!죠)요\s*[.!?]"),
    ("십시오/세요", r"(십시오|세요|십시다)\s*[.!?]"),
    ("의문형(까요/까)", r"(까요|까)\s*[?]"),
    ("체언/명사종결", r"[가-힣]+(임|함|됨|것|점|뿐)\s*[.]"),
]


def count_hits(text, needles):
    return Counter({n: text.count(n) for n in needles if text.count(n) > 0})


def main():
    decks = sorted(DECK_DIR.glob("*.qmd"))
    if not decks:
        sys.exit(f"no decks under {DECK_DIR.resolve()}")
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    all_notes, per_deck, agg_int, agg_ai = [], [], Counter(), Counter()

    for deck in decks:
        notes = notes_of(deck)
        joined = "\n".join(n[1] for n in notes)
        ints, ais = count_hits(joined, INTENSIFIERS), count_hits(joined, AI_PHRASES)
        agg_int += ints
        agg_ai += ais
        endings = {name: len(re.findall(pat, joined)) for name, pat in ENDING_PATTERNS}
        per_deck.append({
            "deck": deck.name, "n_notes": len(notes), "chars": len(joined),
            "ints": sum(ints.values()), "ais": sum(ais.values()), "endings": endings,
        })
        for k, (t, body, s, e) in enumerate(notes):
            all_notes.append((deck.name, t, body, s, e, k))

    # ---- corpus dump: every note, in deck order, for manual reading ----------
    with (OUT_DIR / "notes-corpus.md").open("w", encoding="utf-8") as f:
        for deck, title, body, s, e, k in all_notes:
            f.write(f"\n\n{'=' * 78}\n<<<DECK {deck} IDX {k}>>>  L{s}-{e}  |  {title}\n"
                    f"{'-' * 78}\n{body.strip()}\n")

    # ---- diagnostic report ---------------------------------------------------
    with (OUT_DIR / "notes-diagnosis.md").open("w", encoding="utf-8") as f:
        f.write("# Speaker-note diagnosis (2026-08-30)\n\n## Volume and hit counts\n\n")
        f.write("| Deck | Notes | Chars | Intensifiers | AI phrases | per 1k chars |\n")
        f.write("|:--|--:|--:|--:|--:|--:|\n")
        tn = tc = ti = ta = 0
        for d in per_deck:
            rate = (d["ints"] + d["ais"]) / d["chars"] * 1000 if d["chars"] else 0
            f.write(f"| {d['deck']} | {d['n_notes']} | {d['chars']:,} | {d['ints']} | {d['ais']} | {rate:.1f} |\n")
            tn += d["n_notes"]; tc += d["chars"]; ti += d["ints"]; ta += d["ais"]
        rate = (ti + ta) / tc * 1000 if tc else 0
        f.write(f"| **TOTAL** | **{tn}** | **{tc:,}** | **{ti}** | **{ta}** | **{rate:.1f}** |\n")

        f.write("\n## Sentence-ending mix (mechanical rhythm check)\n\n")
        names = [n for n, _ in ENDING_PATTERNS]
        f.write("| Deck | " + " | ".join(names) + " |\n|:--|" + "--:|" * len(names) + "\n")
        for d in per_deck:
            f.write(f"| {d['deck']} | " + " | ".join(str(d["endings"][n]) for n in names) + " |\n")

        f.write("\n## Intensifiers, by frequency\n\n| Term | Count |\n|:--|--:|\n")
        for term, c in agg_int.most_common():
            f.write(f"| {term} | {c} |\n")

        f.write("\n## AI / translationese phrases, by frequency\n\n| Phrase | Count |\n|:--|--:|\n")
        for term, c in agg_ai.most_common():
            f.write(f"| {term} | {c} |\n")

        # Longest notes are the likeliest to carry padded prose.
        f.write("\n## Longest 25 notes (revision priority)\n\n| Deck | Slide | Chars |\n|:--|:--|--:|\n")
        for deck, title, body, s, e, k in sorted(all_notes, key=lambda x: -len(x[2]))[:25]:
            f.write(f"| {deck[:2]} | {title} | {len(body)} |\n")

    print(f"notes={tn} chars={tc} intensifiers={ti} ai_phrases={ta}")


if __name__ == "__main__":
    main()
