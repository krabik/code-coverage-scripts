#!/bin/bash
#=========================================================================================
## DESCRIPTION: Script to validate Current build code coverage numbers with previous build

## USAGE: code-coverage-check.sh Arg1
##              Arg1 -- Jenkins Job type (Trunk, iOS, Android, JS)
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

    IT_COVERAGE_BASELINE=85.00
    FITNESSE_XML="current_FITNESSE.xml"
    FITNESSE_PREV_XML="previous_FITNESSE.xml"
    IT_COVERAGE_XML="current_coverage_jacoco.xml"
    IT_PREV_COVERAGE_XML="previous_coverage_jacoco.xml"
    COVERAGE_TOOL="jacoco"

#Clear old reports
    rm $FITNESSE_XML $FITNESSE_PREV_XML
##### Extract CURRENT Fitnesse Test Results
<<<<<<< HEAD
    curl --user ykhandelwal:d281b39fd700529e65201fcab6822779 -k ${BUILD_URL}testReport/api/xml --output $FITNESSE_XML
    CURR_FITNESSE_PASS=$(grep '<passCount>' $FITNESSE_XML | cut -f9 -d">"| cut -f1 -d"<"|bc)
    CURR_FITNESSE_FAIL=$(grep '<passCount>' $FITNESSE_XML | cut -f7 -d">"| cut -f1 -d"<"|bc)
    CURR_FITNESSE_SKIP=$(grep '<passCount>' $FITNESSE_XML | cut -f11 -d">"| cut -f1 -d"<"|bc)
    CURR_FITNESSE_TOTAL=$(echo "($CURR_FITNESSE_PASS + $CURR_FITNESSE_FAIL + $CURR_FITNESSE_SKIP )" | bc)
##### Extract PREVIOUS Fitnesse Test Results
    curl --user ykhandelwal:d281b39fd700529e65201fcab6822779 -k ${JOB_URL}lastSuccessfulBuild/testReport/api/xml --output $FITNESSE_PREV_XML
    PREV_FITNESSE_PASS=$(grep '<passCount>' $FITNESSE_PREV_XML | cut -f9 -d">"| cut -f1 -d"<"|bc)
    PREV_FITNESSE_FAIL=$(grep '<passCount>' $FITNESSE_PREV_XML | cut -f7 -d">"| cut -f1 -d"<"|bc)
    PREV_FITNESSE_SKIP=$(grep '<passCount>' $FITNESSE_PREV_XML | cut -f11 -d">"| cut -f1 -d"<"|bc)
    PREV_FITNESSE_TOTAL=$(echo "($PREV_FITNESSE_PASS + $PREV_FITNESSE_FAIL + $PREV_FITNESSE_SKIP )" | bc)
=======
    curl -k ${BUILD_URL}fitnesseReport/api/xml --output $FITNESSE_XML
    CURR_FITNESSE_PASS=$(xmlstarlet sel -t -v "count(/fitnesseResults/passedTest)" $FITNESSE_XML | bc)
    CURR_FITNESSE_FAIL=$(xmlstarlet sel -t -v "count(/fitnesseResults/failedTest)" $FITNESSE_XML | bc)
    CURR_FITNESSE_TOTAL=$(echo "($CURR_FITNESSE_PASS + $CURR_FITNESSE_FAIL )" | bc)
##### Extract PREVIOUS Fitnesse Test Results
    curl -k ${JOB_URL}lastSuccessfulBuild/fitnesseReport/api/xml --output $FITNESSE_PREV_XML
    PREV_FITNESSE_PASS=$(xmlstarlet sel -t -v "count(/fitnesseResults/passedTest)" $FITNESSE_PREV_XML | bc)
    PREV_FITNESSE_FAIL=$(xmlstarlet sel -t -v "count(/fitnesseResults/failedTest)" $FITNESSE_PREV_XML | bc)
    PREV_FITNESSE_TOTAL=$(echo "($PREV_FITNESSE_PASS + $PREV_FITNESSE_FAIL )" | bc)
>>>>>>> c50df6521dde3a3c7653008d6f18c216246a69de
##### Extract PREVIOUS Fitnesse Test Results


##### **************** Fitnesse TEST CODE COVERAGE **************** #####
##### Extract CURRENT coverage info
##Get Current Total number of lines
<<<<<<< HEAD
     scp "jenkins@jenkins-master.pre-prod-aws.mint.com:$JENKINS_HOME/jobs/$JOB_NAME/builds/$BUILD_ID/archive/target/coverage-report/coverage-report.xml" "$IT_COVERAGE_XML"
    scp "jenkins@jenkins-master.pre-prod-aws.mint.com:$JENKINS_HOME/jobs/$JOB_NAME/builds/lastStableBuild/archive/target/coverage-report/coverage-report.xml" "$IT_PREV_COVERAGE_XML"

##### **************** UNIT TEST CODE COVERAGE **************** #####
##### Extract CURRENT coverage info
##Get Current Total number of lines
IT_CURR_MISSED_TOTAL=`xmlstarlet sel -t -c "/report/counter[@type="\"LINE\""]" $IT_COVERAGE_XML | awk '{print $3}' | awk -F"=" '{print $2}' | sed 's/\"//g'`
IT_CURR_COV_TOTAL=`xmlstarlet sel -t -c "/report/counter[@type="\"LINE\""]" $IT_COVERAGE_XML | awk '{print $4}' | awk -F"=" '{print $2}' | sed 's/\"//g' | sed 's/\/>//g'`
IT_CURR_LINE_TOTAL=$((IT_CURR_MISSED_TOTAL+IT_CURR_COV_TOTAL))
##Get Current Covered Lines & round off
IT_CURR_LINE_COV=$((IT_CURR_COV_TOTAL))

##### Extract PREVIOUS coverage info
#Get Previous Total number of lines
IT_PREV_MISSED_TOTAL=`xmlstarlet sel -t -c "/report/counter[@type="\"LINE\""]" $IT_PREV_COVERAGE_XML | awk '{print $3}' | awk -F"=" '{print $2}' | sed 's/\"//g'`
IT_PREV_COV_TOTAL=`xmlstarlet sel -t -c "/report/counter[@type="\"LINE\""]" $IT_PREV_COVERAGE_XML | awk '{print $4}' | awk -F"=" '{print $2}' | sed 's/\"//g' | sed 's/\/>//g'`
IT_PREV_LINE_TOTAL=$((IT_PREV_MISSED_TOTAL+IT_PREV_COV_TOTAL))
##Get Current Covered Lines & round off
IT_PREV_LINE_COV=$((IT_PREV_COV_TOTAL))
=======
    curl -k ${BUILD_URL}jacoco/api/xml --output $IT_COVERAGE_XML
    IT_CURR_MISSED_TOTAL=$(grep '<lineCoverage>' $IT_COVERAGE_XML | cut -f54 -d">" | cut -f1 -d"<" | bc)
    IT_CURR_COV_TOTAL=$(grep '<lineCoverage>' $IT_COVERAGE_XML | cut -f52 -d">" | cut -f1 -d"<")
    IT_CURR_LINE_TOTAL=$((IT_CURR_MISSED_TOTAL+IT_CURR_COV_TOTAL))
##Get Current Covered Lines & round off
    IT_CURR_LINE_COV=$((IT_CURR_COV_TOTAL))

##### Extract PREVIOUS coverage info
#Get Previous Total number of lines
    curl -k ${JOB_URL}lastSuccessfulBuild/jacoco/api/xml --output $IT_PREV_COVERAGE_XML
    IT_PREV_MISSED_TOTAL=$(grep '<lineCoverage>' $IT_PREV_COVERAGE_XML | cut -f54 -d">" | cut -f1 -d"<" | bc)
    IT_PREV_COV_TOTAL=$(grep '<lineCoverage>' $IT_PREV_COVERAGE_XML | cut -f52 -d">" | cut -f1 -d"<" | bc)
    IT_PREV_LINE_TOTAL=$((IT_PREV_MISSED_TOTAL+IT_PREV_COV_TOTAL))
##Get Current Covered Lines & round off
    IT_PREV_LINE_COV=$((IT_PREV_COV_TOTAL))
>>>>>>> c50df6521dde3a3c7653008d6f18c216246a69de




#=========================================================================================
##Calculate Current IT Code Coverage
IT_CURR_CODE_COV=0
IT_CURR_CODE_COV=$(grep '<lineCoverage>' $IT_COVERAGE_XML | cut -f58 -d">" | cut -f1 -d"<")
#Limit the decimal to 5 digits (No Rounding)
IT_CURR_CODE_COV_RND=$IT_CURR_CODE_COV
#Calculate Current Line difference
IT_CURR_LINE_DIFF=$(echo "($IT_CURR_LINE_TOTAL - $IT_CURR_LINE_COV)" | bc -l)

## Print in logs for debugging
echo "#### CURRENT LINE COVERAGE #### "
echo "INFO: Total Lines =  $IT_CURR_LINE_TOTAL"
echo "INFO: Covered Lines = $IT_CURR_LINE_COV"
echo "INFO: Code Coverage = $IT_CURR_CODE_COV"
echo "INFO: Line Difference = $IT_CURR_LINE_DIFF"

## Calculate Previous Code Coverage
IT_PREV_CODE_COV=0
IT_PREV_CODE_COV=$(grep '<lineCoverage>' $IT_PREV_COVERAGE_XML | cut -f58 -d">" | cut -f1 -d"<")
#Limit the decimal to 5 digits (No Rounding)
IT_PREV_CODE_COV_RND=$IT_PREV_CODE_COV
#Calculate Previous Line difference
IT_PREV_LINE_DIFF=$(echo "($IT_PREV_LINE_TOTAL - $IT_PREV_LINE_COV)" | bc -l)


## Coverage in this build increased or decreased by
IT_CC_OVERALL_DELTA=$(echo "($IT_CURR_CODE_COV - $IT_PREV_CODE_COV)" | bc -l)

## Print in logs for debugging
echo "#### PREVIOUS LINE COVERAGE #### "
echo "INFO: Total Lines =  $IT_PREV_LINE_TOTAL"
echo "INFO: Covered Lines = $IT_PREV_LINE_COV"
echo "INFO: Code Coverage = $IT_PREV_CODE_COV"
echo "INFO: Line Difference = $IT_PREV_LINE_DIFF"

#=========================================================================================

##### IT Coverage Comparison
#Calculate Coverage Difference
IT_CC_TOTAL_DIFF=$(echo "($IT_CURR_LINE_TOTAL - $IT_PREV_LINE_TOTAL)" | bc -l)
IT_CC_COV_DIFF=$(echo "($IT_CURR_LINE_COV - $IT_PREV_LINE_COV)" | bc -l)
echo $IT_CC_COV_DIFF
if [ $IT_CC_COV_DIFF -eq 0 -a $IT_CC_TOTAL_DIFF -eq 0 ]
then
    echo "1#############################################"
    IT_CC_COMPARE_VALUE="NA"
elif [ $IT_CC_COV_DIFF -ge 0 -a $IT_CC_TOTAL_DIFF -eq 0 ]
then
    echo "2#############################################"
    IT_CC_COMPARE_VALUE="NA"
elif [ $IT_CC_COV_DIFF -ge 0 -a $IT_CC_TOTAL_DIFF -lt 0 ]
then
    echo "3#############################################"
    IT_CC_COMPARE_VALUE=$(echo "100.00" | bc -l)
elif [ $IT_CC_COV_DIFF -le 0 -a $IT_CC_TOTAL_DIFF -eq 0 ]
then
    echo "4#############################################"
    IT_CC_COMPARE_VALUE="NA"
elif [ $IT_CC_COV_DIFF -le 0 -a $IT_CC_TOTAL_DIFF -lt 0 ]
then
    echo "4#############################################"
    IT_CC_COMPARE_VALUE=$(echo "0.00" | bc -l)
elif [ $IT_CC_COV_DIFF -le 0 -a $IT_CC_TOTAL_DIFF -ge 0 ]
then
    echo "5#############################################"
    IT_CC_COMPARE_VALUE=$(echo "0.00" | bc -l)
else
    echo "6#############################################"
    #UT_CC_MISSED_DIFF=$(echo "($UT_CURR_MISSED_TOTAL - $UT_PREV_MISSED_TOTAL)" | bc -l)
    IT_CC_COMPARE_VALUE=$(echo "($IT_CC_COV_DIFF * 100 / $IT_CC_TOTAL_DIFF)" | bc -l | awk '{printf "%0.2f", $1}')
    if [[ $(echo "$IT_CC_COMPARE_VALUE > 100" | bc) -eq 1 ]]
    then
        echo "INFO: Delta is more than 100"
        IT_CC_COMPARE_VALUE=$(echo "100.00" | bc -l)
    fi
    echo $IT_CC_COV_DIFF
    echo "*********************************"
    echo $IT_CC_TOTAL_DIFF
fi




## Coverage Comparison Check
#Reduced
IT_CC_COMPARE_RESULT=$(echo "$IT_CURR_CODE_COV < $IT_PREV_CODE_COV" | bc -l)
if [ $IT_CC_COMPARE_RESULT -eq 1 ]
then
    IT_DIFF_MSG="REDUCED"
fi

#Unchanged
IT_CC_COMPARE_RESULT=$(echo "$IT_CURR_CODE_COV == $IT_PREV_CODE_COV" | bc -l)
if [ $IT_CC_COMPARE_RESULT -eq 1 ]
then
    IT_DIFF_MSG="UNCHANGED"
fi

#Increased
IT_CC_COMPARE_RESULT=$(echo "$IT_CURR_CODE_COV > $IT_PREV_CODE_COV" | bc -l)
if [ $IT_CC_COMPARE_RESULT -eq 1 ]
then
    IT_DIFF_MSG="INCREASED"
fi

##### LINE Comparison
#LINE_COMPARE_RESULT=$(echo "$CURR_LINE_DIFF > $PREV_LINE_DIFF" | bc -l)
#Calculate Line Difference
IT_LINE_COMPARE_VALUE=$(echo "($IT_CURR_LINE_DIFF - $IT_PREV_LINE_DIFF)" | bc -l)

## Line Comparison Check
if [ $IT_LINE_COMPARE_VALUE -gt 0 ]
then
    IT_LINE_DIFF_MSG="INCREASED"
elif [ $IT_LINE_COMPARE_VALUE -lt 0 ]
then
    IT_LINE_DIFF_MSG="REDUCED"
else
    IT_LINE_DIFF_MSG="UNCHANGED"
fi

# Make the value absolITe value
#LINE_COMPARE_VALUE_ABS=$(echo $LINE_COMPARE_VALUE | awk '{ print ($1 >= 0) ? $1 : 0 - $1}')
IT_LINE_COMPARE_VALUE_ABS=$(echo $IT_LINE_COMPARE_VALUE | awk '{ if($1>=0) { print $1} else {print $1*-1 }}')

## Print in logs for debugging
echo "INFO: Code Coverage LINE_DIFF_MSG = $IT_LINE_DIFF_MSG"
echo "INFO: Line Coverage Diff = $IT_LINE_COMPARE_VALUE"
echo "INFO: Line Coverage Diff (ABS) = $IT_LINE_COMPARE_VALUE_ABS"

##### NEW Lines Coverage Calculations
#Calculate Total Line diff
IT_TOTAL_LINE_DIFF=$(echo "($IT_CURR_LINE_TOTAL - $IT_PREV_LINE_TOTAL)" | bc -l)
#Calculate Covered Line diff
IT_COV_LINE_DIFF=$(echo "($IT_CURR_LINE_COV - $IT_PREV_LINE_COV)" | bc -l)

## Comparison check
if [ $IT_COV_LINE_DIFF == 0 -a $IT_TOTAL_LINE_DIFF == 0 ]
then
    #No change in total lines & covered lines, set coverage % to empty
    IT_COV_DIFF_MSG="NO LINE DIFF than"
    IT_COVERAGE_PERCENTAGE=""
elif [ $IT_COV_LINE_DIFF -ge 0 -a $IT_TOTAL_LINE_DIFF -eq 0 ]
then
      #UT_COV_DIFF_MSG="NO NEW LINEs than but Covered Line"
      IT_COV_DIFF_MSG="Total LINEs removed than"
      IT_COVERAGE_PERCENTAGE=100
elif [ $IT_COV_LINE_DIFF -ge 0 -a $IT_TOTAL_LINE_DIFF -lt 0 ]
then
      #UT_COV_DIFF_MSG="NO NEW LINEs than but Covered Line"
      IT_COV_DIFF_MSG="Total LINEs removed than"
      IT_COVERAGE_PERCENTAGE=100
elif [ $IT_COV_LINE_DIFF -le 0 -a $IT_TOTAL_LINE_DIFF -le 0 ]
then
       IT_COV_DIFF_MSG="Covered LINEs removed than"
       IT_COVERAGE_PERCENTAGE=0
elif [ $IT_COV_LINE_DIFF -le 0 -a $IT_TOTAL_LINE_DIFF -ge 0 ]
then
       IT_COV_DIFF_MSG="Covered LINEs removed than"
       IT_COVERAGE_PERCENTAGE=0
#
#elif [ $IT_TOTAL_LINE_DIFF == 0 ]
#then
#    #No change in total lines, set coverage % to empty
#    UT_COV_DIFF_MSG="NO NEW LINEs than"
#    IT_COVERAGE_PERCENTAGE=0
#elif [[ $(echo "$IT_TOTAL_LINE_DIFF < 0" | bc) -eq 1 ]]
#then
#    #Total lines reduced, set coverage % to empty
#    UT_COV_DIFF_MSG="Total LINEs removed than"
#    IT_COVERAGE_PERCENTAGE=0
#elif [[ $(echo "$IT_COV_LINE_DIFF < 0" | bc) -eq 1 ]]
#then
#    #Covered lines reduced, set coverage % to empty
#    UT_COV_DIFF_MSG="Covered LINEs removed than"
#    IT_COVERAGE_PERCENTAGE=0
else
    #Calculate the Coverage % for new lines (Change in total lines & covered lines)
    IT_COVERAGE_PERCENTAGE=$(echo "$IT_COV_LINE_DIFF * 100 / $IT_TOTAL_LINE_DIFF" | bc -l | awk '{printf "%0.2f", $1}')
    #If coverage % is more than 100, change it to 100
    if [[ $(echo "$IT_COVERAGE_PERCENTAGE > 100" | bc) -eq 1 ]]
    then
        echo "INFO: COVERAGE_PERCENTAGE is more than 100"
        IT_COVERAGE_PERCENTAGE=100
    fi
fi

#Set Fitnesse Test Coverage Baseline to Previous stable Code coverage value
#IT_COVERAGE_BASELINE=$IT_PREV_CODE_COV

#If % is empty then set it to 'NA'
if [ -z "$IT_COVERAGE_PERCENTAGE" ]; then
    #If % is empty then set it to 'NA'
    echo "INFO: COVERAGE_PERCENTAGE is empty"
    IT_COVERAGE_PERCENTAGE="NA"
    IT_COV_DIFF_MSG="NA"
else
    #If % is not empty then do condition check - above, below, in par
    echo "INFO: COVERAGE_PERCENTAGE is NOT empty"
    #Below Baseline
    IT_CC_BASELINE_COMPARE_RESULT=$(echo "$IT_PREV_CODE_COV > $IT_COVERAGE_BASELINE" | bc -l)
    if [ $IT_CC_BASELINE_COMPARE_RESULT -eq 1 ]
    then
    IT_COVERAGE_BASELINE="$IT_COVERAGE_BASELINE"
    fi

    IT_CC_BASELINE_COMPARE_RESULT=$(echo "$IT_PREV_CODE_COV < $IT_COVERAGE_BASELINE" | bc -l)
    if [ $IT_CC_BASELINE_COMPARE_RESULT -eq 1 ]
    then
    IT_COVERAGE_BASELINE="$IT_PREV_CODE_COV"
    fi

    IT_CC_BASELINE_COMPARE_RESULT=$(echo "$IT_PREV_CODE_COV == $IT_COVERAGE_BASELINE" | bc -l)
    if [ $IT_CC_BASELINE_COMPARE_RESULT -eq 1 ]
    then
    IT_COVERAGE_BASELINE="$IT_PREV_CODE_COV"
    fi


    IT_COV_PER_DIFF=$(echo "$IT_COVERAGE_PERCENTAGE < $IT_COVERAGE_BASELINE" | bc -l)
    if [ $IT_COV_PER_DIFF -eq 1 ]; then
        IT_COV_DIFF_MSG="BELOW"
    fi
    #Above Baseline
    IT_COV_PER_DIFF=$(echo "$IT_COVERAGE_PERCENTAGE > $IT_COVERAGE_BASELINE" | bc -l)
    if [ $IT_COV_PER_DIFF -eq 1 ]; then
        IT_COV_DIFF_MSG="ABOVE"
    fi
    #In Par with Baseline
    IT_COV_PER_DIFF=$(echo "$IT_COVERAGE_PERCENTAGE == $IT_COVERAGE_BASELINE" | bc -l)
    if [ $IT_COV_PER_DIFF -eq 1 ]; then
        IT_COV_DIFF_MSG="IN PAR with"
    fi
fi

#If coverage % is negative number, make it absolITe value
if [ "$IT_COVERAGE_PERCENTAGE" != "NA" ]
then
    if [[ $(echo "$IT_COVERAGE_PERCENTAGE < 0" | bc) -eq 1 ]]
    then
        echo "INFO: IT COVERAGE_PERCENTAGE is -ve : $IT_COVERAGE_PERCENTAGE"
        IT_COVERAGE_PERCENTAGE=$(echo "$IT_COVERAGE_PERCENTAGE" |  awk '{ if($1>=0) { print $1} else {print $1*-1 }}')
    fi
fi

##### Write required info to txt files for email notification
#echo "Code Coverage is $DIFF_MSG , Line with no coverage is $LINE_DIFF_MSG" > $WORKSPACE/CompareResultSubject.txt
## Email Warning
if [[ "$IT_COV_DIFF_MSG" = "BELOW" ]] || [[ "$IT_DIFF_MSG" = "REDUCED" ]]
then
    echo "[WARNING] " > $WORKSPACE/MessageSubject.txt
elif [[ "$IT_COV_DIFF_MSG" = "ABOVE" ]] && [[ "$IT_DIFF_MSG" = "INCREASED" ]]
then
    echo "[WooHoo] " > $WORKSPACE/MessageSubject.txt
elif [[ "$IT_COV_DIFF_MSG" != "ABOVE" ]] && [[ "$IT_DIFF_MSG" = "INCREASED" ]]
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

if [ "$IT_CC_COMPARE_VALUE" != "NA" ]
then
IT_CC_COMPARE_VALUE_2=$(echo $(round $IT_CC_COMPARE_VALUE 2));
else
IT_CC_COMPARE_VALUE_2="NA"
fi
IT_CURR_CODE_COV_2=$(echo $(round $IT_CURR_CODE_COV 2));
## Email Subject based on Fitnesse Test Coverage

if [[ "$IT_DIFF_MSG" = "REDUCED" ]]
then
    SUBJECT_MSG="↓"
elif [[ "$IT_DIFF_MSG" = "INCREASED" ]]
then
    SUBJECT_MSG="↑"
elif [[ "$IT_DIFF_MSG" = "UNCHANGED" ]]
then
    SUBJECT_MSG="="
fi

##Remove Delta if coverage is more than 85 %
echo "$IT_CURR_CODE_COV_2"
 if [[ $(echo "$IT_CURR_CODE_COV_2 > 85" | bc) -eq 1 ]]
    then
        echo "[Failed Tests: $CURR_FITNESSE_FAIL | CC =$IT_CURR_CODE_COV_2%: $IT_DIFF_MSG]" > $WORKSPACE/CompareResultSubject.txt
 else
    if [ "$IT_CC_COMPARE_VALUE_2" != "NA" ]
    then
        echo "[Failed Tests: $CURR_FITNESSE_FAIL | CC = $IT_CURR_CODE_COV_2% : $IT_DIFF_MSG | Delta CC : $IT_CC_COMPARE_VALUE_2%]" > $WORKSPACE/CompareResultSubject.txt
    else
        echo "[Failed Tests: $CURR_FITNESSE_FAIL | CC = $IT_CURR_CODE_COV_2% : $IT_DIFF_MSG | Delta CC : $IT_CC_COMPARE_VALUE_2]" > $WORKSPACE/CompareResultSubject.txt
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

if [[ -e $FITNESSE_XML ]]
then
    BUILD_FAILURE_FLAG=false
else
    echo "There is a Build Failure."
    FAILURE_MSG_1="There is a Build Failure."
    BUILD_FAILURE_FLAG=true
fi


#IT
if [[ $CURR_FITNESSE_FAIL -gt 0 ]]
then
    IT_MSG="FAILED : $CURR_FITNESSE_PASS P, $CURR_FITNESSE_FAIL F, $CURR_FITNESSE_SKIP S"
elif [[ ! -e $FITNESSE_XML ]]
then
    IT_MSG="DIDNOT EXEcutE"
elif [[ $CURR_FITNESSE_FAIL -eq 0 ]] && [[ $CURR_FITNESSE_PASS -eq 0 ]]
then
    IT_MSG="DIDNOT EXEcutE"
elif [[ $CURR_FITNESSE_FAIL -eq 0 ]]
then
    IT_MSG="PASSED : $CURR_FITNESSE_PASS P, $CURR_FITNESSE_FAIL F, $CURR_FITNESSE_SKIP S"
else
    IT_MSG="PANICKED"
fi

#=========================================================================================

##COV BASED ON Fitnesse COV BASELINE VALUE
echo IT_COV_DIFF_MSG=$IT_COV_DIFF_MSG
if [[ $IT_COV_DIFF_MSG == "BELOW" ]]
then
    CC_MSG="Reduced below Baseline of $IT_PREV_CODE_COV%"
elif [[ ! -e $IT_COVERAGE_XML ]]
then
    CC_MSG="DIDNOT EXECUTE"
elif [[ $IT_COV_DIFF_MSG == "IN PAR with" ]] || [[ $IT_COV_DIFF_MSG == "ABOVE" ]]
then
    CC_MSG="Coverage above or on Par with Baseline of $IT_PREV_CODE_COV%"
elif [[ $IT_COV_DIFF_MSG == "NA" ]]
then
    CC_MSG="Fitnesse Test COVERAGE for New Lines : $IT_DIFF_MSG by $IT_CC_COMPARE_VALUE [CC for new lines should not reduce below existing baseline of $IT_PREV_CODE_COV%]"
fi

FAILURE_MSG_1=""
FAILURE_MSG_2=""


echo $FAILURE_MSG_1 > $WORKSPACE/FailureMsg.txt
printf "%s\n" "Job Failed as : " >> $WORKSPACE/FailureMsg.txt
#printf "\t%s\n" "Fitnesse Tests : $IT_MSG" >> $WORKSPACE/FailureMsg.txt
printf "\t%s\n" "Fitnesse Tests : $IT_MSG" >> $WORKSPACE/FailureMsg.txt
printf "\t%s\n" "Code Coverage : $CC_MSG" >> $WORKSPACE/FailureMsg.txt
echo "IT_DIFF_MSG=$IT_DIFF_MSG"
if [[ $CURR_FITNESSE_FAIL -gt 0 ]] || [[ $IT_COV_DIFF_MSG == "BELOW" ]] || [[ $CURR_FITNESSE_FAIL == "" ]]
then
echo "BUILD_STATUS_ON_COVERAGE_N_TEST_FAILED"
BUILD_FAILURE_FLAG=true
SUB1="Reason : "
SUB3="Failure"
    if [[ $CURR_FITNESSE_FAIL -gt 0 ]] || [[ ! -e $IT_COVERAGE_XML ]] || [[ $CURR_FITNESSE_FAIL -eq 0 && $CURR_FITNESSE_PASS -eq 0 ]]
    then
       SUB2="FitnesseTest"
    fi
    if [[ $IT_COV_DIFF_MSG == "BELOW" ]]
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
Fitnesse Test Code Coverage for New Lines $IT_COVERAGE_PERCENTAGE which is $IT_COV_DIFF_MSG the Baseline $IT_PREV_CODE_COV% #

Overall Code Coverage $IT_DIFF_MSG by $IT_CC_OVERALL_DELTA %
    CURRENT Build   : $IT_CURR_CODE_COV  %
    PREVIOUS Build  : $IT_PREV_CODE_COV  %

Uncovered lines $IT_LINE_DIFF_MSG by $IT_LINE_COMPARE_VALUE *

    CURRENT Build       Total Lines=$IT_CURR_LINE_TOTAL         |   Covered Lines=$IT_CURR_LINE_COV |   Uncovered Lines=$IT_CURR_LINE_DIFF
    PREVIOUS Build      Total Lines=$IT_PREV_LINE_TOTAL         |   Covered Lines=$IT_PREV_LINE_COV |   Uncovered Lines=$IT_PREV_LINE_DIFF
    --------------------------------------------------------------------------------------------------------------------
    DIFFERENCE         Total Lines=$IT_TOTAL_LINE_DIFF      |   Covered Lines=$IT_COV_LINE_DIFF     |   Uncovered Lines=$IT_LINE_COMPARE_VALUE


=========================================================================================

Fitnesse Tests

    CURR Build      Total=$CURR_FITNESSE_TOTAL     |   Passed=$CURR_FITNESSE_PASS     |   Failed=$CURR_FITNESSE_FAIL     |   Skipped=$CURR_FITNESSE_SKIP
    PREV Build      Total=$PREV_FITNESSE_TOTAL     |   Passed=$PREV_FITNESSE_PASS     |   Failed=$PREV_FITNESSE_FAIL     |   Skipped=$PREV_FITNESSE_SKIP
=========================================================================================

# Code Coverage for new lines is calculated as Percentage of lines added with respect to change in covered lines. (In certain scenarios, this may not indicate code coverage only for new lines).
*  Uncovered Lines are calculated as Difference of (Total Lines - Covered Lines) for Current and Previous builds.
** Coverage % for additional lines is NA when there is no new lines added

===========================================================

EOF
else
cat << EOF > $WORKSPACE/CompareResultSummary.txt
=========================================================================================

$(cat $WORKSPACE/FailureMsg.txt)

Code Coverage Details:

=========================================================================================
Fitnesse Test Code Coverage for new lines $IT_COVERAGE_PERCENTAGE which is $IT_COV_DIFF_MSG the Baseline $IT_PREV_CODE_COV% #

Code Coverage $IT_DIFF_MSG by $IT_CC_OVERALL_DELTA  %
    CURRENT Build   : $IT_CURR_CODE_COV  %
    PREVIOUS Build  : $IT_PREV_CODE_COV  %

Uncovered lines $IT_LINE_DIFF_MSG by $IT_LINE_COMPARE_VALUE *

    CURRENT Build       Total Lines=$IT_CURR_LINE_TOTAL         |   Covered Lines=$IT_CURR_LINE_COV |   Uncovered Lines=$IT_CURR_LINE_DIFF
    PREVIOUS Build      Total Lines=$IT_PREV_LINE_TOTAL         |   Covered Lines=$IT_PREV_LINE_COV |   Uncovered Lines=$IT_PREV_LINE_DIFF
    --------------------------------------------------------------------------------------------------------------------
    DIFFERENCE         Total Lines=$IT_TOTAL_LINE_DIFF      |   Covered Lines=$IT_COV_LINE_DIFF     |   Uncovered Lines=$IT_LINE_COMPARE_VALUE

=========================================================================================

Fitnesse Tests

    CURR Build      Total=$CURR_FITNESSE_TOTAL     |   Passed=$CURR_FITNESSE_PASS     |   Failed=$CURR_FITNESSE_FAIL     |   Skipped=$CURR_FITNESSE_SKIP
    PREV Build      Total=$PREV_FITNESSE_TOTAL     |   Passed=$PREV_FITNESSE_PASS     |   Failed=$PREV_FITNESSE_FAIL     |   Skipped=$PREV_FITNESSE_SKIP
=========================================================================================


# Code Coverage for new lines is calculated as Percentage of lines added with respect to change in covered lines. (In certain scenarios, this may not indicate code coverage only for new lines).
*  Uncovered Lines are calculated as Difference of (Total Lines - Covered Lines) for Current and Previous builds.
** Coverage % for additional lines is NA when there is no new lines added


=========================================================================================
EOF
fi



##### Write coverage info as key=value in a txt files which will be archived for fITure use
COVERAGE_INFO_FILE="$WORKSPACE/coverage_info.txt"
echo "PARENT_BUILD_NUMBER=$PARENT_BUILD_NUMBER" > $COVERAGE_INFO_FILE
echo "BUILD_NUMBER=$BUILD_NUMBER" >> $COVERAGE_INFO_FILE
echo "SVN_REVISION=$SVN_REVISION" >> $COVERAGE_INFO_FILE
echo "CURR_LINE_TOTAL=$IT_CURR_LINE_TOTAL" >> $COVERAGE_INFO_FILE
echo "PREV_LINE_TOTAL=$IT_PREV_LINE_TOTAL" >> $COVERAGE_INFO_FILE
echo "CURR_LINE_COV=$IT_CURR_LINE_COV" >> $COVERAGE_INFO_FILE
echo "PREV_LINE_COV=$IT_PREV_LINE_COV" >> $COVERAGE_INFO_FILE
echo "CURR_CODE_COV=$IT_CURR_CODE_COV" >> $COVERAGE_INFO_FILE
echo "PREV_CODE_COV=$IT_PREV_CODE_COV" >> $COVERAGE_INFO_FILE

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
echo "CURR_FITNESSE_TOTAL=$CURR_FITNESSE_TOTAL"
echo "CURR_FITNESSE_FAIL=$CURR_FITNESSE_FAIL"
echo "CURR_FITNESSE_SKIP=$CURR_FITNESSE_SKIP"
echo "CURR_FITNESSE_PASS=$CURR_FITNESSE_PASS"
echo "PREV_FITNESSE_TOTAL=$PREV_FITNESSE_TOTAL"
echo "PREV_FITNESSE_FAIL=$PREV_FITNESSE_FAIL"
echo "PREV_FITNESSE_SKIP=$PREV_FITNESSE_SKIP"
echo "PREV_FITNESSE_PASS=$PREV_FITNESSE_PASS"
echo "IT_COV_LINE_DIFF=$IT_COV_LINE_DIFF"
echo "--------------------------"
echo "CURR_IT_PASS=$CURR_IT_PASS"
echo "CURR_IT_FAIL=$CURR_IT_FAIL"
echo "CURR_IT_TOTAL=$CURR_IT_TOTAL"
echo "PREV_IT_PASS=$PREV_IT_PASS"
echo "PREV_IT_FAIL=$PREV_IT_FAIL"
<<<<<<< HEAD
echo "PREV_IT_TOTAL=$PREV_IT_TOTAL"
=======
echo "PREV_IT_TOTAL=$PREV_IT_TOTAL"
>>>>>>> c50df6521dde3a3c7653008d6f18c216246a69de
