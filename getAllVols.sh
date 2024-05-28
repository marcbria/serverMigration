#!/bin/bash

# Check if a list of journals is provided as an argument
if [ $# -eq 0 ]; then
    echo "Gets all the journals listed in the fileParam from the remote server"
    echo "Usage: $0 <listOfJournals>"
    exit 1
fi

listOfJournals=$1

# Check if the file exists
if [ ! -f "$listOfJournals" ]; then
    echo "The file $listOfJournals does not exist."
    exit 1
fi

# Record the start time
startTime=$(date +%s)

# Read the file line by line and execute the command
while IFS= read -r line || [ -n "$line" ]; do
    ./getRemoteVol.sh "$line"
done < "$listOfJournals"

echo "=============================="
echo "==     Process completed    =="
echo "=============================="

# Record the end time
endTime=$(date +%s)

# Calculate the execution time
executionTime=$((endTime - startTime))
minutes=$((executionTime / 60))
hours=$((minutes / 60))

echo -e "\nExecution time:"
echo    "   - Seconds: ${executionTime}"
echo    "   - Minutes: ${minutes}"
echo    "   - Hours: ${hours}"
