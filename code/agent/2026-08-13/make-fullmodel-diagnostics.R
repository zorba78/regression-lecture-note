# Date        : 2026-08-13
# Description : Residual diagnostics for the FULL ice cream model
#               (IC ~ price + income + temp), used in Chapter 5.
#               Chapter 5 comes before variable selection in the lecture's
#               8-step spine, so it must diagnose the full model; the
#               reduced-model diagnostics (2026-08-11/fig04) stay in Chapter 7
#               as the "re-diagnose after selection" example.
#               Run from the project root:
#                 Rscript code/agent/2026-08-13/make-fullmodel-diagnostics.R
# File        : make-fullmodel-diagnostics.R

FIG_DIR <- "output/agent/2026-08-13"
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
plot(fit_full, pch = 16, col = INK2)
mtext("Residual Diagnostics for the Full Model (IC ~ price + income + temp)",
      outer = TRUE, cex = 1.0, col = INK)
dev.off()

cat("\n===== Chapter 5 full model =====\n")
print(summary(fit_full))

# Values quoted on the Chapter 5 slides
cat("\n===== quantities quoted in Chapter 5 =====\n")
cat(sprintf("largest absolute standardized residual : %.2f (obs %d)\n",
            max(abs(rstandard(fit_full))), which.max(abs(rstandard(fit_full)))))
cat(sprintf("largest leverage h_ii                  : %.3f (obs %d), 2(p+1)/n = %.3f\n",
            max(hatvalues(fit_full)), which.max(hatvalues(fit_full)),
            2 * length(coef(fit_full)) / nrow(ice)))
cat(sprintf("largest Cook's distance                : %.3f (obs %d)\n",
            max(cooks.distance(fit_full)), which.max(cooks.distance(fit_full))))

cat("\nFigure written to", FIG_DIR, "\n")
