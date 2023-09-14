library(data.table)

master <- fread('./project/volume/data/raw/Stat_380_housedata.csv')

train <- master[!(is.na(master$SalePrice))]
test <- master[is.na(master$SalePrice)]
sub <- fread('./project/volume/data/raw/example_sub.csv')

#pairs(DepDelay~CRSDepTime+DayofMonth,data=DT[1:1000,])
train$BldgType <- as.factor(train$BldgType)
train$BldgType <- unclass(train$BldgType)
train$LotFrontage[is.na(train$LotFrontage)] <- mean(train$LotFrontage, na.rm = TRUE)
test$LotFrontage[is.na(test$LotFrontage)] <- mean(test$LotFrontage, na.rm = TRUE)


train$CentralAir <- unclass(as.factor(train$CentralAir))
test$CentralAir <- unclass(as.factor(test$CentralAir))
train$TotalBath <- train$FullBath + 0.5*train$HalfBath
test$TotalBath <- test$FullBath + 0.5*test$HalfBath
train$Heating <- unclass(as.factor(train$Heating))
test$Heating <- unclass(as.factor(test$Heating))


cor_matrix <- cor(train[, c("TotalBsmtSF"), with=FALSE], train$SalePrice)
print(cor_matrix)

pairs(SalePrice~Heating, data=train)



sub_train <- train[,.(Id, YearBuilt, GrLivArea, TotalBsmtSF, LotArea, SalePrice)]
sub_test <- test[,.(Id, YearBuilt, GrLivArea, TotalBsmtSF, LotArea, SalePrice)]
fwrite(sub_train, './project/volume/data/interim/sub_train.csv')
fwrite(sub_test, './project/volume/data/interim/sub_test.csv')


setkey(testing, qc_code)
setkey(train, qc_code)

train$qc_test <- merge(train, testing)$V1
