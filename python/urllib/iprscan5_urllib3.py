#!/usr/bin/env python3
# $Id: iprscan5_urllib3.py 2106 2012-05-01 17:00:40Z hpm $
# ======================================================================
# InterProScan 5 (REST) Python 3 client using urllib3 and 
# xmltramp2 (https://pypi.python.org/pypi/xmltramp2/).
#
# Tested with:
#  Python 3.4.3
#
# See:
# http://www.ebi.ac.uk/Tools/webservices/services/pfa/iprscan5_rest
# http://www.ebi.ac.uk/Tools/webservices/tutorials/python
# ======================================================================
# Base URL for service
baseUrl = 'http://www.ebi.ac.uk/Tools/services/rest/iprscan5'

# Load libraries
import platform, os, sys, time, re, urllib
from optparse import OptionParser
from xmltramp2 import xmltramp
import urllib.request as urllib2

# Set interval for checking status
checkInterval = 10
# Output level
outputLevel = 1
# Debug level
debugLevel = 0
# Number of option arguments.
numOpts = len(sys.argv)

# Usage message
usage = "Usage: %prog [options...] [seqFile]"
description = """Identify protein family, domain and signal signatures in a 
protein sequence using InterProScan. For more information on InterPro and InterProScan refer to http://www.ebi.ac.uk/interpro/"""
epilog = """For further information about the InterProScan 5 (REST) web service, see http://www.ebi.ac.uk/Tools/webservices/services/pfa/iprscan5_est."""
version = "$Id: iprscan5_urllib3.py 2773 2014-04-11 11:27:27Z hpm $"
# Process command-line options
parser = OptionParser(usage=usage, description=description, epilog=epilog, version=version)
# Tool specific options
parser.add_option('--appl', help='signature methods to use, see --paramDetail appl')
parser.add_option('--crc', action="store_true", help='enable InterProScan Matches look-up (ignored)')
parser.add_option('--nocrc', action="store_true", help='disable InterProScan Matches look-up (ignored)')
parser.add_option('--goterms', action="store_true", help='enable inclusion of GO terms')
parser.add_option('--nogoterms', action="store_true", help='disable inclusion of GO terms')
parser.add_option('--pathways', action="store_true", help='enable inclusion of pathway terms')
parser.add_option('--nopathways', action="store_true", help='disable inclusion of pathway terms')
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
        print ('[' + functionName + '] ' + message, file=sys.stderr)

# User-agent for request (see RFC2616).
def getUserAgent():
    printDebugMessage('getUserAgent', 'Begin', 11)
    # Agent string for urllib2 library.
    urllib_agent = 'Python-urllib/%s' % urllib2.__version__
    clientRevision = '$Revision: 2106 $'
    clientVersion = '0'
    if len(clientRevision) > 11:
        clientVersion = clientRevision[11:-2]
    # Prepend client specific agent string.
    user_agent = 'EBI-Sample-Client/%s (%s; Python %s; %s) %s' % (
        clientVersion, os.path.basename( __file__ ),
        platform.python_version(), platform.system(),
        urllib_agent
    )
    printDebugMessage('getUserAgent', 'user_agent: ' + user_agent, 12)
    printDebugMessage('getUserAgent', 'End', 11)
    return user_agent

# Wrapper for a REST (HTTP GET) request
def restRequest(url):
    printDebugMessage('restRequest', 'Begin', 11)
    printDebugMessage('restRequest', 'url: ' + url, 11)
    # Errors are indicated by HTTP status codes.
    try:
        # Set the User-agent.
        user_agent = getUserAgent()
        http_headers = { 'User-Agent' : user_agent }
        req = urllib2.Request(url, None, http_headers)
        # Make the request (HTTP GET).
        reqH = urllib2.urlopen(req)
        resp = reqH.read();
        contenttype = reqH.getheader("Content-Type")
                
        if(len(resp)>0 and contenttype!="image/png;charset=UTF-8"
            and contenttype!="image/jpeg;charset=UTF-8"
            and contenttype!="application/gzip;charset=UTF-8"):
            result = str(resp, 'utf-8')
        else:
            result = resp;
        reqH.close()
    # Errors are indicated by HTTP status codes.
    except urllib2.HTTPError as ex:
        # Trap exception and output the document to get error message.
        print (ex.read(), file=sys.stderr)
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
    for id_ in idList:
        print (id_)
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
    print (str(doc.name) + "\t" + str(doc.type))
    print (doc.description)
    for value in doc.values:
        print (value.value,end=" ")
        if str(value.defaultValue) == 'true':
            print ('default', end=" ")
        print
        print ("\t" + str(value.label))
        if(hasattr(value, 'properties')):
            for wsProperty in value.properties:
                print  ("\t" + str(wsProperty.key) + "\t" + str(wsProperty.value))
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
    # Signature methods requires special handling (list)
    applData = ''
    if 'appl' in params:
        # So extract from params
        applList = params['appl']
        del params['appl']
        # Build the method data options
        for appl in applList:
            applData += '&appl=' + appl
    # Get the data for the other options
    requestData = urllib.parse.urlencode(params);
    
    requestData += applData;
    printDebugMessage('serviceRun', 'requestData: ' + requestData, 2)
    # Errors are indicated by HTTP status codes.
    try:
        # Set the HTTP User-agent.
        user_agent = getUserAgent()
        http_headers = { 'User-Agent' : user_agent }
        req = urllib2.Request(requestUrl, None, http_headers)
        # Make the submission (HTTP POST).
        reqH = urllib2.urlopen(req, requestData.encode(encoding='utf_8', errors='strict'))
        jobId = str(reqH.read(), 'utf-8')
        reqH.close()
    except urllib2.HTTPError as ex:
        # Trap exception and output the document to get error message.
        print (ex.read(), file=sys.stderr)
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
    print (status)
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
        print (resultType['identifier'])
        if(hasattr(resultType, 'label')):
            print ("\t", resultType['label'])
        if(hasattr(resultType, 'description')):
            print ("\t", resultType['description'])
        if(hasattr(resultType, 'mediaType')):
            print ("\t", resultType['mediaType'])
        if(hasattr(resultType, 'fileSuffix')):
            print ("\t", resultType['fileSuffix'])
    printDebugMessage('printGetResultTypes', 'End', 1)

# Get result
def serviceGetResult(jobId, type_):
    printDebugMessage('serviceGetResult', 'Begin', 1)
    printDebugMessage('serviceGetResult', 'jobId: ' + jobId, 2)
    printDebugMessage('serviceGetResult', 'type_: ' + type_, 2)
    requestUrl = baseUrl + '/result/' + jobId + '/' + type_
    result = restRequest(requestUrl)
    printDebugMessage('serviceGetResult', 'End', 1)
    return result

# Client-side poll
def clientPoll(jobId):
    printDebugMessage('clientPoll', 'Begin', 1)
    result = 'PENDING'
    while result == 'RUNNING' or result == 'PENDING':
        result = serviceGetStatus(jobId)
        print (result, file=sys.stderr)
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
            if(str(resultType['mediaType']) == "image/png"
                or str(resultType['mediaType']) == "image/jpeg"
                or str(resultType['mediaType']) == "application/gzip"):
                fmode= 'wb'
            else:
                fmode='w'
                
            fh = open(filename, fmode);
            
            fh.write(result)
            fh.close()
            print (filename)
    printDebugMessage('getResult', 'End', 1)

# Read a file
def readFile(filename):
    printDebugMessage('readFile', 'Begin', 1)
    fh = open(filename, 'r')
    data = fh.read()
    fh.close()
    printDebugMessage('readFile', 'End', 1)
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
            params['sequence'] = readFile(args[0])
        else: # Argument is a sequence id
            params['sequence'] = args[0]
    elif options.sequence: # Specified via option
        if os.access(options.sequence, os.R_OK): # Read file into content
            params['sequence'] = readFile(options.sequence)
        else: # Argument is a sequence id
            params['sequence'] = options.sequence
    # Map flag options to boolean values.
    #if options.crc:
    #    params['crc'] = True
    #elif options.nocrc:
    #    params['crc'] = False
    if options.goterms:
        params['goterms'] = True
    elif options.nogoterms:
        params['goterms'] = False
    if options.pathways:
        params['pathways'] = True
    elif options.nopathways:
        params['pathways'] = False
    # Add the other options (if defined)
    if options.appl:
        params['appl'] = re.split('[ \t\n,;]+', options.appl)
    
    # Submit the job
    jobid = serviceRun(options.email, options.title, params)
    if options.async: # Async mode
        print (jobid)
    else: # Sync mode
        print (jobid, file=sys.stderr)
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
    print ('Error: unrecognised argument combination', file=sys.stderr)
    parser.print_help()
