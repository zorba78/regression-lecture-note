# Date        : 2026-11-26
# Description : Recompute every number that chapter 6 (Weighted Regression) of
#               the KINS lecture shows for the physics example, from the
#               original data, and write a reproduction table.
#
#               Data: alr4::physics (Weisberg, S. 2014, Applied Linear
#               Regression, 4th ed., Wiley; original source Weisberg, H. et al.
#               1978, Physics Review D 17, 2875-2887). Values were checked
#               against data/physics.rda of the CRAN alr4 1.0.7 source:
#                 - the 4th x is 0.225 (the CNU lecture-note code had 0.255),
#                 - the third column is the STANDARD DEVIATION of y (SD),
#                   so the precision weight is w = 1/SD^2.
#               alr4 is not installed here (no CRAN access), so the ten rows are
#               typed in below and compared with the .rda when it is present.
#
#               Quantities computed (all by matrix formulas, then cross-checked
#               against lm(); lm() is used only as a check):
#                 1. OLS and WLS straight-line fits, SE, R^2
#                 2. weighted residuals r_i^w = sqrt(w_i) e_i = e_i / SD_i
#                 3. lack-of-fit statistic X^2 = sum r_i^w^2 and its chi-square p
#                 4. WLS quadratic fit
#                 5. extra-sum-of-squares F for the quadratic term
#                 6. VIF of x and x^2 (weighted and unweighted)
#                 7. inverse prediction x0_hat for a new reading y0 on the
#                    quadratic curve, with its delta-method standard error,
#                    cross-checked by numerical differentiation and by Monte
#                    Carlo simulation
#
#               Output: output/agent/2026-11-26/tab-ch06-physics-reproduction.csv
#               Run   : Rscript code/agent/2026-11-26/check-ch06-physics-wls.R
# File        : check-ch06-physics-wls.R

root    <- "g:/Projects/regression-lecture-note"
out_dir <- file.path(root, "output/agent/2026-11-26")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

## ---- data ---------------------------------------------------------------

phys <- data.frame(
  x  = c(0.345, 0.287, 0.251, 0.225, 0.207, 0.186, 0.161, 0.132, 0.084, 0.060),
  y  = c(367, 311, 295, 268, 253, 239, 220, 213, 193, 192),
  SD = c(17, 9, 9, 7, 7, 6, 6, 6, 5, 5)
)

# Compare with the original package file when the downloaded copy still exists
# (it lives in a session scratchpad and may have been cleaned up).
rda <- paste0("C:/Users/user/AppData/Local/Temp/claude/8e9d2e3cd900d121/",
              "7b1be0f0-af40-4a47-bf09-5ad6ab7c7670/scratchpad/alr4dl/alr4/",
              "data/physics.rda")
if (file.exists(rda)) {
  e <- new.env(); load(rda, envir = e)
  cat("identical to alr4 physics.rda:",
      isTRUE(all.equal(phys, as.data.frame(e$physics), check.attributes = FALSE)),
      "\n")
} else {
  cat("alr4 physics.rda not found - comparison skipped\n")
}

x <- phys$x; y <- phys$y; SD <- phys$SD
n <- nrow(phys)
w <- 1 / SD^2                       # precision weight: inverse of the variance
W <- diag(w)

## ---- helpers: WLS by the matrix formula -----------------------------------
# beta = (X'WX)^{-1} X'Wy
# weighted RSS   S_W = sum w_i e_i^2                       (= X^2 when SD known)
# sigma2_hat     = S_W / (n - p - 1)                      (scale estimated)
# Var(beta)      = sigma2 (X'WX)^{-1}; sigma2 = sigma2_hat or 1 (SD known)
# weighted R^2   = 1 - S_W / sum w_i (y_i - ybar_w)^2,  ybar_w = sum w y / sum w
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

## ---- cross-check against lm() ---------------------------------------------
chk <- function(a, b) stopifnot(isTRUE(all.equal(unname(a), unname(b), tolerance = 1e-10)))
m_ols1 <- lm(y ~ x); m_wls1 <- lm(y ~ x, weights = w); m_wls2 <- lm(y ~ x + I(x^2), weights = w)
chk(ols1$b, coef(m_ols1)); chk(ols1$se_est, summary(m_ols1)$coefficients[, 2])
chk(ols1$R2, summary(m_ols1)$r.squared)
chk(wls1$b, coef(m_wls1)); chk(wls1$se_est, summary(m_wls1)$coefficients[, 2])
chk(wls1$R2, summary(m_wls1)$r.squared); chk(wls1$s2, summary(m_wls1)$sigma^2)
chk(wls2$b, coef(m_wls2)); chk(wls2$se_est, summary(m_wls2)$coefficients[, 2])
chk(wls2$R2, summary(m_wls2)$r.squared)
chk(wls1$rw, weighted.residuals(m_wls1)); chk(wls2$rw, weighted.residuals(m_wls2))
chk(wls1$h, hatvalues(m_wls1)); chk(wls2$h, hatvalues(m_wls2))
cat("matrix formulas agree with lm() to 1e-10\n")

## ---- printout -------------------------------------------------------------
pr <- function(lab, f) {
  cat(sprintf("\n== %s ==\n", lab))
  print(data.frame(b = f$b, se_est = f$se_est, se_known = f$se_known,
                   t_est = f$b / f$se_est))
  cat(sprintf("df=%d  S_W=%.4f  sigma2_hat=%.4f  R2=%.4f\n", f$df, f$SW, f$s2, f$R2))
}
pr("OLS linear", ols1); pr("WLS linear", wls1); pr("WLS quadratic", wls2)

cat("\nweight 1/SD^2          :", signif(w, 4), "\n")
cat("weight relative to max :", round(w / max(w), 3), "\n")
cat("weighted resid, linear :", sprintf("%.2f", wls1$rw), "\n")
cat("weighted resid, quad   :", sprintf("%.2f", wls2$rw), "\n")
cat("weighted leverage lin  :", sprintf("%.3f", wls1$h), "\n")
cat("weighted leverage quad :", sprintf("%.3f", wls2$h), "\n")
# studentized version, for comparison only: r_i = rw_i / sqrt(1 - h_ii) (SD known)
cat("rw/sqrt(1-h), linear   :", sprintf("%.2f", wls1$rw / sqrt(1 - wls1$h)), "\n")

## lack of fit: X^2 = S_W ~ chi^2(n - p - 1) when SD is known, model correct, normal
p_lof1 <- pchisq(wls1$SW, wls1$df, lower.tail = FALSE)
p_lof2 <- pchisq(wls2$SW, wls2$df, lower.tail = FALSE)
cat(sprintf("\nlack of fit: linear X2=%.4f df=%d X2/df=%.4f p=%.5f\n", wls1$SW, wls1$df, wls1$SW / wls1$df, p_lof1))
cat(sprintf("lack of fit: quad   X2=%.4f df=%d X2/df=%.4f p=%.5f\n", wls2$SW, wls2$df, wls2$SW / wls2$df, p_lof2))
cat(sprintf("chi-square 0.95 quantiles: df8 %.3f  df7 %.3f\n", qchisq(0.95, 8), qchisq(0.95, 7)))

## extra sum of squares F for the quadratic term (k = 1)
Fq  <- ((wls1$SW - wls2$SW) / 1) / (wls2$SW / wls2$df)
pFq <- pf(Fq, 1, wls2$df, lower.tail = FALSE)
cat(sprintf("\nF = {(%.4f - %.4f)/1} / (%.4f/%d) = %.4f, p = %.6f\n",
            wls1$SW, wls2$SW, wls2$SW, wls2$df, Fq, pFq))
chk(Fq, anova(m_wls1, m_wls2)$F[2])
cat(sprintf("t^2 for beta2 = %.4f (equals F)\n", (wls2$b[3] / wls2$se_est[3])^2))
# SD-known version: drop in X^2 ~ chi^2(1)
cat(sprintf("SD known: X2 drop = %.4f, chi2(1) p = %.6f\n",
            wls1$SW - wls2$SW, pchisq(wls1$SW - wls2$SW, 1, lower.tail = FALSE)))

## VIF of x and x^2. Unweighted: 1/(1 - cor^2). Weighted: same with weighted
## centring, i.e. the R^2 of the WLS regression of x on x^2 (with intercept).
vif_u <- 1 / (1 - cor(x, x^2)^2)
r2w   <- summary(lm(x ~ I(x^2), weights = w))$r.squared
vif_w <- 1 / (1 - r2w)
cat(sprintf("\nVIF(x, x^2): unweighted %.1f  weighted %.1f  (cor = %.4f)\n", vif_u, vif_w, cor(x, x^2)))
# a centred quadratic removes most of it: x and (x - xbar_w)^2
xc    <- x - sum(w * x) / sum(w)
r2wc  <- summary(lm(xc ~ I(xc^2), weights = w))$r.squared
cat(sprintf("VIF after weighted centring: %.2f\n", 1 / (1 - r2wc)))
m_c   <- lm(y ~ xc + I(xc^2), weights = w)
print(round(summary(m_c)$coefficients, 3))

## ---- inverse prediction on the quadratic curve -------------------------
# f(x; b) = b0 + b1 x + b2 x^2. Given a new reading y0 with standard deviation
# SD0, x0_hat solves f(x0_hat; b_hat) = y0 (root inside the calibrated range).
# Implicit-function derivatives:
#   d x0 / d y0 = 1 / f'(x0),        f'(x0) = b1 + 2 b2 x0
#   d x0 / d b  = -(1, x0, x0^2) / f'(x0)
# Delta method, y0 independent of b_hat:
#   Var(x0_hat) ~ { Var(y0) + g' Var(b_hat) g } / f'(x0)^2,  g = (1, x0, x0^2)
# With SD known (sigma^2 = 1): Var(y0) = SD0^2, Var(b_hat) = (X'WX)^{-1}.
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
cat(sprintf("\ninverse prediction: y0 = %g, SD0 = %g\n", y0, SD0))
cat(sprintf("x0_hat = %.5f ; f'(x0) = %.3f\n", x0, fp))
cat(sprintf("Var(y0)=%.3f ; g'Var(b)g = %.4f (SD %.4f)\n", SD0^2, drop(t(g) %*% wls2$A %*% g), sqrt(drop(t(g) %*% wls2$A %*% g))))
cat(sprintf("components: new reading %.3e, curve %.3e ; SE(x0_hat) = %.5f\n", v_new, v_curve, se_x0))
cat(sprintf("share of variance: new reading %.1f%%, curve %.1f%%\n", 100 * v_new / (v_new + v_curve), 100 * v_curve / (v_new + v_curve)))
# same with sigma^2 estimated (sigma2_hat scales both terms)
cat(sprintf("if sigma^2 estimated (%.4f): SE = %.5f\n", wls2$s2, sqrt(wls2$s2) * se_x0))
# linear-curve version for reference
b1 <- wls1$b; x0_lin <- (y0 - b1[1]) / b1[2]
cat(sprintf("straight line would give x0_hat = %.5f\n", x0_lin))

# check 1: numerical gradient of x0_hat with respect to (b, y0)
eps <- 1e-6
num_grad <- sapply(1:4, function(j) {
  th <- c(b, y0); thp <- th; thm <- th; thp[j] <- th[j] + eps; thm[j] <- th[j] - eps
  (x0_of(thp[1:3], thp[4]) - x0_of(thm[1:3], thm[4])) / (2 * eps)
})
ana_grad <- c(-g / fp, 1 / fp)
cat("gradient analytic :", signif(ana_grad, 6), "\n")
cat("gradient numerical:", signif(num_grad, 6), "\n")
stopifnot(max(abs(num_grad - ana_grad) / abs(ana_grad)) < 1e-5)

# check 2: Monte Carlo with SD known. Truth = fitted quadratic; regenerate the
# ten calibration points and the new reading, refit, invert.
set.seed(20261126)
B <- 20000
true_y0 <- y0                          # the new item's true response
sim <- replicate(B, {
  ys  <- drop(X2 %*% b) + rnorm(n, 0, SD)
  bs  <- drop(solve(t(X2) %*% W %*% X2, t(X2) %*% W %*% ys))
  y0s <- true_y0 + rnorm(1, 0, SD0)
  r   <- x0_of(bs, y0s)
  if (length(r) == 1) r else NA
})
cat(sprintf("Monte Carlo (B = %d): mean x0_hat = %.5f, SD = %.5f, NA = %d\n",
            B, mean(sim, na.rm = TRUE), sd(sim, na.rm = TRUE), sum(is.na(sim))))
cat(sprintf("delta-method SE / Monte Carlo SD = %.4f\n", se_x0 / sd(sim, na.rm = TRUE)))
mc_sd <- sd(sim, na.rm = TRUE)

## ---- reproduction table -------------------------------------------------
f3 <- function(v) formatC(signif(v, 3), format = "fg", digits = 3, flag = "#")
rep_tab <- data.frame(
  quantity = c(
    "OLS b0", "OLS SE(b0)", "OLS b1", "OLS SE(b1)", "OLS R2",
    "WLS1 b0", "WLS1 SE(b0)", "WLS1 b1", "WLS1 SE(b1)", "WLS1 R2",
    "WLS1 X2 (= S_W)", "WLS1 df", "WLS1 X2/df (= sigma2_hat)", "WLS1 LOF p",
    paste0("WLS1 r_w[", 1:10, "]"),
    "WLS2 b0", "WLS2 SE(b0)", "WLS2 b1", "WLS2 SE(b1)", "WLS2 b2", "WLS2 SE(b2)", "WLS2 R2",
    "WLS2 X2 (= S_W)", "WLS2 df", "WLS2 X2/df", "WLS2 LOF p",
    paste0("WLS2 r_w[", 1:10, "]"),
    "F (quadratic term)", "p of F",
    "VIF x,x^2 weighted",
    "inverse: x0_hat", "inverse: f'(x0)", "inverse: SE new-reading part", "inverse: SE curve part",
    "inverse: SE(x0_hat) delta", "inverse: SD(x0_hat) Monte Carlo"),
  value = c(
    ols1$b[1], ols1$se_est[1], ols1$b[2], ols1$se_est[2], ols1$R2,
    wls1$b[1], wls1$se_est[1], wls1$b[2], wls1$se_est[2], wls1$R2,
    wls1$SW, wls1$df, wls1$s2, p_lof1, wls1$rw,
    wls2$b[1], wls2$se_est[1], wls2$b[2], wls2$se_est[2], wls2$b[3], wls2$se_est[3], wls2$R2,
    wls2$SW, wls2$df, wls2$s2, p_lof2, wls2$rw,
    Fq, pFq, vif_w,
    x0, fp, sqrt(v_new), sqrt(v_curve), se_x0, mc_sd),
  formula = c(
    rep("(X'X)^-1 X'y ; SE = sqrt(diag(s2 (X'X)^-1)), s2 = SSE/8", 4), "1 - SSE/SST",
    rep("(X'WX)^-1 X'Wy, W = diag(1/SD^2) ; SE = sqrt(diag(s2 (X'WX)^-1)), s2 = S_W/8", 4),
    "1 - S_W / sum w (y - ybar_w)^2",
    "sum w_i e_i^2", "n - 2", "S_W / 8", "P(chi2_8 > X2)",
    rep("(y_i - yhat_i) / SD_i, straight line", 10),
    rep("(X'WX)^-1 X'Wy, X = [1, x, x^2] ; SE with s2 = S_W/7", 6),
    "1 - S_W / sum w (y - ybar_w)^2",
    "sum w_i e_i^2", "n - 3", "S_W / 7", "P(chi2_7 > X2)",
    rep("(y_i - yhat_i) / SD_i, quadratic", 10),
    "{(S_W1 - S_W2)/1} / (S_W2/7)", "P(F_{1,7} > F)",
    "1 / (1 - R2_w(x on x^2))",
    "root of f(x) = 250 in (0, 0.5)", "b1 + 2 b2 x0", "SD0 / |f'(x0)|, SD0 = 7",
    "sqrt(g'(X'WX)^-1 g) / |f'(x0)|", "sqrt(sum of squares of the two parts)",
    "SD of 20000 refits, seed 20261126"),
  script = "code/agent/2026-11-26/check-ch06-physics-wls.R"
)
# secondary numbers quoted in the slide bodies and speaker notes
xbar_w <- sum(w * x) / sum(w)
extra <- data.frame(
  quantity = c("weight ratio w1/w10 = 25/289", "SD ratio SD1/SD10",
               "1/(w1/w10)", "WLS1 e_1", "WLS1 e_10",
               "WLS1 weighted leverage h_10", "WLS1 r_w[10]/sqrt(1-h_10)",
               "chi2(8) 0.95 quantile", "P(chi2_7 < 3.23) (lower tail)",
               "1/sqrt(sigma2_hat quad)", "weighted mean of x",
               "centred quad: slope at xbar_w", "centred quad: SE of that slope",
               "VIF after weighted centring", "max |r_w| quadratic",
               "S_W1 - S_W2", "t^2 of beta2 (quad)",
               "inverse: share of variance from new reading (%)",
               "inverse: SE if sigma^2 estimated", "inverse: straight-line x0_hat",
               "inverse: x0_hat(quad) - x0_hat(line)"),
  value = c(w[1] / w[10], SD[1] / SD[10], w[10] / w[1], wls1$e[1], wls1$e[10],
            wls1$h[10], wls1$rw[10] / sqrt(1 - wls1$h[10]),
            qchisq(0.95, 8), pchisq(wls2$SW, 7),
            1 / sqrt(wls2$s2), xbar_w,
            coef(m_c)[2], summary(m_c)$coefficients[2, 2],
            1 / (1 - r2wc), max(abs(wls2$rw)),
            wls1$SW - wls2$SW, (wls2$b[3] / wls2$se_est[3])^2,
            100 * v_new / (v_new + v_curve),
            sqrt(wls2$s2) * se_x0, x0_lin, x0 - x0_lin),
  formula = c("(1/17^2)/(1/5^2)", "17/5", "289/25", "y_1 - yhat_1", "y_10 - yhat_10",
              "diag of W^1/2 X (X'WX)^-1 X' W^1/2", "r_w / sqrt(1 - h)",
              "qchisq(0.95, 8)", "pchisq(3.2255, 7)", "1/sqrt(0.4608)", "sum w x / sum w",
              "b1 + 2 b2 xbar_w", "WLS of y on (x - xbar_w), (x - xbar_w)^2",
              "1/(1 - R2_w(xc on xc^2))", "max over i", "21.95 - 3.23", "(b2/SE)^2",
              "Var new / (Var new + Var curve)", "sqrt(sigma2_hat) x SE(x0_hat)",
              "(250 - b0)/b1, straight line", "difference"),
  script = "code/agent/2026-11-26/check-ch06-physics-wls.R"
)
rep_tab <- rbind(rep_tab, extra)
rep_tab$shown_3sig <- f3(rep_tab$value)
write.csv(rep_tab, file.path(out_dir, "tab-ch06-physics-reproduction.csv"), row.names = FALSE)
cat("\nwrote", file.path(out_dir, "tab-ch06-physics-reproduction.csv"), "\n")
print(rep_tab[, c("quantity", "value", "shown_3sig")], row.names = FALSE)
