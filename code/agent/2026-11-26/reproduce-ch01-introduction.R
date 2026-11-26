# Date        : 2026-11-26
# Description : Reproduce, from the raw data, every data-derived number and every
#               R-drawn figure of chapter 1 (Introduction), in the slide order of
#               the canonical deck quarto/agent/2026-08-26/01-introduction.qmd.
#
#               Each section below is headed by the title of the slide it
#               serves.  Slides that carry no result computed from data (pure
#               definitions, the model-classification exercise, the field cases,
#               the chapter map, the references) are skipped.
#
#               The code is MOVED, not rewritten: every block names the script
#               that originally produced the result, and only the output path was
#               changed.  One block has no earlier script and is marked NEW
#               (the six-row head and the ranges of the ice cream variables).
#
#               Output
#                 figures : output/agent/2026-11-26/reproduce/ch01/<same file
#                           name the deck references>.  The deck's own PNGs are
#                           never touched.
#                 numbers : printed to the console and written to
#                           output/agent/2026-11-26/reproduce/ch01/tab-ch01-numbers.csv
#                           (columns: slide, quantity, value; value at full
#                           precision, the slide shows 3 significant digits)
#
#               Data
#                 Galton family records : data/derived-data/galton-stata11.tab
#                                         (898 children, 197 families; the same
#                                         file is published as docs/data/galton.csv)
#                 ice cream             : references/cnu-regression-lecture-note/
#                                         강의노트/R 예제/7장/ice.csv.csv
#                                         (n = 30; identical rows to docs/data/ice.csv)
#
#               Run from the project root:
#                 Rscript code/agent/2026-11-26/reproduce-ch01-introduction.R
# File        : reproduce-ch01-introduction.R

## ---- setup ------------------------------------------------------------

OUT <- "output/agent/2026-11-26/reproduce/ch01"
dir.create(OUT, recursive = TRUE, showWarnings = FALSE)

# Palette shared by all chapter 1 figures (identical in every source script)
COL_BLUE   <- "#2a78d6"   # fitted regression line
COL_ORANGE <- "#eb6834"   # local / conditional means, residual drops
COL_RED    <- "#e34948"   # y = x reference line, reference means
COL_GREEN  <- "#1c8f6b"   # third candidate curve on fig-i07
INK        <- "#0b0b0b"
INK2       <- "#52514e"
GRID_C     <- "#e1e0d9"
FILL_GREY  <- "#d8d7d2"
BAND_A     <- "#dce9f7"   # alternating bin bands on fig-i03
BAND_B     <- "#f0f5fb"
BAND_DROP  <- "#f2f1ee"   # bins too sparse to give a usable local mean

# Every number quoted on a slide (body or speaker notes) is printed through
# rec() and collected in `nums`, which is written to the CSV at the end.
nums <- data.frame(slide = character(0), quantity = character(0),
                   value = numeric(0), stringsAsFactors = FALSE)
rec <- function(slide, quantity, value) {
  nums[nrow(nums) + 1, ] <<- list(slide, quantity, unname(value))
  cat(sprintf("  %-62s %s\n", quantity, format(unname(value), digits = 7)))
}
hdr <- function(title) cat("\n==== ", title, " ====\n", sep = "")

## ---- data -------------------------------------------------------------

# Galton (1886) transmutation: mother's and daughters' statures x 1.08,
# mid-parent = (father + 1.08 * mother) / 2.
g <- read.delim("data/derived-data/galton-stata11.tab", stringsAsFactors = FALSE)
g$midparent <- (g$father + 1.08 * g$mother) / 2
g$child     <- ifelse(g$gender == "F", 1.08 * g$height, g$height)

fit <- lm(child ~ midparent, data = g)
B0  <- coef(fit)[1]
B1  <- coef(fit)[2]
SIG <- summary(fit)$sigma

ice <- read.csv("references/cnu-regression-lecture-note/강의노트/R 예제/7장/ice.csv.csv",
                stringsAsFactors = FALSE)

## =====================================================================
## Slide: Galton과 회귀의 기원  (fig-i01)
## Source: code/agent/2026-08-30/make-galton-midparent-scatter.R
## =====================================================================
s <- "Galton과 회귀의 기원"
hdr(s)
rec(s, "children in the file (n)", nrow(g))
rec(s, "families in the file", length(unique(g$family)))
# Notes: a mid-parent 4 in above the mean has children about 2.7 in above
# theirs.  That is Galton's published 2/3 law; least squares on this file
# gives a slightly steeper slope, so both are printed side by side.
rec(s, "child deviation for mid-parent +4 in, Galton 2/3 law (4*2/3)", 4 * 2 / 3)
rec(s, "child deviation for mid-parent +4 in, least squares (4*b1)", 4 * B1)

png(file.path(OUT, "fig-i01-galton-scatter.png"), width = 1800, height = 1100, res = 170)
par(mar = c(4.5, 4.5, 3, 1), col.axis = INK2, col.lab = INK, fg = INK2)
plot(g$midparent, g$child,
     pch = 16, col = adjustcolor(INK2, alpha.f = 0.35), cex = 0.8,
     panel.first = grid(col = GRID_C, lty = 1),
     main = "Mid-Parent Height vs Child Height (Galton's family records)",
     xlab = "Mid-parent height (inches)", ylab = "Child height (inches)")
# Thin crosshair at the two means (69.22 vs 69.23), so y = x passes through
# the centre of the cloud
abline(v = mean(g$midparent), col = adjustcolor(INK2, alpha.f = 0.45), lty = 3)
abline(h = mean(g$child),     col = adjustcolor(INK2, alpha.f = 0.45), lty = 3)
# Red: perfect transmission.  Blue: the flatter least-squares line.
abline(a = 0, b = 1, col = COL_RED, lwd = 3)
abline(fit, col = COL_BLUE, lwd = 3)
legend("topleft", bty = "o", bg = "white", box.col = GRID_C,
       lwd = c(3, 3), lty = c(1, 1), col = c(COL_RED, COL_BLUE),
       legend = c("y = x  (children exactly as tall as their parents)",
                  sprintf("Fitted line: y = %.2f + %.3f x", B0, B1)),
       text.col = INK)
dev.off()

## =====================================================================
## Slide: 주변분포와 조건부분포  (fig-i02)
## Source: code/agent/2026-08-30/make-galton-midparent-conditional-figures.R
## =====================================================================
s <- "주변분포와 조건부분포"
hdr(s)
# Conditional panel: mid-parent within +/- 0.75 in of 72 in
slice <- g[abs(g$midparent - 72) < 0.75, ]
rec(s, "mean child height, all children (E(Y))", mean(g$child))
rec(s, "children with mid-parent in 72 +/- 0.75 in (n)", nrow(slice))
rec(s, "mean child height in that slice", mean(slice$child))
rec(s, "fitted intercept b0", B0)
rec(s, "fitted slope b1", B1)
rec(s, "fitted E(Y | X = 72) = b0 + b1*72",
    predict(fit, newdata = data.frame(midparent = 72)))

png(file.path(OUT, "fig-i02-marginal-vs-conditional.png"),
    width = 2000, height = 780, res = 170)
par(mfrow = c(1, 2), mar = c(4.5, 4.5, 3.5, 1),
    col.axis = INK2, col.lab = INK, fg = INK2)
hist(g$child, breaks = 24, col = FILL_GREY, border = "white",
     main = sprintf("(a) All children  (n = %d)", nrow(g)),
     xlab = "Child height (inches)", ylab = "Frequency")
abline(v = mean(g$child), col = COL_RED, lwd = 3)
text(mean(g$child), par("usr")[4] * 0.92,
     labels = sprintf(" mean = %.1f", mean(g$child)), col = COL_RED, pos = 4)
hist(slice$child, breaks = 10, col = FILL_GREY, border = "white",
     main = sprintf("(b) Children whose mid-parent is about 72 in  (n = %d)",
                    nrow(slice)),
     xlab = "Child height (inches)", ylab = "Frequency")
abline(v = mean(slice$child), col = COL_RED, lwd = 3)
text(mean(slice$child), par("usr")[4] * 0.92,
     labels = sprintf(" mean = %.1f", mean(slice$child)), col = COL_RED, pos = 4)
dev.off()

## =====================================================================
## Slide: 국소평균과 회귀직선  (fig-i03)
## Source: code/agent/2026-08-30/make-galton-midparent-conditional-figures.R
## =====================================================================
s <- "국소평균과 회귀직선"
hdr(s)
MIN_N <- 10          # a local mean on fewer than 10 children is too noisy

brk  <- seq(floor(min(g$midparent)), ceiling(max(g$midparent)), by = 1)
bin  <- cut(g$midparent, breaks = brk, include.lowest = TRUE)
locm <- tapply(g$child, bin, mean)
locn <- tapply(g$child, bin, length)
ctr  <- brk[-length(brk)] + 0.5
keep <- !is.na(locm) & locn >= MIN_N

# Console only: the slide quotes no local-mean value, only the 1-inch bins
# and the n >= 10 rule
print(data.frame(midparent_bin = paste0("[", brk[-length(brk)][keep], ", ",
                                        brk[-1][keep], ")"),
                 n = as.numeric(locn[keep]),
                 mean_child = round(as.numeric(locm[keep]), 2)))

png(file.path(OUT, "fig-i03-local-means.png"), width = 2150, height = 1000, res = 170)
par(mar = c(4.5, 4.5, 3, 1), col.axis = INK2, col.lab = INK, fg = INK2)
plot(g$midparent, g$child, type = "n",
     main = "Local Means Trace Out the Regression Line",
     xlab = "Mid-parent height (inches)", ylab = "Child height (inches)")
# One vertical band per 1-inch bin; used bins tinted, sparse bins grey
usr  <- par("usr")
kept <- 0
for (i in seq_len(length(brk) - 1)) {
  if (isTRUE(keep[i])) {
    kept <- kept + 1
    fill <- if (kept %% 2 == 1) BAND_A else BAND_B
  } else {
    fill <- BAND_DROP
  }
  rect(brk[i], usr[3], brk[i + 1], usr[4], col = fill, border = NA)
  abline(v = brk[i], col = adjustcolor(INK2, alpha.f = 0.35), lty = 3)
}
abline(v = brk[length(brk)], col = adjustcolor(INK2, alpha.f = 0.35), lty = 3)
grid(col = GRID_C, lty = 1)
box(col = INK2)
points(g$midparent, g$child, pch = 16,
       col = adjustcolor(INK2, alpha.f = 0.30), cex = 0.8)
abline(fit, col = COL_BLUE, lwd = 3)
lines(ctr[keep], locm[keep], col = COL_ORANGE, lwd = 2, lty = 2)
points(ctr[keep], locm[keep], pch = 18, col = COL_ORANGE, cex = 2.4)
legend("topleft", bty = "o", bg = "white", box.col = GRID_C,
       lwd = c(3, 2, NA), lty = c(1, 2, NA), pch = c(NA, 18, 22),
       pt.cex = c(NA, 2.2, 2.2), pt.bg = c(NA, NA, BAND_A),
       col = c(COL_BLUE, COL_ORANGE, adjustcolor(INK2, alpha.f = 0.5)),
       legend = c("Least-squares line",
                  sprintf("Mean child height per 1-inch bin (n >= %d)", MIN_N),
                  "Shaded band = one binning interval"),
       text.col = INK)
dev.off()

## =====================================================================
## Slide: 회귀의 정의  (fig-i04)
## Source: code/agent/2026-08-30/make-galton-midparent-conditional-figures.R
## =====================================================================
s <- "회귀의 정의"
hdr(s)
xr <- range(g$midparent)
yr <- c(B0 + B1 * xr[1] - 4 * SIG, B0 + B1 * xr[2] + 4 * SIG)
# Console only: the conditional means at the three anchors drawn in the figure
for (x0 in c(65, 69, 73)) cat(sprintf("  E(Y | X = %d) = %.2f\n", x0, B0 + B1 * x0))

png(file.path(OUT, "fig-i04-conditional-expectation.png"),
    width = 1800, height = 1100, res = 170)
par(mar = c(4.5, 4.5, 3, 1), col.axis = INK2, col.lab = INK, fg = INK2)
plot(NA, xlim = xr, ylim = yr,
     panel.first = grid(col = GRID_C, lty = 1),
     main = "Regression Is the Conditional Mean of Y Given X = x",
     xlab = "x  (mid-parent height, inches)",
     ylab = "y  (child height, inches)")
points(g$midparent, g$child, pch = 16,
       col = adjustcolor(INK2, alpha.f = 0.18), cex = 0.7)
abline(fit, col = COL_BLUE, lwd = 3)
# A sideways normal density N(b0 + b1 x0, sigma-hat^2) at each anchor
for (x0 in c(65, 69, 73)) {
  mu <- B0 + B1 * x0
  yy <- seq(mu - 3 * SIG, mu + 3 * SIG, length.out = 200)
  dd <- dnorm(yy, mu, SIG)
  dd <- dd / max(dd) * 1.6                        # width in x units
  polygon(c(x0 + dd, rep(x0, length(yy))), c(yy, rev(yy)),
          col = adjustcolor(COL_ORANGE, alpha.f = 0.25), border = COL_ORANGE)
  points(x0, mu, pch = 18, col = COL_ORANGE, cex = 2.0)
  segments(x0, mu, x0 + 1.6, mu, col = COL_ORANGE, lty = 3)
}
legend("topleft", bty = "n", lwd = c(3, NA), pch = c(NA, 18), pt.cex = c(NA, 2),
       col = c(COL_BLUE, COL_ORANGE),
       legend = c(expression(paste("E(Y | X = x) = ", beta[0] + beta[1] * x)),
                  "Conditional mean at x = 65, 69, 73"),
       text.col = INK)
dev.off()

## =====================================================================
## Slide: Galton 자료: 모형 적합  (coefficient table and ANOVA table)
## Source: code/agent/2026-08-30/make-galton-midparent-conditional-figures.R
##         (notes' father-only slope: code/agent/2026-08-24/make-galton-real-figures.R)
## =====================================================================
s <- "Galton 자료: 모형 적합"
hdr(s)
ct <- summary(fit)$coefficients
av <- anova(fit)
print(signif(ct, 3))
print(av)
rec(s, "intercept estimate b0", ct[1, 1])
rec(s, "intercept SE", ct[1, 2])
rec(s, "intercept t value", ct[1, 3])
rec(s, "intercept p-value", ct[1, 4])
rec(s, "slope estimate b1", ct[2, 1])
rec(s, "slope SE", ct[2, 2])
rec(s, "slope t value", ct[2, 3])
rec(s, "slope p-value", ct[2, 4])
rec(s, "ANOVA df, x", av$Df[1])
rec(s, "ANOVA Sum Sq, x", av$`Sum Sq`[1])
rec(s, "ANOVA Mean Sq, x", av$`Mean Sq`[1])
rec(s, "ANOVA F value", av$`F value`[1])
rec(s, "ANOVA p-value", av$`Pr(>F)`[1])
rec(s, "ANOVA df, residuals", av$Df[2])
rec(s, "ANOVA Sum Sq, residuals", av$`Sum Sq`[2])
rec(s, "ANOVA Mean Sq, residuals", av$`Mean Sq`[2])
rec(s, "R-squared", summary(fit)$r.squared)
rec(s, "residual SD (sigma-hat, inches)", SIG)

# Notes: with the father's height alone as the explanatory variable the slope
# drops to 0.448.  This is the father -> son fit (465 sons) of the 2026-08-24
# script, the pairing the deck used before the mid-parent redraw.
son <- subset(g, gender == "M", select = c(father, height))
names(son) <- c("father", "son")
fit_fs <- lm(son ~ father, data = son)
rec(s, "notes: father -> son slope (sons only)", coef(fit_fs)[2])
rec(s, "notes: number of father-son pairs", nrow(son))

## =====================================================================
## Slide: 회귀분석의 8단계  (fig-i06, a flow chart; no data)
## Source: code/agent/2026-08-25/make-eight-step-flowchart.R
## =====================================================================
hdr("회귀분석의 8단계")

BAND      <- c("#eef4fb", "#e7f3ee", "#fdf0e9")   # one tint per phase
BAND_EDGE <- c("#c3d9f2", "#bfe0d2", "#f7d3bf")
BOX_FILL  <- "#ffffff"

phases <- list(
  list(head = "문제 설정 및 데이터 획득", sub = "Problem setting and data collection"),
  list(head = "모형 특정 및 적합", sub = "Model specification and fitting"),
  list(head = "검증 및 사용", sub = "Validation and use")
)
steps <- list(
  c("1. 문제의 진술", "Statement of the problem"),
  c("2. 관련 변수의 선택", "Selection of relevant variables"),
  c("3. 자료 수집", "Data collection"),
  c("4. 모형 설정", "Model specification"),
  c("5. 적합 방법의 선택", "Choice of fitting method"),
  c("6. 모형 적합", "Model fitting"),
  c("7. 모형 검증과 비판", "Model validation and criticism"),
  c("8. 선택된 모형의 사용", "Using the chosen model")
)
group_of <- list(1:3, 4:6, 7:8)   # which steps sit in which phase

bx <- c(16, 50, 84)   # centre of each phase band
half_b <- 15          # band half-width
half_x <- 12.0        # box half-width (leaves a lane inside the band)
half_y <- 5.4         # box half-height
band_top <- 90
band_bot <- 30

png(file.path(OUT, "fig-i06-eight-steps.png"), width = 2300, height = 1000, res = 165)
par(mar = c(0, 0, 0, 0))
plot(0, 0, type = "n", xlim = c(0, 100), ylim = c(4, 100), axes = FALSE,
     xlab = "", ylab = "", xaxs = "i", yaxs = "i")
for (k3 in 1:3) {
  rect(bx[k3] - half_b, band_bot, bx[k3] + half_b, band_top,
       col = BAND[k3], border = BAND_EDGE[k3], lwd = 2)
  text(bx[k3], band_top - 4.0, phases[[k3]]$head, font = 2, cex = 1.62, col = INK)
  text(bx[k3], band_top - 8.2, phases[[k3]]$sub, font = 3, cex = 1.10, col = INK2)
  ids <- group_of[[k3]]
  ys <- seq(band_top - 16, band_bot + 7, length.out = 3)[seq_along(ids)]
  for (k in seq_along(ids)) {
    i <- ids[k]
    y <- ys[k]
    rect(bx[k3] - half_x, y - half_y, bx[k3] + half_x, y + half_y,
         col = BOX_FILL, border = COL_BLUE, lwd = 2)
    text(bx[k3], y + 1.7, steps[[i]][1], font = 2, cex = 1.36, col = INK)
    text(bx[k3], y - 2.6, steps[[i]][2], font = 3, cex = 1.04, col = INK2)
    if (k < length(ids)) {
      arrows(bx[k3], y - half_y, bx[k3], ys[k + 1] + half_y,
             length = 0.10, lwd = 2.5, col = COL_BLUE)
    }
  }
}
for (k3 in 1:2) {   # arrows between the phases
  arrows(bx[k3] + half_b, 60, bx[k3 + 1] - half_b - 0.4, 60,
         length = 0.16, lwd = 3.5, col = COL_BLUE)
}
# Feedback loop from step 7 back to step 4, routed under the bands
fb <- 16
lane  <- bx[2] - half_b + 1.8
lane3 <- bx[3] + half_b - 1.8
y4 <- seq(band_top - 16, band_bot + 7, length.out = 3)[1]
lines(c(bx[3] + half_x, lane3, lane3, lane, lane), c(y4, y4, fb, fb, y4),
      lwd = 3, col = COL_ORANGE, lty = 2)
arrows(lane, y4, bx[2] - half_x - 0.4, y4, length = 0.16, lwd = 3, col = COL_ORANGE)
text((lane + lane3) / 2, fb - 3.8, "7단계 모형 검증 결과가 만족스럽지 않은 경우",
     font = 2, cex = 1.36, col = COL_ORANGE)
text((lane + lane3) / 2, fb - 7.6, "Regression analysis is a loop, not a one-way street",
     font = 3, cex = 1.07, col = COL_ORANGE)
dev.off()

## =====================================================================
## Slide: 3단계 자료 수집: 아이스크림 자료  (first six rows, variable ranges)
## Source: NEW (no earlier script printed the six-row head or the ranges of
##         price and income; code/agent/2026-08-26/make-candidate-curves-figure.R
##         printed the temp and IC ranges only)
## =====================================================================
s <- "3단계 자료 수집: 아이스크림 자료"
hdr(s)
print(head(ice, 6))
rec(s, "number of periods (n)", nrow(ice))
rec(s, "number of variables", ncol(ice))
for (v in c("IC", "price", "income", "temp", "year")) {
  rec(s, sprintf("%s minimum", v), min(ice[[v]]))
  rec(s, sprintf("%s maximum", v), max(ice[[v]]))
}

## =====================================================================
## Slide: 4단계 모형 설정: 선의 후보  (fig-i07)
## Source: code/agent/2026-08-26/make-candidate-curves-figure.R
## =====================================================================
hdr("4단계 모형 설정: 선의 후보")
f_line <- lm(IC ~ temp, data = ice)
f_quad <- lm(IC ~ temp + I(temp^2), data = ice)
f_log  <- lm(IC ~ log(temp), data = ice)
# Console only, deliberately kept off the slide (step 5 supplies the criterion)
for (nm in c("line", "quad", "log")) {
  m <- get(paste0("f_", nm))
  cat(sprintf("  %-5s  R2 = %.4f  adj.R2 = %.4f\n",
              nm, summary(m)$r.squared, summary(m)$adj.r.squared))
}
grd <- data.frame(temp = seq(min(ice$temp), max(ice$temp), length.out = 300))

png(file.path(OUT, "fig-i07-candidate-curves.png"), width = 2050, height = 1000, res = 150)
par(mar = c(4.2, 4.6, 1.0, 1), col.axis = INK2, col.lab = INK, fg = INK2)
plot(ice$temp, ice$IC, type = "n",
     xlab = "Mean temperature (Fahrenheit)",
     ylab = "Ice cream consumption (pints per capita)")
grid(col = GRID_C, lty = 1)
box(col = INK2)
points(ice$temp, ice$IC, pch = 16, col = adjustcolor(INK2, alpha.f = 0.55), cex = 1.4)
lines(grd$temp, predict(f_line, grd), col = COL_BLUE,   lwd = 3.2, lty = 1)
lines(grd$temp, predict(f_quad, grd), col = COL_ORANGE, lwd = 3.2, lty = 2)
lines(grd$temp, predict(f_log,  grd), col = COL_GREEN,  lwd = 3.2, lty = 3)
legend("topleft", bty = "o", bg = "white", box.col = GRID_C,
       lwd = 3.2, lty = c(1, 2, 3),
       col = c(COL_BLUE, COL_ORANGE, COL_GREEN),
       legend = c("Straight line in temp", "Quadratic in temp", "Log of temp"),
       text.col = INK)
dev.off()

## =====================================================================
## Slide: 7단계 모형 검증과 비판  (fig-i08)
## Source: code/agent/2026-08-31/make-ice-residual-figures.R
## =====================================================================
s <- "7단계 모형 검증과 비판"
hdr(s)

# Runs of residual signs ordered by fitted value (console only); about n/2 + 1
# when nothing systematic is left behind
runs_of <- function(res, ord) {
  sg <- sign(res[order(ord)])
  1 + sum(sg[-1] != sg[-length(sg)])
}
# Residual-versus-fitted panel shared by fig-i08 and the three fig-i09 panels
resid_panel <- function(f, r, title) {
  plot(f, r, type = "n", main = title, xlab = "Fitted value", ylab = "Residual")
  grid(col = GRID_C, lty = 1)
  box(col = INK2)
  abline(h = 0, col = INK2, lwd = 1.6, lty = 2)
  points(f, r, pch = 16, col = adjustcolor(INK2, alpha.f = 0.6), cex = 1.5)
}

m <- lm(IC ~ temp, data = ice)
rec(s, "notes: intercept b0 (IC on temp)", coef(m)[1])
rec(s, "notes: slope b1 (IC on temp)", coef(m)[2])
rec(s, "notes: R-squared (IC on temp)", summary(m)$r.squared)
cat(sprintf("  runs (ordered by fitted) = %d, expected = %.1f\n",
            runs_of(resid(m), fitted(m)), nrow(ice) / 2 + 1))

png(file.path(OUT, "fig-i08-ice-residual.png"), width = 2100, height = 1000, res = 150)
par(mfrow = c(1, 2), mar = c(4.3, 4.6, 3.0, 1),
    col.axis = INK2, col.lab = INK, fg = INK2)
plot(ice$temp, ice$IC, type = "n",
     main = "Fitted line and the residuals it leaves",
     xlab = "Mean temperature (Fahrenheit)",
     ylab = "Ice cream consumption (pints per capita)")
grid(col = GRID_C, lty = 1)
box(col = INK2)
segments(ice$temp, ice$IC, ice$temp, fitted(m),
         col = adjustcolor(COL_ORANGE, alpha.f = 0.75), lwd = 1.6)
abline(m, col = COL_BLUE, lwd = 3.2)
points(ice$temp, ice$IC, pch = 16, col = adjustcolor(INK2, alpha.f = 0.6), cex = 1.4)
resid_panel(fitted(m), resid(m), "Residual versus fitted: no pattern left")
lines(lowess(fitted(m), resid(m), f = 0.8), col = COL_BLUE, lwd = 3.4)
dev.off()

## =====================================================================
## Slide: 7단계: 문제가 되는 잔차  (fig-i09, simulated at the ice cream scale)
## Source: code/agent/2026-08-31/make-ice-residual-figures.R
##         The draws below must stay in this order after set.seed(2026):
##         curve, funnel, outlier, edge.
## =====================================================================
s <- "7단계: 문제가 되는 잔차"
hdr(s)
set.seed(2026)
x  <- ice$temp
b0 <- coef(m)[1]
b1 <- coef(m)[2]
xc <- x - mean(x)

y_curve  <- b0 + b1 * x - 1.2e-4 * xc^2 + rnorm(length(x), 0, 0.015)           # missed bend
y_funnel <- b0 + b1 * x + rnorm(length(x), 0, 0.008 + 0.0014 * (x - min(x)))   # growing spread
y_out    <- b0 + b1 * x + rnorm(length(x), 0, 0.020)                           # one far point
i_out    <- which.min(abs(x - median(x)))          # a middle period, not an edge
y_out[i_out] <- y_out[i_out] + 0.18

m_curve  <- lm(y_curve  ~ x)
m_funnel <- lm(y_funnel ~ x)
m_out    <- lm(y_out    ~ x)

cat(sprintf("  curved : R2 = %.4f, runs = %d (expected %.1f)\n",
            summary(m_curve)$r.squared, runs_of(resid(m_curve), fitted(m_curve)),
            length(x) / 2 + 1))
rec(s, "notes: funnel residual SD, cool half", sd(resid(m_funnel)[x <= median(x)]))
rec(s, "notes: funnel residual SD, warm half", sd(resid(m_funnel)[x >  median(x)]))
b_with    <- coef(m_out)[2]
b_without <- coef(lm(y_out[-i_out] ~ x[-i_out]))[2]
rec(s, "notes: slope change when the middle outlier is dropped (%)",
    100 * (b_with - b_without) / b_without)

# The same 0.18 displacement placed at the hottest period instead
y_edge <- b0 + b1 * x + rnorm(length(x), 0, 0.020)
i_edge <- which.max(x)
y_edge[i_edge] <- y_edge[i_edge] + 0.18
b_edge_with    <- coef(lm(y_edge ~ x))[2]
b_edge_without <- coef(lm(y_edge[-i_edge] ~ x[-i_edge]))[2]
rec(s, "notes: slope change when the same shift sits at the edge (%)",
    100 * (b_edge_with - b_edge_without) / b_edge_without)

png(file.path(OUT, "fig-i09-residual-warning.png"),
    width = 2100, height = 860, res = 150, pointsize = 20)
par(mfrow = c(1, 3), mar = c(4.3, 4.6, 3.0, 1),
    col.axis = INK2, col.lab = INK, fg = INK2)
resid_panel(fitted(m_curve), resid(m_curve), "Curved: a bend was missed")
lines(lowess(fitted(m_curve), resid(m_curve), f = 0.8), col = COL_ORANGE, lwd = 3.4)
rf <- resid(m_funnel); ff <- fitted(m_funnel)
resid_panel(ff, rf, "Funnel: the spread keeps growing")
env <- lowess(ff, abs(rf), f = 0.9)              # the widening band, both sides
lines(env$x,  env$y, col = COL_ORANGE, lwd = 3.0, lty = 2)
lines(env$x, -env$y, col = COL_ORANGE, lwd = 3.0, lty = 2)
resid_panel(fitted(m_out), resid(m_out), "One point stands far apart")
points(fitted(m_out)[i_out], resid(m_out)[i_out], pch = 1, cex = 3.2,
       col = COL_ORANGE, lwd = 3.0)
dev.off()

## ---- numbers table ----------------------------------------------------

write.csv(nums, file.path(OUT, "tab-ch01-numbers.csv"), row.names = FALSE,
          fileEncoding = "UTF-8")
cat(sprintf("\n%d numbers written to %s\n", nrow(nums),
            file.path(OUT, "tab-ch01-numbers.csv")))
cat("figures written to", OUT, ":\n")
print(list.files(OUT, pattern = "\\.png$"))
