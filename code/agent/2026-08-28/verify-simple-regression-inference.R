# Date        : 2026-08-28
# Description : Verify every number and every algebraic claim for the four
#               slides added to chapter 3 (Simple Linear Regression):
#                 (1) unbiasedness   E(b1) = beta1, E(b0) = beta0
#                 (2) variances      Var(b1), Var(b0), Cov(b0, b1)
#                 (3) Gauss-Markov   OLS is BLUE, shown against a competing
#                                    linear unbiased estimator built from the
#                                    same data
#                 (4) ANOVA          the F test and the identity F = t^2 that
#                                    holds only when there is one predictor
#               The whole argument rests on writing b1 as a fixed weighted sum
#               of the responses, b1 = sum(c_i * y_i) with c_i = (x_i - xbar)/Sxx,
#               so the three properties of those weights are checked first.
#               Data: ice cream consumption, n = 30, IC ~ temp.
# File        : verify-simple-regression-inference.R

options(digits = 10)

ice <- read.csv("../../../references/cnu-regression-lecture-note/강의노트/R 예제/7장/ice.csv.csv")
names(ice) <- tolower(names(ice))
x <- ice$temp
y <- ice$ic
n <- length(y)

xbar <- mean(x); ybar <- mean(y)
Sxx  <- sum((x - xbar)^2)
Sxy  <- sum((x - xbar) * (y - ybar))
b1   <- Sxy / Sxx
b0   <- ybar - b1 * xbar
fit  <- lm(ic ~ temp, data = ice)

cat("n =", n, "  xbar =", xbar, "  ybar =", ybar, "\n")
cat("Sxx =", Sxx, "  Sxy =", Sxy, "\n")
cat("b1 =", b1, "   b0 =", b0, "\n")
cat("max |coef - lm| =", max(abs(c(b0, b1) - coef(fit))), "\n\n")

cat("=== (1) the weights c_i = (x_i - xbar)/Sxx ===\n")
# b1 is a FIXED weighted sum of the y's; that is what makes it linear.
cc <- (x - xbar) / Sxx
cat("b1 = sum(c_i y_i) ?  value =", sum(cc * y), "  difference =",
    abs(sum(cc * y) - b1), "\n")
cat("sum(c_i)      =", sum(cc),        "  (must be 0)\n")
cat("sum(c_i x_i)  =", sum(cc * x),    "  (must be 1)\n")
cat("sum(c_i^2)    =", sum(cc^2),      "  = 1/Sxx =", 1 / Sxx,
    "  difference =", abs(sum(cc^2) - 1 / Sxx), "\n")
# Unbiasedness follows at once: E(b1) = beta0*sum(c) + beta1*sum(c*x) = beta1.
# The two sums above ARE the proof, so they are printed rather than asserted.
cat("\n")

cat("=== (1b) unbiasedness checked by simulation on the real design ===\n")
# beta and the errors are unknown in real data, so the response is regenerated
# from a beta we choose. The average of many fitted slopes must approach it.
set.seed(20260828)
beta_true <- c(0.20, 0.0031)
sigma_sim <- 0.0423
B <- 20000
sim <- replicate(B, {
  ys <- beta_true[1] + beta_true[2] * x + rnorm(n, 0, sigma_sim)
  c(sum(cc * ys), mean(ys) - sum(cc * ys) * xbar)   # b1, b0
})
cat("mean of b1 over", B, "draws =", mean(sim[1, ]), "  true beta1 =", beta_true[2], "\n")
cat("mean of b0 over", B, "draws =", mean(sim[2, ]), "  true beta0 =", beta_true[1], "\n")
cat("sd   of b1 =", sd(sim[1, ]), "  theory sqrt(sigma^2/Sxx) =",
    sqrt(sigma_sim^2 / Sxx), "\n")
cat("sd   of b0 =", sd(sim[2, ]), "  theory =",
    sqrt(sigma_sim^2 * (1 / n + xbar^2 / Sxx)), "\n\n")

cat("=== (2) variances and the covariance ===\n")
SSE   <- sum(residuals(fit)^2)
s2    <- SSE / (n - 2)
se_b1 <- sqrt(s2 / Sxx)
se_b0 <- sqrt(s2 * (1 / n + xbar^2 / Sxx))
cov01 <- -s2 * xbar / Sxx
cat("SSE =", SSE, "   sigma^2 hat = SSE/(n-2) =", s2, "   sigma hat =", sqrt(s2), "\n")
cat("se(b1) = sqrt(s2/Sxx)                 =", se_b1, "\n")
cat("se(b0) = sqrt(s2*(1/n + xbar^2/Sxx))  =", se_b0, "\n")
cat("compare with summary(lm):\n")
print(summary(fit)$coefficients)
cat("max |se - lm se| =",
    max(abs(c(se_b0, se_b1) - summary(fit)$coefficients[, 2])), "\n")
cat("Cov(b0,b1) = -s2*xbar/Sxx =", cov01,
    "   vcov(lm)[1,2] =", vcov(fit)[1, 2],
    "   difference =", abs(cov01 - vcov(fit)[1, 2]), "\n\n")

cat("=== (3) Gauss-Markov: a competing linear unbiased estimator ===\n")
# Split at the median of x and use the two group means. This is linear in y and,
# as the two checks below show, unbiased - so Gauss-Markov says its variance
# cannot be smaller than that of least squares.
hi <- x > median(x); lo <- !hi
nH <- sum(hi); nL <- sum(lo)
d  <- mean(x[hi]) - mean(x[lo])
a  <- ifelse(hi, 1 / (nH * d), -1 / (nL * d))
cat("group sizes: high =", nH, " low =", nL, "   xbar_H - xbar_L =", d, "\n")
cat("sum(a_i)     =", sum(a),     "  (must be 0 for unbiasedness)\n")
cat("sum(a_i x_i) =", sum(a * x), "  (must be 1 for unbiasedness)\n")
b1_alt <- sum(a * y)
cat("competing estimate =", b1_alt, "   least squares =", b1, "\n")
var_alt <- s2 * sum(a^2)
var_ols <- s2 * sum(cc^2)
cat("Var(competing) = s2*sum(a^2) =", var_alt, "  se =", sqrt(var_alt), "\n")
cat("Var(OLS)       = s2/Sxx      =", var_ols, "  se =", sqrt(var_ols), "\n")
cat("ratio Var(competing)/Var(OLS) =", var_alt / var_ols, "  (must be >= 1)\n")
# The excess is exactly sigma^2 * sum(d_i^2) with d_i = a_i - c_i, and the cross
# term vanishes. Both facts are checked here rather than asserted on the slide.
dd <- a - cc
cat("sum(c_i d_i) =", sum(cc * dd), "  (cross term, must be 0)\n")
cat("s2*sum(d^2)  =", s2 * sum(dd^2),
    "   Var(competing) - Var(OLS) =", var_alt - var_ols,
    "   difference =", abs(s2 * sum(dd^2) - (var_alt - var_ols)), "\n\n")

cat("=== (4) analysis of variance and F = t^2 ===\n")
SST <- sum((y - ybar)^2)
SSR <- SST - SSE
R2  <- SSR / SST
MSR <- SSR / 1
MSE <- SSE / (n - 2)
Fst <- MSR / MSE
tst <- b1 / se_b1
cat("SST =", SST, "  SSR =", SSR, "  SSE =", SSE,
    "   SST-(SSR+SSE) =", SST - (SSR + SSE), "\n")
cat("R2 =", R2, "   summary(lm) =", summary(fit)$r.squared, "\n")
cat("df: regression 1, residual", n - 2, ", total", n - 1, "\n")
cat("MSR =", MSR, "   MSE =", MSE, "   sigma hat =", sqrt(MSE), "\n")
cat("F = MSR/MSE =", Fst, "   summary(lm) F =", summary(fit)$fstatistic[1], "\n")
cat("p-value =", pf(Fst, 1, n - 2, lower.tail = FALSE), "\n")
cat("t = b1/se(b1) =", tst, "   t^2 =", tst^2,
    "   F - t^2 =", Fst - tst^2, "\n")
cat("critical values: F(0.95; 1,", n - 2, ") =", qf(0.95, 1, n - 2),
    "   t(0.975;", n - 2, ") =", qt(0.975, n - 2),
    "   squared =", qt(0.975, n - 2)^2, "\n")
cat("anova(lm):\n")
print(anova(fit))
