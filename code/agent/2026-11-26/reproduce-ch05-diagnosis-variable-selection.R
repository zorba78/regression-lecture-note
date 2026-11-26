# Date        : 2026-11-26
# Description : Chapter 5 (Diagnosis & Variable Selection) reproduction script.
#               Recomputes, from the raw data, every data-derived number shown on
#               the chapter 5 deck
#                 quarto/agent/2026-08-26/05-diagnosis-variable-selection.qmd
#               and redraws every R-generated figure that deck links to. Sections
#               follow the slide order of the deck; each section comment carries
#               the slide title verbatim. Slides that hold only theory,
#               definitions or literature values (no number computed from data,
#               no R figure) are listed in a one-line comment where they occur
#               and skipped.
#
#               Numbers flagged "[notes]" appear only in the speaker notes of the
#               slide, not in the slide body.
#
#               The code is NOT new: each block is copied from the script that
#               originally produced that figure or number, with only the output
#               path (and, where scripts are merged, the R object names) changed.
#               Source scripts:
#                 code/agent/2026-08-11/make-lecture-figures.R      (fig08 Anscombe,
#                                                                    models, VIF, step)
#                 code/agent/2026-11-26/make-fullmodel-diagnostics.R (fig-i05)
#                 code/agent/2026-11-26/check-ch05-links.R          (diagnostic maxima,
#                                                                    AIC*, c_jj)
#                 code/agent/2026-11-26/check-ch05-r8-numbers.R     (r_i check,
#                                                                    Scale-Location,
#                                                                    Breusch-Pagan,
#                                                                    Bonferroni test)
#                 code/agent/2026-08-28/outlier-leverage-influence-figure.R
#                                                                   (fig-m05-outlier-...)
#                 code/agent/2026-11-26/residual-pattern-figure.R   (fig-m05-residual-
#                                                                    patterns; the latest
#                                                                    of two versions)
#                 code/agent/2026-08-29/boxcox-gala-transformation.R (fig-m05-boxcox-gala)
#                 code/agent/2026-11-26/make-selected-model-diagnostics.R (fig04)
#
#               Data:
#                 - ice cream consumption, CNU lecture note R examples, chapter 7
#                   (references/cnu-regression-lecture-note/강의노트/R 예제/7장/
#                   ice.csv.csv, n = 30), same path as the original scripts;
#                 - Galapagos species (faraway::gala, Johnson & Raven 1973). The
#                   original script loaded gala.rda from a session scratchpad that
#                   no longer exists and faraway is not installed, so the CSV
#                   exported from that same file by
#                   code/agent/2026-08-31/export-data.R is used:
#                   docs/data/gala.csv (n = 30);
#                 - anscombe (base R datasets, Anscombe 1973);
#                 - two simulated teaching panels, with the seeds of the original
#                   scripts (20260828, 20260829).
#               Packages: MASS (boxcox), lmtest (bptest), as in the originals.
#
#               Outputs (and ONLY these; the PNGs the deck links to are never
#               touched):
#                 output/agent/2026-11-26/reproduce/ch05/<same file names as the deck>
#                 output/agent/2026-11-26/reproduce/ch05/tab-ch05-numbers.csv
#                   (columns: slide, quantity, value)
#
#               Run from the project root:
#                 Rscript code/agent/2026-11-26/reproduce-ch05-diagnosis-variable-selection.R
# File        : reproduce-ch05-diagnosis-variable-selection.R

options(digits = 10)
suppressMessages({library(MASS); library(lmtest)})

## ---- setup -------------------------------------------------------------------

FIG_DIR <- "output/agent/2026-11-26/reproduce/ch05"
dir.create(FIG_DIR, recursive = TRUE, showWarnings = FALSE)

# Colours copied from make-lecture-figures.R / make-fullmodel-diagnostics.R
COL_BLUE <- "#2a78d6"
INK      <- "#0b0b0b"
INK2     <- "#52514e"
GRID_C   <- "#e1e0d9"

ice <- read.csv(
  "references/cnu-regression-lecture-note/강의노트/R 예제/7장/ice.csv.csv",
  header = TRUE
)
n <- nrow(ice)                                     # 30 four-week periods

# Every number that is compared with the deck is printed to the console and
# appended to `nums`, which is written to tab-ch05-numbers.csv at the end.
nums <- data.frame(slide = character(), quantity = character(), value = numeric())
rec <- function(slide, quantity, value) {
  cat(sprintf("  %-62s %s\n", quantity, format(value, digits = 10)))
  nums[nrow(nums) + 1, ] <<- list(slide, quantity, value)
}

## ---- Slide: "요약통계량이 같은 네 자료" (Anscombe's quartet) -------------------
# Figure block and coefficient print copied from make-lecture-figures.R (fig08);
# open_png() there is png(width = w, height = h, res = 170).
s <- "요약통계량이 같은 네 자료"; cat("\n=== ", s, " ===\n", sep = "")
for (i in 1:4) {
  cf <- coef(lm(anscombe[[paste0("y", i)]] ~ anscombe[[paste0("x", i)]]))
  rec(s, sprintf("data set %d: intercept", i), cf[[1]])
  rec(s, sprintf("data set %d: slope", i), cf[[2]])
}

png(file.path(FIG_DIR, "fig08-anscombe.png"), width = 1700, height = 1500, res = 170)
par(mfrow = c(2, 2), mar = c(4, 4, 2.5, 1), oma = c(0, 0, 2, 0),
    col.axis = INK2, col.lab = INK, fg = INK2)
for (i in 1:4) {
  xi <- anscombe[[paste0("x", i)]]
  yi <- anscombe[[paste0("y", i)]]
  plot(xi, yi, pch = 16, col = INK2, cex = 1.2,
       panel.first = grid(col = GRID_C, lty = 1),
       xlim = c(3, 19), ylim = c(3, 13),
       main = paste0("Data set ", i),
       xlab = paste0("x", i), ylab = paste0("y", i))
  abline(lm(yi ~ xi), col = COL_BLUE, lwd = 2)
}
mtext("Anscombe's Quartet: Same Summary Numbers, Different Stories",
      outer = TRUE, cex = 1.2, col = INK)
invisible(dev.off())

# (Slide "회귀모형의 네 가지 가정": assumptions only.)

## ---- Slide: "잔차: 모형이 설명하지 못한 나머지" (residuals) --------------------
s <- "잔차: 모형이 설명하지 못한 나머지"; cat("\n=== ", s, " ===\n", sep = "")
fit_full <- lm(IC ~ price + income + temp, data = ice)   # full model, p = 3
p <- length(coef(fit_full)) - 1
h <- hatvalues(fit_full)                                # leverages h_ii
rec(s, "tr(I - H) = n - (p + 1)", sum(1 - h))

## ---- Slide: "진단 그림 4종 읽는 법" (four diagnostic plots, full model) --------
# Figure block copied from code/agent/2026-11-26/make-fullmodel-diagnostics.R.
# The [notes] numbers are check-ch05-r8-numbers.R blocks (B) and (C): plot.lm's
# Scale-Location smoother is lowess(fitted, sqrt|r_i|, f = 2/3, iter = 3).
s <- "진단 그림 4종 읽는 법"; cat("\n=== ", s, " ===\n", sep = "")
png(file.path(FIG_DIR, "fig-i05-fullmodel-diagnostics.png"),
    width = 1700, height = 1500, res = 170)
par(mfrow = c(2, 2), mar = c(4.2, 4.2, 3.2, 1.2), oma = c(0, 0, 2.4, 0),
    cex.main = 0.95, col.axis = INK2, col.lab = INK, fg = INK2)
plot(fit_full, pch = 16, col = INK2, sub.caption = "")
mtext("Residual diagnostics: full model (price, income, temp)",
      outer = TRUE, cex = 1.0, col = INK)
invisible(dev.off())

yhat <- fitted(fit_full)
sl   <- sqrt(abs(rstandard(fit_full)))                   # Scale-Location y axis
lw   <- lowess(yhat, sl, f = 2/3, iter = 3)
for (x in c(0.30, 0.35, 0.40))
  rec(s, sprintf("[notes] Scale-Location smoother at fitted = %.2f", x),
      approx(lw$x, lw$y, xout = x)$y)
rec(s, "[notes] Scale-Location smoother at the largest fitted value", lw$y[length(lw$y)])
rec(s, "[notes] number of points with fitted value > 0.42", sum(yhat > 0.42))
for (i in which(yhat > 0.42)) rec(s, "[notes] observation with fitted value > 0.42", i)
rec(s, "[notes] observation with the largest sqrt|r_i| among them",
    which(yhat > 0.42)[which.max(sl[yhat > 0.42])])
rec(s, "[notes] Breusch-Pagan (Koenker, lmtest default) p-value",
    bptest(fit_full)$p.value)

## ---- Slide: "레버리지 $h_{ii}$" (leverage) -------------------------------------
s <- "레버리지 $h_{ii}$"; cat("\n=== ", s, " ===\n", sep = "")
rec(s, "tr(H) = p + 1", sum(h))
rec(s, "average leverage (p+1)/n", mean(h))
rec(s, "rule of thumb 2(p+1)/n", 2 * mean(h))
rec(s, "largest h_ii", max(h))
rec(s, "observation with the largest h_ii", which.max(h))

## ---- Slide: "스튜던트화 잔차" (studentized residual) ---------------------------
# check-ch05-r8-numbers.R block (A): the "Standardized residuals" axis of the
# diagnostic plot is rstandard(), which equals e_i / (sigma-hat sqrt(1 - h_ii)).
s <- "스튜던트화 잔차"; cat("\n=== ", s, " ===\n", sep = "")
r_formula <- resid(fit_full) / (summary(fit_full)$sigma * sqrt(1 - h))
rec(s, "max |rstandard - e/(sigma-hat sqrt(1-h))|",
    max(abs(rstandard(fit_full) - r_formula)))

# (Slides "외적 스튜던트화 잔차", "이상치, 레버리지, 영향점: 정의": definitions only.)

## ---- Slide: "이상치, 레버리지, 영향점: 그림 비교" (simulated three cases) ------
# Simulated teaching panel. Block copied from outlier-leverage-influence-figure.R
# with its seed; local() keeps its h, b, fit0 etc. apart from the ice cream
# objects. The console lines of the original are recorded with rec() instead of
# cat(); they back the qualitative table on the slide (small/large, moves/not).
s <- "이상치, 레버리지, 영향점: 그림 비교"; cat("\n=== ", s, " ===\n", sep = "")
local({
  set.seed(20260828)

  ## 1. Base data: a clean simple linear relationship, y = 2 + 0.8x + noise
  n0 <- 20
  x0 <- round(seq(2, 10, length.out = n0) + rnorm(n0, 0, 0.35), 2)
  y0 <- round(2 + 0.8 * x0 + rnorm(n0, 0, 0.8), 2)
  base <- data.frame(x = x0, y = y0)
  fit0 <- lm(y ~ x, data = base)

  ## 2. Three cases, each = base data + ONE extra point
  b <- coef(fit0)
  line_at <- function(x) as.numeric(b[1] + b[2] * x)

  cases <- list(
    list(key = "outlier",     x = 6.0,  y = line_at(6.0) + 5.0,
         title = "(a) Outlier: far in y, centre of x"),
    list(key = "leverage",    x = 19.0, y = line_at(19.0) + 0.9,
         title = "(b) High leverage: far in x, near the line"),
    list(key = "influential", x = 19.0, y = line_at(19.0) - 7.0,
         title = "(c) Influential: far in x and off the line")
  )

  res <- list()
  for (cs in cases) {
    d <- rbind(base, data.frame(x = cs$x, y = cs$y))
    f <- lm(y ~ x, data = d)
    k <- nrow(d)                       # the added point is the last row
    res[[cs$key]] <- list(cs = cs, d = d, fit = f)
    rec(s, sprintf("(%s) leverage h of the added point", cs$key), hatvalues(f)[[k]])
    rec(s, sprintf("(%s) studentized (deleted) residual", cs$key), rstudent(f)[[k]])
    rec(s, sprintf("(%s) Cook's distance", cs$key), cooks.distance(f)[[k]])
    rec(s, sprintf("(%s) slope change, %% of the base slope", cs$key),
        100 * (coef(f)[[2]] - b[[2]]) / b[[2]])
  }
  rec(s, "mean leverage 2/21 for n = 21", 2 / 21)

  ## 3. Figure (conceptual; no number is drawn)
  png(file.path(FIG_DIR, "fig-m05-outlier-leverage-influence.png"),
      width = 2000, height = 780, res = 150)
  op <- par(mfrow = c(1, 3), mar = c(4.6, 4.6, 5.2, 1.0), cex.axis = 1.2,
            cex.lab = 1.45)

  xlim <- c(0, 21)
  ylim <- range(c(base$y, sapply(res, function(z) z$cs$y))) + c(-1.5, 2.0)
  xbar <- mean(base$x)

  titles <- c(outlier     = "(a) Far in y only",
              leverage    = "(b) Far in x only",
              influential = "(c) Far in both")
  verdict <- c(outlier     = "line barely moves",
               leverage    = "line barely moves",
               influential = "line is pulled away")

  for (key in c("outlier", "leverage", "influential")) {
    z <- res[[key]]
    plot(base$x, base$y, xlim = xlim, ylim = ylim, xlab = "x", ylab = "y",
         main = "", pch = 21, bg = "grey80", col = "grey35", cex = 1.3)
    mtext(titles[[key]], side = 3, line = 2.3, cex = 1.15, font = 2)
    mtext(verdict[[key]], side = 3, line = 0.7, cex = 0.95, col = "#C44E52")
    abline(v = xbar, col = "grey65", lty = 3, lwd = 2)
    text(xbar, ylim[2], "centre of x", pos = 4, offset = 0.3, col = "grey45",
         cex = 1.15)
    abline(fit0, col = "grey45", lwd = 2.4, lty = 2)
    abline(z$fit, col = "#C44E52", lwd = 3.0)
    segments(z$cs$x, z$cs$y, z$cs$x, line_at(z$cs$x),
             col = "#C44E52", lwd = 2, lty = 3)
    points(z$cs$x, z$cs$y, pch = 21, bg = "#C44E52", col = "white",
           cex = 2.6, lwd = 2)
    if (key == "outlier") {
      legend("bottomright", bty = "n", cex = 1.3, lwd = c(2.4, 3.0),
             lty = c(2, 1), col = c("grey45", "#C44E52"),
             legend = c("fit without the red point", "fit with the red point"))
    }
  }
  par(op)
  invisible(dev.off())
})

## ---- Slide: "이상치, 레버리지, 영향점: Cook 거리" (diagnostic maxima) ---------
# check-ch05-links.R block (3).
s <- "이상치, 레버리지, 영향점: Cook 거리"; cat("\n=== ", s, " ===\n", sep = "")
r  <- rstandard(fit_full)
cd <- cooks.distance(fit_full)
rec(s, "largest |r_i| (studentized residual)", max(abs(r)))
rec(s, "observation with the largest |r_i|", which.max(abs(r)))
rec(s, "largest h_ii", max(h))
rec(s, "observation with the largest h_ii", which.max(h))
rec(s, "largest Cook's distance D_i", max(cd))
rec(s, "observation with the largest D_i", which.max(cd))

# (Slide "영향점 측도: DFFITS": definition and cut-off only, no data value.)

## ---- Slide: "이상점 검정" (Bonferroni outlier test) ----------------------------
# check-ch05-r8-numbers.R block (D): critical value t_{alpha/(2n), n-p-2}.
s <- "이상점 검정"; cat("\n=== ", s, " ===\n", sep = "")
t_ext <- rstudent(fit_full)                       # externally studentized
rec(s, "largest |t_i|", max(abs(t_ext)))
rec(s, "observation with the largest |t_i|", which.max(abs(t_ext)))
rec(s, "[notes] upper-tail probability alpha/(2n) = 0.05/60", 0.05 / (2 * n))
rec(s, "df = n - p - 2", n - p - 2)
rec(s, "critical value t_{0.05/60, 25}", qt(1 - 0.05 / (2 * n), n - p - 2))

# (Slides "이상점: 유의점과 대처", "다중공선성과 VIF: 정의": no data numbers.)

## ---- Slide: "다중공선성과 VIF: 아이스크림 자료" (VIF) ---------------------------
# R_j^2 from regressing predictor j on the other two (make-lecture-figures.R
# vif_manual); the [notes] numbers are check-ch05-links.R block (1).
s <- "다중공선성과 VIF: 아이스크림 자료"; cat("\n=== ", s, " ===\n", sep = "")
preds <- c("price", "income", "temp")
for (j in preds) {
  r2j <- summary(lm(reformulate(setdiff(preds, j), response = j), data = ice))$r.squared
  rec(s, sprintf("R_j^2 (%s on the other two)", j), r2j)
  rec(s, sprintf("1 - R_j^2 (%s)", j), 1 - r2j)
  rec(s, sprintf("VIF (%s)", j), 1 / (1 - r2j))
}
X    <- model.matrix(fit_full)
c_pp <- solve(crossprod(X))["price", "price"]
s_pp <- sum((ice$price - mean(ice$price))^2)
vif_p <- 1 / (1 - summary(lm(price ~ income + temp, data = ice))$r.squared)
rec(s, "[notes] c_jj of price, (X'X)^{-1}[price, price]", c_pp)
rec(s, "[notes] S_pp = sum((price - mean)^2)", s_pp)
rec(s, "[notes] 1 / S_pp (value with no overlap)", 1 / s_pp)
rec(s, "[notes] VIF(price) / S_pp", vif_p / s_pp)
rec(s, "[notes] VIF(price) - 1 (share added by overlap)", vif_p - 1)

# (Slide "진단 후 처방": table of remedies, no data numbers.)

## ---- Slide: "잔차그림과 가정 위반" (six residual shapes) -----------------------
# Simulated teaching panel; nothing is estimated and no number is on the slide.
# Block copied from the latest version, code/agent/2026-11-26/residual-pattern-
# figure.R, with its seed; local() keeps its n, x, e apart from the ice objects.
local({
  set.seed(20260829)

  n <- 160
  x <- seq(0, 1, length.out = n)

  ## AR(1) series for the lag plots; the first 50 draws are discarded because
  ## filter() starts the recursion at 0 and the transient is not AR(1).
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
              bowtie    = "(c) Variance grows then shrinks",
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

  png(file.path(FIG_DIR, "fig-m05-residual-patterns.png"),
      width = 2000, height = 950, res = 150)
  op <- par(mfrow = c(2, 3), mar = c(2.6, 2.8, 3.9, 0.8), cex.lab = 1.15,
            mgp = c(1.3, 0.5, 0))

  for (k in names(pat)) {
    e <- pat[[k]]
    if (k %in% c("pos_ar", "neg_ar")) {
      ## lag plot: each point is one consecutive pair of residuals; the line is
      ## the least-squares slope through the origin (lag-1 autocorrelation)
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
  invisible(dev.off())
})

# (Slide "보정 1: Box-Cox 변환": method only; its notes quote lambda-hat = 0.315,
#  recorded on the next slide.)

## ---- Slide: "보정 1: Box-Cox 적용 예" (Galapagos species) ----------------------
# Block copied from boxcox-gala-transformation.R. Kept at top level (not local())
# because MASS::boxcox() refits the lm through update(), which looks up `gala`
# in the global environment.
s <- "보정 1: Box-Cox 적용 예"; cat("\n=== ", s, " ===\n", sep = "")
gala <- read.csv("docs/data/gala.csv")
rec(s, "n (islands)", nrow(gala))

form <- Species ~ Area + Elevation + Nearest + Scruz + Adjacent

## 1. raw response
fit0 <- lm(form, data = gala)
s0   <- summary(fit0)
sw0  <- shapiro.test(residuals(fit0))
bp0  <- bptest(fit0)
h0   <- fitted(fit0) > median(fitted(fit0))     # upper half of the fitted values

## 2. Box-Cox profile over lambda; 95% CI = lambda within qchisq(0.95, 1)/2 of
##    the maximum of the profile log-likelihood
bc <- boxcox(fit0, lambda = seq(-0.25, 1.0, by = 0.005), plotit = FALSE)
lam_hat <- bc$x[which.max(bc$y)]
cut <- max(bc$y) - qchisq(0.95, 1) / 2
inside <- range(bc$x[bc$y > cut])

## 3. square-root response, the round number inside the interval
fit1 <- lm(sqrt(Species) ~ Area + Elevation + Nearest + Scruz + Adjacent,
           data = gala)
s1   <- summary(fit1)
sw1  <- shapiro.test(residuals(fit1))
bp1  <- bptest(fit1)
h1   <- fitted(fit1) > median(fitted(fit1))

rec(s, "R2, y = Species", s0$r.squared)
rec(s, "R2, y = sqrt(Species)", s1$r.squared)
rec(s, "Shapiro-Wilk p, y = Species", sw0$p.value)
rec(s, "Shapiro-Wilk p, y = sqrt(Species)", sw1$p.value)
rec(s, "Breusch-Pagan p, y = Species", bp0$p.value)
rec(s, "Breusch-Pagan p, y = sqrt(Species)", bp1$p.value)
rec(s, "residual SD ratio, upper/lower fitted half, y = Species",
    sd(residuals(fit0)[h0]) / sd(residuals(fit0)[!h0]))
rec(s, "residual SD ratio, upper/lower fitted half, y = sqrt(Species)",
    sd(residuals(fit1)[h1]) / sd(residuals(fit1)[!h1]))
rec(s, "lambda-hat (grid step 0.005)", lam_hat)
rec(s, "95% CI lower for lambda", inside[1])
rec(s, "95% CI upper for lambda", inside[2])

## 4. Figure: residuals before, the lambda profile, residuals after
png(file.path(FIG_DIR, "fig-m05-boxcox-gala.png"),
    width = 1900, height = 760, res = 150)
op <- par(mfrow = c(1, 3), mar = c(4.6, 4.8, 3.6, 1.0), cex.axis = 1.3,
          cex.lab = 1.55, cex.main = 1.6, mgp = c(2.9, 0.8, 0))

plot(fitted(fit0), residuals(fit0), pch = 21, bg = "#4C72B0", col = "white",
     cex = 1.5, lwd = 1.2, xlab = "Fitted value", ylab = "Residual",
     main = "(a) Before: y = Species")
abline(h = 0, col = "grey40", lwd = 1.8)

plot(bc$x, bc$y, type = "l", lwd = 3, col = "#4C72B0",
     xlab = expression(lambda), ylab = "Profile log-likelihood",
     main = expression(paste("(b) Box-Cox profile for ", lambda)))
abline(h = cut, col = "#C44E52", lwd = 2, lty = 2)
abline(v = inside, col = "#C44E52", lwd = 2, lty = 3)
abline(v = 0.5, col = "grey35", lwd = 2)
text(0.5, max(bc$y) - 0.06 * diff(range(bc$y)), "lambda = 0.5 ",
     pos = 2, col = "grey25", cex = 1.45)
legend("bottomleft", bty = "n", cex = 1.4,
       legend = c(sprintf("lambda-hat = %.3f", lam_hat),
                  sprintf("95%% CI [%.3f, %.3f]", inside[1], inside[2])))

plot(fitted(fit1), residuals(fit1), pch = 21, bg = "#55A868", col = "white",
     cex = 1.5, lwd = 1.2, xlab = "Fitted value", ylab = "Residual",
     main = "(c) After: y = sqrt(Species)")
abline(h = 0, col = "grey40", lwd = 1.8)
par(op)
invisible(dev.off())

# (Slides "보정 2: 분산안정화 변환", "보정 3: 선형화 변환", "변수선택의 필요성",
#  "모형 선택 기준: AIC의 정의", "AIC의 두 항 읽기": theory only; the AIC values
#  quoted in the notes of "AIC의 두 항 읽기" are recorded on the next slide.)

## ---- Slide: "아이스크림 자료: 후보 모형 비교" (R2, adjusted R2, AIC) ----------
# make-lecture-figures.R tab01. stats::AIC() of an lm is -2 log L-hat + 2k with
# k = p + 2 (coefficients plus sigma^2), the definition on the slide.
s <- "아이스크림 자료: 후보 모형 비교"; cat("\n=== ", s, " ===\n", sep = "")
fit_red  <- lm(IC ~ income + temp, data = ice)
fit_temp <- lm(IC ~ temp, data = ice)
models <- list("M1 (price, income, temp)" = fit_full,
               "M2 (income, temp)" = fit_red,
               "M3 (temp)" = fit_temp)
for (m in names(models)) {
  rec(s, paste("R2,", m), summary(models[[m]])$r.squared)
  rec(s, paste("adjusted R2,", m), summary(models[[m]])$adj.r.squared)
  rec(s, paste("AIC,", m), AIC(models[[m]]))
}
# The worked lines on the slide: AIC = n ln(SSE/n) + 2k + n(1 + ln 2 pi)
sse1 <- sum(resid(fit_full)^2)
sse2 <- sum(resid(fit_red)^2)
rec(s, "constant n(1 + ln 2 pi)", n * (1 + log(2 * pi)))
rec(s, "SSE, M1", sse1)
rec(s, "SSE, M2", sse2)
rec(s, "n ln(SSE/n), M1 (exact SSE)", n * log(sse1 / n))
rec(s, "n ln(SSE/n), M2 (exact SSE)", n * log(sse2 / n))
# The slide substitutes the SSE values rounded to 0.0353 and 0.0374; these two
# lines evaluate exactly the printed expressions.
rec(s, "30 ln(0.0353/30) as printed", 30 * log(0.0353 / 30))
rec(s, "30 ln(0.0374/30) as printed", 30 * log(0.0374 / 30))
rec(s, "AIC(M1) = n ln(SSE/n) + 2*5 + n(1 + ln 2 pi)",
    n * log(sse1 / n) + 2 * 5 + n * (1 + log(2 * pi)))
rec(s, "AIC(M2) = n ln(SSE/n) + 2*4 + n(1 + ln 2 pi)",
    n * log(sse2 / n) + 2 * 4 + n * (1 + log(2 * pi)))
rec(s, "p-value of price in the full model",
    summary(fit_full)$coefficients["price", "Pr(>|t|)"])

## ---- Slide: "후진제거법: 탐색 경로" (backward elimination) ---------------------
# AIC* = n ln(SSE/n) + 2(p + 1) is what stats::extractAIC() returns for an lm and
# what step() prints (make-lecture-figures.R ran step(r_full)).
s <- "후진제거법: 탐색 경로"; cat("\n=== ", s, " ===\n", sep = "")
cand <- list("start: price, income, temp" = IC ~ price + income + temp,
             "drop price"                 = IC ~ income + temp,
             "drop income"                = IC ~ price + temp,
             "drop temp"                  = IC ~ price + income,
             "step 2: drop income too (temp only)" = IC ~ temp,
             "step 2: drop temp too (income only)" = IC ~ income)
for (k in names(cand)) rec(s, paste("AIC*,", k), extractAIC(lm(cand[[k]], data = ice))[2])
rec(s, "AIC - AIC* = 2 + n(1 + ln 2 pi)", AIC(fit_full) - extractAIC(fit_full)[2])
rec(s, "AIC*(M2) - AIC*(M1)", extractAIC(fit_red)[2] - extractAIC(fit_full)[2])
rec(s, "AIC(M2) - AIC(M1)", AIC(fit_red) - AIC(fit_full))
rec(s, "-194.62 - (-194.34) as printed", -194.62 - (-194.34))
rec(s, "-107.48 - (-107.21) as printed", -107.48 - (-107.21))
cat("\n  step() trace, cross-check of the path:\n")
invisible(step(fit_full))

## ---- Slide: "선택 후 재진단" (re-diagnosis of the selected model) ---------------
# Figure block copied from code/agent/2026-11-26/make-selected-model-diagnostics.R.
s <- "선택 후 재진단"; cat("\n=== ", s, " ===\n", sep = "")
cf <- coef(fit_red)
rec(s, "intercept", cf[["(Intercept)"]])
rec(s, "income coefficient (x_i2)", cf[["income"]])
rec(s, "temp coefficient (x_i3)", cf[["temp"]])
rec(s, "R2", summary(fit_red)$r.squared)
rec(s, "adjusted R2", summary(fit_red)$adj.r.squared)

png(file.path(FIG_DIR, "fig04-residual-diagnostics.png"),
    width = 1700, height = 1500, res = 170)
par(mfrow = c(2, 2), mar = c(4, 4, 2.5, 1), oma = c(0, 0, 2, 0),
    col.axis = INK2, col.lab = INK, fg = INK2)
plot(fit_red, pch = 16, col = INK2, sub.caption = "")
mtext("Residual diagnostics: selected model (income, temp)", outer = TRUE,
      cex = 1.2, col = INK)
invisible(dev.off())

# (Slide "자동 선택의 한계": no numbers. Slide "실무 적용: 방사선 선량-반응 모형
#  선택": ERR values and counts are quoted from the Life Span Study paper
#  (Carcinogenesis, 2025); no data set for them is in this repository, so they
#  are not reproduced. Slides "이 장의 정리", "참고문헌": no numbers.)

## ---- write the number table ----------------------------------------------------
write.csv(nums, file.path(FIG_DIR, "tab-ch05-numbers.csv"), row.names = FALSE,
          fileEncoding = "UTF-8")
cat("\n", nrow(nums), "numbers written to", file.path(FIG_DIR, "tab-ch05-numbers.csv"), "\n")
cat("figures written to", FIG_DIR, ":\n")
print(list.files(FIG_DIR, pattern = "\\.png$"))
