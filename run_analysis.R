# Load file and data
fileUrl<- "http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
fname <- "data.zip"
    if(!exists(fname)) {
        download.file(fileUrl, destfile=fname, method="curl")
		unzip(fname)
    }


# Load any required packages 

if (!require("data.table")) {
  install.packages("data.table")
}

if (!require("reshape2")) {
  install.packages("reshape2")
}

require("data.table")
require("reshape2")

# Load: activity labels
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]

# Load: data column names
features <- read.table("./UCI HAR Dataset/features.txt")[,2]

# Extract only the measurements on the mean and standard deviation for each measurement.
extract_features <- grepl("mean|std", features)

# Load and process X_test & y_test data.
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")

#Only extract the neccessary labels

X_test <- X_test[,extract_features]

#Add activity labels to the Y set
y_test[,2] <- activity_labels[y_test[,1]]
names(y_test) = c("ActivityID", "Activity")
names(subject_test) = "Subject"

#Bind test data together

test_data <- cbind(as.data.table(subject_test), y_test, X_test)

# Load and process X_train & y_train data.
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")

subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")

names(X_train) = features

# Only extract the neccessary labels 
X_train = X_train[,extract_features]

# Load activity data
y_train[,2] = activity_labels[y_train[,1]]
names(y_train) = c("ActivityID", "Activity")
names(subject_train) = "Subject"

# Bind training data
train_data <- cbind(as.data.table(subject_train), y_train, X_train)

# Merge the test and train data
data = rbind(test_data, train_data)

#Tidy up merged data

id_labels <- c("Subject", "ActivityID", "Activity")
measure_labels <- setdiff(colnames(data), id_labels)
melted_data <- melt(data, id = id_labels, measure.vars = measure_labels)

tidy <- dcast(melted_data, Subject + Activity ~ variable, mean)

#Write to file

write.table(tidy, file = "./tidy_data.txt")
