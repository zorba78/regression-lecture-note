# Date        : 2026-11-26
# Description : Reproduce, from the raw data, every data-derived number and every
#               R-drawn figure of chapter 3 (Simple Linear Regression), in the
#               slide order of the canonical deck
#               quarto/agent/2026-08-26/03-simple-linear-regression.qmd.
#
#               Each section below is headed by the title of the slide it
#               serves.  Slides with definitions or algebra only (the derivation
#               slides, the proofs, the table structures) are skipped; their
#               numbers, where the speaker notes quote any, are recorded under
#               the slide that quotes them.
#
#               The code is MOVED, not rewritten: every block names the script
#               that originally produced the result, and only the output path was
#               changed.  Where two scripts used clashing names, the toy data of
#               CNU Example 3.1 keep the x3 / y3 names of the 2026-08-11 script
#               and their fit is suffixed _3.  Blocks with no earlier script
#               (the confidence intervals of the coefficients, the two intervals
#               at temp = 65, and 1/p) are marked NEW.
#
#               Output
#                 figures : output/agent/2026-11-26/reproduce/ch03/<same file
#                           name the deck references>.  The deck's own PNGs are
#                           never touched.
#                 numbers : printed to the console and written to
#                           output/agent/2026-11-26/reproduce/ch03/tab-ch03-numbers.csv
#                           (columns: slide, quantity, value; full precision)
#
#               Data
#                 ice cream     : references/cnu-regression-lecture-note/강의노트/
#                                 R 예제/7장/ice.csv.csv (n = 30; identical rows
#                                 to docs/data/ice.csv); y = IC, x = temp
#                 toy, n = 10   : CNU lecture note ch.3 Example 3.1, typed in below
#                 simulated     : fig-p01 (seed 11), fig-ls01 fan of lines
#                                 (seed 20260825), fig-s03 repetitions (seed 2026)
#
#               Run from the project root:
#                 Rscript code/agent/2026-11-26/reproduce-ch03-simple-linear-regression.R
# File        : reproduce-ch03-simple-linear-regression.R

options(digits = 10)

## ---- setup ------------------------------------------------------------

OUT <- "output/agent/2026-11-26/reproduce/ch03"
dir.create(OUT, recursive = TRUE, showWarnings = FALSE)

# Palette shared by the chapter 3 figures (identical in every source script)
COL_BLUE   <- "#2a78d6"   # least-squares line
COL_ORANGE <- "#eb6834"   # competing line / ML curve
COL_AQUA   <- "#1baf7a"   # third candidate line
COL_RED    <- "#e34948"   # residual segments, mean lines
COL_DARK   <- "#14324a"   # total deviation on the R-squared figure
INK        <- "#0b0b0b"
INK2       <- "#52514e"
GRID_C     <- "#e1e0d9"
PALE       <- "#c9c8c2"   # the many "possible" lines on fig-ls01

# Every number quoted on a slide (body or speaker notes) is printed through
# rec() and collected in `nums`, which is written to the CSV at the end.
nums <- data.frame(slide = character(0), quantity = character(0),
                   value = numeric(0), stringsAsFactors = FALSE)
rec <- function(slide, quantity, value) {
  nums[nrow(nums) + 1, ] <<- list(slide, quantity, unname(value))
  cat(sprintf("  %-62s %s\n", quantity, format(unname(value), digits = 7)))
}
hdr <- function(title) cat("\n==== ", title, " ====\n", sep = "")

## ---- data and the simple regression IC ~ temp -------------------------

ice <- read.csv("references/cnu-regression-lecture-note/강의노트/R 예제/7장/ice.csv.csv",
                stringsAsFactors = FALSE)
x <- ice$temp
y <- ice$IC
n <- length(x)

# Sums of squares in deviation form, as defined on the derivation slide
xbar <- mean(x); ybar <- mean(y)
Sxx  <- sum((x - xbar)^2)
Sxy  <- sum((x - xbar) * (y - ybar))
Syy  <- sum((y - ybar)^2)
sx   <- sd(x); sy <- sd(y)
r_xy <- cor(x, y)

fit <- lm(IC ~ temp, data = ice)
b0  <- coef(fit)[1]
b1  <- coef(fit)[2]
SSE <- sum(resid(fit)^2)
s2  <- SSE / (n - 2)                     # sigma^2 hat, unbiased
se_b1 <- sqrt(s2 / Sxx)
se_b0 <- sqrt(s2 * (1 / n + xbar^2 / Sxx))
ct  <- summary(fit)$coefficients

## =====================================================================
## Slide: 공분산의 착안: 편차의 곱  (fig-p01, simulated)
## Source: code/agent/2026-08-25/make-quadrant-figure.R
## =====================================================================
hdr("공분산의 착안: 편차의 곱")
set.seed(11)
xa <- rnorm(60); ya <-  0.85 * xa + rnorm(60, sd = 0.55)
xb <- rnorm(60); yb <- -0.85 * xb + rnorm(60, sd = 0.55)
# Console only: the r printed in the two panel titles
cat(sprintf("  panel r: positive %.2f, negative %.2f\n", cor(xa, ya), cor(xb, yb)))

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

png(file.path(OUT, "fig-p01-quadrant-signs.png"), width = 2000, height = 780, res = 170)
par(mfrow = c(1, 2), mar = c(4.3, 4.3, 3.2, 1),
    col.axis = INK2, col.lab = INK, fg = INK2)
quad_panel(xa, ya, sprintf("Positive association (r = %.2f)", cor(xa, ya)))
quad_panel(xb, yb, sprintf("Negative association (r = %.2f)", cor(xb, yb)))
dev.off()

## =====================================================================
## Slide: 상관계수: r=0 의 함정  (fig-p02)
## Source: code/agent/2026-08-13/make-restructure-figures.R
## =====================================================================
s <- "상관계수: r=0 의 함정"
hdr(s)
xq <- seq(-7, 7, length.out = 60)
yq <- 50 - xq^2
rec(s, "corr(x, 50 - x^2) on a symmetric grid of 60 points", cor(xq, yq))

png(file.path(OUT, "fig-p02-zero-correlation.png"), width = 1500, height = 1050, res = 170)
par(mar = c(4.5, 4.5, 3.2, 1), col.axis = INK2, col.lab = INK, fg = INK2)
plot(xq, yq, pch = 16, col = INK2, cex = 1.1,
     panel.first = grid(col = GRID_C, lty = 1),
     main = sprintf("Perfect relation y = 50 - x^2, yet r = %.2f", cor(xq, yq)),
     xlab = "x", ylab = "y")
abline(lm(yq ~ xq), col = COL_BLUE, lwd = 3)
dev.off()

## Slide 상관계수: 산점도와 상관계수 uses fig-p08-correlation-types.png, a
## rasterised copy of an SVG from the earlier UST lecture note
## (code/agent/2026-08-31/convert-correlation-types-figure.py).  It was not
## drawn by R in this project, so it is not reproduced here.

## =====================================================================
## Slide: 예제 자료: 아이스크림 소비량  (first five rows, summary, cov, r)
## Source: code/agent/2026-08-13/make-restructure-figures.R
## =====================================================================
s <- "예제 자료: 아이스크림 소비량"
hdr(s)
print(head(ice[, c("period", "IC", "price", "income", "temp", "year")], 5))
rec(s, "number of periods (n)", n)
rec(s, "number of variables", ncol(ice))
rec(s, "mean of temp (x)", xbar)
rec(s, "SD of temp (s_x)", sx)
rec(s, "mean of IC (y)", ybar)
rec(s, "SD of IC (s_y)", sy)
rec(s, "cov(y, x) = Sxy/(n-1)", Sxy / (n - 1))
rec(s, "s_y * s_x", sy * sx)
rec(s, "r = cov/(s_y s_x)", r_xy)

## =====================================================================
## Slide: 후보 직선의 비교  (fig-ls01, toy data n = 10)
## Source: code/agent/2026-08-25/make-ls-rationale-figures.R
## =====================================================================
s <- "후보 직선의 비교"
hdr(s)
# CNU ch.3 Example 3.1 toy data, also used by fig02 and fig-ls02
x3 <- c(1.9, 0.8, 1.1, 0.1, -0.1, 4.4, 4.6, 1.6, 5.5, 3.4)
y3 <- c(0.7, -1.0, -0.2, -1.2, -0.1, 3.4, 0.0, 0.8, 3.7, 2.0)
n3 <- length(x3)
rec(s, "points in the toy scatter", n3)

fit3  <- lm(y3 ~ x3)
b0_3  <- unname(coef(fit3)[1])
b1_3  <- unname(coef(fit3)[2])
xbar3 <- mean(x3); ybar3 <- mean(y3)

# Three criteria for a line y = a0 + a1 x
S   <- function(a0, a1) sum((y3 - a0 - a1 * x3)^2)     # sum of squared residuals
Sab <- function(a0, a1) sum(abs(y3 - a0 - a1 * x3))    # sum of absolute residuals
Ssg <- function(a0, a1) sum(y3 - a0 - a1 * x3)         # plain sum of residuals

# (A) line joining the two extreme points of the cloud
iA <- which.min(x3); iB <- which.max(x3)
a1_A <- (y3[iB] - y3[iA]) / (x3[iB] - x3[iA])
a0_A <- y3[iA] - a1_A * x3[iA]
# (B) a line through the centroid but too flat: sum of residuals is exactly 0
a1_B <- 0.4 * b1_3
a0_B <- ybar3 - a1_B * xbar3
# (C) least absolute deviations line.  The L1 optimum passes through at least
#     two data points, so the search over all C(10,2) pairs is exact.
best <- list(v = Inf)
for (i in 1:(n3 - 1)) for (j in (i + 1):n3) {
  if (x3[i] == x3[j]) next
  sl <- (y3[j] - y3[i]) / (x3[j] - x3[i]); a <- y3[i] - sl * x3[i]
  v <- Sab(a, sl)
  if (v < best$v) best <- list(v = v, a0 = a, a1 = sl, pair = c(i, j))
}
a0_L1 <- best$a0; a1_L1 <- best$a1

cand <- data.frame(
  name = c("A", "B", "C", "OLS"),
  a0 = c(a0_A, a0_B, a0_L1, b0_3),
  a1 = c(a1_A, a1_B, a1_L1, b1_3)
)
cand$sum_e  <- mapply(Ssg, cand$a0, cand$a1)
cand$sum_ae <- mapply(Sab, cand$a0, cand$a1)
cand$sse    <- mapply(S,   cand$a0, cand$a1)

png(file.path(OUT, "fig-ls01-candidate-lines.png"), width = 1250, height = 1000, res = 205)
par(mar = c(4.4, 4.4, 3.0, 1.0), col.axis = INK2, col.lab = INK, fg = INK2)
plot(x3, y3, type = "n", ylim = c(-1.5, 4.0),
     panel.first = grid(col = GRID_C, lty = 1),
     main = "Which line is the best one?", xlab = "x", ylab = "y")
set.seed(20260825)
for (k in 1:45) {                     # a pale fan of arbitrary candidate lines
  sl <- b1_3 + runif(1, -0.5, 0.5)
  a  <- ybar3 - sl * xbar3 + runif(1, -1.0, 1.0)
  abline(a = a, b = sl, col = PALE, lwd = 1)
}
abline(a = a0_A, b = a1_A, col = COL_AQUA,   lwd = 3, lty = 2)
abline(a = a0_B, b = a1_B, col = COL_ORANGE, lwd = 3, lty = 4)
abline(a = b0_3, b = b1_3, col = COL_BLUE,   lwd = 3.5)
# one residual, drawn to the OLS line, to define r_i on the picture
i0 <- which(x3 == 3.4)
segments(x3[i0], y3[i0], x3[i0], b0_3 + b1_3 * x3[i0], col = COL_RED, lwd = 3)
text(x3[i0] + 0.12, (y3[i0] + b0_3 + b1_3 * x3[i0]) / 2, labels = expression(r[i]),
     col = COL_RED, cex = 1.15, adj = 0)
points(x3, y3, pch = 21, bg = INK2, col = "white", cex = 1.7, lwd = 2)
legend("topleft", bty = "n", cex = 0.95, text.col = INK,
       lwd = c(1, 3, 3, 3.5), lty = c(1, 2, 4, 1),
       col = c(PALE, COL_AQUA, COL_ORANGE, COL_BLUE),
       legend = c("arbitrary lines", "line A", "line B", "line OLS"))
dev.off()

## =====================================================================
## Slide: 최소제곱 기준  (fig02, toy data n = 10)
## Source: code/agent/2026-08-11/make-lecture-figures.R
## =====================================================================
hdr("최소제곱 기준")
png(file.path(OUT, "fig02-least-squares-idea.png"), width = 1800, height = 1100, res = 170)
par(mar = c(4.5, 4.5, 3, 1), col.axis = INK2, col.lab = INK, fg = INK2)
plot(x3, y3, pch = 16, col = INK2, cex = 1.3,
     panel.first = grid(col = GRID_C, lty = 1),
     main = "Least Squares: Minimize the Sum of Squared Vertical Gaps",
     xlab = "x", ylab = "y")
segments(x3, y3, x3, fitted(fit3), col = COL_RED, lwd = 2)
abline(fit3, col = COL_BLUE, lwd = 3)
legend("topleft", bty = "n", lwd = c(3, 2), col = c(COL_BLUE, COL_RED),
       legend = c("Least-squares line", "Residual (vertical gap)"),
       text.col = INK)
dev.off()

## =====================================================================
## Slide: 제곱합을 기준으로 삼는 이유  (four lines x three criteria, fig-ls02)
## Source: code/agent/2026-08-25/make-ls-rationale-figures.R
## =====================================================================
s <- "제곱합을 기준으로 삼는 이유"
hdr(s)
print(cand, digits = 4, row.names = FALSE)
for (k in seq_len(nrow(cand))) {
  rec(s, sprintf("line %s intercept", cand$name[k]), cand$a0[k])
  rec(s, sprintf("line %s slope", cand$name[k]), cand$a1[k])
  rec(s, sprintf("line %s sum of residuals", cand$name[k]), cand$sum_e[k])
  rec(s, sprintf("line %s sum of |residuals|", cand$name[k]), cand$sum_ae[k])
  rec(s, sprintf("line %s sum of squared residuals", cand$name[k]), cand$sse[k])
}
cat("  L1 line passes through points", best$pair, "\n")

png(file.path(OUT, "fig-ls02-criterion-curve.png"), width = 1150, height = 1000, res = 215)
par(mar = c(4.4, 4.6, 3.0, 1.0), col.axis = INK2, col.lab = INK, fg = INK2)
sl  <- seq(b1_3 - 0.85, b1_3 + 0.85, length.out = 400)
# at each slope the intercept is set to its best value ybar - slope * xbar,
# so the curve is the profile of S(b) along the slope axis
Ssl <- sapply(sl, function(s) S(ybar3 - s * xbar3, s))
plot(sl, Ssl, type = "l", lwd = 3.5, col = COL_BLUE, ylim = c(8, 38),
     panel.first = grid(col = GRID_C, lty = 1),
     main = "The criterion ranks every line",
     xlab = "slope of the candidate line",
     ylab = "S(b) : sum of squared residuals")
points(b1_3, S(b0_3, b1_3), pch = 21, bg = COL_BLUE,   col = "white", cex = 1.9, lwd = 2)
points(a1_B, S(a0_B, a1_B), pch = 21, bg = COL_ORANGE, col = "white", cex = 1.9, lwd = 2)
text(b1_3, 12.8, labels = "OLS", col = COL_BLUE, adj = 0.5, cex = 1.1, font = 2)
text(a1_B - 0.06, S(a0_B, a1_B), labels = "line B", col = COL_ORANGE, adj = 1, cex = 1.1)
dev.off()

## =====================================================================
## Slide: 최소제곱법: 해의 성질  (fig-s02, the mean point)
## Source: code/agent/2026-08-27/make-mean-point-figure.R
## =====================================================================
s <- "최소제곱법: 해의 성질"
hdr(s)
yhat_at_xbar <- b0 + b1 * xbar
rec(s, "intercept b0", b0)
rec(s, "slope b1", b1)
rec(s, "mean of x", xbar)
rec(s, "b0 + b1 * xbar", yhat_at_xbar)
rec(s, "mean of y", ybar)
rec(s, "sum of residuals", sum(resid(fit)))

png(file.path(OUT, "fig-s02-mean-point.png"), width = 1950, height = 1000, res = 150)
xlim <- range(x) + c(-3, 2)
ylim <- range(y) + c(-0.022, 0.012)
par(mar = c(4.4, 5.0, 2.6, 1.2), family = "sans", cex.lab = 1.15, cex.axis = 1.05)
plot(x, y, type = "n", xlim = xlim, ylim = ylim,
     xlab = "Temperature (F)", ylab = "Ice cream consumption (pint)",
     main = "The least-squares line always passes through the mean point",
     cex.main = 1.25, font.main = 1, bty = "n", las = 1)
segments(xbar, ylim[1], xbar, ybar, lty = 2, col = "#b0b0b0")
segments(xlim[1], ybar, xbar, ybar, lty = 2, col = "#b0b0b0")
points(x, y, pch = 19, col = "#8a8a8a", cex = 1.15)
abline(fit, col = "#3b9ab2", lwd = 3)
points(xbar, ybar, pch = 21, bg = "#e8552d", col = "#ffffff", cex = 2.6, lwd = 2)
text(xbar + 0.8, ylim[1] + 0.004, adj = c(0, 0), col = "#52514e", cex = 1.12,
     labels = sprintf("mean of x = %.1f", xbar))
text(xlim[1] + 0.6, ybar + 0.006, adj = c(0, 0), col = "#52514e", cex = 1.12,
     labels = sprintf("mean of y = %.3f", ybar))
text(xbar + 1.6, ybar - 0.011, adj = c(0, 1), col = "#e8552d", cex = 1.5,
     labels = expression(paste("(", bar(x), ", ", bar(y), ")")))
legend("topleft", bty = "n", cex = 1.18, inset = c(0, -0.02),
       legend = c(sprintf("fitted line: y = %.3f + %.5f x", b0, b1), "mean point"),
       lty = c(1, NA), lwd = c(3, NA), pch = c(NA, 21),
       col = c("#3b9ab2", "#ffffff"), pt.bg = c(NA, "#e8552d"), pt.cex = c(NA, 1.9))
dev.off()

## =====================================================================
## Slide: 최대가능도법의 착안  (fig-s01-likelihood)
## Source: code/agent/2026-08-27/make-likelihood-figure.R
## =====================================================================
s <- "최대가능도법의 착안"
hdr(s)
s2_ml <- SSE / n           # maximum likelihood, divides by n
# Log-likelihood of the normal-error model
loglik <- function(b0, b1, s2) {
  r <- ice$IC - b0 - b1 * ice$temp
  -n / 2 * log(2 * pi) - n / 2 * log(s2) - sum(r^2) / (2 * s2)
}
rec(s, "peak of the log-likelihood over slopes (= b1)", b1)

png(file.path(OUT, "fig-s01-likelihood.png"), width = 2100, height = 950, res = 150)
par(mfrow = c(1, 2), mar = c(4.3, 4.6, 3.0, 1),
    col.axis = INK2, col.lab = INK, fg = INK2)
# left: the model, one bell per x
sig    <- sqrt(s2_ml)
x_show <- c(30, 50, 70)
SPAN   <- 2.6                              # each bell drawn over mu +/- 2.6 sigma
scale  <- 8 / dnorm(0, sd = sig)           # tallest bell spans about 8 x-units
mu_show <- b0 + b1 * x_show
ylim <- range(ice$IC, mu_show - SPAN * sig, mu_show + SPAN * sig)
xlim <- c(min(ice$temp) - 1, max(ice$temp) + 9)
plot(ice$temp, ice$IC, type = "n", xlim = xlim, ylim = ylim,
     main = "Each observation is drawn from its own bell",
     xlab = "Mean temperature (Fahrenheit)",
     ylab = "Ice cream consumption (pints per capita)")
grid(col = GRID_C, lty = 1); box(col = INK2)
abline(fit, col = COL_BLUE, lwd = 3)
for (x0 in x_show) {
  mu <- b0 + b1 * x0
  yy <- seq(mu - SPAN * sig, mu + SPAN * sig, length.out = 200)
  lines(x0 + scale * dnorm(yy, mu, sig), yy, col = COL_ORANGE, lwd = 2.4)
  segments(x0, mu - SPAN * sig, x0, mu + SPAN * sig, col = INK2, lty = 3)
  points(x0, mu, pch = 16, col = COL_BLUE, cex = 1.3)
}
points(ice$temp, ice$IC, pch = 16, col = adjustcolor(INK2, alpha.f = 0.55), cex = 1.2)
legend("topleft", bty = "o", bg = "white", box.col = GRID_C,
       lwd = c(3, 2.4), col = c(COL_BLUE, COL_ORANGE),
       legend = c("Fitted line: the mean at each x",
                  expression(paste("Normal density, same ", sigma, " everywhere"))),
       text.col = INK)
# right: the log-likelihood as the slope varies (intercept profiled out)
grid_b1 <- seq(b1 - 0.0020, b1 + 0.0020, length.out = 400)
ll <- sapply(grid_b1, function(bb) {
  a0 <- mean(ice$IC) - bb * mean(ice$temp)
  loglik(a0, bb, s2_ml)
})
plot(grid_b1, ll, type = "n",
     main = "Log-likelihood over candidate slopes",
     xlab = expression(paste("Candidate slope  ", beta[1])),
     ylab = "Log-likelihood")
grid(col = GRID_C, lty = 1); box(col = INK2)
lines(grid_b1, ll, col = COL_BLUE, lwd = 3.2)
abline(v = b1, col = COL_ORANGE, lwd = 2.4, lty = 2)
points(b1, loglik(b0, b1, s2_ml), pch = 16, col = COL_ORANGE, cex = 1.8)
text(b1, min(ll) + 0.28 * diff(range(ll)),
     labels = sprintf("peak at %.5f", b1), pos = 4, col = INK, cex = 0.95)
dev.off()

## =====================================================================
## Slide: 최대가능도 추정: 결과  (least squares vs maximum likelihood)
## Source: code/agent/2026-08-27/make-likelihood-figure.R
## =====================================================================
s <- "최대가능도 추정: 결과"
hdr(s)
# Recover the estimates by numerical maximisation of the likelihood, without
# the normal equations; it must land on the lm() coefficients
nll <- function(p) -loglik(p[1], p[2], exp(p[3]))
opt <- optim(c(0, 0, log(var(ice$IC))), nll, method = "Nelder-Mead",
             control = list(maxit = 20000, reltol = 1e-14))
rec(s, "least squares b1", b1)
rec(s, "maximum likelihood b1 (optim)", opt$par[2])
rec(s, "least squares b0", b0)
rec(s, "maximum likelihood b0 (optim)", opt$par[1])
rec(s, "S = SSE", SSE)
rec(s, "sigma^2 least squares = S/(n-2)", s2)
rec(s, "sigma^2 maximum likelihood = S/n", s2_ml)
rec(s, "sigma^2 maximum likelihood (optim)", exp(opt$par[3]))
rec(s, "notes: ratio ML/LS = (n-2)/n (about 7% smaller)", s2_ml / s2)
cat(sprintf("  max log-likelihood: formula %.4f, logLik() %.4f\n",
            loglik(b0, b1, s2_ml), as.numeric(logLik(fit))))

## =====================================================================
## Slide: 공분산, 상관계수, 회귀계수의 관계  (speaker notes)
## Source: code/agent/2026-08-13/make-restructure-figures.R
## =====================================================================
s <- "공분산, 상관계수, 회귀계수의 관계"
hdr(s)
rec(s, "notes: r", r_xy)
rec(s, "notes: slope b1", b1)
rec(s, "notes: s_y", sy)
rec(s, "notes: s_x", sx)

## =====================================================================
## Slide: 적합 결과: 아이스크림 자료  (fig01; four routes to the slope)
## Source: figure from code/agent/2026-08-11/make-lecture-figures.R;
##         routes from code/agent/2026-08-13/make-restructure-figures.R
## =====================================================================
s <- "적합 결과: 아이스크림 자료"
hdr(s)
rec(s, "intercept b0", b0)
rec(s, "slope b1", b1)
rec(s, "notes: 10 * b1 (change for 10 F)", 10 * b1)
rec(s, "s_x^2", sx^2)
rec(s, "route 1: Sxy/Sxx", Sxy / Sxx)
rec(s, "route 2: cov(y,x)/s_x^2", (Sxy / (n - 1)) / sx^2)
rec(s, "route 3: r * s_y/s_x", r_xy * sy / sx)
rec(s, "route 4: normal equations (lm)", coef(lm(y ~ x))[2])

png(file.path(OUT, "fig01-what-is-regression.png"), width = 1800, height = 1100, res = 170)
par(mar = c(4.5, 4.5, 3, 1), col.axis = INK2, col.lab = INK, fg = INK2)
plot(ice$temp, ice$IC, pch = 16, col = INK2, cex = 1.2,
     panel.first = grid(col = GRID_C, lty = 1),
     main = "Ice Cream Consumption vs Temperature",
     xlab = "Mean temperature (deg F)",
     ylab = "Consumption (pints per capita)")
abline(fit, col = COL_BLUE, lwd = 3)
dev.off()

## =====================================================================
## Slide: Gauss-Markov 정리: 경쟁자로 확인  (fig-s03)
## Source: code/agent/2026-08-31/make-gauss-markov-figure.R
## =====================================================================
s <- "Gauss-Markov 정리: 경쟁자로 확인"
hdr(s)
var_ols <- s2 / Sxx                          # = s2 * sum(c_i^2), c_i = (x-xbar)/Sxx
# The competitor: split at the median of x and join the two group means
hi <- x > median(x); lo <- !hi
nH <- sum(hi); nL <- sum(lo)
xH <- mean(x[hi]); xL <- mean(x[lo])
yH <- mean(y[hi]); yL <- mean(y[lo])
d  <- xH - xL
# d is fixed by x alone, so the estimator is a weighted sum sum(a_i y_i)
a  <- ifelse(hi, 1 / (nH * d), -1 / (nL * d))
b1_alt  <- sum(a * y)
sum_a2  <- sum(a^2)                          # = (1/nH + 1/nL)/d^2
var_alt <- s2 * sum_a2

rec(s, "notes: median of temp", median(x))
rec(s, "notes: periods above the median (n_H)", nH)
rec(s, "notes: periods at or below the median (n_L)", nL)
rec(s, "d = xbar_H - xbar_L", d)
rec(s, "sum(a_i) (must be 0)", sum(a))
rec(s, "sum(a_i x_i) (must be 1)", sum(a * x))
rec(s, "sum(a_i^2) = (1/n_H + 1/n_L)/d^2", sum_a2)
rec(s, "sum(c_i^2) = 1/Sxx", 1 / Sxx)
rec(s, "variance ratio Var(competitor)/Var(OLS)", var_alt / var_ols)
rec(s, "se of OLS slope", sqrt(var_ols))
rec(s, "se of competitor slope", sqrt(var_alt))
rec(s, "notes: OLS slope", b1)
rec(s, "notes: competitor slope", b1_alt)

# Panel (b): the fitted model taken as the truth, experiment repeated B times
set.seed(2026)
B <- 20000
mu <- b0 + b1 * x
sim <- replicate(B, {
  ys <- mu + rnorm(n, 0, sqrt(s2))
  c(sum((x - mean(x)) * ys) / Sxx, sum(a * ys))
})
rec(s, "notes: number of simulated repetitions", B)
cat(sprintf("  sim OLS mean = %.7f, sd = %.7f (theory %.7f)\n",
            mean(sim[1, ]), sd(sim[1, ]), sqrt(var_ols)))
cat(sprintf("  sim alt mean = %.7f, sd = %.7f (theory %.7f)\n",
            mean(sim[2, ]), sd(sim[2, ]), sqrt(var_alt)))

png(file.path(OUT, "fig-s03-gauss-markov.png"),
    width = 2100, height = 720, res = 150, pointsize = 17)
par(mfrow = c(1, 2), mar = c(4.2, 4.6, 3.0, 1),
    col.axis = INK2, col.lab = INK, fg = INK2)
# (a) the two lines on the same scatter; the competitor is dashed
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
# (b) the two sampling distributions, zoomed to +/- 4 competitor SEs
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

## =====================================================================
## Slide: 회귀계수의 분산과 공분산
## Source: code/agent/2026-08-28/verify-simple-regression-inference.R, section (2)
## =====================================================================
s <- "회귀계수의 분산과 공분산"
hdr(s)
cov01 <- -s2 * xbar / Sxx
rec(s, "sigma^2 hat = SSE/(n-2)", s2)
rec(s, "se(b1) = sigma-hat/sqrt(Sxx)", se_b1)
rec(s, "se(b0) = sigma-hat*sqrt(1/n + xbar^2/Sxx)", se_b0)
rec(s, "Cov(b0, b1) = -sigma^2 hat * xbar/Sxx", cov01)
rec(s, "mean of x", xbar)
rec(s, "Sxx", Sxx)
rec(s, "temp minimum", min(x))
rec(s, "temp maximum", max(x))
cat(sprintf("  check against lm: max |se - lm se| = %.3e, |cov - vcov| = %.3e\n",
            max(abs(c(se_b0, se_b1) - ct[, 2])), abs(cov01 - vcov(fit)[1, 2])))

## =====================================================================
## Slide: 오차분산의 추정: E(sigma^2 hat) = sigma^2  (speaker notes)
## Source: code/agent/2026-08-31/verify-sigma2-unbiased.R, checks (1) and (2)
##         (its simulation, check (3), produces no number on the slide)
## =====================================================================
s <- "오차분산의 추정: E(sigma^2 hat)=sigma^2"
hdr(s)
SSR <- b1^2 * Sxx
cat(sprintf("  identity SSE = Syy - b1^2 Sxx: gap = %.3e\n", abs((Syy - SSR) - SSE)))
rec(s, "notes: Syy", Syy)
rec(s, "notes: b1^2 * Sxx (explained part)", SSR)
rec(s, "notes: SSE", SSE)
rec(s, "notes: SSE/(n-2)", s2)
rec(s, "notes: sigma hat", sqrt(s2))
rec(s, "notes: (n-2)/n", (n - 2) / n)

## =====================================================================
## Slide: 기울기의 표준오차
## Source: code/agent/2026-08-28/verify-simple-regression-inference.R, section (2)
## =====================================================================
s <- "기울기의 표준오차"
hdr(s)
rec(s, "sigma^2 hat", s2)
rec(s, "sigma hat", sqrt(s2))
rec(s, "Sxx = (n-1) s_x^2", (n - 1) * sx^2)
rec(s, "se(b1) = sqrt(sigma^2 hat/Sxx)", se_b1)

## =====================================================================
## Slide: 회귀계수 검정: 결과와 p값
## Source: code/agent/2026-08-28/verify-simple-regression-inference.R
##         (1/p is NEW)
## =====================================================================
s <- "회귀계수 검정: 결과와 p값"
hdr(s)
print(ct)
rec(s, "intercept estimate", ct[1, 1])
rec(s, "intercept se", ct[1, 2])
rec(s, "intercept t", ct[1, 3])
rec(s, "intercept p-value", ct[1, 4])
rec(s, "slope estimate", ct[2, 1])
rec(s, "slope se", ct[2, 2])
rec(s, "slope t", ct[2, 3])
rec(s, "slope p-value", ct[2, 4])
rec(s, "1/p for the slope (NEW)", 1 / ct[2, 4])
rec(s, "df", n - 2)

## =====================================================================
## Slide: 결정계수 R^2: 변동의 분해  (fig-s01-r2-decomposition)
## Source: code/agent/2026-08-25/make-r2-decomposition-figure.R
## =====================================================================
s <- "결정계수 R^2: 변동의 분해"
hdr(s)
yh  <- fitted(fit)
SST <- sum((ice$IC - ybar)^2)
SSR_f <- sum((yh - ybar)^2)
SSE_f <- sum((ice$IC - yh)^2)
rec(s, "notes: SSR", SSR_f)
rec(s, "notes: SSE", SSE_f)
rec(s, "notes: SST", SST)
rec(s, "notes: R^2 = SSR/SST", SSR_f / SST)

# The annotated observation: line well above ybar, point well above the line
score <- (yh - ybar) * (ice$IC - yh)
i0    <- which.max(ifelse(yh > ybar & ice$IC > yh, score, -Inf))
x0 <- ice$temp[i0]; y0 <- ice$IC[i0]; h0 <- yh[i0]
cat(sprintf("  annotated point: temp %.0f, IC %.3f, fitted %.3f, ybar %.3f\n",
            x0, y0, h0, ybar))

png(file.path(OUT, "fig-s01-r2-decomposition.png"), width = 2300, height = 950, res = 190)
layout(matrix(1:2, nrow = 1), widths = c(1.35, 1))
# (a) one observation, dissected
par(mar = c(4.4, 4.4, 3.2, 1.0), col.axis = INK2, col.lab = INK, fg = INK2)
plot(ice$temp, ice$IC, type = "n", xlim = c(min(ice$temp), max(ice$temp) + 11),
     panel.first = grid(col = GRID_C, lty = 1),
     main = "(a) One observation, split in two",
     xlab = "Mean temperature (deg F)", ylab = "Consumption (pints per capita)")
abline(h = ybar, col = INK2, lwd = 2, lty = 2)
abline(fit, col = COL_BLUE, lwd = 3)
points(ice$temp, ice$IC, pch = 16, col = adjustcolor(INK2, alpha.f = 0.35), cex = 1.0)
dd <- 1.6                                   # horizontal offset for the total bar
segments(x0 - dd, ybar, x0 - dd, y0, col = COL_DARK, lwd = 5)   # y - ybar
segments(x0,      ybar, x0,      h0, col = COL_BLUE, lwd = 5)   # yhat - ybar
segments(x0,      h0,   x0,      y0, col = COL_RED,  lwd = 5)   # y - yhat
points(x0, y0, pch = 16, col = INK, cex = 1.5)
text(x0 - dd - 0.8, (ybar + y0) / 2, expression(y[i] - bar(y)),
     col = COL_DARK, adj = 1, cex = 0.95)
text(x0 + 0.8, (ybar + h0) / 2, expression(hat(y)[i] - bar(y)),
     col = COL_BLUE, adj = 0, cex = 0.95)
text(x0 + 0.8, (h0 + y0) / 2, expression(y[i] - hat(y)[i]),
     col = COL_RED, adj = 0, cex = 0.95)
text(min(ice$temp), ybar, expression(bar(y)), col = INK2, adj = c(0.4, -0.6), cex = 1.0)
legend("bottomright", bty = "n", cex = 0.85, text.col = INK,
       lwd = 4, col = c(COL_DARK, COL_BLUE, COL_RED),
       legend = c("total", "explained by the line", "left over"))
# (b) the same split over all n observations
par(mar = c(4.4, 1.0, 3.2, 1.0))
plot(0, 0, type = "n", xlim = c(0, 1), ylim = c(0, 1),
     axes = FALSE, xlab = "", ylab = "",
     main = "(b) Adding the squares over all n = 30")
pp <- SSR_f / SST
rect(0.10, 0.52, 0.10 + 0.80 * pp, 0.72, col = COL_BLUE, border = "white")
rect(0.10 + 0.80 * pp, 0.52, 0.90, 0.72, col = COL_RED, border = "white")
rect(0.10, 0.52, 0.90, 0.72, col = NA, border = COL_DARK, lwd = 2)
text(0.10 + 0.40 * pp, 0.62, sprintf("SSR  %.3f", SSR_f), col = "white",
     font = 2, cex = 0.95)
text(0.10 + 0.80 * pp + 0.40 * (1 - pp), 0.62, sprintf("SSE  %.3f", SSE_f),
     col = "white", font = 2, cex = 0.95)
text(0.50, 0.80, sprintf("SST  %.3f", SST), col = COL_DARK, font = 2, cex = 1.05)
arrows(0.10, 0.76, 0.90, 0.76, code = 3, length = 0.06, col = COL_DARK, lwd = 1.5)
text(0.50, 0.33, expression(R^2 == SSR / SST), col = INK, cex = 1.25)
text(0.50, 0.20, sprintf("= %.3f / %.3f = %.3f", SSR_f, SST, SSR_f / SST),
     col = INK, cex = 1.10)
text(0.50, 0.07, "the line explains 60.2% of the spread in y",
     col = INK2, font = 3, cex = 0.90)
dev.off()

## =====================================================================
## Slide: 결정계수와 상관계수
## Source: code/agent/2026-08-13/make-restructure-figures.R
## =====================================================================
s <- "결정계수와 상관계수"
hdr(s)
rec(s, "r = corr(y, x)", r_xy)
rec(s, "r^2", r_xy^2)
rec(s, "R^2 of the fitted model", summary(fit)$r.squared)

## =====================================================================
## Slide: 회귀분산분석표: F=t^2 확인
## Source: code/agent/2026-08-28/verify-simple-regression-inference.R, section (4)
## =====================================================================
s <- "회귀분산분석표: F=t^2 확인"
hdr(s)
av  <- anova(fit)
print(av)
MSE <- SSE / (n - 2)
Fst <- (SST - SSE) / MSE
tst <- b1 / se_b1
rec(s, "df regression", av$Df[1])
rec(s, "df residual", av$Df[2])
rec(s, "df total", n - 1)
rec(s, "SSR", av$`Sum Sq`[1])
rec(s, "SSE", av$`Sum Sq`[2])
rec(s, "SST", SST)
rec(s, "MSR", av$`Mean Sq`[1])
rec(s, "MSE", av$`Mean Sq`[2])
rec(s, "F", Fst)
rec(s, "p-value of F", pf(Fst, 1, n - 2, lower.tail = FALSE))
rec(s, "t = b1/se(b1)", tst)
rec(s, "t^2", tst^2)
rec(s, "F(0.95; 1, 28)", qf(0.95, 1, n - 2))
rec(s, "t(0.975; 28)", qt(0.975, n - 2))
rec(s, "t(0.975; 28)^2", qt(0.975, n - 2)^2)
rec(s, "sqrt(MSE) = sigma hat", sqrt(MSE))
rec(s, "R^2 = SSR/SST", (SST - SSE) / SST)

## =====================================================================
## Slide: 회귀계수의 신뢰구간  (95%, df = 28)
## Source: NEW (no earlier script computed these intervals)
## =====================================================================
s <- "회귀계수의 신뢰구간"
hdr(s)
tq <- qt(0.975, n - 2)
ci <- confint(fit, level = 0.95)
print(ci)
rec(s, "t(0.975; 28)", tq)
rec(s, "slope estimate", b1)
rec(s, "slope se", se_b1)
rec(s, "slope half-width t*se(b1)", tq * se_b1)
rec(s, "slope lower limit", ci[2, 1])
rec(s, "slope upper limit", ci[2, 2])
rec(s, "intercept estimate", b0)
rec(s, "intercept se", se_b0)
rec(s, "intercept half-width t*se(b0)", tq * se_b0)
rec(s, "intercept lower limit", ci[1, 1])
rec(s, "intercept upper limit", ci[1, 2])

## =====================================================================
## Slide: 두 구간의 수치 비교  (temp = 65)
## Source: NEW (no earlier script computed the two intervals at temp = 65)
## =====================================================================
s <- "두 구간의 수치 비교"
hdr(s)
x0  <- 65
new <- data.frame(temp = x0)
cc0 <- 1 / n + (x0 - xbar)^2 / Sxx
pci <- predict(fit, new, interval = "confidence", level = 0.95)
ppi <- predict(fit, new, interval = "prediction", level = 0.95)
print(rbind(confidence = pci[1, ], prediction = ppi[1, ]))
hw_ci <- tq * sqrt(s2) * sqrt(cc0)
hw_pi <- tq * sqrt(s2) * sqrt(1 + cc0)
rec(s, "fitted value at temp = 65", pci[1, "fit"])
rec(s, "x0 - xbar", x0 - xbar)
rec(s, "c = 1/n + (x0 - xbar)^2/Sxx", cc0)
rec(s, "confidence half-width", hw_ci)
rec(s, "confidence lower limit", pci[1, "lwr"])
rec(s, "confidence upper limit", pci[1, "upr"])
rec(s, "prediction half-width", hw_pi)
rec(s, "prediction lower limit", ppi[1, "lwr"])
rec(s, "prediction upper limit", ppi[1, "upr"])
rec(s, "ratio of widths, prediction/confidence", hw_pi / hw_ci)

## =====================================================================
## Slide: 추정에서 검정까지: 계산 경로
## Source: code/agent/2026-08-28/verify-simple-regression-inference.R
## =====================================================================
s <- "추정에서 검정까지: 계산 경로"
hdr(s)
rec(s, "Sxx", Sxx)
rec(s, "Sxy", Sxy)
rec(s, "b1 = Sxy/Sxx", Sxy / Sxx)
rec(s, "b0 = ybar - b1 xbar", ybar - (Sxy / Sxx) * xbar)
rec(s, "SSE", SSE)
rec(s, "sigma^2 hat = SSE/(n-2)", s2)
rec(s, "sigma hat", sqrt(s2))
rec(s, "SE(b1)", se_b1)
rec(s, "t = b1/SE(b1)", tst)

## =====================================================================
## Slide: 계산 경로: 결과표와 각 항의 뜻
## Source: code/agent/2026-08-11/make-lecture-figures.R (summary of lm(IC ~ temp))
## =====================================================================
s <- "계산 경로: 결과표와 각 항의 뜻"
hdr(s)
rec(s, "intercept estimate", ct[1, 1])
rec(s, "intercept SE", ct[1, 2])
rec(s, "intercept t", ct[1, 3])
rec(s, "intercept p-value", ct[1, 4])
rec(s, "slope estimate", ct[2, 1])
rec(s, "slope SE", ct[2, 2])
rec(s, "slope t", ct[2, 3])
rec(s, "slope p-value", ct[2, 4])
rec(s, "residual standard error", summary(fit)$sigma)
rec(s, "residual df", fit$df.residual)
rec(s, "R-squared", summary(fit)$r.squared)
rec(s, "r", r_xy)
rec(s, "r^2", r_xy^2)

## =====================================================================
## Slide: 이 장의 정리
## Source: code/agent/2026-08-13/make-restructure-figures.R
## =====================================================================
s <- "이 장의 정리"
hdr(s)
rec(s, "covariance", Sxy / (n - 1))
rec(s, "correlation", r_xy)
rec(s, "slope", b1)
rec(s, "coefficient of determination", summary(fit)$r.squared)

## ---- numbers table ----------------------------------------------------

write.csv(nums, file.path(OUT, "tab-ch03-numbers.csv"), row.names = FALSE,
          fileEncoding = "UTF-8")
cat(sprintf("\n%d numbers written to %s\n", nrow(nums),
            file.path(OUT, "tab-ch03-numbers.csv")))
cat("figures written to", OUT, ":\n")
print(list.files(OUT, pattern = "\\.png$"))
