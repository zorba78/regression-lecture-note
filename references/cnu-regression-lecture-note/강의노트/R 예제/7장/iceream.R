####################################################
#               ice cream data analysis            #
# r.full : full model with 3 explantory variables  #
# r: reduced model with 2 explantory variables     #
####################################################
ice=read.csv("c:/ice.csv", header=TRUE)
attach(ice)
summary(ice)

library(lattice)
splom(~ice, pch=8)
r.full=lm(ice$IC~ice$price+ice$income+ice$temp)
summary(r.full)
anova(r.full)

op=par(mfrow=c(2,2))
plot(r.full)
par(op)

attributes(r.full)
summary(resid(r.full))
plot(resid(r.full),ylab="standardised residuals", xlab="fitted values")
abline(h=0,col="red")

##### scatter plot#####
par(mfrow=c(2,2))
plot(ice$price, ice$IC, pch="*")
plot(ice$income, ice$IC, pch="*")
plot(ice$temp, ice$IC, pch="*")

##### model selection-stepwiswe #####
library(car)
step(r.full)                        #with AIC
r=lm(ice$IC~ice$income+ice$temp)    #reduced model


##### residual analysis #####
require(graphics)
pairs(ice)
boxplot(r$res,horisontal=T, main="box-and-whisker plot")
hist(r$res)
plot(r$res, main="Residuals")
plot(rstandard(r), main="standardized residuals")
plot(rstudent(r), main= "Studentized residuals")
plot(r$res~r$fitted.values, main="Residuals and predicted values")
abline(h=0,lty=3)
plot(rstudent(r) ~ hatvalues(r), xlim=c(0,0.2))  ##Studentized residuals and hat-diagonals
abline(h=0)
quantile(rstudent(r))   #studentized quantile
rank(rstudent(r))
rank(hatvalues(r))

##### partial regression(added variable) plot #####
library(car)
avPlots(r,ask=F, main="Partial regression")

##### partial residual plot-function #####
crPlots(r, one.page=TRUE, ask=FALSE)

##### hat matrix dffits, dfbetas #####
plot(hat(ice),type="h",lwd=3)
plot(dffits(r),type="h",lwd=3)
par(mfrow=c(1,3))
   plot(dfbetas(r)[,1], type="h", lwd=3, main="intercept")
   plot(dfbetas(r)[,2], type="h", lwd=3, main="income")
   plot(dfbetas(r)[,3], type="h", lwd=3, main="temperature")
pairs(dfbetas(r))

library(leaps)     #all possible regression
lp=leaps(ice[,2:4], ice$IC, method="Cp")
leaps<-regsubsets(IC~price+income+temp, data=ice, nbest=7)
summary(leaps)   ##View results

##### multicolinearity #####
a=summary(r,correlation=T)$correlation
plot(col(a), row(a), cex=10*abs(a), xlim=c(0,dim(a)[2]+1), ylim=c(0,dim(a)[1]+1),
     main="Correlation matrix and the coefficients of a regression")

##### Influential Observations #####
av.plots(r, one.page=TRUE, ask=FALSE)    #added variable plots
# Cook's D plot
# identify D values > 4/(n-k-1)
cutoff=4/((nrow(ice)-length(r$coefficients)-2))
plot(r, which=1, cook.leves=cutoff)
plot(r, which=2, cook.leves=cutoff)
plot(r, which=3, cook.leves=cutoff)
plot(r, which=4, cook.leves=cutoff)
plot(r, which=5, cook.leves=cutoff)
plot(r, which=6, cook.leves=cutoff)

#Influence Plot
influencePlot(r, main="Influence Plot", sub="Circle size is proportial to Cook's Distance")

#Normality of Residuals
qqPlot(r, main="QQ plots")          ##qq plots for studentized resid

#distribution of studentized residuals
library(MASS)
sresid=studres(r)
hist(sresid, freq=FALSE, main="Distribution of Studentized Residuals")
xice=seq(min(sresid), max(sresid), length=40)
yice=dnorm(xice)
lines(xice,yice)

#Evaluate homoscedasticity
ncvTest(r)              #non-constant error variance test
spreadLevelPlot(r)      #plot studentized residuals vs. fitted values

#Evaluate Collinearity
vif(r)                  #Variance inflation factors
sqrt(vif(r)) > 2        #check with vif

#Evaluate Nonlinearity
cr.plots(r, one.page=TRUE, ask=FALSE)     #component + residual plot

#Ceres plots
ceresPlots(r, one.page=TRUE, ask=FALSE)

#Test for AUtocorrelated Errors
durbinWatsonTest(r)

##### outliers #####
outlierTest(r)          #Bonferonni p-value for most extreme obs

##### predicted interval #####
require(graphics)
predict(r, se.fit=TRUE)
pred.pre=predict(r, interval="prediction")
pred.con=predict(r,interval="confidence")
matplot(cbind(pred.con, pred.pre[,-1]), lty=c(1,2,2,3,3), type="l",
        ylab="predicted y")

#####outlier removed #####
m30=ice[-30,]   #30번 결측치 제거

r.m30=lm(m30$IC~m30$income+m30$temp)
summary(r.m30)
aov(r.m30)
require(graphics)
predict(r.m30, se.fit=TRUE)
pred.pre=predict(r.m30, interval="prediction")
pred.con=predict(r.m30, interval="confidence")
matplot(cbind(pred.con, pred.pre[,-1]), lty=c(1,2,2,3,3), type="l",
              ylab="predicted y")

r.full.m30=lm(m30$IC ~ m30$price + m30$income + m30$temp)
summary(r.full.m30)