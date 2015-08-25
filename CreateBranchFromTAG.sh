#!/bin/bash
# set -x
<< DOCUMENT
 createBRfromTAG.sh [Source:TAG_name] [Target :Branch_name ]
 This script will take the input of the source TAG_name and will use it to
 create the branch
 FileList.txt  (This file must have all the git repo names ONLY)
DOCUMENT

function script_usage
{
    echo "INFO: Usage   : $0  [Source:TAG_name] [Target :Branch_name ]"
    echo "INFO: Example : $0 G3TEST_TAG g3test_rcbr "
    echo "INFO: Example : $0 G3_RCTAG G3_RCBR  "
}

SRC_TAG=''
TRG_BR=''
RC_TAG_CREATE='false'
CWD=''

USER=khaazher
GERRIT_URL=ssh://$USER@review.gerrit.net:29418

if [ $# -lt 1 ]
then
    script_usage
    exit 56
else
    SRC_TAG=$1
    TRG_BR=$2
        RC_TAG_CREATE='true'
    CWD=`pwd`
fi

if [ ! -f FileList.txt ]
then
    echo "ERROR: The Git repo list file is missing"
    echo "ERROR: Please ensure to have the FileList.txt file at the $PWD location"
    exit 26
fi
dos2unix FileList.txt

rm -f BranchNOTCreated.log BranchCreated.log

cat FileList.txt | while read dirname
do
    echo "=================================================================================================="
    echo "INFO: Checkout the ${dirname} git repo from master "
    echo "INFO: git clone ${GERRIT_URL}/${dirname}.git "
    git clone ${GERRIT_URL}/${dirname}.git
    RETVAL=$?
    if [ $RETVAL = 0 ]
    then
        cd ${dirname}
        echo "INFO: You are currently in `pwd` "
        echo "INFO: Performing git pull --ff-only "
        git pull --ff-only
        if [ "${RC_TAG_CREATE}" = "true" ]
        then
            echo "INFO: Verifying if ${SRC_TAG} Tag already exists "

            if [ `git tag -l | grep -c ${SRC_TAG} ` -eq 0 ]
            then
                echo "WARNING: ${SRC_TAG} Tag DOES NOT Exist in ${dirname^^} repo hence will not create the ${TRG_BR} branch"  2>&1 | tee -a  ../BranchNOTCreated.log
            else
                echo "INFO: ${RC_TG} Tag Exists in ${dirname} hence will proceed to verify ${TRG_BR} branch"  2>&1 | tee -a  ../BranchCreated.log

                                        if [ ` git branch -a | grep -c ${TRG_BR} ` -eq 0 ]
                                                then
                                                                echo "INFO: The ${TRG_BR} Branch is not present in ${dirname^^} repo proceeding to create it now... " 2>&1 | tee -a  ../BranchCreated.log
                                                                git checkout -b ${TRG_BR} ${SRC_TAG}
                                                                git push -u origin ${TRG_BR}
                                                                echo "INFO: Created the ${TRG_BR} Branch in ${dirname^^} repo " 2>&1 | tee -a  ../BranchCreated.log
                                                else
                                                                echo "WARNING: ${TRG_BR} already exists in ${dirname^^} hence will not create the Branch" 2>&1 | tee -a  ../BranchNOTCreated.log
                                                fi

            fi
        else
            echo "INFO: Skipping ${TRG_BR} branch creation phase "
        fi
        echo "INFO: Moving to the parent directory $CWD "
        cd $CWD
        echo "=================================================================================================="
    else
        echo " ERROR: Failed to Checkout the ${dirname^^} git repo "  2>&1 | tee -a  ../BranchesNOTCreated.log
        echo " ERROR: Verify the ${dirname^^} git repo "
        echo "=================================================================================================="
    fi
done

## EOF ##
