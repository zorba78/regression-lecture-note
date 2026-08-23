######예제4.2###############

## 실험쥐 데이터 입력

x <- c(1,2,3,4,5,6,7,8)
y <- c(1, 1.2, 1.8, 2.0, 3.8, 4.3, 6.5, 9.0)


##다항회귀모형 적용

mouse.lm = lm(y ~ x+I(x^2))
summary(mouse.lm)

## 산점도

plot(x,y)
 lines(x, mouse.lm$fitted.values)
 
 
 
######예제4.3###############
 
 install.packages("faraway")
 
 library(faraway) 
 
 data("corrosion")
 head(corrosion)
 
 attach(corrosion)
 
 par(mfrow=c(1,3))
 # 1) 1차 선형회귀모형
 gF <- lm(loss~Fe, corrosion)
 
 summary(gF) 
 
 plot(Fe, loss)
 abline(coef(gF))
 
 # 2) 3차 다항회귀모형
 gp3 <- lm(loss~Fe+I(Fe^2)+I(Fe^3), corrosion)
 
 summary(gp3) 
 
 grid <- seq(0,2, length=50)
 plot(loss~Fe, ylim=c(60,150))
 lines(grid, predict(gp3, data.frame(Fe=grid)))
 
 # 3) 5장 다항회귀모형
 gp5 <- lm(loss~Fe+I(Fe^2)+I(Fe^3)+I(Fe^4)+I(Fe^5), corrosion)
 
 summary(gp5) 
 
 grid <- seq(0,2, length=50)
 plot(loss~Fe, ylim=c(60,150))
 lines(grid, predict(gp5, data.frame(Fe=grid)))
 
 
