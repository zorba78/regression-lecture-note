# Date        : 2026-08-12
# Description : Regenerate the four-panel residual diagnostic figure with
#               enough outer and panel margin to prevent title collisions.
# File        : make-diagnostic-figure.R

FIG_DIR <- "output/agent/2026-08-12"
dir.create(FIG_DIR, recursive = TRUE, showWarnings = FALSE)

ice <- read.csv(
  "references/cnu-regression-lecture-note/강의노트/R 예제/7장/ice.csv.csv",
  header = TRUE
)
fit <- lm(IC ~ income + temp, data = ice)

png(
  filename = file.path(FIG_DIR, "fig04-residual-diagnostics.png"),
  width = 2000,
  height = 1750,
  res = 170
)
par(
  mfrow = c(2, 2),
  mar = c(4.2, 4.2, 3.2, 1),
  oma = c(0, 0, 4.5, 0),
  col.axis = "#52514e",
  col.lab = "#0b0b0b",
  fg = "#52514e"
)
plot(fit)
mtext(
  "Residual Diagnostics for IC ~ income + temp",
  outer = TRUE,
  line = 1.2,
  cex = 1.2,
  col = "#0b0b0b"
)
dev.off()
