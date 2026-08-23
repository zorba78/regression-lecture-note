rm(list=ls())

## 예제3.1 ##

x <- c(1.9, 0.8, 1.1, 0.1, -0.1, 4.4, 4.6, 1.6, 5.5, 3.4)
y <- c(0.7, -1.0, -0.2, -1.2, -0.1, 3.4, 0.0, 0.8, 3.7, 2.0)

out = lm(y~x)
summary(out)
plot(x,y)
abline(out)

# 주어진 x값에서 추정값을 구하기
pred_y = predict(out, newdata=data.frame(x=x))
pred_y

# 새로운 x값에 대한 반응 추정값 구하기 

pred_1 = predict(out, newdata=data.frame(x=2.3))
pred_1

pred = predict(out, newdata=data.frame(x=c(1, 2.2, 6.7)))
pred


## 예제3.2 ## 

volume = c(412, 953, 929, 1492, 419, 1010, 595, 1034)
weight = c(250, 700, 650, 975, 350, 950, 425, 725)

book.lm = lm(weight~volume)

summary(book.lm)

par(mfrow=c(2,2))
plot(volume, weight)
lines(volume, book.lm$fitted.values)

plot(book.lm, which=1)
plot(book.lm, which=2, pch=16)

## 추정된 단순선형회귀모형이 제공하는 값 알아보기 
## attributes()함수 활용

attributes(book.lm)

book.lm$coefficients
book.lm$residuals
book.lm$fitted.values


## 예제3.3 ## 

tb1 = abs((0.6859-1)/0.1059)
tb1

ptb1 = 2 * pt(tb1, 6, lower.tail = FALSE)
ptb1


## 예제3.4 ## 

book.lm0 = lm(weight ~ 0+volume)
summary(book.lm0)

par(mfrow=c(2,2))
plot(book.lm0)
