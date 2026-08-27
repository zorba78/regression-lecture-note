# Date        : 2026-08-27
# NOTE        : SUPERSEDED as the slide figure by make-r2-adjr2-schematic.R.
#               Kept because the numbers it prints are quoted in the notes:
#               on this data all three predictors carry information, so the
#               adjusted-R2 downturn never appears and the figure could not
#               make the teaching point. Writes fig-m01b-... so the two do not
#               collide.
# Description : Figure for the chapter 4 slide on how R2, adjusted R2 and SSE
#               move together. Fits ALL eight subsets of the three ice cream
#               predictors (price, income, temp) and plots them against the
#               number of predictors p.
#
#               The teaching point is the contrast between the two panels:
#                 left  - SSE can only fall as a predictor is added, and R2 is
#                         its mirror image because R2 = 1 - SSE/SST with SST
#                         fixed. So R2 alone can never argue against adding a
#                         variable.
#                 right - adjusted R2 divides each sum of squares by its degrees
#                         of freedom, so it can and does fall when the added
#                         variable buys less than it costs.
#
#               Every plotted value is printed so the slide can quote it.
# File        : make-r2-adjr2-sse-figure.R

options(digits = 10)

ice <- read.csv("../../../references/cnu-regression-lecture-note/강의노트/R 예제/7장/ice.csv.csv")
names(ice) <- tolower(names(ice))
n <- nrow(ice)
SST <- sum((ice$ic - mean(ice$ic))^2)

vars <- c("price", "income", "temp")
subsets <- unlist(lapply(0:3, function(k) combn(vars, k, simplify = FALSE)),
                  recursive = FALSE)

res <- do.call(rbind, lapply(subsets, function(v) {
  f <- if (length(v)) paste("ic ~", paste(v, collapse = " + ")) else "ic ~ 1"
  m <- lm(as.formula(f), data = ice)
  p <- length(v)
  SSE <- sum(residuals(m)^2)
  data.frame(p = p,
             label = if (p) paste(substr(v, 1, 2), collapse = "+") else "none",
             SSE = SSE,
             R2 = 1 - SSE / SST,
             # adjusted R2 is undefined in the usual sense for the null model;
             # the formula still evaluates and gives 0 there.
             adjR2 = 1 - (SSE / (n - p - 1)) / (SST / (n - 1)),
             stringsAsFactors = FALSE)
}))
res <- res[order(res$p), ]
cat("SST =", SST, "   n =", n, "\n\n")
print(res, row.names = FALSE)

# The highlighted path is NESTED and chosen because it actually shows the
# phenomenon: price -> price+income -> price+income+temp. Adding income to price
# raises R2 by 0.0004 and DROPS adjusted R2 from 0.031 to -0.004, because the
# variable buys less than the degree of freedom it costs. The best-SSE path was
# tried first and was useless for teaching - on this data its adjusted R2 rises
# at every step, so the caption would have had no example to point at.
path_labels <- c("none", "pr", "pr+in", "pr+in+te")
path <- res[match(path_labels, res$label), ]
cat("
highlighted nested path (price -> +income -> +temp):
")
print(path, row.names = FALSE)
cat("
step p=1 -> p=2:  R2", path$R2[2], "->", path$R2[3],
    " (change", path$R2[3] - path$R2[2], ")
")
cat("                  adjR2", path$adjR2[2], "->", path$adjR2[3],
    " (change", path$adjR2[3] - path$adjR2[2], ")
")

out <- "../../../output/agent/2026-08-27"
dir.create(out, showWarnings = FALSE, recursive = TRUE)
png(file.path(out, "fig-m01b-r2-adjr2-sse-icecream.png"),
    width = 2100, height = 950, res = 150)

par(mfrow = c(1, 2), mar = c(4.4, 5.2, 3.0, 2.6), family = "sans",
    cex.lab = 1.15, cex.axis = 1.05)

# --- left panel: SSE ------------------------------------------------------
plot(res$p, res$SSE, type = "n", xaxt = "n", las = 1, bty = "n",
     xlab = "Number of predictors p", ylab = "SSE",
     main = "SSE never rises when a predictor is added",
     cex.main = 1.15, font.main = 1,
     xlim = c(-0.15, 3.35), ylim = c(0, max(res$SSE) * 1.08))
axis(1, at = 0:3)
points(res$p, res$SSE, pch = 19, col = "#c3ced6", cex = 1.4)
lines(path$p, path$SSE, col = "#e8552d", lwd = 3)
points(path$p, path$SSE, pch = 19, col = "#e8552d", cex = 1.8)
text(path$p, path$SSE, labels = sprintf("%.4f", path$SSE),
     pos = c(4, 3, 3, 3), offset = 0.7, col = "#e8552d", cex = 1.02)

# --- right panel: R2 and adjusted R2 --------------------------------------
plot(res$p, res$R2, type = "n", xaxt = "n", las = 1, bty = "n",
     xlab = "Number of predictors p", ylab = "",
     main = "R-squared always rises, adjusted R-squared need not",
     cex.main = 1.15, font.main = 1,
     xlim = c(-0.15, 3.35), ylim = c(-0.12, 0.86))
axis(1, at = 0:3)
abline(h = 0, col = "#d8d8d8")
points(res$p, res$R2,    pch = 19, col = "#c3ced6", cex = 1.25)
points(res$p, res$adjR2, pch = 17, col = "#c3ced6", cex = 1.25)
lines(path$p, path$R2,    col = "#3b9ab2", lwd = 3)
points(path$p, path$R2,    pch = 19, col = "#3b9ab2", cex = 1.8)
lines(path$p, path$adjR2, col = "#c1663f", lwd = 3, lty = 2)
points(path$p, path$adjR2, pch = 17, col = "#c1663f", cex = 1.8)
text(path$p, path$R2, labels = sprintf("%.3f", path$R2),
     pos = c(4, 3, 3, 1), offset = 0.75, col = "#3b9ab2", cex = 1.02)
text(path$p, path$adjR2, labels = sprintf("%.3f", path$adjR2),
     pos = c(4, 1, 1, 3), offset = 0.75, col = "#c1663f", cex = 1.02)
# Call out the one step where the two measures disagree.
arrows(1.5, 0.28, 1.5, 0.10, length = 0.10, col = "#8a8a8a", lwd = 1.5)
text(1.5, 0.395, adj = c(0.5, 0), col = "#52514e", cex = 1.02,
     labels = "adding income:")
text(1.5, 0.315, adj = c(0.5, 0), col = "#52514e", cex = 1.02,
     labels = "R2 +0.0004, adj R2 -0.035")
legend("topleft", bty = "n", cex = 1.05, inset = c(0, 0),
       legend = c("R-squared", "adjusted R-squared", "all 8 subsets"),
       lty = c(1, 2, NA), lwd = c(3, 3, NA), pch = c(19, 17, 19),
       col = c("#3b9ab2", "#c1663f", "#c3ced6"))

dev.off()
cat("
file written:", file.path(out, "fig-m01b-r2-adjr2-sse-icecream.png"), "
")

# The identity the left panel and the right panel share.
cat("\ncheck R2 = 1 - SSE/SST on the full model:",
    1 - res$SSE[res$label == "pr+in+te"] / SST, "\n")
