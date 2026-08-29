---
name: run-regression-lecture-note
description: Build, run, and check the KINS regression lecture decks. Use when asked to render the Quarto revealjs slides, screenshot a slide, look at how a slide actually renders, check the decks for clipped or overflowing content, verify layout after editing a qmd or the shared CSS, or run the R scripts that produce the figures.
---

This repo is a lecture, not a service: eight Quarto **revealjs** decks
(`01`–`08`) on a fixed **1280×1024** canvas. There is no server and no GUI
to click — the deliverable is rendered HTML, and the thing that breaks is
**layout**: content sliced off the bottom edge or running past the right edge,
which you cannot see from the `.qmd` source.

The handle is
[`.claude/skills/run-regression-lecture-note/slidecheck.py`](slidecheck.py):
it renders the decks, screenshots **every slide** with headless Edge, and
measures each shot. Run it after any edit to a `.qmd`, the shared CSS, or a
figure. All paths below are relative to the **repo root**.

## Prerequisites

Windows. Everything is already installed on this machine; these are the
verification commands, not an installer.

```bash
/c/PROGRA~1/RStudio/RESOUR~1/app/bin/quarto/bin/quarto.cmd --version   # 1.9.38
"/c/Program Files/R/R-4.6.0/bin/Rscript.exe" -e 'cat(R.version.string)' # R 4.6.0
python -c "import sys, PIL, numpy; print(sys.version.split()[0], PIL.__version__, numpy.__version__)"
ls "/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe"
```

Expected: `1.9.38`, `R version 4.6.0`, `3.14.3 12.3.0 2.4.4`, and the Edge
binary. Quarto is **not on `PATH`** — it ships inside RStudio. Override the
built-in paths with `QUARTO_CMD` / `EDGE_EXE` if they move.

## Build

Render all eight decks and check them in one pass:

```bash
python .claude/skills/run-regression-lecture-note/slidecheck.py --render --fresh
```

Takes about 12 minutes (211 slides × one headless Edge launch each). Exits
non-zero if any slide is clipped or any screenshot failed.

## Run (agent path)

**The everyday loop is incremental, not the full run.** Delete the shots for
what you changed, then re-check that deck — a single slide round-trips in
under 3 seconds:

```bash
# 1. locate the slide you edited (ids are Korean; substring match)
python .claude/skills/run-regression-lecture-note/slidecheck.py --find 잔차그림
#    -> 05:016  잔차그림과-가정-위반

# 2. drop the stale shot, then re-render and re-measure that deck
rm .slidecheck/shots/05/016.png
python .claude/skills/run-regression-lecture-note/slidecheck.py --deck 05 --render

# 3. LOOK at it - the measurement says "not clipped", not "reads well"
python .claude/skills/run-regression-lecture-note/slidecheck.py --shot 05:16
#    -> G:\...\.slidecheck\shots\05\016.png     then Read that path
```

Step 3 is not optional. The driver catches clipping and overflow; it cannot
tell you a caption is misaligned or a figure is too small.

| flag | what it does |
|---|---|
| *(none)* | shoot any missing slides, measure all, report |
| `--render` | `quarto render` each deck first |
| `--fresh` | discard cached shots first (forces a full re-shoot) |
| `--deck 05` | limit to one deck |
| `--find TEXT` | print `deck:idx` for slides whose id contains TEXT |
| `--shot 05:16` | print the png path for one slide |
| `--deck-dir DIR` | override the auto-detected dated deck folder |

Artifacts land in `.slidecheck/` at the repo root — `shots/<deck>/<idx>.png`
and `profile.csv` (`deck,idx,id,ink,last_row,right_overflow`). The driver
writes `.slidecheck/.gitignore` containing `*` on first run, so the
screenshots stay out of `git status`; the repo has no root `.gitignore`.

### Reading the report

```
slides   : 211
no shot  : 0
clipped  : 0
overflow : 25   (25 is the accepted baseline for all 8 decks)
```

- **clipped** — content cut mid-glyph at the bottom edge. Always a bug. Fix by
  shrinking that block with `::: {style="font-size: 0.8em"}`, not by adding
  `.smaller` to the whole slide.
- **overflow** — ink past 95.5% of the width. **The baseline is 0** (since
  2026-08-29), so any hit is a real defect. It used to be 25, and all 25 were
  one CSS bug: `.reveal blockquote { width: 100% }` in `lecture.css` plus
  content-box padding made the tinted definition band overhang the right edge.
  Converting those blockquotes to `.highlight-box` removed it.
- **no shot** — headless Edge intermittently produces nothing. Just re-run;
  only missing shots are retried.

### Regenerating a figure

Figures are R scripts under `code/agent/<date>/` that write PNGs to
`output/agent/<date>/`. Run one, then re-render the deck that embeds it:

```bash
"/c/Program Files/R/R-4.6.0/bin/Rscript.exe" code/agent/2026-08-29/residual-pattern-figure.R
```

## Run (human path)

Open any `quarto/agent/2026-08-26/0*-*.html` in a browser. The decks are
`embed-resources`, so a single file is the whole deck — no server needed.
`s` opens speaker notes.

## Test

**There is no test suite** — no `tests/`, `testthat/`, `Makefile`, or CI
config in this repo. `slidecheck.py` is the check, and its exit code is the
pass/fail signal.

## Gotchas

- **Quarto's long path breaks `render` but not `--version`.** With
  `"/c/Program Files/RStudio/resources/app/bin/quarto/bin/quarto.cmd"`,
  `--version` prints `1.9.38` and looks fine, but `render` dies with
  `error: Module not found "file:///.../Files/RStudio/resources/..."` —
  `quarto.cmd` splits on the space in `Program Files`. **Always use the 8.3
  short path** `/c/PROGRA~1/RStudio/RESOUR~1/...`. Do not "clean this up".
- **Editing the shared CSS means re-rendering all eight decks.**
  `quarto/agent/2026-08-13/assets/css/lecture.css` is inlined into every HTML
  by `embed-resources`, so a CSS change is invisible until you re-render —
  `--render` without `--deck`. Confirm all eight actually got rebuilt, since a
  partial render looks like a CSS bug:
  `ls -la --time-style=+%H:%M:%S quarto/agent/2026-08-26/0*.html`
  — every timestamp must be later than the CSS edit. Cross-check the class
  landed: `grep -c my-class quarto/agent/2026-08-26/0*.html`.
- **PowerShell mangles the Korean section ids.** `Get-Content -Raw` decodes the
  UTF-8 `.qmd`/`.html` as the legacy codepage; a regex over the result silently
  under-matches (it found 21 of 32 slides). Use `--find`, the Grep tool, or
  Python with `encoding="utf-8"` — never PowerShell regex on this repo's text.
- **Python must be told to print UTF-8.** The driver calls
  `sys.stdout.reconfigure(encoding="utf-8")`; any helper script you write
  needs the same line or Korean output is mojibake.
- **`cd … && …` in Bash can hang** on a permission prompt and has to be killed.
  Use absolute paths in a single command, or run the driver from the repo root.
- **`--find` matches the section *id*, not the title.** Quarto slugifies:
  spaces and `:` become `-`, so `이상점: 유의점과 대처` is
  `이상점-유의점과-대처`. Match a distinctive word, not the whole title.
- **The driver's `idx` is not the number on screen.** `idx` is 0-based over H2
  sections; reveal counts the title slide too. `05:016` displays as `20 / 34`.
  The offset is deck-dependent — read it off the screenshot.
- **`.fig-led` slides cap images at 512px tall** (`lecture.css`, the
  `section.fig-led img` rule). When that cap binds, changing `{width=X%}` in
  the markdown does nothing to the rendered height; set `{height=440}` instead.

## Troubleshooting

- **`error: Module not found "file:///…/Files/RStudio/resources/app/bin/quarto/bin/tools/x86_64/deno.exe"`**
  — you used the long quarto path. Use `/c/PROGRA~1/RStudio/RESOUR~1/...`.
- **`… not rendered yet - run with --render`** — the `.html` for that deck is
  missing. Add `--render`.
- **`no shot : 1`** with a deck/idx listed — headless Edge returned nothing for
  that slide. Re-run the same command; it retries only the missing ones.
- **Report shows Korean as `?????` or `�`** — you ran a helper without the
  UTF-8 reconfigure, or piped through a tool that re-encodes. The driver itself
  is fine.
- **A CSS edit doesn't show up in the screenshots** — you re-shot without
  re-rendering. `embed-resources` inlines the CSS; re-run with `--render`.
