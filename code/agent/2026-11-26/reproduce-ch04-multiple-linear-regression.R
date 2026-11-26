# Date        : 2026-11-26
# Description : Chapter 4 (Multiple Linear Regression) reproduction script.
#               Recomputes, from the raw ice cream data, every data-derived number
#               shown on the chapter 4 deck
#                 quarto/agent/2026-08-26/04-multiple-linear-regression.qmd
#               and redraws every R-generated figure that deck links to. Sections
#               follow the slide order of the deck; each section comment carries
#               the slide title verbatim. Slides that hold only theory or
#               definitions (no number computed from data, no R figure) are listed
#               in a one-line comment at the point where they occur and skipped.
#
#               Numbers flagged "[notes]" appear only in the speaker notes of the
#               slide, not in the slide body.
#
#               The code is NOT new: each block is copied from the script that
#               originally produced that figure or number, with only the output
#               path (and, where two scripts are merged, the R object names)
#               changed. Source scripts:
#                 code/agent/2026-08-11/make-lecture-figures.R      (fig03, models)
#                 code/agent/2026-08-13/make-restructure-figures.R  (fig-p05, H)
#                 code/agent/2026-08-26/verify-matrix-toolbox-numbers.R (det X'X)
#                 code/agent/2026-08-27/verify-multiple-regression.R (sections 1-7)
#                 code/agent/2026-08-27/make-added-variable-figure.R (fig-m02)
#                 code/agent/2026-08-27/make-r2-adjr2-schematic.R   (fig-m01)
#                 code/agent/2026-08-28/make-df-decomposition-figure.R (fig-m03)
#                 code/agent/2026-11-25/verify-fwl-auxiliary-coefficients.R (FWL)
#                 code/agent/2026-11-26/check-r9-numbers.R          (S(b), partial F)
#
#               Data: ice cream consumption, CNU lecture note R examples, chapter 7
#               (references/cnu-regression-lecture-note/강의노트/R 예제/7장/ice.csv.csv,
#               n = 30; identical in content to docs/data/ice.csv). Same path as
#               the original scripts.
#
#               Outputs (and ONLY these; the PNGs the deck links to are never
#               touched):
#                 output/agent/2026-11-26/reproduce/ch04/<same file names as the deck>
#                 output/agent/2026-11-26/reproduce/ch04/tab-ch04-numbers.csv
#                   (columns: slide, quantity, value)
#
#               Run from the project root:
#                 Rscript code/agent/2026-11-26/reproduce-ch04-multiple-linear-regression.R
# File        : reproduce-ch04-multiple-linear-regression.R

options(digits = 10)

## ---- setup -------------------------------------------------------------------

FIG_DIR <- "output/agent/2026-11-26/reproduce/ch04"
dir.create(FIG_DIR, recursive = TRUE, showWarnings = FALSE)

# Colours copied from make-lecture-figures.R / make-restructure-figures.R
COL_BLUE   <- "#2a78d6"
COL_ORANGE <- "#eb6834"
COL_AQUA   <- "#1baf7a"
INK        <- "#0b0b0b"
INK2       <- "#52514e"

ice <- read.csv(
  "references/cnu-regression-lecture-note/강의노트/R 예제/7장/ice.csv.csv",
  header = TRUE
)
n <- nrow(ice)                                     # 30 four-week periods

# Every number that is compared with the deck is printed to the console and
# appended to `nums`, which is written to tab-ch04-numbers.csv at the end.
nums <- data.frame(slide = character(), quantity = character(), value = numeric())
rec <- function(slide, quantity, value) {
  cat(sprintf("  %-62s %s\n", quantity, format(value, digits = 10)))
  nums[nrow(nums) + 1, ] <<- list(slide, quantity, value)
}

## ---- Slide: "설명변수가 여럿일 때" (several predictors) -------------------------
# R^2 = 0.602 is the simple regression of chapter 3, IC on temp only.
s <- "설명변수가 여럿일 때"; cat("\n=== ", s, " ===\n", sep = "")
fit_temp <- lm(IC ~ temp, data = ice)
rec(s, "R2 of the simple model (temp only)", summary(fit_temp)$r.squared)
rec(s, "n (rows of the data file)", n)
rec(s, "number of variables (columns of the data file)", ncol(ice))

## ---- Slide: "아이스크림 자료: 데이터 구조" (first five rows) --------------------
s <- "아이스크림 자료: 데이터 구조"; cat("\n=== ", s, " ===\n", sep = "")
vars <- c("period", "IC", "price", "income", "temp", "year")
print(head(ice[, vars], 5))
for (i in 1:5) for (v in vars) rec(s, sprintf("row %d, %s", i, v), ice[i, v])

## ---- Slide: "설명변수 간 관계 파악: 산점도 행렬" (scatterplot matrix) ----------
# Figure block copied from make-lecture-figures.R (fig03); open_png() there is
# png(width = w, height = h, res = 170).
png(file.path(FIG_DIR, "fig03-scatterplot-matrix.png"),
    width = 1500, height = 1500, res = 170)
pairs(ice[, c("IC", "price", "income", "temp")],
      pch = 16, col = INK2,
      main = "Scatterplot Matrix of the Ice Cream Data")
invisible(dev.off())

# (Slides "다중선형회귀모형: 정의", "다중선형회귀모형: 행렬 표현": definitions only;
#  the size 30 x 4 of X quoted there is recorded on the next slide.)

## ---- Slide: "아이스크림 자료: 설계행렬" (design matrix) ------------------------
s <- "아이스크림 자료: 설계행렬"; cat("\n=== ", s, " ===\n", sep = "")
X <- model.matrix(IC ~ price + income + temp, data = ice)   # n x (p + 1)
y <- ice$IC
p <- ncol(X) - 1                                              # 3 predictors
rec(s, "rows of X", nrow(X))
rec(s, "columns of X", ncol(X))
rec(s, "y_1", y[1])
rec(s, "x_11 (price, row 1)", X[1, "price"])
rec(s, "x_12 (income, row 1)", X[1, "income"])
rec(s, "x_13 (temp, row 1)", X[1, "temp"])

# (Slide "최소제곱 해와 정규방정식": derivation only.)

## ---- Slide: "최소제곱 해가 존재할 조건" (full-rank condition) -----------------
# Normal equations X'X b = X'y solved directly (verify-multiple-regression.R
# section 1; check-r9-numbers.R block 3c). S(b) is computed two ways.
s <- "최소제곱 해가 존재할 조건"; cat("\n=== ", s, " ===\n", sep = "")
XtX  <- t(X) %*% X
XtXi <- solve(XtX)
beta <- drop(XtXi %*% t(X) %*% y)                 # (X'X)^{-1} X'y
e    <- drop(y - X %*% beta)                      # residual vector
SSE  <- sum(e^2)                                  # S(beta-hat) = e'e
rec(s, "rank(X)", qr(X)$rank)
rec(s, "S(beta-hat) = (y - Xb)'(y - Xb)", SSE)
rec(s, "S(beta-hat) = y'y - b'X'y", drop(t(y) %*% y - t(beta) %*% t(X) %*% y))
# [notes] the chapter 2 example recalled here: appending temp in Celsius, an
# exact linear function of the intercept and temp, leaves rank 4 and sends
# det(X'X) to (numerically) zero (verify-matrix-toolbox-numbers.R block 2).
tempC <- (ice$temp - 32) * 5 / 9
X2 <- cbind(X, tempC = tempC)
rec(s, "[notes] det(X'X)", det(XtX))
rec(s, "[notes] det(X'X) with Celsius temp appended", det(t(X2) %*% X2))
rec(s, "[notes] rank(X) with Celsius temp appended", qr(X2)$rank)

# (Slide "최대가능도 추정: 유도": derivation only.)

## ---- Slide: "최대가능도 추정: $\sigma^2$ 의 차이" (ML vs unbiased variance) ---
s <- "최대가능도 추정: $\\sigma^2$ 의 차이"; cat("\n=== ", s, " ===\n", sep = "")
s2_ml <- SSE / n                                  # divides by n = 30
s2_ls <- SSE / (n - p - 1)                        # divides by n - p - 1 = 26
rec(s, "SSE", SSE)
rec(s, "sigma2 ML = SSE/n", s2_ml)
rec(s, "sigma2 unbiased = SSE/(n-p-1)", s2_ls)
rec(s, "ratio (n-p-1)/n = sigma2 ML / sigma2 unbiased", s2_ml / s2_ls)

# (Slide "모자행렬: 정의": definition only.)

## ---- Slide: "모자행렬: 직교사영" (orthogonal projection) ----------------------
# Schematic, no data. Figure block copied from make-restructure-figures.R
# (fig-p05); open_png() there is png(width = w, height = h, res = 170).
png(file.path(FIG_DIR, "fig-p05-projection.png"), width = 1500, height = 1050, res = 170)
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
invisible(dev.off())

## ---- Slide: "모자행렬: 성질과 확인" (properties of H) --------------------------
# make-restructure-figures.R "hat matrix numbers"; symmetry and idempotence are
# reported as the largest absolute entry of H - H' and HH - H.
s <- "모자행렬: 성질과 확인"; cat("\n=== ", s, " ===\n", sep = "")
H <- X %*% XtXi %*% t(X)
h <- diag(H)                                      # leverages h_ii
rec(s, "rows of H", nrow(H))
rec(s, "columns of H", ncol(H))
rec(s, "max |H - H'| (symmetry)", max(abs(H - t(H))))
rec(s, "max |HH - H| (idempotence)", max(abs(H %*% H - H)))
rec(s, "tr(H)", sum(h))
rec(s, "mean leverage (p+1)/n", mean(h))
rec(s, "largest leverage h_ii", max(h))
rec(s, "observation with the largest leverage", which.max(h))

# (Slides "모자행렬: 증명", "회귀계수의 해석: 정의": proof / definition only.)

## ---- Slide: "회귀계수의 해석: 완전모형 적합" (full model fit) -----------------
s <- "회귀계수의 해석: 완전모형 적합"; cat("\n=== ", s, " ===\n", sep = "")
fit_full <- lm(IC ~ price + income + temp, data = ice)
cf <- summary(fit_full)$coefficients
print(cf)
for (j in rownames(cf)) {
  rec(s, paste("estimate,", j), cf[j, "Estimate"])
  rec(s, paste("p-value,", j), cf[j, "Pr(>|t|)"])
}
rec(s, "max |normal-equation beta - lm coefficient|", max(abs(beta - coef(fit_full))))
rec(s, "R2", summary(fit_full)$r.squared)
rec(s, "adjusted R2", summary(fit_full)$adj.r.squared)

## ---- Slide: "회귀계수의 해석: 계수와 p-value" (reading the coefficients) ------
# beta_temp = 0.00346 is recorded above; the new number here is the simple slope.
s <- "회귀계수의 해석: 계수와 p-value"; cat("\n=== ", s, " ===\n", sep = "")
rec(s, "temp slope of the simple regression IC ~ temp", coef(fit_temp)["temp"])
rec(s, "temp coefficient of the full model", coef(fit_full)["temp"])

## ---- Slide: "회귀계수의 해석: '보정'의 두 단계" (Frisch-Waugh-Lovell) ---------
# verify-fwl-auxiliary-coefficients.R blocks (3) and (6): sweep price and income
# out of BOTH IC (y-tilde) and temp (x-tilde), then regress y-tilde on x-tilde.
s <- "회귀계수의 해석: '보정'의 두 단계"; cat("\n=== ", s, " ===\n", sep = "")
ey <- residuals(lm(IC ~ price + income, data = ice))     # y-tilde
ex <- residuals(lm(temp ~ price + income, data = ice))   # x-tilde
rec(s, "sum(x~ y~)", sum(ex * ey))
rec(s, "sum(x~^2)", sum(ex^2))
rec(s, "slope sum(x~ y~)/sum(x~^2)", sum(ex * ey) / sum(ex^2))
# [notes] compare numerator and denominator with the simple regression S_xy, S_xx
Sxx <- sum((ice$temp - mean(ice$temp))^2)
Sxy <- sum((ice$temp - mean(ice$temp)) * (y - mean(y)))
rec(s, "[notes] S_xx of temp (simple regression)", Sxx)
rec(s, "[notes] S_xy (simple regression)", Sxy)
rec(s, "[notes] share of S_xx left: sum(x~^2)/S_xx", sum(ex^2) / Sxx)
rec(s, "[notes] share of S_xy left: sum(x~ y~)/S_xy", sum(ex * ey) / Sxy)
rec(s, "[notes] slope ratio FWL / simple", (sum(ex * ey) / sum(ex^2)) / (Sxy / Sxx))

## ---- Slide: "회귀계수의 해석: '보정'의 직접 확인" (added-variable plot) -------
# Numbers and figure block copied from make-added-variable-figure.R (fig-m02).
# Object names adapted: simple -> fit_temp, full -> fit_full, ice$ic -> ice$IC.
s <- "회귀계수의 해석: '보정'의 직접 확인"; cat("\n=== ", s, " ===\n", sep = "")
av <- lm(ey ~ ex)
b_simple <- coef(fit_temp)["temp"]
b_full   <- coef(fit_full)["temp"]
b_av     <- coef(av)[2]
rec(s, "left panel slope (simple regression)", b_simple)
rec(s, "right panel slope (added-variable regression)", b_av)
rec(s, "|added-variable slope - full-model beta_temp|", abs(b_av - b_full))
rec(s, "added-variable intercept (zero by construction)", coef(av)[1])

png(file.path(FIG_DIR, "fig-m02-added-variable.png"),
    width = 2100, height = 980, res = 150)

par(mfrow = c(1, 2), mar = c(4.6, 5.2, 3.2, 1.4), family = "sans",
    cex.lab = 1.15, cex.axis = 1.05)

plot(ice$temp, ice$IC, pch = 19, col = "#8a8a8a", cex = 1.15, las = 1, bty = "n",
     xlab = "Temperature (F)", ylab = "Ice cream consumption (pint)",
     main = "Temperature on its own", cex.main = 1.2, font.main = 1)
abline(fit_temp, col = "#3b9ab2", lwd = 3)
legend("topleft", bty = "n", cex = 1.1, lty = 1, lwd = 3, col = "#3b9ab2",
       legend = sprintf("slope = %.5f", b_simple))

plot(ex, ey, pch = 19, col = "#8a8a8a", cex = 1.15, las = 1, bty = "n",
     xlab = "Temperature, with price and income removed",
     ylab = "Consumption, with price and income removed",
     main = "Temperature after adjusting for price and income",
     cex.main = 1.2, font.main = 1)
abline(h = 0, col = "#d8d8d8"); abline(v = 0, col = "#d8d8d8")
abline(av, col = "#e8552d", lwd = 3)
legend("topleft", bty = "n", cex = 1.1, lty = 1, lwd = 3, col = "#e8552d",
       legend = sprintf("slope = %.5f", b_av))

invisible(dev.off())

# (Slide "회귀계수의 해석: 유의하지 않은 계수": repeats the price estimate -1.03 and
#  p = 0.226 recorded on "완전모형 적합". Slide "모형의 설명력: 수정 $R^2$":
#  definition only.)

## ---- Slide: "$R^2$, 수정 $R^2$, SSE의 관계" (schematic) -----------------------
# CONCEPTUAL figure, not a fit to data (n = 20 is nominal). Block copied from
# make-r2-adjr2-schematic.R; local() keeps its n, p, SSE from overwriting the
# ice cream values used further down.
local({
  n    <- 20
  SST  <- 1
  pmax <- 10
  pstar <- 4

  p  <- 0:pmax
  R2 <- 0.80 * (1 - exp(-p / 1.0)) + 0.0008 * p
  SSE   <- SST * (1 - R2)
  adjR2 <- 1 - (1 - R2) * (n - 1) / (n - p - 1)

  png(file.path(FIG_DIR, "fig-m01-r2-adjr2-sse.png"),
      width = 2100, height = 950, res = 150)

  par(mfrow = c(1, 2), mar = c(4.6, 5.2, 3.2, 1.6), family = "sans",
      cex.lab = 1.15, cex.axis = 1.05)

  shade <- function() {
    # Mark the region where the predictors being added are useless.
    u <- par("usr")
    rect(pstar, u[3], u[2], u[4], col = "#f4f2ee", border = NA)
    abline(v = pstar, lty = 2, col = "#a8a8a8")
  }

  # --- left panel: SSE ----------------------------------------------------
  plot(p, SSE, type = "n", las = 1, bty = "n", xaxt = "n",
       xlab = "Number of predictors p", ylab = "SSE",
       main = "SSE can only fall", cex.main = 1.2, font.main = 1,
       ylim = c(0, SST * 1.02))
  shade()
  axis(1, at = p)
  lines(p, SSE, col = "#e8552d", lwd = 3)
  points(p, SSE, pch = 19, col = "#e8552d", cex = 1.3)
  text(pstar + 0.15, SST * 0.93, adj = c(0, 0.5), col = "#7a7a7a", cex = 1.02,
       labels = "useless predictors added")

  # --- right panel: R2 and adjusted R2 ------------------------------------
  plot(p, R2, type = "n", las = 1, bty = "n", xaxt = "n",
       xlab = "Number of predictors p", ylab = "",
       main = "R-squared cannot fall, adjusted R-squared can",
       cex.main = 1.2, font.main = 1, ylim = c(0, 0.95))
  shade()
  axis(1, at = p)
  lines(p, R2, col = "#3b9ab2", lwd = 3)
  points(p, R2, pch = 19, col = "#3b9ab2", cex = 1.3)
  lines(p, adjR2, col = "#c1663f", lwd = 3, lty = 2)
  points(p, adjR2, pch = 17, col = "#c1663f", cex = 1.3)

  kmax <- which.max(adjR2)
  points(p[kmax], adjR2[kmax], pch = 1, col = "#c1663f", cex = 3.0, lwd = 2.5)
  arrows(p[kmax] - 2.2, adjR2[kmax] + 0.14, p[kmax] - 0.35, adjR2[kmax] + 0.035,
         length = 0.10, col = "#8a8a8a", lwd = 1.5)
  text(p[kmax] - 2.3, adjR2[kmax] + 0.165, adj = c(0.5, 0), col = "#52514e",
       cex = 1.05, labels = "peak: best model size")

  legend("bottomright", bty = "n", cex = 1.08, inset = c(0.02, 0.02),
         legend = c("R-squared", "adjusted R-squared"),
         lty = c(1, 2), lwd = c(3, 3), pch = c(19, 17),
         col = c("#3b9ab2", "#c1663f"))

  invisible(dev.off())
})

## ---- Slide: "모형의 설명력: 세 모형 비교" (three nested models) ---------------
# check-r9-numbers.R block (2b) / make-lecture-figures.R tab01.
s <- "모형의 설명력: 세 모형 비교"; cat("\n=== ", s, " ===\n", sep = "")
fit_red <- lm(IC ~ income + temp, data = ice)
models <- list("temp" = fit_temp, "income, temp" = fit_red,
               "price, income, temp" = fit_full)
for (m in names(models)) {
  rec(s, paste0("R2 (", m, ")"), summary(models[[m]])$r.squared)
  rec(s, paste0("adjusted R2 (", m, ")"), summary(models[[m]])$adj.r.squared)
}
rec(s, "adjusted R2 gain from adding price",
    summary(fit_full)$adj.r.squared - summary(fit_red)$adj.r.squared)

# (Slide "제곱합의 분해": derivation only; the identity is checked numerically on
#  the next slide.)

## ---- Slide: "자유도의 분해" (sums of squares and degrees of freedom) ----------
# Numbers from make-df-decomposition-figure.R; the drawing is that script's block,
# run inside local() so its a, b, c and plotting variables stay out of the way.
s <- "자유도의 분해"; cat("\n=== ", s, " ===\n", sep = "")
yhat  <- fitted(fit_full)
SST   <- sum((y - mean(y))^2)
SSR   <- sum((yhat - mean(y))^2)
R2    <- SSR / SST
theta <- acos(sqrt(SSR / SST))                    # angle at the origin
rec(s, "SST", SST)
rec(s, "SSR", SSR)
rec(s, "SSE", SSE)
rec(s, "SST - (SSR + SSE)", SST - (SSR + SSE))
rec(s, "inner product of the two legs, sum((yhat - ybar) e)", sum((yhat - mean(y)) * e))
rec(s, "cos^2(theta) = SSR/SST = R2", cos(theta)^2)
rec(s, "[notes] theta (degrees)", theta * 180 / pi)
rec(s, "total df n - 1", n - 1)
rec(s, "regression df p", p)
rec(s, "residual df n - p - 1 (= tr(I - H))", n - p - 1)
rec(s, "tr(I - H)", sum(1 - h))

local({
  a <- sqrt(SSR)      # horizontal leg
  b <- sqrt(SSE)      # vertical leg
  c <- sqrt(SST)      # hypotenuse

  png(file.path(FIG_DIR, "fig-m03-df-decomposition.png"),
      width = 2100, height = 880, res = 150)

  par(mfrow = c(1, 2), mar = c(1.4, 1.2, 2.6, 1.2), family = "sans")

  col_reg <- "#3b9ab2"
  col_res <- "#e8552d"
  col_tot <- "#14324a"

  # --- left panel: the right triangle, to scale -----------------------------
  plot(NA, xlim = c(-0.030, 0.412), ylim = c(-0.062, 0.275),
       asp = 1, axes = FALSE, xlab = "", ylab = "",
       main = "Sums of squares: a right triangle, drawn to scale",
       cex.main = 1.1, font.main = 1)

  polygon(c(0, a, a), c(0, 0, b), col = "#f4f7f9", border = NA)

  # the right angle at the corner where the two legs meet
  sq <- 0.017
  lines(c(a - sq, a - sq, a), c(0, sq, sq), col = "#8a8a8a", lwd = 1.4)

  arrows(0, 0, a, 0, length = 0.10, lwd = 3.2, col = col_reg)
  arrows(a, 0, a, b, length = 0.10, lwd = 3.2, col = col_res)
  arrows(0, 0, a, b, length = 0.10, lwd = 3.2, col = col_tot)

  # the angle whose squared cosine is R-squared
  ang <- seq(0, theta, length.out = 60)
  r_a <- 0.075
  lines(r_a * cos(ang), r_a * sin(ang), col = "#8a8a8a", lwd = 1.3)
  text(0.090 * cos(theta / 2), 0.090 * sin(theta / 2),
       labels = expression(theta), col = "#52514e", cex = 1.15, adj = c(0, 0.35))

  text(a / 2, -0.013, adj = c(0.5, 1), col = col_reg, cex = 1.02,
       labels = expression(hat(y) - bar(y) * bold(1)))
  text(a / 2, -0.036, adj = c(0.5, 1), col = col_reg, cex = 1.02,
       labels = sprintf("SSR = %.4f", SSR))

  text(a + 0.013, b / 2 + 0.011, adj = c(0, 0.5), col = col_res, cex = 1.02,
       labels = expression(y - hat(y)))
  text(a + 0.013, b / 2 - 0.012, adj = c(0, 0.5), col = col_res, cex = 1.02,
       labels = sprintf("SSE = %.4f", SSE))

  # hypotenuse, labelled along it (offset along the perpendicular (-b, a)/c)
  px <- -b / c; py <- a / c
  srt_h <- theta * 180 / pi
  text(a / 2 + px * 0.034, b / 2 + py * 0.034, srt = srt_h, adj = c(0.5, 0),
       col = col_tot, cex = 1.02, labels = expression(y - bar(y) * bold(1)))
  text(a / 2 + px * 0.013, b / 2 + py * 0.013, srt = srt_h, adj = c(0.5, 0),
       col = col_tot, cex = 1.02, labels = sprintf("SST = %.4f", SST))

  # the three facts the picture is here to carry
  text(-0.026, 0.272, adj = c(0, 1), col = "#52514e", cex = 1.04,
       labels = sprintf("SST = SSR + SSE:   %.4f = %.4f + %.4f", SST, SSR, SSE))
  text(-0.026, 0.248, adj = c(0, 1), col = "#52514e", cex = 1.04,
       labels = sprintf("side lengths (hyp, base, height):   %.4f, %.4f, %.4f",
                        c, a, b))
  text(-0.026, 0.224, adj = c(0, 1), col = "#52514e", cex = 1.04,
       labels = sprintf("cos²θ = SSR / SST = R² = %.4f", R2))

  # --- right panel: the same split, counted in dimensions -------------------
  df_reg <- p
  df_res <- n - p - 1
  df_tot <- n - 1

  plot(NA, xlim = c(-2.0, df_tot + 2.0), ylim = c(0, 1),
       axes = FALSE, xlab = "", ylab = "",
       main = "Degrees of freedom split the same way",
       cex.main = 1.1, font.main = 1)

  # total bar on top
  rect(0, 0.76, df_tot, 0.94, col = col_tot, border = NA)
  text(df_tot / 2, 0.85, col = "#ffffff", cex = 1.08,
       labels = sprintf("SST:  n - 1 = %d", df_tot))

  # the two pieces below, drawn to the same scale so the widths are comparable
  rect(0, 0.44, df_reg, 0.62, col = col_reg, border = NA)
  rect(df_reg, 0.44, df_tot, 0.62, col = col_res, border = NA)
  text((df_reg + df_tot) / 2, 0.53, col = "#ffffff", cex = 1.08,
       labels = sprintf("SSE:  n - p - 1 = %d", df_res))

  # the SSR block is only 3 of 29 units wide, too narrow to hold its own label
  segments(df_reg / 2, 0.42, df_reg / 2, 0.34, col = col_reg, lwd = 1.4)
  text(df_reg / 2, 0.31, adj = c(0.5, 1), col = col_reg, cex = 1.05,
       labels = sprintf("SSR:  p = %d", df_reg))

  # dotted ticks showing the two blocks span exactly the same width as the total
  segments(c(0, df_reg, df_tot), 0.64, c(0, df_reg, df_tot), 0.74,
           col = "#b9c2c8", lwd = 1.2, lty = 3)

  text(df_tot / 2, 0.15, adj = c(0.5, 0.5), col = "#52514e", cex = 1.2,
       labels = sprintf("%d = %d + %d", df_tot, df_reg, df_res))

  invisible(dev.off())
})

# (Slide "모형 전체의 유의성: 검정의 목적": hypotheses only.)

## ---- Slide: "모형 전체의 유의성: F 통계량" (overall F statistic) --------------
s <- "모형 전체의 유의성: F 통계량"; cat("\n=== ", s, " ===\n", sep = "")
rec(s, "numerator df p", p)
rec(s, "denominator df n - p - 1", n - p - 1)
rec(s, "[notes] 5% critical value of F(3, 26)", qf(0.95, p, n - p - 1))

## ---- Slide: "회귀분산분석표" (ANOVA table) ------------------------------------
# verify-multiple-regression.R section (4).
s <- "회귀분산분석표"; cat("\n=== ", s, " ===\n", sep = "")
MSR   <- SSR / p
MSE   <- SSE / (n - p - 1)
Fstat <- MSR / MSE
rec(s, "Regression: Df", p)
rec(s, "Regression: Sum Sq (SSR)", SSR)
rec(s, "Regression: Mean Sq (MSR)", MSR)
rec(s, "F = MSR/MSE", Fstat)
rec(s, "p-value of F(3, 26)", pf(Fstat, p, n - p - 1, lower.tail = FALSE))
rec(s, "Residual: Df", n - p - 1)
rec(s, "Residual: Sum Sq (SSE)", SSE)
rec(s, "Residual: Mean Sq (MSE)", MSE)
rec(s, "Total: Df", n - 1)
rec(s, "Total: Sum Sq (SST)", SST)
rec(s, "5% critical value of F(3, 26)", qf(0.95, p, n - p - 1))
rec(s, "sigma-hat = sqrt(MSE)", sqrt(MSE))
rec(s, "F reported by lm() (cross-check)", summary(fit_full)$fstatistic[["value"]])

## ---- Slide: "회귀계수 일부에 대한 검정" (partial F test) ----------------------
# check-r9-numbers.R block (3d): H0 beta_price = beta_income = 0, k = 2.
s <- "회귀계수 일부에 대한 검정"; cat("\n=== ", s, " ===\n", sep = "")
SSE_rm <- sum(residuals(fit_temp)^2)              # reduced model: temp only
k <- 2
Fsub <- ((SSE_rm - SSE) / k) / (SSE / (n - p - 1))
rec(s, "SSE (RM: temp only)", SSE_rm)
rec(s, "SSE (FM: price + income + temp)", SSE)
rec(s, "[notes] SSE(RM) - SSE(FM)", SSE_rm - SSE)
rec(s, "(SSE(RM) - SSE(FM)) / k", (SSE_rm - SSE) / k)
rec(s, "sigma2-hat = SSE(FM)/26", SSE / (n - p - 1))
rec(s, "F", Fsub)
rec(s, "p-value of F(2, 26)", pf(Fsub, k, n - p - 1, lower.tail = FALSE))
print(anova(fit_temp, fit_full))                  # cross-check with R's anova()

# (Slides "회귀계수의 표집분포: 추정량은 확률변수" through "표준오차에서 신뢰구간으로":
#  derivations, assumptions and the Gauss-Markov theorem; no data numbers.)

## ---- Slide: "회귀계수에 대한 검정과 신뢰구간" (coefficient table) -------------
# verify-multiple-regression.R section (3): se = sigma-hat * sqrt(c_jj).
s <- "회귀계수에 대한 검정과 신뢰구간"; cat("\n=== ", s, " ===\n", sep = "")
cjj   <- diag(XtXi)
se    <- sqrt(s2_ls * cjj)
tval  <- beta / se
pval  <- 2 * pt(abs(tval), df = n - p - 1, lower.tail = FALSE)
tcrit <- qt(0.975, df = n - p - 1)
rec(s, "sigma2-hat = SSE/(n-p-1)", s2_ls)
rec(s, "t_{0.025, 26}", tcrit)
for (j in names(beta)) {
  rec(s, paste("estimate,", j), beta[j])
  rec(s, paste("c_jj,", j), cjj[j])
  rec(s, paste("se,", j), se[j])
  rec(s, paste("t,", j), tval[j])
  rec(s, paste("p-value,", j), pval[j])
  rec(s, paste("95% CI lower,", j), beta[j] - tcrit * se[j])
  rec(s, paste("95% CI upper,", j), beta[j] + tcrit * se[j])
}
rec(s, "max |se - lm() se|", max(abs(se - summary(fit_full)$coefficients[, 2])))

# (Slide "반응평균의 신뢰구간과 예측구간: 정의": formulas only.)

## ---- Slide: "반응평균의 신뢰구간과 예측구간: 수치" (CI and PI at x0) ----------
# verify-multiple-regression.R section (6).
s <- "반응평균의 신뢰구간과 예측구간: 수치"; cat("\n=== ", s, " ===\n", sep = "")
x0 <- c(1, 0.280, 85, 65)                         # (1, price, income, temp)
y0 <- sum(x0 * beta)
c0 <- drop(t(x0) %*% XtXi %*% x0)                 # x0'(X'X)^{-1}x0
half_ci <- tcrit * sqrt(s2_ls) * sqrt(c0)
half_pi <- tcrit * sqrt(s2_ls) * sqrt(1 + c0)
rec(s, "fitted value y0-hat = x0' beta-hat", y0)
# The slide writes the sum with the coefficients rounded as on the slide; this
# line evaluates exactly that printed expression for comparison.
rec(s, "printed sum 0.19270 - 1.02906*0.280 + 0.00331*85 + 0.00346*65",
    0.19270 - 1.02906 * 0.280 + 0.00331 * 85 + 0.00346 * 65)
rec(s, "x0'(X'X)^{-1}x0", c0)
rec(s, "sigma-hat", sqrt(s2_ls))
rec(s, "t_{0.025, 26}", tcrit)
rec(s, "CI half-width", half_ci)
rec(s, "CI lower", y0 - half_ci)
rec(s, "CI upper", y0 + half_ci)
rec(s, "CI width", 2 * half_ci)
rec(s, "PI half-width", half_pi)
rec(s, "PI lower", y0 - half_pi)
rec(s, "PI upper", y0 + half_pi)
rec(s, "PI width", 2 * half_pi)
rec(s, "PI width / CI width", half_pi / half_ci)
nd <- data.frame(price = 0.280, income = 85, temp = 65)
print(predict(fit_full, nd, interval = "confidence"))   # cross-check
print(predict(fit_full, nd, interval = "prediction"))

## ---- write the number table ----------------------------------------------------
write.csv(nums, file.path(FIG_DIR, "tab-ch04-numbers.csv"), row.names = FALSE,
          fileEncoding = "UTF-8")
cat("\n", nrow(nums), "numbers written to", file.path(FIG_DIR, "tab-ch04-numbers.csv"), "\n")
cat("figures written to", FIG_DIR, ":\n")
print(list.files(FIG_DIR, pattern = "\\.png$"))
