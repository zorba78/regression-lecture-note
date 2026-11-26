# Date        : 2026-11-26
# Description : Figures for the physics calibration example in chapter 6
#               (Weighted Regression) of the KINS lecture.
#               Data: alr4::physics (Weisberg, S. 2014, Applied Linear
#               Regression, 4th ed.; original Weisberg, H. et al. 1978,
#               Physics Review D 17, 2875-2887), checked against the CRAN
#               alr4 1.0.7 data file. The 4th x is 0.225 and the third
#               column is the standard deviation SD of y, so the precision
#               weight is w = 1/SD^2 (see check-ch06-physics-wls.R for every
#               number that the slides quote).
#               Replaces output/agent/2026-08-11/fig06-wls-physics.png, which
#               used x4 = 0.255 and weight 1/SD; that file and its script are
#               left untouched.
#               Writes to output/agent/2026-11-26/:
#                 fig-p06-physics-ols-wls.png        data +/- SD, OLS and WLS lines
#                 fig-p06-physics-wresid-linear.png  weighted residuals, straight line
#                 fig-p06-physics-quadratic.png      data +/- SD, WLS line and quadratic
#                 fig-p06-physics-wresid-compare.png weighted residuals, line vs quadratic
#               Run   : Rscript code/agent/2026-11-26/make-ch06-physics-figures.R
# File        : make-ch06-physics-figures.R

out_dir <- "g:/Projects/regression-lecture-note/output/agent/2026-11-26"
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

## ---- palette (same values as code/agent/2026-08-11/make-lecture-figures.R) --
COL_BLUE   <- "#2a78d6"   # OLS
COL_ORANGE <- "#eb6834"   # WLS straight line
COL_AQUA   <- "#1baf7a"   # WLS quadratic
INK        <- "#0b0b0b"
INK2       <- "#52514e"
GRID_C     <- "#e1e0d9"

# res = 230 (not the 170 of the 2026-08-11 script): these figures sit in a
# 56-60% column or a two-panel strip, where 170 dpi left tick labels near 9 px
# on the 1280 x 1024 slide; 230 dpi enlarges all text by 230/170 = 1.35.
open_png <- function(file, w = 1800, h = 1100, res = 230) {
  png(file.path(out_dir, file), width = w, height = h, res = res)
}

## ---- data and fits ------------------------------------------------------------
x  <- c(0.345, 0.287, 0.251, 0.225, 0.207, 0.186, 0.161, 0.132, 0.084, 0.060)
y  <- c(367, 311, 295, 268, 253, 239, 220, 213, 193, 192)
SD <- c(17, 9, 9, 7, 7, 6, 6, 6, 5, 5)
w  <- 1 / SD^2

ols  <- lm(y ~ x)                              # equal weights
wls1 <- lm(y ~ x, weights = w)                 # straight line, w = 1/SD^2
wls2 <- lm(y ~ x + I(x^2), weights = w)        # quadratic, same weights

# weighted residuals r_i^w = sqrt(w_i) e_i = (y_i - yhat_i) / SD_i
rw1 <- (y - fitted(wls1)) / SD
rw2 <- (y - fitted(wls2)) / SD
cat("weighted residuals, line:", sprintf("%.2f", rw1), "\n")
cat("weighted residuals, quad:", sprintf("%.2f", rw2), "\n")

# curves are drawn only over the observed x range (no extrapolation)
xg <- seq(min(x), max(x), length.out = 200)

# scatter with +/- 1 SD error bars, shared by the two data panels
data_panel <- function(main) {
  par(mar = c(4.5, 4.8, 3, 1), col.axis = INK2, col.lab = INK, fg = INK2)
  # y range covers the error bars and every fitted line drawn on top
  plot(x, y, type = "n", ylim = range(c(y - SD, y + SD, fitted(ols))),
       panel.first = grid(col = GRID_C, lty = 1), main = main,
       xlab = "x (inverse total energy)", ylab = "y (cross-section)")
  arrows(x, y - SD, x, y + SD, angle = 90, code = 3, length = 0.04,
         col = INK2, lwd = 1.5)
  points(x, y, pch = 16, col = INK, cex = 1.2)
}

## ---- figure 1: OLS vs WLS straight lines ---------------------------------------
open_png("fig-p06-physics-ols-wls.png")
data_panel("Straight-line fits to the physics data (bars = +/- 1 SD)")
lines(xg, predict(ols,  newdata = data.frame(x = xg)), col = COL_BLUE,   lwd = 3)
lines(xg, predict(wls1, newdata = data.frame(x = xg)), col = COL_ORANGE, lwd = 3, lty = 2)
legend("topleft", bty = "n", lwd = 3, lty = c(1, 2), col = c(COL_BLUE, COL_ORANGE),
       legend = c("OLS (equal weights)", "WLS (w = 1/SD^2)"), text.col = INK)
dev.off()

## ---- weighted-residual panel helper --------------------------------------------
resid_panel <- function(r, main, col, cx = 0.85, pcex = 1.5) {
  par(mar = c(4.5, 4.8, 3, 1), col.axis = INK2, col.lab = INK, fg = INK2)
  # x range padded on both sides so the end-point value labels are not clipped
  plot(x, r, type = "n", ylim = c(-3, 3), xlim = c(0.04, 0.365), main = main,
       panel.first = grid(col = GRID_C, lty = 1),
       xlab = "x (inverse total energy)", ylab = "Weighted residual (y - fitted) / SD")
  abline(h = 0, col = INK2, lwd = 1.5)
  abline(h = c(-2, 2), col = INK2, lwd = 1, lty = 3)
  o <- order(x)
  lines(x[o], r[o], col = col, lwd = 1.5, lty = 2)       # joins points left to right
  # value labels, placed above positive and below negative points, on a white
  # box so the dashed joining line does not run through the digits
  lab <- sprintf("%.2f", r)
  dy  <- ifelse(r >= 0, 1, -1) * 2.0 * strheight("0", cex = cx)
  bw  <- strwidth(lab, cex = cx) / 2 * 1.15
  bh  <- strheight("0", cex = cx) / 2 * 1.5
  rect(x - bw, r + dy - bh, x + bw, r + dy + bh, col = "white", border = NA)
  text(x, r + dy, lab, cex = cx, col = INK)
  points(x, r, pch = 16, col = col, cex = pcex)           # drawn last, on top of the boxes
}

## ---- figure 2: weighted residuals of the straight line -------------------------
open_png("fig-p06-physics-wresid-linear.png")
resid_panel(rw1, "Weighted residuals of the WLS straight line", COL_ORANGE)
dev.off()

## ---- figure 3: WLS straight line vs WLS quadratic ------------------------------
open_png("fig-p06-physics-quadratic.png")
data_panel("WLS straight line and quadratic (bars = +/- 1 SD)")
lines(xg, predict(wls1, newdata = data.frame(x = xg)), col = COL_ORANGE, lwd = 3, lty = 2)
lines(xg, predict(wls2, newdata = data.frame(x = xg)), col = COL_AQUA, lwd = 3)
legend("topleft", bty = "n", lwd = 3, lty = c(2, 1), col = c(COL_ORANGE, COL_AQUA),
       legend = c("Straight line", "Quadratic"), text.col = INK)
dev.off()

## ---- figure 4: residuals before and after the quadratic term -------------------
# two panels shown about 820 px wide on the slide: a higher res keeps the
# tick and value labels legible at that size
open_png("fig-p06-physics-wresid-compare.png", w = 2200, h = 1000, res = 270)
par(mfrow = c(1, 2))
# smaller labels and points: at res 270 the default sizes made -0.77 and -1.37 collide
resid_panel(rw1, "(a) Straight line", COL_ORANGE, cx = 0.7, pcex = 1.2)
resid_panel(rw2, "(b) Quadratic", COL_AQUA, cx = 0.7, pcex = 1.2)
dev.off()

cat("figures written to", out_dir, "\n")
