# Date        : 2026-11-26
# Description : Residual diagnostics for the FULL ice cream model
#               (IC ~ price + income + temp), used in Chapter 5 slide
#               "진단 그림 4종 읽는 법". Copy of
#               code/agent/2026-08-13/make-fullmodel-diagnostics.R with ONE fix:
#               plot.lm() prints its own outer caption "lm(IC ~ ...)" whenever
#               the device holds several panels (sub.caption), and that caption
#               landed on top of the mtext() title below, so the two titles were
#               printed over each other. sub.caption = "" switches the plot.lm
#               caption off and leaves the single mtext() title.
#               The original script and its PNG (output/agent/2026-08-13/) are
#               left untouched; this version writes to output/agent/2026-11-26/.
#               Data: CNU lecture note R examples, chapter 7 (ice.csv.csv, n = 30).
#               Run from the project root:
#                 Rscript code/agent/2026-11-26/make-fullmodel-diagnostics.R
# File        : make-fullmodel-diagnostics.R

FIG_DIR <- "output/agent/2026-11-26"
dir.create(FIG_DIR, recursive = TRUE, showWarnings = FALSE)

INK    <- "#0b0b0b"
INK2   <- "#52514e"

ice <- read.csv(
  "references/cnu-regression-lecture-note/강의노트/R 예제/7장/ice.csv.csv",
  header = TRUE
)

fit_full <- lm(IC ~ price + income + temp, data = ice)

# Wide margins and a smaller title cex keep the four panel titles from
# colliding at revealjs slide scale
png(file.path(FIG_DIR, "fig-i05-fullmodel-diagnostics.png"),
    width = 1700, height = 1500, res = 170)
par(mfrow = c(2, 2), mar = c(4.2, 4.2, 3.2, 1.2), oma = c(0, 0, 2.4, 0),
    cex.main = 0.95, col.axis = INK2, col.lab = INK, fg = INK2)
# sub.caption = "" : the only change from the 2026-08-13 script (see header)
plot(fit_full, pch = 16, col = INK2, sub.caption = "")
# Title names the predictors in plain words, without R formula notation (~),
# because the audience does not read R (changed 2026-11-26)
mtext("Residual diagnostics: full model (price, income, temp)",
      outer = TRUE, cex = 1.0, col = INK)
dev.off()

cat("Figure written to", file.path(FIG_DIR, "fig-i05-fullmodel-diagnostics.png"), "\n")
