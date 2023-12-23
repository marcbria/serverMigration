#!/bin/bash

# Check if a journal list file is provided as an argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 <journal_list_file>"
    exit 1
fi

journalListFile=$1

# Check if the file exists
if [ ! -f "$journalListFile" ]; then
    echo "The file $journalListFile does not exist."
    exit 1
fi

# Size limits in MB
minSize=10
maxSize=500

# Function to get the size of a directory in MB
getDirectorySize() {
    local dir="$1"
    # Check if the directory exists before getting its size
    if [ -d "$dir" ]; then
        sudo du -sm "$dir" | cut -f1
    else
        echo "0"
    fi
}

# Function to print an output line with color based on size
printOutputLine() {
    local journal="$1"
    local size="$2"

    if [ "$size" -le "$minSize" ]; then
        color=$(tput setaf 1)  # Red
    elif [ "$size" -le "$maxSize" ]; then
        color=$(tput setaf 3)  # Yellow
    else
        color=$(tput setaf 1)  # Red
    fi

    printf "%-20s | %s %s MB%s\n" "$journal" "$color" "$size" "$(tput sgr0)"
}

# Header of the output
printf "%-20s | %s\n" "Journal" "Size"

# Calculate and display the space occupied for each journal
while IFS= read -r journal; do
    volumeSize=$(getDirectorySize "/srv/volumes/${journal}")
    backupSize=$(getDirectorySize "/srv/backups/${journal}")
    totalSize=$((volumeSize + backupSize))
    printOutputLine "$journal" "$totalSize"
done < "$journalListFile"

