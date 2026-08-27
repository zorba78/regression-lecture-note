# Date        : 2026-08-27
# Description : Verify every number used on the new eigenvalue / spectral
#               decomposition slides of chapter 2 (Preliminary Knowledge).
#               Three blocks:
#                 (1) a clean symmetric 2x2 example, A = [[2,1],[1,2]]
#                 (2) the idempotent J = 0.5 * ones(2,2) already on the
#                     idempotent slide, decomposed with the SAME eigenvectors
#                     as A so the two slides connect
#                 (3) the hat matrix H of the ice cream full model, to confirm
#                     its eigenvalues are exactly p+1 ones and n-p-1 zeros,
#                     which is what makes tr(H) = p + 1
#               Everything is printed with its derivation so the slide numbers
#               can be checked line by line.
# File        : verify-spectral-decomposition.R

options(digits = 10)

cat("=== (1) symmetric example  A = [[2,1],[1,2]] ===\n")
A <- matrix(c(2, 1, 1, 2), nrow = 2)
print(A)
ea <- eigen(A, symmetric = TRUE)
cat("eigenvalues :", ea$values, "\n")
cat("eigenvectors (columns, unit length):\n"); print(ea$vectors)
cat("1/sqrt(2) =", 1 / sqrt(2), "\n")

# The two identities the slide claims: trace = sum of eigenvalues,
# determinant = product of eigenvalues.
cat("tr(A)  =", sum(diag(A)), "  sum(lambda)  =", sum(ea$values), "\n")
cat("det(A) =", det(A),        "  prod(lambda) =", prod(ea$values), "\n")

# Reconstruct A from Q Lambda Q' and from the sum of rank-one pieces.
Q <- ea$vectors; L <- diag(ea$values)
cat("max |A - Q L Q'| =", max(abs(A - Q %*% L %*% t(Q))), "\n")
rank1 <- ea$values[1] * ea$vectors[, 1] %*% t(ea$vectors[, 1]) +
         ea$values[2] * ea$vectors[, 2] %*% t(ea$vectors[, 2])
cat("max |A - sum lambda_j q_j q_j'| =", max(abs(A - rank1)), "\n")
cat("Q'Q = I ?  max |Q'Q - I| =", max(abs(t(Q) %*% Q - diag(2))), "\n")

cat("\n=== (2) idempotent  J = 0.5 * ones(2,2) ===\n")
J <- matrix(0.5, nrow = 2, ncol = 2)
print(J)
cat("J %*% J == J ?  max |JJ - J| =", max(abs(J %*% J - J)), "\n")
ej <- eigen(J, symmetric = TRUE)
cat("eigenvalues :", ej$values, "\n")
cat("eigenvectors (columns):\n"); print(ej$vectors)
cat("tr(J) =", sum(diag(J)), "  = number of eigenvalues equal to 1 =",
    sum(abs(ej$values - 1) < 1e-12), "\n")
cat("rank(J) =", qr(J)$rank, "\n")
# The rank-one form the slide shows: J = 1 * q1 q1' + 0 * q2 q2'
q1 <- c(1, 1) / sqrt(2)
cat("q1 q1' =\n"); print(q1 %*% t(q1))
cat("max |J - q1 q1'| =", max(abs(J - q1 %*% t(q1))), "\n")

cat("\n=== (3) hat matrix of the ice cream full model ===\n")
ice <- read.csv("../../../references/cnu-regression-lecture-note/강의노트/R 예제/7장/ice.csv.csv")
names(ice) <- tolower(names(ice))
X <- model.matrix(~ price + income + temp, data = ice)
n <- nrow(X); p <- ncol(X) - 1
cat("n =", n, "  p =", p, "  p+1 =", p + 1, "\n")
H <- X %*% solve(t(X) %*% X) %*% t(X)
cat("H symmetric ?  max |H - H'| =", max(abs(H - t(H))), "\n")
cat("H idempotent ? max |HH - H| =", max(abs(H %*% H - H)), "\n")
eh <- eigen(H, symmetric = TRUE)$values
cat("eigenvalues near 1 :", sum(abs(eh - 1) < 1e-8), "\n")
cat("eigenvalues near 0 :", sum(abs(eh) < 1e-8), "\n")
cat("tr(H)     =", sum(diag(H)), "  = p+1 =", p + 1, "\n")
cat("tr(I - H) =", sum(diag(diag(n) - H)), "  = n-p-1 =", n - p - 1, "\n")
cat("rank(H)   =", qr(H)$rank, "\n")
