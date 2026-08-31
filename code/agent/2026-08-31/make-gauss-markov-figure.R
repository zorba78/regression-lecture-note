# Date        : 2026-08-31
# Description : Figure for the Gauss-Markov slide of chapter 3.  The slide had
#               only a table of standard errors, which does not show what the
#               competing estimator is or why it loses.  Two panels:
#                 (a) what the competitor is - split the data at the median of
#                     temperature and join the two group means.  Both lines are
#                     drawn on the same scatter so the slopes can be compared
#                     by eye.
#                 (b) why it loses - the fitted model is treated as the truth
#                     and the experiment is repeated 20,000 times.  The two
#                     sampling distributions have the SAME centre (both
#                     estimators are unbiased) and DIFFERENT widths (least
#                     squares is the narrower one).  That picture is exactly
#                     what the Gauss-Markov theorem asserts.
#
#               Every number quoted on the slide is printed to the console:
#               the weights a_i of the competitor, sum(a_i), sum(a_i x_i),
#               sum(a_i^2), the two variances and their ratio, and the
#               simulated means and standard deviations as a check on the
#               algebra.  The algebra itself was already verified in
#               code/agent/2026-08-28/verify-simple-regression-inference.R;
#               this script reproduces it so the figure is self-contained.
#
#               Data: references/cnu-regression-lecture-note/강의노트/
#               R 예제/7장/ice.csv.csv (n = 30 four-week periods).
#
#               Run from the project root:
#                 Rscript code/agent/2026-08-31/make-gauss-markov-figure.R
# File        : make-gauss-markov-figure.R

options(digits = 10)

FIG_DIR <- "output/agent/2026-08-31"
dir.create(FIG_DIR, recursive = TRUE, showWarnings = FALSE)

# Same palette as the other chapter 3 figures
COL_BLUE   <- "#2a78d6"
COL_ORANGE <- "#eb6834"
INK        <- "#0b0b0b"
INK2       <- "#52514e"
GRID_C     <- "#e1e0d9"

ice <- read.csv("references/cnu-regression-lecture-note/강의노트/R 예제/7장/ice.csv.csv",
                stringsAsFactors = FALSE)
x <- ice$temp
y <- ice$IC
n <- length(x)

# ---------------------------------------------------------------------------
# Least squares
# ---------------------------------------------------------------------------
fit  <- lm(y ~ x)
b0   <- coef(fit)[1]
b1   <- coef(fit)[2]
Sxx  <- sum((x - mean(x))^2)
s2   <- sum(resid(fit)^2) / (n - 2)          # sigma^2 hat = SSE/(n-2)
var_ols <- s2 / Sxx                          # = s2 * sum(c_i^2), c_i = (x-xbar)/Sxx
cat(sprintf("OLS   : b0 = %.6f, b1 = %.7f, Sxx = %.1f, s2 = %.9f\n",
            b0, b1, Sxx, s2))
cat(sprintf("        Var(b1) = s2/Sxx = %.6e, se = %.7f\n",
            var_ols, sqrt(var_ols)))

# ---------------------------------------------------------------------------
# The competitor: split at the median of x, join the two group means
# ---------------------------------------------------------------------------
hi <- x > median(x); lo <- !hi
nH <- sum(hi); nL <- sum(lo)
xH <- mean(x[hi]); xL <- mean(x[lo])
yH <- mean(y[hi]); yL <- mean(y[lo])
d  <- xH - xL

# The denominator d is fixed by x alone, so the estimator is a weighted sum of
# the responses with weights a_i, i.e. it is "linear" in the sense of the theorem.
a  <- ifelse(hi, 1 / (nH * d), -1 / (nL * d))
b1_alt <- sum(a * y)
sum_a2 <- sum(a^2)                           # = (1/nH + 1/nL)/d^2
var_alt <- s2 * sum_a2

cat(sprintf("\nsplit : median(x) = %.1f, nH = %d, nL = %d\n", median(x), nH, nL))
cat(sprintf("        (xL, yL) = (%.3f, %.4f), (xH, yH) = (%.3f, %.4f), d = %.5f\n",
            xL, yL, xH, yH, d))
cat(sprintf("alt   : b1 = (yH - yL)/d = %.7f  (= sum(a_i y_i) = %.7f)\n",
            (yH - yL) / d, b1_alt))
cat(sprintf("        sum(a_i) = %.3e (must be 0), sum(a_i x_i) = %.10f (must be 1)\n",
            sum(a), sum(a * x)))
cat(sprintf("        sum(a_i^2) = %.7e, closed form (1/nH + 1/nL)/d^2 = %.7e\n",
            sum_a2, (1 / nH + 1 / nL) / d^2))
cat(sprintf("        Var = s2 * sum(a_i^2) = %.6e, se = %.7f\n",
            var_alt, sqrt(var_alt)))
cat(sprintf("ratio : Var(alt)/Var(OLS) = %.5f\n", var_alt / var_ols))

# ---------------------------------------------------------------------------
# Panel (b): repeat the experiment with the fitted model taken as the truth
# ---------------------------------------------------------------------------
set.seed(2026)
B <- 20000
mu <- b0 + b1 * x
sim <- replicate(B, {
  ys <- mu + rnorm(n, 0, sqrt(s2))
  c(sum((x - mean(x)) * ys) / Sxx, sum(a * ys))
})
cat(sprintf("\nsim   : B = %d, true slope used = %.7f\n", B, b1))
cat(sprintf("        OLS  mean = %.7f, sd = %.7f (theory %.7f)\n",
            mean(sim[1, ]), sd(sim[1, ]), sqrt(var_ols)))
cat(sprintf("        alt  mean = %.7f, sd = %.7f (theory %.7f)\n",
            mean(sim[2, ]), sd(sim[2, ]), sqrt(var_alt)))

# ---------------------------------------------------------------------------
# The figure
# ---------------------------------------------------------------------------
png(file.path(FIG_DIR, "fig-s03-gauss-markov.png"),
    width = 2100, height = 720, res = 150, pointsize = 17)
par(mfrow = c(1, 2), mar = c(4.2, 4.6, 3.0, 1),
    col.axis = INK2, col.lab = INK, fg = INK2)

# (a) the two lines on the same scatter.  They very nearly coincide, which is
# the point: on THIS sample the two answers agree, so the difference between
# the estimators is not visible here at all.  The competitor is dashed so that
# both can still be told apart where they overlap.
plot(x, y, type = "n", cex.main = 1.0,
     main = "(a) Two ways to draw the slope",
     xlab = "Mean temperature (deg F)",
     ylab = "Consumption (pints per capita)")
grid(col = GRID_C, lty = 1); box(col = INK2)
abline(v = median(x), col = INK2, lwd = 1.4, lty = 3)
points(x, y, pch = 16, col = adjustcolor(INK2, alpha.f = 0.45), cex = 1.2)
abline(fit, col = COL_BLUE, lwd = 3.4)
abline(a = yL - (yH - yL) / d * xL, b = (yH - yL) / d,
       col = COL_ORANGE, lwd = 3.4, lty = 2)
points(c(xL, xH), c(yL, yH), pch = 16, col = COL_ORANGE, cex = 2.4)
points(c(xL, xH), c(yL, yH), pch = 1, col = INK, cex = 2.4, lwd = 1.6)
text(median(x), min(y), "median of x", col = INK2, pos = 4, cex = 0.85)
legend("topleft", bty = "n", lwd = 3.4, cex = 0.9, lty = c(1, 2),
       col = c(COL_BLUE, COL_ORANGE),
       legend = c(sprintf("least squares: %.5f", b1),
                  sprintf("two group means: %.5f", b1_alt)))

# (b) the two sampling distributions, zoomed to +/- 4 standard errors so the
# difference in width is on screen rather than squeezed into the middle.
xlim <- b1 + c(-4, 4) * sqrt(var_alt)
dO <- density(sim[1, ], from = xlim[1], to = xlim[2])
dA <- density(sim[2, ], from = xlim[1], to = xlim[2])
plot(dO, type = "n", xlim = xlim, ylim = c(0, max(dO$y) * 1.18), cex.main = 1.0,
     main = sprintf("(b) If the experiment were repeated %s times",
                    format(B, big.mark = ",")),
     xlab = "Estimated slope", ylab = "Density")
grid(col = GRID_C, lty = 1); box(col = INK2)
polygon(c(dA$x, rev(dA$x)), c(dA$y, rep(0, length(dA$y))),
        col = adjustcolor(COL_ORANGE, alpha.f = 0.22), border = NA)
polygon(c(dO$x, rev(dO$x)), c(dO$y, rep(0, length(dO$y))),
        col = adjustcolor(COL_BLUE, alpha.f = 0.22), border = NA)
lines(dA, col = COL_ORANGE, lwd = 3.4)
lines(dO, col = COL_BLUE, lwd = 3.4)
abline(v = b1, col = INK2, lwd = 1.4, lty = 2)
text(b1, max(dO$y) * 0.06, "true slope", col = INK2, pos = 4, cex = 0.85)
legend("topleft", bty = "n", lwd = 3.4, cex = 0.9,
       col = c(COL_BLUE, COL_ORANGE),
       legend = c(sprintf("least squares, se = %.6f", sqrt(var_ols)),
                  sprintf("two group means, se = %.6f", sqrt(var_alt))))
dev.off()
cat("\nwritten:", file.path(FIG_DIR, "fig-s03-gauss-markov.png"), "\n")
