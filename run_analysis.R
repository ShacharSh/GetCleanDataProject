run_analysis <- function() {
    
    # This function manipulates the "Human Activity Recognition Using Smartphones Data Set"
    # from the following URL: "http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones#"
    #
    # The training and test sets are fitted together along with the data about the different
    # subjects and the different activities. The coded activities are replaces with their
    # descriptive names and the features variables names are transformed to a more descriptive
    # format. Finally, the mean value for each feature measurements is calculated for
    # each combination of subject and activity. The function writes this aggregated tidy
    # data set into a file called "aggregated_data.txt".
    #
    # Assumptions:
    # (1) The "reshape2" package is installed and loaded (using library(reshape2))
    # (2) The current directory from which the script is being run is the directory
    #     in which all of the data files are in.
    
    # (Step 1) - Merge the 2 data sets (training and the test)  to create 1 data set
    
    # the relative paths to the relevant files to be merged into one dataframe
    FEATURES_NAMES_FILENAME = "features.txt"
    ACTIVITY_LABELS_FILENAME = "activity_labels.txt"
    TRAIN_FEATURES_RESULTS_FILENAME = "train/X_train.txt"
    TRAIN_SUBJECT_FILENAME = "train/subject_train.txt"
    TRAIN_ACTIVITY_FILENAME = "train/y_train.txt"
    TEST_FEATURES_RESULTS_FILENAME = "test/X_test.txt"
    TEST_SUBJECT_FILENAME = "test/subject_test.txt"
    TEST_ACTIVITY_FILENAME = "test/y_test.txt"
    
    # read the features and activities files and extract their names
    features_names_file <- read.table(file=FEATURES_NAMES_FILENAME, sep=" ", stringsAsFactors=FALSE)
    features_names <- features_names_file[,2]
    activities_names_file <- read.table(file=ACTIVITY_LABELS_FILENAME, sep=" ",stringsAsFactors=FALSE)
    activities_names <- activities_names_file[,2]
    
    # give the data frame columns their corresponding names from the 
    # features names file, including the two new columns to bee added shortly
    unified_df_col_names = c(features_names, "subject", "activity")
    
    # build the train portion of the unified data frame
    train_features_results_file <- read.table(file=TRAIN_FEATURES_RESULTS_FILENAME)
    train_subject_file <- read.table(file=TRAIN_SUBJECT_FILENAME)
    train_activity_file <- read.table(file=TRAIN_ACTIVITY_FILENAME)
    
    # create a factor with the activities numeric symbols mapped to their names (to meet Step 3 requirement)
    train_activity_factor <- factor(x=train_activity_file[,1], levels=activities_names_file[,1], labels=activities_names)
    
    train_df <- train_features_results_file
    train_df <- cbind(train_df, train_subject_file)
    train_df <- cbind(train_df, train_activity_factor)
    colnames(train_df) <- unified_df_col_names
    
    # build the test portion of the unified data frame
    test_features_results_file <- read.table(file=TEST_FEATURES_RESULTS_FILENAME)
    test_subject_file <- read.table(file=TEST_SUBJECT_FILENAME)
    test_activity_file <- read.table(file=TEST_ACTIVITY_FILENAME)
    
    # create a factor with the activities numeric symbols mapped to their names (to meet Step 3 requirement)
    test_activity_factor <- factor(x=test_activity_file[,1], levels=activities_names_file[,1], labels=activities_names)
    
    test_df <- test_features_results_file
    test_df <- cbind(test_df, test_subject_file)
    test_df <- cbind(test_df, test_activity_factor)
    colnames(test_df) <- unified_df_col_names
    
    # bind the test and train data frames together
    unified_df <- train_df
    unified_df <- rbind(unified_df, test_df)
    
    # (Step 2) - Extract only the measurements on the mean and standard deviation 
    # for each measurement
    
    # identify the features that has to do with mean or standard deviation
    relevant_features_vec <- grep("[Mm]ean|std", features_names)
    # adding the last two positions, of the 'subject' and 'activity' columns
    relevant_features_vec <- append(relevant_features_vec, 
                                          c(length(features_names)+1, length(features_names)+2))
    # save the number of relevant features for later analysis
    len = length(relevant_features_vec)
    original_len = len - 2
    
    # trim the data frame to include only the relevant columns
    unified_df <- unified_df[relevant_features_vec]
    
    # NOTE: (Step 3) is embedded within the code of step 1 above. 
    # The activities numeric indicators are translated to their names while building the data frame
    
    # (Step 4) - transform the variables names to be descriptive
    
    original_names <- colnames(unified_df)
    # get rid of empty parentheses
    descriptive_names <- gsub("\\(\\)", "", original_names)
    # replace prefixes with their meaningful names
    descriptive_names <- gsub("^t", "time", descriptive_names)
    descriptive_names <- gsub("\\(t", "(time", descriptive_names)
    descriptive_names <- gsub("^f", "frequency", descriptive_names)
    # replace the shortcuts of some key terms with their meaningful names
    descriptive_names <- gsub("Acc", "Accelerometer", descriptive_names)
    descriptive_names <- gsub("Gyro", "Gyroscope", descriptive_names)
    descriptive_names <- gsub("Mag", "Magnitude", descriptive_names)
    descriptive_names <- gsub("Freq", "Frequency", descriptive_names)
    descriptive_names <- gsub("std", "StandardDeviation", descriptive_names)
    # correct the duplicate naming in the original feature names
    descriptive_names <- gsub("BodyBody", "Body", descriptive_names)
    # when a letter follows an hyphen - convert it to upper case (\\U) 
    descriptive_names <- gsub("-([a-zA-Z])", "\\U\\1", descriptive_names, perl=TRUE)
    
    # (Step 5) - Creates a second, independent tidy data set with the average 
    # of each variable for each activity and each subject
    
    colnames(unified_df) <- descriptive_names
    
    # melt the unified data frame to a narrow form where each combination of a subject,
    # an activity and a feature (variable) has a row with its value
    melted_unified_df <- melt(unified_df, id=c("subject", "activity"), measure.vars=descriptive_names[1:original_len])
    # create an aggregared form in which each combination of a subject and an activity
    # has a row and each feature (variable) has its own column
    dcasted_unified_df <- dcast(melted_unified_df, subject + activity ~ variable, mean)
    # rename the columns using the previously prepared descriptive names
    colnames(dcasted_unified_df) <- c("subject", "activity", descriptive_names[1:original_len])
    
    # write the aggregated form into a file
    write.table(x=dcasted_unified_df, file= "aggregated_data.txt", row.names=FALSE)
}