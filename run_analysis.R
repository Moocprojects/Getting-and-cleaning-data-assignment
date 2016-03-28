# Downloading and unziping dataset
filename<- "getdata_dataset.zip"
if (!file.exists(filename)) { 
  url<- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(url, filename)
} 
if (!file.exists("UCI HAR Dataset")){
  unzip(filename)
}


#Step 1: loading datasets
test_set<- read.table("UCI HAR Dataset/test/X_test.txt")
test_labels<- read.table ("UCI HAR Dataset/test/y_test.txt")
test_subject<- read.table("UCI HAR Dataset/test/subject_test.txt")
train_set<- read.table("UCI HAR Dataset/train/X_train.txt")
train_labels<- read.table("UCI HAR Dataset/train/y_train.txt")
train_subject<- read.table("UCI HAR Dataset/train/subject_train.txt")

#Adding label and subject columns to test and train set
test_set<- cbind(test_set,test_labels,test_subject)
train_set<- cbind(train_set,train_labels,train_subject)


#Merging test and train datasets
dataset<- rbind(train_set,test_set)
features<- read.table("UCI HAR Dataset/features.txt")
colnames(dataset)<- c(as.character(features[,2]), "activity","subject")

# Step 2: Extracting mean and Standard Deviation measurements

features_subset<- features$V2[grep("mean\\(\\)|std\\(\\)", features$V2 )]
features_names<- c(as.character(features_subset), "activity","subject")
project_data<-subset(dataset,select= features_names)


#Step 3 : Naming Descriptive activites
activity_labels<- read.table("UCI HAR Dataset/activity_labels.txt", header= FALSE)
xyz<- project_data$activity
project_data$activity<-factor(xyz,levels = activity_labels[,1], labels = activity_labels[,2])
project_data$subject<- as.factor(project_data$subject)
project_data <- data.table(project_data)

  
#Step 4: Appropriately naming the  Variable labels
names(project_data)<-gsub("^t", "time", names(project_data))
names(project_data)<-gsub("^f", "frequency", names(project_data))
names(project_data)<-gsub("Acc", "Accelerometer", names(project_data))
names(project_data)<-gsub("Gyro", "Gyroscope", names(project_data))
names(project_data)<-gsub("Mag", "Magnitude", names(project_data))
names(project_data)<-gsub("BodyBody", "Body", names(project_data))

#Step 5: Creating independent tidy data set with the average of each variable activity and subject
library(reshape2);
id_var<- c("subject","activity")
measure_var<- setdiff(colnames(project_data),id_var)
melt_data<- melt(project_data,id = id_var, measure.vars = measure_var)
tidy<- dcast(melt_data,subject + activity ~ variable,mean)
write.table(tidy, file = "tidydata.txt", row.name=FALSE)

