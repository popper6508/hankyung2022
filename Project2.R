setwd(dirname(rstudioapi::getSourceEditorContext()$path))
source("packages.R")

realalldata <- read.csv("factoringdata.csv", fileEncoding = "euc-kr")

##데이터 가공

for (i in 8:ncol(realalldata)) {
  realalldata[,i] <- as.numeric(realalldata[,i])
}

realalldata$Cash.flow <- realalldata$보완_처분가능소득 + realalldata$자산_금융자산_저축금액 - realalldata$지출_소비지출비 - realalldata$원리금상환금액

realalldata$DefaultS <- realalldata$Cash.flow/realalldata$보완_경상소득
for (i in 1:nrow(realalldata)) {
  if (realalldata$DefaultS[i] < 0) {
    realalldata$Shortdefault[i] = 1
  } else {realalldata$Shortdefault[i] = 0}
}

realalldata$DefaultL <- realalldata$부채/realalldata$자산
for (i in 1:nrow(realalldata)) {
  if (realalldata$DefaultL[i] > 1) {
    realalldata$Longdefault[i] = 1
  } else {realalldata$Longdefault[i] = 0}
}

realalldata$Mortgage1 = realalldata$부채_금융부채_담보대출_대출용도_거주주택구입금액 + realalldata$부채_금융부채_담보대출_대출용도_거주주택이외부동산구입금액 + realalldata$부채_금융부채_신용대출_대출용도_거주주택구입금액 + realalldata$부채_금융부채_신용대출_대출용도_거주주택이외부동산구입금액
realalldata$Mortgage2 = realalldata$부채_금융부채_담보대출_대출용도_거주주택구입금액 + realalldata$부채_금융부채_담보대출_대출용도_거주주택이외부동산구입금액 + realalldata$부채_금융부채_신용대출_대출용도_거주주택구입금액 + realalldata$부채_금융부채_신용대출_대출용도_거주주택이외부동산구입금액 + realalldata$부채_임대보증금
realalldata <- mutate(realalldata, Mortgage3 = realalldata$부채_금융부채_담보대출_대출용도_거주주택구입금액 + realalldata$부채_금융부채_담보대출_대출용도_거주주택구입금액)
realalldata <- mutate(realalldata, Mortgage4 = realalldata$Mortgage1-realalldata$Mortgage3)
realalldata <- mutate(realalldata, Mortgage5 = realalldata$Mortgage2-realalldata$Mortgage3)

realalldata$Gapratio <- (realalldata$Mortgage5)/realalldata$자산_실물자산_부동산_거주주택이외부동산금액

realalldata <- mutate(realalldata, mor_default = realalldata$Mortgage2/realalldata$자산_실물자산_부동산금액)

realalldata <- mutate(realalldata, Gap_Pro = realalldata$부채_임대보증금 - realalldata$Cash.flow)

realalldata <- mutate(realalldata, Gap_Pro_2 = realalldata$Mortgage5/realalldata$자산_실물자산_부동산_거주주택이외부동산금액)



## classification : 레버러지 형태별 분류
group1_1 <- realalldata[realalldata$부채>0,]
group1 <- group1_1[group1_1$Mortgage2==0,]

group2_1 <- group1_1[group1_1$Mortgage2>0,]
group2 <- group2_1[group2_1$자산_실물자산_부동산_거주주택이외부동산금액==0,]

group3_1 <- group2_1[group2_1$자산_실물자산_부동산_거주주택이외부동산금액>0,]
group3_2 <- group3_1[group3_1$Mortgage5>0,]
group3 <- group3_1[group3_1$부채_임대보증금==0,]

group4 <- group3_1[group3_1$부채_임대보증금>0,]

mean(group1$보완_경상소득)
mean(group2$보완_경상소득)
mean(group3$보완_경상소득)
mean(group4$보완_경상소득)

mean(group1$자산)/mean(group1$부채)
mean(group2$자산)/mean(group2$부채)
mean(group3$자산)/mean(group3$부채)
mean(group4$자산)/mean(group4$부채)

mean(group1$Cash.flow)
mean(group2$Cash.flow)
mean(group3$Cash.flow)
mean(group4$Cash.flow)


###기초 통계 분석
#
sdg1 <- realalldata[realalldata$Shortdefault==1, ]

group1_1_s <- sdg1[sdg1$부채>0,]
group1_s <- group1_1_s[group1_1_s$Mortgage2==0,]

group2_1_s <- group1_1_s[group1_1_s$Mortgage2>0,]
group2_s <- group2_1_s[group2_1_s$자산_실물자산_부동산_거주주택이외부동산금액==0,]

group3_1_s <- group2_1_s[group2_1_s$자산_실물자산_부동산_거주주택이외부동산금액>0,]
group3_2_s <- group3_1_s[group3_1_s$Mortgage5>0,]
group3_s <- group3_1_s[group3_1_s$부채_임대보증금==0,]

group4_s <- group3_1_s[group3_1_s$부채_임대보증금>0,]

nrow(group1_s) / nrow(sdg1)
nrow(group2_s) / nrow(sdg1)
nrow(group3_s) / nrow(sdg1)
nrow(group4_s) / nrow(sdg1)

nrow(group1_s[group1_s$가구주_만연령<=30,])/nrow(group1_s)
nrow(group2_s[group2_s$가구주_만연령<=30,])/nrow(group2_s)
nrow(group3_s[group3_s$가구주_만연령<=30,])/nrow(group3_s)
nrow(group4_s[group4_s$가구주_만연령<=30,])/nrow(group4_s)

nrow(group1_l[group1_l$가구주_만연령<=30,])/nrow(group1_l)
nrow(group2_l[group2_l$가구주_만연령<=30,])/nrow(group2_l)
nrow(group3_l[group3_l$가구주_만연령<=30,])/nrow(group3_l)
nrow(group4_l[group4_l$가구주_만연령<=30,])/nrow(group4_l)

#
ldg2 <- realalldata[realalldata$Longdefault==1, ]

group1_1_l <- ldg2[ldg2$부채>0,]
group1_l <- group1_1_l[group1_1_l$Mortgage2==0,]

group2_1_l <- group1_1_l[group1_1_l$Mortgage2>0,]
group2_l <- group2_1_l[group2_1_l$자산_실물자산_부동산_거주주택이외부동산금액==0,]

group3_1_l <- group2_1_l[group2_1_l$자산_실물자산_부동산_거주주택이외부동산금액>0,]
group3_2_l <- group3_1_l[group3_1_l$Mortgage5>0,]
group3_l <- group3_1_l[group3_1_l$부채_임대보증금==0,]

group4_l <- group3_1_l[group3_1_l$부채_임대보증금>0,]

nrow(group1_l) / nrow(ldg2)
nrow(group2_l) / nrow(ldg2)
nrow(group3_l) / nrow(ldg2)
nrow(group4_l) / nrow(ldg2)

###_____시나리오 분석
Re_supde <- as.data.frame(read_xlsx('C:/Users/Owner/Desktop/김겨레/대학교/2022 한국경제신문 공모전/데이터/시나리오 데이터/1_Dem_Sup_RE.xlsx'))
De_supde <- as.data.frame(read_xlsx('C:/Users/Owner/Desktop/김겨레/대학교/2022 한국경제신문 공모전/데이터/시나리오 데이터/2_Dem_Sup_Deposit.xlsx'))
Re_price <- as.data.frame(read_xlsx('C:/Users/Owner/Desktop/김겨레/대학교/2022 한국경제신문 공모전/데이터/시나리오 데이터/3_Real_Estate_Index.xlsx'))
De_price <- as.data.frame(read_xlsx('C:/Users/Owner/Desktop/김겨레/대학교/2022 한국경제신문 공모전/데이터/시나리오 데이터/4_Deposit_Index.xlsx'))

df_cap <- as.data.frame(cbind(Re_supde$수도권, Re_price$수도권변화정도))
df_noncap <- as.data.frame(cbind(Re_supde$지방권, Re_price$지방변화정도))

##시계열 안정성
#
df_ts <- ts(data=df_cap$V1, start = c(2012,7), end=c(2022,8), frequency = 12)
acf(df_ts, main="ACF",ylab="")
pacf(df_ts, main = "PACF", ylab="")
adf.test(df_ts,k=0)

acf(diff(df_ts), main="ACF",ylab="")
pacf(diff(df_ts), main = "PACF", ylab="")
adf.test(diff(df_ts),k=0)

#
df_ts2 <- ts(data=df_cap$V2, start = c(2012,7), end=c(2022,8), frequency = 12)
acf(df_ts2, main="ACF",ylab="")
pacf(df_ts2, main = "PACF", ylab="")
adf.test(df_ts2,k=0)

acf(diff(df_ts2), main="ACF",ylab="")
pacf(diff(df_ts2), main = "PACF", ylab="")
adf.test(diff(df_ts2),k=0)

#
df_ts21 <- ts(data=df_noncap$V1, start = c(2012,7), end=c(2022,8), frequency = 12)
acf(df_ts21, main="ACF",ylab="")
pacf(df_ts21, main = "PACF", ylab="")
adf.test(df_ts21,k=0)

acf(diff(df_ts21), main="ACF",ylab="")
pacf(diff(df_ts21), main = "PACF", ylab="")
adf.test(diff(df_ts21),k=0)


#
df_ts22 <- ts(data=df_noncap$V2, start = c(2012,7), end=c(2022,8), frequency = 12)
acf(df_ts22, main="ACF",ylab="")
pacf(df_ts22, main = "PACF", ylab="")
adf.test(df_ts22,k=0)

acf(diff(df_ts22), main="ACF",ylab="")
pacf(diff(df_ts22), main = "PACF", ylab="")
adf.test(diff(df_ts22),k=0)

auto.arima(diff(df_ts))


## 시나리오 반영



###활용 데이터 저장
write.csv(realalldata, file='./factoringdata.csv')

#가격 변화 예측모형 테스트
De_price_test <- as.data.frame(read_xlsx('C:/Users/Owner/Downloads/Pri_Re.xlsx'))

De_price_test2 <- as.data.frame(read_xlsx('C:/Users/Owner/Downloads/Desu_Re.xlsx'))

test_test <- De_price_test$전국변화[15:nrow(De_price_test) ]
test_test_2 <- De_price_test2$전국[1:(nrow(De_price_test2)-14)]

testttt <- cbind(De_price_test$전국변화,De_price_test2$전국)
colnames(testttt) <- c("y1","y2")

VAR(testttt, p=3)

xXXXX <- lm(test_test~test_test_2)
stargazer::stargazer(xXXXX, type="text")



DE_price_test <- as.data.frame(read_xlsx('C:/Users/Owner/Downloads/Pri_Dep.xlsx'))

DE_price_test2 <- as.data.frame(read_xlsx('C:/Users/Owner/Downloads/Desu_Dep.xlsx'))

test_tes <- DE_price_test$전국변화[15:nrow(DE_price_test) ]
test_tes_2 <- DE_price_test2$전국[1:(nrow(DE_price_test2)-14)]

xXXXXx <- lm(test_tes~test_tes_2)
stargazer::stargazer(xXXXXx, type="text")
xXXXXx$residuals
