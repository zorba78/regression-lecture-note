# Date        : 2026-11-25
# Description : Verify the statements added to the chapter 4 slide
#               "'보정'의 의미: 두 단계" (renamed in the 2nd revision to
#               "회귀계수의 해석: '보정'의 두 단계") (Frisch-Waugh-Lovell), where the symbols
#               gamma-hat and delta-hat are now defined on the slide:
#                 gamma-hat = least squares coefficients of the auxiliary
#                             regression of y (IC) on price and income
#                 delta-hat = least squares coefficients of the auxiliary
#                             regression of x_temp on price and income
#               Checks:
#                 (1) gamma-hat and delta-hat differ from the full-model beta-hat
#                 (2) algebraic link gamma-hat = beta-hat[0,price,income]
#                     + beta-hat_temp * delta-hat (so they coincide only when
#                     beta-hat_temp = 0 or delta-hat = 0)
#                 (3) the FWL numbers already on the slide:
#                     sum(x~ y~) = 23.696, sum(x~^2) = 6844.6, slope 0.003462,
#                     and S_xx(temp) = 7820.7, ratio 87.5 %
#                 (4) residualizing y only (not temp) does NOT reproduce
#                     beta-hat_temp - used to judge the laundry analogy in the
#                     speaker notes
#                 (5) the income p-value printed in two tables of the deck
#                     (0.0090 vs 0.0089) - report only, slides not changed
#                 (6) added in the 2nd revision: compare the FWL numerator and
#                     denominator with those of the simple regression IC ~ temp
#                     (S_xy, S_xx). Supports the speaker-note statement that
#                     BOTH shrink and the denominator shrinks more, so the slope
#                     grows from 0.00311 to 0.00346 (ratio = num/den ratios)
#               Data: ice cream consumption, n = 30, IC ~ price + income + temp.
#               Run from this folder: Rscript verify-fwl-auxiliary-coefficients.R
# File        : verify-fwl-auxiliary-coefficients.R

options(digits = 10)

# Same relative data path as code/agent/2026-08-27/verify-multiple-regression.R
ice <- read.csv("../../../references/cnu-regression-lecture-note/강의노트/R 예제/7장/ice.csv.csv")
names(ice) <- tolower(names(ice))

# Full model: IC ~ price + income + temp
full <- lm(ic ~ price + income + temp, data = ice)
b <- coef(full)
cat("=== full model beta-hat ===\n"); print(b)

# (1) Auxiliary regressions on price and income only
aux_y <- lm(ic ~ price + income, data = ice)    # gamma-hat
aux_x <- lm(temp ~ price + income, data = ice)  # delta-hat
g <- coef(aux_y); d <- coef(aux_x)
cat("\n=== (1) gamma-hat (IC on price, income) ===\n"); print(g)
cat("=== (1) delta-hat (temp on price, income) ===\n"); print(d)
cat("gamma-hat vs full beta-hat[0,price,income]:\n")
print(rbind(gamma = g, beta_full = b[1:3]))

# (2) Exact identity: gamma = beta[1:3] + beta_temp * delta
cat("\n=== (2) max |gamma - (beta[1:3] + beta_temp * delta)| =",
    max(abs(g - (b[1:3] + b["temp"] * d))), "\n")

# (3) FWL numbers shown on the slide
y_t <- resid(aux_y); x_t <- resid(aux_x)
sxy <- sum(x_t * y_t); sxx_t <- sum(x_t^2)
cat("\n=== (3) FWL ===\n")
cat("sum(x~ y~) =", sxy, "  sum(x~^2) =", sxx_t, "  slope =", sxy / sxx_t, "\n")
cat("beta_temp (full) =", b["temp"], "  diff =", sxy / sxx_t - b["temp"], "\n")
Sxx <- sum((ice$temp - mean(ice$temp))^2)
cat("S_xx(temp) =", Sxx, "  ratio sum(x~^2)/S_xx =", sxx_t / Sxx, "\n")

# (4) Residualize y only, regress on raw temp (the laundry analogy's procedure)
slope_y_only <- coef(lm(y_t ~ ice$temp))[2]
cat("\n=== (4) slope of y~ on raw temp =", slope_y_only,
    " vs beta_temp =", b["temp"], "\n")

# (5) income p-value at full precision
cat("\n=== (5) income p-value =", summary(full)$coefficients["income", 4], "\n")

# (6) Simple regression IC ~ temp: slope = S_xy / S_xx.
#     FWL slope = sum(x~ y~) / sum(x~^2). Compare numerator with numerator and
#     denominator with denominator; the slope ratio equals their quotient.
Sxy <- sum((ice$temp - mean(ice$temp)) * (ice$ic - mean(ice$ic)))
b1_simple <- Sxy / Sxx
cat("\n=== (6) simple vs FWL ===\n")
cat("numerator   : S_xy =", Sxy, " -> sum(x~ y~) =", sxy,
    "  ratio =", sxy / Sxy, "\n")
cat("denominator : S_xx =", Sxx, " -> sum(x~^2) =", sxx_t,
    "  ratio =", sxx_t / Sxx, "\n")
cat("slope       : simple =", b1_simple, " (lm:", coef(lm(ic ~ temp, data = ice))[2], ")",
    " -> FWL =", sxy / sxx_t, "\n")
cat("slope ratio FWL/simple =", (sxy / sxx_t) / b1_simple,
    "  = (num ratio)/(den ratio) =", (sxy / Sxy) / (sxx_t / Sxx), "\n")
