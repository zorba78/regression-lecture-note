# Date        : 2026-11-26
# Description : Reproduce, from the raw data, every data-derived number that
#               chapter 8 (Summary) of the KINS regression lecture quotes in its
#               slide bodies and speaker notes (::: notes), in slide order, and
#               write them to a three-column table (slide, quantity, value).
#               Chapter 8 has no figures; it only repeats results of chapters
#               3 to 7, so each number is recomputed here directly rather than
#               taken from the other chapters' scripts.
#
#               Deck : quarto/agent/2026-08-26/08-summary.qmd
#               Data : docs/data/ice.csv  - ice cream consumption, n = 30
#                        (identical copy of the CNU lecture-note chapter 7
#                        example ice.csv.csv, written by
#                        code/agent/2026-08-31/export-data.R)
#                      docs/data/physical-measurement.csv - alr4::physics
#                        (Weisberg 2014), x4 = 0.225, third column is the
#                        standard deviation SD of y, so the weight is 1/SD^2
#                      datasets::anscombe - Anscombe (1973) quartet, base R
#               Methods follow the earlier check scripts:
#                 verify-simple-regression-inference.R (ch 3),
#                 verify-multiple-regression.R (ch 4),
#                 check-ch05-links.R (ch 5), check-ch06-physics-wls.R (ch 6),
#                 dummy-interaction-fit.R (ch 7).
#               Output: output/agent/2026-11-26/reproduce/ch08/tab-ch08-numbers.csv
#               Run from the repository root:
#                 Rscript code/agent/2026-11-26/reproduce-ch08-summary.R
# File        : reproduce-ch08-summary.R

out_dir <- "output/agent/2026-11-26/reproduce/ch08"
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

ice  <- read.csv("docs/data/ice.csv")
phys <- read.csv("docs/data/physical-measurement.csv")
n    <- nrow(ice)                                   # 30 observation periods

## ---- Chapter 3: simple regression IC ~ temp ------------------------------
# Sample covariance  cov(y, x) = sum((y - ybar)(x - xbar)) / (n - 1)
# Correlation        r = cov(y, x) / (s_y s_x)
# Slope, intercept   b1 = Sxy / Sxx,  b0 = ybar - b1 xbar
# R^2 (formula 5)    1 - sum(e^2) / sum((y - ybar)^2); equals r^2 with one x
y <- ice$IC; x <- ice$temp
cov_yx <- sum((y - mean(y)) * (x - mean(x))) / (n - 1)
r      <- cov_yx / (sd(y) * sd(x))
b1     <- sum((y - mean(y)) * (x - mean(x))) / sum((x - mean(x))^2)
b0     <- mean(y) - b1 * mean(x)
e1     <- y - (b0 + b1 * x)
R2_1   <- 1 - sum(e1^2) / sum((y - mean(y))^2)
cat("ch3: cov =", cov_yx, " r =", r, " r^2 =", r^2, "\n")
cat("     b0 =", b0, " b1 =", b1, " R2 =", R2_1, " R2 - r^2 =", R2_1 - r^2, "\n")
cat("     lm() check: coef =", coef(lm(IC ~ temp, data = ice)),
    " R2 =", summary(lm(IC ~ temp, data = ice))$r.squared, "\n")

## ---- Chapter 4: full model IC ~ price + income + temp ---------------------
# adj R^2 = 1 - {SSE / (n - p - 1)} / {SST / (n - 1)},  p = 3
fit_full <- lm(IC ~ price + income + temp, data = ice)
R2_full  <- summary(fit_full)$r.squared
aR2_full <- summary(fit_full)$adj.r.squared
cat("ch4: full model R2 =", R2_full, " adj R2 =", aR2_full, "\n")

## ---- Chapter 5: Cook's distance of the full model, backward elimination ---
# D_i = r_i^2 h_ii / {(p + 1)(1 - h_ii)}, r_i the standardized residual.
# step() drops one predictor at a time while extractAIC = n ln(SSE/n) + 2(p+1)
# (the AIC* scale of the chapter 5 deck) decreases.
D        <- cooks.distance(fit_full)
fit_sel  <- step(fit_full, direction = "backward", trace = 0)
sel_vars <- paste(attr(terms(fit_sel), "term.labels"), collapse = ", ")
cat("ch5: max Cook D =", max(D), " at obs", which.max(D),
    "; backward elimination keeps:", sel_vars, "\n")

## ---- Chapter 6: physics calibration data, WLS with w = 1/SD^2 -------------
# Lack-of-fit statistic X^2 = sum(r_w^2), r_w = (y - yhat)/SD = sqrt(w) e.
# With SD known and the model correct, X^2 ~ chi-square(n - p - 1).
w        <- 1 / phys$SD^2
fit_lin  <- lm(y ~ x, data = phys, weights = w)
fit_quad <- lm(y ~ x + I(x^2), data = phys, weights = w)
X2_lin   <- sum(weighted.residuals(fit_lin)^2);  df_lin  <- df.residual(fit_lin)
X2_quad  <- sum(weighted.residuals(fit_quad)^2); df_quad <- df.residual(fit_quad)
p_lin    <- pchisq(X2_lin,  df_lin,  lower.tail = FALSE)
p_quad   <- pchisq(X2_quad, df_quad, lower.tail = FALSE)
cat("ch6: linear    X2 =", X2_lin,  " df =", df_lin,  " P(chi2 > X2) =", p_lin,  "\n")
cat("     quadratic X2 =", X2_quad, " df =", df_quad, " P(chi2 > X2) =", p_quad, "\n")
# Sign pattern behind the "U-shaped weighted residuals" remark in the notes
cat("     weighted residuals, linear   :", sprintf("%.2f", weighted.residuals(fit_lin)), "\n")
cat("     weighted residuals, quadratic:", sprintf("%.2f", weighted.residuals(fit_quad)), "\n")

## ---- Chapter 7: parallel-lines model with two year dummies ----------------
# IC = b0 + b1 temp + b2 d1 + b3 d2; factor(year) creates d1, d2 (year 0 base)
fit_dum <- lm(IC ~ temp + factor(year), data = ice)
R2_dum  <- summary(fit_dum)$r.squared
aR2_dum <- summary(fit_dum)$adj.r.squared
cat("ch7: dummy model R2 =", R2_dum, " adj R2 =", aR2_dum,
    " number of dummies =", length(coef(fit_dum)) - 2, "\n")

## ---- Checklist slide: Anscombe quartet, same fitted line for all four -----
ans <- sapply(1:4, function(k) coef(lm(anscombe[[paste0("y", k)]] ~ anscombe[[paste0("x", k)]])))
cat("Anscombe intercepts:", ans[1, ], "\n")
cat("Anscombe slopes    :", ans[2, ], "\n")

## ---- Table in slide order --------------------------------------------------
s2 <- "핵심 공식 정리: 적합의 뼈대"
s3 <- "핵심 공식 정리: 평가와 확장"
s5 <- "강의 구성 요약"
s6 <- "실무 체크리스트: 1~4단계"
tab <- data.frame(
  slide = c(s2, rep(s3, 3), rep(s5, 22), rep(s6, 8)),
  quantity = c(
    "notes: number of ice cream observations n",
    "notes: correlation r of IC and temp", "notes: r^2", "notes: R^2 of IC ~ temp",
    "ch3 sample covariance cov(IC, temp)", "ch3 correlation r",
    "ch3 intercept b0", "ch3 slope b1 (temp)", "ch3 R^2", "ch3 R^2 - r^2",
    "ch4 full model R^2", "ch4 full model adjusted R^2",
    "ch5 max Cook's distance (full model)", "ch5 observation with max Cook's distance",
    "ch5 predictors kept by backward elimination (AIC)",
    "ch6 WLS linear X^2", "ch6 WLS linear df", "ch6 WLS linear P(chi2 > X^2)",
    "ch6 WLS quadratic X^2", "ch6 WLS quadratic df", "ch6 WLS quadratic P(chi2 > X^2)",
    "ch7 parallel-lines model R^2", "ch7 parallel-lines model adjusted R^2",
    "ch7 number of year dummies",
    "notes: percent of variation explained, IC ~ temp (100 R^2)",
    "notes: percent of variation explained, full model (100 R^2)",
    paste("notes: Anscombe set", 1:4, "intercept"),
    paste("notes: Anscombe set", 1:4, "slope")),
  value = c(
    n, r, r^2, R2_1,
    cov_yx, r, b0, b1, R2_1, R2_1 - r^2,
    R2_full, aR2_full,
    max(D), which.max(D), sel_vars,
    X2_lin, df_lin, p_lin, X2_quad, df_quad, p_quad,
    R2_dum, aR2_dum, length(coef(fit_dum)) - 2,
    100 * R2_1, 100 * R2_full,
    ans[1, ], ans[2, ])
)
write.csv(tab, file.path(out_dir, "tab-ch08-numbers.csv"), row.names = FALSE,
          fileEncoding = "UTF-8")
cat("\nwrote", file.path(out_dir, "tab-ch08-numbers.csv"), "\n")
print(tab[, c("quantity", "value")], row.names = FALSE)
