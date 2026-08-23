# Date        : 2026-08-11
# Description : Generate all figures and summary tables used in the Quarto
#               revealjs draft of the regression special lecture.
#               Data sources:
#                 - CNU lecture-note R examples: ch3 toy data (Example 3.1),
#                   ch7 ice cream data (ice.csv.csv), ch8 physics data
#                   (Example 8.1, weighted regression).
#                 - anscombe (base R datasets, Anscombe 1973).
#                 - One simulated data set for the heteroscedasticity figure
#                   (saved to data/derived-data/agent/2026-08-11/).
#               Run from the project root:
#                 Rscript code/agent/2026-08-11/make-lecture-figures.R
# File        : make-lecture-figures.R

## ---- setup ------------------------------------------------------------

# Output directories (created if missing)
FIG_DIR  <- "output/agent/2026-08-11"
DATA_DIR <- "data/derived-data/agent/2026-08-11"
dir.create(FIG_DIR,  recursive = TRUE, showWarnings = FALSE)
dir.create(DATA_DIR, recursive = TRUE, showWarnings = FALSE)

# Validated categorical palette (dataviz skill reference palette, light mode)
COL_BLUE   <- "#2a78d6"   # series 1: main fitted line / OLS
COL_ORANGE <- "#eb6834"   # series 2: comparison line / WLS
COL_AQUA   <- "#1baf7a"   # series 3: third group
COL_RED    <- "#e34948"   # residual gap segments only
INK        <- "#0b0b0b"   # primary ink
INK2       <- "#52514e"   # secondary ink (points)
GRID_C     <- "#e1e0d9"   # hairline grid

# Helper to open a PNG device with slide-friendly size (16:10-ish)
open_png <- function(file, w = 1800, h = 1100, res = 170) {
  png(file.path(FIG_DIR, file), width = w, height = h, res = res)
}

## ---- data -------------------------------------------------------------

# Ice cream data (CNU lecture note, ch7): 30 four-week periods
# IC = per-capita consumption, price, income, temp, year (0/1/2)
ice <- read.csv(
  "references/cnu-regression-lecture-note/강의노트/R 예제/7장/ice.csv.csv",
  header = TRUE
)

# Toy data from CNU ch3 Example 3.1 (n = 10)
x3 <- c(1.9, 0.8, 1.1, 0.1, -0.1, 4.4, 4.6, 1.6, 5.5, 3.4)
y3 <- c(0.7, -1.0, -0.2, -1.2, -0.1, 3.4, 0.0, 0.8, 3.7, 2.0)

# Physics data from CNU ch8 Example 8.1 (weighted regression);
# w is proportional to the measurement variance of each y, so the
# lm() precision weight is 1/w (larger w -> less reliable point)
xp <- c(0.345, 0.287, 0.251, 0.255, 0.207, 0.186, 0.161, 0.132, 0.084, 0.060)
yp <- c(367, 311, 295, 268, 253, 239, 220, 213, 193, 192)
wp <- c(17, 9, 9, 7, 7, 6, 6, 6, 5, 5)

## ---- fig01: what is regression (ch1) ----------------------------------

fit_temp <- lm(IC ~ temp, data = ice)

open_png("fig01-what-is-regression.png")
par(mar = c(4.5, 4.5, 3, 1), col.axis = INK2, col.lab = INK, fg = INK2)
plot(ice$temp, ice$IC, pch = 16, col = INK2, cex = 1.2,
     panel.first = grid(col = GRID_C, lty = 1),
     main = "Ice Cream Consumption vs Temperature",
     xlab = "Mean temperature (deg F)",
     ylab = "Consumption (pints per capita)")
abline(fit_temp, col = COL_BLUE, lwd = 3)
dev.off()

cat("\n===== fig01 / ch1,ch3: lm(IC ~ temp) =====\n")
print(summary(fit_temp))

## ---- fig02: least-squares idea (ch3) ----------------------------------

fit3 <- lm(y3 ~ x3)

open_png("fig02-least-squares-idea.png")
par(mar = c(4.5, 4.5, 3, 1), col.axis = INK2, col.lab = INK, fg = INK2)
plot(x3, y3, pch = 16, col = INK2, cex = 1.3,
     panel.first = grid(col = GRID_C, lty = 1),
     main = "Least Squares: Minimize the Sum of Squared Vertical Gaps",
     xlab = "x", ylab = "y")
segments(x3, y3, x3, fitted(fit3), col = COL_RED, lwd = 2)
abline(fit3, col = COL_BLUE, lwd = 3)
legend("topleft", bty = "n", lwd = c(3, 2), col = c(COL_BLUE, COL_RED),
       legend = c("Least-squares line", "Residual (vertical gap)"),
       text.col = INK)
dev.off()

cat("\n===== fig02 / ch3: lm(y3 ~ x3), CNU Example 3.1 =====\n")
print(summary(fit3))

## ---- fig03: scatterplot matrix (ch4, ch7) -----------------------------

open_png("fig03-scatterplot-matrix.png", w = 1500, h = 1500)
pairs(ice[, c("IC", "price", "income", "temp")],
      pch = 16, col = INK2,
      main = "Scatterplot Matrix of the Ice Cream Data")
dev.off()

## ---- full and reduced models (ch4, ch6, ch7) --------------------------

r_full <- lm(IC ~ price + income + temp, data = ice)
r_red  <- lm(IC ~ income + temp, data = ice)

cat("\n===== ch4,ch7: full model lm(IC ~ price + income + temp) =====\n")
print(summary(r_full))
cat("\n===== ch7: reduced model lm(IC ~ income + temp) =====\n")
print(summary(r_red))

# Stepwise selection by AIC (base stats::step), as in CNU ch7 example
cat("\n===== ch6,ch7: step(r_full) trace =====\n")
r_step <- step(r_full)

# Manual VIF for the full model: VIF_j = 1 / (1 - R^2_j), where R^2_j is
# from regressing predictor j on the remaining predictors (base R only)
vif_manual <- function(model) {
  X <- model.matrix(model)[, -1, drop = FALSE]
  sapply(seq_len(ncol(X)), function(j) {
    r2 <- summary(lm(X[, j] ~ X[, -j]))$r.squared
    1 / (1 - r2)
  }) |> setNames(colnames(X))
}
cat("\n===== ch5: VIF of full model (manual, base R) =====\n")
print(vif_manual(r_full))

# Model comparison table: R2, adjusted R2, AIC for three candidates
cand <- list(
  "IC ~ price + income + temp" = r_full,
  "IC ~ income + temp"         = r_red,
  "IC ~ temp"                  = fit_temp
)
tab01 <- data.frame(
  model  = names(cand),
  R2     = sapply(cand, function(m) summary(m)$r.squared),
  adj_R2 = sapply(cand, function(m) summary(m)$adj.r.squared),
  AIC    = sapply(cand, AIC),
  row.names = NULL
)
write.csv(tab01, file.path(FIG_DIR, "tab01-model-selection.csv"),
          row.names = FALSE)
cat("\n===== tab01: model comparison =====\n")
print(tab01)

## ---- fig04: residual diagnostics (ch5, ch7) ---------------------------

open_png("fig04-residual-diagnostics.png", w = 1700, h = 1500)
par(mfrow = c(2, 2), mar = c(4, 4, 2.5, 1), oma = c(0, 0, 2, 0),
    col.axis = INK2, col.lab = INK, fg = INK2)
plot(r_red, pch = 16, col = INK2)
mtext("Residual Diagnostics for IC ~ income + temp", outer = TRUE,
      cex = 1.2, col = INK)
dev.off()

## ---- fig05: heteroscedasticity, simulated (ch8) -----------------------

# Simulated data whose error SD grows with x (funnel shape)
set.seed(2026)
n_sim <- 120
x_sim <- runif(n_sim, 0, 10)
y_sim <- 2 + 0.5 * x_sim + rnorm(n_sim, mean = 0, sd = 0.1 + 0.15 * x_sim)
sim <- data.frame(x = x_sim, y = y_sim)
write.csv(sim, file.path(DATA_DIR, "hetero-sim.csv"), row.names = FALSE)

fit_sim <- lm(y ~ x, data = sim)

open_png("fig05-heteroscedasticity.png", w = 2000, h = 1000)
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

## ---- fig06 + tab02: WLS on the physics data (ch8) ---------------------

ols_p <- lm(yp ~ xp)
wls_p <- lm(yp ~ xp, weights = 1 / wp)

# Point size proportional to the precision weight 1/w so that
# "reliable points get a bigger say" is visible on the plot
cex_w <- 0.8 + 2 * (1 / wp - min(1 / wp)) / diff(range(1 / wp))

open_png("fig06-wls-physics.png")
par(mar = c(4.5, 4.5, 3, 1), col.axis = INK2, col.lab = INK, fg = INK2)
plot(xp, yp, pch = 16, col = INK2, cex = cex_w,
     panel.first = grid(col = GRID_C, lty = 1),
     main = "OLS vs WLS on the Physics Data (point size = weight)",
     xlab = "x", ylab = "y")
abline(ols_p, col = COL_BLUE, lwd = 3)
abline(wls_p, col = COL_ORANGE, lwd = 3, lty = 2)
legend("topleft", bty = "n", lwd = 3, lty = c(1, 2),
       col = c(COL_BLUE, COL_ORANGE),
       legend = c("OLS (equal weights)", "WLS (weights = 1/w)"),
       text.col = INK)
dev.off()

tab02 <- data.frame(
  method    = c("OLS", "WLS"),
  intercept = c(coef(ols_p)[1], coef(wls_p)[1]),
  slope     = c(coef(ols_p)[2], coef(wls_p)[2]),
  se_intercept = c(summary(ols_p)$coefficients[1, 2],
                   summary(wls_p)$coefficients[1, 2]),
  se_slope     = c(summary(ols_p)$coefficients[2, 2],
                   summary(wls_p)$coefficients[2, 2])
)
write.csv(tab02, file.path(FIG_DIR, "tab02-wls-compare.csv"),
          row.names = FALSE)
cat("\n===== tab02: OLS vs WLS on physics data =====\n")
print(tab02)
cat("\n===== ch8: WLS model summary =====\n")
print(summary(wls_p))

## ---- fig07 + tab03: dummy variables (ch9) -----------------------------

fit_dummy <- lm(IC ~ temp + factor(year), data = ice)

cat("\n===== ch9: lm(IC ~ temp + factor(year)) =====\n")
print(summary(fit_dummy))

tab03 <- data.frame(
  term     = rownames(summary(fit_dummy)$coefficients),
  estimate = summary(fit_dummy)$coefficients[, 1],
  se       = summary(fit_dummy)$coefficients[, 2],
  t_value  = summary(fit_dummy)$coefficients[, 3],
  p_value  = summary(fit_dummy)$coefficients[, 4],
  row.names = NULL
)
write.csv(tab03, file.path(FIG_DIR, "tab03-dummy-coef.csv"),
          row.names = FALSE)

b <- coef(fit_dummy)   # (Intercept), temp, factor(year)1, factor(year)2
grp_col <- c(COL_BLUE, COL_ORANGE, COL_AQUA)

open_png("fig07-dummy-variable.png")
par(mar = c(4.5, 4.5, 3, 1), col.axis = INK2, col.lab = INK, fg = INK2)
plot(ice$temp, ice$IC, pch = 16, cex = 1.2,
     col = grp_col[ice$year + 1],
     panel.first = grid(col = GRID_C, lty = 1),
     main = "One Slope, Three Intercepts: IC ~ temp + factor(year)",
     xlab = "Mean temperature (deg F)",
     ylab = "Consumption (pints per capita)")
abline(a = b[1],               b = b[2], col = grp_col[1], lwd = 3)
abline(a = b[1] + b[3],        b = b[2], col = grp_col[2], lwd = 3)
abline(a = b[1] + b[4],        b = b[2], col = grp_col[3], lwd = 3)
legend("topleft", bty = "n", pch = 16, col = grp_col,
       legend = c("year = 0", "year = 1", "year = 2"), text.col = INK)
dev.off()

## ---- fig08: Anscombe's quartet (ch5 motivation) -----------------------

# anscombe: base R data set (Anscombe, 1973, The American Statistician)
open_png("fig08-anscombe.png", w = 1700, h = 1500)
par(mfrow = c(2, 2), mar = c(4, 4, 2.5, 1), oma = c(0, 0, 2, 0),
    col.axis = INK2, col.lab = INK, fg = INK2)
for (i in 1:4) {
  xi <- anscombe[[paste0("x", i)]]
  yi <- anscombe[[paste0("y", i)]]
  plot(xi, yi, pch = 16, col = INK2, cex = 1.2,
       panel.first = grid(col = GRID_C, lty = 1),
       xlim = c(3, 19), ylim = c(3, 13),
       main = paste0("Data set ", i),
       xlab = paste0("x", i), ylab = paste0("y", i))
  abline(lm(yi ~ xi), col = COL_BLUE, lwd = 2)
}
mtext("Anscombe's Quartet: Same Summary Numbers, Different Stories",
      outer = TRUE, cex = 1.2, col = INK)
dev.off()

cat("\n===== fig08: anscombe fitted coefficients (all four) =====\n")
for (i in 1:4) {
  print(round(coef(lm(anscombe[[paste0("y", i)]] ~
                        anscombe[[paste0("x", i)]])), 3))
}

cat("\nAll figures written to", FIG_DIR, "\n")
cat("Simulated data written to", DATA_DIR, "\n")
cat("\n===== sessionInfo =====\n")
print(sessionInfo())
