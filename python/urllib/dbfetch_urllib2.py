#!/usr/bin/env python

# ======================================================================
#
# Copyright 2009-2018 EMBL - European Bioinformatics Institute
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
# WSDbfetch (REST) using urllib2 and xmltramp
# (http://www.aaronsw.com/2002/xmltramp/).
#
# Tested with:
#  Python 2.5.2 (Ubuntu 8.04 LTS)
#  Python 2.6.5 (Ubuntu 10.04 LTS)
#
# See:
# http://www.ebi.ac.uk/Tools/webservices/services/dbfetch_rest
# http://www.ebi.ac.uk/Tools/webservices/tutorials/python
# ======================================================================

# Load libraries
import platform, os, sys, urllib2
from xmltramp2 import xmltramp
from optparse import OptionParser
from gzip import GzipFile
from StringIO import StringIO

# Service base URL
baseUrl = 'http://www.ebi.ac.uk/Tools/dbfetch/dbfetch'

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
epilog = """For further information about the WSDbfetch (SOAP) web service, see
http://www.ebi.ac.uk/Tools/webservices/services/dbfetch."""
version = "$Id$"
# Process command-line options
parser = OptionParser(usage=usage, description=description, epilog=epilog, version=version)
parser.add_option('--quiet', action='store_true', help='decrease output level')
parser.add_option('--verbose', action='store_true', help='increase output level')
parser.add_option('--baseUrl', default=baseUrl, help='base URL for dbfetch')
parser.add_option('--debugLevel', type='int', default=debugLevel, help='debug output level')
(options, args) = parser.parse_args()

# Increase output level.
if options.verbose:
    outputLevel += 1

# Decrease output level.
if options.quiet:
    outputLevel -= 1

# Debug level.
if options.debugLevel:
    debugLevel = options.debugLevel

# Base URL for service.
if options.baseUrl:
    baseUrl = options.baseUrl


# Debug print
def printDebugMessage(functionName, message, level):
    if (level <= debugLevel):
        print >> sys.stderr, '[' + functionName + '] ' + message


# User-agent for request.
def getUserAgent():
    printDebugMessage('getUserAgent', 'Begin', 11)
    urllib_agent = 'Python-urllib/%s' % urllib2.__version__
    clientRevision = '$Revision$'
    clientVersion = '0'
    if len(clientRevision) > 11:
        clientVersion = clientRevision[11:-2]
    user_agent = 'EBI-Sample-Client/%s (%s; Python %s; %s) %s' % (
        clientVersion, os.path.basename(__file__),
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
    try:
        user_agent = getUserAgent()
        http_headers = {
            'User-Agent': user_agent,
            'Accept-Encoding': 'gzip'
        }
        req = urllib2.Request(url, None, http_headers)
        resp = urllib2.urlopen(req)
        encoding = resp.info().getheader('Content-Encoding')
        result = None
        if encoding == None or encoding == 'identity':
            result = resp.read()
        elif encoding == 'gzip':
            result = resp.read()
            printDebugMessage('restRequest', 'result: ' + result, 21)
            gz = GzipFile(
                fileobj=StringIO(result),
                mode="r"
            )
            result = gz.read()
        else:
            raise Exception('Unsupported Content-Encoding')
        resp.close()
    except urllib2.HTTPError, ex:
        print ex.read()
        raise
    printDebugMessage('restRequest', 'result: ' + result, 11)
    printDebugMessage('restRequest', 'End', 11)
    return result


# Get database details.
def getDatabaseInfoList():
    printDebugMessage('getDatabaseInfoList', 'Begin', 11)
    requestUrl = baseUrl + '/dbfetch.databases?style=xml'
    xmlDoc = restRequest(requestUrl)
    printDebugMessage('getDatabaseInfoList', 'xmlDoc: ' + xmlDoc, 21)
    doc = xmltramp.parse(xmlDoc)
    databaseInfoList = doc['databaseInfo':]
    printDebugMessage('getDatabaseInfoList', 'End', 11)
    return databaseInfoList


# Get list of database names.
def getSupportedDbs():
    printDebugMessage('getSupportedDbs', 'Begin', 1)
    dbList = []
    dbInfoList = getDatabaseInfoList()
    for dbInfo in dbInfoList:
        dbList.append(str(dbInfo.name))
    printDebugMessage('getSupportedDbs', 'End', 1)
    return dbList


# Check if a databaseInfo matches a database name.
def is_database(dbInfo, dbName):
    printDebugMessage('is_database', 'Begin', 11)
    retVal = False
    if str(dbInfo.name) == dbName:
        retVal = True
    else:
        for dbAlias in dbInfo.aliasList:
            if str(dbAlias) == dbName:
                retVal = True
    printDebugMessage('is_database', 'retVal: ' + str(retVal), 11)
    printDebugMessage('is_database', 'End', 11)
    return retVal


# Get list of formats for a database.
def getDbFormats(db):
    printDebugMessage('getDbFormats', 'Begin', 1)
    printDebugMessage('getDbFormats', 'db: ' + db, 2)
    formatNameList = []
    dbInfoList = getDatabaseInfoList()
    for dbInfo in dbInfoList:
        if is_database(dbInfo, db):
            for formatInfo in dbInfo.formatInfoList:
                formatNameList.append(str(formatInfo.name))
    printDebugMessage('getDbFormats', 'End', 1)
    return formatNameList


# Check if a formatInfo matches a format name.
def is_format(formatInfo, formatName):
    printDebugMessage('is_format', 'Begin', 11)
    retVal = False
    if str(formatInfo.name) == formatName:
        retVal = True
    else:
        for formatAlias in formatInfo.aliases:
            if str(formatAlias) == formatName:
                retVal = True
    printDebugMessage('is_format', 'retVal: ' + str(retVal), 12)
    printDebugMessage('is_format', 'End', 11)
    return retVal


# Get list of styles for a format of a database.
def getFormatStyles(db, format):
    printDebugMessage('getFormatStyles', 'Begin', 1)
    styleNameList = []
    dbInfoList = getDatabaseInfoList()
    for dbInfo in dbInfoList:
        if is_database(dbInfo, db):
            for formatInfo in dbInfo.formatInfoList:
                if is_format(formatInfo, format):
                    for styleInfo in formatInfo.styleInfoList:
                        styleNameList.append(str(styleInfo.name))
    printDebugMessage('getFormatStyles', 'End', 1)
    return styleNameList


# Get an entry.
def fetchData(query, format='default', style='raw'):
    printDebugMessage('fetchData', 'Begin', 1)
    requestUrl = baseUrl + '/' + query.replace(':', '/') + '/' + format + '?style=' + style
    result = restRequest(requestUrl)
    printDebugMessage('fetchData', 'End', 1)
    return result


# Get a set of entries.
def fetchBatch(db, idListStr, format='default', style='raw'):
    printDebugMessage('fetchBatch', 'Begin', 1)
    requestUrl = baseUrl + '/' + db + '/' + idListStr + '/' + format + '?style=' + style
    result = restRequest(requestUrl)
    printDebugMessage('fetchBatch', 'End', 1)
    return result


# No arguments, print usage
if len(args) < 1:
    parser.print_help()
# List databases.
elif args[0] == 'getSupportedDBs':
    dbNameList = getSupportedDbs()
    for dbName in dbNameList:
        print dbName
# List formats for a database.
elif args[0] == 'getDbFormats' and len(args) > 1:
    formatNameList = getDbFormats(args[1])
    if len(formatNameList) > 0:
        for formatName in formatNameList:
            print formatName
    else:
        print 'Database not found'
# List formats for a database.
elif args[0] == 'getFormatStyles' and len(args) > 2:
    styleNameList = getFormatStyles(args[1], args[2])
    if len(styleNameList) > 0:
        for styleName in styleNameList:
            print styleName
    else:
        print 'Database and format not found'
# Fetch an entry
elif args[0] == 'fetchData' and len(args) > 1:
    if len(args) > 3:
        print fetchData(args[1], args[2], args[3])
    elif len(args) > 2:
        print fetchData(args[1], args[2])
    else:
        print fetchData(args[1])
# Fetch a set of entries
elif args[0] == 'fetchBatch' and len(args) > 2:
    if len(args) > 4:
        print fetchBatch(args[1], args[2], args[3], args[4])
    elif len(args) > 3:
        print fetchBatch(args[1], args[2], args[3])
    else:
        print fetchBatch(args[1], args[2])
# Unknown argument combination, display usage
else:
    print 'Error: unrecognised argument combination'
    parser.print_help()
