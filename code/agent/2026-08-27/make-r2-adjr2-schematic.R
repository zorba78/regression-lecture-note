# Date        : 2026-08-27
# Description : SCHEMATIC figure for the chapter 4 slide on R2, adjusted R2 and
#               SSE. Replaces an earlier version drawn from the ice cream data,
#               which could not show the point: all three of its predictors
#               carry information, so adjusted R2 rises at every step there and
#               the characteristic downturn never appears.
#
#               This figure is a CONCEPTUAL diagram, not a fit to data. Only the
#               R2 curve is stipulated - a rise that saturates near 0.80 plus a
#               small linear creep, which is what an uninformative predictor
#               buys. Everything else is DERIVED from it with the exact
#               definitions, so the three quantities stay mutually consistent:
#                 SSE      = SST * (1 - R2)                with SST fixed
#                 adj R2   = 1 - (1 - R2) * (n - 1)/(n - p - 1)
#               The downturn in adjusted R2 is therefore a consequence of the
#               formulas, not something drawn by hand.
# File        : make-r2-adjr2-schematic.R

options(digits = 10)

n    <- 20           # nominal sample size; the penalty (n-1)/(n-p-1) bites
                     # harder at small n, which is what makes the downturn legible
SST  <- 1            # SST is fixed by the data, so its scale is arbitrary here
pmax <- 10
pstar <- 4           # where the useful predictors run out, for the annotation

p  <- 0:pmax
# Stipulated: steep gain while the predictors carry information, then a plateau
# with only the small creep an uninformative variable always provides.
R2 <- 0.80 * (1 - exp(-p / 1.0)) + 0.0008 * p
SSE   <- SST * (1 - R2)
adjR2 <- 1 - (1 - R2) * (n - 1) / (n - p - 1)

tab <- data.frame(p = p, R2 = R2, adjR2 = adjR2, SSE = SSE)
print(tab, row.names = FALSE)
cat("\nadjusted R2 peaks at p =", p[which.max(adjR2)],
    " value =", max(adjR2), "\n")
cat("R2 is non-decreasing?  ", all(diff(R2) >= 0), "\n")
cat("SSE is non-increasing? ", all(diff(SSE) <= 0), "\n")
cat("adj R2 falls after the peak? ",
    all(diff(adjR2[which.max(adjR2):length(adjR2)]) < 0), "\n")

out <- "../../../output/agent/2026-08-27"
dir.create(out, showWarnings = FALSE, recursive = TRUE)
png(file.path(out, "fig-m01-r2-adjr2-sse.png"),
    width = 2100, height = 950, res = 150)

par(mfrow = c(1, 2), mar = c(4.6, 5.2, 3.2, 1.6), family = "sans",
    cex.lab = 1.15, cex.axis = 1.05)

shade <- function() {
  # Mark the region where the predictors being added are useless.
  u <- par("usr")
  rect(pstar, u[3], u[2], u[4], col = "#f4f2ee", border = NA)
  abline(v = pstar, lty = 2, col = "#a8a8a8")
}

# --- left panel: SSE ------------------------------------------------------
plot(p, SSE, type = "n", las = 1, bty = "n", xaxt = "n",
     xlab = "Number of predictors p", ylab = "SSE",
     main = "SSE can only fall", cex.main = 1.2, font.main = 1,
     ylim = c(0, SST * 1.02))
shade()
axis(1, at = p)
lines(p, SSE, col = "#e8552d", lwd = 3)
points(p, SSE, pch = 19, col = "#e8552d", cex = 1.3)
text(pstar + 0.15, SST * 0.93, adj = c(0, 0.5), col = "#7a7a7a", cex = 1.02,
     labels = "useless predictors added")

# --- right panel: R2 and adjusted R2 --------------------------------------
plot(p, R2, type = "n", las = 1, bty = "n", xaxt = "n",
     xlab = "Number of predictors p", ylab = "",
     main = "R-squared cannot fall, adjusted R-squared can",
     cex.main = 1.2, font.main = 1, ylim = c(0, 0.95))
shade()
axis(1, at = p)
lines(p, R2, col = "#3b9ab2", lwd = 3)
points(p, R2, pch = 19, col = "#3b9ab2", cex = 1.3)
lines(p, adjR2, col = "#c1663f", lwd = 3, lty = 2)
points(p, adjR2, pch = 17, col = "#c1663f", cex = 1.3)

kmax <- which.max(adjR2)
points(p[kmax], adjR2[kmax], pch = 1, col = "#c1663f", cex = 3.0, lwd = 2.5)
arrows(p[kmax] - 2.2, adjR2[kmax] + 0.14, p[kmax] - 0.35, adjR2[kmax] + 0.035,
       length = 0.10, col = "#8a8a8a", lwd = 1.5)
text(p[kmax] - 2.3, adjR2[kmax] + 0.165, adj = c(0.5, 0), col = "#52514e",
     cex = 1.05, labels = "peak: best model size")

legend("bottomright", bty = "n", cex = 1.08, inset = c(0.02, 0.02),
       legend = c("R-squared", "adjusted R-squared"),
       lty = c(1, 2), lwd = c(3, 3), pch = c(19, 17),
       col = c("#3b9ab2", "#c1663f"))

dev.off()
cat("\nfile written:", file.path(out, "fig-m01-r2-adjr2-sse.png"), "\n")
