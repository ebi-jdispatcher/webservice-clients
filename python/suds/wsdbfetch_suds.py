#!/usr/bin/env python
# $Id$
# ======================================================================
# 
# Copyright 2010-2018 EMBL - European Bioinformatics Institute
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
import platform, os, suds, sys, urllib2
import logging
from suds import WebFault
from suds.client import Client
from optparse import OptionParser

# Setup logging
logging.basicConfig(level=logging.INFO)

# Output level
outputLevel = 1
# Debug level
debugLevel = 0

# Usage message
usage = """
  %prog fetchBatch <dbName> <id1,id2,...> [formatName [styleName]] [options...]
  %prog fetchData <dbName:id> [formatName [styleName]] [options...]
  %prog getDbFormats <dbName> [options...]
  %prog getFormatStyles <dbName> <formatName> [options...]
  %prog getSupportedDBs [options...]
  %prog getSupportedFormats [options...]
  %prog getSupportedStyles [options...]"""
description = """Fetch database entries using entry identifiers. For more information on dbfetch 
refer to http://www.ebi.ac.uk/Tools/dbfetch/"""
epilog = """For further information about the WSDbfetch (SOAP) web service, see http://www.ebi.ac.uk/Tools/webservices/services/dbfetch."""
version = "$Id$"
# Process command-line options
parser = OptionParser(usage=usage, description=description, epilog=epilog, version=version)
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

# If required enable SOAP message trace
if options.trace:
    logging.getLogger('suds.client').setLevel(logging.DEBUG)

# Create the service interface
printDebugMessage('main', 'WSDL: ' + options.WSDL, 1)
client = Client(options.WSDL)
if outputLevel > 1:
    print client
dbfetch = client.service

# Set the client user-agent.
clientRevision = '$Revision$'
clientVersion = '0'
if len(clientRevision) > 11:
    clientVersion = clientRevision[11:-2] 
userAgent = 'EBI-Sample-Client/%s (%s; Python %s; %s) suds/%s Python-urllib/%s' % (
    clientVersion, os.path.basename( __file__ ),
    platform.python_version(), platform.system(),
    suds.__version__, urllib2.__version__
)
printDebugMessage('main', 'userAgent: ' + userAgent, 1)
httpHeaders = {'User-agent': userAgent}
client.set_options(headers=httpHeaders)

# Configure HTTP proxy from OS environment (e.g. http_proxy="http://proxy.example.com:8080")
proxyOpts = dict()
if os.environ.has_key('http_proxy'):
    proxyOpts['http'] = os.environ['http_proxy'].replace('http://', '')
elif os.environ.has_key('HTTP_PROXY'):
    proxyOpts['http'] = os.environ['HTTP_PROXY'].replace('http://', '')
if 'http' in proxyOpts:
    client.set_options(proxy=proxyOpts)

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
