# Date        : 2026-08-26
# Description : Verify every number that goes on the five new matrix slides of
#               02-preliminary-knowledge.qmd (determinant, orthogonality, trace,
#               idempotent matrix, vector/matrix differentiation).  Nothing is
#               written to the slides unless it is reproduced here, so each
#               printed line is the derivation behind one printed figure.
#
#               Sections
#                 0  transpose of a vector and of a matrix, and (AB)' = B'A'
#                 1  determinant of a 2x2, and of a singular 2x2
#                 2  determinant of X'X for the ice cream full model, and what
#                    happens when a perfectly collinear column is appended
#                 2b rank: why the singular example has det = 0, and the rank of
#                    the ice cream design matrix with and without the extra column
#                 3  inner product, orthogonality, Pythagoras on a 2-vector pair
#                 4  trace, and tr(AB) = tr(BA) on non-square factors
#                 5  a symmetric idempotent 2x2 and its complement
#                 6  hat matrix of the ice cream model: symmetry, idempotency,
#                    trace = p+1 and trace(I-H) = n-p-1
#                 7  normal equations solved by hand vs lm()
#
#               Run from the project root:
#                 Rscript code/agent/2026-08-26/verify-matrix-toolbox-numbers.R
# File        : verify-matrix-toolbox-numbers.R

ice <- read.csv("references/cnu-regression-lecture-note/강의노트/R 예제/7장/ice.csv.csv",
                stringsAsFactors = FALSE)

hr <- function(s) cat("\n== ", s, " ", strrep("=", max(0, 56 - nchar(s))), "\n", sep = "")

## 0  transpose ---------------------------------------------------------------
hr("0  transpose of a vector and of a matrix")
y3 <- matrix(ice$IC[1:3], ncol = 1)          # first three responses, 3 x 1
cat("y (3x1) =\n"); print(y3)
cat("t(y) (1x3) =\n"); print(t(y3))

M <- matrix(1:6, nrow = 2, byrow = TRUE)     # 2 x 3
cat("\nM (2x3) =\n"); print(M)
cat("t(M) (3x2) =\n"); print(t(M))
cat(sprintf("t(t(M)) == M : %s\n", isTRUE(all.equal(t(t(M)), M))))

# (AB)' = B'A' : the order flips.  Checked on a 2x3 times 3x2 product.
N <- matrix(c(1, 0, 2, 1, 0, 3), nrow = 3, byrow = TRUE)   # 3 x 2
cat("\nMN (2x2) =\n"); print(M %*% N)
cat("t(MN) =\n"); print(t(M %*% N))
cat("t(N) %*% t(M) =\n"); print(t(N) %*% t(M))
cat(sprintf("(MN)' == N'M' : %s\n", isTRUE(all.equal(t(M %*% N), t(N) %*% t(M)))))

## 1  determinant of a 2x2 -----------------------------------------------------
hr("1  determinant of a 2x2")
A <- matrix(c(2, 1, 1, 1), nrow = 2, byrow = TRUE)   # the matrix already on the 전치/역행렬 slide
cat("A =\n"); print(A)
cat(sprintf("det(A) = 2*1 - 1*1 = %g\n", det(A)))
cat("A^{-1} =\n"); print(solve(A))

S <- matrix(c(2, 1, 4, 2), nrow = 2, byrow = TRUE)   # row 2 = 2 * row 1
cat("\nS =\n"); print(S)
cat(sprintf("det(S) = 2*2 - 1*4 = %g\n", det(S)))
cat("solve(S) ->\n")
cat(tryCatch({ solve(S); "no error" },
             error = function(e) paste("Error:", conditionMessage(e))), "\n")

## 2  determinant of X'X, with and without an exactly collinear column ---------
hr("2  det(X'X) for the ice cream full model")
X <- cbind(1, ice$price, ice$income, ice$temp)
colnames(X) <- c("(Intercept)", "price", "income", "temp")
XtX <- t(X) %*% X
cat(sprintf("dim(X) = %d x %d\n", nrow(X), ncol(X)))
cat(sprintf("det(X'X) = %.6e   (not zero -> the inverse exists)\n", det(XtX)))

# temp in Celsius is an exact linear function of the intercept and temp:
#   tempC = -160/9 * 1 + 5/9 * temp
tempC <- (ice$temp - 32) * 5 / 9
X2 <- cbind(X, tempC = tempC)
cat(sprintf("\ndet(X'X) with tempC appended = %.6e\n", det(t(X2) %*% X2)))
cat(sprintf("rank(X) = %d of %d columns, rank(X2) = %d of %d columns\n",
            qr(X)$rank, ncol(X), qr(X2)$rank, ncol(X2)))
cat("solve(X2'X2) ->\n")
cat(tryCatch({ solve(t(X2) %*% X2); "no error" },
             error = function(e) paste("Error:", conditionMessage(e))), "\n")

## 2b rank ---------------------------------------------------------------------
hr("2b rank: the reason det = 0")
cat(sprintf("rank(A) = %d of 2 columns -> full rank, det = %g\n", qr(A)$rank, det(A)))
cat(sprintf("rank(S) = %d of 2 columns -> rank deficient, det = %g\n", qr(S)$rank, det(S)))
cat(sprintf("\nrank(X)   = %d of %d,  rank(X'X)   = %d\n",
            qr(X)$rank, ncol(X), qr(XtX)$rank))
cat(sprintf("rank(X2)  = %d of %d,  rank(X2'X2) = %d   (the extra column adds no rank)\n",
            qr(X2)$rank, ncol(X2), qr(t(X2) %*% X2)$rank))

## 3  inner product, orthogonality, Pythagoras ---------------------------------
hr("3  orthogonality of a = (1,2)' and b = (-2,1)'")
a <- c(1, 2); b <- c(-2, 1)
cat(sprintf("a'b = 1*(-2) + 2*1 = %g\n", sum(a * b)))
cat(sprintf("||a||^2 = 1^2 + 2^2 = %g,  ||b||^2 = (-2)^2 + 1^2 = %g\n",
            sum(a^2), sum(b^2)))
cat(sprintf("a + b = (%g, %g),  ||a+b||^2 = %g  vs  ||a||^2 + ||b||^2 = %g\n",
            (a + b)[1], (a + b)[2], sum((a + b)^2), sum(a^2) + sum(b^2)))

## 4  trace --------------------------------------------------------------------
hr("4  trace, and tr(AB) = tr(BA)")
tr <- function(M) sum(diag(M))
cat(sprintf("tr(A) = 2 + 1 = %g\n", tr(A)))

P <- matrix(c(1, 2, 3), nrow = 1)   # 1 x 3
Q <- matrix(c(1, 0, 2), ncol = 1)   # 3 x 1
cat("\nP (1x3) =\n"); print(P)
cat("Q (3x1) =\n"); print(Q)
cat("PQ (1x1) =\n"); print(P %*% Q)
cat("QP (3x3) =\n"); print(Q %*% P)
cat(sprintf("tr(PQ) = %g,  tr(QP) = 1*1 + 0*2 + 2*3 = %g\n",
            tr(P %*% Q), tr(Q %*% P)))

## 5  a symmetric idempotent 2x2 ----------------------------------------------
hr("5  idempotent matrix")
J <- 0.5 * matrix(1, nrow = 2, ncol = 2)
cat("J =\n"); print(J)
cat("J %*% J =\n"); print(J %*% J)
cat(sprintf("J^2 == J : %s,  tr(J) = %g\n", all.equal(J %*% J, J), tr(J)))
I2 <- diag(2)
cat("\nI - J =\n"); print(I2 - J)
cat(sprintf("(I-J)^2 == I-J : %s,  tr(I-J) = %g\n",
            all.equal((I2 - J) %*% (I2 - J), I2 - J), tr(I2 - J)))
cat("eigenvalues of J:", round(eigen(J)$values, 10), "\n")

## 6  hat matrix of the ice cream model ---------------------------------------
hr("6  hat matrix H = X (X'X)^{-1} X'")
H <- X %*% solve(XtX) %*% t(X)
n <- nrow(X); p <- ncol(X) - 1
cat(sprintf("n = %d, p = %d\n", n, p))
cat(sprintf("H symmetric : %s\n", isTRUE(all.equal(H, t(H)))))
cat(sprintf("H idempotent: %s\n", isTRUE(all.equal(H %*% H, H))))
cat(sprintf("tr(H)   = %.10f  (p + 1 = %d)\n", tr(H), p + 1))
cat(sprintf("tr(I-H) = %.10f  (n - p - 1 = %d)\n", tr(diag(n) - H), n - p - 1))

## 7  normal equations by hand vs lm() ----------------------------------------
hr("7  beta hat from the normal equations vs lm()")
beta_hat <- solve(XtX) %*% t(X) %*% ice$IC
fit <- lm(IC ~ price + income + temp, data = ice)
cmp <- cbind(`by hand` = as.vector(beta_hat), `lm()` = unname(coef(fit)))
rownames(cmp) <- colnames(X)
print(round(cmp, 8))
cat(sprintf("max abs difference = %.3e\n",
            max(abs(cmp[, 1] - cmp[, 2]))))

# X' e = 0 : the residual is orthogonal to every column of X
e <- resid(fit)
cat(sprintf("max |X'e| = %.3e  (0 up to rounding -> residual orthogonal to X)\n",
            max(abs(t(X) %*% e))))
