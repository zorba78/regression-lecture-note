# Date: 2026-11-26
# Purpose: Numerical checks behind the chapter 5 (Diagnosis & Variable Selection)
#          wording/link review. Verifies (1) why price has a large (X'X)^{-1}
#          diagonal in chapter 4 when its VIF is ~1, (2) the second step of
#          backward elimination from the reduced model, (3) the diagnostic
#          maxima quoted on the chapter 5 slides, (4) the identity
#          h_ii = 1/n + Mahalanobis-type distance of x_i from the predictor means,
#          (5) cor(e, yhat) = 0 under least squares with an intercept.
# File: code/agent/2026-11-26/check-ch05-links.R

# Read the ice cream data (n = 30) used throughout chapters 1-5
ice <- read.csv("references/cnu-regression-lecture-note/강의노트/R 예제/7장/ice.csv.csv")
n <- nrow(ice)

# Full model IC ~ price + income + temp
fit <- lm(IC ~ price + income + temp, data = ice)
X <- model.matrix(fit)

# (1) Diagonal of (X'X)^{-1} for price, decomposed as VIF_j / S_jj
xtx_inv <- solve(crossprod(X))
s_pp <- sum((ice$price - mean(ice$price))^2)               # S_jj for price
r2_price <- summary(lm(price ~ income + temp, data = ice))$r.squared
vif_price <- 1 / (1 - r2_price)
cat("(1) (X'X)^{-1}[price]      =", format(xtx_inv["price", "price"], digits = 7), "\n")
cat("    S_pp = sum((price-mean)^2) =", format(s_pp, digits = 7), "\n")
cat("    R^2_price, VIF_price   =", format(r2_price, digits = 4), format(vif_price, digits = 4), "\n")
cat("    VIF / S_pp             =", format(vif_price / s_pp, digits = 7), "\n")
cat("    1 / S_pp (no-overlap value) =", format(1 / s_pp, digits = 7), "\n")
cat("    price range            =", range(ice$price), " sd =", format(sd(ice$price), digits = 4), "\n")

# (2) Backward elimination: step 1 from the full model and step 2 from IC ~ income + temp
aic_star <- function(f) {          # AIC* = n ln(SSE/n) + 2(p+1), the constant-free scale
  m <- lm(f, data = ice)
  n * log(sum(resid(m)^2) / n) + 2 * length(coef(m))
}
cat("(2) AIC* full               =", round(aic_star(IC ~ price + income + temp), 2), "\n")
cat("    step 1 drop price/income/temp =",
    round(aic_star(IC ~ income + temp), 2), round(aic_star(IC ~ price + temp), 2),
    round(aic_star(IC ~ price + income), 2), "\n")
cat("    step 2 from income+temp: drop income -> temp only =", round(aic_star(IC ~ temp), 2),
    "; drop temp -> income only =", round(aic_star(IC ~ income), 2), "\n")
cat("    AIC (stats::AIC) M1, M2, M3 =", round(AIC(fit), 2),
    round(AIC(lm(IC ~ income + temp, data = ice)), 2), round(AIC(lm(IC ~ temp, data = ice)), 2), "\n")

# (3) Diagnostic maxima for the full model
h <- hatvalues(fit); r <- rstandard(fit); d <- cooks.distance(fit); t_ext <- rstudent(fit)
cat("(3) max h_ii =", round(max(h), 3), "obs", which.max(h),
    "; max |r_i| =", round(max(abs(r)), 2), "obs", which.max(abs(r)),
    "; max D_i =", round(max(d), 3), "obs", which.max(d), "\n")
cat("    max |t_i| =", round(max(abs(t_ext)), 2), "obs", which.max(abs(t_ext)),
    "; Bonferroni critical t_{0.05/(2n), n-p-2} =", round(qt(1 - 0.05 / (2 * n), n - 3 - 2), 2), "\n")

# (4) h_ii = 1/n + (x_i - xbar)' (Xc'Xc)^{-1} (x_i - xbar)
Xc <- scale(as.matrix(ice[, c("price", "income", "temp")]), center = TRUE, scale = FALSE)
maha <- rowSums((Xc %*% solve(crossprod(Xc))) * Xc)
cat("(4) max |h_ii - (1/n + dist_i)| =", format(max(abs(h - (1 / n + maha))), digits = 3), "\n")

# (5) Correlation of residuals and fitted values
cat("(5) cor(e, yhat) =", format(cor(resid(fit), fitted(fit)), digits = 3), "\n")
