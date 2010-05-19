#!/usr/bin/env python
# $Id$
# ======================================================================
# NCBI BLAST SOAP service, Python client using SUDS.
#
# Tested with:
#   Python 2.6.5 with SUDS 0.3.9 (Ubuntu 10.04 LTS)
#
# See:
# http://www.ebi.ac.uk/Tools/webservices/services/sss/ncbi_blast_soap
# http://www.ebi.ac.uk/Tools/webservices/tutorials/python
# ======================================================================
# WSDL URL for service
wsdlUrl = 'http://www.ebi.ac.uk/Tools/services/soap/ncbiblast?wsdl'

# Load libraries
import os
import sys
import base64
import time
import warnings
import logging
from suds import WebFault
from suds.client import Client
from optparse import OptionParser

# Setup logging
logging.basicConfig(level=logging.INFO)

# Set interval for checking status
checkInterval = 3
# Output level
outputLevel = 1
# Debug level
debugLevel = 0

# Usage message
usage = "Usage: %prog [options...] [seqFile]"
# Process command-line options
parser = OptionParser(usage=usage)
# Tool specific options
parser.add_option('-p', '--program', help='program to run')
parser.add_option('-D', '--database', help='database to search')
parser.add_option('--stype', default='protein', help='query sequence type')
parser.add_option('-m', '--matrix', help='scoring matrix')
parser.add_option('-E', '--exp', type='float', help='E-value threshold')
parser.add_option('-f', '--filter', action="store_true", help='low complexity sequence filter')
parser.add_option('-n', '--alignments', type='int', help='maximum number of alignments')
parser.add_option('-s', '--scores', type='int', help='maximum number of scores')
parser.add_option('-d', '--dropoff', type='int', help='dropoff score')
parser.add_option('--match_score', help='match/missmatch score')
parser.add_option('-o', '--gapopen', type='int', help='open gap penalty')
parser.add_option('-x', '--gapext', type='int', help='extend gap penalty')
parser.add_option('-g', '--gapalign', action="store_true", help='optimise gap alignments')
parser.add_option('--seqrange', help='region within input to use as query')
parser.add_option('--sequence', help='input sequence file name')
# General options
parser.add_option('--email', help='e-mail address')
parser.add_option('--title', help='job title')
parser.add_option('--outfile', help='file name for results')
parser.add_option('--outformat', help='output format for results')
parser.add_option('--async', action='store_true', help='asynchronous mode')
parser.add_option('--jobid', help='job identifier')
parser.add_option('--polljob', action="store_true", help='get job result')
parser.add_option('--status', action="store_true", help='get job status')
parser.add_option('--resultTypes', action='store_true', help='get result types')
parser.add_option('--params', action='store_true', help='list input parameters')
parser.add_option('--paramDetail', help='get details for parameter')
parser.add_option('--quiet', action='store_true', help='decrease output level')
parser.add_option('--verbose', action='store_true', help='increase output level')
parser.add_option('--trace', action="store_true", help='show SOAP messages')
parser.add_option('--WSDL', default=wsdlUrl, help='WSDL URL for service')
parser.add_option('--debugLevel', type='int', default=debugLevel, help='debug output level')

(options, args) = parser.parse_args()

# Create the client
client = Client(options.WSDL)
server = client.service

# Configure HTTP proxy from OS environment (e.g. http_proxy="http://proxy.example.com:8080")
if os.environ.has_key('http_proxy'):
    http_proxy_conf = os.environ['http_proxy'].replace('http://', '')
    proxy = dict(http=http_proxy_conf)
    client.set_options(proxy=proxy)
elif os.environ.has_key('HTTP_PROXY'):
    http_proxy_conf = os.environ['HTTP_PROXY'].replace('http://', '')
    proxy = dict(http=http_proxy_conf)
    client.set_options(proxy=proxy)

# Increase output level
if options.verbose:
    outputLevel += 1

# Decrease output level
if options.quiet:
    outputLevel -= 1

# Debug level
if options.debugLevel:
    debugLevel = options.debugLevel

# If required enable SOAP message trace
if options.trace:
    logging.getLogger('suds.client').setLevel(logging.DEBUG);

# Debug print
def printDebugMessage(functionName, message, level):
    if(level <= debugLevel):
        print >>sys.stderr, '[' + functionName + '] ' + message

# Get input parameters list
def serviceGetParameters():
    printDebugMessage('serviceGetParameters', 'Begin', 1)
    result = server.getParameters()
    printDebugMessage('serviceGetParameters', 'End', 1)
    return result

# Get input parameter information
def serviceGetParameterDetails(paramName):
    printDebugMessage('serviceGetParameterDetails', 'Begin', 1)
    result= server.getParameterDetails(parameterId=paramName)
    printDebugMessage('serviceGetParameterDetails', 'End', 1)
    return result

# Submit job
def serviceRun(email, title, params):
    printDebugMessage('serviceRun', 'Begin', 1)
    jobid = server.run(email=email, title=title, parameters=params)
    printDebugMessage('serviceRun', 'End', 1)
    return jobid

# Get job status
def serviceCheckStatus(jobId):
    printDebugMessage('serviceCheckStatus', 'jobId: ' + jobId, 1)
    result = server.getStatus(jobId = jobId)
    return result

# Get available result types for job
def serviceGetResultTypes(jobId):
    printDebugMessage('serviceGetResultTypes', 'Begin', 1)
    result = server.getResultTypes(jobId=jobId)
    printDebugMessage('serviceGetResultTypes', 'End', 1)
    return result['type']

# Get result
def serviceGetResult(jobId, type):
    printDebugMessage('serviceGetResult', 'Begin', 1)
    printDebugMessage('serviceGetResult', 'jobId: ' + jobId, 1)
    printDebugMessage('serviceGetResult', 'type: ' + type, 1)
    resultBase64 = server.getResult(jobId=jobId, type=type)
    result = base64.decodestring(resultBase64)
    printDebugMessage('serviceGetResult', 'End', 1)
    return result

# Client-side poll
def clientPoll(jobId):
    printDebugMessage('clientPoll', 'Begin', 1)
    result = 'PENDING'
    while result == 'RUNNING' or result == 'PENDING':
        result = serviceCheckStatus(jobId)
        print >>sys.stderr, result
        if result == 'RUNNING' or result == 'PENDING':
            time.sleep(15)
    printDebugMessage('clientPoll', 'End', 1)

# Get result for a jobid
def getResult(jobId):
    printDebugMessage('getResult', 'Begin', 1)
    printDebugMessage('getResult', 'jobId: ' + jobId, 1)
    # Check status and wait if necessary
    clientPoll(jobId)
    # Get available result types
    resultTypes = serviceGetResultTypes(jobId)
    for resultType in resultTypes:
        # Get the result
        result = serviceGetResult(jobId, resultType['identifier'])
        # Derive the filename for the result
        if options.outfile:
            filename = options.outfile + '.' + resultType['identifier'] + '.' + resultType['fileSuffix']
        else:
            filename = jobId + '.' + resultType['identifier'] + '.' + resultType['fileSuffix']
        # Write a result file
        if not options.outformat or options.outformat == resultType['identifier']:
            fh = open(filename, 'w');
            fh.write(result)
            fh.close()
            print filename
    printDebugMessage('getResult', 'End', 1)

# Read a file
def readFile(filename):
    printDebugMessage('readFile', 'Begin', 1)
    fh = open(filename, 'r')
    data = fh.read()
    fh.close()
    printDebugMessage('readFile', 'End', 1)
    return data

# List parameters
if options.params:
    for paramName in serviceGetParameters()['id']:
        print paramName
# Get parameter details
elif options.paramDetail:
    paramDetail = serviceGetParameterDetails(options.paramDetail)
    print paramDetail['name'], "\t", paramDetail['type']
    print paramDetail['description']
    for value in paramDetail['values']['value']:
        print value['value'],
        if(value['defaultValue'] == 'true'):
            print '(default)',
        print
        print "\t", value['label']
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
        params['database'] = {'string':options.database}
    if options.stype:
        params['stype'] = options.stype
    if options.matrix:
        params['matrix'] = options.matrix
    if options.exp:
        params['exp'] = options.exp
    if options.filter:
        params['filter'] = options.filter
    if options.alignments:
        params['alignments'] = options.alignments
    if options.scores:
        params['scores'] = options.scores
    if options.dropoff:
        params['dropoff'] = options.dropoff
    if options.match_score:
        params['match_score'] = options.match_score
    if options.gapopen:
        params['gapopen'] = options.gapopen
    if options.gapext:
        params['gapext'] = options.gapext
    
    # Submit the job
    jobid = serviceRun(options.email, options.title, params)
    if options.async: # Async mode
        print jobid
    else: # Sync mode
        time.sleep(5)
        getResult(jobid)
# Get job status
elif options.status and options.jobid:
    status = serviceCheckStatus(options.jobid)
    print status
# List result types for job
elif options.resultTypes and options.jobid:
    for resultType in serviceGetResultTypes(options.jobid):
        print resultType['identifier']
        if(hasattr(resultType, 'label')):
            print "\t", resultType['label']
        if(hasattr(resultType, 'description')):
            print "\t", resultType['description']
        if(hasattr(resultType, 'mediaType')):
            print "\t", resultType['mediaType']
        if(hasattr(resultType, 'fileSuffix')):
            print "\t", resultType['fileSuffix']
# Get results for job
elif options.polljob and options.jobid:
    getResult(options.jobid)
else:
    print 'Error: unrecognised argument combination'
    parser.print_help()