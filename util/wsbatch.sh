#!/bin/bash
# ======================================================================
# Example script for submitting a set of single input per file jobs to 
# a Dispatcher based EMBL-EBI web service.
#
# See:
# http://www.ebi.ac.uk/Tools/webservices/
# http://www.ebi.ac.uk/Tools/webservices/help/faq
# http://www.ebi.ac.uk/Tools/webservices/tutorials/01_intro
# http://www.ebi.ac.uk/Tools/webservices/tutorials/07_workflows
# ----------------------------------------------------------------------
# NB: this script illustrates a possible submission workflow for 
# handling the submission of multiple concurrent jobs. In order to use 
# this script it will have to be modified to match your environment and 
# updated to run the required web service client with the required 
# options.
# ======================================================================
### Defaults ###
# User e-mail address. This *must* be a vaild e-mail address.
userEmail="email@example.org"
# Max number of simultaneous jobs.
declare -i MAX=15
# Executable for the web service client.
exec="$HOME/src/ebi/ebiws/1.0-ebiws/perl/soaplite/maxsprout.pl"
#exec="java -Djava.ext.dirs=lib -jar bin/WSMaxsprout.jar"
# Command line options for the client.
# NB: the 'email' and 'async' options are required.
command_line="--email $userEmail --async --quiet";

### Command-line ###
# You need to specify a directory to process
if [ $# -gt 0 ]; then
    todo="$1"
else
    echo "Error: a directory to process must be specified" 1>&2
    exit 1
fi

### Functions ###
function polljob {
    # For each pending/running job...
    for job in `echo $PENDING` ; do
	sleep 2
	# Get the status of the job
	status=`${exec} --quiet --status --jobid $job`
	echo "[INFO] $status for $job"
	# Check the job status...
	case "$status" in
	    # Job finished
	    "DONE")
		# Remove job identifier from tracking list
		PENDING=${PENDING/${job}/};
		# Get array index to look-up file name
		index=`expr match "$job" '.*\([0-9][0-9][0-9][0-9][0-9][0-9][0-9]\)'`
		# Get the job results
		# Note: to name the results for the input file add:
		# --outfile $todo/${results[${index}]}
		ok=`${exec} --quiet --polljob --jobid $job`
		# Allow a new job to run.
		pend=pend-1;
		# Report job complete.
   		echo "[INFO] Get results for $job (" ${results[${index}]} ')'
		;;
	    ERROR|NOT_FOUND)
		echo "[WARN] $status for $job (" ${results[${index}]} ')'
		;;
	esac
    done # for all pending
}

### Run jobs ###
# Initialise tracking varibles.
declare -i pend=0      # Number of pending/running jobs.
# Remember where we are...
home=`pwd`
# Get list of files to process.
cd $todo
files=`ls`
# Move back to working directory.
cd $home

# For each file to process...
for seq in $files; do
    # Submit the job for the file.
    jobid=`${exec} ${command_line} ${todo}/${seq}`
    echo "[INFO] $jobid for $seq"
    # Record the job identifier.
    PENDING="${PENDING} ${jobid}"
    # Record the input file for the job.
    index=`expr match "$jobid" '.*\([0-9][0-9][0-9][0-9][0-9][0-9][0-9]\)'`
    results[$index]=$seq
    # Update the pending/running job counter.
    pend=pend+1
    # While at the maximum number of concurrent jobs...
    while [ $pend -gt $MAX ]; do
	# Wait before polling
	sleep 2
	polljob
    done # while pending
done # for all files

# Submitted all files, so now handle remaining pending/running jobs.
while [ $pend -gt 0 ]; do
    sleep 2
    polljob
done # while pending
