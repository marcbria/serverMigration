#!/bin/bash

# Check if a list of journals is provided as an argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 <list_of_journals>"
    exit 1
fi

listOfJournals=$1

# Check if the file exists
if [ ! -f "$listOfJournals" ]; then
    echo "The file $listOfJournals does not exist."
    exit 1
fi

# Read the file line by line and execute the command
while IFS= read -r line || [ -n "$line" ]; do
    unlink /srv/backups/$line/$line
    unlink /srv/volumes/logs/$line/$line
    unlink /srv/volumes/db/$line/$line
done < "$listOfJournals"

echo "=============================="
echo "==     Process completed    =="
echo "=============================="
