# Date        : 2026-08-24
# Description : Figures and numbers for the attenuation-curve example added to
#               the "Weighted Regression" chapter, at the request of the
#               institute running the lecture (energy attenuation curves).
#
#               The point of the example: an attenuation curve is a weighted
#               regression problem whose weights are known in advance, not
#               estimated. Beer-Lambert gives N(x) = N0 exp(-mu x); taking logs
#               makes it linear, and because counts are Poisson the delta
#               method gives Var(log N) ~= 1/N. So the log-linear fit has a
#               known, unequal error variance and the weight is w_i = N_i.
#
#               (a) fig-a01: the counts, with +-1 SD bars on the log scale, and
#                   the variance of log N against absorber thickness.
#               (b) fig-a02: OLS vs WLS fits on one experiment, and the
#                   sampling distribution of mu-hat over 2000 repeats.
#
#               Everything here is SIMULATED from Beer-Lambert plus Poisson
#               counting; mu = 1.25 /cm is an input to the simulation, not a
#               measured constant for any particular material. The slides say
#               so. Run from the project root:
#                 Rscript code/agent/2026-08-24/make-attenuation-figures.R
# File        : make-attenuation-figures.R

FIG_DIR <- "output/agent/2026-08-24"
dir.create(FIG_DIR, recursive = TRUE, showWarnings = FALSE)

COL_BLUE   <- "#2a78d6"
COL_ORANGE <- "#eb6834"
COL_RED    <- "#e34948"
COL_AQUA   <- "#1baf7a"
INK        <- "#0b0b0b"
INK2       <- "#52514e"
GRID_C     <- "#e1e0d9"
FILL_GREY  <- "#d8d7d2"

open_png <- function(file, w = 2000, h = 1000, res = 170) {
  png(file.path(FIG_DIR, file), width = w, height = h, res = res)
}

set.seed(20260824)

MU <- 1.25          # true attenuation coefficient (per cm), simulation input
N0 <- 20000         # counts with no absorber
XG <- seq(0, 4, by = 0.4)

## ---- one experiment ----------------------------------------------------

N    <- rpois(length(XG), N0 * exp(-MU * XG))
dat  <- data.frame(x = XG, N = N, logN = log(N), varlog = 1 / N)
fols <- lm(logN ~ x, data = dat)
fwls <- lm(logN ~ x, data = dat, weights = dat$N)

cat("===== one simulated attenuation experiment =====\n")
print(cbind(dat[c("x", "N", "logN")],
            varlog = round(dat$varlog, 6),
            sd_log = round(sqrt(dat$varlog), 4)))
cat(sprintf("\nspread of Var(log N): %.6f at x = 0  ->  %.6f at x = %.1f  (%.0f-fold)\n",
            dat$varlog[1], dat$varlog[nrow(dat)], max(XG),
            dat$varlog[nrow(dat)] / dat$varlog[1]))
cat(sprintf("mu-hat  OLS = %.4f   WLS = %.4f   (true %.2f)\n",
            -coef(fols)[2], -coef(fwls)[2], MU))

## ---- fig-a01: where the unequal variance comes from --------------------

open_png("fig-a01-attenuation-variance.png")
par(mfrow = c(1, 2), mar = c(4.5, 4.8, 3.5, 1),
    col.axis = INK2, col.lab = INK, fg = INK2)

sdl <- sqrt(dat$varlog)
plot(dat$x, dat$logN, pch = 16, col = COL_BLUE, cex = 1.1,
     ylim = range(dat$logN - 3 * sdl, dat$logN + 3 * sdl),
     panel.first = grid(col = GRID_C, lty = 1),
     main = "(a) log counts, with +-3 SD bars",
     xlab = "Absorber thickness (cm)", ylab = "log N")
arrows(dat$x, dat$logN - 3 * sdl, dat$x, dat$logN + 3 * sdl,
       angle = 90, code = 3, length = 0.04, col = COL_ORANGE, lwd = 2)
abline(fwls, col = COL_BLUE, lwd = 2, lty = 2)
legend("topright", bty = "n", pch = c(16, NA), lwd = c(NA, 2),
       col = c(COL_BLUE, COL_ORANGE),
       legend = c("log N", "+-3 SD, SD = sqrt(1/N)"), text.col = INK)

plot(dat$x, dat$varlog, type = "b", pch = 16, lwd = 2, cex = 1.1,
     col = COL_RED,
     panel.first = grid(col = GRID_C, lty = 1),
     main = "(b) the error variance is not constant",
     xlab = "Absorber thickness (cm)",
     ylab = expression(paste("Var(log N)  ", symbol("\273"), "  1/N")))
dev.off()

## ---- fig-a02: OLS vs WLS ----------------------------------------------

sim_one <- function() {
  Ns <- rpois(length(XG), N0 * exp(-MU * XG))
  k  <- Ns > 0
  d  <- data.frame(x = XG[k], N = Ns[k], logN = log(Ns[k]))
  c(-coef(lm(logN ~ x, data = d))[2],
    -coef(lm(logN ~ x, data = d, weights = d$N))[2])
}
res <- replicate(2000, sim_one())

open_png("fig-a02-ols-vs-wls.png")
par(mfrow = c(1, 2), mar = c(4.5, 4.8, 3.5, 1),
    col.axis = INK2, col.lab = INK, fg = INK2)

plot(dat$x, dat$logN, pch = 16, col = adjustcolor(INK2, alpha.f = 0.7), cex = 1.2,
     panel.first = grid(col = GRID_C, lty = 1),
     main = "(a) one experiment: the two fits nearly coincide",
     xlab = "Absorber thickness (cm)", ylab = "log N")
abline(fols, col = COL_ORANGE, lwd = 3, lty = 2)
abline(fwls, col = COL_BLUE,   lwd = 3)
legend("topright", bty = "n", lwd = 3, lty = c(2, 1),
       col = c(COL_ORANGE, COL_BLUE),
       legend = c(sprintf("OLS   mu-hat = %.3f", -coef(fols)[2]),
                  sprintf("WLS   mu-hat = %.3f", -coef(fwls)[2])),
       text.col = INK)

rng <- range(res)
b   <- seq(rng[1], rng[2], length.out = 45)
h1  <- hist(res[1, ], breaks = b, plot = FALSE)
h2  <- hist(res[2, ], breaks = b, plot = FALSE)
plot(h1, col = adjustcolor(COL_ORANGE, alpha.f = 0.45), border = "white",
     ylim = c(0, max(h1$counts, h2$counts)),
     main = "(b) sampling distribution of mu-hat, 2000 repeats",
     xlab = expression(hat(mu)), ylab = "Frequency")
plot(h2, col = adjustcolor(COL_BLUE, alpha.f = 0.55), border = "white", add = TRUE)
abline(v = MU, col = COL_RED, lwd = 3)
legend("topright", bty = "n", fill = c(adjustcolor(COL_ORANGE, alpha.f = 0.45),
                                       adjustcolor(COL_BLUE, alpha.f = 0.55)),
       border = "white",
       legend = c(sprintf("OLS   SD = %.4f", sd(res[1, ])),
                  sprintf("WLS   SD = %.4f", sd(res[2, ]))),
       text.col = INK)
text(MU, max(h1$counts, h2$counts) * 0.55, labels = " true mu",
     col = COL_RED, pos = 4)
dev.off()

cat("\n===== 2000 repeats =====\n")
for (i in 1:2)
  cat(sprintf("  %-3s bias %+.4f   SD %.4f   RMSE %.4f\n", c("OLS", "WLS")[i],
              mean(res[i, ]) - MU, sd(res[i, ]),
              sqrt(mean((res[i, ] - MU)^2))))
cat(sprintf("  variance ratio OLS/WLS = %.2f\n", var(res[1, ]) / var(res[2, ])))
