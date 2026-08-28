# Date        : 2026-08-28
# Description : Numerical check of the derivation added to the chapter 4 slide
#               "회귀계수의 표집분포: 추정량은 확률변수" (31/46). The slide now
#               derives, in three steps,
#                   bhat = (X'X)^-1 X'y
#                        = (X'X)^-1 X'(X*beta + eps)
#                        = beta + (X'X)^-1 X' eps
#               On real data beta and eps are unknown, so the identity cannot be
#               checked directly there. It is checked here on a SIMULATED
#               response built from the real ice cream design matrix with a beta
#               that we choose, so both sides of the last line are computable.
#               Two things are verified:
#                 (1) (X'X)^-1 X'X = I            - the cancellation in step 3
#                 (2) bhat - beta = (X'X)^-1 X'eps - the whole derivation
#               Design matrix source: references/cnu-regression-lecture-note
#               7장 ice.csv (n = 30, p = 3).
# File        : verify-beta-decomposition.R

options(digits = 10)
set.seed(20260828)

ice <- read.csv("../../../references/cnu-regression-lecture-note/강의노트/R 예제/7장/ice.csv.csv")
names(ice) <- tolower(names(ice))

X <- model.matrix(~ price + income + temp, data = ice)
n <- nrow(X); p <- ncol(X) - 1
XtXi <- solve(t(X) %*% X)

# A beta we choose, so the "true" value is known, and a normal error vector.
beta  <- c(0.30, -1.00, 0.003, 0.0035)
sigma <- 0.037
eps   <- rnorm(n, mean = 0, sd = sigma)
y     <- drop(X %*% beta + eps)

bhat <- drop(XtXi %*% t(X) %*% y)

# (1) the cancellation used in step 3
I_check <- XtXi %*% (t(X) %*% X)
cat("=== step 3: (X'X)^-1 X'X = I ===\n")
cat("max |(X'X)^-1 X'X - I| =", max(abs(I_check - diag(p + 1))), "\n\n")

# (2) the identity the slide derives
transmitted <- drop(XtXi %*% t(X) %*% eps)
cat("=== the derived identity: bhat = beta + (X'X)^-1 X' eps ===\n")
tab <- data.frame(beta = beta,
                  transmitted = transmitted,
                  sum = beta + transmitted,
                  bhat = bhat,
                  diff = bhat - (beta + transmitted))
print(tab)
cat("\nmax |bhat - (beta + (X'X)^-1 X' eps)| =",
    max(abs(bhat - (beta + transmitted))), "\n")

# The first term does not move when the data are regenerated; only the second
# does. Repeating the draw shows exactly that, which is the point of the slide.
cat("\n=== repeat the draw 5 times: only the transmitted part moves ===\n")
rep_tab <- t(sapply(1:5, function(k) {
  e <- rnorm(n, mean = 0, sd = sigma)
  b <- drop(XtXi %*% t(X) %*% drop(X %*% beta + e))
  c(bhat_temp = b["temp"], transmitted_temp = drop(XtXi %*% t(X) %*% e)["temp"])
}))
print(rep_tab)
cat("beta_temp (fixed in every row) =", beta[4], "\n")
cat("check: bhat_temp - transmitted_temp equals beta_temp in every row ->",
    all(abs(rep_tab[, 1] - rep_tab[, 2] - beta[4]) < 1e-12), "\n")
