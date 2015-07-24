## Predict short term movements in stock prices

Traders, analysts and investors are always looking for techniques to better predict price movements.  Knowing whether a security will increase or decrease allows traders to make better investment decisions and manage risk more effectively. 

This repo contains code for predicting 4 pm stock price of 198 stocks given: 
1. stock price at 5 min intervals from 9:30am to 1pm
2. 300 days of stock changes
3. 224 features

# Challenges: 
1. no identifying stock information including names, dates
2. features are not labeled
3. data is noisy 

# Approach
1. exploratory data analysis 
2. apply predictive models
	a. extract features (see below)
	b. linear - glm, gbm
	c. non-linear - rf, rpart
3. ensemble 
	a. average
	b. median
	c. Euclidean distance
	d. Weighted

# Proposed Features 
(*important ^not tested $not important)
- binary previous day performance up or down/same ^
- binary previous 7 days ^
- binary previous 30 days performance ^
- volatility $
- other stocks performance ^
- stock mean**
- stock median**
- stock max*, min*, range*
- stock period (time between peaks) $
- starting price up or down $
- variance**, standard deviation**
- skewness of distribution **
- 1 hour average slope*
- 30 min average slope*

Results: for 1.csv 

       Feature Importance
past      past   0.000000
vol        vol   4.592863
mean      mean   8.622352
start    start   0.000000
period  period   1.521173
range    range   6.006772
max        max   5.174736
min        min   5.956562
skew1    skew1   2.297619
var        var   4.317896
sd          sd   6.492151
median  median   8.612310

Results of 2.csv
       Feature Importance
past      past  0.0000000
vol        vol  3.8324361
mean      mean  7.3395562
start    start  0.0000000
period  period -0.5366969
range    range  4.9543515
max        max  5.7882383
min        min  4.7342192
skew1    skew1  4.3641045
var        var  5.8761784
sd          sd  6.1825136
median  median  7.3839088

Results for 30.csv
        Feature  Importance
past       past  0.00000000
vol         vol  4.75811761
mean       mean  9.17432595
start     start  0.00000000
period   period -0.08120935
range     range  5.33710891
max         max  4.89473853
min         min  5.35692606
skew1     skew1  3.19276082
var         var  3.01942808
sd           sd  2.84019366
delta60 delta60  3.57870781
delta30 delta30  8.56666674
median   median  7.87679902

Results for 35.csv
        Feature Importance
past       past   0.000000
vol         vol   1.971967
mean       mean   5.561477
start     start   0.000000
period   period   1.430271
range     range   5.933090
max         max   5.018914
min         min   6.162218
skew1     skew1   2.827238
var         var   2.800500
sd           sd   2.738912
delta60 delta60   3.345796
delta30 delta30   3.828079
median   median   7.276007

Modeling Results for 35.csv 
	 RMSE
rpart 	1.68 worst
rf 	0.54 better
gbm	0.54 better
glm 	0.27 best

Percent of Predictions within 10% of Actual Value
	Percent
rpart 	0.17 worst
rf 	0.27 ok
gbm	0.35 better
glm 	0.42 best

Ensemble Performance
		RMSE
Averages 	0.638
Median 		0.479
Euclidean Dist	
Weighted 	0.993