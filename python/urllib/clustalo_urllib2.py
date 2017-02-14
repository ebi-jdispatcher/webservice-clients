#!/usr/bin/env python
# $Id: clustalo_urllib2.py 2106 2012-05-01 17:00:40Z hpm $
# ======================================================================
# Clustal Omega(REST) Python-2 client using urllib2 and
# xmltramp2 (https://pypi.python.org/pypi/xmltramp2/).
#
# Script edited by Manavalan Gajapathy (UAH) to suit Python 2.7 users and
# following features were added to assist users.
# 1. Prints error if 'email' parameter is missing in user's command.
# 2. Allows to have more than one output file with 'outformat' parameter.
#    Its arguments need to separated by comma.
#
# Tested with:
#  Python 2.7.6
#
# See:
# http://www.ebi.ac.uk/Tools/webservices/services/msa/clustalo_rest
# http://www.ebi.ac.uk/Tools/webservices/tutorials/python
# ======================================================================

# Load libraries
from __future__ import absolute_import
from io import open
import platform, os, sys, time, urllib, xmltramp
from optparse import OptionParser
import urllib2

# Base URL for service
baseUrl = u'http://www.ebi.ac.uk/Tools/services/rest/clustalo'

# Set interval for checking status
checkInterval = 10
# Output level
outputLevel = 1
# Debug level
debugLevel = 0
# Number of option arguments.
numOpts = len(sys.argv)

# Usage message
usage = u"Usage: %prog [options...] [seqFile]"
description = u"""Multiple sequence alignment using Clustal Omega"""
epilog = u"""For further information about the Clustal Omega web service, see
http://www.ebi.ac.uk/tools/webservices/services/msa/clustalo_rest."""
version = u"$Id: clustalo_urllib2.py 2106 2012-05-01 17:00:40Z hpm $"
# Process command-line options
parser = OptionParser(usage=usage, description=description, epilog=epilog, version=version)
# Tool specific options
parser.add_option(u'--guidetreeout', help=u'Enable output guide tree')
parser.add_option(u'--noguidetreeout', help=u'Disable output guide tree')
parser.add_option(u'--dismatout', help=u'Enable output distance matrix')
parser.add_option(u'--nodismatout', help=u'Disable output distance matrix')
parser.add_option(u'--dealign', help=u'Dealign input sequences')
parser.add_option(u'--nodealign', help=u'Not dealign input sequences')
parser.add_option(u'--mbed', help=u'Mbed-like clustering guide-tree')
parser.add_option(u'--nombed', help=u'No Mbed-like clustering guide-tree')
parser.add_option(u'--mbediteration', help=u'Mbed-like clustering iteration')
parser.add_option(u'--nombediteration', help=u'No Mbed-like clustering iteration')
parser.add_option(u'--iterations', help=u'Number of iterations')
parser.add_option(u'--gtiterations', help=u'Maximum guild tree iterations')
parser.add_option(u'--hmmiterations', help=u'Maximum HMM iterations')
parser.add_option(u'--outfmt', help=u'Output alignment format')
parser.add_option(u'--stype', default=u'protein', help=u'Input sequence type')
parser.add_option(u'--sequence', help=u'input sequence file name')
# General options
parser.add_option(u'--email', help=u'e-mail address')
parser.add_option(u'--title', help=u'job title')
parser.add_option(u'--outfile', help=u'file name for results')
parser.add_option(u'--outformat', help=u'output format for results')
parser.add_option(u'--async', action=u'store_true', help=u'asynchronous mode')
parser.add_option(u'--jobid', help=u'job identifier')
parser.add_option(u'--polljob', action=u"store_true", help=u'get job result')
parser.add_option(u'--status', action=u"store_true", help=u'get job status')
parser.add_option(u'--resultTypes', action=u'store_true', help=u'get result types')
parser.add_option(u'--params', action=u'store_true', help=u'list input parameters')
parser.add_option(u'--paramDetail', help=u'get details for parameter')
parser.add_option(u'--quiet', action=u'store_true', help=u'decrease output level')
parser.add_option(u'--verbose', action=u'store_true', help=u'increase output level')
parser.add_option(u'--baseURL', default=baseUrl, help=u'Base URL for service')
parser.add_option(u'--debugLevel', type=u'int', default=debugLevel, help=u'debug output level')

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
        print >>sys.stderr, u'[' + functionName + u'] ' + message

# User-agent for request (see RFC2616).
def getUserAgent():
    printDebugMessage(u'getUserAgent', u'Begin', 11)
    # Agent string for urllib2 library.
    urllib_agent = u'Python-urllib/%s' % urllib2.__version__
    clientRevision = u'$Revision: 2106 $'
    clientVersion = u'0'
    if len(clientRevision) > 11:
        clientVersion = clientRevision[11:-2]
    # Prepend client specific agent string.
    user_agent = u'EBI-Sample-Client/%s (%s; Python %s; %s) %s' % (
        clientVersion, os.path.basename( __file__ ),
        platform.python_version(), platform.system(),
        urllib_agent
    )
    printDebugMessage(u'getUserAgent', u'user_agent: ' + user_agent, 12)
    printDebugMessage(u'getUserAgent', u'End', 11)
    return user_agent

# Wrapper for a REST (HTTP GET) request
def restRequest(url):
    printDebugMessage(u'restRequest', u'Begin', 11)
    printDebugMessage(u'restRequest', u'url: ' + url, 11)
    try:
        # Set the User-agent.
        user_agent = getUserAgent()
        http_headers = { u'User-Agent' : user_agent }
        req = urllib2.Request(url, None, http_headers)
        # Make the request (HTTP GET).
        reqH = urllib2.urlopen(req)
        resp = reqH.read();
        contenttype = reqH.info()


        if(len(resp)>0 and contenttype!=u"image/png;charset=UTF-8"
           and contenttype!=u"image/jpeg;charset=UTF-8"
           and contenttype!=u"application/gzip;charset=UTF-8"):
            result = unicode(resp, u'utf-8')
        else:
            result = resp;
        reqH.close()
    # Errors are indicated by HTTP status codes.
    except urllib2.HTTPError, ex:
        # Trap exception and output the document to get error message.
        print >>sys.stderr, ex.read()
        raise
    printDebugMessage(u'restRequest', u'End', 11)
    return result

# Get input parameters list
def serviceGetParameters():
    printDebugMessage(u'serviceGetParameters', u'Begin', 1)
    requestUrl = baseUrl + u'/parameters'
    printDebugMessage(u'serviceGetParameters', u'requestUrl: ' + requestUrl, 2)
    xmlDoc = restRequest(requestUrl)
    doc = xmltramp.parse(xmlDoc)
    printDebugMessage(u'serviceGetParameters', u'End', 1)
    return doc[u'id':]

# Print list of parameters
def printGetParameters():
    printDebugMessage(u'printGetParameters', u'Begin', 1)
    idList = serviceGetParameters()
    for id_ in idList:
        print id_
    printDebugMessage(u'printGetParameters', u'End', 1)

# Get input parameter information
def serviceGetParameterDetails(paramName):
    printDebugMessage(u'serviceGetParameterDetails', u'Begin', 1)
    printDebugMessage(u'serviceGetParameterDetails', u'paramName: ' + paramName, 2)
    requestUrl = baseUrl + u'/parameterdetails/' + paramName
    printDebugMessage(u'serviceGetParameterDetails', u'requestUrl: ' + requestUrl, 2)
    xmlDoc = restRequest(requestUrl)
    doc = xmltramp.parse(xmlDoc)
    printDebugMessage(u'serviceGetParameterDetails', u'End', 1)
    return doc

# Print description of a parameter
def printGetParameterDetails(paramName):
    printDebugMessage(u'printGetParameterDetails', u'Begin', 1)
    doc = serviceGetParameterDetails(paramName)
    print unicode(doc.name) + u"\t" + unicode(doc.type)
    print doc.description
    for value in doc.values:
        print value.value,
        if unicode(value.defaultValue) == u'true':
            print u'default',
        print
        print u"\t" + unicode(value.label)
        if(hasattr(value, u'properties')):
            for wsProperty in value.properties:
                print u"\t" + unicode(wsProperty.key) + u"\t" + unicode(wsProperty.value)
    #print doc
    printDebugMessage(u'printGetParameterDetails', u'End', 1)

# Submit job
def serviceRun(email, title, params):
    printDebugMessage(u'serviceRun', u'Begin', 1)
    # Insert e-mail and title into params
    params[u'email'] = email
    if title:
        params[u'title'] = title
    requestUrl = baseUrl + u'/run/'
    printDebugMessage(u'serviceRun', u'requestUrl: ' + requestUrl, 2)

    # Get the data for the other options
    requestData = urllib.urlencode(params)

    printDebugMessage(u'serviceRun', u'requestData: ' + requestData, 2)
    # Errors are indicated by HTTP status codes.
    try:
        # Set the HTTP User-agent.
        user_agent = getUserAgent()
        http_headers = { u'User-Agent' : user_agent }
        req = urllib2.Request(requestUrl, None, http_headers)
        # Make the submission (HTTP POST).
        reqH = urllib2.urlopen(req, requestData.encode(encoding=u'utf_8', errors=u'strict'))
        jobId = unicode(reqH.read(), u'utf-8')
        reqH.close()
    except urllib2.HTTPError, ex:
        # Trap exception and output the document to get error message.
        print >>sys.stderr, ex.read()
        raise
    printDebugMessage(u'serviceRun', u'jobId: ' + jobId, 2)
    printDebugMessage(u'serviceRun', u'End', 1)
    return jobId

# Get job status
def serviceGetStatus(jobId):
    printDebugMessage(u'serviceGetStatus', u'Begin', 1)
    printDebugMessage(u'serviceGetStatus', u'jobId: ' + jobId, 2)
    requestUrl = baseUrl + u'/status/' + jobId
    printDebugMessage(u'serviceGetStatus', u'requestUrl: ' + requestUrl, 2)
    status = restRequest(requestUrl)
    printDebugMessage(u'serviceGetStatus', u'status: ' + status, 2)
    printDebugMessage(u'serviceGetStatus', u'End', 1)
    return status

# Print the status of a job
def printGetStatus(jobId):
    printDebugMessage(u'printGetStatus', u'Begin', 1)
    status = serviceGetStatus(jobId)
    print status
    printDebugMessage(u'printGetStatus', u'End', 1)


# Get available result types for job
def serviceGetResultTypes(jobId):
    printDebugMessage(u'serviceGetResultTypes', u'Begin', 1)
    printDebugMessage(u'serviceGetResultTypes', u'jobId: ' + jobId, 2)
    requestUrl = baseUrl + u'/resulttypes/' + jobId
    printDebugMessage(u'serviceGetResultTypes', u'requestUrl: ' + requestUrl, 2)
    xmlDoc = restRequest(requestUrl)
    doc = xmltramp.parse(xmlDoc)
    printDebugMessage(u'serviceGetResultTypes', u'End', 1)
    return doc[u'type':]

# Print list of available result types for a job.
def printGetResultTypes(jobId):
    printDebugMessage(u'printGetResultTypes', u'Begin', 1)
    resultTypeList = serviceGetResultTypes(jobId)
    for resultType in resultTypeList:
        print resultType[u'identifier']
        if(hasattr(resultType, u'label')):
            print u"\t", resultType[u'label']
        if(hasattr(resultType, u'description')):
            print u"\t", resultType[u'description']
        if(hasattr(resultType, u'mediaType')):
            print u"\t", resultType[u'mediaType']
        if(hasattr(resultType, u'fileSuffix')):
            print u"\t", resultType[u'fileSuffix']
    printDebugMessage(u'printGetResultTypes', u'End', 1)

# Get result
def serviceGetResult(jobId, type_):
    printDebugMessage(u'serviceGetResult', u'Begin', 1)
    printDebugMessage(u'serviceGetResult', u'jobId: ' + jobId, 2)
    printDebugMessage(u'serviceGetResult', u'type_: ' + type_, 2)
    requestUrl = baseUrl + u'/result/' + jobId + u'/' + type_
    result = restRequest(requestUrl)
    printDebugMessage(u'serviceGetResult', u'End', 1)
    return result

# Client-side poll
def clientPoll(jobId):
    printDebugMessage(u'clientPoll', u'Begin', 1)
    result = u'PENDING'
    while result == u'RUNNING' or result == u'PENDING':
        result = serviceGetStatus(jobId)
        print >>sys.stderr, result
        if result == u'RUNNING' or result == u'PENDING':
            time.sleep(checkInterval)
    printDebugMessage(u'clientPoll', u'End', 1)

# Get result for a jobid
# function modified by Mana to allow more than one output file written when 'outformat' is defined.
def getResult(jobId):
    printDebugMessage(u'getResult', u'Begin', 1)
    printDebugMessage(u'getResult', u'jobId: ' + jobId, 1)
    # Check status and wait if necessary
    clientPoll(jobId)
    # Get available result types
    resultTypes = serviceGetResultTypes(jobId)

    for resultType in resultTypes:
        # Derive the filename for the result
        if options.outfile:
            filename = options.outfile + u'.' + unicode(resultType[u'identifier']) + u'.' + unicode(resultType[u'fileSuffix'])
        else:
            filename = jobId + u'.' + unicode(resultType[u'identifier']) + u'.' + unicode(resultType[u'fileSuffix'])
        # Write a result file

        outformat_parm = str(options.outformat).split(',')
        for outformat_type in outformat_parm:
            outformat_type = outformat_type.replace(' ', '')

            if outformat_type == 'None':
                outformat_type = None

            if not outformat_type or outformat_type == unicode(resultType[u'identifier']):
                # Get the result
                result = serviceGetResult(jobId, unicode(resultType[u'identifier']))
                if(unicode(resultType[u'mediaType']) == u"image/png"
                   or unicode(resultType[u'mediaType']) == u"image/jpeg"
                   or unicode(resultType[u'mediaType']) == u"application/gzip"):
                    fmode= u'wb'
                else:
                    fmode=u'w'

                fh = open(filename, fmode);

                fh.write(result)
                fh.close()
                print filename
    printDebugMessage(u'getResult', u'End', 1)

# Read a file
def readFile(filename):
    printDebugMessage(u'readFile', u'Begin', 1)
    fh = open(filename, u'r')
    data = fh.read()
    fh.close()
    printDebugMessage(u'readFile', u'End', 1)
    return data

# No options... print help.
if numOpts < 2:
    parser.print_help()
# List parameters
elif options.params:
    printGetParameters()
# Get parameter details
elif options.paramDetail:
    printGetParameterDetails(options.paramDetail)
# Submit job
elif options.email and not options.jobid:
    params = {}
    if len(args) > 0:
        if os.access(args[0], os.R_OK): # Read file into content
            params[u'sequence'] = readFile(args[0])
        else: # Argument is a sequence id
            params[u'sequence'] = args[0]
    elif options.sequence: # Specified via option
        if os.access(options.sequence, os.R_OK): # Read file into content
            params[u'sequence'] = readFile(options.sequence)
        else: # Argument is a sequence id
            params[u'sequence'] = options.sequence
    # Booleans need to be represented as 1/0 rather than True/False
    if options.guidetreeout:
        params[u'guidetreeout'] = True
    else:
        params[u'guidetreeout'] = False
    if options.dismatout:
        params[u'dismatout'] = True
    else:
        params[u'dismatout'] = False
    if options.dealign:
        params[u'dealign'] = True
    else:
        params[u'dealign'] = False
    if options.mbed:
        params[u'mbed'] = True
    else:
        params[u'mbed'] = False
    if options.mbediteration:
        params[u'mbediteration'] = True
    else:
        params[u'mbediteration'] = False

    # Add the other options (if defined)
    if options.stype:
        params[u'stype'] = options.stype
    if options.iterations:
        params[u'iterations'] = options.iterations
    if options.gtiterations:
        params[u'gtiterations'] = options.gtiterations
    if options.hmmiterations:
        params[u'hmmiterations'] = options.hmmiterations
    if options.outfmt:
        params[u'outfmt'] = options.outfmt

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
    # Checks for 'email' parameter; added by Mana.
    if not options.email:
        print '\nParameter "--email" is missing in your command. It is required!\n'

    print >>sys.stderr, u'Error: unrecognised argument combination'
    parser.print_help()