# Date        : 2026-08-31
# Description : Two figures for the Introduction slides on step 7 (model
#               validation and criticism).  Both are drawn on the ice cream
#               data used throughout the deck, so the running example is not
#               interrupted by an unrelated data set:
#                 fig-i08-ice-residual.png   - the simple regression
#                     IC ~ temp: the fitted line with the residuals drawn as
#                     vertical drops (left), and residual versus fitted with a
#                     lowess curve (right).  This fit leaves no pattern, so it
#                     is the reference case that passes the check.
#                 fig-i09-residual-warning.png - the three residual shapes
#                     that do signal a problem.  These are SIMULATED, because
#                     the ice cream fit shows none of them; they are simulated
#                     on the observed temp values and at the observed IC scale
#                     so the axes read the same as on the previous slide.
#
#               Data: references/cnu-regression-lecture-note/강의노트/R 예제/
#               7장/ice.csv.csv (n = 30 four-week periods).
#
#               Run from the project root:
#                 Rscript code/agent/2026-08-31/make-ice-residual-figures.R
# File        : make-ice-residual-figures.R

FIG_DIR <- "output/agent/2026-08-31"
dir.create(FIG_DIR, recursive = TRUE, showWarnings = FALSE)

# Same palette as the other Introduction figures
COL_BLUE   <- "#2a78d6"
COL_ORANGE <- "#eb6834"
INK        <- "#0b0b0b"
INK2       <- "#52514e"
GRID_C     <- "#e1e0d9"

ice <- read.csv("references/cnu-regression-lecture-note/강의노트/R 예제/7장/ice.csv.csv",
                stringsAsFactors = FALSE)

# Runs of residual signs ordered by fitted value: about n/2 + 1 when nothing
# systematic is left behind.  Console only, as in the other figure scripts.
runs_of <- function(res, ord) {
  s <- sign(res[order(ord)])
  1 + sum(s[-1] != s[-length(s)])
}

# A residual-versus-fitted panel, shared by both figures
resid_panel <- function(f, r, title) {
  plot(f, r, type = "n", main = title,
       xlab = "Fitted value", ylab = "Residual")
  grid(col = GRID_C, lty = 1)
  box(col = INK2)
  abline(h = 0, col = INK2, lwd = 1.6, lty = 2)
  points(f, r, pch = 16, col = adjustcolor(INK2, alpha.f = 0.6), cex = 1.5)
}

# ---------------------------------------------------------------------------
# Figure 1: the simple regression actually fitted to the ice cream data
# ---------------------------------------------------------------------------
m <- lm(IC ~ temp, data = ice)
cat(sprintf("IC ~ temp: b0 = %.5f, b1 = %.5f, R2 = %.4f, sigma = %.5f\n",
            coef(m)[1], coef(m)[2], summary(m)$r.squared, summary(m)$sigma))
cat(sprintf("runs (ordered by fitted) = %d, expected = %.1f\n",
            runs_of(resid(m), fitted(m)), nrow(ice) / 2 + 1))

png(file.path(FIG_DIR, "fig-i08-ice-residual.png"),
    width = 2100, height = 1000, res = 150)
par(mfrow = c(1, 2), mar = c(4.3, 4.6, 3.0, 1),
    col.axis = INK2, col.lab = INK, fg = INK2)

plot(ice$temp, ice$IC, type = "n",
     main = "Fitted line and the residuals it leaves",
     xlab = "Mean temperature (Fahrenheit)",
     ylab = "Ice cream consumption (pints per capita)")
grid(col = GRID_C, lty = 1)
box(col = INK2)
# Each residual as a vertical drop from the observation to the fitted line
segments(ice$temp, ice$IC, ice$temp, fitted(m),
         col = adjustcolor(COL_ORANGE, alpha.f = 0.75), lwd = 1.6)
abline(m, col = COL_BLUE, lwd = 3.2)
points(ice$temp, ice$IC, pch = 16,
       col = adjustcolor(INK2, alpha.f = 0.6), cex = 1.4)

resid_panel(fitted(m), resid(m), "Residual versus fitted: no pattern left")
lines(lowess(fitted(m), resid(m), f = 0.8), col = COL_BLUE, lwd = 3.4)
dev.off()
cat("written:", file.path(FIG_DIR, "fig-i08-ice-residual.png"), "\n")

# ---------------------------------------------------------------------------
# Figure 2: the three shapes that do signal a problem (simulated)
# ---------------------------------------------------------------------------
set.seed(2026)
x  <- ice$temp                       # observed temperatures, n = 30
b0 <- coef(m)[1]
b1 <- coef(m)[2]
xc <- x - mean(x)

# (a) a bend the straight line cannot follow
y_curve <- b0 + b1 * x - 1.2e-4 * xc^2 + rnorm(length(x), 0, 0.015)
# (b) spread that grows with temperature
y_funnel <- b0 + b1 * x + rnorm(length(x), 0, 0.008 + 0.0014 * (x - min(x)))
# (c) one observation pulled far away from the rest
y_out <- b0 + b1 * x + rnorm(length(x), 0, 0.020)
i_out <- which.min(abs(x - median(x)))          # a middle period, not an edge
y_out[i_out] <- y_out[i_out] + 0.18

m_curve  <- lm(y_curve  ~ x)
m_funnel <- lm(y_funnel ~ x)
m_out    <- lm(y_out    ~ x)

# Numbers quoted on the slide, all printed here for checking
cat(sprintf("\ncurved : R2 = %.4f, runs = %d (expected %.1f)\n",
            summary(m_curve)$r.squared, runs_of(resid(m_curve), fitted(m_curve)),
            length(x) / 2 + 1))
sd_lo <- sd(resid(m_funnel)[x <= median(x)])
sd_hi <- sd(resid(m_funnel)[x >  median(x)])
cat(sprintf("funnel : sd of residuals, cool half = %.4f, warm half = %.4f, ratio = %.1f\n",
            sd_lo, sd_hi, sd_hi / sd_lo))
b_with    <- coef(m_out)[2]
b_without <- coef(lm(y_out[-i_out] ~ x[-i_out]))[2]
cat(sprintf("outlier: slope with = %.5f, without = %.5f, change = %.1f%%\n",
            b_with, b_without, 100 * (b_with - b_without) / b_without))

# The same displacement placed at the edge of the temperature range instead:
# a point far from the centre of x moves the line much more, which is why the
# second question of step 7 asks about single observations separately.
y_edge <- b0 + b1 * x + rnorm(length(x), 0, 0.020)
i_edge <- which.max(x)
y_edge[i_edge] <- y_edge[i_edge] + 0.18
b_edge_with    <- coef(lm(y_edge ~ x))[2]
b_edge_without <- coef(lm(y_edge[-i_edge] ~ x[-i_edge]))[2]
cat(sprintf("same shift at the edge: slope with = %.5f, without = %.5f, change = %.1f%%\n",
            b_edge_with, b_edge_without,
            100 * (b_edge_with - b_edge_without) / b_edge_without))

# Three panels share the width that two panels had on the previous slide, so
# the base font is enlarged: the slide shows the figure at about half its pixel
# width, and at the default 12 points the axis labels would not read from the
# back of a room.
png(file.path(FIG_DIR, "fig-i09-residual-warning.png"),
    width = 2100, height = 860, res = 150, pointsize = 20)
par(mfrow = c(1, 3), mar = c(4.3, 4.6, 3.0, 1),
    col.axis = INK2, col.lab = INK, fg = INK2)

resid_panel(fitted(m_curve), resid(m_curve), "Curved: a bend was missed")
lines(lowess(fitted(m_curve), resid(m_curve), f = 0.8), col = COL_ORANGE, lwd = 3.4)

rf <- resid(m_funnel); ff <- fitted(m_funnel)
resid_panel(ff, rf, "Funnel: the spread keeps growing")
env <- lowess(ff, abs(rf), f = 0.9)              # the widening band, both sides
lines(env$x,  env$y, col = COL_ORANGE, lwd = 3.0, lty = 2)
lines(env$x, -env$y, col = COL_ORANGE, lwd = 3.0, lty = 2)

resid_panel(fitted(m_out), resid(m_out), "One point stands far apart")
points(fitted(m_out)[i_out], resid(m_out)[i_out], pch = 1, cex = 3.2,
       col = COL_ORANGE, lwd = 3.0)
dev.off()
cat("written:", file.path(FIG_DIR, "fig-i09-residual-warning.png"), "\n")
