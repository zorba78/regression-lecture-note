# Date        : 2026-08-25
# Description : Re-draw the covariance quadrant-sign figure with a wider, shorter
#               canvas so the slide can show it at full width and place the two
#               explanation boxes directly beneath the matching panel.
#               Drawing code and seed are copied unchanged from
#               code/agent/2026-08-13/make-restructure-figures.R (fig-p01);
#               only the canvas proportions differ (2000x1000 -> 2000x780).
#               Run from the project root:
#                 Rscript code/agent/2026-08-25/make-quadrant-figure.R
# File        : make-quadrant-figure.R

FIG_DIR <- "output/agent/2026-08-25"
dir.create(FIG_DIR, recursive = TRUE, showWarnings = FALSE)

COL_BLUE   <- "#2a78d6"
COL_ORANGE <- "#eb6834"
COL_RED    <- "#e34948"
INK        <- "#0b0b0b"
INK2       <- "#52514e"
GRID_C     <- "#e1e0d9"

set.seed(11)
xa <- rnorm(60); ya <-  0.85 * xa + rnorm(60, sd = 0.55)
xb <- rnorm(60); yb <- -0.85 * xb + rnorm(60, sd = 0.55)

quad_panel <- function(xx, yy, main) {
  plot(xx, yy, pch = 16, col = INK2, cex = 0.9,
       xlim = c(-3, 3), ylim = c(-3, 3),
       panel.first = grid(col = GRID_C, lty = 1),
       main = main, xlab = "x", ylab = "y")
  abline(v = mean(xx), h = mean(yy), col = COL_RED, lwd = 2, lty = 2)
  # sign of (y - ybar)(x - xbar) in each quadrant
  text( 2.1,  2.1, "+", col = COL_BLUE,   cex = 2.6, font = 2)
  text(-2.1,  2.1, "-", col = COL_ORANGE, cex = 2.6, font = 2)
  text(-2.1, -2.1, "+", col = COL_BLUE,   cex = 2.6, font = 2)
  text( 2.1, -2.1, "-", col = COL_ORANGE, cex = 2.6, font = 2)
}

png(file.path(FIG_DIR, "fig-p01-quadrant-signs.png"),
    width = 2000, height = 780, res = 170)
par(mfrow = c(1, 2), mar = c(4.3, 4.3, 3.2, 1),
    col.axis = INK2, col.lab = INK, fg = INK2)
quad_panel(xa, ya, sprintf("Positive association (r = %.2f)", cor(xa, ya)))
quad_panel(xb, yb, sprintf("Negative association (r = %.2f)", cor(xb, yb)))
dev.off()

cat("written:", file.path(FIG_DIR, "fig-p01-quadrant-signs.png"), "\n")
