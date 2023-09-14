library(data.table)

# Read initial data file
master <- fread('./project/volume/data/raw/Stat_380_housedata.csv')

# Train-test split, NA SalePrice means testing data
train <- master[!(is.na(master$SalePrice))]
test <- master[is.na(master$SalePrice)]

# Table that holds mean sale price grouped by qc_code
intermediate_table <- train[, mean(SalePrice), by=qc_code]

# I found there was one testing qc_code not in training set, changed it to nearest one 
test[qc_code == 166162232, qc_code := 163178105]

# Setkey to use in the merge step
setkey(intermediate_table, qc_code)
setkey(test, qc_code)
setkey(train, qc_code)

# Grab the mean columns from the merge to match with correct qc_codes
train$qc_mean <- merge(train, intermediate_table)$V1
test$qc_mean <- merge(test, intermediate_table)$V1

# Pick selected features and write data
sub_train <- train[,.(Id, YearBuilt, GrLivArea, TotalBsmtSF, qc_mean, SalePrice)]
sub_test <- test[,.(Id, YearBuilt, GrLivArea, TotalBsmtSF, qc_mean, SalePrice)]
fwrite(sub_train, './project/volume/data/interim/sub_train.csv')
fwrite(sub_test, './project/volume/data/interim/sub_test.csv')
