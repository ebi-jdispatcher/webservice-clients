#!/usr/bin/env python
# $Id$
# ======================================================================
# NCBI BLAST jDispatcher Python client.
#
# Tested with: Python 2.5.1 with SOAPpy 0.11.3
#
# See:
# http://www.ebi.ac.uk/Tools/webservices/tutorials/python
# ======================================================================
# WSDL URL for service
wsdlUrl = 'http://wwwdev.ebi.ac.uk/Tools/jdispatcher/services/soap/ncbiblast?wsdl'

# Load libraries
import os
import sys
import base64
import time
from SOAPpy import WSDL
from optparse import OptionParser

# Usage message
usage = "Usage: %prog [options...] [seqFile]"
# Process command-line options
parser = OptionParser(usage=usage)
# General options
parser.add_option('--email', help='E-mail address')
parser.add_option('--title', help='Job title')
parser.add_option('--outfile', help='File name for results')
parser.add_option('--outformat', help='Output format for results')
parser.add_option('--polljob', action="store_true", help='Get job result')
parser.add_option('--status', action="store_true", help='Get job status')
parser.add_option('--jobid', help='Job identifier')
parser.add_option('--async', action='store_true', help='Asynchronous mode')
parser.add_option('--trace', action="store_true", help='Show SOAP messages')
# Tool specific options
parser.add_option('-p', '--program', help='Program to run')
parser.add_option('-D', '--database', help='Database to search')
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

# Create the service interface
server = WSDL.Proxy(wsdlUrl)

# If required enable SOAP message trace
if options.trace:
    server.soapproxy.config.dumpSOAPOut = 1
    server.soapproxy.config.dumpSOAPIn = 1

# Get job status
def serviceCheckStatus(jobId):
    result = server.getStatus(jobId = jobId)
    return result

# Submit job
def serviceRun(email, title, params):
    jobid = server.run(email=email, title=title, parameters=params)
    return jobid

# Get available result types for job
def serviceGetResultTypes(jobId):
    result = server.getResultTypes(jobId=jobId)
    return result['type']

# Get result
def serviceGetResult(jobId, type):
    result = server.getRawResultOutput(jobId=jobId, type=type)
    return base64.decodestring(result)

# Get input parameters list
def serviceGetParameters():
    result = server.getParameters(tool='ncbiblast')
    return result

# Get input parameter information
def serviceGetParameterDetails(paramName):
    result= server.getParameterDetails(tool='ncbiblast', parameter=paramName)
    return result

# Client-side poll
def clientPoll(jobId):
    result = 'PENDING'
    while result == 'RUNNING' or result == 'PENDING':
        result = serviceCheckStatus(jobId)
        print >>sys.stderr, result
        if result == 'RUNNING' or result == 'PENDING':
            time.sleep(15)

# Get result for a jobid
def getResult(jobId):
    # Check status and wait if necessary
    clientPoll(jobId)
    # Get available result types
    resultTypes = serviceGetResultTypes(jobId)
    for resultType in resultTypes:
        # Get the result
        result = serviceGetResult(jobId, resultType)
        # Derive the filename for the result
        if options.outfile:
            filename = options.outfile + '.' + resultType
        else:
            filename = jobId + '.' + resultType
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

# Get results
if options.polljob and options.jobid:
    getResult(options.jobid)
# Get status
elif options.status and options.jobid:
    status = serviceCheckStatus(options.jobid)
    print status
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
    if options.matrix:
        params['matrix'] = options.matrix
    if options.exp:
        params['exp'] = options.exp
    if options.filter:
        params['filter'] = options.filter
    if options.numal:
        params['numal'] = options.numal
    if options.scores:
        params['scores'] = options.scores
    if options.dropoff:
        params['dropoff'] = options.dropoff
    if options.match_score:
        params['match_score'] = options.match_score
    if options.opengap:
        params['opengap'] = options.opengap
    if options.extendgap:
        params['extendgap'] = options.extendgap
    
    # Submit the job
    jobid = serviceRun(options.email, options.title, params)
    if options.async: # Async mode
        print jobid
    else: # Sync mode
        time.sleep(5)
        getResult(jobid)
else:
    print 'Error: unrecognised argument combination'
    parser.print_help()
