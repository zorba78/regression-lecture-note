# Date        : 2026-08-27
# Description : Verify every number for the expanded chapter 4 (Multiple Linear
#               Regression) slides. Follows the section order of the reference
#               chapter (CNU 제4장) so each block below maps to one part of the
#               deck:
#                 (1) least squares by matrix algebra, full-rank condition
#                 (2) maximum likelihood: same beta, biased sigma^2
#                 (3) t test and confidence interval for a single coefficient
#                 (4) goodness of fit: R2, adjusted R2, ANOVA F
#                 (5) subset F test (a block of coefficients equal to zero)
#                 (6) confidence interval for the mean response and prediction
#                     interval for a new observation
#                 (7) the "adjusted for the other variables" reading of a
#                     coefficient, shown as an added-variable regression
#               Data: ice cream consumption, n = 30, IC ~ price + income + temp.
# File        : verify-multiple-regression.R

options(digits = 10)

ice <- read.csv("../../../references/cnu-regression-lecture-note/강의노트/R 예제/7장/ice.csv.csv")
names(ice) <- tolower(names(ice))
y <- ice$ic
X <- model.matrix(~ price + income + temp, data = ice)
n <- nrow(X); p <- ncol(X) - 1
cat("n =", n, "  p =", p, "  p+1 =", p + 1, "\n\n")

cat("=== (1) least squares ===\n")
cat("rank(X) =", qr(X)$rank, " of ", ncol(X), " -> full rank?",
    qr(X)$rank == ncol(X), "\n")
XtX <- t(X) %*% X
XtXi <- solve(XtX)
beta <- XtXi %*% t(X) %*% y
print(drop(beta))
cat("max |beta - coef(lm)| =", max(abs(drop(beta) - coef(lm(y ~ X - 1)))), "\n")
H <- X %*% XtXi %*% t(X)
e <- y - X %*% beta
SSE <- drop(t(e) %*% e)
cat("SSE = e'e            =", SSE, "\n")
cat("SSE = y'(I - H)y     =", drop(t(y) %*% (diag(n) - H) %*% y), "\n")
cat("SSE = y'y - bhat'X'y =", drop(t(y) %*% y - t(beta) %*% t(X) %*% y), "\n")
cat("max |X'e| =", max(abs(t(X) %*% e)), "  (normal equations hold)\n\n")

cat("=== (2) maximum likelihood ===\n")
s2_ml <- SSE / n
s2_ls <- SSE / (n - p - 1)
cat("sigma2 ML  = SSE/n       =", s2_ml, "\n")
cat("sigma2 LS  = SSE/(n-p-1) =", s2_ls, "  sigma =", sqrt(s2_ls), "\n")
cat("ratio ML/LS = (n-p-1)/n  =", s2_ml / s2_ls, " = ", (n - p - 1) / n, "\n")
# logLik of the fitted model, both by formula and by R, to show they agree.
ll <- -n / 2 * log(2 * pi) - n / 2 * log(s2_ml) - SSE / (2 * s2_ml)
cat("log-likelihood formula =", ll, "   logLik(lm) =",
    as.numeric(logLik(lm(ic ~ price + income + temp, data = ice))), "\n\n")

cat("=== (3) t test and CI for one coefficient ===\n")
fit <- lm(ic ~ price + income + temp, data = ice)
cjj <- diag(XtXi)
se <- sqrt(s2_ls * cjj)
tval <- drop(beta) / se
pval <- 2 * pt(abs(tval), df = n - p - 1, lower.tail = FALSE)
tcrit <- qt(0.975, df = n - p - 1)
tab <- data.frame(estimate = drop(beta), c_jj = cjj, se = se, t = tval, p = pval,
                  lower = drop(beta) - tcrit * se, upper = drop(beta) + tcrit * se)
print(round(tab, 6))
cat("t(0.975, df =", n - p - 1, ") =", tcrit, "\n")
cat("max |se - summary(lm) se| =",
    max(abs(se - summary(fit)$coefficients[, 2])), "\n\n")

cat("=== (4) goodness of fit ===\n")
SST <- sum((y - mean(y))^2)
SSR <- SST - SSE
R2 <- SSR / SST
adjR2 <- 1 - (SSE / (n - p - 1)) / (SST / (n - 1))
cat("SST =", SST, "  SSR =", SSR, "  SSE =", SSE, "\n")
cat("SST = SSR + SSE ?  difference =", SST - (SSR + SSE), "\n")
cat("R2      =", R2, "   summary(lm) =", summary(fit)$r.squared, "\n")
cat("adj R2  =", adjR2, "   summary(lm) =", summary(fit)$adj.r.squared, "\n")
Fstat <- (SSR / p) / (SSE / (n - p - 1))
cat("F = (SSR/p)/(SSE/(n-p-1)) =", Fstat, "  df =", p, ",", n - p - 1, "\n")
cat("p-value =", pf(Fstat, p, n - p - 1, lower.tail = FALSE), "\n")
cat("summary(lm) F =", summary(fit)$fstatistic[1], "\n\n")

cat("=== (5) subset F test  H0: beta_price = beta_income = 0 ===\n")
red <- lm(ic ~ temp, data = ice)
SSE_rm <- sum(residuals(red)^2)
k <- 2                                   # number of coefficients dropped
Fsub <- ((SSE_rm - SSE) / k) / (SSE / (n - p - 1))
cat("SSE(reduced, temp only) =", SSE_rm, "\n")
cat("SSE(full)               =", SSE, "\n")
cat("F = ((SSE_RM - SSE_FM)/k)/(SSE_FM/(n-p-1)) =", Fsub, "  df =", k, ",", n - p - 1, "\n")
cat("p-value =", pf(Fsub, k, n - p - 1, lower.tail = FALSE), "\n")
print(anova(red, fit))
cat("\n")

cat("=== (6) mean-response CI and prediction interval ===\n")
# A concrete new setting, inside the observed ranges of all three predictors.
x0 <- data.frame(price = 0.280, income = 85, temp = 65)
x0v <- c(1, 0.280, 85, 65)
fitted0 <- drop(t(x0v) %*% beta)
c0 <- drop(t(x0v) %*% XtXi %*% x0v)
half_ci <- tcrit * sqrt(s2_ls) * sqrt(c0)
half_pi <- tcrit * sqrt(s2_ls) * sqrt(1 + c0)
cat("x0 = (1, 0.280, 85, 65)\n")
cat("fitted value  =", fitted0, "\n")
cat("c0 = x0'(X'X)^{-1}x0 =", c0, "\n")
cat("CI half-width = t*sigma*sqrt(c0)     =", half_ci,
    "  ->  (", fitted0 - half_ci, ",", fitted0 + half_ci, ")\n")
cat("PI half-width = t*sigma*sqrt(1 + c0) =", half_pi,
    "  ->  (", fitted0 - half_pi, ",", fitted0 + half_pi, ")\n")
cat("PI / CI width ratio =", half_pi / half_ci, "\n")
cat("check against predict():\n")
print(predict(fit, x0, interval = "confidence"))
print(predict(fit, x0, interval = "prediction"))
cat("\n")

cat("=== (7) what 'adjusted for the others' means ===\n")
# The multiple-regression coefficient of temp equals the slope from regressing
# the part of y not explained by the other predictors on the part of temp not
# explained by them. This is the added-variable (partial regression) result.
ey <- residuals(lm(ic ~ price + income, data = ice))
ex <- residuals(lm(temp ~ price + income, data = ice))
av <- lm(ey ~ ex)
cat("slope of resid(IC ~ price+income) on resid(temp ~ price+income) =",
    coef(av)[2], "\n")
cat("beta_temp from the full model                                   =",
    coef(fit)["temp"], "\n")
cat("difference =", abs(coef(av)[2] - coef(fit)["temp"]), "\n")
cat("intercept of the added-variable fit =", coef(av)[1], " (should be 0)\n")
# For contrast: the simple regression of IC on temp alone.
cat("simple regression slope of IC on temp alone =",
    coef(lm(ic ~ temp, data = ice))[2], "\n")
