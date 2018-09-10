#!/usr/bin/env python
# -*- coding: utf-8 -*-

###############################################################################
#
# Python Client Automatically generated with:
# https://github.com/ebi-wp/webservice-client-generator
#
# Copyright (C) 2006-2018 EMBL - European Bioinformatics Institute
# Under GNU GPL v3 License - See LICENSE for more details!
###############################################################################

from __future__ import print_function
import platform, os, sys, time
from xmltramp2 import xmltramp
from optparse import OptionParser

try:
    from urllib.parse import urlparse, urlencode
    from urllib.request import urlopen, Request
    from urllib.error import HTTPError
    from urllib.request import __version__ as urllib_version
except ImportError:
    from urlparse import urlparse
    from urllib import urlencode
    from urllib2 import urlopen, Request, HTTPError
    from urllib2 import __version__ as urllib_version

# allow unicode(str) to be used in python 3
try:
  unicode('')
except NameError:
  unicode = str

# Base URL for service
baseUrl = u'http://www.ebi.ac.uk/Tools/services/rest/fastm'

# Set interval for checking status
checkInterval = 10
# Output level
outputLevel = 1
# Debug level
debugLevel = 0
# Number of option arguments.
numOpts = len(sys.argv)

# Usage message
usage = u'''`Usage: %prog [options...] [seqFile]'''
description = u'''\
    FASTM --- compare peptides to a protein sequence database.\
'''
epilog = u'''For further information about the FASTM web service, see
http://www.ebi.ac.uk/tools/webservices/services/sss/fastm_rest.'''
version = u'ee8df29'

# Process command-line options
parser = OptionParser(usage=usage, description=description, epilog=epilog, version=version)

# Tool specific options (Try to print all the commands automatically)

parser.add_option('--program', help='The FASTA program to be used for the Sequence Similarity Search')
parser.add_option('--stype', help='Indicates if the query sequence is protein, DNA or RNA. Used to force FASTA to interpret the input sequence as specified type of sequence (via. the \'-p\', \'-n\' or \'-U\' options), this prevents issues when using nucleotide sequences that contain many ambiguous residues.')
parser.add_option('--matrix', help='The comparison matrix to be used to score alignments when searching the database')
parser.add_option('--match_scores', help=' Specify match/mismatch scores for DNA comparisons.  The default is \'+5/-4\'. \'+3/-2\' can perform better in some cases.')
parser.add_option('--gapopen', help='Score for the first residue in a gap.')
parser.add_option('--gapext', help='Score for each additional residue in a gap.')
parser.add_option('--hsps', help='Turn on/off the display of all significant alignments between query and library sequence.')
parser.add_option('--expupperlim', help='Limits the number of scores and alignments reported based on the expectation value. This is the maximum number of times the match is expected to occur by chance.')
parser.add_option('--explowlim', help='Limit the number of scores and alignments reported based on the expectation value. This is the minimum number of times the match is expected to occur by chance. This allows closely related matches to be excluded from the result in favor of more distant relationships.')
parser.add_option('--strand', help='For nucleotide sequences specify the sequence strand to be used for the search. By default both upper (provided) and lower (reverse complement of provided) strands are used, for single stranded sequences searching with only the upper or lower strand may provide better results.')
parser.add_option('--hist', help='Turn on/off the histogram in the FASTA result. The histogram gives a qualitative view of how well the statistical theory fits the similarity scores calculated by the program.')
parser.add_option('--scores', help='Maximum number of match score summaries reported in the result output.')
parser.add_option('--alignments', help='Maximum number of match alignments reported in the result output.')
parser.add_option('--scoreformat', help='Different score report formats.')
parser.add_option('--stats', help='The statistical routines assume that the library contains a large sample of unrelated sequences. Options to select what method to use include regression,  maximum likelihood estimates, shuffles, or combinations of these.')
parser.add_option('--seqrange', help='Specify a range or section of the input sequence to use in the search. Example: Specifying \'34-89\' in an input sequence of total length 100, will tell FASTA to only use residues 34 to 89, inclusive.')
parser.add_option('--dbrange', help='Specify the sizes of the sequences in a database to search against. For example: 100-250 will search all sequences in a database with length between 100 and 250 residues, inclusive.')
parser.add_option('--filter', help='Filter regions of low sequence complexity. This can avoid issues with low complexity sequences where matches are found due to composition rather then meaningful sequence similarity. However in some cases filtering also masks regions of interest and so should be used with caution.')
parser.add_option('--sequence', help='The input set of peptide or nucleotide sequence fragments are described using a modified fasta sequence format. This comprises a fasta header line with an identifier for the set of sequences and optionally a description, followed by the individual sequences each starting on a newline and separated with commas. Partially formatted sequences are not accepted. Adding a return to the end of the sequence may help certain applications understand the input. Note that directly using data from word processors may yield unpredictable results as hidden/control characters may be present.')
parser.add_option('--database', help='The databases to run the sequence similarity search against. Multiple databases can be used at the same time')
parser.add_option('--ktup', help='FASTA uses a rapid word-based lookup strategy to speed the initial phase of the similarity search. The KTUP is used to control the sensitivity of the search. Lower values lead to more sensitive, but slower searches.')
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
        print(u'[' + functionName + u'] ' + message, file=sys.stderr)

# User-agent for request (see RFC2616).
def getUserAgent():
    printDebugMessage(u'getUserAgent', u'Begin', 11)
    # Agent string for urllib2 library.
    urllib_agent = u'Python-urllib/%s' % urllib_version
    clientRevision = u'$Revision: 2107 $'
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
        req = Request(url, None, http_headers)
        # Make the request (HTTP GET).
        reqH = urlopen(req)
        resp = reqH.read()
        contenttype = reqH.info()


        if(len(resp)>0 and contenttype!=u"image/png;charset=UTF-8"
           and contenttype!=u"image/jpeg;charset=UTF-8"
           and contenttype!=u"application/gzip;charset=UTF-8"):

            try:
                result = unicode(resp, u'utf-8')
            except UnicodeDecodeError:
                result = resp
        else:
            result = resp
        reqH.close()
    # Errors are indicated by HTTP status codes.
    except HTTPError as ex:
        print(xmltramp.parse(ex.read())[0][0])
        quit()
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
        print(id_)
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
    print(unicode(doc.name) + u"\t" + unicode(doc.type))
    print(doc.description)
    for value in doc.values:
        print(value.value)
        if unicode(value.defaultValue) == u'true':
            print(u'default')
        print
        print(u"\t" + unicode(value.label))
        if hasattr(value, u'properties'):
            for wsProperty in value.properties:
                print(u"\t" + unicode(wsProperty.key) + u"\t" + unicode(wsProperty.value))
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
    requestData = urlencode(params)

    printDebugMessage(u'serviceRun', u'requestData: ' + requestData, 2)
    # Errors are indicated by HTTP status codes.
    try:
        # Set the HTTP User-agent.
        user_agent = getUserAgent()
        http_headers = { u'User-Agent' : user_agent }
        req = Request(requestUrl, None, http_headers)
        # Make the submission (HTTP POST).
        reqH = urlopen(req, requestData.encode(encoding=u'utf_8', errors=u'strict'))
        jobId = unicode(reqH.read(), u'utf-8')
        reqH.close()
    except HTTPError as ex:
        print(xmltramp.parse(ex.read())[0][0])
        quit()
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
    print(status)
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
        print(resultType[u'identifier'])
        if(hasattr(resultType, u'label')):
            print(u"\t", resultType[u'label'])
        if(hasattr(resultType, u'description')):
            print(u"\t", resultType[u'description'])
        if(hasattr(resultType, u'mediaType')):
            print(u"\t", resultType[u'mediaType'])
        if(hasattr(resultType, u'fileSuffix')):
            print(u"\t", resultType[u'fileSuffix'])
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
        print(result, file=sys.stderr)
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
                    fmode = 'wb'
                else:
                    fmode = 'w'

                fh = open(filename, fmode)

                fh.write(result)
                fh.close()
                print(filename)
    printDebugMessage(u'getResult', u'End', 1)

# Read a file
def readFile(filename):
    printDebugMessage(u'readFile', u'Begin', 1)
    fh = open(filename, 'r')
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

    if options.program:
            params['program'] = options.program
    if options.stype:
            params['stype'] = options.stype
    if options.matrix:
            params['matrix'] = options.matrix
    if options.match_scores:
            params['match_scores'] = options.match_scores
    if options.gapopen:
            params['gapopen'] = options.gapopen
    if options.gapext:
            params['gapext'] = options.gapext
    if options.hsps:
        params['hsps'] = True
    else:
        params['hsps'] = False
    if options.expupperlim:
            params['expupperlim'] = options.expupperlim
    if options.explowlim:
            params['explowlim'] = options.explowlim
    if options.strand:
            params['strand'] = options.strand
    if options.hist:
        params['hist'] = True
    else:
        params['hist'] = False
    if options.scores:
            params['scores'] = options.scores
    if options.alignments:
            params['alignments'] = options.alignments
    if options.scoreformat:
            params['scoreformat'] = options.scoreformat
    if options.stats:
            params['stats'] = options.stats
    if options.seqrange:
            params['seqrange'] = options.seqrange
    if options.dbrange:
            params['dbrange'] = options.dbrange
    if options.filter:
            params['filter'] = options.filter
    if options.sequence:
            params['sequence'] = options.sequence
    if options.database:
            params['database'] = options.database
    if options.ktup:
            params['ktup'] = options.ktup
# Submit the job
    jobid = serviceRun(options.email, options.title, params)
    if options.async: # Async mode
        print(jobid)
    else: # Sync mode
        print(jobid, file=sys.stderr)
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
        print('\nParameter "--email" is missing in your command. It is required!\n')

    print(u'Error: unrecognised argument combination', file=sys.stderr)
    parser.print_help()