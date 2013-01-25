#!/bin/bash
# ======================================================================
# 
# Copyright 2012-2013 EMBL - European Bioinformatics Institute
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# 
# ======================================================================
# Example script for submitting a set of single input per file jobs to 
# a JDispatcher based EMBL-EBI web service.
#
# See:
# http://www.ebi.ac.uk/Tools/webservices/
# http://www.ebi.ac.uk/Tools/webservices/help/faq
# ----------------------------------------------------------------------
# NB: this script illustrates a possible submission workflow for 
# handling the submission of multiple concurrent jobs. In order to use 
# this script it will have to be modified to match your environment and 
# updated to run the required web service client  with the required 
# options.
# ======================================================================
### Defaults ###
# User e-mail address. This *must* be a vaild e-mail address.
userEmail="email@example.org"
# Maximum number of concurrent jobs.
MAX_JOBS=15
# Web service client command.
wsClientCmd="$HOME/ncbiblast_soaplite.pl"
# Web service client options.
wsClientSubmitOpts="--email $userEmail --program blastp --database pdb --stype protein"

### Command-line ###
if [ $# -gt 0 ]; then
    inputFileDir=$1
else
    echo "Error: specifiy directory containing files to process" 1>&2
    exit 1
fi

### Functions ###

# Poll job status and get results if completed.
function polljob {
    for tmpJobNum in $runningJobs; do
	tmpJobId=${jobIdArray[$tmpJobNum]}
	jobStatusCmd="$wsClientCmd --status --jobid $tmpJobId --quiet"
	jobStatus=`$jobStatusCmd`
	echo "[INFO] $jobStatus for $tmpJobId"
	case "$jobStatus" in
	    FINISHED|FAILURE)
		# Get results...
		tmpFileName=${inFileArray[$tmpJobNum]}
		# To use named files add: --outfile $tmpFileName
		$wsClientCmd --polljob --jobid $tmpJobId
		# Remove the job from the tracking array.
		runningJobs=`echo "$runningJobs" | sed "s/ ${tmpJobNum} //"`
		# Allow an new job to be submitted.
		runningJobCount=`expr $runningJobCount - 1`
		echo "[INFO] Done $tmpJobId for $tmpFileName."
		;;
	    ERROR|NOT_FOUND)
		echo "[INFO] $jobStatus for $tmpJobId for $tmpFileName."
		;;
	esac
	# Wait between polls.
	sleep 2
    done
}

### Run Jobs ###
# Initialise tracking variables.
jobNum=0
runningJobCount=0
runningJobs=''
# For each file in the directory.
cd $inputFileDir
for inputFile in `ls -1U`; do
    # Submit the job.
    jobCmd="$wsClientCmd $wsClientSubmitOpts --async --quiet $inputFile"
    jobId=`$jobCmd`
    # Check for job identifier being returned.
    if [ -z "$jobId" ]; then
	echo "[ERROR] failed to submit job for $inputFile"
    else
	# Update tracking variables.
	jobNum=`expr $jobNum + 1`
	runningJobCount=`expr $runningJobCount + 1`
	runningJobs="${runningJobs} ${jobNum} "
	inFileArray[$jobNum]=$inputFile
	jobIdArray[$jobNum]=$jobId
    fi
    # Delay between submissions.
    sleep 2
    # If maximum concurrent job limit has been reached...
    while [ $runningJobCount -ge $MAX_JOBS ]; do
	# Poll the status of each job.
	polljob
    done
done

# Get results for any remaining running jobs.
while [ $runningJobCount -gt 0 ]; do
    # Poll the status of each job.
    polljob
done
