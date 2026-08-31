# -----------------------------------------------------------------------------
# Created : 2026-08-31
# File    : code/agent/2026-08-31/export-data.R
# Purpose : Write every dataset used in the lecture to plain CSV for the
#           download page. The audience does not use R, so pointing them at
#           data(trees) or faraway::gala is not an option -- each set has to be
#           a text file they can open in Excel.
#
#           gala is not on CRAN here and faraway is not installed; the copy is
#           read from a session scratchpad that will not survive, so writing it
#           into the repository is also what preserves it.
# -----------------------------------------------------------------------------

root <- "G:/Projects/regression-lecture-note"
out  <- file.path(root, "docs", "data")
dir.create(out, showWarnings = FALSE, recursive = TRUE)

w <- function(df, name) {
  path <- file.path(out, name)
  write.csv(df, path, row.names = FALSE, fileEncoding = "UTF-8")
  cat(sprintf("%-26s %4d x %2d  %6d B\n", name, nrow(df), ncol(df),
              file.info(path)$size))
}

## ---- ice cream: the running example --------------------------------------
ice <- read.csv(file.path(root, "references/cnu-regression-lecture-note",
                          "강의노트/R 예제/7장/ice.csv.csv"))
w(ice, "ice.csv")

## ---- Galton family heights: convert the tab-delimited original -----------
galton <- read.delim(file.path(root, "data/derived-data/galton-stata11.tab"),
                     stringsAsFactors = FALSE)
w(galton, "galton.csv")

## ---- black cherry trees (ch 01, curvature in the residuals) --------------
w(datasets::trees, "trees.csv")

## ---- Lake Huron level (ch 06, autocorrelation and GLS) ------------------
lh <- data.frame(year = as.numeric(time(datasets::LakeHuron)),
                 level = as.numeric(datasets::LakeHuron))
w(lh, "lake-huron.csv")

## ---- Galapagos species (ch 05, Box-Cox) ---------------------------------
gala_rda <- file.path("C:/Users/user/AppData/Local/Temp/claude",
                      "g--Projects-regression-lecture-note",
                      "193236f0-e008-4bc6-b4a3-4409708d888c/scratchpad",
                      "alsm/faraway/data/gala.rda")
if (file.exists(gala_rda)) {
  load(gala_rda)
  gala <- data.frame(island = rownames(gala), gala, row.names = NULL)
  w(gala, "gala.csv")
} else {
  cat("gala.rda missing - gala.csv not written\n")
}

## ---- physical measurement example (ch 06, known measurement variance) ---
# Values as used in code/agent/2026-08-11/make-lecture-figures.R.
phys <- data.frame(
  x = c(0.345, 0.287, 0.251, 0.255, 0.207, 0.186, 0.161, 0.132, 0.084, 0.060),
  y = c(367, 311, 295, 268, 253, 239, 220, 213, 193, 192),
  w = c(17, 9, 9, 7, 7, 6, 6, 6, 5, 5)
)
w(phys, "physical-measurement.csv")
