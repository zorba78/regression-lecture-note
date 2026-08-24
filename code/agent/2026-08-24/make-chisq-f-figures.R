# Date        : 2026-08-24
# Description : Figures for the two sampling distributions added to the
#               "Preliminary Knowledge" chapter:
#               (a) chi-square densities for several degrees of freedom,
#               (b) F densities, with the right-tail rejection region shaded
#                   at the ice cream full-model degrees of freedom F(3, 26).
#               Also prints the regression ANOVA table of the ice cream full
#               model so the slides can quote checked numbers, and verifies
#               the identity t^2 = F for the simple regression.
#               Style (colours, png helper) follows
#               code/agent/2026-08-13/make-restructure-figures.R.
#               Run from the project root:
#                 Rscript code/agent/2026-08-24/make-chisq-f-figures.R
# File        : make-chisq-f-figures.R

FIG_DIR <- "output/agent/2026-08-24"
dir.create(FIG_DIR, recursive = TRUE, showWarnings = FALSE)

COL_BLUE   <- "#2a78d6"
COL_ORANGE <- "#eb6834"
COL_RED    <- "#e34948"
COL_AQUA   <- "#1baf7a"
INK        <- "#0b0b0b"
INK2       <- "#52514e"
GRID_C     <- "#e1e0d9"

open_png <- function(file, w = 1800, h = 1050, res = 170) {
  png(file.path(FIG_DIR, file), width = w, height = h, res = res)
}

## ---- fig-p06: chi-square densities -------------------------------------
# The chi-square distribution is right-skewed and lives on [0, Inf).
# Larger degrees of freedom shift the mass right (mean = df) and make the
# shape more symmetric, which is why SSE / sigma^2 behaves like a chi-square.

xx <- seq(0.01, 30, length.out = 800)

open_png("fig-p06-chisq.png")
par(mar = c(4.5, 4.5, 3.2, 1), col.axis = INK2, col.lab = INK, fg = INK2)
plot(xx, dchisq(xx, df = 3), type = "l", lwd = 3, col = COL_BLUE,
     ylim = c(0, 0.25),
     panel.first = grid(col = GRID_C, lty = 1),
     main = "Chi-square Densities",
     xlab = "value", ylab = "density")
lines(xx, dchisq(xx, df = 10), lwd = 3, col = COL_ORANGE, lty = 2)
lines(xx, dchisq(xx, df = 26), lwd = 3, col = COL_AQUA,   lty = 3)
legend("topright", bty = "n", lwd = 3, lty = c(1, 2, 3),
       col = c(COL_BLUE, COL_ORANGE, COL_AQUA),
       legend = c("3 df", "10 df", "26 df  (ice cream residual df)"),
       text.col = INK)
dev.off()

## ---- fig-p07: F densities with rejection region ------------------------
# F(3, 26) are the degrees of freedom of the ice cream full-model F test.
# The shaded area is the upper 5% tail, i.e. the rejection region.

ff  <- seq(0.001, 6, length.out = 800)
df1 <- 3
df2 <- 26
f_crit <- qf(0.95, df1, df2)

open_png("fig-p07-f-distribution.png")
par(mar = c(4.5, 4.5, 3.2, 1), col.axis = INK2, col.lab = INK, fg = INK2)
plot(ff, df(ff, df1, df2), type = "l", lwd = 3, col = COL_BLUE,
     ylim = c(0, 0.8),
     panel.first = grid(col = GRID_C, lty = 1),
     main = sprintf("F Densities; shaded area is the upper 5%% tail of F(%d, %d)",
                    df1, df2),
     xlab = "value", ylab = "density")
xs <- seq(f_crit, 6, length.out = 300)
polygon(c(xs, rev(xs)), c(df(xs, df1, df2), rep(0, length(xs))),
        col = adjustcolor(COL_RED, alpha.f = 0.35), border = NA)
abline(v = f_crit, col = COL_RED, lwd = 2, lty = 2)
lines(ff, df(ff, 10, 26), lwd = 3, col = COL_ORANGE, lty = 2)
lines(ff, df(ff,  1, 26), lwd = 3, col = COL_AQUA,   lty = 3)
legend("topright", bty = "n", lwd = 3, lty = c(1, 2, 3),
       col = c(COL_BLUE, COL_ORANGE, COL_AQUA),
       legend = c(sprintf("F(%d, %d)", df1, df2), "F(10, 26)", "F(1, 26)"),
       text.col = INK)
text(f_crit, 0.55, sprintf("critical value %.2f", f_crit),
     pos = 4, col = COL_RED, cex = 0.9)
dev.off()

## ---- numbers: regression ANOVA of the ice cream full model -------------

ice <- read.csv(
  "references/cnu-regression-lecture-note/강의노트/R 예제/7장/ice.csv.csv",
  header = TRUE
)

full <- lm(IC ~ price + income + temp, data = ice)
n    <- nrow(ice)
p    <- 3

SST <- sum((ice$IC - mean(ice$IC))^2)
SSE <- sum(residuals(full)^2)
SSR <- SST - SSE
MSR <- SSR / p
MSE <- SSE / (n - p - 1)
Fv  <- MSR / MSE

cat(sprintf("SST = %.6f  SSR = %.6f  SSE = %.6f  (SSR + SSE = %.6f)\n",
            SST, SSR, SSE, SSR + SSE))
cat(sprintf("df  : regression %d, residual %d, total %d\n", p, n - p - 1, n - 1))
cat(sprintf("MSR = %.6f  MSE = %.6f  F = %.4f  p = %.3e\n",
            MSR, MSE, Fv, pf(Fv, p, n - p - 1, lower.tail = FALSE)))
cat(sprintf("R2  = %.6f   F critical at 5%% = %.4f\n", SSR / SST, f_crit))

# Identity t^2 = F when there is a single explanatory variable
simple <- lm(IC ~ temp, data = ice)
t_val  <- coef(summary(simple))["temp", "t value"]
F_val  <- anova(simple)[["F value"]][1]
cat(sprintf("simple regression: t = %.4f, t^2 = %.4f, F = %.4f\n",
            t_val, t_val^2, F_val))
