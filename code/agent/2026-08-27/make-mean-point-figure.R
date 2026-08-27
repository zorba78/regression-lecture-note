# Date        : 2026-08-27
# Description : Figure for the "least squares: solution and properties" slide of
#               chapter 3. Shows the ice cream scatter with the fitted line and
#               marks the mean point (xbar, ybar), making visible the property
#               that the least-squares line ALWAYS passes through it - which is
#               what the intercept formula beta0 = ybar - beta1 * xbar says.
#               Guide lines drop from the mean point to both axes so the two
#               averages can be read off directly.
#
#               Every number printed at the end is the one quoted on the slide.
# File        : make-mean-point-figure.R

options(digits = 10)

ice <- read.csv("../../../references/cnu-regression-lecture-note/강의노트/R 예제/7장/ice.csv.csv")
names(ice) <- tolower(names(ice))
x <- ice$temp
y <- ice$ic
n <- length(x)

fit <- lm(y ~ x)
b0 <- coef(fit)[1]
b1 <- coef(fit)[2]
xbar <- mean(x)
ybar <- mean(y)

# The property being drawn: the fitted value AT xbar is exactly ybar.
yhat_at_xbar <- b0 + b1 * xbar

out <- "../../../output/agent/2026-08-27"
dir.create(out, showWarnings = FALSE, recursive = TRUE)
# Wide and short on purpose. Layout C caps a slide figure at 512px of height,
# so a 1.57:1 figure only reached 806px of the ~1150px content width. At 1.95:1
# the same height cap yields about 1000px, which is what fills the slide.
png(file.path(out, "fig-s02-mean-point.png"),
    width = 1950, height = 1000, res = 150)

# Explicit limits with padding: the axis labels for the two means are drawn
# inside the plotting region, so they need room that the default range does not
# leave (an earlier version put them at par("usr") and they were cut off).
xlim <- range(x) + c(-3, 2)
ylim <- range(y) + c(-0.022, 0.012)

par(mar = c(4.4, 5.0, 2.6, 1.2), family = "sans", cex.lab = 1.15, cex.axis = 1.05)
plot(x, y, type = "n", xlim = xlim, ylim = ylim,
     xlab = "Temperature (F)", ylab = "Ice cream consumption (pint)",
     main = "The least-squares line always passes through the mean point",
     cex.main = 1.25, font.main = 1, bty = "n", las = 1)

# Guide lines first so the fitted line and the mean point sit on top of them.
segments(xbar, ylim[1], xbar, ybar, lty = 2, col = "#b0b0b0")
segments(xlim[1], ybar, xbar, ybar, lty = 2, col = "#b0b0b0")

points(x, y, pch = 19, col = "#8a8a8a", cex = 1.15)
abline(fit, col = "#3b9ab2", lwd = 3)
points(xbar, ybar, pch = 21, bg = "#e8552d", col = "#ffffff", cex = 2.6, lwd = 2)

# Both mean labels sit just inside the axes, clear of the data.
text(xbar + 0.8, ylim[1] + 0.004, adj = c(0, 0), col = "#52514e", cex = 1.12,
     labels = sprintf("mean of x = %.1f", xbar))
text(xlim[1] + 0.6, ybar + 0.006, adj = c(0, 0), col = "#52514e", cex = 1.12,
     labels = sprintf("mean of y = %.3f", ybar))
text(xbar + 1.6, ybar - 0.011, adj = c(0, 1), col = "#e8552d", cex = 1.5,
     labels = expression(paste("(", bar(x), ", ", bar(y), ")")))

legend("topleft", bty = "n", cex = 1.18, inset = c(0, -0.02),
       legend = c(sprintf("fitted line: y = %.3f + %.5f x", b0, b1),
                  "mean point"),
       lty = c(1, NA), lwd = c(3, NA), pch = c(NA, 21),
       col = c("#3b9ab2", "#ffffff"), pt.bg = c(NA, "#e8552d"), pt.cex = c(NA, 1.9))

dev.off()

cat("n      =", n, "\n")
cat("beta0  =", b0, "\n")
cat("beta1  =", b1, "\n")
cat("xbar   =", xbar, "\n")
cat("ybar   =", ybar, "\n")
cat("beta0 + beta1 * xbar =", yhat_at_xbar, "  (equals ybar?)\n")
cat("difference from ybar =", yhat_at_xbar - ybar, "\n")
# The same property stated through the residuals: they sum to zero.
cat("sum of residuals     =", sum(residuals(fit)), "\n")
cat("Sxy =", sum((x - xbar) * (y - ybar)), "\n")
cat("Sxx =", sum((x - xbar)^2), "\n")
# The two identities the derivation slide uses to turn the raw sums that come
# out of the normal equations into the deviation sums of squares.
cat("sum(x*y) - n*xbar*ybar =", sum(x * y) - n * xbar * ybar, "  should equal Sxy\n")
cat("sum(x^2) - n*xbar^2    =", sum(x^2) - n * xbar^2,        "  should equal Sxx\n")
cat("Sxy / Sxx =", sum((x - xbar) * (y - ybar)) / sum((x - xbar)^2), "\n")
cat("ybar - beta1 * xbar =", ybar - b1 * xbar, "\n")
cat("file written:", file.path(out, "fig-s02-mean-point.png"), "\n")
