# Date        : 2026-08-25
# Description : Re-draw the local-means figure with a wider, shorter canvas so
#               the slide can show it at full width with the explanation text
#               placed underneath.  Data reading and drawing code are copied
#               unchanged from code/agent/2026-08-24/make-galton-real-figures.R
#               (fig-i03); only the canvas proportions differ (1800x1100 ->
#               2150x1000).
#               Run from the project root:
#                 Rscript code/agent/2026-08-25/make-local-means-figure.R
# File        : make-local-means-figure.R

FIG_DIR <- "output/agent/2026-08-25"
dir.create(FIG_DIR, recursive = TRUE, showWarnings = FALSE)

COL_BLUE   <- "#2a78d6"
COL_ORANGE <- "#eb6834"
INK        <- "#0b0b0b"
INK2       <- "#52514e"
GRID_C     <- "#e1e0d9"
BAND_A     <- "#dce9f7"   # alternating bin bands (both visible)
BAND_B     <- "#f0f5fb"
BAND_DROP  <- "#f2f1ee"   # bins too sparse to give a usable local mean

g   <- read.delim("data/derived-data/galton-stata11.tab", stringsAsFactors = FALSE)
son <- subset(g, gender == "M", select = c(father, height))
names(son) <- c("father", "son")
fit <- lm(son ~ father, data = son)

MIN_N <- 10          # a local mean on fewer than 10 sons is too noisy to plot

brk  <- seq(floor(min(son$father)), ceiling(max(son$father)), by = 1)
bin  <- cut(son$father, breaks = brk, include.lowest = TRUE)
locm <- tapply(son$son, bin, mean)
locn <- tapply(son$son, bin, length)
ctr  <- brk[-length(brk)] + 0.5
keep <- !is.na(locm) & locn >= MIN_N

png(file.path(FIG_DIR, "fig-i03-local-means.png"),
    width = 2150, height = 1000, res = 170)
par(mar = c(4.5, 4.5, 3, 1), col.axis = INK2, col.lab = INK, fg = INK2)
plot(son$father, son$son, type = "n",
     main = "Local Means Trace Out the Regression Line",
     xlab = "Father's height (inches)", ylab = "Son's height (inches)")

# Alternating vertical bands: one band per 1-inch bin. Bins that are actually
# used for a plotted local mean are tinted; sparse bins are left grey so the
# audience can see why no diamond is drawn there.
usr <- par("usr")
kept <- 0
for (i in seq_len(length(brk) - 1)) {
  if (isTRUE(keep[i])) {
    kept <- kept + 1
    fill <- if (kept %% 2 == 1) BAND_A else BAND_B   # every interval visible
  } else {
    fill <- BAND_DROP                                # sparse bin, no diamond
  }
  rect(brk[i], usr[3], brk[i + 1], usr[4], col = fill, border = NA)
  abline(v = brk[i], col = adjustcolor(INK2, alpha.f = 0.35), lty = 3)
}
abline(v = brk[length(brk)], col = adjustcolor(INK2, alpha.f = 0.35), lty = 3)
grid(col = GRID_C, lty = 1)
box(col = INK2)

points(son$father, son$son, pch = 16,
       col = adjustcolor(INK2, alpha.f = 0.30), cex = 0.8)
abline(fit, col = COL_BLUE, lwd = 3)
# Join the local means so the audience literally sees them tracing the line
lines(ctr[keep], locm[keep], col = COL_ORANGE, lwd = 2, lty = 2)
points(ctr[keep], locm[keep], pch = 18, col = COL_ORANGE, cex = 2.4)
legend("topleft", bty = "o", bg = "white", box.col = GRID_C,
       lwd = c(3, 2, NA), lty = c(1, 2, NA), pch = c(NA, 18, 22),
       pt.cex = c(NA, 2.2, 2.2), pt.bg = c(NA, NA, BAND_A),
       col = c(COL_BLUE, COL_ORANGE, adjustcolor(INK2, alpha.f = 0.5)),
       legend = c("Least-squares line",
                  sprintf("Mean son height per 1-inch bin (n >= %d)", MIN_N),
                  "Shaded band = one binning interval"),
       text.col = INK)
dev.off()

cat("written:", file.path(FIG_DIR, "fig-i03-local-means.png"), "\n")
