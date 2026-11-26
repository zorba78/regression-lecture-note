# Date        : 2026-11-26
# Description : One-stop reproduction of every data-derived number, table and
#               R-made figure in chapter 7 (Dummy Variable) of the KINS
#               regression lecture, following the slide order of the canonical
#               deck quarto/agent/2026-08-26/07-dummy-variable.qmd.
#               Sections are headed by the exact slide title; slides that carry
#               only theory or definitions (no number computed from data) are
#               listed but skipped.
#
#               The code is moved, not rewritten, from the scripts that made
#               the deck (only the output paths and some object names changed):
#                 - code/agent/2026-08-11/make-lecture-figures.R (fig07 and the
#                   simple regression IC ~ temp)
#                 - code/agent/2026-08-28/dummy-interaction-fit.R (parallel-lines
#                   and interaction models, partial F, AIC, fig-m07)
#               Lines added here because no earlier script computed them: the
#               rank of the design matrix (slide "가변수 코딩: dummy trap").
#
#               Data: ice cream data, n = 30 four-week periods, read from the
#               same file the earlier scripts used,
#               references/cnu-regression-lecture-note/강의노트/R 예제/7장/ice.csv.csv
#               (docs/data/ice.csv is an identical export of it). year is the
#               observation year 0/1/2, not a season (memory/ice-data-year-variable.md).
#
#               Outputs (only under output/agent/2026-11-26/reproduce/ch07/; the
#               figure files carry the same names as the ones the deck uses, but
#               the deck's own PNGs are never written):
#                 fig07-dummy-variable.png, fig-m07-interaction-lines.png,
#                 tab-ch07-numbers.csv (columns slide, quantity, value)
#
#               Run   : from the project root,
#                       Rscript code/agent/2026-11-26/reproduce-ch07-dummy-variable.R
# File        : reproduce-ch07-dummy-variable.R

out_dir <- "output/agent/2026-11-26/reproduce/ch07"
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

## Palette of make-lecture-figures.R (fig07); fig-m07 uses its own hex codes
COL_BLUE   <- "#2a78d6"
COL_ORANGE <- "#eb6834"
COL_AQUA   <- "#1baf7a"
INK        <- "#0b0b0b"
INK2       <- "#52514e"
GRID_C     <- "#e1e0d9"

## Every quoted number is printed and collected into one table, one row per
## (slide, quantity), and written to tab-ch07-numbers.csv at the end.
num <- NULL
rec <- function(slide, quantity, value) {
  cat(sprintf("\n==== %s ====\n", slide))
  print(data.frame(quantity = quantity, value = signif(value, 6)), row.names = FALSE)
  num <<- rbind(num, data.frame(slide = slide, quantity = quantity, value = value))
}

## ============================================================================
## Slides with no data-derived result (skipped):
##   질적 설명변수의 처리 / 가변수의 정의
## ============================================================================

## ============================================================================
## Slide: 예제 자료: 관측 연차
## First five rows, size of the data, and the number of year categories k.
## ============================================================================
ice <- read.csv("references/cnu-regression-lecture-note/강의노트/R 예제/7장/ice.csv.csv",
                header = TRUE)
ice$yr <- factor(ice$year)                    # 0 = baseline, 1, 2
n <- nrow(ice)
print(head(ice[, c("period", "IC", "price", "income", "temp", "year")], 5), row.names = FALSE)
print(table(year = ice$year))

rec("예제 자료: 관측 연차",
    c("n (rows)", "number of variables in the file", "k = number of year categories"),
    c(n, ncol(ice) - 1, nlevels(ice$yr)))     # minus the added factor column yr

## ============================================================================
## Slide with no data-derived result (skipped): 가변수 코딩: k-1개 규칙
## ============================================================================

## ============================================================================
## Slide: 가변수 코딩: dummy trap
## The design matrix [1, temp, d1, d2] is 30 x 4 with rank 4. Adding the third
## dummy d0 (year = 0) makes d0 + d1 + d2 = 1 = the intercept column, so the
## 30 x 5 matrix still has rank 4 (perfect collinearity).
## ============================================================================
fit_par <- lm(IC ~ temp + yr, data = ice)          # parallel lines, 4 coef
X  <- model.matrix(fit_par)
X5 <- cbind(X, d0 = as.numeric(ice$year == 0))
cat("\nd0 + d1 + d2 equals the intercept column in every row:",
    all(X5[, "d0"] + X5[, "yr1"] + X5[, "yr2"] == X5[, "(Intercept)"]), "\n")
rec("가변수 코딩: dummy trap",
    c("rows of X", "columns of X (k - 1 dummies)", "rank of X",
      "columns with all k dummies", "rank with all k dummies"),
    c(nrow(X), ncol(X), qr(X)$rank, ncol(X5), qr(X5)$rank))

## ============================================================================
## Slide: 평행선 모형: 정의
## Figure fig07-dummy-variable.png (from make-lecture-figures.R, fig07): one
## common slope, three year-specific intercepts. The original fitted
## lm(IC ~ temp + factor(year)); fit_par is the same model.
## ============================================================================
b <- coef(fit_par)   # (Intercept), temp, yr1, yr2
grp_col <- c(COL_BLUE, COL_ORANGE, COL_AQUA)

png(file.path(out_dir, "fig07-dummy-variable.png"), width = 1800, height = 1100, res = 170)
par(mar = c(4.5, 4.5, 3, 1), col.axis = INK2, col.lab = INK, fg = INK2)
plot(ice$temp, ice$IC, pch = 16, cex = 1.2,
     col = grp_col[ice$year + 1],
     panel.first = grid(col = GRID_C, lty = 1),
     main = "One Slope, Three Intercepts: IC ~ temp + factor(year)",
     xlab = "Mean temperature (deg F)",
     ylab = "Consumption (pints per capita)")
abline(a = b[1],               b = b[2], col = grp_col[1], lwd = 3)
abline(a = b[1] + b[3],        b = b[2], col = grp_col[2], lwd = 3)
abline(a = b[1] + b[4],        b = b[2], col = grp_col[3], lwd = 3)
legend("topleft", bty = "n", pch = 16, col = grp_col,
       legend = c("year = 0", "year = 1", "year = 2"), text.col = INK)
dev.off()

## ============================================================================
## Slide with no data-derived result (skipped): 평행선 모형: 연차별 반응함수
## ============================================================================

## ============================================================================
## Slide: 평행선 모형: 적합 결과
## Coefficients and p-values of IC = b0 + b1 temp + b2 d1 + b3 d2.
## ============================================================================
sp <- summary(fit_par)
print(round(sp$coefficients, 6))
rec("평행선 모형: 적합 결과",
    c("b0 (intercept, year = 0)", "b1 (temp)", "b2 (d1: year = 1)", "b3 (d2: year = 2)",
      "p(b1)", "p(b2)", "p(b3)", "R2", "adjusted R2", "n"),
    c(b, sp$coefficients[2:4, 4], sp$r.squared, sp$adj.r.squared, n))

## ============================================================================
## Slide: 평행선 모형: 결과 해석
## Year-specific intercepts b0, b0 + b2, b0 + b3, and the R^2 of the simple
## regression on temperature alone (fit_temp of make-lecture-figures.R).
## ============================================================================
fit_temp <- lm(IC ~ temp, data = ice)
rec("평행선 모형: 결과 해석",
    c("intercept year = 0 (b0)", "intercept year = 1 (b0 + b2)", "intercept year = 2 (b0 + b3)",
      "R2 of IC ~ temp alone", "R2 parallel-lines model", "adjusted R2 parallel-lines model"),
    c(b[1], b[1] + b[3], b[1] + b[4],
      summary(fit_temp)$r.squared, sp$r.squared, sp$adj.r.squared))

## ============================================================================
## Slides with no data-derived result (skipped):
##   상호작용 모형: 도입 / 상호작용 모형: 연차별 직선
## ============================================================================

## ============================================================================
## Slide: 상호작용 모형: 적합 결과
## IC = b0 + b1 temp + b2 d1 + b3 d2 + b4 temp d1 + b5 temp d2 (R's temp * yr),
## the three year-specific lines
##    year = 0 : b0            + b1            * temp
##    year = 1 : (b0 + b2)     + (b1 + b4)     * temp
##    year = 2 : (b0 + b3)     + (b1 + b5)     * temp
## and the cross-check that a separate fit per year gives the same lines.
## ============================================================================
fit_int <- lm(IC ~ temp * yr, data = ice)          # interaction, 6 coef
si <- summary(fit_int)
print(round(si$coefficients, 6))

bi <- coef(fit_int)   # (Intercept), temp, yr1, yr2, temp:yr1, temp:yr2
lines_tab <- data.frame(
  year      = c(0, 1, 2),
  intercept = c(bi[1], bi[1] + bi[3], bi[1] + bi[4]),
  slope     = c(bi[2], bi[2] + bi[5], bi[2] + bi[6]),
  row.names = NULL)
print(round(lines_tab, 6))

## cross-check: fitting each year separately must give the same lines
chk <- t(sapply(levels(ice$yr), function(g) coef(lm(IC ~ temp, ice[ice$yr == g, ]))))
max_diff <- max(abs(chk - as.matrix(lines_tab[, c("intercept", "slope")])))

rec("상호작용 모형: 적합 결과",
    c(paste("estimate", c("b0", "b1 (temp)", "b2 (d1)", "b3 (d2)", "b4 (x d1)", "b5 (x d2)")),
      paste("SE", c("b0", "b1", "b2", "b3", "b4", "b5")),
      paste("p", c("b0", "b1", "b2", "b3", "b4", "b5")),
      "R2", "adjusted R2", "residual SE", "residual df",
      "year 0 intercept", "year 0 slope", "year 1 intercept", "year 1 slope",
      "year 2 intercept", "year 2 slope",
      "max abs difference vs separate fit per year"),
    c(bi, si$coefficients[, 2], si$coefficients[, 4],
      si$r.squared, si$adj.r.squared, si$sigma, si$df[2],
      t(as.matrix(lines_tab[, c("intercept", "slope")])),
      max_diff))

## ============================================================================
## Slide: 상호작용 모형: 모형 선택
## Parallel-lines vs interaction: R^2, adjusted R^2, AIC, partial F(2, 24),
## and figure fig-m07-interaction-lines.png.
## ============================================================================
av <- anova(fit_par, fit_int)
print(av)

cols <- c("#4C72B0", "#DD8452", "#55A868")     # year 0, 1, 2
png(file.path(out_dir, "fig-m07-interaction-lines.png"), width = 2100, height = 900, res = 150)
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
par_int <- c(b[1], b[1] + b[3], b[1] + b[4])
for (g in 0:2) {
  k <- g + 1
  points(ice$temp[ice$year == g], ice$IC[ice$year == g],
         pch = 21, bg = cols[k], col = "white", cex = 1.3, lwd = 1.2)
  lines(xg, par_int[k] + b[2] * xg, col = cols[k], lwd = 2.2, lty = 2)
  lines(xg, lines_tab$intercept[k] + lines_tab$slope[k] * xg,
        col = cols[k], lwd = 2.8)
}
legend("topleft", bty = "n", cex = 0.98,
       legend = c(sprintf("partial F = %.3f  (p = %.3f)",
                          av$F[2], av$`Pr(>F)`[2]),
                  sprintf("adj R2:  %.3f -> %.3f",
                          sp$adj.r.squared, si$adj.r.squared)))
par(op)
dev.off()

rec("상호작용 모형: 모형 선택",
    c("coefficients parallel", "coefficients interaction",
      "R2 parallel", "R2 interaction", "adjusted R2 parallel", "adjusted R2 interaction",
      "AIC parallel", "AIC interaction",
      "partial F df1", "partial F df2", "partial F", "partial F p"),
    c(length(b), length(bi),
      sp$r.squared, si$r.squared, sp$adj.r.squared, si$adj.r.squared,
      AIC(fit_par), AIC(fit_int),
      av$Df[2], av$Res.Df[2], av$F[2], av$`Pr(>F)`[2]))

## ============================================================================
## Slide with no data-derived result (skipped):
##   실무 적용: 원자로압력용기 조사취화 예측식 (1878 records, 26 parameters,
##   RMSE 13.3 C and R^2 0.875 are quoted from ASTM E900 / Metals 2022, not
##   computed from data in this repository)
## ============================================================================

## ============================================================================
## Slide: 이 장의 정리
## Repeats the year = 2 effect of the parallel-lines model.
## ============================================================================
rec("이 장의 정리", "b3 (d2: year = 2), parallel-lines model", b[4])

## ============================================================================
## Slide with no data-derived result (skipped): 참고문헌
## ============================================================================

write.csv(num, file.path(out_dir, "tab-ch07-numbers.csv"), row.names = FALSE, fileEncoding = "UTF-8")
cat("\nwrote", file.path(out_dir, "tab-ch07-numbers.csv"), "with", nrow(num), "rows\n")
cat("figures written to", out_dir, "\n")
