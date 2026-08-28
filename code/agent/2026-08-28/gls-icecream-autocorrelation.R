# Date        : 2026-08-28
# Description : Worked GLS example for chapter 6 (Weighted Regression) of the KINS
#               lecture. The ice cream data used throughout the lecture is a time
#               series of 30 consecutive four-week periods, so its errors are a
#               natural place to show autocorrelation and generalized least squares.
#               The script (1) fits OLS, (2) measures the lag-1 autocorrelation of
#               the residuals with the Durbin-Watson test, (3) fits GLS under an
#               AR(1) error covariance three ways that must agree - a hand-coded
#               matrix solve, Cochrane-Orcutt iteration, and nlme::gls - and
#               (4) draws the two diagnostic panels used on the slide.
#               Every number printed here is reported on the slides; nothing is
#               rounded by hand.
#               Data source: references/cnu-regression-lecture-note/강의노트/
#                            R 예제/7장/ice.csv.csv (Hildreth & Lu 1960 ice cream
#                            consumption, 30 four-week periods).
# File        : gls-icecream-autocorrelation.R

library(nlme)

## ---------------------------------------------------------------------------
## 0. Paths and data
## ---------------------------------------------------------------------------
root    <- "g:/Projects/regression-lecture-note"
in_csv  <- file.path(root, "references/cnu-regression-lecture-note",
                     "강의노트/R 예제/7장/ice.csv.csv")
out_dir <- file.path(root, "output/agent/2026-08-28")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

ice <- read.csv(in_csv, header = TRUE, fileEncoding = "UTF-8")
n   <- nrow(ice)
cat("=== data ===\n")
cat("n =", n, " variables:", paste(names(ice), collapse = ", "), "\n")
cat("periods are consecutive:",
    all(diff(ice$period) == 1), "\n\n")

## ---------------------------------------------------------------------------
## 1. OLS fit - the model used in the earlier chapters
## ---------------------------------------------------------------------------
fit_ols <- lm(IC ~ price + income + temp, data = ice)
s_ols   <- summary(fit_ols)
cat("=== 1. OLS ===\n")
print(round(s_ols$coefficients, 6))
cat("residual SE =", round(s_ols$sigma, 6),
    " df =", s_ols$df[2], "\n\n")

## ---------------------------------------------------------------------------
## 2. Is there autocorrelation left in the residuals?
##    r1 : lag-1 sample autocorrelation of the residuals
##    DW : Durbin-Watson statistic. DW ~= 2(1 - r1), so DW well below 2 means
##         neighbouring residuals are positively correlated.
## ---------------------------------------------------------------------------
e  <- residuals(fit_ols)
r1 <- sum(e[-1] * e[-n]) / sum(e^2)
DW <- sum(diff(e)^2) / sum(e^2)
# slope of a through-the-origin regression of e_t on e_{t-1}; printed so the
# figure's fitted line can be labelled with the quantity it actually shows
b1 <- sum(e[-1] * e[-n]) / sum(e[-n]^2)
cat("=== 2. autocorrelation of the OLS residuals ===\n")
cat("lag-1 autocorrelation r1 =", round(r1, 6), "\n")
cat("slope of e_t on e_{t-1}  =", round(b1, 6), "\n")
cat("Durbin-Watson  DW        =", round(DW, 6), "\n")
# DW = 2(1 - r1) - (e_1^2 + e_n^2)/sum(e^2) exactly. The usual "DW ~= 2(1-r1)"
# drops that end correction, which is large here because e_30 is the known
# outlier of this data set (period 30, IC = 0.548).
endc <- (e[1]^2 + e[n]^2) / sum(e^2)
cat("  2*(1-r1)                 =", round(2 * (1 - r1), 6), "\n")
cat("  end correction           =", round(endc, 6),
    " -> 2(1-r1) - end =", round(2 * (1 - r1) - endc, 6), "\n")
cat("  e_1 =", round(e[1], 6), "  e_30 =", round(e[n], 6),
    "  residual SD =", round(sd(e), 6), "\n")
dwt <- car::durbinWatsonTest(fit_ols, simulate = TRUE, reps = 10000)
cat("car::durbinWatsonTest    : DW =", round(dwt$dw, 6),
    " bootstrap p =", round(dwt$p, 6), "\n")
dwe <- lmtest::dwtest(fit_ols, alternative = "greater")
cat("lmtest::dwtest (exact)   : DW =", round(as.numeric(dwe$statistic), 6),
    " p =", signif(dwe$p.value, 4), "\n")
# number of runs of the residual signs: a distribution-free look at the same thing
runs <- sum(diff(sign(e)) != 0) + 1
cat("sign changes in time order:", runs - 1,
    "runs =", runs, "out of", n, "residuals\n\n")

## ---------------------------------------------------------------------------
## 3. GLS under an AR(1) error covariance
##    Sigma = sigma^2 * V,  V[i,j] = rho^|i-j|
##    beta_GLS = (X' V^-1 X)^-1 X' V^-1 y
##    Var(beta_GLS) = s2_GLS * (X' V^-1 X)^-1
##    Three routes are computed; they must give the same numbers.
## ---------------------------------------------------------------------------
X <- model.matrix(fit_ols)
y <- ice$IC
p <- ncol(X)

gls_by_hand <- function(rho) {
  V    <- rho^abs(outer(seq_len(n), seq_len(n), "-"))
  Vinv <- solve(V)
  XtVX <- t(X) %*% Vinv %*% X
  beta <- solve(XtVX, t(X) %*% Vinv %*% y)
  res  <- y - X %*% beta
  s2   <- as.numeric(t(res) %*% Vinv %*% res) / (n - p)
  se   <- sqrt(diag(s2 * solve(XtVX)))
  list(beta = drop(beta), se = se, s2 = s2, rho = rho)
}

## 3a. plug in the residual estimate of rho (one-step feasible GLS)
g1 <- gls_by_hand(r1)

## 3b. Cochrane-Orcutt: re-estimate rho from the GLS residuals and iterate
rho_it <- r1
for (k in 1:50) {
  g      <- gls_by_hand(rho_it)
  res    <- y - X %*% g$beta
  rho_nw <- sum(res[-1] * res[-n]) / sum(res^2)
  if (abs(rho_nw - rho_it) < 1e-10) { rho_it <- rho_nw; break }
  rho_it <- rho_nw
}
g2 <- gls_by_hand(rho_it)
cat("=== 3. GLS with an AR(1) error covariance ===\n")
cat("3a. one-step  rho =", round(r1, 6), "\n")
cat("3b. iterated  rho =", round(rho_it, 6), " (", k, "iterations )\n")

## 3c. nlme::gls, which estimates rho by maximum likelihood
fit_gls <- gls(IC ~ price + income + temp, data = ice,
               correlation = corAR1(form = ~ period), method = "ML")
rho_ml  <- as.numeric(coef(fit_gls$modelStruct$corStruct, unconstrained = FALSE))
cat("3c. nlme::gls rho =", round(rho_ml, 6), "(maximum likelihood)\n\n")

## ---------------------------------------------------------------------------
## 4. Side-by-side table: OLS vs GLS
## ---------------------------------------------------------------------------
g3 <- gls_by_hand(rho_ml)   # hand solve at the ML rho, to check nlme
cat("=== 4. OLS vs GLS ===\n")
cmp <- data.frame(
  term      = rownames(s_ols$coefficients),
  ols_est   = s_ols$coefficients[, 1],
  ols_se    = s_ols$coefficients[, 2],
  ols_t     = s_ols$coefficients[, 3],
  gls_est   = g2$beta,
  gls_se    = g2$se,
  gls_t     = g2$beta / g2$se,
  row.names = NULL
)
print(cbind(cmp[1], round(cmp[-1], 6)))
cat("\nSE ratio GLS/OLS:", round(g2$se / s_ols$coefficients[, 2], 4), "\n")
cat("\ncross-check, hand solve at the ML rho vs nlme::gls coefficients\n")
print(round(rbind(hand = g3$beta, nlme = coef(fit_gls)), 6))
cat("max abs difference =",
    max(abs(g3$beta - coef(fit_gls))), "\n\n")

## two-sided p-values on n - p = 26 degrees of freedom
pv <- function(est, se) 2 * pt(-abs(est / se), df = n - p)
cat("p-values (df =", n - p, ")\n")
print(round(data.frame(term = cmp$term,
                       ols  = pv(cmp$ols_est, cmp$ols_se),
                       gls  = pv(cmp$gls_est, cmp$gls_se))[, -1], 6))
cat("terms:", paste(cmp$term, collapse = ", "), "\n\n")

## ---------------------------------------------------------------------------
## 5. Does the AR(1) term earn its place? Likelihood ratio against plain OLS
## ---------------------------------------------------------------------------
fit_ml0 <- gls(IC ~ price + income + temp, data = ice, method = "ML")
lrt     <- anova(fit_ml0, fit_gls)
cat("=== 5. likelihood ratio test for rho = 0 ===\n")
print(lrt)
cat("\n")

## ---------------------------------------------------------------------------
## 6. Residual autocorrelation after GLS: did the transformation clean it up?
##    The Prais-Winsten transform P y with P'P = V^-1 whitens the errors.
## ---------------------------------------------------------------------------
rho <- rho_it
P   <- diag(n)
P[1, 1] <- sqrt(1 - rho^2)
for (i in 2:n) { P[i, i] <- 1; P[i, i - 1] <- -rho }
res_g  <- as.numeric(y - X %*% g2$beta)
res_w  <- as.numeric(P %*% res_g)              # whitened GLS residuals
r1_w   <- sum(res_w[-1] * res_w[-n]) / sum(res_w^2)
DW_w   <- sum(diff(res_w)^2) / sum(res_w^2)
Vmat   <- rho^abs(outer(1:n, 1:n, "-"))
cat("=== 6. after the GLS transform ===\n")
# For AR(1), P'P = (1 - rho^2) V^-1, so P scaled by 1/sqrt(1 - rho^2) is the
# matrix that satisfies P'P = V^-1 exactly. Either scaling whitens the errors;
# only the constant differs, and constants do not change the GLS estimate.
cat("check P'P = (1-rho^2) V^-1  max abs error =",
    max(abs(t(P) %*% P - (1 - rho^2) * solve(Vmat))), "\n")
cat("first 4x4 corner of V at rho =", round(rho, 6), "\n")
print(round(Vmat[1:4, 1:4], 6))
cat("lag-1 autocorrelation of the transformed residuals =", round(r1_w, 6), "\n")
cat("Durbin-Watson of the transformed residuals         =", round(DW_w, 6), "\n\n")

## ---------------------------------------------------------------------------
## 7. Figure: (a) OLS residuals in time order, (b) lag-1 scatter
## ---------------------------------------------------------------------------
png(file.path(out_dir, "fig-m06-gls-autocorrelation.png"),
    width = 2100, height = 840, res = 150)
op <- par(mfrow = c(1, 2), mar = c(4.4, 4.6, 3.0, 1.2), cex.axis = 1.05,
          cex.lab = 1.15, cex.main = 1.25)

## (a) residuals against the period index. Drawn as spikes coloured by sign so
##     that runs of consecutive same-signed residuals are the visible feature.
plot(ice$period, e, type = "n", xlab = "Period (4-week)",
     ylab = "OLS residual", main = "(a) Residuals in time order",
     ylim = c(min(e) * 1.08, max(e) * 1.55))   # headroom for the legend only
segments(ice$period, 0, ice$period, e, lwd = 7,
         col = ifelse(e > 0, "#4C72B0", "#DD8452"))
abline(h = 0, col = "grey35", lwd = 1.4)
points(ice$period, e, pch = 21, bg = ifelse(e > 0, "#4C72B0", "#DD8452"),
       col = "white", cex = 1.2, lwd = 1.2)
legend("topleft", bty = "n", cex = 1.0,
       legend = c(sprintf("Durbin-Watson = %.3f  (p = %.4f)",
                          DW, dwe$p.value),
                  sprintf("%d runs of one sign in %d residuals", runs, n)))

## (b) e_t against e_{t-1} with the fitted slope rho
plot(e[-n], e[-1], pch = 21, bg = "#4C72B0", col = "white", cex = 1.6, lwd = 1.4,
     xlab = expression(e[t - 1]), ylab = expression(e[t]),
     main = "(b) Each residual against the previous one")
abline(h = 0, v = 0, col = "grey80")
abline(a = 0, b = b1, col = "#C44E52", lwd = 2.4)
legend("topleft", bty = "n", cex = 1.0,
       legend = c(sprintf("lag-1 autocorrelation = %.3f", r1),
                  sprintf("line: slope %.3f through the origin", b1)))
par(op)
dev.off()
cat("figure written:",
    file.path(out_dir, "fig-m06-gls-autocorrelation.png"), "\n")
