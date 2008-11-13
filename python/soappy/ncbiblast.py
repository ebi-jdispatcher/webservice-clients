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
wsdlUrl = ''

# Load libraries
import os
import sys
import time
from SOAPpy import WSDL
from optparse import OptionParser

# Usage message
usage = "Usage: %prog [options...] [seqFile]"
# Process command-line options
parser = OptionParser(usage=usage)
# General options
parser.add_option('--email', help='E-mail address')
parser.add_option('--outfile', help='File name for results')
parser.add_option('--polljob', action="store_true", help='Get job result')
parser.add_option('--status', action="store_true", help='Get job status')
parser.add_option('--jobid', help='Job identifier')
parser.add_option('--trace', action="store_true", help='Show SOAP messages')
# Tool specific options
parser.add_option('--sequence', help='Input sequence file name')

(options, args) = parser.parse_args()

# Create the service interface
server = WSDL.Proxy(wsdlUrl)

# If required enable SOAP message trace
if options.trace:
    server.soapproxy.config.dumpSOAPOut = 1
    server.soapproxy.config.dumpSOAPIn = 1

# Client-side poll
def clientPoll(jobId):
    result = 'PENDING'
    while result == 'RUNNING' or result == 'PENDING':
        result = server.checkStatus(jobId)
        print >>sys.stderr, result
        if result == 'RUNNING' or result == 'PENDING':
            time.sleep(15)

# Get result for a jobid
def getResult(jobId):
    # Check status and wait if necessary
    clientPoll(jobId)
    # Get available result types
    resultTypes = server.getResults(jobId)
    for resultType in resultTypes:
        # Get the result
        result = server.poll(jobId, resultType.type)
        # Derive the filename for the result
        if options.outfile:
            filename = options.outfile + '.' + resultType.ext
        else:
            filename = jobId + '.' + resultType.ext
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

# Get results
if options.polljob and options.jobid:
    getResult(options.jobid)
# Get status
elif options.status and options.jobid:
    status = server.checkStatus(options.jobid)
    print status
# Submit job
elif options.email and not options.jobid:
    if len(args) > 0:
        if os.access(args[0], os.R_OK): # Read file into content
            seqData = readFile(args[0])
            content = [{'type':'sequence', 'content':seqData}]
        else: # Argument is a sequence id
            content = [{'type':'sequence', 'content':args[0]}]
    elif options.sequence: # Specified via option
        if os.access(options.sequence, os.R_OK): # Read file into content
            seqData = readFile(options.sequence)
            content = [{'type':'sequence', 'content':seqData}]
        else: # Argument is a sequence id
            content = [{'type':'sequence', 'content':options.sequence}]
    iprscan_params = {
        'email':options.email,
        'app':options.app,
        'seqtype':options.seqtype,
        'outformat':options.outformat
        }
    # Booleans need to be represented as 1/0 rather than True/False
    iprscan_params['async'] = 1
    if options.crc:
        iprscan_params['crc'] = 1
    else:
        iprscan_params['crc'] = 0
    if options.goterms:
        iprscan_params['goterms'] = 1
    else:
        iprscan_params['goterms'] = 0
    # Submit the job
    jobid = server.runInterProScan(params=iprscan_params, content=content)
    if options.async: # Async mode
        print jobid
    else: # Sync mode
        time.sleep(5)
        getResult(jobid)
else:
    print 'Error: unrecognised argument combination'
    parser.print_help()
