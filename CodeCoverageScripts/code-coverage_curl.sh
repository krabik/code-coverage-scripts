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

    UT_COVERAGE_BASELINE=85.00
    JUNIT_XML="current_junit.xml"
    JUNIT_PREV_XML="previous_junit.xml"
    UT_COVERAGE_XML="current_coverage_jacoco.xml"
    UT_PREV_COVERAGE_XML="previous_coverage_jacoco.xml"
    COVERAGE_TOOL="jacoco"

#Clear old reports
    rm $JUNIT_XML $JUNIT_PREV_XML
##### Extract CURRENT Unit Test Results
    curl --user ykhandelwal:d281b39fd700529e65201fcab6822779 ${BUILD_URL}testReport/api/xml --output $JUNIT_XML
    sleep 20
    CURR_JUNIT_PASS=$(cat $JUNIT_XML | tr '<' '\n'|grep -a passCount -A1|grep passCount|cut -f2 -d">" |head -1 |bc)
    CURR_JUNIT_FAIL=$(cat $JUNIT_XML | tr '<' '\n'|grep -a failCount -A1|grep failCount|cut -f2 -d">" |head -1 |bc)
    CURR_JUNIT_SKIP=$(cat $JUNIT_XML | tr '<' '\n'|grep -a skipCount -A1|grep skipCount|cut -f2 -d">" |head -1 |bc)
    CURR_JUNIT_TOTAL=$(echo "($CURR_JUNIT_PASS + $CURR_JUNIT_FAIL + $CURR_JUNIT_SKIP )" | bc)
##### Extract PREVIOUS Unit Test Results
    curl --user ykhandelwal:d281b39fd700529e65201fcab6822779 ${JOB_URL}lastSuccessfulBuild/testReport/api/xml --output $JUNIT_PREV_XML
    sleep 20
    PREV_JUNIT_PASS=$(cat $JUNIT_PREV_XML | tr '<' '\n'|grep -a passCount -A1|grep passCount|cut -f2 -d">" |head -1 |bc)
    PREV_JUNIT_FAIL=$(cat $JUNIT_PREV_XML | tr '<' '\n'|grep -a failCount -A1|grep failCount|cut -f2 -d">" |head -1 |bc)
    PREV_JUNIT_SKIP=$(cat $JUNIT_PREV_XML | tr '<' '\n'|grep -a skipCount -A1|grep skipCount|cut -f2 -d">" |head -1 |bc)
    PREV_JUNIT_TOTAL=$(echo "($CURR_JUNIT_PASS + $CURR_JUNIT_FAIL + $CURR_JUNIT_SKIP )" | bc)
##### Extract PREVIOUS Unit Test Results


##### **************** UNIT TEST CODE COVERAGE **************** #####
##### Extract CURRENT coverage info
##Get Current Total number of lines
	curl --user ykhandelwal:d281b39fd700529e65201fcab6822779 ${BUILD_URL}jacoco/api/xml --output $UT_COVERAGE_XML
	UT_CURR_MISSED_TOTAL=$(grep '<lineCoverage>' $UT_COVERAGE_XML | cut -f54 -d">" | cut -f1 -d"<" | bc)
	UT_CURR_COV_TOTAL=$(grep '<lineCoverage>' $UT_COVERAGE_XML | cut -f52 -d">" | cut -f1 -d"<")
	UT_CURR_LINE_TOTAL=$((UT_CURR_MISSED_TOTAL+UT_CURR_COV_TOTAL))
##Get Current Covered Lines & round off
	UT_CURR_LINE_COV=$((UT_CURR_COV_TOTAL))

##### Extract PREVIOUS coverage info
#Get Previous Total number of lines
	curl --user ykhandelwal:d281b39fd700529e65201fcab6822779 ${JOB_URL}lastSuccessfulBuild/jacoco/api/xml --output $UT_PREV_COVERAGE_XML
	UT_PREV_MISSED_TOTAL=$(grep '<lineCoverage>' $UT_PREV_COVERAGE_XML | cut -f54 -d">" | cut -f1 -d"<" | bc)
	UT_PREV_COV_TOTAL=$(grep '<lineCoverage>' $UT_PREV_COVERAGE_XML | cut -f52 -d">" | cut -f1 -d"<" | bc)
	UT_PREV_LINE_TOTAL=$((UT_PREV_MISSED_TOTAL+UT_PREV_COV_TOTAL))
##Get Current Covered Lines & round off
	UT_PREV_LINE_COV=$((UT_PREV_COV_TOTAL))




#=========================================================================================
##Calculate Current UT Code Coverage
UT_CURR_CODE_COV=0
UT_CURR_CODE_COV=$(grep '<lineCoverage>' $UT_COVERAGE_XML | cut -f58 -d">" | cut -f1 -d"<")
#Limit the decimal to 5 digits (No Rounding)
UT_CURR_CODE_COV_RND=$UT_CURR_CODE_COV
#Calculate Current Line difference
UT_CURR_LINE_DIFF=$(echo "($UT_CURR_LINE_TOTAL - $UT_CURR_LINE_COV)" | bc -l)

## Print in logs for debugging
echo "#### CURRENT LINE COVERAGE #### "
echo "INFO: Total Lines =  $UT_CURR_LINE_TOTAL"
echo "INFO: Covered Lines = $UT_CURR_LINE_COV"
echo "INFO: Code Coverage = $UT_CURR_CODE_COV"
echo "INFO: Line Difference = $UT_CURR_LINE_DIFF"

## Calculate Previous Code Coverage
UT_PREV_CODE_COV=0
UT_PREV_CODE_COV=$(grep '<lineCoverage>' $UT_PREV_COVERAGE_XML | cut -f58 -d">" | cut -f1 -d"<")
#Limit the decimal to 5 digits (No Rounding)
UT_PREV_CODE_COV_RND=$UT_PREV_CODE_COV
#Calculate Previous Line difference
UT_PREV_LINE_DIFF=$(echo "($UT_PREV_LINE_TOTAL - $UT_PREV_LINE_COV)" | bc -l)


## Coverage in this build increased or decreased by
UT_CC_OVERALL_DELTA=$(echo "($UT_CURR_CODE_COV - $UT_PREV_CODE_COV)" | bc -l)

## Print in logs for debugging
echo "#### PREVIOUS LINE COVERAGE #### "
echo "INFO: Total Lines =  $UT_PREV_LINE_TOTAL"
echo "INFO: Covered Lines = $UT_PREV_LINE_COV"
echo "INFO: Code Coverage = $UT_PREV_CODE_COV"
echo "INFO: Line Difference = $UT_PREV_LINE_DIFF"

#=========================================================================================

##### UT Coverage Comparison
#Calculate Coverage Difference
UT_CC_TOTAL_DIFF=$(echo "($UT_CURR_LINE_TOTAL - $UT_PREV_LINE_TOTAL)" | bc -l)
UT_CC_COV_DIFF=$(echo "($UT_CURR_LINE_COV - $UT_PREV_LINE_COV)" | bc -l)
echo $UT_CC_COV_DIFF
if [ $UT_CC_COV_DIFF -eq 0 -a $UT_CC_TOTAL_DIFF -eq 0 ]
then
    echo "1#############################################"
    UT_CC_COMPARE_VALUE="NA"
elif [ $UT_CC_COV_DIFF -ge 0 -a $UT_CC_TOTAL_DIFF -eq 0 ]
then
    echo "2#############################################"
    UT_CC_COMPARE_VALUE="NA"
elif [ $UT_CC_COV_DIFF -ge 0 -a $UT_CC_TOTAL_DIFF -lt 0 ]
then
    echo "3#############################################"
    UT_CC_COMPARE_VALUE=$(echo "100.00" | bc -l)
elif [ $UT_CC_COV_DIFF -le 0 -a $UT_CC_TOTAL_DIFF -eq 0 ]
then
    echo "4#############################################"
    UT_CC_COMPARE_VALUE="NA"
elif [ $UT_CC_COV_DIFF -le 0 -a $UT_CC_TOTAL_DIFF -lt 0 ]
then
    echo "5#############################################"
    UT_CC_COMPARE_VALUE=$(echo "0.00" | bc -l)
elif [ $UT_CC_COV_DIFF -le 0 -a $UT_CC_TOTAL_DIFF -ge 0 ]
then
    echo "6#############################################"
    UT_CC_COMPARE_VALUE=$(echo "0.00" | bc -l)
else
    echo "7#############################################"
    #UT_CC_MISSED_DIFF=$(echo "($UT_CURR_MISSED_TOTAL - $UT_PREV_MISSED_TOTAL)" | bc -l)
    UT_CC_COMPARE_VALUE=$(echo "($UT_CC_COV_DIFF * 100 / $UT_CC_TOTAL_DIFF)" | bc -l | awk '{printf "%0.2f", $1}')
    if [[ $(echo "$UT_CC_COMPARE_VALUE > 100" | bc) -eq 1 ]]
    then
        echo "INFO: Delta is more than 100"
        UT_CC_COMPARE_VALUE=$(echo "100.00" | bc -l)
    fi
    echo $UT_CC_COV_DIFF
    echo "*********************************"
    echo $UT_CC_TOTAL_DIFF
fi




## Coverage Comparison Check
#Reduced
UT_CC_COMPARE_RESULT=$(echo "$UT_CURR_CODE_COV < $UT_PREV_CODE_COV" | bc -l)
if [ $UT_CC_COMPARE_RESULT -eq 1 ]
then
    UT_DIFF_MSG="REDUCED"
fi

#Unchanged
UT_CC_COMPARE_RESULT=$(echo "$UT_CURR_CODE_COV == $UT_PREV_CODE_COV" | bc -l)
if [ $UT_CC_COMPARE_RESULT -eq 1 ]
then
    UT_DIFF_MSG="UNCHANGED"
fi

#Increased
UT_CC_COMPARE_RESULT=$(echo "$UT_CURR_CODE_COV > $UT_PREV_CODE_COV" | bc -l)
if [ $UT_CC_COMPARE_RESULT -eq 1 ]
then
    UT_DIFF_MSG="INCREASED"
fi

##### LINE Comparison
#LINE_COMPARE_RESULT=$(echo "$CURR_LINE_DIFF > $PREV_LINE_DIFF" | bc -l)
#Calculate Line Difference
UT_LINE_COMPARE_VALUE=$(echo "($UT_CURR_LINE_DIFF - $UT_PREV_LINE_DIFF)" | bc -l)

## Line Comparison Check
if [ $UT_LINE_COMPARE_VALUE -gt 0 ]
then
    UT_LINE_DIFF_MSG="INCREASED"
elif [ $UT_LINE_COMPARE_VALUE -lt 0 ]
then
    UT_LINE_DIFF_MSG="REDUCED"
else
    UT_LINE_DIFF_MSG="UNCHANGED"
fi

# Make the value absolute value
#LINE_COMPARE_VALUE_ABS=$(echo $LINE_COMPARE_VALUE | awk '{ print ($1 >= 0) ? $1 : 0 - $1}')
UT_LINE_COMPARE_VALUE_ABS=$(echo $UT_LINE_COMPARE_VALUE | awk '{ if($1>=0) { print $1} else {print $1*-1 }}')

## Print in logs for debugging
echo "INFO: Code Coverage LINE_DIFF_MSG = $UT_LINE_DIFF_MSG"
echo "INFO: Line Coverage Diff = $UT_LINE_COMPARE_VALUE"
echo "INFO: Line Coverage Diff (ABS) = $UT_LINE_COMPARE_VALUE_ABS"

##### NEW Lines Coverage Calculations
#Calculate Total Line diff
UT_TOTAL_LINE_DIFF=$(echo "($UT_CURR_LINE_TOTAL - $UT_PREV_LINE_TOTAL)" | bc -l)
#Calculate Covered Line diff
UT_COV_LINE_DIFF=$(echo "($UT_CURR_LINE_COV - $UT_PREV_LINE_COV)" | bc -l)

## Comparison check
if [ $UT_COV_LINE_DIFF == 0 -a $UT_TOTAL_LINE_DIFF == 0 ]
then
    #No change in total lines & covered lines, set coverage % to empty
    UT_COV_DIFF_MSG="NO LINE DIFF than"
    UT_COVERAGE_PERCENTAGE=""
elif [ $UT_COV_LINE_DIFF -ge 0 -a $UT_TOTAL_LINE_DIFF -eq 0 ]
then
      #UT_COV_DIFF_MSG="NO NEW LINEs than but Covered Line"
      UT_COV_DIFF_MSG="Total LINEs removed than"
      UT_COVERAGE_PERCENTAGE=100
elif [ $UT_COV_LINE_DIFF -ge 0 -a $UT_TOTAL_LINE_DIFF -lt 0 ]
then
      #UT_COV_DIFF_MSG="NO NEW LINEs than but Covered Line"
      UT_COV_DIFF_MSG="Total LINEs removed than"
      UT_COVERAGE_PERCENTAGE=100
elif [ $UT_COV_LINE_DIFF -le 0 -a $UT_TOTAL_LINE_DIFF -le 0 ]
then
       UT_COV_DIFF_MSG="Covered LINEs removed than"
       UT_COVERAGE_PERCENTAGE=0
elif [ $UT_COV_LINE_DIFF -le 0 -a $UT_TOTAL_LINE_DIFF -ge 0 ]
then
       UT_COV_DIFF_MSG="Covered LINEs removed than"
       UT_COVERAGE_PERCENTAGE=0
#
#elif [ $UT_TOTAL_LINE_DIFF == 0 ]
#then
#    #No change in total lines, set coverage % to empty
#    UT_COV_DIFF_MSG="NO NEW LINEs than"
#    UT_COVERAGE_PERCENTAGE=0
#elif [[ $(echo "$UT_TOTAL_LINE_DIFF < 0" | bc) -eq 1 ]]
#then
#    #Total lines reduced, set coverage % to empty
#    UT_COV_DIFF_MSG="Total LINEs removed than"
#    UT_COVERAGE_PERCENTAGE=0
#elif [[ $(echo "$UT_COV_LINE_DIFF < 0" | bc) -eq 1 ]]
#then
#    #Covered lines reduced, set coverage % to empty
#    UT_COV_DIFF_MSG="Covered LINEs removed than"
#    UT_COVERAGE_PERCENTAGE=0
else
    #Calculate the Coverage % for new lines (Change in total lines & covered lines)
    UT_COVERAGE_PERCENTAGE=$(echo "$UT_COV_LINE_DIFF * 100 / $UT_TOTAL_LINE_DIFF" | bc -l | awk '{printf "%0.2f", $1}')
    #If coverage % is more than 100, change it to 100
    if [[ $(echo "$UT_COVERAGE_PERCENTAGE > 100" | bc) -eq 1 ]]
    then
        echo "INFO: COVERAGE_PERCENTAGE is more than 100"
        UT_COVERAGE_PERCENTAGE=100
    fi
fi

#Set Unit Test Coverage Baseline to Previous stable Code coverage value
#UT_COVERAGE_BASELINE=$UT_PREV_CODE_COV

#If % is empty then set it to 'NA'
if [ -z "$UT_COVERAGE_PERCENTAGE" ]; then
    #If % is empty then set it to 'NA'
    echo "INFO: COVERAGE_PERCENTAGE is empty"
    UT_COVERAGE_PERCENTAGE="NA"
    UT_COV_DIFF_MSG="NA"
else
    #If % is not empty then do condition check - above, below, in par
    echo "INFO: COVERAGE_PERCENTAGE is NOT empty"
    #Below Baseline
    UT_CC_BASELINE_COMPARE_RESULT=$(echo "$UT_PREV_CODE_COV > $UT_COVERAGE_BASELINE" | bc -l)
    if [ $UT_CC_BASELINE_COMPARE_RESULT -eq 1 ]
    then
    UT_COVERAGE_BASELINE="$UT_COVERAGE_BASELINE"
    fi

    UT_CC_BASELINE_COMPARE_RESULT=$(echo "$UT_PREV_CODE_COV < $UT_COVERAGE_BASELINE" | bc -l)
    if [ $UT_CC_BASELINE_COMPARE_RESULT -eq 1 ]
    then
    UT_COVERAGE_BASELINE="$UT_PREV_CODE_COV"
    fi

    UT_CC_BASELINE_COMPARE_RESULT=$(echo "$UT_PREV_CODE_COV == $UT_COVERAGE_BASELINE" | bc -l)
    if [ $UT_CC_BASELINE_COMPARE_RESULT -eq 1 ]
    then
    UT_COVERAGE_BASELINE="$UT_PREV_CODE_COV"
    fi

    UT_COV_PER_DIFF=$(echo "$UT_COVERAGE_PERCENTAGE < $UT_COVERAGE_BASELINE" | bc -l)
    if [ $UT_COV_PER_DIFF -eq 1 ]; then
        UT_COV_DIFF_MSG="BELOW"
    fi
    #Above Baseline
    UT_COV_PER_DIFF=$(echo "$UT_COVERAGE_PERCENTAGE > $UT_COVERAGE_BASELINE" | bc -l)
    if [ $UT_COV_PER_DIFF -eq 1 ]; then
        UT_COV_DIFF_MSG="ABOVE"
    fi
    #In Par with Baseline
    UT_COV_PER_DIFF=$(echo "$UT_COVERAGE_PERCENTAGE == $UT_COVERAGE_BASELINE" | bc -l)
    if [ $UT_COV_PER_DIFF -eq 1 ]; then
        UT_COV_DIFF_MSG="IN PAR with"
    fi
fi

#If coverage % is negative number, make it absolute value
if [ "$UT_COVERAGE_PERCENTAGE" != "NA" ]
then
    if [[ $(echo "$UT_COVERAGE_PERCENTAGE < 0" | bc) -eq 1 ]]
    then
        echo "INFO: UT COVERAGE_PERCENTAGE is -ve : $UT_COVERAGE_PERCENTAGE"
        UT_COVERAGE_PERCENTAGE=$(echo "$UT_COVERAGE_PERCENTAGE" |  awk '{ if($1>=0) { print $1} else {print $1*-1 }}')
    fi
fi

##### Write required info to txt files for email notification
#echo "Code Coverage is $DIFF_MSG , Line with no coverage is $LINE_DIFF_MSG" > $WORKSPACE/CompareResultSubject.txt
## Email Warning
if [[ "$UT_COV_DIFF_MSG" = "BELOW" ]] || [[ "$UT_DIFF_MSG" = "REDUCED" ]]
then
    echo "[WARNING] " > $WORKSPACE/MessageSubject.txt
elif [[ "$UT_COV_DIFF_MSG" = "ABOVE" ]] && [[ "$UT_DIFF_MSG" = "INCREASED" ]]
then
    echo "[WooHoo] " > $WORKSPACE/MessageSubject.txt
elif [[ "$UT_COV_DIFF_MSG" != "ABOVE" ]] && [[ "$UT_DIFF_MSG" = "INCREASED" ]]
then
    echo "[NICE] " > $WORKSPACE/MessageSubject.txt
else
    echo "[INFO] " > $WORKSPACE/MessageSubject.txt
fi

#=========================================================================================

#Function for 2 digit round off for email subject
round()
{
echo $(printf %.$2f $(echo "scale=$2;(((10^$2)*$1)+0.5)/(10^$2)" | bc))
};

if [ "$UT_CC_COMPARE_VALUE" != "NA" ]
then
UT_CC_COMPARE_VALUE_2=$(echo $(round $UT_CC_COMPARE_VALUE 2));
else
UT_CC_COMPARE_VALUE_2="NA"
fi
UT_CURR_CODE_COV_2=$(echo $(round $UT_CURR_CODE_COV 2));
## Email Subject based on Unit Test Coverage

if [[ "$UT_DIFF_MSG" = "REDUCED" ]]
then
    SUBJECT_MSG="↓"
elif [[ "$UT_DIFF_MSG" = "INCREASED" ]]
then
    SUBJECT_MSG="↑"
elif [[ "$UT_DIFF_MSG" = "UNCHANGED" ]]
then
    SUBJECT_MSG="="
fi

##Remove Delta if coverage is more than 85 %
echo "$UT_CURR_CODE_COV_2"
 if [[ $(echo "$UT_CURR_CODE_COV_2 > 85" | bc) -eq 1 ]]
    then
        echo "[Failed Tests: $CURR_JUNIT_FAIL | CC =$UT_CURR_CODE_COV_2%: $SUBJECT_MSG]" > $WORKSPACE/CompareResultSubject.txt
 else
    if [ "$UT_CC_COMPARE_VALUE_2" != "NA" ]
    then
        echo "[Failed Tests: $CURR_JUNIT_FAIL | CC = $UT_CURR_CODE_COV_2% : $SUBJECT_MSG | Delta CC : $UT_CC_COMPARE_VALUE_2%]" > $WORKSPACE/CompareResultSubject.txt
    else
        echo "[Failed Tests: $CURR_JUNIT_FAIL | CC = $UT_CURR_CODE_COV_2% : $SUBJECT_MSG | Delta CC : $UT_CC_COMPARE_VALUE_2]" > $WORKSPACE/CompareResultSubject.txt
    fi
fi
## Email Body values
#echo -e "Code Coverage for new lines $COVERAGE_PERCENTAGE which is $COV_DIFF_MSG the Baseline $COVERAGE_BASELINE% #" > $WORKSPACE/CompareResultSummary.txt
#echo -e "\nCode Coverage $DIFF_MSG by $CC_COMPARE_VALUE_RND  %\n\tCURRENT Build\t\t: $CURR_CODE_COV_RND  %\n\tPREVIOUS Build\t: $PREV_CODE_COV_RND  %" >> $WORKSPACE/CompareResultSummary.txt
#echo -e "\nUncovered lines $LINE_DIFF_MSG by $LINE_COMPARE_VALUE_ABS * \n\tCURRENT Line Diff\t: $CURR_LINE_DIFF\n\tPREVIOUS Line Diff\t: $PREV_LINE_DIFF" >> $WORKSPACE/CompareResultSummary.txt
#echo -e "\n\tCURRENT Build\t\tTotal Lines=$CURR_LINE_TOTAL\t|\tCovered Lines=$CURR_LINE_COV" >> $WORKSPACE/CompareResultSummary.txt
#echo -e "\tPREVIOUS Build\tTotal Lines=$PREV_LINE_TOTAL\t|\tCovered Lines=$PREV_LINE_COV" >> $WORKSPACE/CompareResultSummary.txt
#echo -e "\tDIFFERENCE\t\tTotal Lines=$TOTAL_LINE_DIFF\t\t|\tCovered Lines=$COV_LINE_DIFF" >> $WORKSPACE/CompareResultSummary.txt


## Check if Current & Previous Build coverage.xml exists
#=========================================================================================

if [[ -e $JUNIT_XML ]]
then
    BUILD_FAILURE_FLAG=false
else
    echo "There is a Build Failure."
    FAILURE_MSG_1="There is a Build Failure."
    BUILD_FAILURE_FLAG=true
fi


#UT
if [[ $CURR_JUNIT_FAIL -gt 0 ]]
then
    UT_MSG="FAILED : $CURR_JUNIT_PASS P, $CURR_JUNIT_FAIL F, $CURR_JUNIT_SKIP S"
elif [[ ! -e $JUNIT_XML ]]
then
    UT_MSG="DIDNOT EXECUTE"
elif [[ $CURR_JUNIT_FAIL -eq 0 ]] && [[ $CURR_JUNIT_PASS -eq 0 ]]
then
    UT_MSG="DIDNOT EXECUTE"
elif [[ $CURR_JUNIT_FAIL -eq 0 ]]
then
    UT_MSG="PASSED : $CURR_JUNIT_PASS P, $CURR_JUNIT_FAIL F, $CURR_JUNIT_SKIP S"
else
    UT_MSG="PANICKED"
fi

#=========================================================================================

##COV BASED ON UNIT COV BASELINE VALUE
echo UT_COV_DIFF_MSG=$UT_COV_DIFF_MSG
if [[ $UT_COV_DIFF_MSG == "BELOW" ]]
then
    CC_MSG="Reduced below Baseline of $UT_PREV_CODE_COV%"
elif [[ ! -e $UT_COVERAGE_XML ]]
then
    CC_MSG="DIDNOT EXECUTE"
elif [[ $UT_COV_DIFF_MSG == "IN PAR with" ]] || [[ $UT_COV_DIFF_MSG == "ABOVE" ]]
then
    CC_MSG="Coverage above or on Par with Baseline of $UT_PREV_CODE_COV%"
elif [[ $UT_COV_DIFF_MSG == "NA" ]]
then
    CC_MSG="Unit Test COVERAGE for New Lines : $UT_DIFF_MSG by $UT_CC_COMPARE_VALUE [CC for new lines should not reduce below existing baseline of $UT_PREV_CODE_COV%]"
fi

FAILURE_MSG_1=""
FAILURE_MSG_2=""


echo $FAILURE_MSG_1 > $WORKSPACE/FailureMsg.txt
printf "%s\n" "Job Failed as : " >> $WORKSPACE/FailureMsg.txt
printf "\t%s\n" "Unit Tests : $UT_MSG" >> $WORKSPACE/FailureMsg.txt
#printf "\t%s\n" "Smoke Tests : $IT_MSG" >> $WORKSPACE/FailureMsg.txt
printf "\t%s\n" "Code Coverage : $CC_MSG" >> $WORKSPACE/FailureMsg.txt
echo "UT_DIFF_MSG=$UT_DIFF_MSG"
if [[ $CURR_JUNIT_FAIL -gt 0 ]] || [[ $UT_COV_DIFF_MSG == "BELOW" ]] || [[ $CURR_JUNIT_FAIL == "" ]]
then
echo "BUILD_STATUS_ON_COVERAGE_N_TEST_FAILED"
BUILD_FAILURE_FLAG=true
SUB1="Reason : "
SUB3="Failure"
    if [[ $CURR_JUNIT_FAIL -gt 0 ]] || [[ ! -e $UT_COVERAGE_XML ]] || [[ $CURR_JUNIT_FAIL -eq 0 && $CURR_JUNIT_PASS -eq 0 ]]
    then
       SUB2="UnitTest"
    fi
    if [[ $UT_COV_DIFF_MSG == "BELOW" ]]
    then
       SUB2="$SUB2 CodeCoverage"
    fi
    if [[ $SUB2 == "" ]]
    then
       SUB2="Compilation/Build"
    fi
    echo "[ $SUB1 $SUB2 $SUB3 ]" #> $WORKSPACE/CompareResultSubject.txt
    printf "\t%s\t%s\t%s\n" "$SUB1 $SUB2 $SUB3" >> $WORKSPACE/FailureMsg.txt
elif [[ "$BUILD_FAILURE_FLAG" = false ]]
then
echo "BUILD_STATUS_ON_COVERAGE_N_TEST_PASSED"
BUILD_FAILURE_FLAG=false
fi


#=========================================================================================
#Checking if the FLAG is set to send email
if [[ "$BUILD_FAILURE_FLAG" = false ]] ; then
cat << EOF > $WORKSPACE/CompareResultSummary.txt
Code Coverage Details:

=========================================================================================
Unit Test Code Coverage for New Lines $UT_COVERAGE_PERCENTAGE which is $UT_COV_DIFF_MSG the Baseline $UT_PREV_CODE_COV% #

Overall Code Coverage $UT_DIFF_MSG by $UT_CC_OVERALL_DELTA %
    CURRENT Build   : $UT_CURR_CODE_COV  %
    PREVIOUS Build  : $UT_PREV_CODE_COV  %

Uncovered lines $UT_LINE_DIFF_MSG by $UT_LINE_COMPARE_VALUE *

    CURRENT Build       Total Lines=$UT_CURR_LINE_TOTAL         |   Covered Lines=$UT_CURR_LINE_COV |   Uncovered Lines=$UT_CURR_LINE_DIFF
    PREVIOUS Build      Total Lines=$UT_PREV_LINE_TOTAL         |   Covered Lines=$UT_PREV_LINE_COV |   Uncovered Lines=$UT_PREV_LINE_DIFF
    --------------------------------------------------------------------------------------------------------------------
    DIFFERENCE         Total Lines=$UT_TOTAL_LINE_DIFF      |   Covered Lines=$UT_COV_LINE_DIFF     |   Uncovered Lines=$UT_LINE_COMPARE_VALUE


=========================================================================================

Unit Tests

    CURR Build      Passed=$CURR_JUNIT_PASS     |   Failed=$CURR_JUNIT_FAIL     |   Skipped=$CURR_JUNIT_SKIP
    PREV Build      Passed=$PREV_JUNIT_PASS     |   Failed=$PREV_JUNIT_FAIL     |   Skipped=$PREV_JUNIT_SKIP
=========================================================================================

# Code Coverage for new lines is calculated as Percentage of lines added with respect to change in covered lines. (In certain scenarios, this may not indicate code coverage only for new lines).
*  Uncovered Lines are calculated as Difference of (Total Lines - Covered Lines) for Current and Previous builds.
** Coverage % for additional lines is NA when there is no new lines added

===========================================================

EOF
else
#echo "[FAILURE] " > $WORKSPACE/MessageSubject.txt
cat << EOF > $WORKSPACE/CompareResultSummary.txt
=========================================================================================

$(cat $WORKSPACE/FailureMsg.txt)

Code Coverage Details:

=========================================================================================
Unit Test Code Coverage for new lines $UT_COVERAGE_PERCENTAGE which is $UT_COV_DIFF_MSG the Baseline $UT_PREV_CODE_COV% #

Code Coverage $UT_DIFF_MSG by $UT_CC_OVERALL_DELTA  %
    CURRENT Build   : $UT_CURR_CODE_COV  %
    PREVIOUS Build  : $UT_PREV_CODE_COV  %

Uncovered lines $UT_LINE_DIFF_MSG by $UT_LINE_COMPARE_VALUE *

    CURRENT Build       Total Lines=$UT_CURR_LINE_TOTAL         |   Covered Lines=$UT_CURR_LINE_COV |   Uncovered Lines=$UT_CURR_LINE_DIFF
    PREVIOUS Build      Total Lines=$UT_PREV_LINE_TOTAL         |   Covered Lines=$UT_PREV_LINE_COV |   Uncovered Lines=$UT_PREV_LINE_DIFF
    --------------------------------------------------------------------------------------------------------------------
    DIFFERENCE         Total Lines=$UT_TOTAL_LINE_DIFF      |   Covered Lines=$UT_COV_LINE_DIFF     |   Uncovered Lines=$UT_LINE_COMPARE_VALUE

=========================================================================================

Unit Tests

    CURR Build      Passed=$CURR_JUNIT_PASS     |   Failed=$CURR_JUNIT_FAIL     |   Skipped=$CURR_JUNIT_SKIP
    PREV Build      Passed=$PREV_JUNIT_PASS     |   Failed=$PREV_JUNIT_FAIL     |   Skipped=$PREV_JUNIT_SKIP
=========================================================================================


# Code Coverage for new lines is calculated as Percentage of lines added with respect to change in covered lines. (In certain scenarios, this may not indicate code coverage only for new lines).
*  Uncovered Lines are calculated as Difference of (Total Lines - Covered Lines) for Current and Previous builds.
** Coverage % for additional lines is NA when there is no new lines added


=========================================================================================
EOF
fi



##### Write coverage info as key=value in a txt files which will be archived for future use
COVERAGE_INFO_FILE="$WORKSPACE/coverage_info.txt"
echo "PARENT_BUILD_NUMBER=$PARENT_BUILD_NUMBER" > $COVERAGE_INFO_FILE
echo "BUILD_NUMBER=$BUILD_NUMBER" >> $COVERAGE_INFO_FILE
echo "SVN_REVISION=$SVN_REVISION" >> $COVERAGE_INFO_FILE
echo "CURR_LINE_TOTAL=$UT_CURR_LINE_TOTAL" >> $COVERAGE_INFO_FILE
echo "PREV_LINE_TOTAL=$UT_PREV_LINE_TOTAL" >> $COVERAGE_INFO_FILE
echo "CURR_LINE_COV=$UT_CURR_LINE_COV" >> $COVERAGE_INFO_FILE
echo "PREV_LINE_COV=$UT_PREV_LINE_COV" >> $COVERAGE_INFO_FILE
echo "CURR_CODE_COV=$UT_CURR_CODE_COV" >> $COVERAGE_INFO_FILE
echo "PREV_CODE_COV=$UT_PREV_CODE_COV" >> $COVERAGE_INFO_FILE

## Print in logs for debugging
echo "CompareResultSubject"
cat "$WORKSPACE/CompareResultSubject.txt"
echo "CompareResultSummary"
cat "$WORKSPACE/CompareResultSummary.txt"
echo "MessageSubject"
cat "$WORKSPACE/MessageSubject.txt"
echo "coverage_info"
cat "$COVERAGE_INFO_FILE"

## Print in logs for debugging
echo "CURR_JUNIT_TOTAL=$CURR_JUNIT_TOTAL"
echo "CURR_JUNIT_FAIL=$CURR_JUNIT_FAIL"
echo "CURR_JUNIT_SKIP=$CURR_JUNIT_SKIP"
echo "CURR_JUNIT_PASS=$CURR_JUNIT_PASS"
echo "PREV_JUNIT_TOTAL=$PREV_JUNIT_TOTAL"
echo "PREV_JUNIT_FAIL=$PREV_JUNIT_FAIL"
echo "PREV_JUNIT_SKIP=$PREV_JUNIT_SKIP"
echo "PREV_JUNIT_PASS=$PREV_JUNIT_PASS"
echo "UT_COV_LINE_DIFF=$UT_COV_LINE_DIFF"
echo "--------------------------"
echo "CURR_IT_PASS=$CURR_IT_PASS"
echo "CURR_IT_FAIL=$CURR_IT_FAIL"
echo "CURR_IT_TOTAL=$CURR_IT_TOTAL"
echo "PREV_IT_PASS=$PREV_IT_PASS"
echo "PREV_IT_FAIL=$PREV_IT_FAIL"
echo "PREV_IT_TOTAL=$PREV_IT_TOTAL"
