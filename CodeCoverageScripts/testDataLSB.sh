#!/bin/bash
#=========================================================================================
## DESCRIPTION: Script to validate Current build code coverage numbers with previous build
## Copyright (C) 2014 Intuit - All Rights Reserved
## AUTHOR: Yogesh Khandelwal
## Last revised 10/06/2015
##
## USAGE: code-coverage-check.sh Arg1
##		   		Arg1 --	Jenkins Job type (Trunk, iOS, Android, JS)
#=========================================================================================
#Sleep and wait for jenkins jacoco plugin to generate merged coverage report.
sleep 10
##### Variables
DIFF_MSG="Default Message"
LINE_DIFF_MSG="Default Message"
COVERAGE_XML=""
PREV_COVERAGE_XML=""
COVERAGE_TOOL=""
CURR_COV_XML=""
PREV_COV_XML=""
COVERAGE_BASELINE=90.00
CURR_LINE_TOTAL=""
CURR_LINE_COV=""
PREV_LINE_TOTAL=""
PREV_LINE_COV=""
JOB_NAME="$1"
BUILD_FAILURE_FLAG=false

#JOB_NAME variable needs to be changed to some other variable.
#Testing 123 456

if [[ "$JOB_NAME" != "" ]]
then
    echo "Jenkins Job Type : $1"
else
    #Set the job type manually in the script
	echo "Jenkins Job Type is empty"
	JOB_NAME=""
fi

#=========================================================================================
## If the job Type is RestAPI (Job for Trunk_Continuous_Rest_API_Build)
## Job specific settings
    JOB_NAME_ESC=$(echo $JOB_NAME | sed -e "s/ /\\\ /g")

    UT_COVERAGE_BASELINE=0.00
    JUNIT_XML="current_junit.xml"
    JUNIT_PREV_XML="previous_junit.xml"

#Clear old reports
    rm $JUNIT_XML $JUNIT_PREV_XML
##### Extract CURRENT Unit Test Results
    curl --user ykhandelwal:85e0b077821e653f3f99b4c24d29b1e3 ${BUILD_URL}testReport/api/xml -O $JUNIT_XML
    CURR_JUNIT_TOTAL=$(grep '<totalCount>' $JUNIT_XML | cut -f7 -d">"| cut -f1 -d"<"|bc)
    CURR_JUNIT_FAIL=$(grep '<totalCount>' $JUNIT_XML | cut -f3 -d">"| cut -f1 -d"<"|bc)
    CURR_JUNIT_SKIP=$(grep '<totalCount>' $JUNIT_XML | cut -f5 -d">"| cut -f1 -d"<"|bc)
    CURR_JUNIT_PASS=$(echo "($CURR_JUNIT_TOTAL - $CURR_JUNIT_FAIL - $CURR_JUNIT_SKIP )" | bc)
##### Extract PREVIOUS Unit Test Results
    curl --user ykhandelwal:85e0b077821e653f3f99b4c24d29b1e3 ${JOB_URL}lastSuccessfulBuild/testReport/api/xml -O $JUNIT_PREV_XML
    PREV_JUNIT_TOTAL=$(grep '<totalCount>' $JUNIT_PREV_XML | cut -f7 -d">"| cut -f1 -d"<"|bc)
    PREV_JUNIT_FAIL=$(grep '<totalCount>' $JUNIT_PREV_XML | cut -f3 -d">"| cut -f1 -d"<"|bc)
    PREV_JUNIT_SKIP=$(grep '<totalCount>' $JUNIT_PREV_XML | cut -f5 -d">"| cut -f1 -d"<"|bc)
    PREV_JUNIT_PASS=$(echo "($PREV_JUNIT_TOTAL - $PREV_JUNIT_FAIL - $PREV_JUNIT_SKIP )" | bc)

#=========================================================================================
#Checking if the FLAG is set to send email

cat << EOF > $WORKSPACE/CompareResultSummary.txt
Unit Tests Details:

    CURR Build      Passed=$CURR_JUNIT_PASS     |   Failed=$CURR_JUNIT_FAIL     |   Skipped=$CURR_JUNIT_SKIP
    PREV Build      Passed=$PREV_JUNIT_PASS     |   Failed=$PREV_JUNIT_FAIL     |   Skipped=$PREV_JUNIT_SKIP
=========================================================================================

EOF
