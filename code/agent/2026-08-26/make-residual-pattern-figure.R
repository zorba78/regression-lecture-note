# Date        : 2026-08-26
# Description : Figure for the Introduction slide "7단계 모형 검증과 비판".
#               Two residual-versus-fitted plots from the SAME real data, so
#               the only thing that changes between the panels is the model:
#                 left  - Volume ~ Girth, a straight line on a relationship
#                         that is not straight; the residuals keep a clear arc
#                 right - log(Volume) ~ log(Girth) + log(Height); the arc is
#                         gone
#               Data: R's built-in `trees` (Black cherry, n = 31; girth in
#               inches, height in feet, volume in cubic feet.  Ryan, Joiner &
#               Ryan, Minitab Student Handbook, 1976).  The log form is not an
#               arbitrary choice: a trunk behaves roughly like a cylinder, so
#               volume is about proportional to girth^2 times height, and
#               taking logs turns that into a first-order equation.
#
#               A lowess curve is drawn through each residual cloud so the
#               pattern (or its absence) is visible from the back of a room.
#               The run counts printed to the console back up the claim that
#               the left panel is systematic and the right panel is not.
#
#               Run from the project root:
#                 Rscript code/agent/2026-08-26/make-residual-pattern-figure.R
# File        : make-residual-pattern-figure.R

FIG_DIR <- "output/agent/2026-08-26"
dir.create(FIG_DIR, recursive = TRUE, showWarnings = FALSE)

COL_BLUE   <- "#2a78d6"
COL_ORANGE <- "#eb6834"
INK        <- "#0b0b0b"
INK2       <- "#52514e"
GRID_C     <- "#e1e0d9"

m_bad  <- lm(Volume ~ Girth, data = trees)
m_good <- lm(log(Volume) ~ log(Girth) + log(Height), data = trees)

# Runs of residual signs ordered by fitted value: about n/2 + 1 if nothing
# systematic is left.  Reported to the console, not printed on the figure.
runs_of <- function(m) {
  r <- resid(m)
  s <- sign(r[order(fitted(m))])
  1 + sum(s[-1] != s[-length(s)])
}
cat(sprintf("n = %d, expected runs = %.1f\n", nrow(trees), nrow(trees) / 2 + 1))
cat(sprintf("Volume ~ Girth            R2 = %.4f  runs = %d\n",
            summary(m_bad)$r.squared, runs_of(m_bad)))
cat(sprintf("log(Volume) ~ log(G)+log(H) R2 = %.4f  runs = %d\n",
            summary(m_good)$r.squared, runs_of(m_good)))
cat("log-log coefficients (girth exponent should sit near 2):\n")
print(round(coef(m_good), 3))

panel <- function(m, title, curve_col) {
  f <- fitted(m)
  r <- resid(m)
  plot(f, r, type = "n", main = title,
       xlab = "Fitted value", ylab = "Residual")
  grid(col = GRID_C, lty = 1)
  box(col = INK2)
  abline(h = 0, col = INK2, lwd = 1.6, lty = 2)
  points(f, r, pch = 16, col = adjustcolor(INK2, alpha.f = 0.6), cex = 1.5)
  lines(lowess(f, r, f = 0.8), col = curve_col, lwd = 3.4)
}

png(file.path(FIG_DIR, "fig-i08-residual-pattern.png"),
    width = 2100, height = 1000, res = 150)
par(mfrow = c(1, 2), mar = c(4.3, 4.6, 3.0, 1),
    col.axis = INK2, col.lab = INK, fg = INK2)
panel(m_bad,  "Straight line: an arc is left behind", COL_ORANGE)
panel(m_good, "Log-log model: no arc left",           COL_BLUE)
dev.off()

cat("written:", file.path(FIG_DIR, "fig-i08-residual-pattern.png"), "\n")
