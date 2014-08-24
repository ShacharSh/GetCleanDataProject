Readme for the run_analysis.R script
========================================================

The run_analysis.R script includes a single function named "run_analysis".

This function manipulates the "Human Activity Recognition Using Smartphones Data Set"
from the following URL: "http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones#"

## Pre-conditions for running the script \ Assumptions:
1. The "reshape2" package is installed and loaded (using library(reshape2))
2. The current directory from which the script is being run is the directory
in which all of the data files (of the original data set from the URL above) reside in.

## Process:
1. The training and test sets are fitted together along with the data about the different
subjects and the different activities into a single unified data frame.
2. The numeric coded activities are replaces with their descriptive names and the features variables names are transformed to a more descriptive format. 
3. The relevant features are being extracted. A relevant feature is one which represents
a mean of some other measurement, a standard deviation of some other measurement, or a 
mathematical manipulation of one of the first two. To locate those features, a regular expression
finding the expressions 'Mean' or 'Std' (case insensetively) in any position of the feature name
has been used.
4. The variables (features) names has been transformed to a more descriptive format. This has been
done by replacing each of the shortcut prefixes or key terms noted in the original data set
readme documentation, with their corresponding longer full format. Some regular expressions
are further explained within the function's documentation.
I found the camel case convention has most readable with the long names given in the original
data set.
5. The mean value for each relevant feature measurements is calculated for
each combination of subject and activity. This has been done by reshaping the data using
the melt and dcast functions of the reshape2 package, as learned in class. The result is 
a tidy data set when each observation (combination of subject and activity) has one row and
each relevant feature has one column.
6. The function eventually writes this aggregated tidy data set into a file called 
"aggregated_data.txt".
