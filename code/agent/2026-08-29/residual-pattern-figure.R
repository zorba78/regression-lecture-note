# Date        : 2026-08-29
# Description : Conceptual residual-pattern panel for chapter 5 (Diagnosis) of the
#               KINS lecture. Section 5.5.1 of the CNU lecture note lists the
#               shapes a residual plot can take and what each one accuses the
#               model of; the deck had the wording but no picture. Six patterns
#               are simulated so each shape is unambiguous:
#                 (a) random          - assumptions hold
#                 (b) megaphone       - variance grows with the fitted value
#                 (c) bow tie         - variance grows then shrinks
#                 (d) curved          - the straight line is the wrong shape
#                 (e) positive serial - neighbouring residuals repeat
#                 (f) negative serial - neighbouring residuals alternate
#               Panels (e) and (f) are LAG PLOTS (e_{t-1} on x, e_t on y), not
#               index plots. Two reasons, both checked in the console output
#               at the bottom of this script:
#                 - the correlation between neighbouring residuals is read as
#                   the tilt of one cloud, so the eye never has to trace a
#                   sequence across a wiggly line;
#                 - the residual-vs-fitted plot cannot show it at all, because
#                   e'yhat = y'(I-H)Hy = 0 exactly, so cor(e, yhat) = 0 for
#                   every OLS fit with an intercept.
#               Nothing here is estimated from data; the point of the figure is
#               to name the shapes, so the y axis carries no numbers.
#               Writes output/agent/2026-08-29/fig-m05-residual-patterns.png
# File        : residual-pattern-figure.R

set.seed(20260829)

out_dir <- "g:/Projects/regression-lecture-note/output/agent/2026-08-29"
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

n <- 160
x <- seq(0, 1, length.out = n)

## AR(1) series for the lag plots. Fewer points than the scatter panels so the
## cloud stays readable at slide size, and the first 50 draws are discarded
## because filter() starts the recursion at 0 and the transient is not AR(1).
ar1 <- function(rho, sd, len = 120, burn = 50) {
  s <- as.numeric(filter(rnorm(len + burn, 0, sd), rho, method = "recursive"))
  s[-seq_len(burn)]
}

## the six residual series, each scaled to a comparable visual range
pat <- list(
  random   = rnorm(n),
  megaphone = rnorm(n) * (0.25 + 1.9 * x),
  bowtie   = rnorm(n) * (0.25 + 2.6 * (0.5 - abs(x - 0.5))),
  curved   = 2.2 * (x - 0.5)^2 * 6 - 1.2 + rnorm(n, 0, 0.30),
  pos_ar   = ar1(0.85, 0.45),
  neg_ar   = ar1(-0.80, 0.55)
)

titles <- c(random    = "(a) Random: assumptions hold",
            megaphone = "(b) Megaphone: variance grows",
            bowtie    = "(c) Bow tie: variance grows then shrinks",
            curved    = "(d) Curved: the line is the wrong shape",
            pos_ar    = "(e) Neighbouring residuals rise together",
            neg_ar    = "(f) Neighbouring residuals alternate")
xlabs  <- c(random = "Fitted value", megaphone = "Fitted value",
            bowtie = "Fitted value", curved = "Fitted value",
            pos_ar = "", neg_ar = "")
verdict <- c(random    = "no action",
             megaphone = "weighted regression or a variance-stabilizing transform",
             bowtie    = "same family of remedies as (b)",
             curved    = "transform x or add a curved term",
             pos_ar    = "positive serial correlation: generalized least squares",
             neg_ar    = "negative serial correlation: generalized least squares")

png(file.path(out_dir, "fig-m05-residual-patterns.png"),
    width = 2000, height = 950, res = 150)
op <- par(mfrow = c(2, 3), mar = c(2.6, 2.8, 3.9, 0.8), cex.lab = 1.15,
          mgp = c(1.3, 0.5, 0))

for (k in names(pat)) {
  e <- pat[[k]]
  if (k %in% c("pos_ar", "neg_ar")) {
    ## lag plot: each point is one consecutive pair of residuals, so the
    ## correlation between them is the tilt of the cloud and no sequence has
    ## to be traced by eye. The drawn line is the least-squares slope through
    ## the origin, which equals the lag-1 autocorrelation printed below.
    e0 <- e[-length(e)]
    e1 <- e[-1]
    lim <- max(abs(e)) * c(-1.1, 1.1)
    plot(e0, e1, type = "n", xlim = lim, ylim = lim, xaxt = "n", yaxt = "n",
         xlab = expression(paste("Previous residual  ", e[t - 1])),
         ylab = expression(paste("Residual  ", e[t])))
    abline(h = 0, v = 0, col = "grey40", lwd = 1.2)
    abline(a = 0, b = sum(e0 * e1) / sum(e0^2), col = "#C44E52", lwd = 2.4)
    points(e0, e1, pch = 16, col = "#4C72B0", cex = 0.85)
  } else {
    ylim <- max(abs(e)) * c(-1.18, 1.18)
    plot(seq_along(e), e, type = "n", xlab = xlabs[[k]], ylab = "Residual",
         main = "", yaxt = "n", xaxt = "n", ylim = ylim)
    abline(h = 0, col = "grey40", lwd = 1.8)
    points(seq_along(e), e, pch = 16, col = "#4C72B0", cex = 0.75)
  }
  box()
  mtext(titles[[k]], side = 3, line = 2.1, cex = 0.95, font = 2)
  mtext(verdict[[k]], side = 3, line = 0.6, cex = 0.8, col = "#C44E52")
}
par(op)
dev.off()

cat("figure written:",
    file.path(out_dir, "fig-m05-residual-patterns.png"), "\n")

## Printed so the shapes are not merely asserted: the simulated spread in the
## first and last fifth of each series, which is what the eye is reading.
cat("\n=== spread in the first vs last fifth of each series ===\n")
for (k in names(pat)) {
  e <- pat[[k]]
  m  <- length(e)                    # the AR series are shorter than n
  i1 <- seq_len(m %/% 5)
  i2 <- (m - m %/% 5 + 1):m
  cat(sprintf("%-10s  sd first = %.2f   sd last = %.2f   lag-1 corr = %+.2f\n",
              k, sd(e[i1]), sd(e[i2]),
              sum(e[-1] * e[-length(e)]) / sum(e^2)))
}

## Why panels (e)-(f) are lag plots and not residual-vs-fitted plots.
## For OLS with an intercept, e'yhat = y'(I - H)H y = y'(H - H)y = 0 and
## mean(e) = 0, hence cor(e, yhat) = 0 exactly for EVERY data set - the
## residual-vs-fitted plot is blind to serial correlation by construction.
## Fit a model on strongly autocorrelated errors and read the two numbers.
cat("\n=== cor(residual, fitted) under strong positive autocorrelation ===\n")
xv  <- seq(0, 10, length.out = 120)
err <- ar1(0.85, 0.45)                       # lag-1 correlation about +0.85
fit <- lm(2 + 0.5 * xv + err ~ xv)
e   <- residuals(fit)
r   <- rstandard(fit)                        # studentized residual
cat(sprintf("cor(e, yhat)            = %+.3e   (algebraically exactly 0)\n",
            cor(e, fitted(fit))))
cat(sprintf("cor(studentized, yhat)  = %+.3e   (leverage reweighting does not\n%24srevive the signal either)\n",
            cor(r, fitted(fit)), ""))
cat(sprintf("lag-1 corr of e         = %+.3f    (the signal, visible only in order)\n",
            sum(e[-1] * e[-length(e)]) / sum(e^2)))
cat(sprintf("Durbin-Watson d         = %.3f     (2(1-r1) = %.3f)\n",
            sum(diff(e)^2) / sum(e^2),
            2 * (1 - sum(e[-1] * e[-length(e)]) / sum(e^2))))
