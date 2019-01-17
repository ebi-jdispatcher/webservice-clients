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
#  WSDbfetch (REST) using urllib
#
# For further information see:
# https://www.ebi.ac.uk/Tools/webservices/
#
###############################################################################

from __future__ import print_function

import os
import sys
import time
import json
import platform
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

# Service base URL
baseUrl = 'https://www.ebi.ac.uk/Tools/dbfetch/dbfetch'
version = u'2019-01-17 15:15'

# Output level
outputLevel = 1
# Debug level
debugLevel = 0

# Usage message


def print_usage():
    print("""\
EMBL-EBI EMBOSS WSDbfetch Python Client:

Dbfetch service enables database entry retrieval given a set of entry
identifiers, and a required data format.

Usage:
  python dbfetch.py <method> [arguments...] [--baseUrl <baseUrl>]

A number of methods are available:
  getSupportedDBs       List available databases.
  getSupportedFormats   List available databases with formats.
  getSupportedStyles    List available databases with styles.
  getDbFormats          List formats for a specifed database. Requires <dbName>.
  getFormatStyles       List styles for a specified database and format.
                        Requires <dbName> and <dbFormat>.
  fetchData             Retrive an database entry. See below for details of arguments.
  fetchBatch            Retrive database entries. See below for details of arguments.

Fetching an entry: fetchData
  python dbfetch.py fetchData <dbName:id> [format [style]]

  dbName:id  database name and entry ID or accession (e.g. UNIPROT:WAP_RAT),
             use @fileName to read identifiers from a file.
  format     format to retrive (e.g. uniprot)
  style      style to retrive (e.g. raw)


Fetching entries: fetchBatch
  python dbfetch.py fetchBatch <dbName> <idList> [format [style]]

  dbName     database name (e.g. UNIPROT)
  idList     list of entry IDs or accessions (e.g. 1433T_RAT,WAP_RAT).
             Maximum of 200 IDs or accessions.
  format     format to retrive (e.g. uniprot)
  style      style to retrive (e.g. raw)

Further information:
  https://www.ebi.ac.uk/Tools/webservices and
    https://github.com/ebi-wp/webservice-clients

Support/Feedback:
  https://www.ebi.ac.uk/support/""")


other_usage = """
      %prog fetchBatch <dbName> <id1,id2,...> [formatName [styleName]] [options...]
      %prog fetchData <dbName:id> [formatName [styleName]] [options...]
      %prog getDbFormats <dbName> [options...]
      %prog getFormatStyles <dbName> <formatName> [options...]
      %prog getSupportedDBs [options...]
      %prog getSupportedFormats [options...]
      %prog getSupportedStyles [options...]"""

description = """Fetch database entries using entry identifiers. For more information on dbfetch
refer to https://www.ebi.ac.uk/Tools/dbfetch/"""

epilog = """\
Further information:
  https://www.ebi.ac.uk/Tools/webservices
Support/Feedback:
  https://www.ebi.ac.uk/support/"""


# Debug print
def printDebugMessage(functionName, message, level):
    if (level <= debugLevel):
        print(sys.stderr, '[' + functionName + '] ' + message)


# User-agent for request.
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
    printDebugMessage('restRequest', 'Begin', 11)
    printDebugMessage('restRequest', 'url: ' + url, 11)
    try:
        user_agent = getUserAgent()
        http_headers = {
            'User-Agent': user_agent,
            'Accept-Encoding': 'gzip'
        }
        req = Request(url, None, http_headers)
        resp = urlopen(req)
        encoding = resp.info().get('Content-Encoding')
        result = None
        if encoding == None or encoding == 'identity':
            result = resp.read().decode('utf-8')
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
    except HTTPError as ex:
        print(ex.read())
        raise
    printDebugMessage('restRequest', 'result: ' + result, 11)
    printDebugMessage('restRequest', 'End', 11)
    return result


# Get database details.
def getDatabaseInfoList():
    printDebugMessage('getDatabaseInfoList', 'Begin', 11)
    requestUrl = baseUrl + '/dbfetch.databases?style=json'
    jsonDoc = restRequest(requestUrl)
    printDebugMessage('getDatabaseInfoList', 'json: ' + jsonDoc, 21)
    doc = json.loads(jsonDoc)
    databaseInfoList = [doc[db] for db in doc]
    printDebugMessage('getDatabaseInfoList', 'End', 11)
    return databaseInfoList

# Get list of database names.
def getSupportedDbs():
    printDebugMessage('getSupportedDbs', 'Begin', 1)
    dbList = []
    dbInfoList = getDatabaseInfoList()
    for dbInfo in dbInfoList:
        dbList.append(str(dbInfo["name"]))
    printDebugMessage('getSupportedDbs', 'End', 1)
    return dbList

# Get list of database names + formats.
def getSupportedFormats():
    printDebugMessage('getSupportedFormats', 'Begin', 1)
    dbList = []
    dbInfoList = getDatabaseInfoList()
    for dbInfo in dbInfoList:
        dbList.append("%s\t%s" % (str(dbInfo["name"]),
                                  ",".join([f["name"] for f in dbInfo["formatInfoList"]])))
    printDebugMessage('getSupportedFormats', 'End', 1)
    return dbList

def getSupportedStyles():
    printDebugMessage('getSupportedStyles', 'Begin', 1)
    dbList = []
    dbInfoList = getDatabaseInfoList()
    for dbInfo in dbInfoList:
        for format in dbInfo["formatInfoList"]:
            dbList.append("%s\t%s\t%s" % (str(dbInfo["name"]), format["name"],
                                          ",".join([s["name"] for s in format["styleInfoList"]])))
    printDebugMessage('getSupportedStyles', 'End', 1)
    return dbList


# Get list of formats for a database.
def getDbFormats(db):
    printDebugMessage('getDbFormats', 'Begin', 1)
    printDebugMessage('getDbFormats', 'db: ' + db, 2)
    formatNameList = []
    dbInfoList = getDatabaseInfoList()
    for dbInfo in dbInfoList:
        if db == dbInfo["name"]:
            formatNameList = [f["name"] for f in dbInfo["formatInfoList"]]
    printDebugMessage('getDbFormats', 'End', 1)
    return formatNameList


# Get list of styles for a format of a database.
def getFormatStyles(db, format):
    printDebugMessage('getFormatStyles', 'Begin', 1)
    styleNameList = []
    dbInfoList = getDatabaseInfoList()
    for dbInfo in dbInfoList:
        if db == dbInfo["name"]:
            for f in dbInfo["formatInfoList"]:
                if format == f["name"]:
                    for s in f["styleInfoList"]:
                        styleNameList = [s["name"] for s in f["styleInfoList"]]
    printDebugMessage('getFormatStyles', 'End', 1)
    return styleNameList


# Get an entry.
def fetchData(query, format='default', style='raw'):
    printDebugMessage('fetchData', 'Begin', 1)
    if query.startswith('@'):
        result = []
        if os.path.exists(query.lstrip('@')):
            with open(query.lstrip('@'), 'r') as inlines:
                for line in inlines:
                    requestUrl = baseUrl + '/' + line.strip().replace(':', '/') + '/' + \
                        format + '?style=' + style
                    result.append(restRequest(requestUrl))
        else:
            print("Error: unable to open file %s (No such file or directory)" % query)
        result = "".join(result)
    else:
        requestUrl = baseUrl + '/' + \
            query.replace(':', '/') + '/' + format + '?style=' + style
        result = restRequest(requestUrl)
    printDebugMessage('fetchData', 'End', 1)
    return result


# Get a set of entries.
def fetchBatch(db, idListStr, format='default', style='raw'):
    printDebugMessage('fetchBatch', 'Begin', 1)
    requestUrl = baseUrl + '/' + db + '/' + \
        idListStr + '/' + format + '?style=' + style
    result = restRequest(requestUrl)
    printDebugMessage('fetchBatch', 'End', 1)
    return result


if __name__ == '__main__':
    # Process command-line options
    # parser = OptionParser(usage=usage, description=description, epilog=epilog, version=version)
    parser = OptionParser(add_help_option=False)
    parser.add_option('-h', '--help', action='store_true',
                      help='Shows this message and exit.')
    parser.add_option('--quiet', action='store_true',
                      help='decrease output level')
    parser.add_option('--verbose', action='store_true',
                      help='increase output level')
    parser.add_option('--version', action='store_true',
                      help='Prints out the version of the Client and exit.')
    parser.add_option('--baseUrl', default=baseUrl,
                      help='base URL for dbfetch')
    parser.add_option('--debugLevel', type='int',
                      default=debugLevel, help='debug output level')
    (options, args) = parser.parse_args()

    # Print Client version
    if options.version:
        print("Revision: %s" % version)
        sys.exit()

    # No arguments, print usage
    if len(args) < 1:
        print_usage()
        sys.exit()

    if options.help:
        print_usage()
        sys.exit()

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

    # List databases.
    if args[0] == 'getSupportedDBs':
        dbNameList = getSupportedDbs()
        for dbName in dbNameList:
            print(dbName)
    elif args[0] == 'getSupportedFormats':
        dbNameFormatList = getSupportedFormats()
        for dbNameFormat in dbNameFormatList:
            print(dbNameFormat)
    elif args[0] == 'getSupportedStyles':
        dbNameStyleList = getSupportedStyles()
        for dbNameStyle in dbNameStyleList:
            print(dbNameStyle)
    # List formats for a database.
    elif args[0] == 'getDbFormats':
        if len(args) > 1:
            formatNameList = getDbFormats(args[1])
            if len(formatNameList) > 0:
                for formatName in formatNameList:
                    print(formatName)
            else:
                print('Database not found')
        else:
            print('<dbName> needed. See --help for more information.')
    # List formats for a database.
    elif args[0] == 'getFormatStyles':
        if len(args) > 2:
            styleNameList = getFormatStyles(args[1], args[2])
            if len(styleNameList) > 0:
                for styleName in styleNameList:
                    print(styleName)
            else:
                print('Database and format not found')
        else:
            print('<dbName> and <dbFormat> needed. See --help for more information.')
    # Fetch an entry
    elif args[0] == 'fetchData' and len(args) > 1:
        if len(args) > 3:
            print(fetchData(args[1], args[2], args[3]))
        elif len(args) > 2:
            print(fetchData(args[1], args[2]))
        else:
            print(fetchData(args[1]))
    # Fetch a set of entries
    elif args[0] == 'fetchBatch' and len(args) > 2:
        if len(args) > 4:
            print(fetchBatch(args[1], args[2], args[3], args[4]))
        elif len(args) > 3:
            print(fetchBatch(args[1], args[2], args[3]))
        else:
            print(fetchBatch(args[1], args[2]))
    # Unknown argument combination, display usage
    else:
        print('Error: unrecognised argument combination')
        print_usage()
