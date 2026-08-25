# Date        : 2026-08-25
# Description : Flow chart of the eight steps of a regression analysis, drawn
#               with base graphics so the deck stays self-contained (no mermaid,
#               no web fonts, no network at render time).
#               The chart shows what the numbered list could not: the three
#               phases the steps group into, and the feedback loop from step 7
#               (validation) back to step 4 (model specification).
#               Step names follow Chatterjee & Hadi, Regression Analysis by
#               Example, 5th ed., Ch.1, as already quoted on the slide.
#               Run from the project root:
#                 Rscript code/agent/2026-08-25/make-eight-step-flowchart.R
# File        : make-eight-step-flowchart.R

FIG_DIR <- "output/agent/2026-08-25"
dir.create(FIG_DIR, recursive = TRUE, showWarnings = FALSE)

COL_BLUE <- "#2a78d6"
COL_ORANGE <- "#eb6834"
INK <- "#0b0b0b"
INK2 <- "#52514e"
BAND <- c("#eef4fb", "#e7f3ee", "#fdf0e9") # one tint per phase
BAND_EDGE <- c("#c3d9f2", "#bfe0d2", "#f7d3bf")
BOX_FILL <- "#ffffff"

## ---- content ----------------------------------------------------------

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
group_of <- list(1:3, 4:6, 7:8) # which steps sit in which phase

## ---- geometry ---------------------------------------------------------

bx <- c(16, 50, 84) # centre of each phase band
half_b <- 15 # band half-width
half_x <- 12.0 # box half-width (leaves a lane inside the band)
half_y <- 5.4 # box half-height
band_top <- 90
band_bot <- 30

png(
     file.path(FIG_DIR, "fig-i06-eight-steps.png"),
     width = 2300,
     height = 1000,
     res = 165
)
par(mar = c(0, 0, 0, 0))
plot(
     0,
     0,
     type = "n",
     xlim = c(0, 100),
     ylim = c(4, 100),
     axes = FALSE,
     xlab = "",
     ylab = "",
     xaxs = "i",
     yaxs = "i"
)

for (g in 1:3) {
     # phase band
     rect(
          bx[g] - half_b,
          band_bot,
          bx[g] + half_b,
          band_top,
          col = BAND[g],
          border = BAND_EDGE[g],
          lwd = 2
     )
     text(
          bx[g],
          band_top - 4.0,
          phases[[g]]$head,
          font = 2,
          cex = 1.62,
          col = INK
     )
     text(
          bx[g],
          band_top - 8.2,
          phases[[g]]$sub,
          font = 3,
          cex = 1.10,
          col = INK2
     )

     # step boxes, evenly spaced inside the band
     ids <- group_of[[g]]
     ys <- seq(band_top - 16, band_bot + 7, length.out = 3)[seq_along(ids)]
     for (k in seq_along(ids)) {
          i <- ids[k]
          y <- ys[k]
          rect(
               bx[g] - half_x,
               y - half_y,
               bx[g] + half_x,
               y + half_y,
               col = BOX_FILL,
               border = COL_BLUE,
               lwd = 2
          )
          text(bx[g], y + 1.7, steps[[i]][1], font = 2, cex = 1.36, col = INK)
          text(bx[g], y - 2.6, steps[[i]][2], font = 3, cex = 1.04, col = INK2)
          # arrow down to the next box inside the same band
          if (k < length(ids)) {
               arrows(
                    bx[g],
                    y - half_y,
                    bx[g],
                    ys[k + 1] + half_y,
                    length = 0.10,
                    lwd = 2.5,
                    col = COL_BLUE
               )
          }
     }
}

# arrows between the phases
for (g in 1:2) {
     arrows(
          bx[g] + half_b,
          60,
          bx[g + 1] - half_b - 0.4,
          60,
          length = 0.16,
          lwd = 3.5,
          col = COL_BLUE
     )
}

# Feedback loop: step 7 sends you back to step 4.  The return path runs under
# It leaves the right edge of step 7, drops down the empty lane inside band 3,
# runs under the bands, then climbs the lane inside band 2, so that both ends of
# the loop touch the boxes they actually refer to.
fb <- 16 # height of the horizontal return
lane <- bx[2] - half_b + 1.8 # lane inside band 2, left of boxes
lane3 <- bx[3] + half_b - 1.8 # lane inside band 3, right of boxes
y4 <- seq(band_top - 16, band_bot + 7, length.out = 3)[1] # steps 4 and 7 sit here
lines(
     c(bx[3] + half_x, lane3, lane3, lane, lane),
     c(y4, y4, fb, fb, y4),
     lwd = 3,
     col = COL_ORANGE,
     lty = 2
)
arrows(
     lane,
     y4,
     bx[2] - half_x - 0.4,
     y4,
     length = 0.16,
     lwd = 3,
     col = COL_ORANGE
)
text(
     (lane + lane3) / 2,
     fb - 3.8,
     "7단계 모형 검증 결과가 만족스럽지 않은 경우",
     font = 2,
     cex = 1.36,
     col = COL_ORANGE
)
text(
     (lane + lane3) / 2,
     fb - 7.6,
     "Regression analysis is a loop, not a one-way street",
     font = 3,
     cex = 1.07,
     col = COL_ORANGE
)

dev.off()
cat("written:", file.path(FIG_DIR, "fig-i06-eight-steps.png"), "\n")
