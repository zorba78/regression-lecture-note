# Date        : 2026-08-25
# Description : Picture of the sum-of-squares decomposition behind R-squared.
#               (a) one observation is dissected on the scatter plot into the
#                   total deviation y - ybar, the part the line explains
#                   yhat - ybar, and the part it leaves over y - yhat;
#               (b) the same split for all n observations, as SST = SSR + SSE.
#               Data: CNU ch.7 ice cream example, IC on temp (n = 30), the same
#               fit the slide already quotes (r = 0.776, R-squared = 0.602).
#               Run from the project root:
#                 Rscript code/agent/2026-08-25/make-r2-decomposition-figure.R
# File        : make-r2-decomposition-figure.R

FIG_DIR <- "output/agent/2026-08-25"
dir.create(FIG_DIR, recursive = TRUE, showWarnings = FALSE)

COL_BLUE   <- "#2a78d6"   # the part explained by the line
COL_RED    <- "#e34948"   # the part left over
COL_DARK   <- "#14324a"   # the total deviation
INK        <- "#0b0b0b"
INK2       <- "#52514e"
GRID_C     <- "#e1e0d9"

ice <- read.csv(
     "references/cnu-regression-lecture-note/강의노트/R 예제/7장/ice.csv.csv",
     header = TRUE
)
fit <- lm(IC ~ temp, data = ice)
yb  <- mean(ice$IC)
yh  <- fitted(fit)

SST <- sum((ice$IC - yb)^2)
SSR <- sum((yh - yb)^2)
SSE <- sum((ice$IC - yh)^2)
cat(sprintf("SST %.5f = SSR %.5f + SSE %.5f  (check %.2e)\n",
            SST, SSR, SSE, SST - SSR - SSE))
cat(sprintf("R2 = SSR/SST = %.4f   r = %.4f   r^2 = %.4f\n",
            SSR / SST, cor(ice$temp, ice$IC), cor(ice$temp, ice$IC)^2))

# pick the observation whose three pieces are all clearly visible: the line must
# sit well above ybar there, and the point well above the line
score <- (yh - yb) * (ice$IC - yh)
i0    <- which.max(ifelse(yh > yb & ice$IC > yh, score, -Inf))
x0 <- ice$temp[i0]; y0 <- ice$IC[i0]; h0 <- yh[i0]
cat(sprintf("annotated point: temp %.0f, IC %.3f, fitted %.3f, ybar %.3f\n",
            x0, y0, h0, yb))

png(file.path(FIG_DIR, "fig-s01-r2-decomposition.png"),
    width = 2300, height = 950, res = 190)
layout(matrix(1:2, nrow = 1), widths = c(1.35, 1))

## ---- (a) one observation, dissected -----------------------------------
par(mar = c(4.4, 4.4, 3.2, 1.0), col.axis = INK2, col.lab = INK, fg = INK2)
# extra room on the right so the labels beside the segments are not clipped
plot(ice$temp, ice$IC, type = "n", xlim = c(min(ice$temp), max(ice$temp) + 11),
     panel.first = grid(col = GRID_C, lty = 1),
     main = "(a) One observation, split in two",
     xlab = "Mean temperature (deg F)", ylab = "Consumption (pints per capita)")
abline(h = yb, col = INK2, lwd = 2, lty = 2)
abline(fit, col = COL_BLUE, lwd = 3)
points(ice$temp, ice$IC, pch = 16, col = adjustcolor(INK2, alpha.f = 0.35),
       cex = 1.0)

d <- 1.6                                   # horizontal offset for the total bar
segments(x0 - d, yb, x0 - d, y0, col = COL_DARK, lwd = 5)   # y - ybar
segments(x0,     yb, x0,     h0, col = COL_BLUE, lwd = 5)   # yhat - ybar
segments(x0,     h0, x0,     y0, col = COL_RED,  lwd = 5)   # y - yhat
points(x0, y0, pch = 16, col = INK, cex = 1.5)

text(x0 - d - 0.8, (yb + y0) / 2, expression(y[i] - bar(y)),
     col = COL_DARK, adj = 1, cex = 0.95)
text(x0 + 0.8, (yb + h0) / 2, expression(hat(y)[i] - bar(y)),
     col = COL_BLUE, adj = 0, cex = 0.95)
text(x0 + 0.8, (h0 + y0) / 2, expression(y[i] - hat(y)[i]),
     col = COL_RED, adj = 0, cex = 0.95)
text(min(ice$temp), yb, expression(bar(y)), col = INK2, adj = c(0.4, -0.6),
     cex = 1.0)
legend("bottomright", bty = "n", cex = 0.85, text.col = INK,
       lwd = 4, col = c(COL_DARK, COL_BLUE, COL_RED),
       legend = c("total", "explained by the line", "left over"))

## ---- (b) the same split over all n observations ------------------------
par(mar = c(4.4, 1.0, 3.2, 1.0))
plot(0, 0, type = "n", xlim = c(0, 1), ylim = c(0, 1),
     axes = FALSE, xlab = "", ylab = "",
     main = "(b) Adding the squares over all n = 30")
p <- SSR / SST
rect(0.10, 0.52, 0.10 + 0.80 * p, 0.72, col = COL_BLUE, border = "white")
rect(0.10 + 0.80 * p, 0.52, 0.90, 0.72, col = COL_RED, border = "white")
rect(0.10, 0.52, 0.90, 0.72, col = NA, border = COL_DARK, lwd = 2)

text(0.10 + 0.40 * p, 0.62, sprintf("SSR  %.3f", SSR), col = "white",
     font = 2, cex = 0.95)
text(0.10 + 0.80 * p + 0.40 * (1 - p), 0.62, sprintf("SSE  %.3f", SSE),
     col = "white", font = 2, cex = 0.95)
text(0.50, 0.80, sprintf("SST  %.3f", SST), col = COL_DARK, font = 2, cex = 1.05)
arrows(0.10, 0.76, 0.90, 0.76, code = 3, length = 0.06, col = COL_DARK, lwd = 1.5)

text(0.50, 0.33, expression(R^2 == SSR / SST), col = INK, cex = 1.25)
text(0.50, 0.20, sprintf("= %.3f / %.3f = %.3f", SSR, SST, SSR / SST),
     col = INK, cex = 1.10)
text(0.50, 0.07, "the line explains 60.2% of the spread in y",
     col = INK2, font = 3, cex = 0.90)
dev.off()

cat("written:", file.path(FIG_DIR, "fig-s01-r2-decomposition.png"), "\n")
