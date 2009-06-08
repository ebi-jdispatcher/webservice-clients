#!/usr/bin/env python
# ======================================================================
# jDispatcher NCBI BLAST Python client.
#
# Tested with:
#   Python 2.5.2 with ZSI 2.0
#
# See:
#
# http://www.ebi.ac.uk/Tools/webservices/tutorials/python
# ======================================================================
# Note: requires subs generated with:
#  wsdl2py -u http://wwwdev.ebi.ac.uk/Tools/services/soap/ncbiblast?wsdl
# ======================================================================
# Load libraries
import os
import sys
import time
from optparse import OptionParser
# Load stubs
from ncbiblast_services import *

# Usage message
usage = "%prog [options...] [seqFile]"

# Process command-line options
parser = OptionParser(usage=usage)
# General options
parser.add_option('--params', action="store_true", help='Get parameter list')
parser.add_option('--paramDetail', help='Get parameter details')
parser.add_option('--async', action='store_true', help='Asynchronous mode')
parser.add_option('--email', help='E-mail address')
parser.add_option('--title', help='Job title')
parser.add_option('--jobid', help='Job identifier')
parser.add_option('--status', action="store_true", help='Get job status')
parser.add_option('--resultTypes', action="store_true", help='Get result types')
parser.add_option('--polljob', action="store_true", help='Get job result')
parser.add_option('--outfile', help='File name for results')
parser.add_option('--outformat', help='Output format for results')
parser.add_option('--trace', action="store_true", help='Show SOAP messages')
# Tool specific options
parser.add_option('-p', '--program', help='Program to run')
parser.add_option('-D', '--database', help='Database to search')
parser.add_option('--stype', default='protein', help='Database to search')
parser.add_option('-m', '--matrix', help='Scoring matrix')
parser.add_option('-E', '--exp', type='float', help='E-value threshold')
parser.add_option('-f', '--filter', action="store_true", help='Low complexity sequence filter')
parser.add_option('-n', '--numal', type='int', help='Maximum number of alignments')
parser.add_option('-s', '--scores', type='int', help='Maximum number of scores')
parser.add_option('-d', '--dropoff', type='int', help='Dropoff score')
parser.add_option('--match_score', help='Match/missmatch score')
parser.add_option('-o', '--opengap', type='int', help='Open gap penalty')
parser.add_option('-x', '--extendgap', type='int', help='Extend gap penalty')
parser.add_option('-g', '--gapalign', action="store_true", help='Optimise gap alignments')
parser.add_option('--sequence', help='Input sequence file name')

(options, args) = parser.parse_args()

# Create the service interface (enabling trace if necessary)
if options.trace:
  srvProxy = JDispatcherServiceLocator().getJDispatcherService(tracefile=sys.stdout)
else:
  srvProxy = JDispatcherServiceLocator().getJDispatcherService()

# Get list of parameters
def getParameters():
    req = getParametersRequest()
    msg = srvProxy.getParameters(req)
    return msg._parameters._id

def printParameters():
    params = getParameters()
    for param in params:
        print param

# Get information about a parameter
def getParameterDetails(paramName):
    req = getParameterDetailsRequest()
    req._parameterId = paramName
    msg = srvProxy.getParameterDetails(req)
    return msg._parameterDetails

# Print parameter information
def printParameterDetails(paramName):
    paramDetails = getParameterDetails(paramName)
    print paramDetails._name + "\t" + paramDetails._type
    print paramDetails._description
    for value in paramDetails._values._value:
        if value._defaultValue:
            print value._value + "\tdefault"
        else:
            print value._value
        print "\t" + value._label

# Client-side job poll
def clientPoll(jobId):
  statusStr = 'PENDING'
  while statusStr == 'RUNNING' or statusStr == 'PENDING':
    statusStr = getStatus(jobId)
    print >>sys.stderr, statusStr
    if statusStr == 'RUNNING' or statusStr == 'PENDING':
      time.sleep(15)

# Submit a job
def run(email, title, params):
    req = runRequest()
    req._email = email
    req._title = title
    InputParameters = ns0.InputParameters_Def(None).pyclass
    req._parameters = InputParameters()
    if params.has_key('program'):
        req._parameters._program = params['program']
    if params.has_key('database'):
        ArrayOfString = ns0.ArrayOfString_Def(None).pyclass
        req._parameters._database = ArrayOfString()
        req._parameters._database._string = [params['database']]
    if params.has_key('stype'):
        req._parameters._stype = params['stype']
    if params.has_key('matrix'):
        req._parameters._matrix = params['matrix']
    if params.has_key('exp'):
        req._parameters._exp = params['exp']
    else:
        req._parameters._exp = "10"
    if params.has_key('filter'):
        req._parameters._filter = params['filter']
    if params.has_key('alignments'):
        req._parameters._alignments = params['alignments']
    else:
        req._parameters._alignments = 50
    if params.has_key('scores'):
        req._parameters._scores = params['scores']
    else:
        req._parameters._scores = 50
    if params.has_key('dropoff'):
        req._parameters._dropoff = params['dropoff']
    if params.has_key('match_score'):
        req._parameters._match_score = params['match_score']
    if params.has_key('gapopen'):
        req._parameters._gapopen = params['gapopen']
    if params.has_key('gapext'):
        req._parameters._gapext = params['gapext']
    if params.has_key('gapalign'):
        req._parameters._gapalign = params['gapalign']
    if params.has_key('sequence'):
        req._parameters._sequence = params['sequence']
    print req._parameters
    msg = srvProxy.run(req)
    return msg._jobId

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
    return msg._resultTypes._type

# Print result type for a job
def printResultTypes(jobId):
    resultTypes = getResultTypes(jobId)
    for resultType in resultTypes:
        print resultType._identifier

# Get result of a specified type
def getResult(jobId, typeName):
    req = getResultRequest()
    req._jobId = jobId
    req._type = typeName
    msg = srvProxy.getResult(req)
    return msg._output

# Get results for a jobid
def getResults(jobId):
    clientPoll(jobId)
    resultTypes = getResultTypes(jobId)
    for resultType in resultTypes:
        # Get the result
        result = getResult(jobId, resultType._identifier)
        # Derive the filename for the result
        if options.outfile:
            filename = options.outfile + '.' + resultType._identifier + '.' + resultType._fileSuffix
        else:
            filename = jobId + '.' + resultType._identifier + '.' + resultType._fileSuffix
        # Write a result file
        if not options.outformat or options.outformat == resultType:
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

if options.params:
    printParameters()
elif options.paramDetail:
    printParameterDetails(options.paramDetail)
# Get status
elif options.status and options.jobid:
    print getStatus(options.jobid)
# Get result types
elif options.resultTypes and options.jobid:
    printResultTypes(options.jobid)
# Get results
elif options.polljob and options.jobid:
    getResults(options.jobid)
# Submit job
elif options.email and not options.jobid:
    params = {}
    if len(args) > 0:
        if os.access(args[0], os.R_OK): # Read file into content
            params['sequence'] = readFile(args[0])
        else: # Argument is a sequence id
            params['sequence'] = args[0]
    elif options.sequence: # Specified via option
        if os.access(options.sequence, os.R_OK): # Read file into content
            params['sequence'] = readFile(options.sequence)
        else: # Argument is a sequence id
            params['sequence'] = options.sequence
    # Booleans need to be represented as 1/0 rather than True/False
    if options.gapalign:
        params['gapalign'] = 1
    else:
        params['gapalign'] = 0
    # Add the other options (if defined)
    if options.program:
        params['program'] = options.program
    if options.database:
        params['database'] = options.database
    if options.stype:
        params['stype'] = options.stype
    if options.matrix:
        params['matrix'] = options.matrix
    if options.exp:
        params['exp'] = options.exp
    if options.filter:
        params['filter'] = options.filter
    if options.numal:
        params['alignments'] = options.numal
    if options.scores:
        params['scores'] = options.scores
    if options.dropoff:
        params['dropoff'] = options.dropoff
    if options.match_score:
        params['match_score'] = options.match_score
    if options.opengap:
        params['gapopen'] = options.opengap
    if options.extendgap:
        params['gapext'] = options.extendgap
    # Submit the job
    jobid = run(options.email, options.title, params)
    if options.async: # Async mode
        print jobid
    else: # Sync mode
        time.sleep(1)
        getResults(jobid)
else:
    print 'Error: unrecognised argument combination'
    parser.print_help()
