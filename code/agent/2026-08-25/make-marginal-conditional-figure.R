# Date        : 2026-08-25
# Description : Re-draw the marginal-vs-conditional histogram pair with a wider,
#               shorter canvas so the slide can show it at full width and place
#               the two question boxes directly beneath the matching panel.
#               Data reading and drawing code are copied unchanged from
#               code/agent/2026-08-24/make-galton-real-figures.R (fig-i02);
#               only the canvas proportions differ (2000x1000 -> 2000x780).
#               Run from the project root:
#                 Rscript code/agent/2026-08-25/make-marginal-conditional-figure.R
# File        : make-marginal-conditional-figure.R

FIG_DIR <- "output/agent/2026-08-25"
dir.create(FIG_DIR, recursive = TRUE, showWarnings = FALSE)

COL_RED   <- "#e34948"
INK       <- "#0b0b0b"
INK2      <- "#52514e"
FILL_GREY <- "#d8d7d2"

g   <- read.delim("data/derived-data/galton-stata11.tab", stringsAsFactors = FALSE)
son <- subset(g, gender == "M", select = c(father, height))
names(son) <- c("father", "son")

slice <- son[abs(son$father - 72) < 0.75, ]

png(file.path(FIG_DIR, "fig-i02-marginal-vs-conditional.png"),
    width = 2000, height = 780, res = 170)
par(mfrow = c(1, 2), mar = c(4.5, 4.5, 3.5, 1),
    col.axis = INK2, col.lab = INK, fg = INK2)

hist(son$son, breaks = 24, col = FILL_GREY, border = "white",
     main = sprintf("(a) All sons  (n = %d)", nrow(son)),
     xlab = "Son's height (inches)", ylab = "Frequency")
abline(v = mean(son$son), col = COL_RED, lwd = 3)
text(mean(son$son), par("usr")[4] * 0.92,
     labels = sprintf(" mean = %.1f", mean(son$son)), col = COL_RED, pos = 4)

hist(slice$son, breaks = 10, col = FILL_GREY, border = "white",
     main = sprintf("(b) Sons whose father is about 72 in  (n = %d)", nrow(slice)),
     xlab = "Son's height (inches)", ylab = "Frequency")
abline(v = mean(slice$son), col = COL_RED, lwd = 3)
text(mean(slice$son), par("usr")[4] * 0.92,
     labels = sprintf(" mean = %.1f", mean(slice$son)), col = COL_RED, pos = 4)
dev.off()

# numbers quoted on the slide and in its speaker notes
cat(sprintf("all sons          : mean %.2f  (n = %d)\n", mean(son$son), nrow(son)))
cat(sprintf("father ~ 72 slice : mean %.2f  (n = %d)\n", mean(slice$son), nrow(slice)))
cat(sprintf("fitted E(Y|X=72)  : %.2f\n",
            predict(lm(son ~ father, data = son), data.frame(father = 72))))
