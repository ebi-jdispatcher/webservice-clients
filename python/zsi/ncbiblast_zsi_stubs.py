#!/usr/bin/env python
# ======================================================================
# jDispatcher NCBI BLAST Python client.
#
# Tested with: Python 2.5.2 with ZSI 2.0
#
# See:
#
# http://www.ebi.ac.uk/Tools/webservices/tutorials/python
# ======================================================================
# Note: requires subs generated with:
#  wsdl2py -u http://wwwdev.ebi.ac.uk/Tools/jdispatcher/services/soap/ncbiblast?wsdl
# ======================================================================
# Load libraries
import os
import sys
import time
from optparse import OptionParser
# Load stubs
from JDispatcherService_services import *

# Usage message
usage = "%prog [options...] [seqFile]"

# Process command-line options
parser = OptionParser(usage=usage)
parser.add_option('-p', '--program', help='Search program: blastp, blastn, blastx, etc.')
parser.add_option('-D', '--database', help='Database to search')
parser.add_option('-m', '--matrix', help='Scoring martix to use')
parser.add_option('-E', '--exp', help='E-value threshold')
parser.add_option('-f', '--filter', action="store_true", help='Low complexity filter')
parser.add_option('-A', '--align', type='int', help='Number of alignments')
parser.add_option('-s', '--scores', type='int', help='Number of scores')
parser.add_option('-n', '--numal', type='int', help='Number of alignments')
parser.add_option('-d', '--dropoff', type='int', help='Dropoff score')
parser.add_option('-u', '--match', type='int', help='Match score')
parser.add_option('-v', '--mismatch', type='int', help='Mismatch score')
parser.add_option('-o', '--opengap', type='int', help='Open gap penalty')
parser.add_option('-x', '--extendgap', type='int', help='Gap extension penality')
parser.add_option('-g', '--gapalign', action="store_true", help='Optimise gap alignments')
parser.add_option('--sequence', help='Input sequence file name')
parser.add_option('--getParameters', help='Get parameter list')
parser.add_option('-a', '--async', action="store_true", help='Async submission')
parser.add_option('--email', help='E-mail address')
parser.add_option('--title', help='Job title')
parser.add_option('-O', '--outfile', help='File name for results')
parser.add_option('--outformat', help='Output format')
parser.add_option('--polljob', action="store_true", help='Get job result')
parser.add_option('--status', action="store_true", help='Get job status')
parser.add_option('-j', '--jobid', help='Job Id')
parser.add_option('--trace', action="store_true", help='Show SOAP messages')
(options, args) = parser.parse_args()

# Create the service interface (enabling trace if necessary)
if options.trace:
  srvProxy = JDispatcherServiceLocator().getJDispatcherService(tracefile=sys.stdout)
else:
  srvProxy = JDispatcherServiceLocator().getJDispatcherService()

# Client-side job poll
def clientPoll(jobId):
  statusStr = 'PENDING'
  while statusStr == 'RUNNING' or statusStr == 'PENDING':
    statusStr = getStatus(jobId)
    print >>sys.stderr, statusStr
    if statusStr == 'RUNNING' or statusStr == 'PENDING':
      time.sleep(15)

# Get status for a jobid
def getStatus(jobid):
    req = getStatusRequest()
    req._jobId = jobid
    msg = srvProxy.getStatus(req)
    return msg._status

# Get list of available result types
def getResultTypes(jobId):
    # Get available result types
    req = getResultTypesRequest()
    req._jobId = jobId
    msg = srvProxy.getResultTypes(req)
    return msg._result

# Get result of a specified type
def getResultOutput(jobId, typeName):
    req = getRawResultOutputRequest()
    req._jobId = jobId
    req._type = typeName
    msg = srvProxy.getRawResultOutput(req)
    return msg._result

# Get results for a jobid
def getResults(jobId):
    resultTypes = getResultTypes(jobId)
    for resultType in resultTypes:
        # Get the result
        result = getResultOutput(jobId, resultType)
        # Derive the filename for the result
        if options.outfile:
            filename = options.outfile + '.' + resultType._ext
        else:
            filename = jobId + '.' + resultType._ext
        # Write a result file
        if not options.outformat or options.outformat == resultType.type:
            fh = open(filename, 'w');
            fh.write(result)
            fh.close()
            print filename

# Read a file
def readFile(filename):
    fh = open(filename, 'r')
    data = fh.read()
    fh.close()
    return data

if options.getParameters:
    srvProxy.getParameters()
# Get results
elif options.polljob and options.jobid:
    getResult(options.jobid)
# Get status
elif options.status and options.jobid:
    print getStatus(options.jobid)
# Submit job
elif options.email and not options.jobid:
    # Input data
    if len(args) > 0:
        if os.access(args[0], os.R_OK): # Read file into content
            seqData = readFile(args[0])
        else: # Argument is a sequence id
            seqData = args[0]
    elif options.sequence: # Specified via option
        if os.access(options.sequence, os.R_OK): # Read file into content
            seqData = readFile(options.sequence)
        else: # Argument is a sequence id
            seqData = options.sequence
    params = {
        'program':options.program,
        'matrix':options.matrix,
        'numal':options.numal,
        'scores':options.scores,
        'exp':options.exp,
        'dropoff':options.dropoff,
        #'match_scores':options.match,
        'opengap':options.opengap,
        'extendgap':options.extendgap,
        'filter':options.filter,
        #'seqrange':options.seqrange,
        'align':options.align,
        'sequence':seqData,
        'database':options.database
    }
    # Booleans need to be represented as 1/0 rather than True/False
    #if options.gapalign:
    #    params['gapalign'] = 1
    #if options.format:
    #    params['format'] = 1
    # Submit the job
    runParams = {
                  'email':options.email,
                  'title':options.title,
                  'parameters':params
                  }
    jobidDict = srvProxy.run(email=options.email, parameters=params)
    jobid = jobidDict['jobid']
    if options.async: # Async mode
        print jobid
    #else: # Sync mode
    #    time.sleep(1)
    #    getResult(jobid)
else:
    print 'Error: unrecognised argument combination'
    parser.print_help()
