train <- fread("./project/volume/data/interim/train.csv")
test <- fread("./project/volume/data/interim/test.csv")
sub <- fread("./project/volume/data/raw/example_sub.csv")
#DT[,.(mean_depdelay=mean(DepDelay,na.rm=T)),by=Origin][order(-mean_depdelay)]
avg_br <- train[,.(mean_saleprice=mean(SalePrice, na.rm=T)), by=BedroomAbvGr]
avg_tr <- train[,.(mean_saleprice=mean(SalePrice, na.rm=T)), by=TotRmsAbvGrd]

setkey(avg_tr, TotRmsAbvGrd)
setkey(test, TotRmsAbvGrd)

test <- merge(test, avg_tr, all.x=T)

setkey(test, Id)
setkey(sub, Id)

sub$SalePrice <- test$mean_saleprice

fwrite(sub, "./project/volume/data/processed/null_submission.csv")
