# Date        : 2026-08-27
# Description : Figure and numbers for the two new maximum-likelihood slides of
#               03-simple-linear-regression.qmd.
#
#               Left panel  - the normal-error model made visible: the fitted
#                             line with a normal density standing on it at three
#                             temperatures.  Each observation is drawn from the
#                             bell perched at its own x, all bells having the
#                             same width sigma.  This is the picture the
#                             likelihood is built from.
#               Right panel - the log-likelihood as the candidate slope varies,
#                             with the intercept profiled out (b0 = ybar - b1
#                             xbar) and sigma^2 held at its ML value.  Then
#                                 l(b1) = -n/2 log(2 pi s2) - S(b1) / (2 s2)
#                             which is the sum-of-squares parabola of
#                             fig-ls02-criterion-curve turned upside down: the
#                             peak of one sits exactly over the bottom of the
#                             other.  That is the whole argument of the slide.
#
#               The console output is the derivation behind every number placed
#               on the slides: beta hats from lm(), the same beta hats recovered
#               by numerically maximising the likelihood with optim(), the two
#               sigma^2 estimates (SSE/(n-2) and SSE/n) and the maximised log
#               likelihood cross-checked against logLik().
#
#               Data: references/cnu-regression-lecture-note/강의노트/R 예제/
#               7장/ice.csv.csv (n = 30), model IC ~ temp, the same simple
#               regression used throughout chapter 3.
#
#               Run from the project root:
#                 Rscript code/agent/2026-08-27/make-likelihood-figure.R
# File        : make-likelihood-figure.R

FIG_DIR <- "output/agent/2026-08-27"
dir.create(FIG_DIR, recursive = TRUE, showWarnings = FALSE)

COL_BLUE   <- "#2a78d6"
COL_ORANGE <- "#eb6834"
INK        <- "#0b0b0b"
INK2       <- "#52514e"
GRID_C     <- "#e1e0d9"

ice <- read.csv("references/cnu-regression-lecture-note/강의노트/R 예제/7장/ice.csv.csv",
                stringsAsFactors = FALSE)

fit <- lm(IC ~ temp, data = ice)
n   <- nrow(ice)
SSE <- sum(resid(fit)^2)

b0 <- coef(fit)[1]
b1 <- coef(fit)[2]

s2_ls <- SSE / (n - 2)     # unbiased, the one already on the standard-error slide
s2_ml <- SSE / n           # maximum likelihood, divides by n

cat(sprintf("n = %d\n", n))
cat(sprintf("beta0 = %.6f, beta1 = %.6f  (lm)\n", b0, b1))
cat(sprintf("SSE = %.6f\n", SSE))
cat(sprintf("sigma2 LS = SSE/(n-2) = %.8f   sigma = %.6f\n", s2_ls, sqrt(s2_ls)))
cat(sprintf("sigma2 ML = SSE/n     = %.8f   sigma = %.6f\n", s2_ml, sqrt(s2_ml)))
cat(sprintf("ratio ML/LS = (n-2)/n = %.6f\n", s2_ml / s2_ls))

# The log-likelihood at its maximum, from the closed form, cross-checked with R
loglik <- function(b0, b1, s2) {
  r <- ice$IC - b0 - b1 * ice$temp
  -n / 2 * log(2 * pi) - n / 2 * log(s2) - sum(r^2) / (2 * s2)
}
cat(sprintf("\nmax log-likelihood (formula) = %.4f\n", loglik(b0, b1, s2_ml)))
cat(sprintf("max log-likelihood (logLik)  = %.4f\n", as.numeric(logLik(fit))))

# Recover the estimates by numerical maximisation, i.e. without ever writing
# down the normal equations.  If MLE and least squares really coincide, optim
# must land on the lm() coefficients.
nll <- function(p) -loglik(p[1], p[2], exp(p[3]))
opt <- optim(c(0, 0, log(var(ice$IC))), nll,
             method = "Nelder-Mead",
             control = list(maxit = 20000, reltol = 1e-14))
cat(sprintf("\noptim  beta0 = %.6f, beta1 = %.6f, sigma2 = %.8f\n",
            opt$par[1], opt$par[2], exp(opt$par[3])))
cat(sprintf("difference from lm(): beta0 %.2e, beta1 %.2e, sigma2 %.2e\n",
            abs(opt$par[1] - b0), abs(opt$par[2] - b1),
            abs(exp(opt$par[3]) - s2_ml)))

## ---------------------------------------------------------------------------
## figure
## ---------------------------------------------------------------------------
png(file.path(FIG_DIR, "fig-s01-likelihood.png"),
    width = 2100, height = 950, res = 150)
par(mfrow = c(1, 2), mar = c(4.3, 4.6, 3.0, 1),
    col.axis = INK2, col.lab = INK, fg = INK2)

## left: the model, one bell per x -------------------------------------------
sig    <- sqrt(s2_ml)
x_show <- c(30, 50, 70)
SPAN   <- 2.6                              # each bell drawn over mu +/- 2.6 sigma
scale  <- 8 / dnorm(0, sd = sig)           # tallest bell spans about 8 x-units

# The bells reach further in y than the data do, so widen the panel to hold them
mu_show <- b0 + b1 * x_show
ylim <- range(ice$IC, mu_show - SPAN * sig, mu_show + SPAN * sig)
xlim <- c(min(ice$temp) - 1, max(ice$temp) + 9)

plot(ice$temp, ice$IC, type = "n", xlim = xlim, ylim = ylim,
     main = "Each observation is drawn from its own bell",
     xlab = "Mean temperature (Fahrenheit)",
     ylab = "Ice cream consumption (pints per capita)")
grid(col = GRID_C, lty = 1); box(col = INK2)
abline(fit, col = COL_BLUE, lwd = 3)

# A density drawn sideways at x0: the curve x0 + scale * dnorm(y) traced over y.
for (x0 in x_show) {
  mu <- b0 + b1 * x0
  yy <- seq(mu - SPAN * sig, mu + SPAN * sig, length.out = 200)
  lines(x0 + scale * dnorm(yy, mu, sig), yy, col = COL_ORANGE, lwd = 2.4)
  segments(x0, mu - SPAN * sig, x0, mu + SPAN * sig, col = INK2, lty = 3)
  points(x0, mu, pch = 16, col = COL_BLUE, cex = 1.3)
}
points(ice$temp, ice$IC, pch = 16,
       col = adjustcolor(INK2, alpha.f = 0.55), cex = 1.2)
legend("topleft", bty = "o", bg = "white", box.col = GRID_C,
       lwd = c(3, 2.4), col = c(COL_BLUE, COL_ORANGE),
       legend = c("Fitted line: the mean at each x",
                  expression(paste("Normal density, same ", sigma, " everywhere"))),
       text.col = INK)

## right: the log-likelihood as the slope varies ------------------------------
grid_b1 <- seq(b1 - 0.0020, b1 + 0.0020, length.out = 400)
ll <- sapply(grid_b1, function(bb) {
  a0 <- mean(ice$IC) - bb * mean(ice$temp)      # intercept profiled out
  loglik(a0, bb, s2_ml)
})
plot(grid_b1, ll, type = "n",
     main = "Log-likelihood over candidate slopes",
     xlab = expression(paste("Candidate slope  ", beta[1])),
     ylab = "Log-likelihood")
grid(col = GRID_C, lty = 1); box(col = INK2)
lines(grid_b1, ll, col = COL_BLUE, lwd = 3.2)
abline(v = b1, col = COL_ORANGE, lwd = 2.4, lty = 2)
points(b1, loglik(b0, b1, s2_ml), pch = 16, col = COL_ORANGE, cex = 1.8)
text(b1, min(ll) + 0.28 * diff(range(ll)),
     labels = sprintf("peak at %.5f", b1), pos = 4, col = INK, cex = 0.95)
dev.off()

cat("\nwritten:", file.path(FIG_DIR, "fig-s01-likelihood.png"), "\n")
