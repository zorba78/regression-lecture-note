# Date        : 2026-08-13
# Description : Figures and numbers for the restructured lecture:
#               (a) quadrant sign device for covariance (DSSI Ch.2 teaching aid),
#               (b) zero correlation with a perfect nonlinear relation,
#               (c) normal vs t distribution,
#               (d) p-value as a tail area of the t distribution,
#               (e) hat matrix as an orthogonal projection.
#               Also prints the covariance / correlation / slope identities for
#               the ice cream data so the slides can quote checked numbers.
#               Run from the project root:
#                 Rscript code/agent/2026-08-13/make-restructure-figures.R
# File        : make-restructure-figures.R

FIG_DIR <- "output/agent/2026-08-13"
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

ice <- read.csv(
  "references/cnu-regression-lecture-note/강의노트/R 예제/7장/ice.csv.csv",
  header = TRUE
)

## ---- numbers: covariance, correlation, slope ---------------------------

x <- ice$temp
y <- ice$IC
n <- length(x)

Sxx <- sum((x - mean(x))^2)
Sxy <- sum((x - mean(x)) * (y - mean(y)))
cov_xy <- Sxy / (n - 1)
r_xy   <- cor(x, y)
sx <- sd(x); sy <- sd(y)
b1 <- Sxy / Sxx

cat("\n===== ice cream: temp (x) vs IC (y), n =", n, "=====\n")
cat(sprintf("mean(x) = %.4f, sd(x) = %.4f\n", mean(x), sx))
cat(sprintf("mean(y) = %.4f, sd(y) = %.6f\n", mean(y), sy))
cat(sprintf("cov(x,y) = Sxy/(n-1) = %.6f\n", cov_xy))
cat(sprintf("corr(x,y)            = %.6f\n", r_xy))
cat("--- three equivalent routes to the slope ---\n")
cat(sprintf("  Sxy/Sxx            = %.8f\n", b1))
cat(sprintf("  cov(x,y)/var(x)    = %.8f\n", cov_xy / sx^2))
cat(sprintf("  r * sy/sx          = %.8f\n", r_xy * sy / sx))
cat(sprintf("  coef(lm)           = %.8f\n", coef(lm(y ~ x))[2]))
cat(sprintf("R^2 = %.6f, r^2 = %.6f (equal in simple regression)\n",
            summary(lm(y ~ x))$r.squared, r_xy^2))

## ---- hat matrix numbers -----------------------------------------------

X <- model.matrix(IC ~ price + income + temp, data = ice)
H <- X %*% solve(t(X) %*% X) %*% t(X)
cat("\n===== hat matrix H for the full model =====\n")
cat(sprintf("dim(H)                 : %d x %d\n", nrow(H), ncol(H)))
cat(sprintf("symmetric  (H = H')    : %s\n", isTRUE(all.equal(H, t(H)))))
cat(sprintf("idempotent (HH = H)    : %s\n", isTRUE(all.equal(H %*% H, H))))
cat(sprintf("trace(H)               : %.6f  (= p + 1 = %d)\n",
            sum(diag(H)), ncol(X)))
cat(sprintf("mean leverage
 (p+1)/n : %.6f\n", ncol(X) / nrow(ice)))

## ---- fig-p01: quadrant signs behind the covariance ---------------------

set.seed(11)
xa <- rnorm(60); ya <- 0.85 * xa + rnorm(60, sd = 0.55)
xb <- rnorm(60); yb <- -0.85 * xb + rnorm(60, sd = 0.55)

quad_panel <- function(xx, yy, main) {
  plot(xx, yy, pch = 16, col = INK2, cex = 0.9,
       xlim = c(-3, 3), ylim = c(-3, 3),
       panel.first = grid(col = GRID_C, lty = 1),
       main = main, xlab = "x", ylab = "y")
  abline(v = mean(xx), h = mean(yy), col = COL_RED, lwd = 2, lty = 2)
  # sign of (y - ybar)(x - xbar) in each quadrant
  text( 2.1,  2.1, "+", col = COL_BLUE,   cex = 2.6, font = 2)
  text(-2.1,  2.1, "-", col = COL_ORANGE, cex = 2.6, font = 2)
  text(-2.1, -2.1, "+", col = COL_BLUE,   cex = 2.6, font = 2)
  text( 2.1, -2.1, "-", col = COL_ORANGE, cex = 2.6, font = 2)
}

open_png("fig-p01-quadrant-signs.png", w = 2000, h = 1000)
par(mfrow = c(1, 2), mar = c(4.3, 4.3, 3.2, 1),
    col.axis = INK2, col.lab = INK, fg = INK2)
quad_panel(xa, ya, sprintf("Positive association (r = %.2f)", cor(xa, ya)))
quad_panel(xb, yb, sprintf("Negative association (r = %.2f)", cor(xb, yb)))
dev.off()

## ---- fig-p02: r = 0 does not mean unrelated ---------------------------

xq <- seq(-7, 7, length.out = 60)
yq <- 50 - xq^2

open_png("fig-p02-zero-correlation.png", w = 1500, h = 1050)
par(mar = c(4.5, 4.5, 3.2, 1), col.axis = INK2, col.lab = INK, fg = INK2)
plot(xq, yq, pch = 16, col = INK2, cex = 1.1,
     panel.first = grid(col = GRID_C, lty = 1),
     main = sprintf("Perfect relation y = 50 - x^2, yet r = %.2f", cor(xq, yq)),
     xlab = "x", ylab = "y")
abline(lm(yq ~ xq), col = COL_BLUE, lwd = 3)
dev.off()

cat("\n===== fig-p02: correlation of the parabola =====\n")
cat(sprintf("corr(x, 50 - x^2) on a symmetric grid = %.6f\n", cor(xq, yq)))

## ---- fig-p03: normal vs t --------------------------------------------

tt <- seq(-4.5, 4.5, length.out = 600)

open_png("fig-p03-normal-vs-t.png", w = 1700, h = 1050)
par(mar = c(4.5, 4.5, 3.2, 1), col.axis = INK2, col.lab = INK, fg = INK2)
plot(tt, dnorm(tt), type = "l", lwd = 3, col = COL_BLUE,
     panel.first = grid(col = GRID_C, lty = 1),
     main = "Standard Normal and t Distributions",
     xlab = "value", ylab = "density")
lines(tt, dt(tt, df = 3),  lwd = 3, col = COL_ORANGE, lty = 2)
lines(tt, dt(tt, df = 10), lwd = 3, col = COL_AQUA,   lty = 3)
legend("topright", bty = "n", lwd = 3, lty = c(1, 2, 3),
       col = c(COL_BLUE, COL_ORANGE, COL_AQUA),
       legend = c("Normal(0, 1)", "t with 3 df", "t with 10 df"),
       text.col = INK)
dev.off()

## ---- fig-p04: p-value as a tail area ----------------------------------

df_ex <- 28          # n - 2 for the ice cream simple regression
t_obs <- 2.20        # an illustrative observed t value

open_png("fig-p04-pvalue-tail.png", w = 1700, h = 1050)
par(mar = c(4.5, 4.5, 3.2, 1), col.axis = INK2, col.lab = INK, fg = INK2)
plot(tt, dt(tt, df_ex), type = "l", lwd = 3, col = COL_BLUE,
     panel.first = grid(col = GRID_C, lty = 1),
     main = sprintf("Two-sided p-value: shaded area beyond |t| = %.2f", t_obs),
     xlab = "t", ylab = "density")
for (s in c(1, -1)) {
  xs <- seq(s * t_obs, s * 4.5, length.out = 200)
  polygon(c(xs, rev(xs)), c(dt(xs, df_ex), rep(0, length(xs))),
          col = adjustcolor(COL_RED, alpha.f = 0.35), border = NA)
}
abline(v = c(-t_obs, t_obs), col = COL_RED, lwd = 2, lty = 2)
dev.off()

cat("\n===== fig-p04: illustrative p-value =====\n")
cat(sprintf("df = %d, |t| = %.2f, two-sided p = %.4f\n",
            df_ex, t_obs, 2 * pt(t_obs, df_ex, lower.tail = FALSE)))

## ---- fig-p05: hat matrix as an orthogonal projection -------------------

# Schematic in 2-D: the response vector y, its projection y-hat onto the
# column space of X (drawn as a line), and the residual at a right angle
open_png("fig-p05-projection.png", w = 1500, h = 1050)
par(mar = c(1, 1, 3.2, 1), col.axis = INK2, col.lab = INK, fg = INK2)
plot(NA, xlim = c(-0.15, 1.15), ylim = c(-0.15, 1.0),
     axes = FALSE, xlab = "", ylab = "",
     main = "Fitted Values Are an Orthogonal Projection of y")

# column space of X drawn as a horizontal plane (line)
lines(c(-0.05, 1.1), c(0, 0), col = INK2, lwd = 2)
text(1.1, -0.07, "column space of X", col = INK2, pos = 2)

# y vector and its projection
yv <- c(0.62, 0.80)
arrows(0, 0, yv[1], yv[2], col = COL_BLUE,   lwd = 4, length = 0.14)
arrows(0, 0, yv[1], 0,     col = COL_AQUA,   lwd = 4, length = 0.14)
arrows(yv[1], 0, yv[1], yv[2], col = COL_ORANGE, lwd = 4, length = 0.14)

text(yv[1] / 2 - 0.02, yv[2] / 2 + 0.06, "y", col = COL_BLUE, cex = 1.5, font = 2)
text(yv[1] / 2, -0.07, expression(hat(y) == H * y), col = COL_AQUA, cex = 1.3)
text(yv[1] + 0.20, yv[2] / 2, expression(e == (I - H) * y),
     col = COL_ORANGE, cex = 1.3)

# right angle marker
rect(yv[1] - 0.045, 0, yv[1], 0.045, border = INK2, lwd = 2)
dev.off()

## ---- data structure table (head of the ice cream data) ----------------

cat("\n===== structure table for the slides (first 5 of 30 rows) =====\n")
print(head(ice[, c("period", "IC", "price", "income", "temp", "year")], 5))
cat(sprintf("\nn = %d periods, %d variables\n", nrow(ice), ncol(ice)))

cat("\nFigures written to", FIG_DIR, "\n")
