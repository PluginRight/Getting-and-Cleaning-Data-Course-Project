library(sjlabelled)
library(plyr)
library(knitr)

##1. Downloading and unzipping the Zipped File

if(!file.exists("C:/Users/sdanilola/Documents/MyProject/Learning R/Getting-and-Cleaning-Data-Course-Project/accelerometers_data")){dir.create("C:/Users/sdanilola/Documents/MyProject/Learning R/Getting-and-Cleaning-Data-Course-Project/accelerometers_data")}
fileurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileurl, destfile="Dataset.zip")

##Unzipping the file

unzip(zipfile = "Dataset.zip", exdir = "C:/Users/sdanilola/Documents/MyProject/Learning R/Getting-and-Cleaning-Data-Course-Project/accelerometers_data")
## files unzipped into a folder called UCI HAR Dataset.

##create a file path containing the list of the files and view it
files_list <- file.path("./accelerometers_data", "UCI HAR Dataset")
files<-list.files(files_list, recursive=TRUE)
files

## 2. Reading the data from the files

activity_test <- read.table(file.path(files_list, "test", "y_test.txt"), header = FALSE)
activity_train <- read.table(file.path(files_list, "train", "y_train.txt"), header = FALSE)

subject_test <- read.table(file.path(files_list, "test", "subject_test.txt"), header = FALSE)
subject_train <- read.table(file.path(files_list, "train", "subject_train.txt"), header = FALSE)

features_test <- read.table(file.path(files_list, "test", "X_test.txt"), header = FALSE)
features_train <- read.table(file.path(files_list, "train", "X_train.txt"), header = FALSE)


##Merging the training and the test sets into one dataset

activity_data <- rbind(activity_train, activity_test)
subject_data <- rbind(subject_train, subject_test)
features_data <- rbind(features_train, features_test)

##naming the variables

names(subject_data) <- c("subject")
names(activity_data) <- c("activity")
features_names_data <- read.table(file.path(files_list, "features.txt"), header = FALSE)
names(features_data) <- features_names_data$V2

##Obtain the complete datasets
data <- cbind(features_data, subject_data, activity_data)

##Extracting the measurements in the mean and standard deviation

#1. take names of features with mean or std by subseting the features names data

sub_features_names_data <- features_names_data$V2[grep("mean\\(\\)|std\\(\\)", features_names_data$V2)]

names_selected <- c(as.character(sub_features_names_data), 
                    "subject", "activity")
data <- subset(data, select = names_selected)

##4. Uses descriptive activity names to name the activities in the data set

activity_labels <- read.table(file.path(files_list, "activity_labels.txt"), header = FALSE)

data <- as.character(data[,data$activity])

data <- var_labels(data$activity, activity_labels$V2)

##4. Appropriately labels the data set with descriptive variable names. 
names(data)<-gsub("^t", "time", names(data))
names(data)<-gsub("^f", "frequency", names(data))
names(data)<-gsub("Acc", "Accelerometer", names(data))
names(data)<-gsub("Gyro", "Gyroscope", names(data))
names(data)<-gsub("Mag", "Magnitude", names(data))
names(data)<-gsub("BodyBody", "Body", names(data))

##creates a second, independent tidy data set with the average of each variable for each activity and each subject
data2<-aggregate(. ~subject + activity, data, mean)
data2<-data2[order(data2$subject,data2$activity),]
write.table(data2, file = "clean_data.txt", row.name=FALSE)

