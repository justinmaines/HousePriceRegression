library(caret)
library(data.table)

# read in data from feature processing / submission file
train <- fread("./project/volume/data/interim/sub_train.csv")
test <- fread("./project/volume/data/interim/sub_test.csv")
sub <- fread("./project/volume/data/raw/example_sub.csv")

# grab test id column
test_id <- test$Id

# remove Id column
train[,Id:=NULL]
test[,Id:=NULL]

# grab sale price of training and set testing sale price to holder value
train_y <- train$SalePrice
test$SalePrice[is.na(test$SalePrice)] <- 100
test_y <- test$SalePrice

master<-rbind(train,test)

# create dummy variables
dummies <- dummyVars(SalePrice ~ ., data = master)
train<-predict(dummies, newdata = train)
test<-predict(dummies, newdata = test)

train<-data.table(train)
train$SalePrice<-train_y
test<-data.table(test)

# train model
lm_model <- lm(SalePrice~ ., data = train)

summary(lm_model)

saveRDS(dummies,"./project/volume/models/SalePrice_lm.dummies")
saveRDS(lm_model,"./project/volume/models/SalePrice_lm.model")

# make predictions
test$SalePrice <- predict(lm_model, newdata = test)
test$Id <- test_id

# reorder to match submissions
test <- test[order(nchar(test$Id), test$Id)]


lm_sub <- test[,.(Id, SalePrice)]
fwrite(lm_sub, './project/volume/data/processed/final_sub.csv')