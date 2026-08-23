  ###########??�� 5.1##############
  
  ####DFFITS ???跮?? ????�� ####
  library(car)
  data(mtcars); attach(mtcars)
  mtcars[1:3,]  #data
  
  fit <- lm(mpg~disp+hp+wt+drat, data=mtcars)   #OLS fit
  summary(fit)
  
  # residuals
  par(mfrow=c(1,2))   #?׸? 5.3
  plot(mpg, rstandard(fit), ylim=c(-2,2.5), pch = "*", main = "standadized residual")
  plot(mpg, rstudent(fit), ylim=c(-2,2.5), pch = "*", main = "standadized residual")
  
  dffits(fit)   #DFFITS
  
  # influece measure
  inflm.fit <- influence.measures(fit)
  which(apply(inflm.fit$is.inf, 1, any))
      #which observations 'are' influential : ????��?? ????
  summary(inflm.fit)    #only these
  inflm.fit             #all ???? ???쿡 ???? ????�� ???? ???跮 ????
  
  
  ####ȸ??????####
  library(car)
  
  fit <- lm(mpg~disp+hp+wt+drat, data=mtcars)   #OLS fit
  summary(fit)
  
  #Assessing Outliers
  outlierTest(fit)              #Bonferonni p-value for most extreme obs
  qqPlot(fit, main="QQ Plot")   #qq plot for studentized resid
  h <-hat(model.matrix(fit))
  plot(h, type = "h", xlab = "case index", main = "leverage plot")
                                #leverage plots ?׸?5.4
  
  #Influential Observations
  avPlots(fit, ask=FALSE)       #added variable plots ?׸?5.5
  
  #Cook's D plot : identify D values > 4/(n-k-1) # ?׸?5.6
  cutoff <- 4/((nrow(mtcars)-length(fit$coefficients)-2))
  plot(fit, which=4, cook.levels = cutoff)
  
  #influence Plot   #?׸?5.7
  influencePlot(fit, main="Influence Plot", 
                sub="Circle size is proportial to Cook's Distance")
  
  #Normality of Residuals       #?׸?5.8
  qqPlot(fit, main="QQ Plot")   #t ???? Q-Q plot for studentized resid
  
  #distribution of studentized residuals
  library(MASS)
  sresid <- studres(fit)
  hist(sresid, freq=FALSE, main = "Distribution of Studentized Residuals")
  xfit <- seq(min(sresid), max(sresid), length=40)
  yfit <- dnorm(xfit)
  lines(xfit, yfit)
  
  #Evaluate homoscedasticity
  ncvTest(fit)    #non-constant error variance test
  
  #plot studentized residuals vs. fitted values
  spreadLevelPlot(fit)  #?׸?5.9
  ls.diag(fit)            #diagnotics statistics
  
  
  
  ###########??�� 5.2##############
  library(faraway)
  data(gala)
  ga <- lm(Species~Area+Elevation+Nearest+Scruz+Adjacent, data=gala)
  summary(ga)
  
  library(MASS)
  op=par(mfrow=c(1,2))
  boxcox(ga, plotit=T)                                #?׸?5.12(a)
  boxcox(ga, lambda=seq(0.0, 1.0, by=0.05), plotit=T) #?׸?5.12(b)
  par(op)
  ga2 <- lm(sqrt(Species)~Area+Elevation+Nearest+Scruz+Adjacent, data=gala)
  summary(ga2)
  
  
  
  ###########??�� 5.3##############
  data(longley)
  y=longley$GNP                   #???��???
  x1=longley$Unemployed; x2=longley$Population; x3=longley$Armed.Forces
  mydata <- data.frame(y, x1, x2, x3)
  fit <- lm(y~x1 + x2 + x3, data=mydata)
  summary(fit)                    #show results
  coefficients(fit)               #model coefficients
  confint(fit, level = 0.95)      #cis for model parameters
  fitted(fit)                     #predicted values
  residuals(fit)                  #residuals
  anova(fit)                      #anova table
  vcov(fit)                       #covariance matrix for model parameters
  influence(fit)                  #regression diagnostics
  ls.diag(fit)
  
  #Residual Diagnostic plots
  layout(matrix(c(1,2,3,4), 2,2)) #optional 4 graghs/page
  plot(fit)                       #?׸?5.13 
  
  
  
  
  
  
