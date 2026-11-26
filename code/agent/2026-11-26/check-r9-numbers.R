# Date        : 2026-11-26
# Description : Recompute, from the raw ice cream data, the numbers that sit
#               on Chapter 4 slides touched by the 2026-11-26 revision round 9:
#               (3c) the residual sum of squares written as S(beta_hat) and
#                    as y'y - beta_hat' X'y on "최소제곱 해가 존재할 조건";
#               (3d) the partial F test of H0: beta_price = beta_income = 0 on
#                    "회귀계수 일부에 대한 검정";
#               (2b) R^2 / adjusted R^2 of the three nested models on
#                    "모형의 설명력: 세 모형 비교" (labels changed, values not).
#               No number on the slides is changed by this script; it only
#               checks that the existing values still match the data.
#               Data: CNU lecture note R examples, chapter 7 (ice.csv.csv, n = 30).
#               Run from the project root:
#                 Rscript code/agent/2026-11-26/check-r9-numbers.R
# File        : check-r9-numbers.R

ice <- read.csv(
  "references/cnu-regression-lecture-note/강의노트/R 예제/7장/ice.csv.csv",
  header = TRUE
)
n <- nrow(ice)                                   # 30 observations

# ---- (3c) S(beta_hat) two ways ------------------------------------------
# Design matrix with an intercept column: n x (p + 1) = 30 x 4
X <- cbind(1, ice$price, ice$income, ice$temp)
y <- ice$IC
b <- solve(t(X) %*% X, t(X) %*% y)               # normal equations X'X b = X'y
S_direct  <- sum((y - X %*% b)^2)                # S(b) = (y - Xb)'(y - Xb)
S_shortcut <- drop(t(y) %*% y - t(b) %*% t(X) %*% y)  # y'y - b'X'y
cat(sprintf("(3c) S(beta_hat) direct   = %.6f\n", S_direct))
cat(sprintf("(3c) y'y - b'X'y          = %.6f\n", S_shortcut))
cat(sprintf("(3c) difference           = %.3e\n", S_direct - S_shortcut))

# ---- (3d) partial F test, k = 2 coefficients set to zero -----------------
fm <- lm(IC ~ price + income + temp, data = ice) # full model, p = 3
rm <- lm(IC ~ temp, data = ice)                  # reduced model
sse_fm <- sum(resid(fm)^2)
sse_rm <- sum(resid(rm)^2)
k   <- 2
df2 <- n - 3 - 1                                 # n - p - 1 = 26
num <- (sse_rm - sse_fm) / k                     # SSE difference divided by k
den <- sse_fm / df2                              # error-variance estimate of FM
Fst <- num / den
cat(sprintf("(3d) SSE(RM) = %.6f, SSE(FM) = %.6f\n", sse_rm, sse_fm))
cat(sprintf("(3d) (SSE(RM)-SSE(FM))/k = %.6f\n", num))
cat(sprintf("(3d) SSE(FM)/(n-p-1)     = %.7f\n", den))
cat(sprintf("(3d) F = %.3f, p = %.4f\n", Fst, pf(Fst, k, df2, lower.tail = FALSE)))

# ---- (2b) R^2 and adjusted R^2 of the three nested models ----------------
for (f in list(IC ~ temp, IC ~ income + temp, IC ~ price + income + temp)) {
  s <- summary(lm(f, data = ice))
  cat(sprintf("(2b) %-28s R2 = %.3f  adjR2 = %.3f\n",
              deparse(f), s$r.squared, s$adj.r.squared))
}
