# Date        : 2026-08-26
# Description : Figure for the Introduction slide "4단계 모형 설정: 어떤 선을
#               그을 것인가".  Draws the ice cream scatter (consumption vs
#               temperature) with the three candidate shapes listed on that
#               slide overlaid: a straight line, a quadratic in temperature,
#               and a log transform of temperature.  No goodness-of-fit number
#               is printed on the figure on purpose -- the slide asks the
#               audience which shape they would commit to, and the criterion
#               for answering that is step 5, one slide later.
#
#               Data: references/cnu-regression-lecture-note/강의노트/R 예제/
#               7장/ice.csv.csv (n = 30 four-week periods).
#
#               Canvas is wide and short so the slide can carry the figure at
#               full width and still fit the two callouts underneath.
#
#               Run from the project root:
#                 Rscript code/agent/2026-08-26/make-candidate-curves-figure.R
# File        : make-candidate-curves-figure.R

FIG_DIR <- "output/agent/2026-08-26"
dir.create(FIG_DIR, recursive = TRUE, showWarnings = FALSE)

COL_BLUE   <- "#2a78d6"
COL_ORANGE <- "#eb6834"
COL_GREEN  <- "#1c8f6b"
INK        <- "#0b0b0b"
INK2       <- "#52514e"
GRID_C     <- "#e1e0d9"

ice <- read.csv("references/cnu-regression-lecture-note/강의노트/R 예제/7장/ice.csv.csv",
                stringsAsFactors = FALSE)

# The three shapes named on the slide, in the same order
f_line <- lm(IC ~ temp, data = ice)
f_quad <- lm(IC ~ temp + I(temp^2), data = ice)
f_log  <- lm(IC ~ log(temp), data = ice)

# Console only: reported to the user, deliberately kept off the slide
cat(sprintf("n = %d, temp %.0f-%.0f, IC %.3f-%.3f\n",
            nrow(ice), min(ice$temp), max(ice$temp),
            min(ice$IC), max(ice$IC)))
for (nm in c("line", "quad", "log")) {
  m <- get(paste0("f_", nm))
  cat(sprintf("%-5s  R2 = %.4f  adj.R2 = %.4f\n",
              nm, summary(m)$r.squared, summary(m)$adj.r.squared))
}

grd <- data.frame(temp = seq(min(ice$temp), max(ice$temp), length.out = 300))

# The slide places this figure under a single callout, leaving about 500 px of
# height.  The canvas is 2.05:1 and the slide shows it at 90% width, so the
# panel keeps its height without running the full width of the slide.  The
# plot title is omitted because the slide heading already asks the question.
png(file.path(FIG_DIR, "fig-i07-candidate-curves.png"),
    width = 2050, height = 1000, res = 150)
par(mar = c(4.2, 4.6, 1.0, 1), col.axis = INK2, col.lab = INK, fg = INK2)
plot(ice$temp, ice$IC, type = "n",
     xlab = "Mean temperature (Fahrenheit)",
     ylab = "Ice cream consumption (pints per capita)")
grid(col = GRID_C, lty = 1)
box(col = INK2)

points(ice$temp, ice$IC, pch = 16,
       col = adjustcolor(INK2, alpha.f = 0.55), cex = 1.4)

lines(grd$temp, predict(f_line, grd), col = COL_BLUE,   lwd = 3.2, lty = 1)
lines(grd$temp, predict(f_quad, grd), col = COL_ORANGE, lwd = 3.2, lty = 2)
lines(grd$temp, predict(f_log,  grd), col = COL_GREEN,  lwd = 3.2, lty = 3)

legend("topleft", bty = "o", bg = "white", box.col = GRID_C,
       lwd = 3.2, lty = c(1, 2, 3),
       col = c(COL_BLUE, COL_ORANGE, COL_GREEN),
       legend = c("Straight line in temp",
                  "Quadratic in temp",
                  "Log of temp"),
       text.col = INK)
dev.off()

cat("written:", file.path(FIG_DIR, "fig-i07-candidate-curves.png"), "\n")
