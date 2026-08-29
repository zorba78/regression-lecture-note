# Date        : 2026-08-29
# Description : Box-Cox worked example for chapter 5 (Diagnosis and correction)
#               of the KINS lecture. This reproduces 예제 5.2 of the CNU lecture
#               note "제5장. 회귀진단 및 보정": the Galapagos species data is
#               fitted, the residuals fail both the constant-variance and the
#               normality check, Box-Cox picks a power for the response, and the
#               refit is checked again.
#               The script prints the lambda estimate with its confidence
#               interval and the before/after diagnostics, so every number that
#               reaches the slide is derived here.
#               Data source: faraway::gala (Johnson & Raven 1973), taken from the
#               CRAN source tarball of the faraway package; the CNU note uses the
#               same data set through library(faraway).
#               Writes output/agent/2026-08-29/fig-m05-boxcox-gala.png
# File        : boxcox-gala-transformation.R

suppressMessages({library(MASS); library(lmtest)})

out_dir <- "g:/Projects/regression-lecture-note/output/agent/2026-08-29"
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

gala_rda <- file.path("C:/Users/user/AppData/Local/Temp/claude",
                      "g--Projects-regression-lecture-note",
                      "193236f0-e008-4bc6-b4a3-4409708d888c/scratchpad",
                      "alsm/faraway/data/gala.rda")
load(gala_rda)

n <- nrow(gala)
cat("=== data: faraway::gala ===\n")
cat("n =", n, " variables:", paste(names(gala), collapse = ", "), "\n")
cat("Species range:", range(gala$Species), " mean:", round(mean(gala$Species), 1),
    " sd:", round(sd(gala$Species), 1), "\n\n")

form <- Species ~ Area + Elevation + Nearest + Scruz + Adjacent

## ---------------------------------------------------------------------------
## 1. Fit on the raw response and check the assumptions
## ---------------------------------------------------------------------------
fit0 <- lm(form, data = gala)
s0   <- summary(fit0)
cat("=== 1. raw response ===\n")
cat("R^2 =", round(s0$r.squared, 4),
    " adj R^2 =", round(s0$adj.r.squared, 4),
    " residual SE =", round(s0$sigma, 3), "\n")
sw0 <- shapiro.test(residuals(fit0))
bp0 <- bptest(fit0)
cat("Shapiro-Wilk on residuals : W =", round(sw0$statistic, 4),
    " p =", signif(sw0$p.value, 4), "\n")
cat("Breusch-Pagan             : LM =", round(bp0$statistic, 4),
    " p =", signif(bp0$p.value, 4), "\n")
cat("residual spread, low vs high fitted half: ")
h0 <- fitted(fit0) > median(fitted(fit0))
cat(round(sd(residuals(fit0)[!h0]), 2), "vs",
    round(sd(residuals(fit0)[h0]), 2), "\n\n")

## ---------------------------------------------------------------------------
## 2. Box-Cox: profile the likelihood over lambda
##    y^(lambda) = (y^lambda - 1)/lambda for lambda != 0, log y for lambda = 0
## ---------------------------------------------------------------------------
bc <- boxcox(fit0, lambda = seq(-0.25, 1.0, by = 0.005), plotit = FALSE)
lam_hat <- bc$x[which.max(bc$y)]
## the usual 95% interval: all lambda whose profile log-likelihood is within
## qchisq(0.95, 1)/2 of the maximum
cut <- max(bc$y) - qchisq(0.95, 1) / 2
inside <- range(bc$x[bc$y > cut])
cat("=== 2. Box-Cox ===\n")
cat("lambda-hat =", round(lam_hat, 3), "\n")
cat("95% CI     = [", round(inside[1], 3), ",", round(inside[2], 3), "]\n")
cat("lambda = 0.5 (square root) inside the interval:",
    inside[1] <= 0.5 && 0.5 <= inside[2], "\n")
cat("lambda = 1   (no transform) inside the interval:",
    inside[1] <= 1 && 1 <= inside[2], "\n")
cat("lambda = 0   (log)          inside the interval:",
    inside[1] <= 0 && 0 <= inside[2], "\n\n")

## ---------------------------------------------------------------------------
## 3. Refit on the square root, the round number inside the interval
## ---------------------------------------------------------------------------
fit1 <- lm(sqrt(Species) ~ Area + Elevation + Nearest + Scruz + Adjacent,
           data = gala)
s1   <- summary(fit1)
sw1  <- shapiro.test(residuals(fit1))
bp1  <- bptest(fit1)
cat("=== 3. square-root response ===\n")
cat("R^2 =", round(s1$r.squared, 4),
    " adj R^2 =", round(s1$adj.r.squared, 4),
    " residual SE =", round(s1$sigma, 3), "\n")
cat("Shapiro-Wilk on residuals : W =", round(sw1$statistic, 4),
    " p =", signif(sw1$p.value, 4), "\n")
cat("Breusch-Pagan             : LM =", round(bp1$statistic, 4),
    " p =", signif(bp1$p.value, 4), "\n")
h1 <- fitted(fit1) > median(fitted(fit1))
cat("residual spread, low vs high fitted half: ")
cat(round(sd(residuals(fit1)[!h1]), 2), "vs",
    round(sd(residuals(fit1)[h1]), 2), "\n\n")

cat("=== 4. slide table ===\n")
tab <- data.frame(
  quantity = c("R^2", "adj R^2", "Shapiro-Wilk p", "Breusch-Pagan p",
               "SD ratio, high/low half"),
  raw = c(round(s0$r.squared, 3), round(s0$adj.r.squared, 3),
          signif(sw0$p.value, 3), signif(bp0$p.value, 3),
          round(sd(residuals(fit0)[h0]) / sd(residuals(fit0)[!h0]), 2)),
  sqrt_y = c(round(s1$r.squared, 3), round(s1$adj.r.squared, 3),
             signif(sw1$p.value, 3), signif(bp1$p.value, 3),
             round(sd(residuals(fit1)[h1]) / sd(residuals(fit1)[!h1]), 2)))
print(tab)

## ---------------------------------------------------------------------------
## 5. Figure: residuals before, the lambda profile, residuals after
## ---------------------------------------------------------------------------
png(file.path(out_dir, "fig-m05-boxcox-gala.png"),
    width = 1900, height = 760, res = 150)
op <- par(mfrow = c(1, 3), mar = c(4.6, 4.8, 3.6, 1.0), cex.axis = 1.3,
          cex.lab = 1.55, cex.main = 1.6, mgp = c(2.9, 0.8, 0))

plot(fitted(fit0), residuals(fit0), pch = 21, bg = "#4C72B0", col = "white",
     cex = 1.5, lwd = 1.2, xlab = "Fitted value", ylab = "Residual",
     main = "(a) Before: y = Species")
abline(h = 0, col = "grey40", lwd = 1.8)

plot(bc$x, bc$y, type = "l", lwd = 3, col = "#4C72B0",
     xlab = expression(lambda), ylab = "Profile log-likelihood",
     main = expression(paste("(b) Box-Cox profile for ", lambda)))
abline(h = cut, col = "#C44E52", lwd = 2, lty = 2)
abline(v = inside, col = "#C44E52", lwd = 2, lty = 3)
abline(v = 0.5, col = "grey35", lwd = 2)
# label the square root where it does not collide with the legend
text(0.5, max(bc$y) - 0.06 * diff(range(bc$y)), "lambda = 0.5 ",
     pos = 2, col = "grey25", cex = 1.45)
legend("bottomleft", bty = "n", cex = 1.4,
       legend = c(sprintf("lambda-hat = %.3f", lam_hat),
                  sprintf("95%% CI [%.3f, %.3f]", inside[1], inside[2])))

plot(fitted(fit1), residuals(fit1), pch = 21, bg = "#55A868", col = "white",
     cex = 1.5, lwd = 1.2, xlab = "Fitted value", ylab = "Residual",
     main = "(c) After: y = sqrt(Species)")
abline(h = 0, col = "grey40", lwd = 1.8)
par(op)
dev.off()

cat("\nfigure written:", file.path(out_dir, "fig-m05-boxcox-gala.png"), "\n")
