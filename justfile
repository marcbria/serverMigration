# Justfile

# Default target to show available targets
default:
	@echo "Available targets:"
	@just -l

# Calculates and display the space occupied for each journal
analyze:
	sudo ./analyze.sh ${JOURNAL_LIST:-journals.lst}

# Gets all the journals listed in the fileParam from the remote server
getAllVols:
	sudo ./getAllVols.sh ${JOURNAL_LIST:-journals.lst}

# Gets the volumes of the specified journal from the remote server
getRemoteVols journal:
	sudo ./getRemoteVol.sh {{journal}} #${JOURNAL_NAME:-demo}
