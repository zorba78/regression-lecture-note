# Date        : 2026-11-26
# Description : Residual diagnostics for the model kept by variable selection
#               (IC ~ income + temp), used in Chapter 5 slide "선택 후 재진단".
#               Reproduces ONLY the fig04 block of
#               code/agent/2026-08-11/make-lecture-figures.R (same size, margins,
#               colours and title) with ONE fix: plot.lm() prints its own outer
#               caption "lm(IC ~ ...)" when the device holds several panels
#               (sub.caption), and it overlapped the mtext() title. sub.caption = ""
#               switches that caption off. The other figures of the 2026-08-11
#               script are not regenerated, and the original script and PNG
#               (output/agent/2026-08-11/fig04-residual-diagnostics.png) are left
#               untouched; this version writes to output/agent/2026-11-26/.
#               Data: CNU lecture note R examples, chapter 7 (ice.csv.csv, n = 30).
#               Run from the project root:
#                 Rscript code/agent/2026-11-26/make-selected-model-diagnostics.R
# File        : make-selected-model-diagnostics.R

FIG_DIR <- "output/agent/2026-11-26"
dir.create(FIG_DIR, recursive = TRUE, showWarnings = FALSE)

INK  <- "#0b0b0b"   # primary ink (same as the 2026-08-11 script)
INK2 <- "#52514e"   # secondary ink (points)

ice <- read.csv(
  "references/cnu-regression-lecture-note/강의노트/R 예제/7장/ice.csv.csv",
  header = TRUE
)

r_red <- lm(IC ~ income + temp, data = ice)

# Same device settings as open_png("fig04-residual-diagnostics.png", w = 1700, h = 1500)
png(file.path(FIG_DIR, "fig04-residual-diagnostics.png"),
    width = 1700, height = 1500, res = 170)
par(mfrow = c(2, 2), mar = c(4, 4, 2.5, 1), oma = c(0, 0, 2, 0),
    col.axis = INK2, col.lab = INK, fg = INK2)
# sub.caption = "" : the only change from the 2026-08-11 fig04 block (see header)
plot(r_red, pch = 16, col = INK2, sub.caption = "")
# Title names the predictors in plain words, without R formula notation (~),
# because the audience does not read R (changed 2026-11-26)
mtext("Residual diagnostics: selected model (income, temp)", outer = TRUE,
      cex = 1.2, col = INK)
dev.off()

cat("Figure written to", file.path(FIG_DIR, "fig04-residual-diagnostics.png"), "\n")
