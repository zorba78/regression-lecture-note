# Date        : 2026-08-30
# Description : Re-draw fig-i02 (marginal vs conditional histograms), fig-i03
#               (local means) and fig-i04 (conditional expectation) with
#               MID-PARENT height as the explanatory variable, so that slides
#               7/25, 8/25 and 9/25 use the same pairing as the Galton origin
#               slide redrawn earlier today
#               (code/agent/2026-08-30/make-galton-midparent-scatter.R).
#
#               Until now these two figures used the 465 father-son pairs.
#               Following Galton (1886) the mother's and the daughters'
#               statures are multiplied by 1.08, and
#                 mid-parent = (father + 1.08 * mother) / 2,
#               which gives all 898 children of the 197 families.
#
#               Drawing code and palette are copied from
#               code/agent/2026-08-24/make-galton-real-figures.R; canvas
#               proportions are those of the versions the slides currently use
#               (2000x780 for fig-i02, 2150x1000 for fig-i03 from the
#               2026-08-25 re-draws, 1800x1100 for fig-i04 from 2026-08-24).
#
#               Run from the project root:
#                 Rscript code/agent/2026-08-30/make-galton-midparent-conditional-figures.R
# File        : make-galton-midparent-conditional-figures.R

## ---- setup ------------------------------------------------------------

FIG_DIR <- "output/agent/2026-08-30"
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

## ---- Galton's transmutation -------------------------------------------

g <- read.delim("data/derived-data/galton-stata11.tab", stringsAsFactors = FALSE)
g$midparent <- (g$father + 1.08 * g$mother) / 2
g$child     <- ifelse(g$gender == "F", 1.08 * g$height, g$height)

fit <- lm(child ~ midparent, data = g)

## ---- fig-i02: marginal vs conditional distribution --------------------

# The conditional panel keeps the +/- 0.75 inch window around 72 inches used
# by the father-son version, so the two figures stay comparable.
slice <- g[abs(g$midparent - 72) < 0.75, ]

png(file.path(FIG_DIR, "fig-i02-marginal-vs-conditional.png"),
    width = 2000, height = 780, res = 170)
par(mfrow = c(1, 2), mar = c(4.5, 4.5, 3.5, 1),
    col.axis = INK2, col.lab = INK, fg = INK2)

hist(g$child, breaks = 24, col = FILL_GREY, border = "white",
     main = sprintf("(a) All children  (n = %d)", nrow(g)),
     xlab = "Child height (inches)", ylab = "Frequency")
abline(v = mean(g$child), col = COL_RED, lwd = 3)
text(mean(g$child), par("usr")[4] * 0.92,
     labels = sprintf(" mean = %.1f", mean(g$child)), col = COL_RED, pos = 4)

hist(slice$child, breaks = 10, col = FILL_GREY, border = "white",
     main = sprintf("(b) Children whose mid-parent is about 72 in  (n = %d)",
                    nrow(slice)),
     xlab = "Child height (inches)", ylab = "Frequency")
abline(v = mean(slice$child), col = COL_RED, lwd = 3)
text(mean(slice$child), par("usr")[4] * 0.92,
     labels = sprintf(" mean = %.1f", mean(slice$child)), col = COL_RED, pos = 4)
dev.off()

cat("===== fig-i02 =====\n")
cat(sprintf("all children              : mean %.2f  (n = %d)\n",
            mean(g$child), nrow(g)))
cat(sprintf("mid-parent ~ 72 in slice  : mean %.2f  (n = %d)\n",
            mean(slice$child), nrow(slice)))
cat(sprintf("fitted E(Y | X = 72)      : %.2f\n",
            predict(fit, newdata = data.frame(midparent = 72))))

## ---- fig-i03: local means, with the bins drawn as shaded bands --------

MIN_N <- 10          # a local mean on fewer than 10 children is too noisy

brk  <- seq(floor(min(g$midparent)), ceiling(max(g$midparent)), by = 1)
bin  <- cut(g$midparent, breaks = brk, include.lowest = TRUE)
locm <- tapply(g$child, bin, mean)
locn <- tapply(g$child, bin, length)
ctr  <- brk[-length(brk)] + 0.5
keep <- !is.na(locm) & locn >= MIN_N

png(file.path(FIG_DIR, "fig-i03-local-means.png"),
    width = 2150, height = 1000, res = 170)
par(mar = c(4.5, 4.5, 3, 1), col.axis = INK2, col.lab = INK, fg = INK2)
plot(g$midparent, g$child, type = "n",
     main = "Local Means Trace Out the Regression Line",
     xlab = "Mid-parent height (inches)", ylab = "Child height (inches)")

# Alternating vertical bands: one band per 1-inch bin. Bins that are actually
# used for a plotted local mean are tinted; sparse bins are left grey so the
# audience can see why no diamond is drawn there.
usr  <- par("usr")
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

points(g$midparent, g$child, pch = 16,
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
                  sprintf("Mean child height per 1-inch bin (n >= %d)", MIN_N),
                  "Shaded band = one binning interval"),
       text.col = INK)
dev.off()

cat(sprintf("\n===== fig-i03: local means (bins with n >= %d) =====\n", MIN_N))
print(data.frame(midparent_bin = paste0("[", brk[-length(brk)][keep], ", ",
                                        brk[-1][keep], ")"),
                 n = as.numeric(locn[keep]),
                 mean_child = round(as.numeric(locm[keep]), 2)))
cat("bins dropped for sparseness:",
    paste0("[", brk[-length(brk)][!keep & !is.na(locm)], ", ",
           brk[-1][!keep & !is.na(locm)], ") n=",
           as.numeric(locn[!keep & !is.na(locm)]), collapse = "  "), "\n")

## ---- fig-i04: regression as a conditional expectation -----------------

B0  <- coef(fit)[1]
B1  <- coef(fit)[2]
SIG <- summary(fit)$sigma
xr  <- range(g$midparent)
yr  <- c(B0 + B1 * xr[1] - 4 * SIG, B0 + B1 * xr[2] + 4 * SIG)

png(file.path(FIG_DIR, "fig-i04-conditional-expectation.png"),
    width = 1800, height = 1100, res = 170)
par(mar = c(4.5, 4.5, 3, 1), col.axis = INK2, col.lab = INK, fg = INK2)
plot(NA, xlim = xr, ylim = yr,
     panel.first = grid(col = GRID_C, lty = 1),
     main = "Regression Is the Conditional Mean of Y Given X = x",
     xlab = "x  (mid-parent height, inches)",
     ylab = "y  (child height, inches)")
points(g$midparent, g$child, pch = 16,
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

cat("\n===== fig-i04 =====\n")
cat(sprintf("residual SD (sigma-hat) used for the conditional densities: %.3f\n",
            SIG))
for (x0 in c(65, 69, 73)) {
  cat(sprintf("E(Y | X = %d) = %.2f\n", x0, B0 + B1 * x0))
}

## ---- numbers quoted on the model-fit slide (11/25) --------------------

cat("\n===== model fit table (3 significant digits) =====\n")
print(signif(summary(fit)$coefficients, 3))
print(anova(fit))
cat(sprintf("R-squared = %.3f   residual SD = %.3f   n = %d\n",
            summary(fit)$r.squared, SIG, nrow(g)))
