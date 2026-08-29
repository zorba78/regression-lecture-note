# Date        : 2026-08-28
# Description : Teaching figure for chapter 5 (Diagnosis) of the KINS lecture.
#               The deck already states in words that a large residual alone or a
#               large leverage alone need not move the fitted line, and that only
#               the two together do. This script shows that claim on one base data
#               set: the same 20 points are refitted three times, each time with a
#               single extra point added.
#                 (a) outlier      - far in y, at the centre of x  (large e, small h)
#                 (b) high leverage - far in x, on the line        (small e, large h)
#                 (c) influential   - far in x AND off the line    (large e, large h)
#               For each case the script prints the leverage h_ii, the studentized
#               residual, Cook's distance and the change in the fitted slope, so
#               every number written on the slide is derived here.
#               Writes output/agent/2026-08-28/fig-m05-outlier-leverage-influence.png
# File        : outlier-leverage-influence-figure.R

set.seed(20260828)

out_dir <- "g:/Projects/regression-lecture-note/output/agent/2026-08-28"
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

## ---------------------------------------------------------------------------
## 1. Base data: a clean simple linear relationship, y = 2 + 0.8x + noise
## ---------------------------------------------------------------------------
n0 <- 20
x0 <- round(seq(2, 10, length.out = n0) + rnorm(n0, 0, 0.35), 2)
y0 <- round(2 + 0.8 * x0 + rnorm(n0, 0, 0.8), 2)
base <- data.frame(x = x0, y = y0)
fit0 <- lm(y ~ x, data = base)

cat("=== base fit (n = 20) ===\n")
print(round(summary(fit0)$coefficients, 4))
cat("mean x =", round(mean(x0), 3), " x range =", round(range(x0), 2), "\n\n")

## ---------------------------------------------------------------------------
## 2. Three cases, each = base data + ONE extra point
##    The added y values are set relative to the base line so that the intended
##    contrast (large e / large h / both) is exact rather than eyeballed.
## ---------------------------------------------------------------------------
b <- coef(fit0)
line_at <- function(x) as.numeric(b[1] + b[2] * x)

cases <- list(
  list(key = "outlier",     x = 6.0,  y = line_at(6.0) + 5.0,
       title = "(a) Outlier: far in y, centre of x"),
  # offset slightly rather than sitting exactly on the line: a residual of
  # exactly zero would look staged, and the point still has to be near the line
  # for this case to be "leverage only"
  list(key = "leverage",    x = 19.0, y = line_at(19.0) + 0.9,
       title = "(b) High leverage: far in x, near the line"),
  list(key = "influential", x = 19.0, y = line_at(19.0) - 7.0,
       title = "(c) Influential: far in x and off the line")
)

res <- list()
for (cs in cases) {
  d <- rbind(base, data.frame(x = cs$x, y = cs$y))
  f <- lm(y ~ x, data = d)
  k <- nrow(d)                       # the added point is the last row
  h <- hatvalues(f)[k]
  rs <- rstudent(f)[k]               # studentized (deleted) residual
  cd <- cooks.distance(f)[k]
  res[[cs$key]] <- list(cs = cs, d = d, fit = f,
                        h = as.numeric(h), rs = as.numeric(rs),
                        cd = as.numeric(cd),
                        slope = as.numeric(coef(f)[2]),
                        icept = as.numeric(coef(f)[1]))
  cat(sprintf("=== %s ===\n", cs$key))
  cat(sprintf("added point (x, y) = (%.2f, %.2f)\n", cs$x, cs$y))
  cat(sprintf("leverage h        = %.3f   (mean h = 2/%d = %.3f, cutoff 2*mean = %.3f)\n",
              h, k, 2 / k, 4 / k))
  cat(sprintf("studentized resid = %.2f\n", rs))
  cat(sprintf("Cook's distance   = %.3f\n", cd))
  cat(sprintf("slope  %.4f -> %.4f   (change %+.1f%%)\n",
              coef(fit0)[2], coef(f)[2],
              100 * (coef(f)[2] - coef(fit0)[2]) / coef(fit0)[2]))
  cat(sprintf("intcpt %.4f -> %.4f\n\n", coef(fit0)[1], coef(f)[1]))
}

## summary table, printed in the layout used on the slide
cat("=== slide table ===\n")
tab <- data.frame(
  case      = c("(a) outlier", "(b) high leverage", "(c) influential"),
  leverage  = sapply(res, function(z) round(z$h, 3)),
  stud_res  = sapply(res, function(z) round(z$rs, 2)),
  cooks_D   = sapply(res, function(z) round(z$cd, 3)),
  slope     = sapply(res, function(z) round(z$slope, 3)),
  pct       = sapply(res, function(z)
                round(100 * (z$slope - coef(fit0)[2]) / coef(fit0)[2], 1)),
  row.names = NULL)
print(tab)
cat("base slope =", round(coef(fit0)[2], 3), "\n")

## ---------------------------------------------------------------------------
## 3. Figure. This is a CONCEPTUAL panel: the numbers above stay in the console
##    as the evidence for the qualitative claims, and none of them are drawn.
##    What the picture has to carry is only:
##      - how far the red point sits from the centre of x  (leverage)
##      - how far it sits from the line in y               (residual)
##      - whether the fitted line moves when it is added
## ---------------------------------------------------------------------------
png(file.path(out_dir, "fig-m05-outlier-leverage-influence.png"),
    width = 2000, height = 780, res = 150)
op <- par(mfrow = c(1, 3), mar = c(4.6, 4.6, 5.2, 1.0), cex.axis = 1.2,
          cex.lab = 1.45)

xlim <- c(0, 21)
ylim <- range(c(base$y, sapply(res, function(z) z$cs$y))) + c(-1.5, 2.0)
xbar <- mean(base$x)

titles <- c(outlier     = "(a) Far in y only",
            leverage    = "(b) Far in x only",
            influential = "(c) Far in both")
verdict <- c(outlier     = "line barely moves",
             leverage    = "line barely moves",
             influential = "line is pulled away")

for (key in c("outlier", "leverage", "influential")) {
  z <- res[[key]]
  plot(base$x, base$y, xlim = xlim, ylim = ylim, xlab = "x", ylab = "y",
       main = "", pch = 21, bg = "grey80", col = "grey35", cex = 1.3)
  # title and verdict on separate margin lines so they cannot collide
  mtext(titles[[key]], side = 3, line = 2.3, cex = 1.15, font = 2)
  mtext(verdict[[key]], side = 3, line = 0.7, cex = 0.95, col = "#C44E52")
  # centre of x: how far the red point is from here is what leverage measures
  abline(v = xbar, col = "grey65", lty = 3, lwd = 2)
  text(xbar, ylim[2], "centre of x", pos = 4, offset = 0.3, col = "grey45",
       cex = 1.15)
  abline(fit0, col = "grey45", lwd = 2.4, lty = 2)
  abline(z$fit, col = "#C44E52", lwd = 3.0)
  # the vertical gap from the point down to the line is the residual
  segments(z$cs$x, z$cs$y, z$cs$x, line_at(z$cs$x),
           col = "#C44E52", lwd = 2, lty = 3)
  points(z$cs$x, z$cs$y, pch = 21, bg = "#C44E52", col = "white",
         cex = 2.6, lwd = 2)
  # name the two lines once; the three panels are read side by side
  if (key == "outlier") {
    legend("bottomright", bty = "n", cex = 1.3, lwd = c(2.4, 3.0),
           lty = c(2, 1), col = c("grey45", "#C44E52"),
           legend = c("fit without the red point", "fit with the red point"))
  }
}
par(op)
dev.off()

cat("\nfigure written:",
    file.path(out_dir, "fig-m05-outlier-leverage-influence.png"), "\n")
