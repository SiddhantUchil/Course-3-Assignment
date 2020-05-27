getwd()

filename <- "getdata_dataset.zip"

## Download and unzip the dataset:
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, filename, method="curl")  ##checks whether hte desired zop file is present
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) ##extracts file from zip if it does not exist
}

# Load activity labels + features
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])  ##ensures that the names are of class character
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])             ##ensures that the names are of class character

# Extract only the data on mean and standard deviation
featuresWanted <- grep(".*mean.*|.*std.*", features[,2]) ##any character repeated any number of times before and after 
                                                         ##mean and std
featuresWanted.names <- features[featuresWanted,2]       ## extracts values using the grep indices as row numbers of features
featuresWanted.names = gsub('-mean', 'Mean', featuresWanted.names) ##removes dashes
featuresWanted.names = gsub('-std', 'Std', featuresWanted.names)
featuresWanted.names <- gsub('[-()]', '', featuresWanted.names) ##The additional square brackets mean "match 
                                                                ##any of the characters inside"


# Load the datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresWanted] ##by default []without"," extracts col
                                                                         ## using []with read extracts only the relevant colnumber data
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresWanted] ##same reason as above
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# merge datasets and add labels
allData <- rbind(train, test)   ##binds both train and test data
colnames(allData) <- c("subject", "activity", featuresWanted.names)

# turn activities & subjects into factors
allData$activity <- factor(allData$activity, levels = activityLabels[,1], labels = activityLabels[,2]) ##levels and labels
                                                                                                      ##are categorical data
allData$subject <- as.factor(allData$subject) ##individuals in the survey are also categorical

library(dplyr)
library(tidyr)
install.packages("reshape2")
library(reshape2)

allData.melted <- melt(allData, id = c("subject", "activity")) ##melted so that we can use single variable name in
                                                                ## the nect step, lists all other variables under a
                                                              ##single variable named "variable"
allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean) ##activity and subject are represented by the 
                                                               ##mean of the other variables

write.table(allData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)

View(features)
View(trainSubjects)

