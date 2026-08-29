# Date        : 2026-08-28
# Description : Fit results and fitted lines for the interaction model of
#               chapter 7 (Dummy Variable). The deck defines the model
#                 IC = b0 + b1*temp + b2*d1 + b3*d2 + b4*temp*d1 + b5*temp*d2
#               but stops at the definition. This script fits it on the ice cream
#               data, prints the coefficient table, splits the fit into the three
#               year-specific lines, and tests the interaction block against the
#               parallel-lines model with a partial F test, so the slide can say
#               whether the extra two coefficients are worth their cost.
#               Writes output/agent/2026-08-28/fig-m07-interaction-lines.png
#               Data source: references/cnu-regression-lecture-note/강의노트/
#                            R 예제/7장/ice.csv.csv
# File        : dummy-interaction-fit.R

root    <- "g:/Projects/regression-lecture-note"
in_csv  <- file.path(root, "references/cnu-regression-lecture-note",
                     "강의노트/R 예제/7장/ice.csv.csv")
out_dir <- file.path(root, "output/agent/2026-08-28")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

ice <- read.csv(in_csv, header = TRUE)
ice$yr <- factor(ice$year)                    # 0 = baseline, 1, 2
n <- nrow(ice)
cat("=== data ===\n")
print(table(ice$yr))
cat("n =", n, "\n\n")

## ---------------------------------------------------------------------------
## 1. The two models. R's `temp * yr` expands to temp + yr + temp:yr, which is
##    exactly the six-coefficient model written on the slide.
## ---------------------------------------------------------------------------
fit_par <- lm(IC ~ temp + yr, data = ice)          # parallel lines, 4 coef
fit_int <- lm(IC ~ temp * yr, data = ice)          # interaction,    6 coef

cat("=== 1. parallel-lines model (for reference) ===\n")
print(round(summary(fit_par)$coefficients, 6))
cat("R^2 =", round(summary(fit_par)$r.squared, 4),
    " adj R^2 =", round(summary(fit_par)$adj.r.squared, 4),
    " residual SE =", round(summary(fit_par)$sigma, 5), "\n\n")

cat("=== 2. interaction model ===\n")
si <- summary(fit_int)
print(round(si$coefficients, 6))
cat("R^2 =", round(si$r.squared, 4),
    " adj R^2 =", round(si$adj.r.squared, 4),
    " residual SE =", round(si$sigma, 5),
    " df =", si$df[2], "\n\n")

## ---------------------------------------------------------------------------
## 2. Split the six coefficients into the three year-specific lines.
##    year = 0 : b0            + b1            * temp
##    year = 1 : (b0 + b2)     + (b1 + b4)     * temp
##    year = 2 : (b0 + b3)     + (b1 + b5)     * temp
## ---------------------------------------------------------------------------
b <- coef(fit_int)
lines_tab <- data.frame(
  year      = c(0, 1, 2),
  intercept = c(b[1], b[1] + b[3], b[1] + b[4]),
  slope     = c(b[2], b[2] + b[5], b[2] + b[6]),
  row.names = NULL)
cat("=== 3. the three fitted lines ===\n")
print(round(lines_tab, 6))

## cross-check: fitting each year separately must give the same lines
cat("\ncross-check, separate fit per year:\n")
chk <- t(sapply(levels(ice$yr), function(g) coef(lm(IC ~ temp, ice[ice$yr == g, ]))))
print(round(chk, 6))
cat("max abs difference =",
    max(abs(chk - as.matrix(lines_tab[, c("intercept", "slope")]))), "\n\n")

## ---------------------------------------------------------------------------
## 3. Is the interaction block worth two extra coefficients?
## ---------------------------------------------------------------------------
cat("=== 4. partial F test: parallel vs interaction ===\n")
av <- anova(fit_par, fit_int)
print(av)
cat("\nF =", round(av$F[2], 4), " p =", round(av$`Pr(>F)`[2], 4), "\n")
cat("AIC  parallel =", round(AIC(fit_par), 3),
    "  interaction =", round(AIC(fit_int), 3), "\n")
cat("adj R^2  parallel =", round(summary(fit_par)$adj.r.squared, 4),
    "  interaction =", round(si$adj.r.squared, 4), "\n\n")

## ---------------------------------------------------------------------------
## 4. Figure: the three fitted lines from the interaction model, with the
##    parallel-lines fit drawn faintly so the difference is visible
## ---------------------------------------------------------------------------
cols <- c("#4C72B0", "#DD8452", "#55A868")     # year 0, 1, 2
png(file.path(out_dir, "fig-m07-interaction-lines.png"),
    width = 2100, height = 900, res = 150)
op <- par(mfrow = c(1, 2), mar = c(4.4, 4.6, 3.0, 1.0), cex.axis = 1.05,
          cex.lab = 1.15, cex.main = 1.25)

xg <- seq(min(ice$temp) - 1, max(ice$temp) + 1, length.out = 100)

## (a) interaction model: three lines free to differ in slope
plot(ice$temp, ice$IC, type = "n", xlab = "Mean temperature (deg F)",
     ylab = "Consumption (pints per capita)",
     main = "(a) Interaction model: slopes free")
for (g in 0:2) {
  k <- g + 1
  points(ice$temp[ice$year == g], ice$IC[ice$year == g],
         pch = 21, bg = cols[k], col = "white", cex = 1.5, lwd = 1.2)
  lines(xg, lines_tab$intercept[k] + lines_tab$slope[k] * xg,
        col = cols[k], lwd = 2.8)
}
legend("topleft", bty = "n", cex = 0.98, pch = 21, pt.bg = cols, col = "white",
       pt.cex = 1.5,
       legend = sprintf("year = %d:  slope %.5f", 0:2, lines_tab$slope))

## (b) the two models side by side, so the "parallel or not" question is visual
plot(ice$temp, ice$IC, type = "n", xlab = "Mean temperature (deg F)",
     ylab = "Consumption (pints per capita)",
     main = "(b) Parallel (dashed) vs interaction (solid)")
bp <- coef(fit_par)
par_int <- c(bp[1], bp[1] + bp[3], bp[1] + bp[4])
for (g in 0:2) {
  k <- g + 1
  points(ice$temp[ice$year == g], ice$IC[ice$year == g],
         pch = 21, bg = cols[k], col = "white", cex = 1.3, lwd = 1.2)
  lines(xg, par_int[k] + bp[2] * xg, col = cols[k], lwd = 2.2, lty = 2)
  lines(xg, lines_tab$intercept[k] + lines_tab$slope[k] * xg,
        col = cols[k], lwd = 2.8)
}
legend("topleft", bty = "n", cex = 0.98,
       legend = c(sprintf("partial F = %.3f  (p = %.3f)",
                          av$F[2], av$`Pr(>F)`[2]),
                  sprintf("adj R2:  %.3f -> %.3f",
                          summary(fit_par)$adj.r.squared, si$adj.r.squared)))
par(op)
dev.off()
cat("figure written:",
    file.path(out_dir, "fig-m07-interaction-lines.png"), "\n")
