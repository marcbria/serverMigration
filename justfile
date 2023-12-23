# Justfile

# Default target to show available targets
default:
	@echo "Available targets:"
	@just -l

# Target to run the analyze.sh script
analyze:
	sudo ./analyze.sh ${JOURNAL_LIST:-journals.lst}

# Target to run the getAllVols.sh script
getAllVols:
	sudo ./getAllVols.sh ${JOURNAL_LIST:-journals.lst}

# Target to run the getRemoteVols.sh script
getRemoteVols:
	sudo ./getRemoteVols.sh ${JOURNAL_NAME:-demo}
