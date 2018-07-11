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
# WSDbfetch document/literal SOAP service, Python client using SOAPpy.
#
# Tested with:
#   Python 2.5.2 with SOAPpy 0.12.0 (Ubuntu 8.04 LTS)
#   Python 2.6.5 with SOAPpy 0.12.0 (Ubuntu 10.04 LTS)
#
# See:
# http://www.ebi.ac.uk/Tools/webservices/services/dbfetch
# http://www.ebi.ac.uk/Tools/webservices/tutorials/python
# ======================================================================
# WSDL URL for service.
wsdlUrl = 'http://www.ebi.ac.uk/ws/services/WSDbfetchDoclit?wsdl'

# Load libraries
import platform, os, SOAPpy, sys
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

# Set the client user-agent.
clientRevision = '$Revision: 1692 $'
clientVersion = '0'
if len(clientRevision) > 11:
    clientVersion = clientRevision[11:-2] 
userAgent = 'EBI-Sample-Client/%s (%s; Python %s; %s) %s' % (
    clientVersion, os.path.basename( __file__ ),
    platform.python_version(), platform.system(),
    SOAPpy.Client.SOAPUserAgent()
)
# Function to return User-agent.
def SOAPUserAgent():
    return userAgent
# Redefine default User-agent function to return custom User-agent.
SOAPpy.Client.SOAPUserAgent = SOAPUserAgent
printDebugMessage('main', 'User-agent: ' + SOAPpy.Client.SOAPUserAgent(), 1)

# Create the service interface
printDebugMessage('main', 'WSDL: ' + options.WSDL, 1)
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
