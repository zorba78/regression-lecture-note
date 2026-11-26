# Date        : 2026-11-26
# Description : Numerical checks for the second-round (r8) edits of chapter 5
#               (Diagnosis & Variable Selection). Complements check-ch05-links.R
#               in the same folder. Checks:
#                 (A) the "Standardized residuals" printed on R's diagnostic
#                     plot axes are exactly r_i = e_i / (sigma_hat sqrt(1-h_ii)),
#                     i.e. the value the deck calls the studentized residual;
#                 (B) the shape of the Scale-Location smoother for the full
#                     model, read numerically rather than by eye;
#                 (C) Breusch-Pagan tests for the ice cream full model (the
#                     Breusch-Pagan p = 0.081 on the deck is for the Galapagos
#                     data, a different data set);
#                 (D) the Bonferroni outlier test: max |t_i| and the critical
#                     value t_{alpha/(2n), n-p-2} written out step by step;
#                 (E) c_jj = VIF_j / S_jj for price, the chapter 4 diagonal 507.68.
#               Data: CNU lecture note R examples, chapter 7 ice cream data
#               (ice.csv.csv, n = 30). Run from the project root:
#                 Rscript code/agent/2026-11-26/check-ch05-r8-numbers.R
# File        : check-ch05-r8-numbers.R

ice <- read.csv("references/cnu-regression-lecture-note/강의노트/R 예제/7장/ice.csv.csv")
n   <- nrow(ice)
fit <- lm(IC ~ price + income + temp, data = ice)   # full model, p = 3
p   <- length(coef(fit)) - 1

e     <- resid(fit)
h     <- hatvalues(fit)
s_hat <- summary(fit)$sigma                          # sqrt(SSE / (n - p - 1))
yhat  <- fitted(fit)

## (A) plot.lm draws rstandard(); compare with the deck's formula for r_i
r_formula <- e / (s_hat * sqrt(1 - h))
cat("(A) max |rstandard - e/(sigma_hat*sqrt(1-h))| =",
    format(max(abs(rstandard(fit) - r_formula)), digits = 3), "\n")

## (B) Scale-Location: y = sqrt(|r_i|) against fitted values. plot.lm adds
##     panel.smooth = lowess(x, y, f = 2/3, iter = 3); read the curve at a few
##     fitted values and count how many points lie at the right end
sl_y <- sqrt(abs(r_formula))
lw   <- lowess(yhat, sl_y, f = 2/3, iter = 3)
grid_x <- c(0.26, 0.30, 0.35, 0.40, 0.44, 0.47)
cat("(B) lowess of sqrt|r_i| at fitted =", grid_x, "\n    ->",
    round(approx(lw$x, lw$y, xout = pmin(grid_x, max(lw$x)))$y, 2), "\n")
cat("    fitted range =", round(range(yhat), 3),
    "; points with fitted > 0.40:", sum(yhat > 0.40),
    "; obs with largest fitted =", which.max(yhat),
    "(sqrt|r| =", round(sl_y[which.max(yhat)], 2), ")\n")
cat("    cor(sqrt|r_i|, fitted) =", round(cor(sl_y, yhat), 3), "\n")
## How much of the right-end rise rests on the last few points: count points
## beyond fitted 0.42 and refit the smoother without observation 30
cat("    points with fitted > 0.42:", sum(yhat > 0.42),
    "-> obs", paste(which(yhat > 0.42), collapse = ","),
    "with sqrt|r| =", paste(round(sl_y[yhat > 0.42], 2), collapse = ","), "\n")
keep <- seq_len(n) != 30
lw30 <- lowess(yhat[keep], sl_y[keep], f = 2/3, iter = 3)
cat("    lowess without obs 30 at fitted =", grid_x[1:5], "\n    ->",
    round(approx(lw30$x, lw30$y, xout = pmin(grid_x[1:5], max(lw30$x)))$y, 2), "\n")

## (C) Breusch-Pagan: regress squared residuals on the model's predictors.
##     Studentized (Koenker) version = n * R^2 of e^2 on X, chi^2 with p df.
##     This is the default of lmtest::bptest(), which the Galapagos slide used.
aux    <- lm(I(e^2) ~ price + income + temp, data = ice)
bp_k   <- n * summary(aux)$r.squared
cat("(C) Koenker BP on (price, income, temp): LM =", round(bp_k, 3),
    "df =", p, "p =", round(pchisq(bp_k, p, lower.tail = FALSE), 3), "\n")
aux_f  <- lm(I(e^2) ~ yhat)
bp_kf  <- n * summary(aux_f)$r.squared
cat("    Koenker BP on fitted values only : LM =", round(bp_kf, 3),
    "df = 1 p =", round(pchisq(bp_kf, 1, lower.tail = FALSE), 3), "\n")
if (requireNamespace("lmtest", quietly = TRUE)) {
  bt <- lmtest::bptest(fit)
  cat("    lmtest::bptest(fit) cross-check  : LM =", round(unname(bt$statistic), 3),
      "p =", round(bt$p.value, 3), "\n")
}

## (D) Bonferroni outlier test, alpha = 0.05, all n observations tested.
##     Per-test level alpha/n, two-sided -> upper tail alpha/(2n); df = n-p-2
t_ext  <- rstudent(fit)
alpha  <- 0.05
df_t   <- n - p - 2
crit   <- qt(1 - alpha / (2 * n), df_t)
cat("(D) max |t_i| =", round(max(abs(t_ext)), 3), "at obs", which.max(abs(t_ext)),
    "; alpha/(2n) =", signif(alpha / (2 * n), 4), "; df = n-p-2 =", df_t,
    "; critical t =", round(crit, 3), "\n")
cat("    Bonferroni-adjusted p for obs 30 = n * 2 * P(T > |t|) =",
    round(min(1, n * 2 * pt(max(abs(t_ext)), df_t, lower.tail = FALSE)), 3), "\n")

## (E) Var(b_j) = sigma^2 * VIF_j / S_jj, so the diagonal c_jj = VIF_j / S_jj
X     <- model.matrix(fit)
c_pp  <- solve(crossprod(X))["price", "price"]
s_pp  <- sum((ice$price - mean(ice$price))^2)
vif_p <- 1 / (1 - summary(lm(price ~ income + temp, data = ice))$r.squared)
cat("(E) c_pp =", round(c_pp, 2), "; S_pp =", signif(s_pp, 4), "; VIF =", round(vif_p, 4),
    "; VIF/S_pp =", round(vif_p / s_pp, 2), "; 1/S_pp =", round(1 / s_pp, 2),
    "; share due to overlap = VIF - 1 =", round(vif_p - 1, 4), "\n")
