# Date        : 2026-08-28
# Description : Worked GLS example for chapter 6 (Weighted Regression) of the KINS
#               lecture. Lake Huron annual water level 1875-1972 (n = 98) is a
#               monitoring series whose OLS residuals carry very strong positive
#               autocorrelation, so it shows the point of GLS without the
#               ambiguity of a weakly correlated data set.
#               The script (1) fits the OLS trend, (2) measures the
#               autocorrelation with the Durbin-Watson test and the residual ACF,
#               (3) estimates rho three independent ways that must agree
#               (Cochrane-Orcutt iteration, ML, REML), (4) fits GLS and
#               cross-checks nlme::gls against a hand-coded matrix solve, and
#               (5) draws the two panels used on the slide.
#               Every number printed here is reported on the slides.
#               Data source: datasets::LakeHuron, shipped with base R. R's help
#               page cites Brockwell & Davis (1991) Time Series: Theory and
#               Methods, 2nd ed., p. 555, and Brockwell & Davis (1996)
#               Introduction to Time Series and Forecasting, sections 5.1 / 7.6.
# File        : gls-lakehuron-autocorrelation.R

library(nlme)

## ---------------------------------------------------------------------------
## 0. Paths and data
## ---------------------------------------------------------------------------
out_dir <- "g:/Projects/regression-lecture-note/output/agent/2026-08-28"
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

lh <- data.frame(year  = as.numeric(time(LakeHuron)),
                 level = as.numeric(LakeHuron))
n  <- nrow(lh)
cat("=== data ===\n")
cat("n =", n, " years", min(lh$year), "-", max(lh$year),
    " level range", round(range(lh$level), 2), "feet\n")
cat("years are consecutive:", all(diff(lh$year) == 1), "\n\n")

## ---------------------------------------------------------------------------
## 1. OLS trend
## ---------------------------------------------------------------------------
fit_ols <- lm(level ~ year, data = lh)
s_ols   <- summary(fit_ols)
cat("=== 1. OLS: level ~ year ===\n")
print(signif(s_ols$coefficients, 6))
cat("residual SE =", round(s_ols$sigma, 4), " df =", s_ols$df[2],
    " R^2 =", round(s_ols$r.squared, 4), "\n")
ci_ols <- confint(fit_ols)["year", ]
cat("OLS 95% CI for the slope:", round(ci_ols, 6), "\n\n")

## ---------------------------------------------------------------------------
## 2. How strong is the autocorrelation?
## ---------------------------------------------------------------------------
e  <- residuals(fit_ols)
r1 <- sum(e[-1] * e[-n]) / sum(e^2)
DW <- sum(diff(e)^2) / sum(e^2)
dwe <- lmtest::dwtest(fit_ols, alternative = "greater")
ac  <- acf(e, plot = FALSE, lag.max = 12)$acf[, , 1]
cat("=== 2. autocorrelation of the OLS residuals ===\n")
cat("lag-1 autocorrelation r1 =", round(r1, 6), "\n")
cat("Durbin-Watson  DW        =", round(DW, 6),
    "  exact p =", signif(dwe$p.value, 4), "\n")
cat("residual ACF, lags 1-6   :", round(ac[2:7], 4), "\n")
runs <- sum(diff(sign(e)) != 0) + 1
cat("runs of one sign         :", runs, "in", n, "residuals\n\n")

## ---------------------------------------------------------------------------
## 3. Estimate rho three ways. If they disagree the example is not safe to use,
##    so this block is the screening test as much as it is a calculation.
## ---------------------------------------------------------------------------
X <- model.matrix(fit_ols)
y <- lh$level
p <- ncol(X)

gls_by_hand <- function(rho) {
  V    <- rho^abs(outer(seq_len(n), seq_len(n), "-"))
  Vinv <- solve(V)
  XtVX <- t(X) %*% Vinv %*% X
  beta <- solve(XtVX, t(X) %*% Vinv %*% y)
  res  <- y - X %*% beta
  s2   <- as.numeric(t(res) %*% Vinv %*% res) / (n - p)
  list(beta = drop(beta), se = sqrt(diag(s2 * solve(XtVX))),
       vcov = s2 * solve(XtVX), s2 = s2, rho = rho)
}

## 3a. Cochrane-Orcutt: start from the residual r1 and iterate to a fixed point
rho_co <- r1
for (k in 1:200) {
  g      <- gls_by_hand(rho_co)
  res    <- y - X %*% g$beta
  rho_nw <- sum(res[-1] * res[-n]) / sum(res^2)
  if (abs(rho_nw - rho_co) < 1e-11) { rho_co <- rho_nw; break }
  rho_co <- rho_nw
}
## 3b/3c. nlme::gls estimates rho jointly with beta
fit_ml   <- gls(level ~ year, data = lh, correlation = corAR1(form = ~ year),
                method = "ML")
fit_reml <- gls(level ~ year, data = lh, correlation = corAR1(form = ~ year),
                method = "REML")
rho_ml   <- as.numeric(coef(fit_ml$modelStruct$corStruct,   unconstrained = FALSE))
rho_reml <- as.numeric(coef(fit_reml$modelStruct$corStruct, unconstrained = FALSE))
cat("=== 3. three estimates of rho ===\n")
cat("Cochrane-Orcutt :", round(rho_co, 6), " (", k, "iterations )\n")
cat("ML              :", round(rho_ml, 6), "\n")
cat("REML            :", round(rho_reml, 6), "\n")
cat("spread          :", round(max(rho_co, rho_ml, rho_reml) -
                               min(rho_co, rho_ml, rho_reml), 6), "\n\n")

## ---------------------------------------------------------------------------
## 4. GLS results, and a cross-check of nlme::gls against the matrix solve
## ---------------------------------------------------------------------------
g_reml <- gls_by_hand(rho_reml)
cat("=== 4. cross-check at rho =", round(rho_reml, 6), "===\n")
print(signif(rbind(hand = g_reml$beta, nlme = coef(fit_reml)), 6))
cat("max abs difference in beta =", max(abs(g_reml$beta - coef(fit_reml))), "\n")
cat("hand SE :", signif(g_reml$se, 6), "\n")
cat("nlme SE :", signif(sqrt(diag(vcov(fit_reml))), 6), "\n\n")

s_reml <- summary(fit_reml)$tTable
cat("=== 5. OLS vs GLS ===\n")
cmp <- data.frame(
  term   = c("(Intercept)", "year"),
  ols    = s_ols$coefficients[, 1],
  ols_se = s_ols$coefficients[, 2],
  ols_t  = s_ols$coefficients[, 3],
  ols_p  = s_ols$coefficients[, 4],
  gls    = s_reml[, 1],
  gls_se = s_reml[, 2],
  gls_t  = s_reml[, 3],
  gls_p  = s_reml[, 4],
  row.names = NULL)
print(cbind(cmp[1], signif(cmp[-1], 5)))
cat("\nSE ratio GLS/OLS:", round(cmp$gls_se / cmp$ols_se, 4), "\n")

## 95% confidence intervals for the slope. GLS uses n - p degrees of freedom,
## which is what summary.gls reports.
tq     <- qt(0.975, n - p)
ci_gls <- s_reml["year", 1] + c(-1, 1) * tq * s_reml["year", 2]
cat("slope 95% CI, OLS:", round(ci_ols, 6),
    " width", round(diff(ci_ols), 6), "\n")
cat("slope 95% CI, GLS:", round(ci_gls, 6),
    " width", round(diff(ci_gls), 6), "\n")
cat("CI width ratio   :", round(diff(ci_gls) / diff(ci_ols), 4), "\n\n")

## 6. Does the AR(1) term earn its place?
fit_ml0 <- gls(level ~ year, data = lh, method = "ML")
lrt     <- anova(fit_ml0, fit_ml)
cat("=== 6. likelihood ratio test for rho = 0 ===\n")
print(lrt)
cat("\n")

## 7. Autocorrelation left after the GLS transform
P <- diag(n); P[1, 1] <- sqrt(1 - rho_reml^2)
for (i in 2:n) { P[i, i] <- 1; P[i, i - 1] <- -rho_reml }
res_w <- as.numeric(P %*% (y - X %*% g_reml$beta))
cat("=== 7. after the GLS transform ===\n")
cat("check P'P = (1-rho^2) V^-1  max abs error =",
    max(abs(t(P) %*% P - (1 - rho_reml^2) *
              solve(rho_reml^abs(outer(1:n, 1:n, "-"))))), "\n")
cat("lag-1 autocorrelation of the transformed residuals =",
    round(sum(res_w[-1] * res_w[-n]) / sum(res_w^2), 6), "\n\n")

## ---------------------------------------------------------------------------
## 8. Figure: (a) the series with both fits and their 95% bands,
##            (b) the residual ACF against the fitted AR(1) curve
## ---------------------------------------------------------------------------
band <- function(vc, beta) {
  xs <- seq(min(lh$year), max(lh$year), length.out = 200)
  X0 <- cbind(1, xs)
  fit <- as.numeric(X0 %*% beta)
  se  <- sqrt(rowSums((X0 %*% vc) * X0))
  list(x = xs, fit = fit, lo = fit - tq * se, hi = fit + tq * se)
}
b_ols <- band(vcov(fit_ols), coef(fit_ols))
b_gls <- band(vcov(fit_reml), coef(fit_reml))

png(file.path(out_dir, "fig-m06-gls-lakehuron.png"),
    width = 2100, height = 840, res = 150)
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
abline(h = c(-1, 1) * 1.96 / sqrt(n), col = "#4C72B0", lty = 3, lwd = 1.6)
segments(0:L, 0, 0:L, ac[1:(L + 1)], lwd = 7, col = "#4C72B0")
lines(0:L, rho_reml^(0:L), col = "#C44E52", lwd = 2.6)
points(0:L, rho_reml^(0:L), pch = 16, col = "#C44E52", cex = 0.9)
legend("topright", bty = "n", cex = 0.98,
       legend = c(sprintf("Durbin-Watson = %.3f  (p = %.1e)", DW, dwe$p.value),
                  sprintf("AR(1) curve: rho^k with rho = %.3f", rho_reml),
                  "dotted: +/- 1.96/sqrt(n)"))
par(op)
dev.off()
cat("figure written:", file.path(out_dir, "fig-m06-gls-lakehuron.png"), "\n")
