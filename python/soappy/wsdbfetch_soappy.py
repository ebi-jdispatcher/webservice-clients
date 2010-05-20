#!/usr/bin/env python
# $Id$
# ======================================================================
# WSDbfetch document/literal SOAP service, Python client using SOAPpy.
#
# Tested with:
#   Python 2.6.5 with SOAPpy 0.12.0 (Ubuntu 10.04)
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
from SOAPpy import WSDL

# Suppress all deprecation warnings (not recommended for development)
warnings.simplefilter('ignore', DeprecationWarning)

# Output level
outputLevel = 1
# Debug level
debugLevel = 0

# Usage message
usage = """Usage:
  %prog <method> [arguments...] [options...]

A number of methods are available:

  getSupportedDBs - list available databases
  getSupportedFormats - list available databases with formats
  getSupportedStyles - list available databases with styles
  getDbFormats - list formats for a specifed database
  getFormatStyles - list styles for a specified database and format
  fetchData - retrive an database entry. See below for details of arguments.
  fetchBatch - retrive database entries. See below for details of arguments.

Fetching an entry: fetchData

  $scriptName fetchData <dbName:id> [format [style]]

  dbName:id  database name and entry ID or accession (e.g. UNIPROT:WAP_RAT)
  format     format to retrive (e.g. uniprot)
  style      style to retrive (e.g. raw)

Fetching entries: fetchBatch

  $scriptName fetchBatch <dbName> <idList> [format [style]]

  dbName     database name (e.g. UNIPROT)
  idList     list of entry IDs or accessions (e.g. 1433T_RAT,WAP_RAT).
             Maximum of 200 IDs or accessions. "-" for STDIN.
  format     format to retrive (e.g. uniprot)
  style      style to retrive (e.g. raw)"""

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

# Create the service interface
dbfetch = WSDL.Proxy(options.WSDL)
# Configure HTTP proxy from OS environment (e.g. http_proxy="http://proxy.example.com:8080")
if os.environ.has_key('http_proxy'):
    http_proxy_conf = os.environ['http_proxy'].replace('http://', '')
elif os.environ.has_key('HTTP_PROXY'):
    http_proxy_conf = os.environ['HTTP_PROXY'].replace('http://', '')
else:
    http_proxy_conf = None
dbfetch.soapproxy.http_proxy = http_proxy_conf

# If required enable SOAP message trace
if options.trace:
    dbfetch.soapproxy.config.dumpSOAPOut = 1
    dbfetch.soapproxy.config.dumpSOAPIn = 1

# Debug print
def printDebugMessage(functionName, message, level):
    if(level <= debugLevel):
        print >>sys.stderr, '[' + functionName + '] ' + message

# Get list of supported database names.
def soapGetSupportedDBs():
    dbList = dbfetch.getSupportedDBs()
    return dbList

# Print list of supported database names.
def printGetSupportedDBs():
    dbNameList = soapGetSupportedDBs()
    for dbName in dbNameList:
        print dbName

# Get list of supported database and format names.
def soapGetSupportedFormats():
    dbList = dbfetch.getSupportedFormats()
    return dbList

# Print list of supported database and format names.
def printGetSupportedFormats():
    dbList = soapGetSupportedFormats()
    for db in dbList:
        print db

# Get list of supported database and style names.
def soapGetSupportedStyles():
    dbList = dbfetch.getSupportedStyles()
    return dbList

# Print list of supported database and style names.
def printGetSupportedStyles():
    dbList = soapGetSupportedStyles()
    for db in dbList:
        print db

# Get list of formats available for a database.
def soapGetDbFormats(dbName):
    formatList = dbfetch.getDbFormats(dbName)
    return formatList

# Print list of formats available for a database.
def printGetDbFormats(dbName):
    formatNameList = soapGetDbFormats(dbName)
    for formatName in formatNameList:
        print formatName

# Get list of available styles for a format of a database.
def soapGetFormatStyles(dbName, formatName):
    styleList = dbfetch.getFormatStyles(dbName, formatName)
    return styleList

# Print list of available styles for a format of a database.
def printGetFormatStyles(dbName, formatName):
    styleNameList = soapGetFormatStyles(dbName, formatName)
    for styleName in styleNameList:
        print styleName

# Fetch an entry.
def soapFetchData(query, formatName, styleName):
    entryStr = dbfetch.fetchData(query, formatName, styleName)
    return entryStr

# Print an entry.
def printFetchData(query, formatName, styleName):
    entryStr = soapFetchData(query, formatName, styleName)
    print entryStr

# Fetch a set of entries.
def soapFetchBatch(dbName, idListStr, formatName, styleName):
    entriesStr = dbfetch.fetchBatch(dbName, idListStr, formatName, styleName)
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
