# Date        : 2026-08-27
# Description : Figure for the chapter 4 slide on what "adjusted for the other
#               variables" means. Two panels on the ice cream data:
#                 left  - IC against temp on its own. The slope is the SIMPLE
#                         regression coefficient, 0.003107.
#                 right - the part of IC that price and income do not explain,
#                         against the part of temp that they do not explain.
#                         The slope of THIS line is 0.003462, which is exactly
#                         the temp coefficient of the full multiple regression.
#               So a multiple-regression coefficient is the simple slope
#               computed after the other predictors have been swept out of both
#               variables - that is the whole content of the word "adjusted".
#               This is the added-variable (partial regression) construction.
# File        : make-added-variable-figure.R

options(digits = 10)

ice <- read.csv("../../../references/cnu-regression-lecture-note/강의노트/R 예제/7장/ice.csv.csv")
names(ice) <- tolower(names(ice))

simple <- lm(ic ~ temp, data = ice)
full   <- lm(ic ~ price + income + temp, data = ice)

# Sweep price and income out of BOTH the response and the predictor of interest.
ey <- residuals(lm(ic   ~ price + income, data = ice))
ex <- residuals(lm(temp ~ price + income, data = ice))
av <- lm(ey ~ ex)

b_simple <- coef(simple)["temp"]
b_full   <- coef(full)["temp"]
b_av     <- coef(av)[2]

out <- "../../../output/agent/2026-08-27"
dir.create(out, showWarnings = FALSE, recursive = TRUE)
png(file.path(out, "fig-m02-added-variable.png"),
    width = 2100, height = 980, res = 150)

par(mfrow = c(1, 2), mar = c(4.6, 5.2, 3.2, 1.4), family = "sans",
    cex.lab = 1.15, cex.axis = 1.05)

plot(ice$temp, ice$ic, pch = 19, col = "#8a8a8a", cex = 1.15, las = 1, bty = "n",
     xlab = "Temperature (F)", ylab = "Ice cream consumption (pint)",
     main = "Temperature on its own", cex.main = 1.2, font.main = 1)
abline(simple, col = "#3b9ab2", lwd = 3)
legend("topleft", bty = "n", cex = 1.1, lty = 1, lwd = 3, col = "#3b9ab2",
       legend = sprintf("slope = %.5f", b_simple))

plot(ex, ey, pch = 19, col = "#8a8a8a", cex = 1.15, las = 1, bty = "n",
     xlab = "Temperature, with price and income removed",
     ylab = "Consumption, with price and income removed",
     main = "Temperature after adjusting for price and income",
     cex.main = 1.2, font.main = 1)
abline(h = 0, col = "#d8d8d8"); abline(v = 0, col = "#d8d8d8")
abline(av, col = "#e8552d", lwd = 3)
legend("topleft", bty = "n", cex = 1.1, lty = 1, lwd = 3, col = "#e8552d",
       legend = sprintf("slope = %.5f", b_av))

dev.off()

cat("simple regression slope of IC on temp      =", b_simple, "\n")
cat("added-variable slope (residual on residual) =", b_av, "\n")
cat("temp coefficient of the full model          =", b_full, "\n")
cat("difference (added-variable vs full model)   =", abs(b_av - b_full), "\n")
cat("added-variable intercept =", coef(av)[1], " (zero by construction)\n")
cat("mean of ex =", mean(ex), "   mean of ey =", mean(ey), "\n")
cat("file written:", file.path(out, "fig-m02-added-variable.png"), "\n")
