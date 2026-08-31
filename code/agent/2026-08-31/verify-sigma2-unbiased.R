# Date        : 2026-08-31
# Description : Check the claim added to chapter 3 that the least squares
#               estimator of the error variance is unbiased,
#                 E(SSE) = (n - 2) * sigma^2   =>   E(SSE/(n-2)) = sigma^2,
#               and that the maximum likelihood version SSE/n is therefore
#               biased by the factor (n-2)/n, which the chapter already
#               asserts on the "최대가능도 추정: 결과" slide.
#               Three checks:
#                 (1) the algebraic identity used in step 1 of the slide,
#                     sum(e_i^2) = Syy - b1^2 * Sxx, on the ice cream data;
#                 (2) the numbers quoted on the slide (Syy, SSR, SSE,
#                     sigma^2 hat, sigma hat);
#                 (3) a simulation with a known sigma^2: the model fitted to
#                     the ice cream data is taken as the truth and the
#                     experiment repeated, so E(SSE/(n-2)) can be compared
#                     with the sigma^2 that generated the data.
#
#               Data: references/cnu-regression-lecture-note/강의노트/
#               R 예제/7장/ice.csv.csv (n = 30 four-week periods).
#
#               Run from the project root:
#                 Rscript code/agent/2026-08-31/verify-sigma2-unbiased.R
# File        : verify-sigma2-unbiased.R

options(digits = 10)

ice <- read.csv("references/cnu-regression-lecture-note/강의노트/R 예제/7장/ice.csv.csv",
                stringsAsFactors = FALSE)
x <- ice$temp
y <- ice$IC
n <- length(x)

fit <- lm(y ~ x)
b0  <- coef(fit)[1]
b1  <- coef(fit)[2]
Sxx <- sum((x - mean(x))^2)
Syy <- sum((y - mean(y))^2)
SSE <- sum(resid(fit)^2)
SSR <- b1^2 * Sxx

cat("=== (1) identity  sum(e^2) = Syy - b1^2 * Sxx ===\n")
cat(sprintf("Syy = %.6f, b1^2*Sxx = %.6f, difference = %.6f, SSE = %.6f, gap = %.3e\n\n",
            Syy, SSR, Syy - SSR, SSE, abs((Syy - SSR) - SSE)))

cat("=== (2) numbers quoted on the slide ===\n")
cat(sprintf("n = %d, n - 2 = %d\n", n, n - 2))
cat(sprintf("Syy = SST = %.6f, SSR = %.6f, SSE = %.6f\n", Syy, SSR, SSE))
s2 <- SSE / (n - 2)
cat(sprintf("sigma^2 hat = SSE/(n-2) = %.9f, sigma hat = %.7f\n", s2, sqrt(s2)))
cat(sprintf("compare with lm: sigma hat = %.7f, difference = %.3e\n\n",
            summary(fit)$sigma, abs(sqrt(s2) - summary(fit)$sigma)))

cat("=== (3) simulation with sigma^2 known ===\n")
# Take the fitted model as the truth, so sigma^2 is known and E(SSE) can be
# compared with (n-2)*sigma^2 rather than merely asserted.
set.seed(2026)
B  <- 50000
mu <- b0 + b1 * x
sse <- replicate(B, sum(resid(lm(mu + rnorm(n, 0, sqrt(s2)) ~ x))^2))
cat(sprintf("true sigma^2 used            = %.9f\n", s2))
cat(sprintf("mean(SSE) over %d reps    = %.9f\n", B, mean(sse)))
cat(sprintf("(n-2)*sigma^2                = %.9f\n", (n - 2) * s2))
cat(sprintf("mean(SSE/(n-2))              = %.9f   ratio to sigma^2 = %.5f\n",
            mean(sse) / (n - 2), mean(sse) / (n - 2) / s2))
cat(sprintf("mean(SSE/n)  (ML version)    = %.9f   ratio to sigma^2 = %.5f",
            mean(sse) / n, mean(sse) / n / s2))
cat(sprintf("   [(n-2)/n = %.5f]\n", (n - 2) / n))
