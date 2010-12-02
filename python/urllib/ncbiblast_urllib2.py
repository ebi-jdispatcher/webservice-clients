#!/usr/bin/env python
# $Id$
# ======================================================================
# NCBI BLAST REST service, Python client using urllib2 and 
# xmltramp (http://www.aaronsw.com/2002/xmltramp/).
#
# Tested with:
#   Python 2.6.2 (Ubuntu 9.04)
#
# See:
# http://www.ebi.ac.uk/Tools/webservices/services/sss/ncbi_blast_rest
# http://www.ebi.ac.uk/Tools/webservices/tutorials/python
# ======================================================================
# Base URL for service
baseUrl = 'http://www.ebi.ac.uk/Tools/services/rest/ncbiblast'

# Load libraries
import os, re, sys, time, urllib, urllib2
import xmltramp
import pprint
from optparse import OptionParser

# Set interval for checking status
checkInterval = 10
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
parser.add_option('-E', '--exp', help='E-value threshold')
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
parser.add_option('--baseURL', default=baseUrl, help='Base URL for service')
parser.add_option('--debugLevel', type='int', default=debugLevel, help='debug output level')

(options, args) = parser.parse_args()

# Increase output level
if options.verbose:
    outputLevel += 1

# Decrease output level
if options.quiet:
    outputLevel -= 1

# Debug level
if options.debugLevel:
    debugLevel = options.debugLevel

# Debug print
def printDebugMessage(functionName, message, level):
    if(level <= debugLevel):
        print >>sys.stderr, '[' + functionName + '] ' + message

# User-agent for request.
def getUserAgent():
    printDebugMessage('getUserAgent', 'Begin', 11)
    urllib_agent = 'Python-urllib/%s' % sys.version[:3]
    clientRevision = '$Revision$'
    clientVersion = '0'
    if len(clientRevision) > 11:
        clientVersion = clientRevision[11:-2]
    user_agent = 'EBI-Sample-Client/' + clientVersion
    user_agent += ' (' + os.path.basename( __file__ ) + '; ' + os.name + ')'
    user_agent += ' ' + urllib_agent
    printDebugMessage('getUserAgent', 'user_agent: ' + user_agent, 12)
    printDebugMessage('getUserAgent', 'End', 11)
    return user_agent

# Wrapper for a REST (HTTP GET) request
def restRequest(url):
    printDebugMessage('restRequest', 'Begin', 11)
    printDebugMessage('restRequest', 'url: ' + url, 11)
    try:
        user_agent = getUserAgent()
        http_headers = { 'User-Agent' : user_agent }
        req = urllib2.Request(url, None, http_headers)
        reqH = urllib2.urlopen(req)
        result = reqH.read()
        reqH.close()
    except urllib2.HTTPError, ex:
        print ex.read()
        raise
    printDebugMessage('restRequest', 'End', 11)
    return result

# Get input parameters list
def serviceGetParameters():
    printDebugMessage('serviceGetParameters', 'Begin', 1)
    requestUrl = baseUrl + '/parameters'
    printDebugMessage('serviceGetParameters', 'requestUrl: ' + requestUrl, 2)
    xmlDoc = restRequest(requestUrl)
    doc = xmltramp.parse(xmlDoc)
    printDebugMessage('serviceGetParameters', 'End', 1)
    return doc['id':]

# Print list of parameters
def printGetParameters():
    printDebugMessage('printGetParameters', 'Begin', 1)
    idList = serviceGetParameters()
    for id in idList:
        print id
    printDebugMessage('printGetParameters', 'End', 1)    

# Get input parameter information
def serviceGetParameterDetails(paramName):
    printDebugMessage('serviceGetParameterDetails', 'Begin', 1)
    printDebugMessage('serviceGetParameterDetails', 'paramName: ' + paramName, 2)
    requestUrl = baseUrl + '/parameterdetails/' + paramName
    printDebugMessage('serviceGetParameterDetails', 'requestUrl: ' + requestUrl, 2)
    xmlDoc = restRequest(requestUrl)
    doc = xmltramp.parse(xmlDoc)
    printDebugMessage('serviceGetParameterDetails', 'End', 1)
    return doc

# Print description of a parameter
def printGetParameterDetails(paramName):
    printDebugMessage('printGetParameterDetails', 'Begin', 1)
    doc = serviceGetParameterDetails(paramName)
    print str(doc.name) + "\t" + str(doc.type)
    print doc.description
    for value in doc.values:
        print value.value,
        if str(value.defaultValue) == 'true':
            print 'default',
        print
        print "\t" + str(value.label)
    #print doc
    printDebugMessage('printGetParameterDetails', 'End', 1)

# Submit job
def serviceRun(email, title, params):
    printDebugMessage('serviceRun', 'Begin', 1)
    # Insert e-mail and title into params
    params['email'] = email
    if title:
        params['title'] = title
    requestUrl = baseUrl + '/run/'
    printDebugMessage('serviceRun', 'requestUrl: ' + requestUrl, 2)
    # Database requires special handling, so extract from params
    databaseList = params['database']
    del params['database']
    # Build the database data options
    databaseData = ''
    for db in databaseList:
        databaseData += '&database=' + db
    # Get the data for the other options
    requestData = urllib.urlencode(params)
    # Concatenate the two parts.
    requestData += databaseData
    printDebugMessage('serviceRun', 'requestData: ' + requestData, 2)
    try:
        reqH = urllib2.urlopen(requestUrl, requestData)
        jobId = reqH.read()
        reqH.close()    
    except urllib2.HTTPError, ex:
        print ex.read()
        raise
    printDebugMessage('serviceRun', 'jobId: ' + jobId, 2)
    printDebugMessage('serviceRun', 'End', 1)
    return jobId

# Get job status
def serviceGetStatus(jobId):
    printDebugMessage('serviceGetStatus', 'Begin', 1)
    printDebugMessage('serviceGetStatus', 'jobId: ' + jobId, 2)
    requestUrl = baseUrl + '/status/' + jobId
    printDebugMessage('serviceGetStatus', 'requestUrl: ' + requestUrl, 2)
    status = restRequest(requestUrl)
    printDebugMessage('serviceGetStatus', 'status: ' + status, 2)
    printDebugMessage('serviceGetStatus', 'End', 1)
    return status

# Print the status of a job
def printGetStatus(jobId):
    printDebugMessage('printGetStatus', 'Begin', 1)
    status = serviceGetStatus(jobId)
    print status
    printDebugMessage('printGetStatus', 'End', 1)
    

# Get available result types for job
def serviceGetResultTypes(jobId):
    printDebugMessage('serviceGetResultTypes', 'Begin', 1)
    printDebugMessage('serviceGetResultTypes', 'jobId: ' + jobId, 2)
    requestUrl = baseUrl + '/resulttypes/' + jobId
    printDebugMessage('serviceGetResultTypes', 'requestUrl: ' + requestUrl, 2)
    xmlDoc = restRequest(requestUrl)
    doc = xmltramp.parse(xmlDoc)
    printDebugMessage('serviceGetResultTypes', 'End', 1)
    return doc['type':]

# Print list of available result types for a job.
def printGetResultTypes(jobId):
    printDebugMessage('printGetResultTypes', 'Begin', 1)
    resultTypeList = serviceGetResultTypes(jobId)
    for resultType in resultTypeList:
        print resultType['identifier']
        if(hasattr(resultType, 'label')):
            print "\t", resultType['label']
        if(hasattr(resultType, 'description')):
            print "\t", resultType['description']
        if(hasattr(resultType, 'mediaType')):
            print "\t", resultType['mediaType']
        if(hasattr(resultType, 'fileSuffix')):
            print "\t", resultType['fileSuffix']
    printDebugMessage('printGetResultTypes', 'End', 1)

# Get result
def serviceGetResult(jobId, type):
    printDebugMessage('serviceGetResult', 'Begin', 1)
    printDebugMessage('serviceGetResult', 'jobId: ' + jobId, 2)
    printDebugMessage('serviceGetResult', 'type: ' + type, 2)
    requestUrl = baseUrl + '/result/' + jobId + '/' + type
    result = restRequest(requestUrl)
    printDebugMessage('serviceGetResult', 'End', 1)
    return result

# Client-side poll
def clientPoll(jobId):
    printDebugMessage('clientPoll', 'Begin', 1)
    result = 'PENDING'
    while result == 'RUNNING' or result == 'PENDING':
        result = serviceGetStatus(jobId)
        print >>sys.stderr, result
        if result == 'RUNNING' or result == 'PENDING':
            time.sleep(checkInterval)
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
        # Derive the filename for the result
        if options.outfile:
            filename = options.outfile + '.' + str(resultType['identifier']) + '.' + str(resultType['fileSuffix'])
        else:
            filename = jobId + '.' + str(resultType['identifier']) + '.' + str(resultType['fileSuffix'])
        # Write a result file
        if not options.outformat or options.outformat == str(resultType['identifier']):
            # Get the result
            result = serviceGetResult(jobId, str(resultType['identifier']))
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
    printGetParameters()
# Get parameter details
elif options.paramDetail:
    printGetParameterDetails(options.paramDetail)
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
        params['gapalign'] = True
    else:
        params['gapalign'] = False
    # Add the other options (if defined)
    if options.program:
        params['program'] = options.program
    if options.database:
        params['database'] = re.split('[ \t\n,;]+', options.database)
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
        print >>sys.stderr, jobid
        time.sleep(5)
        getResult(jobid)
# Get job status
elif options.status and options.jobid:
    printGetStatus(options.jobid)
# List result types for job
elif options.resultTypes and options.jobid:
    printGetResultTypes(options.jobid)
# Get results for job
elif options.polljob and options.jobid:
    getResult(options.jobid)
else:
    print 'Error: unrecognised argument combination'
    parser.print_help()
