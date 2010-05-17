#!/usr/bin/env python
# $Id$
# ======================================================================
# WSDbfetch document/literal SOAP service, Python client using suds.
#
# Tested with:
#   Python 2.6.5 with suds 0.3.9 (Ubuntu 10.04)
#
# See:
# http://www.ebi.ac.uk/Tools/webservices/services/dbfetch
# http://www.ebi.ac.uk/Tools/webservices/tutorials/python
# ======================================================================
# WSDL URL for service.
wsdlUrl = 'http://www.ebi.ac.uk/ws/services/WSDbfetchDoclit?wsdl'

# Load libraries
import os
import sys
import time
import warnings
from optparse import OptionParser
from suds.client import Client
import logging

logging.basicConfig(level=logging.INFO)

# Output level
outputLevel = 1
# Debug level
debugLevel = 0

# Usage message
usage = "Usage: %prog [options...] [seqFile]"
# Process command-line options
parser = OptionParser(usage=usage)
parser.add_option('--quiet', action='store_true', help='decrease output level')
parser.add_option('--verbose', action='store_true', help='increase output level')
parser.add_option('--trace', action="store_true", help='show SOAP messages')
parser.add_option('--WSDL', default=wsdlUrl, help='WSDL URL for service')
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

# If required enable SOAP message trace
if options.trace:
    logging.getLogger('suds.client').setLevel(logging.DEBUG)

# Create the service interface
dbfetch = Client(wsdlUrl)
if outputLevel > 1:
    print dbfetch

# Configure HTTP proxy from OS environment (e.g. http_proxy="http://proxy.example.com:8080")
proxyOpts = dict()
if os.environ.has_key('http_proxy'):
    proxyOpts['http'] = os.environ['http_proxy'].replace('http://', '')
elif os.environ.has_key('HTTP_PROXY'):
    proxyOpts['http'] = os.environ['HTTP_PROXY'].replace('http://', '')
if 'http' in proxyOpts:
    client.set_options(proxy=proxyOpts)

# Debug print
def printDebugMessage(functionName, message, level):
    if(level <= debugLevel):
        print >>sys.stderr, '[' + functionName + '] ' + message

# Get list of supported database names.
def soapGetSupportedDBs():
    dbList = dbfetch.service.getSupportedDBs()
    return dbList

# Print list of supported database names.
def printGetSupportedDBs():
    dbNameList = soapGetSupportedDBs()
    for dbName in dbNameList:
        print dbName

# Get list of supported database and format names.
def soapGetSupportedFormats():
    dbList = dbfetch.service.getSupportedFormats()
    return dbList

# Print list of supported database and format names.
def printGetSupportedFormats():
    dbList = soapGetSupportedFormats()
    for db in dbList:
        print db

# Get list of supported database and style names.
def soapGetSupportedStyles():
    dbList = dbfetch.service.getSupportedStyles()
    return dbList

# Print list of supported database and style names.
def printGetSupportedStyles():
    dbList = soapGetSupportedStyles()
    for db in dbList:
        print db

# Get list of formats available for a database.
def soapGetDbFormats(dbName):
    formatList = dbfetch.service.getDbFormats(dbName)
    return formatList

# Print list of formats available for a database.
def printGetDbFormats(dbName):
    formatNameList = soapGetDbFormats(dbName)
    for formatName in formatNameList:
        print formatName

# Get list of available styles for a format of a database.
def soapGetFormatStyles(dbName, formatName):
    styleList = dbfetch.service.getFormatStyles(dbName, formatName)
    return styleList

# Print list of available styles for a format of a database.
def printGetFormatStyles(dbName, formatName):
    styleNameList = soapGetFormatStyles(dbName, formatName)
    for styleName in styleNameList:
        print styleName

# Fetch an entry.
def soapFetchData(query, formatName, styleName):
    entryStr = dbfetch.service.fetchData(query, formatName, styleName)
    return entryStr

# Print an entry.
def printFetchData(query, formatName, styleName):
    entryStr = soapFetchData(query, formatName, styleName)
    print entryStr

# Fetch a set of entries.
def soapFetchBatch(dbName, idListStr, formatName, styleName):
    entriesStr = dbfetch.service.fetchBatch(dbName, idListStr, formatName, styleName)
    return entriesStr

# Print a set of entries.
def printFetchBatch(dbName, idListStr, formatName, styleName):
    entriesStr = soapFetchBatch(dbName, idListStr, formatName, styleName)
    print entriesStr

# Perform actions.
if len(args) < 1:
    parser.print_help()
elif len(args) > 0 and args[0] == 'getSupportedDBs':
    printGetSupportedDBs()
elif len(args) > 0 and args[0] == 'getSupportedFormats':
    printGetSupportedFormats()
elif len(args) > 0 and args[0] == 'getSupportedStyles':
    printGetSupportedStyles()
elif len(args) > 1 and args[0] == 'getDbFormats':
    printGetDbFormats(args[1])
elif len(args) > 2 and args[0] == 'getFormatStyles':
    printGetFormatStyles(args[1], args[2])
elif len(args) > 1 and args[0] == 'fetchData':
    formatName = 'default'
    if len(args) > 2:
        formatName = args[2]
    styleName = 'default'
    if len(args) > 3:
        styleName = args[3]
    printFetchData(args[1], formatName, styleName)
elif len(args) > 2 and args[0] == 'fetchBatch':
    formatName = 'default'
    if len(args) > 3:
        formatName = args[3]
    styleName = 'default'
    if len(args) > 4:
        styleName = args[4]
    printFetchBatch(args[1], args[2], formatName, styleName)
else:
    print 'Error: unrecognised argument combination'
    parser.print_help()
