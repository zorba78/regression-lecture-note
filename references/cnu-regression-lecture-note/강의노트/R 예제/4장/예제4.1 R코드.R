###########예제4.1##############

# 데이터 파악 

data(airquality)

airquality[1:2,]

plot(airquality[,1:4], panel=panel.smooth) # 산점도


#오존을 반응변수로 한 다중회귀모형

lm.a <- lm(Ozone~Solar.R+Wind+Temp, data=airquality)

summary(lm.a) 

## log(오존)을 반응변수로 한 다중회귀모형

lm.ab <- lm(log(Ozone)~Solar.R+Wind+Temp, data=airquality)

summary(lm.ab)

## 잔차그림

op=par(mfrow=c(1,2))

plot(fitted(lm.a), residuals(lm.a), xlab="fitted", ylab="residual") 

plot(fitted(lm.ab), residuals(lm.ab), xlab="fitted", ylab="residual")

abline(h=0)

par(op)

##잔차정규성검정

shapiro.test(residuals(lm.a))
shapiro.test(residuals(lm.ab))

##Durbin-Watson 검정(잔차독립성검정)

install.packages("lmtest")

library(lmtest)

dwtest(Ozone~Solar.R+Wind+Temp, data=na.omit(airquality))

dwtest(log(Ozone)~Solar.R+Wind+Temp, data=na.omit(airquality))

##오존 데이터의 회귀계수에 대한 신뢰영역

lm.ab <- lm(log(Ozone)~Solar.R+Wind+Temp, data=airquality)

confint(lm.ab)
coef(lm.ab)

install.packages("ellipse")

library(ellipse)

op=par(mfrow=c(1,3))

plot(ellipse(lm.ab,c(2,3)), type="l")
 points(coef(lm.ab)[2], coef(lm.ab)[3], pch=18)
 abline(v=confint(lm.ab)[2,], lty=2)
 abline(h=confint(lm.ab)[3,], lty=2)
 
plot(ellipse(lm.ab,c(2,4)), type="l") 
 points(coef(lm.ab)[2], coef(lm.ab)[4], pch=18)

plot(ellipse(lm.ab,c(3,4)), type="l") 
 points(coef(lm.ab)[3], coef(lm.ab)[4], pch=18)

par(op)
 

## 새로운 데이터에 대한 추정

x0 <- data.frame(Solar.R=170, Wind=8, Temp=70, Month=0, Day=0)

x0 

predict(lm.ab, x0, interval = "confidence") 
predict(lm.ab, x0, interval = "prediction")


conf <- predict(lm.ab, airquality, interval = "confidence")
conf
