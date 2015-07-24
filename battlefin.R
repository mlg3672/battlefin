# Michele Goe
# July 14, 2015
library(dplyr)
library(ggplot2)
library(magrittr)
library(reshape2)
library(randomForest)
# ----set working directory
setwd("~/Documents/Python-Projects/BattleFin")
# ----read csv file ----
table1<-read.table("data/1.csv") #a mess!
table1<-read.csv("data/1.csv")
head(table1)
colnames(table1) #total 442 I1-224 cols following O1- O198 cols
rownames(table1) #55 rows
summary(table1) 
#notes: cols  O1, 02, ..01298 are stock names 
#       cols I01, I02,...I224 are features of stocks
#       no binary 
#       all values less than 1, some negative
# all outputs are relative to previous day's close (line 1) 
# each additional line is 5 min change from line 1 (line 2 = 9:30am, line3 = 935am)
# add timestamp to each row
times<-seq(as.POSIXct("2015-07-14 9:25:00"), as.POSIXct("2015-07-14 13:55:00"), by="5 min")
#by5min<-format(times,"%H:%M") change to character

table1$time<-times
# -- exploratory data analysis -----
# --- plot csv file ----
plot(rownames(table1),table1$O101,type="l")
# ---- plot multiple stocks
er <- table1[,c(1:198,443)] # subset take only output data
colnames(er)
# ---boxplot ---
boxplot(er[2:55,1:198],rm.na=T,xlab="stocks",ylab="percent change")
#---another plot---
d3<- er %>% melt(id.vars='time',na.rm=T)

ggplot(d3)+
  geom_line(aes(x=time,y=value,col=variable,group=variable))+
  scale_color_discrete(name  ="Line Type",
                       breaks=c(1, 2)) #add labels labs = c("01","02"...)
#--- histogram -----
hist(d3$value,breaks=30,xlab="stock percent change")
#---density plot
ggplot(d3, aes(value, fill = variable)) + geom_density(alpha = 0.2) + 
  guides(colour=guide_legend(nrow=70))
# moving average
library(forecast)
library(graphics)
sm<-ma(table1$O1,order=5) # hourly
plot(table1$O1,main="Moving Average for Stocks")
lines(sm,col="red")
# density plot ----
dx<-lapply(table1[,1:198],function (x) density(x))
plot(dx$O198)
#-feature plot -----
featurePlot(x = training, c("age","education","jobclass"),y = training$wage,plot = "pairs")
qplot(age, wage, colour = jobclass, data = training)

# add solution to training dataset ----
solutions<-read.csv("trainLabels.csv")
close<-solutions[1,2:199] # day 1 close 4pm for stock O1
solutions["O1"] # day 1 close 4pm for stock O1

 # extract features from each column ----
#function capture feature other than count and transform data
extractFeatures <- function(data) {
  df<-data.frame(matrix(NA, nrow = 198, ncol = 14)) #empty dataframe
  colnames(df)<- c("past", # previous day's performance up or down
                "vol", # volitility/ skewedness
                "mean", # mean
                "start", # starting price
                "period", # period
                "range", # range
                "max", # max
                "min", # min
                "skew1", # mode
                "var", # variance
                "sd", #sd
                "delta60", # slope every hour
                "delta30", #slope every 30 min
                "median") # median
  df[,1] <- unlist(lapply(data[1,1:198],function(x) if(x>0) { 1 } else { 0 }))
  df[,2] <- unlist(lapply(data[1:198],function(x) sum(x[x>mean(x)])/sum(x) ))
  df[,3] <- colMeans(data[1:198])
  df[,4] <- as.numeric(data[1,1:198])
  df[,5] <- unlist(lapply(data[,1:198],function(x) find.period(x))) # 5 min intervals
  df[,6] <- unlist(lapply(data[1:198],function(x) abs(max(x)-min(x))))
  df[,7] <- unlist(lapply(data[,1:198],function(x) max(x)))
  df[,8] <-unlist(lapply(data[,1:198],function(x) min(x)))
  df[,9] <- unlist(lapply(data[,1:198],function (x) sum(x[x>median(x)])/sum(x)))
  df[,10] <- unlist(lapply(data[,1:198],function(x) var(x)))
  df[,11] <- unlist(lapply(data[,1:198],function(x) sd(x)))
  df[,12] <-unlist(lapply(data[,1:198],function(x) find.delta(x,split=12)))
  df[,13] <-unlist(lapply(data[,1:198],function(x) find.delta(x,split=6)))
  df[,14] <- unlist(lapply(data[,1:198],function (x) median(x)))
  return(df)
}
# delta function
find.delta<-function(x,split=12) {
  mylist<-c(0)
  for(i in seq(1,length(x)-split,split)){
    y<-x[i:(i+split-1)]
    xdat<-c(1:split)
    lm1<-lm(y~xdat)
    mylist<-c(mylist,coef(lm1)[2])
  }
  return(mean(mylist[-1]))
}
# -- period function
find.period<-function(x) {
  i<-0
  while(i<10)
  {
    period = 0
    low<-min(x)
    lt<-match(low,x)
    sprintf("low is: %s", low)
    xtl<-match(low,x[-lt],nomatch=lt)#find next  min, if no match period will be 0
    sprintf("xtl is: %s", xtl)
    period<-abs(lt-xtl) # calc period
    sprintf("period is: %s", period)
    if(period==0) { 
      x<-x[-lt]
      i<-i+1
    }
    else { i<-10 }
    }
  return(period) # if no min loop again
  # else calculate distance between mins
}

# random forest feature importance
dat<-read.csv("data/35.csv")
tx<-extractFeatures(dat)
tx$close<-as.numeric(as.list(solutions[35,2:199]))
rf <- randomForest(tx[,-15], as.numeric(tx[,15]), ntree=100, importance=TRUE)
imp <- importance(rf, type=1)
featureImportance <- data.frame(Feature=row.names(imp), Importance=imp[,1])
featureImportance

# -- apply predictive models -----
# data splitting
library(caret)
library(kernlab)
library(ISLR); data(Wage)
library(ggplot2); library(caret)
library(gbm)
library(klaR)
library(MASS)
inTrain<-createDataPartition(y=tx$close,p=0.75,list=FALSE)
training<-tx[inTrain,]
testing<-tx[-inTrain,]
dim(training)

# fit general linear model to data
set.seed(32343)
modelFit<-train(close~.,data=training, method = "glm") # linear model
modelFit
modelFit$finalModel
modelFit
predictions<-predict(modelFit,newdata=testing)
# --- gbm ------
modgbm<-train(close~., method="gbm", data = training, verbose = FALSE) # gbm
print(modgbm)
qplot(predict(modgbm, testing),close, data=testing)
pgbm<-predict(modgbm, testing)
#---- rpart ------
set.seed(125)
modrpart<-train(close~., method="rpart", data = training)
print(modrpart$finalModel) # print tree
library(rattle)
fancyRpartPlot(modrpart$finalModel)
prpart<-predict(modrpart,testing)
# ---- rf ------
modrf<-train(close~.,method="rf", data=training,
            trControl = trainControl(method = "cv"), number = 3) # random forest
getTree(modrf$finalModel, k=2) # see second tree
prf<-predict(modrf,testing)
table(prf,testing$close)
# --- compare methods ---
library(forecast)
accuracy(prpart, testing$close)[2] # rpart 1.6813
accuracy(pgbm, testing$close)[2] # gbm 0.5404689
accuracy(prf, testing$close)[2] #rf 0.5432
accuracy(predictions, testing$close)[2] #glm 0.27012

inRange<-function(p,x,t=0.1) { sum((x+t>=p)*(x-t<=p))/length(p)}
inRange(prpart, testing$close) #rpart 0.167
inRange(pgbm, testing$close)#gbm 0.271
inRange(prf, testing$close) #rf 0.354
inRange(predictions, testing$close) #glm 0.416

# ensemble models ----
eavg<-rowMeans(submission[,-1])
emed<-apply(submission[,-1],1,median)
weights<-matrix(data=rep(c(0.1,0.2,0.3,0.4),198),nrow=198,ncol=4,byrow=T)
ewei<-rowSums(weights*submission[,-1])

#-- compare ensemble models ---
accuracy(eavg, testing$close)[2] # avg 0.6381175
accuracy(emed, testing$close)[2] # median 0.4787952
accuracy(ewei, testing$close)[2] #weighted 0.992659

inRange(eavg, testing$close) #avg  0.29167
inRange(emed, testing$close)#median 0.375
inRange(ewei, testing$close) #weighted 0.167

#--- make sample output file  -----
x <- paste0("0",c(1:198))
x11<-data.frame(matrix(NA, nrow = 1, ncol = 198)) #empty dataframe
x11[1,]<-rnorm(198,mean=0,sd=1) # random guess
x11[1,]<-er[1,1:198]# same as starting value
x11[1,]<-er[1,1:198]+rnorm(198,mean=0,sd=1)#starting value + rand number
colnames(x11)<-x
#-- measure error 
df<-read.csv("trainLabels.csv")
head(df)
rmse<-sqrt(sum((as.numeric(x11)-as.numeric(df[1,2:199]))^2)) 
rmse # random guess 32.20696
      # starting value 28.22885
      # starting value plus random guess 31.02412
# plot predicted vs actual ---------
##--- melting pot of data
x12<-melt(x11)
x13<-cbind(melt(df[1,2:199]),x12$value) #combine train and pred
colnames(x13)<-c("stock","train","pred")
x14<-melt(x13,id.vars='stock')
## plot
qplot(stock,value,data=x14,colour=variable,ylab="percent change in price")
# write submission file ----
fileId <- 35
submission <-data.frame(FileId=rep(fileId,48),rf=prf,gbm=pgbm,glm=predictions,rpart=prpart)
nameFile<-paste0("results/",fileId,"_submission.csv")
write.csv(submission, file =nameFile, row.names=FALSE)
#  read sample submission file ----
sampleSubmit<-read.csv("sampleSubmission.csv")
head(sampleSubmit)
ncol(sampleSubmit) #199
nrow(sampleSubmit) #310
