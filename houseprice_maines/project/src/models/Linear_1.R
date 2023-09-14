# First linear model
library(caret)
library(data.table)
set.seed(77)

lin_train <- fread("./project/volume/data/interim/sub_train.csv")
lin_test <- fread("./project/volume/data/interim/sub_test.csv")
sub <- fread("./project/volume/data/raw/example_sub.csv")

test_id <- lin_test$Id

lin_train[,Id:=NULL]
lin_test[,Id:=NULL]

train_y <- lin_train$SalePrice
lin_test$SalePrice[is.na(lin_test$SalePrice)] <- 100
test_y <- lin_test$SalePrice

master<-rbind(lin_train,lin_test)

dummies <- dummyVars(SalePrice ~ ., data = master)
lin_train<-predict(dummies, newdata = lin_train)
lin_test<-predict(dummies, newdata = lin_test)

lin_train<-data.table(lin_train)
lin_train$SalePrice<-train_y
lin_test<-data.table(lin_test)

lm_model <- lm(SalePrice~ ., data = lin_train)

summary(lm_model)

lin_test$SalePrice <- predict(lm_model, newdata = lin_test)
lin_test$Id <- test_id
 
lin_test <- lin_test[order(nchar(lin_test$Id), lin_test$Id)]

setkey(lin_test, Id)
setkey(sub, Id)

sub$SalePrice <- lin_test$SalePrice

lm1_sub <- lin_test[,.(Id, SalePrice)]
fwrite(lm1_sub, './project/volume/data/processed/lm1_sub.csv')
