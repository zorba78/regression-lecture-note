# Date        : 2026-08-25
# Description : Figures and numbers for the new "why least squares" slides.
#               Motivated by DSSI lecture note ch.2 p.25 ("Comparison of Lines"):
#               infinitely many lines can be drawn through a scatter, so a
#               criterion is needed to order them.  Data are the CNU ch.3
#               Example 3.1 toy data (n = 10), the same points already used by
#               output/agent/2026-08-11/fig02-least-squares-idea.png, so the
#               three consecutive slides show one and the same scatter.
#               Run from the project root:
#                 Rscript code/agent/2026-08-25/make-ls-rationale-figures.R
# File        : make-ls-rationale-figures.R

## ---- setup ------------------------------------------------------------

FIG_DIR <- "output/agent/2026-08-25"
dir.create(FIG_DIR, recursive = TRUE, showWarnings = FALSE)

# Palette kept identical to code/agent/2026-08-11/make-lecture-figures.R
COL_BLUE   <- "#2a78d6"   # the least-squares line
COL_ORANGE <- "#eb6834"   # competing candidate line
COL_AQUA   <- "#1baf7a"   # third candidate line
COL_RED    <- "#e34948"   # residual segments
INK        <- "#0b0b0b"
INK2       <- "#52514e"
GRID_C     <- "#e1e0d9"
PALE       <- "#c9c8c2"   # the many "possible" lines

open_png <- function(file, w = 1800, h = 1100, res = 170) {
  png(file.path(FIG_DIR, file), width = w, height = h, res = res)
}

## ---- data (CNU ch.3 Example 3.1) --------------------------------------

x <- c(1.9, 0.8, 1.1, 0.1, -0.1, 4.4, 4.6, 1.6, 5.5, 3.4)
y <- c(0.7, -1.0, -0.2, -1.2, -0.1, 3.4, 0.0, 0.8, 3.7, 2.0)
n <- length(x)

fit  <- lm(y ~ x)
b0   <- unname(coef(fit)[1])
b1   <- unname(coef(fit)[2])
xbar <- mean(x); ybar <- mean(y)

## ---- criterion functions ----------------------------------------------

# S(b) = sum of squared residuals for a line y = a0 + a1 x
S   <- function(a0, a1) sum((y - a0 - a1 * x)^2)
Sab <- function(a0, a1) sum(abs(y - a0 - a1 * x))   # sum of absolute residuals
Ssg <- function(a0, a1) sum(y - a0 - a1 * x)        # plain sum of residuals

## ---- candidate lines --------------------------------------------------

# (A) "eyeball" line joining the two extreme points of the cloud
iA <- which.min(x); iB <- which.max(x)
a1_A <- (y[iB] - y[iA]) / (x[iB] - x[iA])
a0_A <- y[iA] - a1_A * x[iA]

# (B) a line forced through the centroid (xbar, ybar) but too flat.
#     Any line through the centroid has sum(residuals) exactly 0, which is
#     precisely why the plain sum of residuals cannot order lines.
a1_B <- 0.4 * b1
a0_B <- ybar - a1_B * xbar

# (C) least absolute deviations (L1) line.  The L1 optimum is attained at a
#     line through at least two data points, so an exhaustive search over all
#     C(10,2) point pairs is exact (no optimiser needed).
best <- list(v = Inf)
for (i in 1:(n - 1)) for (j in (i + 1):n) {
  if (x[i] == x[j]) next
  s <- (y[j] - y[i]) / (x[j] - x[i]); a <- y[i] - s * x[i]
  v <- Sab(a, s)
  if (v < best$v) best <- list(v = v, a0 = a, a1 = s, pair = c(i, j))
}
a0_L1 <- best$a0; a1_L1 <- best$a1

cand <- data.frame(
  name = c("A (two extreme points)", "B (through centroid, flat)",
           "C (least absolute deviations)", "OLS (least squares)"),
  a0 = c(a0_A, a0_B, a0_L1, b0),
  a1 = c(a1_A, a1_B, a1_L1, b1)
)
cand$sum_e  <- mapply(Ssg, cand$a0, cand$a1)
cand$sum_ae <- mapply(Sab, cand$a0, cand$a1)
cand$sse    <- mapply(S,   cand$a0, cand$a1)

cat("\n===== candidate lines on CNU ch.3 Example 3.1 (n = 10) =====\n")
print(round(cand[, -1], 4), row.names = FALSE)
cat("\nnames:\n"); print(cand$name)
cat("\nOLS fit: intercept =", b0, " slope =", b1, "\n")
cat("centroid: xbar =", xbar, " ybar =", ybar, "\n")
cat("L1 line passes through points", best$pair, "\n")

# Which line wins under which criterion (this is the whole argument)
cat("\nminimiser of sum |e| :", cand$name[which.min(cand$sum_ae)], "\n")
cat("minimiser of sum e^2 :", cand$name[which.min(cand$sse)], "\n")
cat("lines with sum e == 0:", paste(cand$name[abs(cand$sum_e) < 1e-9],
                                    collapse = " / "), "\n")

## ---- fig-ls01: infinitely many candidate lines -------------------------

open_png("fig-ls01-candidate-lines.png", w = 1250, h = 1000, res = 205)
par(mar = c(4.4, 4.4, 3.0, 1.0), col.axis = INK2, col.lab = INK, fg = INK2)
plot(x, y, type = "n", ylim = c(-1.5, 4.0),
     panel.first = grid(col = GRID_C, lty = 1),
     main = "Which line is the best one?", xlab = "x", ylab = "y")

set.seed(20260825)
for (k in 1:45) {                     # a pale fan of arbitrary candidate lines
  s <- b1 + runif(1, -0.5, 0.5)
  a <- ybar - s * xbar + runif(1, -1.0, 1.0)
  abline(a = a, b = s, col = PALE, lwd = 1)
}
abline(a = a0_A, b = a1_A, col = COL_AQUA,   lwd = 3, lty = 2)
abline(a = a0_B, b = a1_B, col = COL_ORANGE, lwd = 3, lty = 4)
abline(a = b0,   b = b1,   col = COL_BLUE,   lwd = 3.5)

# one residual, drawn to the OLS line, to define r_i on the picture
i0 <- which(x == 3.4)
segments(x[i0], y[i0], x[i0], b0 + b1 * x[i0], col = COL_RED, lwd = 3)
text(x[i0] + 0.12, (y[i0] + b0 + b1 * x[i0]) / 2, labels = expression(r[i]),
     col = COL_RED, cex = 1.15, adj = 0)

points(x, y, pch = 21, bg = INK2, col = "white", cex = 1.7, lwd = 2)
legend("topleft", bty = "n", cex = 0.95, text.col = INK,
       lwd = c(1, 3, 3, 3.5), lty = c(1, 2, 4, 1),
       col = c(PALE, COL_AQUA, COL_ORANGE, COL_BLUE),
       legend = c("arbitrary lines", "line A", "line B", "line OLS"))
dev.off()

## ---- fig-ls02: the criterion is convex with a unique minimum -----------

open_png("fig-ls02-criterion-curve.png", w = 1150, h = 1000, res = 215)
par(mar = c(4.4, 4.6, 3.0, 1.0), col.axis = INK2, col.lab = INK, fg = INK2)
sl  <- seq(b1 - 0.85, b1 + 0.85, length.out = 400)
# at each slope the intercept is set to its best value ybar - slope * xbar,
# so the curve is the profile of S(b) along the slope axis
Ssl <- sapply(sl, function(s) S(ybar - s * xbar, s))
plot(sl, Ssl, type = "l", lwd = 3.5, col = COL_BLUE, ylim = c(8, 38),
     panel.first = grid(col = GRID_C, lty = 1),
     main = "The criterion ranks every line",
     xlab = "slope of the candidate line",
     ylab = "S(b) : sum of squared residuals")
points(b1,   S(b0, b1),      pch = 21, bg = COL_BLUE,   col = "white",
       cex = 1.9, lwd = 2)
points(a1_B, S(a0_B, a1_B),  pch = 21, bg = COL_ORANGE, col = "white",
       cex = 1.9, lwd = 2)
# the OLS label sits inside the bowl, above the minimum, clear of the curve;
# the line B label sits in the empty area below the descending left branch
text(b1, 12.8, labels = "OLS", col = COL_BLUE, adj = 0.5, cex = 1.1, font = 2)
text(a1_B - 0.06, S(a0_B, a1_B), labels = "line B", col = COL_ORANGE,
     adj = 1, cex = 1.1)
dev.off()

cat("\nfigures written to", FIG_DIR, "\n")
