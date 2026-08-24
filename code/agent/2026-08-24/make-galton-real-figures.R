# Date        : 2026-08-24
# Description : Regenerate the four Introduction figures from GALTON'S OWN
#               family records instead of the simulated data used until now.
#
#               Data provenance:
#                 data/derived-data/galton-stata11.tab, supplied by the user.
#                 898 children of 197 families, with the father's and mother's
#                 height, the child's sex and height, and the number of kids.
#                 The lecture's narrative is father -> son, so the figures use
#                 the 465 sons. This is Galton's family data, NOT the 1078
#                 father-son pairs of Pearson & Lee (1903); the slides state
#                 the sample size that this file actually contains.
#
#               Change requested for fig-i03: the 1-inch bins used to compute
#               the local means are now drawn as alternating shaded bands, so
#               the audience can see exactly which observations are averaged
#               into each local mean.
#
#               Style (palette, png helper, par settings) follows
#               code/agent/2026-08-13/make-intro-figures.R so the four figures
#               stay visually consistent with the rest of the deck.
#
#               Run from the project root:
#                 Rscript code/agent/2026-08-24/make-galton-real-figures.R
# File        : make-galton-real-figures.R

## ---- setup ------------------------------------------------------------

FIG_DIR <- "output/agent/2026-08-24"
dir.create(FIG_DIR, recursive = TRUE, showWarnings = FALSE)

COL_BLUE   <- "#2a78d6"   # fitted regression line
COL_ORANGE <- "#eb6834"   # local / conditional means
COL_RED    <- "#e34948"   # reference means on histograms
INK        <- "#0b0b0b"
INK2       <- "#52514e"
GRID_C     <- "#e1e0d9"
FILL_GREY  <- "#d8d7d2"
BAND_A     <- "#dce9f7"   # alternating bin bands on fig-i03 (both visible)
BAND_B     <- "#f0f5fb"
BAND_DROP  <- "#f2f1ee"   # bins too sparse to give a usable local mean

open_png <- function(file, w = 1800, h = 1100, res = 170) {
  png(file.path(FIG_DIR, file), width = w, height = h, res = res)
}

## ---- read Galton's records --------------------------------------------

g <- read.delim("data/derived-data/galton-stata11.tab", stringsAsFactors = FALSE)
son <- subset(g, gender == "M", select = c(father, height))
names(son) <- c("father", "son")

fit <- lm(son ~ father, data = son)
B0  <- coef(fit)[1]
B1  <- coef(fit)[2]

cat("===== Galton family data: father -> son =====\n")
cat(sprintf("children in file : %d   families : %d   sons used : %d\n",
            nrow(g), length(unique(g$family)), nrow(son)))
print(summary(fit))
cat("\n===== ANOVA =====\n"); print(anova(fit))
cat(sprintf("\ncorrelation r = %.4f   mean father = %.2f   mean son = %.2f\n",
            cor(son$father, son$son), mean(son$father), mean(son$son)))

## ---- fig-i01: scatter plot with the fitted line -----------------------

open_png("fig-i01-galton-scatter.png")
par(mar = c(4.5, 4.5, 3, 1), col.axis = INK2, col.lab = INK, fg = INK2)
plot(son$father, son$son,
     pch = 16, col = adjustcolor(INK2, alpha.f = 0.35), cex = 0.8,
     panel.first = grid(col = GRID_C, lty = 1),
     main = "Father's Height vs Son's Height (Galton's family records)",
     xlab = "Father's height (inches)", ylab = "Son's height (inches)")
abline(fit, col = COL_BLUE, lwd = 3)
# The 45-degree line makes "regression toward the mean" visible: the fitted
# line is flatter, so tall fathers' sons fall below equality and short
# fathers' sons rise above it.
abline(a = 0, b = 1, col = COL_ORANGE, lwd = 2, lty = 2)
legend("topleft", bty = "n", lwd = c(3, 2), lty = c(1, 2),
       col = c(COL_BLUE, COL_ORANGE),
       legend = c(sprintf("Fitted line: y = %.2f + %.3f x", B0, B1),
                  "y = x  (no regression toward the mean)"),
       text.col = INK)
dev.off()

## ---- fig-i02: marginal vs conditional distribution --------------------

slice <- son[abs(son$father - 72) < 0.75, ]

open_png("fig-i02-marginal-vs-conditional.png", w = 2000, h = 1000)
par(mfrow = c(1, 2), mar = c(4.5, 4.5, 3.5, 1),
    col.axis = INK2, col.lab = INK, fg = INK2)

hist(son$son, breaks = 24, col = FILL_GREY, border = "white",
     main = sprintf("(a) All sons  (n = %d)", nrow(son)),
     xlab = "Son's height (inches)", ylab = "Frequency")
abline(v = mean(son$son), col = COL_RED, lwd = 3)
text(mean(son$son), par("usr")[4] * 0.92,
     labels = sprintf(" mean = %.1f", mean(son$son)), col = COL_RED, pos = 4)

hist(slice$son, breaks = 10, col = FILL_GREY, border = "white",
     main = sprintf("(b) Sons whose father is about 72 in  (n = %d)", nrow(slice)),
     xlab = "Son's height (inches)", ylab = "Frequency")
abline(v = mean(slice$son), col = COL_RED, lwd = 3)
text(mean(slice$son), par("usr")[4] * 0.92,
     labels = sprintf(" mean = %.1f", mean(slice$son)), col = COL_RED, pos = 4)
dev.off()

cat("\n===== fig-i02 =====\n")
cat(sprintf("mean of all sons              : %.2f (n = %d)\n",
            mean(son$son), nrow(son)))
cat(sprintf("mean of sons | father ~ 72 in : %.2f (n = %d)\n",
            mean(slice$son), nrow(slice)))
cat(sprintf("fitted E(Y | X = 72)          : %.2f\n",
            predict(fit, newdata = data.frame(father = 72))))

## ---- fig-i03: local means, with the bins drawn as shaded bands --------

MIN_N <- 10          # a local mean on fewer than 10 sons is too noisy to plot

brk  <- seq(floor(min(son$father)), ceiling(max(son$father)), by = 1)
bin  <- cut(son$father, breaks = brk, include.lowest = TRUE)
locm <- tapply(son$son, bin, mean)
locn <- tapply(son$son, bin, length)
ctr  <- brk[-length(brk)] + 0.5
keep <- !is.na(locm) & locn >= MIN_N

open_png("fig-i03-local-means.png")
par(mar = c(4.5, 4.5, 3, 1), col.axis = INK2, col.lab = INK, fg = INK2)
plot(son$father, son$son, type = "n",
     main = "Local Means Trace Out the Regression Line",
     xlab = "Father's height (inches)", ylab = "Son's height (inches)")

# Alternating vertical bands: one band per 1-inch bin. Bins that are actually
# used for a plotted local mean are tinted; sparse bins are left white so the
# audience can see why no diamond is drawn there.
usr <- par("usr")
kept <- 0
for (i in seq_len(length(brk) - 1)) {
  if (isTRUE(keep[i])) {
    kept <- kept + 1
    fill <- if (kept %% 2 == 1) BAND_A else BAND_B   # every interval visible
  } else {
    fill <- BAND_DROP                                # sparse bin, no diamond
  }
  rect(brk[i], usr[3], brk[i + 1], usr[4], col = fill, border = NA)
  abline(v = brk[i], col = adjustcolor(INK2, alpha.f = 0.35), lty = 3)
}
abline(v = brk[length(brk)], col = adjustcolor(INK2, alpha.f = 0.35), lty = 3)
grid(col = GRID_C, lty = 1)
box(col = INK2)

points(son$father, son$son, pch = 16,
       col = adjustcolor(INK2, alpha.f = 0.30), cex = 0.8)
abline(fit, col = COL_BLUE, lwd = 3)
# Join the local means so the audience literally sees them tracing the line
lines(ctr[keep], locm[keep], col = COL_ORANGE, lwd = 2, lty = 2)
points(ctr[keep], locm[keep], pch = 18, col = COL_ORANGE, cex = 2.4)
legend("topleft", bty = "o", bg = "white", box.col = GRID_C,
       lwd = c(3, 2, NA), lty = c(1, 2, NA), pch = c(NA, 18, 22),
       pt.cex = c(NA, 2.2, 2.2), pt.bg = c(NA, NA, BAND_A),
       col = c(COL_BLUE, COL_ORANGE, adjustcolor(INK2, alpha.f = 0.5)),
       legend = c("Least-squares line",
                  sprintf("Mean son height per 1-inch bin (n >= %d)", MIN_N),
                  "Shaded band = one binning interval"),
       text.col = INK)
dev.off()

cat(sprintf("\n===== fig-i03: local means (bins with n >= %d) =====\n", MIN_N))
print(data.frame(father_bin = paste0("[", brk[-length(brk)][keep], ", ",
                                    brk[-1][keep], ")"),
                 n = as.numeric(locn[keep]),
                 mean_son = round(as.numeric(locm[keep]), 2)))
cat("bins dropped for sparseness:",
    paste0("[", brk[-length(brk)][!keep & !is.na(locm)], ", ",
           brk[-1][!keep & !is.na(locm)], ") n=",
           as.numeric(locn[!keep & !is.na(locm)]), collapse = "  "), "\n")

## ---- fig-i04: regression as a conditional expectation -----------------

open_png("fig-i04-conditional-expectation.png")
par(mar = c(4.5, 4.5, 3, 1), col.axis = INK2, col.lab = INK, fg = INK2)
SIG <- summary(fit)$sigma
xr  <- range(son$father)
yr  <- c(B0 + B1 * xr[1] - 4 * SIG, B0 + B1 * xr[2] + 4 * SIG)
plot(NA, xlim = xr, ylim = yr,
     panel.first = grid(col = GRID_C, lty = 1),
     main = "Regression Is the Conditional Mean of Y Given X = x",
     xlab = "x  (father's height, inches)",
     ylab = "y  (son's height, inches)")
points(son$father, son$son, pch = 16,
       col = adjustcolor(INK2, alpha.f = 0.18), cex = 0.7)
abline(fit, col = COL_BLUE, lwd = 3)

# A sideways normal density at each anchor, centred on the fitted line and
# with the estimated residual SD: this is exactly N(beta0 + beta1 x, sigma^2).
for (x0 in c(65, 69, 73)) {
  mu <- B0 + B1 * x0
  yy <- seq(mu - 3 * SIG, mu + 3 * SIG, length.out = 200)
  dd <- dnorm(yy, mu, SIG)
  dd <- dd / max(dd) * 1.6                        # width in x units
  polygon(c(x0 + dd, rep(x0, length(yy))), c(yy, rev(yy)),
          col = adjustcolor(COL_ORANGE, alpha.f = 0.25), border = COL_ORANGE)
  points(x0, mu, pch = 18, col = COL_ORANGE, cex = 2.0)
  segments(x0, mu, x0 + 1.6, mu, col = COL_ORANGE, lty = 3)
}
legend("topleft", bty = "n", lwd = c(3, NA), pch = c(NA, 18), pt.cex = c(NA, 2),
       col = c(COL_BLUE, COL_ORANGE),
       legend = c(expression(paste("E(Y | X = x) = ", beta[0] + beta[1] * x)),
                  "Conditional mean at x = 65, 69, 73"),
       text.col = INK)
dev.off()

cat(sprintf("\nresidual SD (sigma-hat) used for the conditional densities: %.3f\n",
            SIG))
