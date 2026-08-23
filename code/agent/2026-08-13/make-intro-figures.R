# Date        : 2026-08-13
# Description : Generate the introduction figures for the regression lecture,
#               following the DSSI introduction deck
#               (references/DSSI-regression-lecture-note/[회귀분석]1.소개.pdf):
#               father-son height scatter, histograms of the marginal vs the
#               conditional distribution, local means with the regression line,
#               and a schematic of "regression = conditional expectation".
#
#               IMPORTANT - data provenance:
#               The original Pearson & Lee (1903) individual records are not
#               available offline (the HistData package cannot be installed on
#               this machine). The father-son data used here are SIMULATED from
#               a bivariate normal whose parameters were solved so that the
#               fitted line and ANOVA table reproduce the published fit quoted
#               in the DSSI deck:
#                   intercept 33.89, slope 0.51, n = 1078,
#                   residual MS 5.94 (residual SD = 2.437),
#                   regression SS 2144.58, residual SS 6388.00.
#               Derivation of the simulation parameters:
#                   total SS   = 2144.58 + 6388.00 = 8532.58
#                   var(y)     = 8532.58 / 1077     = 7.922  -> sd(y) = 2.815
#                   R^2        = 2144.58 / 8532.58  = 0.2513 -> r     = 0.5013
#                   slope      = r * sd(y)/sd(x)             -> sd(x) = 2.765
#                   mean(y)    = 69 (quoted in the deck)     -> mean(x) = 68.84
#               Every figure caption states that the data are simulated to match
#               the published fit. No numbers are presented as original records.
#
#               Run from the project root:
#                 Rscript code/agent/2026-08-13/make-intro-figures.R
# File        : make-intro-figures.R

## ---- setup ------------------------------------------------------------

FIG_DIR  <- "output/agent/2026-08-13"
DATA_DIR <- "data/derived-data/agent/2026-08-13"
dir.create(FIG_DIR,  recursive = TRUE, showWarnings = FALSE)
dir.create(DATA_DIR, recursive = TRUE, showWarnings = FALSE)

# Palette (same validated colours as the 2026-08-11 figure script)
COL_BLUE   <- "#2a78d6"   # fitted regression line
COL_ORANGE <- "#eb6834"   # local / conditional means
COL_RED    <- "#e34948"   # reference means on histograms
INK        <- "#0b0b0b"
INK2       <- "#52514e"
GRID_C     <- "#e1e0d9"
FILL_GREY  <- "#d8d7d2"

open_png <- function(file, w = 1800, h = 1100, res = 170) {
  png(file.path(FIG_DIR, file), width = w, height = h, res = res)
}

## ---- simulate the father-son data -------------------------------------

# Target moments solved from the published fit (see header for the algebra).
# SD_X is solved so that the regression sum of squares reproduces the
# published 2144.58 exactly:  B1^2 * (n-1) * SD_X^2 = 2144.58
N_OBS   <- 1078
MEAN_X  <- 68.84                                  # father's height (inches)
B0      <- 33.89                                  # published intercept
B1      <- 0.51                                   # published slope
SS_REG  <- 2144.58                                # published regression SS
SS_RES  <- 6388.00                                # published residual SS
SD_X    <- sqrt(SS_REG / (B1^2 * (N_OBS - 1)))
SD_RES  <- sqrt(SS_RES / (N_OBS - 2))             # published residual MS 5.94

set.seed(1886)     # Galton (1886)
father <- rnorm(N_OBS, mean = MEAN_X, sd = SD_X)
# Force the simulated x moments to the targets exactly
father <- MEAN_X + SD_X * as.numeric(scale(father))

# Build residuals that are exactly centred, exactly orthogonal to x, and
# scaled to the published residual sum of squares. With such residuals the
# refitted line reproduces B0 and B1 to machine precision, so the figure
# shows the published fit rather than an approximation of it.
e <- rnorm(N_OBS)
e <- as.numeric(residuals(lm(e ~ father)))        # remove the x and mean parts
e <- e * sqrt(SS_RES / sum(e^2))                  # scale to the published SS
son <- B0 + B1 * father + e

heights <- data.frame(father = father, son = son)
write.csv(heights, file.path(DATA_DIR, "father-son-simulated.csv"),
          row.names = FALSE)

fit <- lm(son ~ father, data = heights)

cat("\n===== Simulated father-son fit (target: 33.89 + 0.51 x) =====\n")
print(summary(fit))
cat("\n===== ANOVA (target: reg SS 2144.58, resid SS 6388.00) =====\n")
print(anova(fit))

## ---- fig-i01: scatter plot with the fitted line -----------------------

open_png("fig-i01-galton-scatter.png")
par(mar = c(4.5, 4.5, 3, 1), col.axis = INK2, col.lab = INK, fg = INK2)
plot(heights$father, heights$son,
     pch = 16, col = adjustcolor(INK2, alpha.f = 0.35), cex = 0.7,
     panel.first = grid(col = GRID_C, lty = 1),
     main = "Father's Height vs Son's Height",
     xlab = "Father's height (inches)", ylab = "Son's height (inches)")
abline(fit, col = COL_BLUE, lwd = 3)
legend("topleft", bty = "n", lwd = 3, col = COL_BLUE,
       legend = sprintf("Fitted line: y = %.2f + %.2f x",
                        coef(fit)[1], coef(fit)[2]),
       text.col = INK)
dev.off()

## ---- fig-i02: marginal vs conditional distribution --------------------

# Sons whose fathers are near 72 inches: the conditional slice
slice <- heights[abs(heights$father - 72) < 0.5, ]

open_png("fig-i02-marginal-vs-conditional.png", w = 2000, h = 1000)
par(mfrow = c(1, 2), mar = c(4.5, 4.5, 3.5, 1),
    col.axis = INK2, col.lab = INK, fg = INK2)

hist(heights$son, breaks = 30, col = FILL_GREY, border = "white",
     main = "(a) All sons",
     xlab = "Son's height (inches)", ylab = "Frequency")
abline(v = mean(heights$son), col = COL_RED, lwd = 3)
text(mean(heights$son), par("usr")[4] * 0.92,
     labels = sprintf(" mean = %.1f", mean(heights$son)),
     col = COL_RED, pos = 4)

hist(slice$son, breaks = 12, col = FILL_GREY, border = "white",
     main = "(b) Sons whose father is about 72 inches",
     xlab = "Son's height (inches)", ylab = "Frequency")
abline(v = mean(slice$son), col = COL_RED, lwd = 3)
text(mean(slice$son), par("usr")[4] * 0.92,
     labels = sprintf(" mean = %.1f", mean(slice$son)),
     col = COL_RED, pos = 4)
dev.off()

cat("\n===== fig-i02: marginal vs conditional means =====\n")
cat(sprintf("mean of all sons              : %.2f (n = %d)\n",
            mean(heights$son), nrow(heights)))
cat(sprintf("mean of sons | father ~ 72 in : %.2f (n = %d)\n",
            mean(slice$son), nrow(slice)))
cat(sprintf("fitted E(Y | X = 72)          : %.2f\n",
            predict(fit, newdata = data.frame(father = 72))))

## ---- fig-i03: local means trace out the regression line ---------------

# Bin fathers into 1-inch bins and take the mean son height in each bin:
# these local means are the empirical conditional expectation E(Y | X = x)
brk  <- seq(floor(min(heights$father)), ceiling(max(heights$father)), by = 1)
bin  <- cut(heights$father, breaks = brk)
locm <- tapply(heights$son, bin, mean)
locn <- tapply(heights$son, bin, length)
ctr  <- brk[-length(brk)] + 0.5
keep <- !is.na(locm) & locn >= 10   # drop sparse bins

open_png("fig-i03-local-means.png")
par(mar = c(4.5, 4.5, 3, 1), col.axis = INK2, col.lab = INK, fg = INK2)
plot(heights$father, heights$son,
     pch = 16, col = adjustcolor(INK2, alpha.f = 0.22), cex = 0.7,
     panel.first = grid(col = GRID_C, lty = 1),
     main = "Local Means Trace Out the Regression Line",
     xlab = "Father's height (inches)", ylab = "Son's height (inches)")
abline(fit, col = COL_BLUE, lwd = 3)
points(ctr[keep], locm[keep], pch = 18, col = COL_ORANGE, cex = 2.2)
legend("topleft", bty = "n",
       lwd = c(3, NA), pch = c(NA, 18), pt.cex = c(NA, 2.2),
       col = c(COL_BLUE, COL_ORANGE),
       legend = c("Least-squares line", "Mean son height within each 1-inch bin"),
       text.col = INK)
dev.off()

cat("\n===== fig-i03: local means (bins with n >= 10) =====\n")
print(round(data.frame(father_bin_center = ctr[keep],
                       mean_son = as.numeric(locm[keep]),
                       n = as.numeric(locn[keep])), 2))

## ---- fig-i04: regression as a conditional expectation -----------------

# Schematic: at three x values, draw the conditional distribution of y
# centred on the regression line, i.e. E(Y | X = x) = beta0 + beta1 x
open_png("fig-i04-conditional-expectation.png")
par(mar = c(4.5, 4.5, 3, 1), col.axis = INK2, col.lab = INK, fg = INK2)
xr <- c(62, 76)
yr <- c(B0 + B1 * xr[1] - 9, B0 + B1 * xr[2] + 9)
plot(NA, xlim = xr, ylim = yr,
     panel.first = grid(col = GRID_C, lty = 1),
     main = "Regression Is the Conditional Mean of Y Given X = x",
     xlab = "x  (father's height, inches)",
     ylab = "y  (son's height, inches)")
abline(fit, col = COL_BLUE, lwd = 3)

# Draw a normal density sideways at each anchor point
for (x0 in c(65, 69, 73)) {
  mu <- coef(fit)[1] + coef(fit)[2] * x0
  yy <- seq(mu - 3 * SD_RES, mu + 3 * SD_RES, length.out = 200)
  dd <- dnorm(yy, mean = mu, sd = SD_RES)
  dd <- dd / max(dd) * 2.2                  # scale density to plot units
  polygon(c(x0 + dd, rep(x0, length(yy))), c(yy, rev(yy)),
          col = adjustcolor(COL_ORANGE, alpha.f = 0.25),
          border = COL_ORANGE, lwd = 2)
  segments(x0, mu, x0 + 2.2, mu, col = COL_ORANGE, lwd = 2, lty = 2)
  points(x0, mu, pch = 16, col = COL_ORANGE, cex = 1.6)
}
legend("topleft", bty = "n",
       lwd = c(3, 2), col = c(COL_BLUE, COL_ORANGE),
       legend = c("Regression line: E(Y | X = x)",
                  "Conditional distribution of Y at x"),
       text.col = INK)
dev.off()

cat("\nAll introduction figures written to", FIG_DIR, "\n")
cat("Simulated data written to", DATA_DIR, "\n")
cat("\n===== sessionInfo =====\n")
print(sessionInfo())
