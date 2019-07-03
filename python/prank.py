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
# Prank (REST) web service Python client using xmltramp2.
#
# For further information see:
# https://www.ebi.ac.uk/Tools/webservices/
#
###############################################################################

from __future__ import print_function

import os
import sys
import time
import requests
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
baseUrl = u'https://www.ebi.ac.uk/Tools/services/rest/prank'
version = u'2019-07-03 12:51'

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
parser.add_option('--sequence', type=str, help=('Three or more sequences to be aligned can be entered directly into'
                  'this form. The sequences must be in FASTA format. Partially formatted'
                  'sequences are not accepted. Adding a return to the end of the sequence'
                  'may help certain applications understand the input. Note that directly'
                  'using data from word processors may yield unpredictable results as'
                  'hidden/control characters may be present. There is a limit of 500'
                  'sequences or 1MB of data.'))
parser.add_option('--data_file', type=str, help=('A file containing valid sequences in FASTA format can be used as input'
                  'for the sequence similarity search. Word processors files may yield'
                  'unpredictable results as hidden/control characters may be present in'
                  'the files. It is best to save files with the Unix format option to'
                  'avoid hidden Windows characters.'))
parser.add_option('--tree_file', type=str, help=('Tree file in Newick Binary Format.'))
parser.add_option('--do_njtree', action='store_true', help=('compute guide tree from input alignment'))
parser.add_option('--do_clustalw_tree', action='store_true', help=('compute guide tree using Clustalw2'))
parser.add_option('--model_file', type=str, help=('Structure Model File.'))
parser.add_option('--output_format', type=str, help=('Format for output alignment file'))
parser.add_option('--trust_insertions', action='store_true', help=('Trust inferred insertions and do not allow their later matching'))
parser.add_option('--show_insertions_with_dots', action='store_true', help=('Show gaps created by insertions as dots, deletions as dashes'))
parser.add_option('--use_log_space', action='store_true', help=('Use log space for probabilities; slower but necessary for large'
                  'numbers of sequences'))
parser.add_option('--use_codon_model', action='store_true', help=('Use codon substutition model for alignment; requires DNA, multiples of'
                  'three in length'))
parser.add_option('--translate_DNA', action='store_true', help=('Translate DNA sequences to proteins and backtranslate results'))
parser.add_option('--mt_translate_DNA', action='store_true', help=('Translate DNA sequences to mt proteins, align and backtranslate'
                  'results'))
parser.add_option('--gap_rate', type=str, help=('Gap Opening Rate'))
parser.add_option('--gap_extension', type=str, help=('Gap Extension Probability'))
parser.add_option('--tn93_kappa', type=str, help=('Parameter kappa for Tamura-Nei DNA substitution model'))
parser.add_option('--tn93_rho', type=str, help=('Parameter rho for Tamura-Nei DNA substitution model'))
parser.add_option('--guide_pairwise_distance', type=str, help=('Fixed pairwise distance used for generating scoring matrix in guide'
                  'tree computation'))
parser.add_option('--max_pairwise_distance', type=str, help=('Maximum pairwise distance allowed in progressive steps of multiple'
                  'alignment; allows making matching more stringent or flexible'))
parser.add_option('--branch_length_scaling', type=str, help=('Factor for scaling all branch lengths'))
parser.add_option('--branch_length_fixed', type=str, help=('Fixed value for all branch lengths'))
parser.add_option('--branch_length_maximum', type=str, help=('Upper limit for branch lengths'))
parser.add_option('--use_real_branch_lengths', action='store_true', help=('Use real branch lengths; using this can be harmful as scoring matrices'
                  'became flat for large distances; rather use max_pairwise_distance'))
parser.add_option('--do_no_posterior', action='store_true', help=('Do not compute posterior probability; much faster if those not needed'))
parser.add_option('--run_once', action='store_true', help=('Do not iterate alignment'))
parser.add_option('--run_twice', action='store_true', help=('Iterate alignment'))
parser.add_option('--penalise_terminal_gaps', action='store_true', help=('Penalise terminal gaps as any other gap'))
parser.add_option('--do_posterior_only', action='store_true', help=('Compute posterior probabilities for given *aligned* sequences; may be'
                  'unstable but useful'))
parser.add_option('--use_chaos_anchors', action='store_true', help=('Use chaos anchors to massively speed up alignments; DNA only'))
parser.add_option('--minimum_anchor_distance', type=int, help=('Minimum chaos anchor distance'))
parser.add_option('--maximum_anchor_distance', type=int, help=('Maximum chaos anchor distance'))
parser.add_option('--skip_anchor_distance', type=int, help=('Chaos anchor skip distance'))
parser.add_option('--drop_anchor_distance', type=int, help=('Chaos anchor drop distance'))
parser.add_option('--output_ancestors', action='store_true', help=('Output ancestral sequences and probability profiles; note additional'
                  'files'))
parser.add_option('--noise_level', type=int, help=('Noise level; progress and debugging information'))
parser.add_option('--stay_quiet', action='store_true', help=('Stay quiet; disable all progress information'))
parser.add_option('--random_seed', type=int, help=('Set seed for random number generator; not recommended'))
# General options
parser.add_option('-h', '--help', action='store_true', help='Show this help message and exit.')
parser.add_option('--email', help='E-mail address.')
parser.add_option('--title', help='Job title.')
parser.add_option('--outfile', help='File name for results.')
parser.add_option('--outformat', help='Output format for results.')
parser.add_option('--asyncjob', action='store_true', help='Asynchronous mode.')
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
    try:
        pythonversion = platform.python_version()
        pythonsys = platform.system()
    except ValueError:
        pythonversion, pythonsys = "Unknown", "Unknown"
    user_agent = u'EBI-Sample-Client/%s (%s; Python %s; %s) %s' % (
        clientRevision, os.path.basename(__file__),
        pythonversion, pythonsys, urllib_agent)
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
        result = requests.get(url).content
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
EMBL-EBI Prank Python Client:

Multiple sequence alignment with Prank.

[Required (for job submission)]
  --email               E-mail address.
  --sequence            Three or more sequences to be aligned can be entered
                        directly into this form. The sequences must be in FASTA
                        format. Partially formatted sequences are not accepted.
                        Adding a return to the end of the sequence may help certain
                        applications understand the input. Note that directly using
                        data from word processors may yield unpredictable results as
                        hidden/control characters may be present. There is a limit
                        of 500 sequences or 1MB of data.

[Optional]
  --data_file           A file containing valid sequences in FASTA format can be
                        used as input for the sequence similarity search. Word
                        processors files may yield unpredictable results as
                        hidden/control characters may be present in the files. It is
                        best to save files with the Unix format option to avoid
                        hidden Windows characters.
  --tree_file           Tree file in Newick Binary Format.
  --do_njtree           compute guide tree from input alignment.
  --do_clustalw_tree    compute guide tree using Clustalw2.
  --model_file          Structure Model File.
  --output_format       Format for output alignment file.
  --trust_insertions    Trust inferred insertions and do not allow their later
                        matching.
  --show_insertions_with_dots Show gaps created by insertions as dots, deletions as dashes.
  --use_log_space       Use log space for probabilities; slower but necessary for
                        large numbers of sequences.
  --use_codon_model     Use codon substutition model for alignment; requires DNA,
                        multiples of three in length.
  --translate_DNA       Translate DNA sequences to proteins and backtranslate
                        results.
  --mt_translate_DNA    Translate DNA sequences to mt proteins, align and
                        backtranslate results.
  --gap_rate            Gap Opening Rate.
  --gap_extension       Gap Extension Probability.
  --tn93_kappa          Parameter kappa for Tamura-Nei DNA substitution model.
  --tn93_rho            Parameter rho for Tamura-Nei DNA substitution model.
  --guide_pairwise_distance Fixed pairwise distance used for generating scoring matrix
                        in guide tree computation.
  --max_pairwise_distance Maximum pairwise distance allowed in progressive steps of
                        multiple alignment; allows making matching more stringent or
                        flexible.
  --branch_length_scaling Factor for scaling all branch lengths.
  --branch_length_fixed Fixed value for all branch lengths.
  --branch_length_maximum Upper limit for branch lengths.
  --use_real_branch_lengths Use real branch lengths; using this can be harmful as
                        scoring matrices became flat for large distances; rather use
                        max_pairwise_distance.
  --do_no_posterior     Do not compute posterior probability; much faster if those
                        not needed.
  --run_once            Do not iterate alignment.
  --run_twice           Iterate alignment.
  --penalise_terminal_gaps Penalise terminal gaps as any other gap.
  --do_posterior_only   Compute posterior probabilities for given *aligned*
                        sequences; may be unstable but useful.
  --use_chaos_anchors   Use chaos anchors to massively speed up alignments; DNA only.
  --minimum_anchor_distance Minimum chaos anchor distance.
  --maximum_anchor_distance Maximum chaos anchor distance.
  --skip_anchor_distance Chaos anchor skip distance.
  --drop_anchor_distance Chaos anchor drop distance.
  --output_ancestors    Output ancestral sequences and probability profiles; note
                        additional files.
  --noise_level         Noise level; progress and debugging information.
  --stay_quiet          Stay quiet; disable all progress information.
  --random_seed         Set seed for random number generator; not recommended.

[General]
  -h, --help            Show this help message and exit.
  --asyncjob            Forces to make an asynchronous query.
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
                        https://www.ebi.ac.uk/Tools/services/rest/prank

Synchronous job:
  The results/errors are returned as soon as the job is finished.
  Usage: python prank.py --email <your@email.com> [options...] <SeqFile|SeqID(s)>
  Returns: results as an attachment

Asynchronous job:
  Use this if you want to retrieve the results at a later time. The results
  are stored for up to 24 hours.
  Usage: python prank.py --asyncjob --email <your@email.com> [options...] <SeqFile|SeqID(s)>
  Returns: jobid

Check status of Asynchronous job:
  Usage: python prank.py --status --jobid <jobId>

Retrieve job data:
  Use the jobid to query for the status of the job. If the job is finished,
  it also returns the results/errors.
  Usage: python prank.py --polljob --jobid <jobId> [--outfile string]
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
    if len(args) == 1 and "true" not in args and "false" not in args:
        if os.path.exists(args[0]):  # Read file into content
            params[u'sequence'] = readFile(args[0])
        else:  # Argument is a sequence id
            params[u'sequence'] = args[0]
    elif len(args) == 2 and "true" not in args and "false" not in args:
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

    if options.data_file:
        params['data_file'] = options.data_file
    

    if options.tree_file:
        params['tree_file'] = options.tree_file
    

    if not options.do_njtree:
        params['do_njtree'] = 'false'
    if options.do_njtree:
        params['do_njtree'] = options.do_njtree
    

    if not options.do_clustalw_tree:
        params['do_clustalw_tree'] = 'false'
    if options.do_clustalw_tree:
        params['do_clustalw_tree'] = options.do_clustalw_tree
    

    if options.model_file:
        params['model_file'] = options.model_file
    

    if not options.output_format:
        params['output_format'] = '8'
    if options.output_format:
        params['output_format'] = options.output_format
    

    if not options.trust_insertions:
        params['trust_insertions'] = 'false'
    if options.trust_insertions:
        params['trust_insertions'] = options.trust_insertions
    

    if not options.show_insertions_with_dots:
        params['show_insertions_with_dots'] = 'false'
    if options.show_insertions_with_dots:
        params['show_insertions_with_dots'] = options.show_insertions_with_dots
    

    if not options.use_log_space:
        params['use_log_space'] = 'false'
    if options.use_log_space:
        params['use_log_space'] = options.use_log_space
    

    if not options.use_codon_model:
        params['use_codon_model'] = 'false'
    if options.use_codon_model:
        params['use_codon_model'] = options.use_codon_model
    

    if not options.translate_DNA:
        params['translate_DNA'] = 'false'
    if options.translate_DNA:
        params['translate_DNA'] = options.translate_DNA
    

    if not options.mt_translate_DNA:
        params['mt_translate_DNA'] = 'false'
    if options.mt_translate_DNA:
        params['mt_translate_DNA'] = options.mt_translate_DNA
    

    if options.gap_rate:
        params['gap_rate'] = options.gap_rate
    

    if options.gap_extension:
        params['gap_extension'] = options.gap_extension
    

    if options.tn93_kappa:
        params['tn93_kappa'] = options.tn93_kappa
    

    if options.tn93_rho:
        params['tn93_rho'] = options.tn93_rho
    

    if options.guide_pairwise_distance:
        params['guide_pairwise_distance'] = options.guide_pairwise_distance
    

    if options.max_pairwise_distance:
        params['max_pairwise_distance'] = options.max_pairwise_distance
    

    if options.branch_length_scaling:
        params['branch_length_scaling'] = options.branch_length_scaling
    

    if options.branch_length_fixed:
        params['branch_length_fixed'] = options.branch_length_fixed
    

    if options.branch_length_maximum:
        params['branch_length_maximum'] = options.branch_length_maximum
    

    if not options.use_real_branch_lengths:
        params['use_real_branch_lengths'] = 'false'
    if options.use_real_branch_lengths:
        params['use_real_branch_lengths'] = options.use_real_branch_lengths
    

    if not options.do_no_posterior:
        params['do_no_posterior'] = 'false'
    if options.do_no_posterior:
        params['do_no_posterior'] = options.do_no_posterior
    

    if not options.run_once:
        params['run_once'] = 'false'
    if options.run_once:
        params['run_once'] = options.run_once
    

    if not options.run_twice:
        params['run_twice'] = 'false'
    if options.run_twice:
        params['run_twice'] = options.run_twice
    

    if not options.penalise_terminal_gaps:
        params['penalise_terminal_gaps'] = 'false'
    if options.penalise_terminal_gaps:
        params['penalise_terminal_gaps'] = options.penalise_terminal_gaps
    

    if not options.do_posterior_only:
        params['do_posterior_only'] = 'false'
    if options.do_posterior_only:
        params['do_posterior_only'] = options.do_posterior_only
    

    if not options.use_chaos_anchors:
        params['use_chaos_anchors'] = 'false'
    if options.use_chaos_anchors:
        params['use_chaos_anchors'] = options.use_chaos_anchors
    

    if options.minimum_anchor_distance:
        params['minimum_anchor_distance'] = options.minimum_anchor_distance
    

    if options.maximum_anchor_distance:
        params['maximum_anchor_distance'] = options.maximum_anchor_distance
    

    if options.skip_anchor_distance:
        params['skip_anchor_distance'] = options.skip_anchor_distance
    

    if options.drop_anchor_distance:
        params['drop_anchor_distance'] = options.drop_anchor_distance
    

    if not options.output_ancestors:
        params['output_ancestors'] = 'false'
    if options.output_ancestors:
        params['output_ancestors'] = options.output_ancestors
    

    if options.noise_level:
        params['noise_level'] = options.noise_level
    

    if not options.stay_quiet:
        params['stay_quiet'] = 'false'
    if options.stay_quiet:
        params['stay_quiet'] = options.stay_quiet
    

    if options.random_seed:
        params['random_seed'] = options.random_seed
    


    # Submit the job
    jobId = serviceRun(options.email, options.title, params)
    if options.asyncjob: # Async mode
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
