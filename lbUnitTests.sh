#!/bin/bash 

# +------------------------------------+
# | lbUnitTests.sh                     |
# | --------------                     |
# | Test script for LoadBalancer rules |
# +------------------------------------+

# Parameters
# ----------
# $0 :: script name

# Configuration
SCRIPT_NAME=$0
TEST_LIST="lbUnitTests.list"

RED="\e[1;31m%s\e[00m\n"
GREEN="\e[1;32m%s\e[00m\n"
YELLOW="\e[0;33m%s\e[00m\n"
WHITE="\e[1;38m%s\e[00m\n"

# Functions
alias trimString='sed -e "s/^ *//" -e "s/* $//"'
alias removeQuotes='sed -e "s/\"//g"'
function _validateParams() {
        if [ $# -ne 0 ]; then
                echo "Usage: $SCRIPT_NAME" 
                exit 1
        fi
}
shopt -s expand_aliases

# Init
_validateParams $*

echo ""
while IFS=$'\n' read i; do

	# avoid blank or commented lines
	if [ "$i" == "" ] || [[ ${i:0:1} == "#" ]]; then continue; fi;

	NAME=$(     echo $i | cut -d ',' -f 1 | trimString | removeQuotes)
	URL=$(      echo $i | cut -d ',' -f 2 | trimString)
	HTTP_CODE=$(echo $i | cut -d ',' -f 3 | trimString | removeQuotes)
	PATTERN=$(  echo $i | cut -d ',' -f 4 | removeQuotes)
	COOKIES=$(  echo $i | cut -d ',' -f 5 | trimString | removeQuotes)
	GREP=""

	OLD_IFS=$IFS
	IFS=$'\n'
	for j in $(echo $PATTERN | tr "|" "\n" | trimString); do
		GREP="$GREP | grep '$j'"
	done
	IFS=$OLD_IFS

        printf "Test: $WHITE" "$NAME"
        printf "URL: $YELLOW" $URL
        echo "Expected HTTP Status Code: $HTTP_CODE"
	echo "Expected 'grep' pattern: $PATTERN" 

	CMD="curl -I $URL 2>/dev/null | tr \"\n\r\" \" \" | grep $HTTP_CODE $GREP"
	eval $CMD > /dev/null
	RESULT=$?

	if [ $RESULT -ne 0 ]; then
                printf "Result: $RED" "FAIL!"
                echo "Try it yourself!"
		printf "$YELLOW" "curl -I $URL 2>/dev/null | tr \"\n\r\" \" \" | grep $HTTP_CODE $GREP; echo \$?"
	else
		printf "Result: $GREEN" "SUCCESS!"
        fi
        echo "";

done < $TEST_LIST

