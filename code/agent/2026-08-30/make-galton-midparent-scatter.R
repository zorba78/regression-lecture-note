# Date        : 2026-08-30
# Description : Redraw the Introduction slide-7 scatter plot so that it matches
#               the speaker notes the user rewrote for "Galton과 회귀의 기원".
#
#               The notes now describe Galton's own analysis, not a father-son
#               subset:
#                 - 197 families, 898 children (the 31 children of the
#                   205-family, 928-child paper whose parental heights are
#                   incomplete are already absent from this file);
#                 - the mother's height is rescaled by 1.08 and averaged with
#                   the father's to give the "mid-parent" height;
#                 - a RED line marks the 1:1 relation y = x, and a BLUE line
#                   with the flatter slope is the fitted regression line.
#
#               Galton, F. (1886), p. 246: "in every case I transmuted the
#               female statures to their corresponding male equivalents and
#               used them in their transmuted form" -- the factor 1.08 is
#               therefore applied to daughters as well as to mothers, otherwise
#               sons and daughters form two separate clouds roughly 5 inches
#               apart and the y = x line has no meaning.
#
#               Data : data/derived-data/galton-stata11.tab (898 rows, 197 families)
#               Style: palette and png settings follow
#                      code/agent/2026-08-24/make-galton-real-figures.R
#
#               Run from the project root:
#                 Rscript code/agent/2026-08-30/make-galton-midparent-scatter.R
# File        : make-galton-midparent-scatter.R

## ---- setup ------------------------------------------------------------

FIG_DIR <- "output/agent/2026-08-30"
dir.create(FIG_DIR, recursive = TRUE, showWarnings = FALSE)

COL_BLUE <- "#2a78d6"   # fitted regression line
COL_RED  <- "#e34948"   # y = x reference line
INK      <- "#0b0b0b"
INK2     <- "#52514e"
GRID_C   <- "#e1e0d9"

open_png <- function(file, w = 1800, h = 1100, res = 170) {
  png(file.path(FIG_DIR, file), width = w, height = h, res = res)
}

## ---- Galton's transmutation -------------------------------------------

g <- read.delim("data/derived-data/galton-stata11.tab", stringsAsFactors = FALSE)

# mid-parent = (father + 1.08 * mother) / 2 ; daughters likewise transmuted
g$midparent <- (g$father + 1.08 * g$mother) / 2
g$child     <- ifelse(g$gender == "F", 1.08 * g$height, g$height)

fit <- lm(child ~ midparent, data = g)
B0  <- coef(fit)[1]
B1  <- coef(fit)[2]

cat("===== Galton family data: mid-parent -> child =====\n")
cat(sprintf("children : %d   families : %d   (sons %d, daughters %d)\n",
            nrow(g), length(unique(g$family)),
            sum(g$gender == "M"), sum(g$gender == "F")))
print(summary(fit))
cat(sprintf("\nr = %.4f   mean mid-parent = %.3f   mean child = %.3f\n",
            cor(g$midparent, g$child), mean(g$midparent), mean(g$child)))

# The slide's story in numbers: a mid-parent 4 inches above the parental mean
# has children on average B1 * 4 inches above the children's mean. Galton's
# published law was 2/3; least squares on this file gives a slightly steeper
# slope, so the two numbers are reported side by side.
cat(sprintf("mid-parent +4 in above its mean -> child %+.3f in above its mean\n",
            4 * B1))
cat(sprintf("Galton's 2/3 law would give %+.3f in\n", 4 * 2 / 3))

## ---- fig-i01: mid-parent vs child, with y = x in red ------------------

open_png("fig-i01-galton-scatter.png")
par(mar = c(4.5, 4.5, 3, 1), col.axis = INK2, col.lab = INK, fg = INK2)
plot(g$midparent, g$child,
     pch = 16, col = adjustcolor(INK2, alpha.f = 0.35), cex = 0.8,
     panel.first = grid(col = GRID_C, lty = 1),
     main = "Mid-Parent Height vs Child Height (Galton's family records)",
     xlab = "Mid-parent height (inches)", ylab = "Child height (inches)")

# Thin crosshair at the two means: the notes read the plot in DEVIATIONS from
# the mean, and the two means are almost identical (69.22 vs 69.23), so the
# y = x line passes through the centre of the cloud.
abline(v = mean(g$midparent), col = adjustcolor(INK2, alpha.f = 0.45), lty = 3)
abline(h = mean(g$child),     col = adjustcolor(INK2, alpha.f = 0.45), lty = 3)

# Red: perfect transmission. Blue: what the data actually show -- a flatter
# slope, so tall parents' children fall below equality and short parents'
# children rise above it.
abline(a = 0, b = 1, col = COL_RED, lwd = 3)
abline(fit, col = COL_BLUE, lwd = 3)

legend("topleft", bty = "o", bg = "white", box.col = GRID_C,
       lwd = c(3, 3), lty = c(1, 1), col = c(COL_RED, COL_BLUE),
       legend = c("y = x  (children exactly as tall as their parents)",
                  sprintf("Fitted line: y = %.2f + %.3f x", B0, B1)),
       text.col = INK)
dev.off()

cat(sprintf("\nwritten: %s\n", file.path(FIG_DIR, "fig-i01-galton-scatter.png")))
