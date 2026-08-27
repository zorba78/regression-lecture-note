# Date        : 2026-08-28
# Description : Figure for the chapter 4 slide on the decomposition of degrees
#               of freedom. Two panels, both drawn from the ice cream fit
#               (n = 30, p = 3) so every length and every count on the picture
#               is a real number from the data, not a sketch:
#
#                 left  - the sum-of-squares identity as a RIGHT TRIANGLE drawn
#                         TO SCALE. The three sides are the three vectors
#                           y - ybar*1   (hypotenuse, length sqrt(SST))
#                           yhat - ybar*1 (leg, length sqrt(SSR))
#                           y - yhat      (leg, length sqrt(SSE))
#                         The legs are perpendicular because X'e = 0, so
#                         SST = SSR + SSE is exactly Pythagoras. The angle at
#                         the origin satisfies cos^2(theta) = SSR/SST = R^2,
#                         which is printed on the panel.
#
#                 right - the same split, counted in DIMENSIONS. The vector
#                         y - ybar*1 lives in the (n-1)-dimensional space
#                         orthogonal to the vector of ones; its two pieces live
#                         in orthogonal subspaces of dimension p and n-p-1. The
#                         bar is drawn to scale in units of one degree of
#                         freedom, so 29 = 3 + 26 is read off directly.
#
#               Data source: references/cnu-regression-lecture-note 7장 ice.csv.
#               Every quantity is printed to the console for the 검산 rule.
# File        : make-df-decomposition-figure.R

options(digits = 10)

ice <- read.csv("../../../references/cnu-regression-lecture-note/강의노트/R 예제/7장/ice.csv.csv")
names(ice) <- tolower(names(ice))

fit  <- lm(ic ~ price + income + temp, data = ice)
n    <- nrow(ice)
p    <- length(coef(fit)) - 1

# --- the three sums of squares, each as the squared length of a vector -------
y     <- ice$ic
ybar  <- mean(y)
yhat  <- fitted(fit)
v_tot <- y - ybar          # hypotenuse
v_reg <- yhat - ybar       # leg that the model explains
v_res <- y - yhat          # leg that it does not

SST <- sum(v_tot^2)
SSR <- sum(v_reg^2)
SSE <- sum(v_res^2)

# The two legs are perpendicular: their inner product is zero. This is the one
# fact that makes the triangle a RIGHT triangle, so it is checked, not assumed.
cross <- sum(v_reg * v_res)

R2    <- SSR / SST
theta <- acos(sqrt(SSR / SST))            # angle at the origin, in radians

cat("n =", n, "  p =", p, "\n")
cat("SST =", SST, "\n")
cat("SSR =", SSR, "\n")
cat("SSE =", SSE, "\n")
cat("SSR + SSE       =", SSR + SSE, "   (must equal SST)\n")
cat("SST - (SSR+SSE) =", SST - (SSR + SSE), "\n")
cat("inner product of the two legs =", cross, "  (must be 0)\n")
cat("side lengths: sqrt(SST) =", sqrt(SST),
    "  sqrt(SSR) =", sqrt(SSR), "  sqrt(SSE) =", sqrt(SSE), "\n")
cat("Pythagoras check: SSR + SSE - SST =", SSR + SSE - SST, "\n")
cat("R2 = SSR/SST =", R2, "   cos^2(theta) =", cos(theta)^2, "\n")
cat("theta =", theta * 180 / pi, "degrees\n")
cat("degrees of freedom:  n-1 =", n - 1, " = p =", p,
    " + n-p-1 =", n - p - 1, "  -> sum =", p + (n - p - 1), "\n")

# --- drawing --------------------------------------------------------------
a <- sqrt(SSR)      # horizontal leg
b <- sqrt(SSE)      # vertical leg
c <- sqrt(SST)      # hypotenuse

out <- "../../../output/agent/2026-08-28"
dir.create(out, showWarnings = FALSE, recursive = TRUE)
png(file.path(out, "fig-m03-df-decomposition.png"),
    width = 2100, height = 880, res = 150)

par(mfrow = c(1, 2), mar = c(1.4, 1.2, 2.6, 1.2), family = "sans")

col_reg <- "#3b9ab2"
col_res <- "#e8552d"
col_tot <- "#14324a"

# --- left panel: the right triangle, to scale -------------------------------
# asp = 1 keeps the right angle square and the side lengths honest. With asp
# set, R expands whichever range has slack, so the limits below are chosen with
# the same width-to-height ratio as the plotting region (about 1.31 for a 7 x
# 5.87 inch panel with these margins). That is what stops the panel from being
# padded out with empty space, and it leaves a deliberate strip on the right
# wide enough for the vertical leg's label.
plot(NA, xlim = c(-0.030, 0.412), ylim = c(-0.062, 0.275),
     asp = 1, axes = FALSE, xlab = "", ylab = "",
     main = "Sums of squares: a right triangle, drawn to scale",
     cex.main = 1.1, font.main = 1)

polygon(c(0, a, a), c(0, 0, b), col = "#f4f7f9", border = NA)

# the right angle at the corner where the two legs meet
sq <- 0.017
lines(c(a - sq, a - sq, a), c(0, sq, sq), col = "#8a8a8a", lwd = 1.4)

arrows(0, 0, a, 0, length = 0.10, lwd = 3.2, col = col_reg)
arrows(a, 0, a, b, length = 0.10, lwd = 3.2, col = col_res)
arrows(0, 0, a, b, length = 0.10, lwd = 3.2, col = col_tot)

# the angle whose squared cosine is R-squared
ang <- seq(0, theta, length.out = 60)
r_a <- 0.075
lines(r_a * cos(ang), r_a * sin(ang), col = "#8a8a8a", lwd = 1.3)
text(0.090 * cos(theta / 2), 0.090 * sin(theta / 2),
     labels = expression(theta), col = "#52514e", cex = 1.15, adj = c(0, 0.35))

# Each side carries two short lines only - the vector and its squared length.
# The side lengths themselves go in the block at the top, because putting them
# on the sides made the hypotenuse's two lines run into each other and pushed
# the vertical leg's label off the panel.
text(a / 2, -0.013, adj = c(0.5, 1), col = col_reg, cex = 1.02,
     labels = expression(hat(y) - bar(y) * bold(1)))
text(a / 2, -0.036, adj = c(0.5, 1), col = col_reg, cex = 1.02,
     labels = sprintf("SSR = %.4f", SSR))

text(a + 0.013, b / 2 + 0.011, adj = c(0, 0.5), col = col_res, cex = 1.02,
     labels = expression(y - hat(y)))
text(a + 0.013, b / 2 - 0.012, adj = c(0, 0.5), col = col_res, cex = 1.02,
     labels = sprintf("SSE = %.4f", SSE))

# hypotenuse, labelled along it. The offset is taken along the perpendicular
# (-b, a)/c so the text sits parallel to the side at a constant distance.
px <- -b / c; py <- a / c
srt_h <- theta * 180 / pi
text(a / 2 + px * 0.034, b / 2 + py * 0.034, srt = srt_h, adj = c(0.5, 0),
     col = col_tot, cex = 1.02, labels = expression(y - bar(y) * bold(1)))
text(a / 2 + px * 0.013, b / 2 + py * 0.013, srt = srt_h, adj = c(0.5, 0),
     col = col_tot, cex = 1.02, labels = sprintf("SST = %.4f", SST))

# the three facts the picture is here to carry
text(-0.026, 0.272, adj = c(0, 1), col = "#52514e", cex = 1.04,
     labels = sprintf("SST = SSR + SSE:   %.4f = %.4f + %.4f", SST, SSR, SSE))
text(-0.026, 0.248, adj = c(0, 1), col = "#52514e", cex = 1.04,
     labels = sprintf("side lengths (hyp, base, height):   %.4f, %.4f, %.4f",
                      c, a, b))
text(-0.026, 0.224, adj = c(0, 1), col = "#52514e", cex = 1.04,
     labels = sprintf("cos²θ = SSR / SST = R² = %.4f", R2))

# --- right panel: the same split, counted in dimensions ---------------------
df_reg <- p
df_res <- n - p - 1
df_tot <- n - 1

plot(NA, xlim = c(-2.0, df_tot + 2.0), ylim = c(0, 1),
     axes = FALSE, xlab = "", ylab = "",
     main = "Degrees of freedom split the same way",
     cex.main = 1.1, font.main = 1)

# total bar on top
rect(0, 0.76, df_tot, 0.94, col = col_tot, border = NA)
text(df_tot / 2, 0.85, col = "#ffffff", cex = 1.08,
     labels = sprintf("SST:  n - 1 = %d", df_tot))

# the two pieces below, drawn to the same scale so the widths are comparable
rect(0, 0.44, df_reg, 0.62, col = col_reg, border = NA)
rect(df_reg, 0.44, df_tot, 0.62, col = col_res, border = NA)
text((df_reg + df_tot) / 2, 0.53, col = "#ffffff", cex = 1.08,
     labels = sprintf("SSE:  n - p - 1 = %d", df_res))

# the SSR block is only 3 of 29 units wide, too narrow to hold its own label
segments(df_reg / 2, 0.42, df_reg / 2, 0.34, col = col_reg, lwd = 1.4)
text(df_reg / 2, 0.31, adj = c(0.5, 1), col = col_reg, cex = 1.05,
     labels = sprintf("SSR:  p = %d", df_reg))

# dotted ticks showing the two blocks span exactly the same width as the total
segments(c(0, df_reg, df_tot), 0.64, c(0, df_reg, df_tot), 0.74,
         col = "#b9c2c8", lwd = 1.2, lty = 3)

text(df_tot / 2, 0.15, adj = c(0.5, 0.5), col = "#52514e", cex = 1.2,
     labels = sprintf("%d = %d + %d", df_tot, df_reg, df_res))

dev.off()
cat("\nfile written:", file.path(out, "fig-m03-df-decomposition.png"), "\n")
