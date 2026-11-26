# Date        : 2026-11-26
# Description : One-stop reproduction of every data-derived number, table and
#               R-made figure in chapter 6 (Weighted Regression) of the KINS
#               regression lecture, following the slide order of the canonical
#               deck quarto/agent/2026-08-26/06-weighted-regression.qmd.
#               Sections are headed by the exact slide title; slides that carry
#               only theory or definitions (no number computed from data) are
#               listed but skipped.
#
#               The code is moved, not rewritten, from the scripts that made
#               the deck (only the output paths and some object names changed):
#                 - code/agent/2026-08-11/make-lecture-figures.R   (fig05, seed 2026)
#                 - code/agent/2026-11-26/check-ch06-physics-wls.R (physics numbers,
#                   Monte Carlo seed 20261126)
#                 - code/agent/2026-11-26/make-ch06-physics-figures.R (4 physics figures)
#                 - code/agent/2026-08-24/make-attenuation-figures.R (seed 20260824)
#                 - code/agent/2026-08-28/gls-lakehuron-autocorrelation.R
#
#               Data:
#                 - docs/data/physical-measurement.csv : alr4::physics (Weisberg
#                   2014; original Weisberg, H. et al. 1978, Phys. Rev. D 17).
#                   Columns x, y, SD; SD is the standard deviation of y, so the
#                   precision weight is w = 1/SD^2 (memory/physics-data-source-
#                   and-weights.md). Same ten rows as typed in the two 2026-11-26
#                   scripts.
#                 - datasets::LakeHuron (base R; Brockwell & Davis 1991, p. 555)
#                 - simulated data (heteroscedasticity figure, attenuation curve)
#
#               Outputs (only under output/agent/2026-11-26/reproduce/ch06/; the
#               figure files carry the same names as the ones the deck uses, but
#               the deck's own PNGs are never written):
#                 fig05-heteroscedasticity.png, fig-p06-physics-ols-wls.png,
#                 fig-p06-physics-wresid-linear.png, fig-p06-physics-quadratic.png,
#                 fig-p06-physics-wresid-compare.png,
#                 fig-a01-attenuation-variance.png, fig-a02-ols-vs-wls.png,
#                 fig-m06-gls-lakehuron.png,
#                 tab-ch06-numbers.csv (columns slide, quantity, value)
#
#               Not reproduced: the Poisson-GLM column and the 13.5 / 1.3 rows of
#               the slide "감쇠 곡선: WLS의 한계". No script that produced them
#               exists in code/agent or in the git history, so they are not
#               re-simulated here (see that section).
#
#               Run   : from the project root,
#                       Rscript code/agent/2026-11-26/reproduce-ch06-weighted-regression.R
# File        : reproduce-ch06-weighted-regression.R

library(nlme)    # gls() for the Lake Huron example; lmtest is called with ::

out_dir <- "output/agent/2026-11-26/reproduce/ch06"
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

## Palette shared by make-lecture-figures.R, make-attenuation-figures.R and
## make-ch06-physics-figures.R (the Lake Huron figure uses its own hex codes)
COL_BLUE   <- "#2a78d6"
COL_ORANGE <- "#eb6834"
COL_RED    <- "#e34948"
COL_AQUA   <- "#1baf7a"
INK        <- "#0b0b0b"
INK2       <- "#52514e"
GRID_C     <- "#e1e0d9"

## Every quoted number is printed and collected into one table, one row per
## (slide, quantity), and written to tab-ch06-numbers.csv at the end.
num <- NULL
rec <- function(slide, quantity, value) {
  cat(sprintf("\n==== %s ====\n", slide))
  print(data.frame(quantity = quantity, value = signif(value, 6)), row.names = FALSE)
  num <<- rbind(num, data.frame(slide = slide, quantity = quantity, value = value))
}

## ============================================================================
## Slides with no data-derived result (skipped):
##   이 장의 출발점 / 등분산과 이분산: 정의
## ============================================================================

## ============================================================================
## Slide: 등분산과 이분산: 깔때기 신호
## Figure fig05-heteroscedasticity.png (from make-lecture-figures.R, fig05).
## Simulated data whose error SD grows with x (funnel shape). The original also
## saved the simulated data to data/derived-data/agent/2026-08-11/; that file
## is not rewritten here.
## ============================================================================
set.seed(2026)
n_sim <- 120
x_sim <- runif(n_sim, 0, 10)
y_sim <- 2 + 0.5 * x_sim + rnorm(n_sim, mean = 0, sd = 0.1 + 0.15 * x_sim)
sim <- data.frame(x = x_sim, y = y_sim)
fit_sim <- lm(y ~ x, data = sim)

png(file.path(out_dir, "fig05-heteroscedasticity.png"), width = 2000, height = 1000, res = 170)
par(mfrow = c(1, 2), mar = c(4.5, 4.5, 3, 1),
    col.axis = INK2, col.lab = INK, fg = INK2)
plot(sim$x, sim$y, pch = 16, col = INK2, cex = 0.9,
     panel.first = grid(col = GRID_C, lty = 1),
     main = "Error Spread Grows with x",
     xlab = "x", ylab = "y")
abline(fit_sim, col = COL_BLUE, lwd = 3)
plot(fitted(fit_sim), resid(fit_sim), pch = 16, col = INK2, cex = 0.9,
     panel.first = grid(col = GRID_C, lty = 1),
     main = "Funnel-Shaped Residuals",
     xlab = "Fitted values", ylab = "Residuals")
abline(h = 0, col = COL_RED, lwd = 2)
dev.off()

## ============================================================================
## Slides with no data-derived result (skipped):
##   등분산 위반: Gauss-Markov 복습 / 등분산 위반: 무너지는 결론 /
##   가중최소제곱(WLS): 목적함수 / 가중최소제곱(WLS): 행렬 해 /
##   가중최소제곱(WLS): 해의 유도 / 가중치를 정하는 규칙 /
##   가중치의 실무 적용: 감마선 검교정 (literature case only; no number is
##   computed from data on this slide)
## ============================================================================

## ============================================================================
## Slide: 물리 측정 예제: 표준편차가 기록된 자료
## Data table (x, y, SD) and the precision weights w = 1/SD^2.
## ============================================================================
phys <- read.csv("docs/data/physical-measurement.csv")
x <- phys$x; y <- phys$y; SD <- phys$SD
n <- nrow(phys)
w <- 1 / SD^2                       # precision weight: inverse of the variance
W <- diag(w)
print(cbind(phys, w = signif(w, 3)))

s <- "물리 측정 예제: 표준편차가 기록된 자료"
rec(s, c("n", paste0("w_", 1:10, " = 1/SD^2"),
         "w_1/w_10 (= 25/289)", "SD_1/SD_10 (notes: 3.4)", "w_10/w_1 (notes: about 1/12)",
         "min SD (notes: 5)", "max SD (notes: 17)"),
    c(n, w, w[1] / w[10], SD[1] / SD[10], w[10] / w[1], min(SD), max(SD)))

## ---- fits used by the following slides (from check-ch06-physics-wls.R) -----
## WLS by the matrix formula:
##   beta = (X'WX)^{-1} X'Wy
##   weighted RSS   S_W = sum w_i e_i^2                       (= X^2 when SD known)
##   sigma2_hat     = S_W / (n - p - 1)                      (scale estimated)
##   Var(beta)      = sigma2 (X'WX)^{-1}; sigma2 = sigma2_hat or 1 (SD known)
##   weighted R^2   = 1 - S_W / sum w_i (y_i - ybar_w)^2,  ybar_w = sum w y / sum w
wls <- function(X, y, w) {
  W     <- diag(w)
  XtWX  <- t(X) %*% W %*% X
  A     <- solve(XtWX)
  b     <- drop(A %*% t(X) %*% W %*% y)
  e     <- drop(y - X %*% b)
  df    <- length(y) - ncol(X)
  SW    <- sum(w * e^2)
  s2    <- SW / df
  ybw   <- sum(w * y) / sum(w)
  R2    <- 1 - SW / sum(w * (y - ybw)^2)
  # weighted hat matrix H_W = W^{1/2} X (X'WX)^{-1} X' W^{1/2}
  Wh    <- diag(sqrt(w))
  h     <- diag(Wh %*% X %*% A %*% t(X) %*% Wh)
  list(b = b, A = A, e = e, df = df, SW = SW, s2 = s2, R2 = R2, h = h,
       se_est = sqrt(diag(s2 * A)),       # sigma^2 estimated (as lm reports)
       se_known = sqrt(diag(A)),          # sigma^2 = 1 (SD known exactly)
       rw = sqrt(w) * e)                  # weighted residual e_i / SD_i
}

X1 <- cbind(1, x)
X2 <- cbind(1, x, x^2)
ols1 <- wls(X1, y, rep(1, n))
wls1 <- wls(X1, y, w)
wls2 <- wls(X2, y, w)

# lm() fits: used as a cross-check of the matrix formulas and for the figures
m_ols1 <- lm(y ~ x)
m_wls1 <- lm(y ~ x, weights = w)
m_wls2 <- lm(y ~ x + I(x^2), weights = w)
chk <- function(a, b) stopifnot(isTRUE(all.equal(unname(a), unname(b), tolerance = 1e-10)))
chk(ols1$b, coef(m_ols1)); chk(ols1$se_est, summary(m_ols1)$coefficients[, 2])
chk(wls1$b, coef(m_wls1)); chk(wls1$se_est, summary(m_wls1)$coefficients[, 2])
chk(wls1$R2, summary(m_wls1)$r.squared); chk(wls1$s2, summary(m_wls1)$sigma^2)
chk(wls2$b, coef(m_wls2)); chk(wls2$se_est, summary(m_wls2)$coefficients[, 2])
chk(wls2$R2, summary(m_wls2)$r.squared)
chk(wls1$rw, weighted.residuals(m_wls1)); chk(wls2$rw, weighted.residuals(m_wls2))
chk(wls1$h, hatvalues(m_wls1)); chk(wls2$h, hatvalues(m_wls2))
cat("\nmatrix formulas agree with lm() to 1e-10\n")

## ---- figure helpers (from make-ch06-physics-figures.R) ----------------------
# curves are drawn only over the observed x range (no extrapolation)
xg <- seq(min(x), max(x), length.out = 200)

# scatter with +/- 1 SD error bars, shared by the two data panels
data_panel <- function(main) {
  par(mar = c(4.5, 4.8, 3, 1), col.axis = INK2, col.lab = INK, fg = INK2)
  # y range covers the error bars and every fitted line drawn on top
  plot(x, y, type = "n", ylim = range(c(y - SD, y + SD, fitted(m_ols1))),
       panel.first = grid(col = GRID_C, lty = 1), main = main,
       xlab = "x (inverse total energy)", ylab = "y (cross-section)")
  arrows(x, y - SD, x, y + SD, angle = 90, code = 3, length = 0.04,
         col = INK2, lwd = 1.5)
  points(x, y, pch = 16, col = INK, cex = 1.2)
}

# weighted-residual panel
resid_panel <- function(r, main, col, cx = 0.85, pcex = 1.5) {
  par(mar = c(4.5, 4.8, 3, 1), col.axis = INK2, col.lab = INK, fg = INK2)
  # x range padded on both sides so the end-point value labels are not clipped
  plot(x, r, type = "n", ylim = c(-3, 3), xlim = c(0.04, 0.365), main = main,
       panel.first = grid(col = GRID_C, lty = 1),
       xlab = "x (inverse total energy)", ylab = "Weighted residual (y - fitted) / SD")
  abline(h = 0, col = INK2, lwd = 1.5)
  abline(h = c(-2, 2), col = INK2, lwd = 1, lty = 3)
  o <- order(x)
  lines(x[o], r[o], col = col, lwd = 1.5, lty = 2)       # joins points left to right
  # value labels, placed above positive and below negative points, on a white
  # box so the dashed joining line does not run through the digits
  lab <- sprintf("%.2f", r)
  dy  <- ifelse(r >= 0, 1, -1) * 2.0 * strheight("0", cex = cx)
  bw  <- strwidth(lab, cex = cx) / 2 * 1.15
  bh  <- strheight("0", cex = cx) / 2 * 1.5
  rect(x - bw, r + dy - bh, x + bw, r + dy + bh, col = "white", border = NA)
  text(x, r + dy, lab, cex = cx, col = INK)
  points(x, r, pch = 16, col = col, cex = pcex)           # drawn last, on top of the boxes
}

## ============================================================================
## Slide: 1차식 적합: OLS와 WLS의 두 직선
## Figure fig-p06-physics-ols-wls.png
## ============================================================================
png(file.path(out_dir, "fig-p06-physics-ols-wls.png"), width = 1800, height = 1100, res = 230)
data_panel("Straight-line fits to the physics data (bars = +/- 1 SD)")
lines(xg, predict(m_ols1, newdata = data.frame(x = xg)), col = COL_BLUE,   lwd = 3)
lines(xg, predict(m_wls1, newdata = data.frame(x = xg)), col = COL_ORANGE, lwd = 3, lty = 2)
legend("topleft", bty = "n", lwd = 3, lty = c(1, 2), col = c(COL_BLUE, COL_ORANGE),
       legend = c("OLS (equal weights)", "WLS (w = 1/SD^2)"), text.col = INK)
dev.off()

## ============================================================================
## Slide: 1차식 적합: 추정 결과
## OLS vs WLS straight-line coefficients and SE (sigma^2 estimated), weighted
## R^2 of the WLS line, and sigma2_hat = S_W / (n - 2).
## ============================================================================
rec("1차식 적합: 추정 결과",
    c("OLS b0", "OLS SE(b0)", "OLS b1", "OLS SE(b1)",
      "WLS b0", "WLS SE(b0)", "WLS b1", "WLS SE(b1)",
      "WLS weighted R2", "WLS sigma2_hat = S_W/8"),
    c(ols1$b[1], ols1$se_est[1], ols1$b[2], ols1$se_est[2],
      wls1$b[1], wls1$se_est[1], wls1$b[2], wls1$se_est[2],
      wls1$R2, wls1$s2))

## ============================================================================
## Slide: 가중 잔차: 측정의 SD로 나눈 잔차
## Raw and weighted residuals of points 1 and 10 on the WLS straight line,
## weighted leverage h_10 and the leverage-corrected value r_w / sqrt(1 - h).
## ============================================================================
cat("\nsum of squared weighted residuals equals S_W:",
    isTRUE(all.equal(sum(wls1$rw^2), wls1$SW)), "\n")
rec("가중 잔차: 측정의 SD로 나눈 잔차",
    c("WLS1 e_1", "WLS1 e_10", "WLS1 r_w[1]", "WLS1 r_w[10]",
      "WLS1 weighted leverage h_10", "WLS1 r_w[10]/sqrt(1-h_10)"),
    c(wls1$e[1], wls1$e[10], wls1$rw[1], wls1$rw[10],
      wls1$h[10], wls1$rw[10] / sqrt(1 - wls1$h[10])))

## ============================================================================
## Slide: 1차식의 가중 잔차: 양 끝은 양수, 가운데는 음수
## Figure fig-p06-physics-wresid-linear.png and the ten weighted residuals,
## listed from small x to large x as on the slide.
## ============================================================================
png(file.path(out_dir, "fig-p06-physics-wresid-linear.png"), width = 1800, height = 1100, res = 230)
resid_panel(wls1$rw, "Weighted residuals of the WLS straight line", COL_ORANGE)
dev.off()

o <- order(x)
rec("1차식의 가중 잔차: 양 끝은 양수, 가운데는 음수",
    sprintf("WLS1 r_w at x = %.3f", x[o]), wls1$rw[o])

## ============================================================================
## Slide: 적합결여 검정: 잔차의 크기와 SD의 비교
## X^2 = S_W ~ chi^2(n - p - 1) when SD is known, the model is right and the
## errors are independent normal.
## ============================================================================
p_lof1 <- pchisq(wls1$SW, wls1$df, lower.tail = FALSE)
p_lof2 <- pchisq(wls2$SW, wls2$df, lower.tail = FALSE)
rec("적합결여 검정: 잔차의 크기와 SD의 비교",
    c("line X2", "line df", "line X2/df", "line p",
      "quad X2", "quad df", "quad X2/df", "quad p",
      "chi2(8) 0.95 quantile (notes: 15.5)"),
    c(wls1$SW, wls1$df, wls1$SW / wls1$df, p_lof1,
      wls2$SW, wls2$df, wls2$SW / wls2$df, p_lof2,
      qchisq(0.95, 8)))

## ============================================================================
## Slide: 2차식 적합: 계수에 대해서는 선형
## Figure fig-p06-physics-quadratic.png, the WLS quadratic coefficients (SE with
## sigma^2 estimated), weighted R^2, the VIF of x and x^2 before and after
## weighted centring, and the numbers quoted in the speaker notes.
## ============================================================================
png(file.path(out_dir, "fig-p06-physics-quadratic.png"), width = 1800, height = 1100, res = 230)
data_panel("WLS straight line and quadratic (bars = +/- 1 SD)")
lines(xg, predict(m_wls1, newdata = data.frame(x = xg)), col = COL_ORANGE, lwd = 3, lty = 2)
lines(xg, predict(m_wls2, newdata = data.frame(x = xg)), col = COL_AQUA, lwd = 3)
legend("topleft", bty = "n", lwd = 3, lty = c(2, 1), col = c(COL_ORANGE, COL_AQUA),
       legend = c("Straight line", "Quadratic"), text.col = INK)
dev.off()

## VIF of x and x^2. Unweighted: 1/(1 - cor^2). Weighted: same with weighted
## centring, i.e. the R^2 of the WLS regression of x on x^2 (with intercept).
vif_u <- 1 / (1 - cor(x, x^2)^2)
r2w   <- summary(lm(x ~ I(x^2), weights = w))$r.squared
vif_w <- 1 / (1 - r2w)
cat(sprintf("\nVIF(x, x^2): unweighted %.1f  weighted %.1f  (cor = %.4f)\n", vif_u, vif_w, cor(x, x^2)))
# a centred quadratic removes most of it: x and (x - xbar_w)^2
xc    <- x - sum(w * x) / sum(w)
r2wc  <- summary(lm(xc ~ I(xc^2), weights = w))$r.squared
m_c   <- lm(y ~ xc + I(xc^2), weights = w)
print(round(summary(m_c)$coefficients, 3))

rec("2차식 적합: 계수에 대해서는 선형",
    c("quad b0", "quad SE(b0)", "quad b1", "quad SE(b1)", "quad b2", "quad SE(b2)",
      "quad weighted R2", "line weighted R2",
      "VIF x, x^2 (weighted)", "VIF after weighted centring",
      "centred quad: linear coefficient", "centred quad: SE of it",
      "SE(sigma2 = 1) / SE(sigma2 estimated) = 1/sqrt(sigma2_hat)",
      "points with |r_w| <= 1 on the quadratic (curve inside +/- 1 SD bar)"),
    c(wls2$b[1], wls2$se_est[1], wls2$b[2], wls2$se_est[2], wls2$b[3], wls2$se_est[3],
      wls2$R2, wls1$R2, vif_w, 1 / (1 - r2wc),
      coef(m_c)[2], summary(m_c)$coefficients[2, 2],
      1 / sqrt(wls2$s2), sum(abs(wls2$rw) <= 1)))

## ============================================================================
## Slide: 1차식과 2차식 비교: 2차항의 F 검정과 재진단
## Extra-sum-of-squares F with S_W in place of SSE (RM = line, FM = quadratic),
## and figure fig-p06-physics-wresid-compare.png.
## ============================================================================
Fq  <- ((wls1$SW - wls2$SW) / 1) / (wls2$SW / wls2$df)
pFq <- pf(Fq, 1, wls2$df, lower.tail = FALSE)
chk(Fq, anova(m_wls1, m_wls2)$F[2])

# two panels shown about 820 px wide on the slide: a higher res keeps the
# tick and value labels legible at that size
png(file.path(out_dir, "fig-p06-physics-wresid-compare.png"), width = 2200, height = 1000, res = 270)
par(mfrow = c(1, 2))
# smaller labels and points: at res 270 the default sizes made -0.77 and -1.37 collide
resid_panel(wls1$rw, "(a) Straight line", COL_ORANGE, cx = 0.7, pcex = 1.2)
resid_panel(wls2$rw, "(b) Quadratic", COL_AQUA, cx = 0.7, pcex = 1.2)
dev.off()

cat("\nweighted residuals, quadratic:", sprintf("%.2f", wls2$rw), "\n")
rec("1차식과 2차식 비교: 2차항의 F 검정과 재진단",
    c("S_W(line) - S_W(quad)", "S_W(quad)/7", "F", "p of F(1,7)",
      "t^2 of quad b2", "max |r_w| quadratic"),
    c(wls1$SW - wls2$SW, wls2$SW / wls2$df, Fq, pFq,
      (wls2$b[3] / wls2$se_est[3])^2, max(abs(wls2$rw))))

## ============================================================================
## Slide: 검교정 곡선을 정하는 절차
## Only data-derived number: the calibrated range of x.
## ============================================================================
rec("검교정 곡선을 정하는 절차", c("min x", "max x"), range(x))

## ============================================================================
## Slide with no data-derived result (skipped): 역추정: 새 측정값에서 x 구하기
## ============================================================================

## ============================================================================
## Slide: 역추정: 2차 검교정 곡선의 수치 예
## f(x; b) = b0 + b1 x + b2 x^2. Given a new reading y0 with standard deviation
## SD0, x0_hat solves f(x0_hat; b_hat) = y0 (root inside the calibrated range).
## Implicit-function derivatives:
##   d x0 / d y0 = 1 / f'(x0),        f'(x0) = b1 + 2 b2 x0
##   d x0 / d b  = -(1, x0, x0^2) / f'(x0)
## Delta method, y0 independent of b_hat:
##   Var(x0_hat) ~ { Var(y0) + g' Var(b_hat) g } / f'(x0)^2,  g = (1, x0, x0^2)
## With SD known (sigma^2 = 1): Var(y0) = SD0^2, Var(b_hat) = (X'WX)^{-1}.
## ============================================================================
b  <- wls2$b
y0 <- 250; SD0 <- 7     # SD0 assumed equal to the SD recorded at x = 0.207 (y = 253)
x0_of <- function(b, y0) {
  r <- polyroot(c(b[1] - y0, b[2], b[3]))
  r <- Re(r[abs(Im(r)) < 1e-9])
  r[r > 0 & r < 0.5]                       # root inside the calibrated range
}
x0   <- x0_of(b, y0)
fp   <- b[2] + 2 * b[3] * x0
g    <- c(1, x0, x0^2)
v_new   <- SD0^2 / fp^2
v_curve <- drop(t(g) %*% wls2$A %*% g) / fp^2
se_x0   <- sqrt(v_new + v_curve)
# linear-curve version for reference
b1 <- wls1$b; x0_lin <- (y0 - b1[1]) / b1[2]

# check 1: numerical gradient of x0_hat with respect to (b, y0)
eps <- 1e-6
num_grad <- sapply(1:4, function(j) {
  th <- c(b, y0); thp <- th; thm <- th; thp[j] <- th[j] + eps; thm[j] <- th[j] - eps
  (x0_of(thp[1:3], thp[4]) - x0_of(thm[1:3], thm[4])) / (2 * eps)
})
ana_grad <- c(-g / fp, 1 / fp)
cat("\ngradient analytic :", signif(ana_grad, 6), "\n")
cat("gradient numerical:", signif(num_grad, 6), "\n")
stopifnot(max(abs(num_grad - ana_grad) / abs(ana_grad)) < 1e-5)

# check 2: Monte Carlo with SD known. Truth = fitted quadratic; regenerate the
# ten calibration points and the new reading, refit, invert.
set.seed(20261126)
B <- 20000
true_y0 <- y0                          # the new item's true response
sim_x0 <- replicate(B, {
  ys  <- drop(X2 %*% b) + rnorm(n, 0, SD)
  bs  <- drop(solve(t(X2) %*% W %*% X2, t(X2) %*% W %*% ys))
  y0s <- true_y0 + rnorm(1, 0, SD0)
  r   <- x0_of(bs, y0s)
  if (length(r) == 1) r else NA
})
cat(sprintf("Monte Carlo (B = %d): mean x0_hat = %.5f, NA = %d\n",
            B, mean(sim_x0, na.rm = TRUE), sum(is.na(sim_x0))))

rec("역추정: 2차 검교정 곡선의 수치 예",
    c("y0 (input)", "SD0 (input)", "SD recorded at x = 0.207",
      "quad b0 (in the root equation)", "quad b1", "quad b2",
      "x0_hat", "f'(x0_hat)", "new-reading part SD0/f'",
      "curve part sqrt(g'(X'WX)^-1 g)/f'", "SE(x0_hat) delta method",
      "SD of x0_hat over 20000 simulations (seed 20261126)",
      "share of variance from the new reading (%)",
      "SE(x0_hat) if sigma^2 estimated", "quad sigma2_hat",
      "x0_hat from the straight line", "x0_hat(quad) - x0_hat(line)"),
    c(y0, SD0, SD[x == 0.207],
      b[1], b[2], b[3],
      x0, fp, sqrt(v_new), sqrt(v_curve), se_x0,
      sd(sim_x0, na.rm = TRUE),
      100 * v_new / (v_new + v_curve),
      sqrt(wls2$s2) * se_x0, wls2$s2,
      x0_lin, x0 - x0_lin))

## ============================================================================
## Slide with no data-derived result (skipped): 감쇠 곡선: 문제 설정
## ============================================================================

## ============================================================================
## Slide: 감쇠 곡선: 분산의 증가
## One simulated attenuation experiment (Beer-Lambert + Poisson counts) and
## figure fig-a01-attenuation-variance.png. mu = 1.25 /cm and N0 = 20000 are
## simulation inputs, not measured constants.
## ============================================================================
set.seed(20260824)

MU <- 1.25          # true attenuation coefficient (per cm), simulation input
N0 <- 20000         # counts with no absorber
XG <- seq(0, 4, by = 0.4)

N    <- rpois(length(XG), N0 * exp(-MU * XG))
dat  <- data.frame(x = XG, N = N, logN = log(N), varlog = 1 / N)
fols <- lm(logN ~ x, data = dat)
fwls <- lm(logN ~ x, data = dat, weights = dat$N)

cat("\n===== one simulated attenuation experiment =====\n")
print(cbind(dat[c("x", "N", "logN")],
            varlog = round(dat$varlog, 6),
            sd_log = round(sqrt(dat$varlog), 4)))

png(file.path(out_dir, "fig-a01-attenuation-variance.png"), width = 2000, height = 1000, res = 170)
par(mfrow = c(1, 2), mar = c(4.5, 4.8, 3.5, 1),
    col.axis = INK2, col.lab = INK, fg = INK2)

sdl <- sqrt(dat$varlog)
plot(dat$x, dat$logN, pch = 16, col = COL_BLUE, cex = 1.1,
     ylim = range(dat$logN - 3 * sdl, dat$logN + 3 * sdl),
     panel.first = grid(col = GRID_C, lty = 1),
     main = "(a) log counts, with +-3 SD bars",
     xlab = "Absorber thickness (cm)", ylab = "log N")
arrows(dat$x, dat$logN - 3 * sdl, dat$x, dat$logN + 3 * sdl,
       angle = 90, code = 3, length = 0.04, col = COL_ORANGE, lwd = 2)
abline(fwls, col = COL_BLUE, lwd = 2, lty = 2)
legend("topright", bty = "n", pch = c(16, NA), lwd = c(NA, 2),
       col = c(COL_BLUE, COL_ORANGE),
       legend = c("log N", "+-3 SD, SD = sqrt(1/N)"), text.col = INK)

plot(dat$x, dat$varlog, type = "b", pch = 16, lwd = 2, cex = 1.1,
     col = COL_RED,
     panel.first = grid(col = GRID_C, lty = 1),
     main = "(b) the error variance is not constant",
     xlab = "Absorber thickness (cm)",
     ylab = expression(paste("Var(log N)  ", symbol("\273"), "  1/N")))
dev.off()

k5 <- match(c(0, 1.2, 2.4, 3.6, 4.0), round(dat$x, 1))   # the five columns of the slide table
rec("감쇠 곡선: 분산의 증가",
    c(sprintf("N at %.1f cm", dat$x[k5]), sprintf("Var(log N) = 1/N at %.1f cm", dat$x[k5]),
      "variance ratio 4.0 cm / 0 cm (fold)"),
    c(dat$N[k5], dat$varlog[k5], dat$varlog[nrow(dat)] / dat$varlog[1]))

## ============================================================================
## Slide: 감쇠 곡선: OLS와 WLS 비교
## 2000 repeated experiments (continuing the same random stream as the
## original script) and figure fig-a02-ols-vs-wls.png.
## ============================================================================
sim_one <- function() {
  Ns <- rpois(length(XG), N0 * exp(-MU * XG))
  k  <- Ns > 0
  d  <- data.frame(x = XG[k], N = Ns[k], logN = log(Ns[k]))
  c(-coef(lm(logN ~ x, data = d))[2],
    -coef(lm(logN ~ x, data = d, weights = d$N))[2])
}
res <- replicate(2000, sim_one())

png(file.path(out_dir, "fig-a02-ols-vs-wls.png"), width = 2000, height = 1000, res = 170)
par(mfrow = c(1, 2), mar = c(4.5, 4.8, 3.5, 1),
    col.axis = INK2, col.lab = INK, fg = INK2)

plot(dat$x, dat$logN, pch = 16, col = adjustcolor(INK2, alpha.f = 0.7), cex = 1.2,
     panel.first = grid(col = GRID_C, lty = 1),
     main = "(a) one experiment: the two fits nearly coincide",
     xlab = "Absorber thickness (cm)", ylab = "log N")
abline(fols, col = COL_ORANGE, lwd = 3, lty = 2)
abline(fwls, col = COL_BLUE,   lwd = 3)
legend("topright", bty = "n", lwd = 3, lty = c(2, 1),
       col = c(COL_ORANGE, COL_BLUE),
       legend = c(sprintf("OLS   mu-hat = %.3f", -coef(fols)[2]),
                  sprintf("WLS   mu-hat = %.3f", -coef(fwls)[2])),
       text.col = INK)

rng <- range(res)
bk  <- seq(rng[1], rng[2], length.out = 45)
h1  <- hist(res[1, ], breaks = bk, plot = FALSE)
h2  <- hist(res[2, ], breaks = bk, plot = FALSE)
plot(h1, col = adjustcolor(COL_ORANGE, alpha.f = 0.45), border = "white",
     ylim = c(0, max(h1$counts, h2$counts)),
     main = "(b) sampling distribution of mu-hat, 2000 repeats",
     xlab = expression(hat(mu)), ylab = "Frequency")
plot(h2, col = adjustcolor(COL_BLUE, alpha.f = 0.55), border = "white", add = TRUE)
abline(v = MU, col = COL_RED, lwd = 3)
legend("topright", bty = "n", fill = c(adjustcolor(COL_ORANGE, alpha.f = 0.45),
                                       adjustcolor(COL_BLUE, alpha.f = 0.55)),
       border = "white",
       legend = c(sprintf("OLS   SD = %.4f", sd(res[1, ])),
                  sprintf("WLS   SD = %.4f", sd(res[2, ]))),
       text.col = INK)
text(MU, max(h1$counts, h2$counts) * 0.55, labels = " true mu",
     col = COL_RED, pos = 4)
dev.off()

bias <- rowMeans(res) - MU
sdv  <- apply(res, 1, sd)
rmse <- sqrt(rowMeans((res - MU)^2))
rec("감쇠 곡선: OLS와 WLS 비교",
    c("OLS bias", "OLS SD", "OLS RMSE", "WLS bias", "WLS SD", "WLS RMSE",
      "variance ratio OLS/WLS"),
    c(bias[1], sdv[1], rmse[1], bias[2], sdv[2], rmse[2],
      var(res[1, ]) / var(res[2, ])))

## ============================================================================
## Slide: 감쇠 곡선: WLS의 한계
## Only the first row (weakest expected count 135, i.e. N0 exp(-MU * 4) for
## the design above) can be reproduced: its OLS and WLS biases are the 2000
## repeats of the previous slide. The Poisson-GLM column and the rows for an
## expected count of 13.5 and 1.3 come from a simulation whose script is not
## in code/agent or in the git history, so they are NOT recomputed here.
## ============================================================================
rec("감쇠 곡선: WLS의 한계",
    c("expected count at 4 cm = N0 exp(-4 MU)", "row 135: OLS bias", "row 135: WLS bias"),
    c(N0 * exp(-MU * 4), bias[1], bias[2]))

## ============================================================================
## Slide with no data-derived result (skipped): 일반화최소제곱(GLS): 정의와 WLS와의 관계
## ============================================================================

## ============================================================================
## Slide: GLS 예제: Lake Huron 수위
## OLS trend of the annual level 1875-1972, Durbin-Watson test, residual ACF,
## runs of one sign, and figure fig-m06-gls-lakehuron.png. The figure also
## draws the REML GLS fit, which is therefore fitted here; its numbers are
## reported under the next slide.
## ============================================================================
lh <- data.frame(year  = as.numeric(time(LakeHuron)),
                 level = as.numeric(LakeHuron))
nl <- nrow(lh)
cat("\nLake Huron: n =", nl, " years", min(lh$year), "-", max(lh$year),
    " consecutive:", all(diff(lh$year) == 1), "\n")

fit_ols <- lm(level ~ year, data = lh)
s_ols   <- summary(fit_ols)
e   <- residuals(fit_ols)
DW  <- sum(diff(e)^2) / sum(e^2)
dwe <- lmtest::dwtest(fit_ols, alternative = "greater")
ac  <- acf(e, plot = FALSE, lag.max = 12)$acf[, , 1]
runs <- sum(diff(sign(e)) != 0) + 1

fit_reml <- gls(level ~ year, data = lh, correlation = corAR1(form = ~ year),
                method = "REML")
rho_reml <- as.numeric(coef(fit_reml$modelStruct$corStruct, unconstrained = FALSE))
s_reml   <- summary(fit_reml)$tTable
tq       <- qt(0.975, nl - 2)

band <- function(vc, beta) {
  xs <- seq(min(lh$year), max(lh$year), length.out = 200)
  X0 <- cbind(1, xs)
  fit <- as.numeric(X0 %*% beta)
  se  <- sqrt(rowSums((X0 %*% vc) * X0))
  list(x = xs, fit = fit, lo = fit - tq * se, hi = fit + tq * se)
}
b_ols <- band(vcov(fit_ols), coef(fit_ols))
b_gls <- band(vcov(fit_reml), coef(fit_reml))

png(file.path(out_dir, "fig-m06-gls-lakehuron.png"), width = 2100, height = 840, res = 150)
op <- par(mfrow = c(1, 2), mar = c(4.4, 4.8, 3.0, 1.2), cex.axis = 1.05,
          cex.lab = 1.15, cex.main = 1.25)

## (a) the series, the two fitted trends and their 95% confidence bands
plot(lh$year, lh$level, type = "n", xlab = "Year", ylab = "Lake level (feet)",
     main = "(a) Annual level with the two fitted trends",
     ylim = range(lh$level, b_gls$lo, b_gls$hi))
polygon(c(b_gls$x, rev(b_gls$x)), c(b_gls$lo, rev(b_gls$hi)),
        col = "#DD845233", border = NA)
polygon(c(b_ols$x, rev(b_ols$x)), c(b_ols$lo, rev(b_ols$hi)),
        col = "#4C72B044", border = NA)
lines(lh$year, lh$level, col = "grey45", lwd = 1.3)
points(lh$year, lh$level, pch = 21, bg = "grey85", col = "grey35", cex = 0.8)
lines(b_ols$x, b_ols$fit, col = "#4C72B0", lwd = 2.6)
lines(b_gls$x, b_gls$fit, col = "#C44E52", lwd = 2.6, lty = 2)
legend("topright", bty = "n", cex = 0.98, lwd = 2.6, lty = c(1, 2),
       col = c("#4C72B0", "#C44E52"),
       legend = c(sprintf("OLS  slope %.4f (SE %.4f)",
                          coef(fit_ols)[2], s_ols$coefficients[2, 2]),
                  sprintf("GLS  slope %.4f (SE %.4f)",
                          coef(fit_reml)[2], s_reml[2, 2])))

## (b) residual ACF with the AR(1) curve rho^k drawn through it
L <- 12
plot(0:L, ac[1:(L + 1)], type = "n", xlab = "Lag (years)",
     ylab = "Residual autocorrelation", ylim = c(-0.3, 1),
     main = "(b) Residual ACF and the fitted AR(1) curve")
abline(h = 0, col = "grey35")
abline(h = c(-1, 1) * 1.96 / sqrt(nl), col = "#4C72B0", lty = 3, lwd = 1.6)
segments(0:L, 0, 0:L, ac[1:(L + 1)], lwd = 7, col = "#4C72B0")
lines(0:L, rho_reml^(0:L), col = "#C44E52", lwd = 2.6)
points(0:L, rho_reml^(0:L), pch = 16, col = "#C44E52", cex = 0.9)
legend("topright", bty = "n", cex = 0.98,
       legend = c(sprintf("Durbin-Watson = %.3f  (p = %.1e)", DW, dwe$p.value),
                  sprintf("AR(1) curve: rho^k with rho = %.3f", rho_reml),
                  "dotted: +/- 1.96/sqrt(n)"))
par(op)
dev.off()

rec("GLS 예제: Lake Huron 수위",
    c("n", "first year", "last year", "Durbin-Watson d", "Durbin-Watson exact p",
      "residual ACF lag 1", "residual ACF lag 2", "residual ACF lag 3",
      "runs of one sign", "sign changes (= runs - 1)"),
    c(nl, min(lh$year), max(lh$year), DW, dwe$p.value,
      ac[2], ac[3], ac[4], runs, runs - 1))

## ============================================================================
## Slide: GLS 예제: OLS와 GLS 비교
## rho estimated three ways (Cochrane-Orcutt, ML, REML), OLS vs feasible GLS
## (REML, AR(1)) coefficient table, slope CIs, likelihood ratio test for
## rho = 0, and the lag-1 autocorrelation left after the GLS transform.
## ============================================================================
X  <- model.matrix(fit_ols)
yl <- lh$level
p  <- ncol(X)

gls_by_hand <- function(rho) {
  V    <- rho^abs(outer(seq_len(nl), seq_len(nl), "-"))
  Vinv <- solve(V)
  XtVX <- t(X) %*% Vinv %*% X
  beta <- solve(XtVX, t(X) %*% Vinv %*% yl)
  res  <- yl - X %*% beta
  s2   <- as.numeric(t(res) %*% Vinv %*% res) / (nl - p)
  list(beta = drop(beta), se = sqrt(diag(s2 * solve(XtVX))), s2 = s2, rho = rho)
}

## Cochrane-Orcutt: start from the residual lag-1 correlation and iterate
r1 <- sum(e[-1] * e[-nl]) / sum(e^2)
rho_co <- r1
for (k in 1:200) {
  gco    <- gls_by_hand(rho_co)
  rco    <- yl - X %*% gco$beta
  rho_nw <- sum(rco[-1] * rco[-nl]) / sum(rco^2)
  if (abs(rho_nw - rho_co) < 1e-11) { rho_co <- rho_nw; break }
  rho_co <- rho_nw
}
fit_ml <- gls(level ~ year, data = lh, correlation = corAR1(form = ~ year),
              method = "ML")
rho_ml <- as.numeric(coef(fit_ml$modelStruct$corStruct, unconstrained = FALSE))

## cross-check of nlme::gls against the matrix solve at rho_reml
g_reml <- gls_by_hand(rho_reml)
cat("\nGLS: max abs difference hand vs nlme beta =",
    max(abs(g_reml$beta - coef(fit_reml))), "\n")

ci_ols <- confint(fit_ols)["year", ]
ci_gls <- s_reml["year", 1] + c(-1, 1) * tq * s_reml["year", 2]

## likelihood ratio test: does the AR(1) term earn its place?
fit_ml0 <- gls(level ~ year, data = lh, method = "ML")
lrt     <- anova(fit_ml0, fit_ml)
print(lrt)

## autocorrelation left after the GLS transform P (P'P proportional to V^-1)
P <- diag(nl); P[1, 1] <- sqrt(1 - rho_reml^2)
for (i in 2:nl) { P[i, i] <- 1; P[i, i - 1] <- -rho_reml }
res_w <- as.numeric(P %*% (yl - X %*% g_reml$beta))

rec("GLS 예제: OLS와 GLS 비교",
    c("rho REML", "rho Cochrane-Orcutt", "rho ML",
      "OLS b0", "OLS SE(b0)", "GLS b0", "GLS SE(b0)",
      "OLS b1", "OLS SE(b1)", "GLS b1", "GLS SE(b1)",
      "OLS t(b1)", "GLS t(b1)", "OLS p(b1)", "GLS p(b1)",
      "OLS 95% CI lower", "OLS 95% CI upper", "GLS 95% CI lower", "GLS 95% CI upper",
      "SE ratio GLS/OLS (slope)", "CI width ratio GLS/OLS", "residual df (n - 2)",
      "LRT chi-square (rho = 0)", "LRT p", "lag-1 autocorrelation after GLS transform",
      "covariance cells n^2"),
    c(rho_reml, rho_co, rho_ml,
      s_ols$coefficients[1, 1], s_ols$coefficients[1, 2], s_reml[1, 1], s_reml[1, 2],
      s_ols$coefficients[2, 1], s_ols$coefficients[2, 2], s_reml[2, 1], s_reml[2, 2],
      s_ols$coefficients[2, 3], s_reml[2, 3], s_ols$coefficients[2, 4], s_reml[2, 4],
      ci_ols[1], ci_ols[2], ci_gls[1], ci_gls[2],
      s_reml[2, 2] / s_ols$coefficients[2, 2], diff(ci_gls) / diff(ci_ols), nl - p,
      lrt$L.Ratio[2], lrt$`p-value`[2],
      sum(res_w[-1] * res_w[-nl]) / sum(res_w^2),
      nl^2))

## ============================================================================
## Slides with no data-derived result (skipped): 이 장의 정리 / 참고문헌
## ============================================================================

write.csv(num, file.path(out_dir, "tab-ch06-numbers.csv"), row.names = FALSE, fileEncoding = "UTF-8")
cat("\nwrote", file.path(out_dir, "tab-ch06-numbers.csv"), "with", nrow(num), "rows\n")
cat("figures written to", out_dir, "\n")
