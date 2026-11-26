# Date        : 2026-11-26
# Description : Reproduce, from the raw data, every computed number and every
#               R-drawn figure of chapter 2 (Preliminary Knowledge), in the slide
#               order of the canonical deck
#               quarto/agent/2026-08-26/02-preliminary-knowledge.qmd.
#
#               Scope.  Two kinds of number are reproduced:
#                 (a) numbers computed from the ice cream data (first responses,
#                     det(X'X), rank, trace of the hat matrix, the fitted simple
#                     regression coefficients);
#                 (b) numbers that need a distribution function (normal coverage,
#                     t and F critical values, the illustrative p-value).
#               Toy-matrix examples whose arithmetic is written out on the slide
#               itself (13/23/33, AB vs BA, det = 8, 1, 0, 100, eigenvalues 3 and
#               1, J^2 = J, ...) are not data-derived and are skipped, as are
#               slides with definitions only.
#
#               The code is MOVED, not rewritten: every block names the script
#               that originally produced the result, and only the output path was
#               changed.  Blocks with no earlier script are marked NEW.
#
#               Output
#                 figures : output/agent/2026-11-26/reproduce/ch02/<same file
#                           name the deck references>.  The deck's own PNGs are
#                           never touched.
#                 numbers : printed to the console and written to
#                           output/agent/2026-11-26/reproduce/ch02/tab-ch02-numbers.csv
#                           (columns: slide, quantity, value; full precision)
#
#               Data
#                 ice cream : references/cnu-regression-lecture-note/강의노트/
#                             R 예제/7장/ice.csv.csv (n = 30; identical rows to
#                             docs/data/ice.csv)
#
#               Run from the project root:
#                 Rscript code/agent/2026-11-26/reproduce-ch02-preliminary-knowledge.R
# File        : reproduce-ch02-preliminary-knowledge.R

## ---- setup ------------------------------------------------------------

OUT <- "output/agent/2026-11-26/reproduce/ch02"
dir.create(OUT, recursive = TRUE, showWarnings = FALSE)

# Palette shared by the chapter 2 distribution figures
COL_BLUE   <- "#2a78d6"
COL_ORANGE <- "#eb6834"
COL_RED    <- "#e34948"
COL_AQUA   <- "#1baf7a"
INK        <- "#0b0b0b"
INK2       <- "#52514e"
GRID_C     <- "#e1e0d9"

# Every number quoted on a slide (body or speaker notes) is printed through
# rec() and collected in `nums`, which is written to the CSV at the end.
nums <- data.frame(slide = character(0), quantity = character(0),
                   value = numeric(0), stringsAsFactors = FALSE)
rec <- function(slide, quantity, value) {
  nums[nrow(nums) + 1, ] <<- list(slide, quantity, unname(value))
  cat(sprintf("  %-62s %s\n", quantity, format(unname(value), digits = 7)))
}
hdr <- function(title) cat("\n==== ", title, " ====\n", sep = "")

## ---- data -------------------------------------------------------------

ice <- read.csv("references/cnu-regression-lecture-note/강의노트/R 예제/7장/ice.csv.csv",
                stringsAsFactors = FALSE)

# Design matrix of the ice cream full model IC ~ price + income + temp
X <- cbind(1, ice$price, ice$income, ice$temp)
colnames(X) <- c("(Intercept)", "price", "income", "temp")
XtX <- t(X) %*% X
n <- nrow(X); p <- ncol(X) - 1

# temp in Celsius is an exact linear function of the intercept and temp:
#   tempC = -160/9 * 1 + 5/9 * temp, so appending it adds no rank
tempC <- (ice$temp - 32) * 5 / 9
X2 <- cbind(X, tempC = tempC)

## =====================================================================
## Slide: 전치  (first three ice cream responses)
## Source: code/agent/2026-08-26/verify-matrix-toolbox-numbers.R, section 0
## =====================================================================
s <- "전치"
hdr(s)
y3 <- matrix(ice$IC[1:3], ncol = 1)          # first three responses, 3 x 1
print(t(y3))
for (i in 1:3) rec(s, sprintf("y_%d (IC of period %d)", i, i), y3[i, 1])

## =====================================================================
## Slide: 행렬식: 넓이와 부피  (det(X'X) with and without a Celsius column)
## Source: code/agent/2026-08-26/verify-matrix-toolbox-numbers.R, section 2
## =====================================================================
s <- "행렬식: 넓이와 부피"
hdr(s)
rec(s, "det(X'X), full model, X is 30 x 4", det(XtX))
# With tempC appended X2'X2 is exactly singular; the printed determinant is
# whatever floating-point rounding leaves, so its digits are machine dependent.
rec(s, "det(X2'X2), Celsius column appended (30 x 5)", det(t(X2) %*% X2))
cat("  solve(X2'X2) -> ",
    tryCatch({ solve(t(X2) %*% X2); "no error" },
             error = function(e) paste("Error:", conditionMessage(e))), "\n")

## =====================================================================
## Slide: 행렬의 계수  (rank of the design matrix)
## Source: code/agent/2026-08-26/verify-matrix-toolbox-numbers.R, sections 2 and 2b
## =====================================================================
s <- "행렬의 계수"
hdr(s)
rec(s, "rows of X", nrow(X))
rec(s, "columns of X", ncol(X))
rec(s, "rank(X)", qr(X)$rank)
rec(s, "columns of X2 (Celsius appended)", ncol(X2))
rec(s, "rank(X2)", qr(X2)$rank)
rec(s, "rank(X'X)", qr(XtX)$rank)
rec(s, "rank(X2'X2)", qr(t(X2) %*% X2)$rank)

## =====================================================================
## Slide: 멱등행렬  (hat matrix of the ice cream full model)
## Source: code/agent/2026-08-26/verify-matrix-toolbox-numbers.R, section 6
##         code/agent/2026-08-27/verify-spectral-decomposition.R, block (3)
## =====================================================================
s <- "멱등행렬"
hdr(s)
H <- X %*% solve(XtX) %*% t(X)
cat(sprintf("  H symmetric : %s\n", isTRUE(all.equal(H, t(H)))))
cat(sprintf("  H idempotent: %s\n", isTRUE(all.equal(H %*% H, H))))
eh <- eigen(H, symmetric = TRUE)$values
rec(s, "eigenvalues of H equal to 1", sum(abs(eh - 1) < 1e-8))
rec(s, "eigenvalues of H equal to 0", sum(abs(eh) < 1e-8))
rec(s, "tr(H) (= p + 1)", sum(diag(H)))
rec(s, "tr(I - H) (= n - p - 1)", sum(diag(diag(n) - H)))

## =====================================================================
## Slide: 벡터와 행렬의 미분  (notes: the eigenvalues of X'X are all positive)
## Source: NEW (no earlier script printed the eigenvalues of X'X)
## =====================================================================
s <- "벡터와 행렬의 미분"
hdr(s)
ev <- eigen(XtX, symmetric = TRUE)$values
print(ev)
rec(s, "notes: number of positive eigenvalues of X'X", sum(ev > 0))
rec(s, "notes: smallest eigenvalue of X'X", min(ev))

## =====================================================================
## Slide: 정규분포: 68-95-99.7 규칙
## Source: NEW (no earlier script computed the coverage probabilities)
## =====================================================================
s <- "정규분포: 68-95-99.7 규칙"
hdr(s)
for (k in 1:3) rec(s, sprintf("P(|Z| <= %d)", k), 2 * pnorm(k) - 1)
rec(s, "P(|Z| > 3) (about 0.3%)", 2 * pnorm(-3))

## =====================================================================
## Slide: 카이제곱분포  (fig-p06)
## Source: code/agent/2026-08-24/make-chisq-f-figures.R
## =====================================================================
s <- "카이제곱분포"
hdr(s)
rec(s, "residual df of the ice cream full model, n - p - 1", n - p - 1)

xx <- seq(0.01, 30, length.out = 800)
png(file.path(OUT, "fig-p06-chisq.png"), width = 1800, height = 1050, res = 170)
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

## =====================================================================
## Slide: t분포  (fig-p03)
## Source: figure from code/agent/2026-08-13/make-restructure-figures.R;
##         critical values NEW except t(0.975; 28), which
##         code/agent/2026-08-28/verify-simple-regression-inference.R printed
## =====================================================================
s <- "t분포"
hdr(s)
for (dfk in c(3, 10, 28)) rec(s, sprintf("t(0.975; %d)", dfk), qt(0.975, dfk))
rec(s, "z(0.975), standard normal", qnorm(0.975))
rec(s, "df of the simple regression, n - 2", n - 2)

tt <- seq(-4.5, 4.5, length.out = 600)   # shared by fig-p03 and fig-p04
png(file.path(OUT, "fig-p03-normal-vs-t.png"), width = 1700, height = 1050, res = 170)
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

## =====================================================================
## Slide: F분포  (fig-p07)
## Source: code/agent/2026-08-24/make-chisq-f-figures.R
## =====================================================================
s <- "F분포"
hdr(s)
ff  <- seq(0.001, 6, length.out = 800)
df1 <- 3
df2 <- 26
f_crit <- qf(0.95, df1, df2)
rec(s, "F(0.95; 3, 26), 5% critical value", f_crit)
# Notes: the simple-regression t value 6.50 squared gives its F value
simple <- lm(IC ~ temp, data = ice)
t_val  <- coef(summary(simple))["temp", "t value"]
rec(s, "notes: t of the simple regression slope", t_val)
rec(s, "notes: t^2", t_val^2)
rec(s, "notes: F of the simple regression", anova(simple)[["F value"]][1])

png(file.path(OUT, "fig-p07-f-distribution.png"), width = 1800, height = 1050, res = 170)
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

## =====================================================================
## Slide: 점추정: 추정량과 추정값  (the two estimates of the simple regression)
## Source: code/agent/2026-08-11/make-lecture-figures.R (lm(IC ~ temp) summary)
## =====================================================================
s <- "점추정: 추정량과 추정값"
hdr(s)
rec(s, "estimate of beta0 (IC on temp)", coef(simple)[1])
rec(s, "estimate of beta1 (IC on temp)", coef(simple)[2])

## =====================================================================
## Slide: 신뢰구간
## Source: code/agent/2026-08-28/verify-simple-regression-inference.R
## =====================================================================
s <- "신뢰구간"
hdr(s)
rec(s, "t(0.975; 28)", qt(0.975, 28))

## =====================================================================
## Slide: p-value: 정의  (fig-p04; illustrative |t| = 2.20 on 28 df)
## Source: code/agent/2026-08-13/make-restructure-figures.R
## =====================================================================
s <- "p-value: 정의"
hdr(s)
df_ex <- 28          # n - 2 for the ice cream simple regression
t_obs <- 2.20        # an illustrative observed t value (not from data)
rec(s, "two-sided p-value, |t| = 2.20, 28 df", 2 * pt(t_obs, df_ex, lower.tail = FALSE))

png(file.path(OUT, "fig-p04-pvalue-tail.png"), width = 1700, height = 1050, res = 170)
par(mar = c(4.5, 4.5, 3.2, 1), col.axis = INK2, col.lab = INK, fg = INK2)
plot(tt, dt(tt, df_ex), type = "l", lwd = 3, col = COL_BLUE,
     panel.first = grid(col = GRID_C, lty = 1),
     main = sprintf("Two-sided p-value: shaded area beyond |t| = %.2f", t_obs),
     xlab = "t", ylab = "density")
for (sg in c(1, -1)) {
  xs <- seq(sg * t_obs, sg * 4.5, length.out = 200)
  polygon(c(xs, rev(xs)), c(dt(xs, df_ex), rep(0, length(xs))),
          col = adjustcolor(COL_RED, alpha.f = 0.35), border = NA)
}
abline(v = c(-t_obs, t_obs), col = COL_RED, lwd = 2, lty = 2)
dev.off()

## Slide 좋은 추정량: 편의와 변동성 uses fig-p09-bias-variance-target.svg,
## reused from the earlier UST lecture note.  It was not drawn by R in this
## project, so it is not reproduced here.

## ---- numbers table ----------------------------------------------------

write.csv(nums, file.path(OUT, "tab-ch02-numbers.csv"), row.names = FALSE,
          fileEncoding = "UTF-8")
cat(sprintf("\n%d numbers written to %s\n", nrow(nums),
            file.path(OUT, "tab-ch02-numbers.csv")))
cat("figures written to", OUT, ":\n")
print(list.files(OUT, pattern = "\\.png$"))
