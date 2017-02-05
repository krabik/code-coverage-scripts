#!/bin/bash
#=========================================================================================

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
    XUNIT_XML="current_XUNIT.xml"
    XUNIT_PREV_XML="previous_XUNIT.xml"

#Clear old reports
    rm $XUNIT_XML $XUNIT_PREV_XML
##### Extract CURRENT Unit Test Results
     curl --user ykhandelwal:d281b39fd700529e65201fcab6822779 ${BUILD_URL}testReport/api/xml --output $XUNIT_XML
    CURR_XUNIT_PASS=$(grep '<passCount>' $XUNIT_XML | cut -f9 -d">"| cut -f1 -d"<"|bc)
    CURR_XUNIT_FAIL=$(grep '<passCount>' $XUNIT_XML | cut -f7 -d">"| cut -f1 -d"<"|bc)
    CURR_XUNIT_SKIP=$(grep '<passCount>' $XUNIT_XML | cut -f11 -d">"| cut -f1 -d"<"|bc)
    CURR_XUNIT_TOTAL=$(echo "($CURR_XUNIT_PASS + $CURR_XUNIT_FAIL + $CURR_XUNIT_SKIP )" | bc)
##### Extract PREVIOUS Unit Test Results
    curl --user ykhandelwal:d281b39fd700529e65201fcab6822779 ${JOB_URL}lastStableBuild/testReport/api/xml --output $XUNIT_PREV_XML
    PREV_XUNIT_PASS=$(grep '<passCount>' $XUNIT_PREV_XML | cut -f9 -d">"| cut -f1 -d"<"|bc)
    PREV_XUNIT_FAIL=$(grep '<passCount>' $XUNIT_PREV_XML | cut -f7 -d">"| cut -f1 -d"<"|bc)
    PREV_XUNIT_SKIP=$(grep '<passCount>' $XUNIT_PREV_XML | cut -f11 -d">"| cut -f1 -d"<"|bc)
    PREV_XUNIT_TOTAL=$(echo "($PREV_XUNIT_PASS + $PREV_XUNIT_FAIL + $PREV_XUNIT_SKIP )" | bc)

#=========================================================================================
#Checking if the FLAG is set to send email

cat << EOF > $WORKSPACE/CompareResultSummary.txt
Functional Tests Details:

    CURR Build      Passed=$CURR_XUNIT_PASS     |   Failed=$CURR_XUNIT_FAIL     |   Skipped=$CURR_XUNIT_SKIP
    PREV Build      Passed=$PREV_XUNIT_PASS     |   Failed=$PREV_XUNIT_FAIL     |   Skipped=$PREV_XUNIT_SKIP
=========================================================================================

EOF
