#!/usr/bin/env python
# -*- coding: utf-8 -*-

###############################################################################
#
# Copyright 2012-2018 EMBL - European Bioinformatics Institute
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
# Python Client Automatically generated with:
# https://github.com/ebi-wp/webservice-clients-generator
#
# PSI-Blast (REST) web service Python client using xmltramp2.
#
# For further information see:
# https://www.ebi.ac.uk/Tools/webservices/
#
###############################################################################

from __future__ import print_function

import os
import sys
import time
import platform
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
baseUrl = u'https://www.ebi.ac.uk/Tools/services/rest/psiblast'
version = u'2019-01-16 13:32'

# Set interval for checking status
pollFreq = 3
# Output level
outputLevel = 1
# Debug level
debugLevel = 0
# Number of option arguments.
numOpts = len(sys.argv)

# Process command-line options
parser = OptionParser(add_help_option=False)

# Tool specific options (Try to print all the commands automatically)
parser.add_option('--matrix', help=('The comparison matrix to be used to score alignments when searching'
                  'the database'))
parser.add_option('--gapopen', help=('Penalty taken away from the score when a gap is created in sequence.'
                  'Increasing the gap openning penalty will decrease the number of gaps'
                  'in the final alignment.'))
parser.add_option('--gapext', help=('Penalty taken away from the score for each base or residue in the gap.'
                  'Increasing the gap extension penalty favors short gaps in the final'
                  'alignment, conversly decreasing the gap extension penalty favors long'
                  'gaps in the final alignment.'))
parser.add_option('--expthr', help=('Limits the number of scores and alignments reported based on the'
                  'expectation value. This is the maximum number of times the match is'
                  'expected to occur by chance.'))
parser.add_option('--psithr', help=('Expectation value threshold for automatic selection of matched'
                  'sequences for inclusion in PSSM at each iteration.'))
parser.add_option('--scores', help=('Maximum number of match score summaries reported in the result output.'))
parser.add_option('--alignments', help=('Maximum number of match alignments reported in the result output.'))
parser.add_option('--alignView', help=('Formating for the alignments'))
parser.add_option('--dropoff', help=('The amount a score can drop before extension of word hits is halted'))
parser.add_option('--finaldropoff', help=('Dropoff value for final gapped alignment'))
parser.add_option('--filter', help=('Filter regions of low sequence complexity. This can avoid issues with'
                  'low complexity sequences where matches are found due to composition'
                  'rather than meaningful sequence similarity. However in some cases'
                  'filtering also masks regions of interest and so should be used with'
                  'caution.'))
parser.add_option('--seqrange', help=('Specify a range or section of the input sequence to use in the search.'
                  'Example: Specifying 34-89 in an input sequence of total length 100,'
                  'will tell BLAST to only use residues 34 to 89, inclusive.'))
parser.add_option('--sequence', help=('The query sequence can be entered directly into this form. The'
                  'sequence can be in GCG, FASTA, PIR, NBRF, PHYLIP or UniProtKB/Swiss-'
                  'Prot format. A partially formatted sequence is not accepted. Adding a'
                  'return to the end of the sequence may help certain applications'
                  'understand the input. Note that directly using data from word'
                  'processors may yield unpredictable results as hidden/control'
                  'characters may be present.'))
parser.add_option('--database', help=('The databases to run the sequence similarity search against. Multiple'
                  'databases can be used at the same time'))
parser.add_option('--previousjobid', help=('The job identifier for the previous PSI-BLAST iteration.'))
parser.add_option('--selectedHits', help=('List of identifiers of the hits from the previous iteration to use to'
                  'construct the search PSSM for this iteration.'))
parser.add_option('--cpfile', help=('Checkpoint file from the previous iteration. Must be in ASN.1 Binary'
                  'Format.'))
parser.add_option('--umode', help=('Usage mode for PHI-BLAST functionality'))
parser.add_option('--patfile', help=('Pattern file for PHI-BLAST functionality. This file needs to be in the'
                  'style of a prosite entry file, with at least an ID line, PA line and'
                  'optional HI line.'))
# General options
parser.add_option('-h', '--help', action='store_true', help='Show this help message and exit.')
parser.add_option('--email', help='E-mail address.')
parser.add_option('--title', help='Job title.')
parser.add_option('--outfile', help='File name for results.')
parser.add_option('--outformat', help='Output format for results.')
parser.add_option('--async', action='store_true', help='Asynchronous mode.')
parser.add_option('--jobid', help='Job identifier.')
parser.add_option('--polljob', action="store_true", help='Get job result.')
parser.add_option('--pollFreq', type='int', default=3, help='Poll frequency in seconds (default 3s).')
parser.add_option('--status', action="store_true", help='Get job status.')
parser.add_option('--resultTypes', action='store_true', help='Get result types.')
parser.add_option('--params', action='store_true', help='List input parameters.')
parser.add_option('--paramDetail', help='Get details for parameter.')
parser.add_option('--quiet', action='store_true', help='Decrease output level.')
parser.add_option('--verbose', action='store_true', help='Increase output level.')
parser.add_option('--version', action='store_true', help='Prints out the version of the Client and exit.')
parser.add_option('--debugLevel', type='int', default=debugLevel, help='Debugging level.')
parser.add_option('--baseUrl', default=baseUrl, help='Base URL for service.')

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

if options.pollFreq:
    pollFreq = options.pollFreq

if options.baseUrl:
    baseUrl = options.baseUrl


# Debug print
def printDebugMessage(functionName, message, level):
    if (level <= debugLevel):
        print(u'[' + functionName + u'] ' + message, file=sys.stderr)


# User-agent for request (see RFC2616).
def getUserAgent():
    printDebugMessage(u'getUserAgent', u'Begin', 11)
    # Agent string for urllib2 library.
    urllib_agent = u'Python-urllib/%s' % urllib_version
    clientRevision = version
    # Prepend client specific agent string.
    user_agent = u'EBI-Sample-Client/%s (%s; Python %s; %s) %s' % (
        clientVersion, os.path.basename(__file__),
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
        http_headers = {u'User-Agent': user_agent}
        req = Request(url, None, http_headers)
        # Make the request (HTTP GET).
        reqH = urlopen(req)
        resp = reqH.read()
        contenttype = reqH.info()

        if (len(resp) > 0 and contenttype != u"image/png;charset=UTF-8"
                and contenttype != u"image/jpeg;charset=UTF-8"
                and contenttype != u"application/gzip;charset=UTF-8"):
            try:
                result = unicode(resp, u'utf-8')
            except UnicodeDecodeError:
                result = resp
        else:
            result = resp
        reqH.close()
    # Errors are indicated by HTTP status codes.
    except HTTPError as ex:
        print(xmltramp.parse(unicode(ex.read(), u'utf-8'))[0][0])
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
    if hasattr(doc, 'values'):
        for value in doc.values:
            print(value.value)
            if unicode(value.defaultValue) == u'true':
                print(u'default')
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
        http_headers = {u'User-Agent': user_agent}
        req = Request(requestUrl, None, http_headers)
        # Make the submission (HTTP POST).
        reqH = urlopen(req, requestData.encode(encoding=u'utf_8', errors=u'strict'))
        jobId = unicode(reqH.read(), u'utf-8')
        reqH.close()
    except HTTPError as ex:
        print(xmltramp.parse(unicode(ex.read(), u'utf-8'))[0][0])
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
    if outputLevel > 0:
        print("Getting status for job %s" % jobId)
    print(status)
    if outputLevel > 0 and status == "FINISHED":
        print("To get results: python %s --polljob --jobid %s"
              "" % (os.path.basename(__file__), jobId))
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
    if outputLevel > 0:
        print("Getting result types for job %s" % jobId)

    resultTypeList = serviceGetResultTypes(jobId)
    if outputLevel > 0:
        print("Available result types:")
    for resultType in resultTypeList:
        print(resultType[u'identifier'])
        if hasattr(resultType, u'label'):
            print(u"\t", resultType[u'label'])
        if hasattr(resultType, u'description'):
            print(u"\t", resultType[u'description'])
        if hasattr(resultType, u'mediaType'):
            print(u"\t", resultType[u'mediaType'])
        if hasattr(resultType, u'fileSuffix'):
            print(u"\t", resultType[u'fileSuffix'])
    if outputLevel > 0:
        print("To get results:\n  python %s --polljob --jobid %s\n"
              "  python %s --polljob --outformat <type> --jobid %s"
              "" % (os.path.basename(__file__), jobId,
                    os.path.basename(__file__), jobId))
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
        if outputLevel > 0:
            print(result)
        if result == u'RUNNING' or result == u'PENDING':
            time.sleep(pollFreq)
    printDebugMessage(u'clientPoll', u'End', 1)


# Get result for a jobid
# Allows more than one output file written when 'outformat' is defined.
def getResult(jobId):
    printDebugMessage(u'getResult', u'Begin', 1)
    printDebugMessage(u'getResult', u'jobId: ' + jobId, 1)
    if outputLevel > 1:
        print("Getting results for job %s" % jobId)
    # Check status and wait if necessary
    clientPoll(jobId)
    # Get available result types
    resultTypes = serviceGetResultTypes(jobId)

    for resultType in resultTypes:
        # Derive the filename for the result
        if options.outfile:
            filename = (options.outfile + u'.' + unicode(resultType[u'identifier']) +
                        u'.' + unicode(resultType[u'fileSuffix']))
        else:
            filename = (jobId + u'.' + unicode(resultType[u'identifier']) +
                        u'.' + unicode(resultType[u'fileSuffix']))
        # Write a result file

        outformat_parm = str(options.outformat).split(',')
        for outformat_type in outformat_parm:
            outformat_type = outformat_type.replace(' ', '')

            if outformat_type == 'None':
                outformat_type = None

            if not outformat_type or outformat_type == unicode(resultType[u'identifier']):
                if outputLevel > 1:
                    print("Getting %s" % unicode(resultType[u'identifier']))
                # Get the result
                result = serviceGetResult(jobId, unicode(resultType[u'identifier']))
                if (unicode(resultType[u'mediaType']) == u"image/png"
                        or unicode(resultType[u'mediaType']) == u"image/jpeg"
                        or unicode(resultType[u'mediaType']) == u"application/gzip"):
                    fmode = 'wb'
                else:
                    fmode = 'w'

                try:
                    fh = open(filename, fmode)
                    fh.write(result)
                    fh.close()
                except TypeError:
                    fh.close()
                    fh = open(filename, "wb")
                    fh.write(result)
                    fh.close()
                if outputLevel > 0:
                    print("Creating result file: " + filename)
    printDebugMessage(u'getResult', u'End', 1)


# Read a file
def readFile(filename):
    printDebugMessage(u'readFile', u'Begin', 1)
    fh = open(filename, 'r')
    data = fh.read()
    fh.close()
    printDebugMessage(u'readFile', u'End', 1)
    return data


def print_usage():
    print("""\
EMBL-EBI PSI-Blast Python Client:

Sequence similarity search with PSI-Blast.

[Required (for job submission)]
  --email               E-mail address.
  --sequence            The query sequence can be entered directly into this form.
                        The sequence can be in GCG, FASTA, PIR, NBRF, PHYLIP or
                        UniProtKB/Swiss-Prot format. A partially formatted sequence
                        is not accepted. Adding a return to the end of the sequence
                        may help certain applications understand the input. Note
                        that directly using data from word processors may yield
                        unpredictable results as hidden/control characters may be
                        present.
  --database            The databases to run the sequence similarity search against.
                        Multiple databases can be used at the same time.

[Optional]
  --matrix              The comparison matrix to be used to score alignments when
                        searching the database.
  --gapopen             Penalty taken away from the score when a gap is created in
                        sequence. Increasing the gap openning penalty will decrease
                        the number of gaps in the final alignment.
  --gapext              Penalty taken away from the score for each base or residue
                        in the gap. Increasing the gap extension penalty favors
                        short gaps in the final alignment, conversly decreasing the
                        gap extension penalty favors long gaps in the final
                        alignment.
  --expthr              Limits the number of scores and alignments reported based on
                        the expectation value. This is the maximum number of times
                        the match is expected to occur by chance.
  --psithr              Expectation value threshold for automatic selection of
                        matched sequences for inclusion in PSSM at each iteration.
  --scores              Maximum number of match score summaries reported in the
                        result output.
  --alignments          Maximum number of match alignments reported in the result
                        output.
  --alignView           Formating for the alignments.
  --dropoff             The amount a score can drop before extension of word hits is
                        halted.
  --finaldropoff        Dropoff value for final gapped alignment.
  --filter              Filter regions of low sequence complexity. This can avoid
                        issues with low complexity sequences where matches are found
                        due to composition rather than meaningful sequence
                        similarity. However in some cases filtering also masks
                        regions of interest and so should be used with caution.
  --seqrange            Specify a range or section of the input sequence to use in
                        the search. Example: Specifying '34-89' in an input sequence
                        of total length 100, will tell BLAST to only use residues 34
                        to 89, inclusive.
  --previousjobid       The job identifier for the previous PSI-BLAST iteration.
  --selectedHits        List of identifiers of the hits from the previous iteration
                        to use to construct the search PSSM for this iteration.
  --cpfile              Checkpoint file from the previous iteration. Must be in
                        ASN.1 Binary Format.
  --umode               Usage mode for PHI-BLAST functionality.
  --patfile             Pattern file for PHI-BLAST functionality. This file needs to
                        be in the style of a prosite entry file, with at least an ID
                        line, PA line and optional HI line.

[General]
  -h, --help            Show this help message and exit.
  --async               Forces to make an asynchronous query.
  --title               Title for job.
  --status              Get job status.
  --resultTypes         Get available result types for job.
  --polljob             Poll for the status of a job.
  --pollFreq            Poll frequency in seconds (default 3s).
  --jobid               JobId that was returned when an asynchronous job was submitted.
  --outfile             File name for results (default is JobId; for STDOUT).
  --outformat           Result format(s) to retrieve. It accepts comma-separated values.
  --params              List input parameters.
  --paramDetail         Display details for input parameter.
  --verbose             Increase output.
  --version             Prints out the version of the Client and exit.
  --quiet               Decrease output.
  --baseUrl             Base URL. Defaults to:
                        https://www.ebi.ac.uk/Tools/services/rest/psiblast

Synchronous job:
  The results/errors are returned as soon as the job is finished.
  Usage: python psiblast.py --email <your@email.com> [options...] <SeqFile|SeqID(s)>
  Returns: results as an attachment

Asynchronous job:
  Use this if you want to retrieve the results at a later time. The results
  are stored for up to 24 hours.
  Usage: python psiblast.py --async --email <your@email.com> [options...] <SeqFile|SeqID(s)>
  Returns: jobid

Check status of Asynchronous job:
  Usage: python psiblast.py --status --jobid <jobId>

Retrieve job data:
  Use the jobid to query for the status of the job. If the job is finished,
  it also returns the results/errors.
  Usage: python psiblast.py --polljob --jobid <jobId> [--outfile string]
  Returns: string indicating the status of the job and if applicable, results
  as an attachment.

Further information:
  https://www.ebi.ac.uk/Tools/webservices and
    https://github.com/ebi-wp/webservice-clients

Support/Feedback:
  https://www.ebi.ac.uk/support/""")


# No options... print help.
if numOpts < 2:
    print_usage()
elif options.help:
    print_usage()
# List parameters
elif options.params:
    printGetParameters()
# Get parameter details
elif options.paramDetail:
    printGetParameterDetails(options.paramDetail)
# Print Client version
elif options.version:
    print("Revision: %s" % version)
    sys.exit()
# Submit job
elif options.email and not options.jobid:
    params = {}
    if len(args) == 1:
        if os.path.exists(args[0]):  # Read file into content
            params[u'sequence'] = readFile(args[0])
        else:  # Argument is a sequence id
            params[u'sequence'] = args[0]
    elif len(args) == 2:
        if os.path.exists(args[0]) and os.path.exists(args[1]):  # Read file into content
            params[u'asequence'] = readFile(args[0])
            params[u'bsequence'] = readFile(args[1])
        else:  # Argument is a sequence id
            params[u'asequence'] = args[0]
            params[u'bsequence'] = args[0]
    elif hasattr(options, "sequence") or (hasattr(options, "asequence") and hasattr(options, "bsequence")):  # Specified via option
        if hasattr(options, "sequence"):
            if os.path.exists(options.sequence):  # Read file into content
                params[u'sequence'] = readFile(options.sequence)
            else:  # Argument is a sequence id
                params[u'sequence'] = options.sequence
        elif hasattr(options, "asequence") and hasattr(options, "bsequence"):
            if os.path.exists(options.asequence) and os.path.exists(options.bsequence):  # Read file into content
                params[u'asequence'] = readFile(options.asequence)
                params[u'bsequence'] = readFile(options.bsequence)
            else:  # Argument is a sequence id
                params[u'asequence'] = options.asequence
                params[u'bsequence'] = options.bsequence

    # Pass default values and fix bools (without default value)
    if options.database:
        params['database'] = options.database

    if not options.matrix:
        params['matrix'] = 'BLOSUM62'
    if options.matrix:
        params['matrix'] = options.matrix
    

    if not options.gapopen:
        params['gapopen'] = '11'
    if options.gapopen:
        params['gapopen'] = options.gapopen
    

    if not options.gapext:
        params['gapext'] = '1'
    if options.gapext:
        params['gapext'] = options.gapext
    

    if not options.expthr:
        params['expthr'] = '10.0'
    if options.expthr:
        params['expthr'] = options.expthr
    

    if not options.psithr:
        params['psithr'] = '1.0e-3'
    if options.psithr:
        params['psithr'] = options.psithr
    

    if not options.scores:
        params['scores'] = '500'
    if options.scores:
        params['scores'] = options.scores
    

    if not options.alignments:
        params['alignments'] = '500'
    if options.alignments:
        params['alignments'] = options.alignments
    

    if not options.alignView:
        params['alignView'] = '0'
    if options.alignView:
        params['alignView'] = options.alignView
    

    if not options.dropoff:
        params['dropoff'] = '15'
    if options.dropoff:
        params['dropoff'] = options.dropoff
    

    if not options.finaldropoff:
        params['finaldropoff'] = '25'
    if options.finaldropoff:
        params['finaldropoff'] = options.finaldropoff
    

    if not options.filter:
        params['filter'] = 'F'
    if options.filter:
        params['filter'] = options.filter
    

    if options.seqrange:
        params['seqrange'] = options.seqrange
    

    if options.previousjobid:
        params['previousjobid'] = options.previousjobid
    

    if options.selectedHits:
        params['selectedHits'] = options.selectedHits
    

    if options.cpfile:
        params['cpfile'] = options.cpfile
    

    if not options.umode:
        params['umode'] = 'blastpgp'
    if options.umode:
        params['umode'] = options.umode
    

    if options.patfile:
        params['patfile'] = options.patfile
    


    # Submit the job
    jobId = serviceRun(options.email, options.title, params)
    if options.async: # Async mode
        print(jobId)
        if outputLevel > 0:
            print("To check status: python %s --status --jobid %s"
                  "" % (os.path.basename(__file__), jobId))
    else:
        # Sync mode
        if outputLevel > 0:
            print("JobId: " + jobId, file=sys.stderr)
        else:
            print(jobId)
        time.sleep(pollFreq)
        getResult(jobId)
# Get job status
elif options.jobid and options.status:
    printGetStatus(options.jobid)

elif options.jobid and (options.resultTypes or options.polljob):
    status = serviceGetStatus(options.jobid)
    if status == 'PENDING' or status == 'RUNNING':
        print("Error: Job status is %s. "
              "To get result types the job must be finished." % status)
        quit()
    # List result types for job
    if options.resultTypes:
        printGetResultTypes(options.jobid)
    # Get results for job
    elif options.polljob:
        getResult(options.jobid)
else:
    # Checks for 'email' parameter
    if not options.email:
        print('\nParameter "--email" is missing in your command. It is required!\n')

    print(u'Error: unrecognised argument combination', file=sys.stderr)
    print_usage()
