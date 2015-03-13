#!/usr/bin/env python
# $Id: dbfetch_urllib2.py 2468 2013-01-25 14:01:01Z hpm $
# ======================================================================
# 
# Copyright 2009-2013 EMBL - European Bioinformatics Institute
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
# EB-eye (REST) using urllib2 and xmltramp 
# (http://www.aaronsw.com/2002/xmltramp/).
#
# Tested with:
#  Python 2.5.2 (Ubuntu 8.04 LTS)
#  Python 2.6.5 (Ubuntu 10.04 LTS)
#
# See:
# http://www.ebi.ac.uk/Tools/webservices/services/eb-eye
# http://www.ebi.ac.uk/Tools/webservices/tutorials/python
# ======================================================================
# Service base URL
baseUrl = 'http://www.ebi.ac.uk/ebisearch/ws/rest'

# Load libraries
import platform, os, sys, urllib2, xmltramp
from optparse import OptionParser
from gzip import GzipFile
from StringIO import StringIO

# Output level
outputLevel = 1
# Debug level
debugLevel = 0

# Usage message
usage = """
  %prog getDomainHierarchy
  %prog getDomainDetails [<domain>]
  %prog getResults <domain> <query> <fields> [<size> [<start> [<fieldurl> [<viewurl> [<sortfield> [<order>]]]]]]
  %prog getFacetedResults <domain> <query> <fields> [<size> [<start> [<fieldurl> [<viewurl> [<sortfield> [<order> [<facetcount> [<facetfields>]]]]]]]]
  %prog getEntries <domain> <entryids> <fields> [<fieldurl> [<viewurl>]]
  %prog getDomainsReferencedInDomain <domain>
  %prog getDomainsReferencedInEntry <domain> <entryid>
  %prog getReferencedEntries <domain> <entryids> <referencedDomain> <fields> [<start> [<size> [<fieldurl> [<viewurl>]]]"""
description = """Search at EMBL-EBI in All results using the EB-eye search engine. For more information on EB-eye 
refer to http://www.ebi.ac.uk/ebisearch/"""
version = "$Id: dbfetch_urllib2.py 2468 2013-01-25 14:01:01Z hpm $"
# Process command-line options
parser = OptionParser(usage=usage, description=description, version=version)
parser.add_option('--quiet', action='store_true', help='decrease output level')
parser.add_option('--verbose', action='store_true', help='increase output level')
parser.add_option('--baseUrl', default=baseUrl, help='base URL for EBI Search')
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
    if(level <= debugLevel):
        print >>sys.stderr, '[' + functionName + '] ' + message

# User-agent for request.
def getUserAgent():
    printDebugMessage('getUserAgent', 'Begin', 11)
    urllib_agent = 'Python-urllib/%s' % urllib2.__version__
    clientRevision = '$Revision: 2468 $'
    clientVersion = '0'
    if len(clientRevision) > 11:
        clientVersion = clientRevision[11:-2]
    user_agent = 'EBI-Sample-Client/%s (%s; Python %s; %s) %s' % (
        clientVersion, os.path.basename( __file__ ), 
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
    url = urllib2.quote(url, safe="%/:=&?~#+!$,;'@()*[]")

    try:
        user_agent = getUserAgent()
        http_headers = {
            'User-Agent' : user_agent,
            'Accept-Encoding' : 'gzip'
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

def hasSubdomains(domainInfo):
    for dir in domainInfo._dir:
        if dir._name == 'subdomains':
            return True
    return False

def printDomains(domainInfo, indent):
    printDebugMessage('printDomains', 'Begin', 1)
    print (indent + domainInfo('id') + ':' + domainInfo('name'))
    if hasSubdomains(domainInfo):
        subdomains = domainInfo['subdomains']['domain':]
        for subdomain in subdomains:
            printDomains (subdomain, indent + '\t')
    printDebugMessage('printDomains', 'End', 1)

# Get domain Hierarchy
def getDomainHierarchy():
    printDebugMessage('getDomainHierarchy', 'Begin', 1)
    requestUrl = baseUrl + '/allebi'
    printDebugMessage('getDomainHierarchy', requestUrl, 2)
    xmlDoc = restRequest(requestUrl)
    doc = xmltramp.parse(xmlDoc)
    allebi = doc['domains']['domain']
    printDomains(allebi, '')
    domainInfoList = doc['result.domains.domain':]
    #for domainInfo in domainInfoList:
    #    print (domainInfo.id)
    printDebugMessage('getDomainHierarchy', 'End', 1)

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

# Get domain details
def getDomainDetails(domain):
    printDebugMessage('getDomainDetails', 'Begin', 1)
    requestUrl = baseUrl + '/' + domain
    printDebugMessage('getDomainDetails', requestUrl, 2)
    xmlDoc = restRequest(requestUrl)
    doc = xmltramp.parse(xmlDoc)
    domainInfo = doc['domains']['domain']
    printDomainDetails(domainInfo)
    printDebugMessage('getDomainDetails', 'End', 1)

def printDomainDetails(domainInfo):
    printDebugMessage('printDomainDetails', 'Begin', 1)
    print (domainInfo('name') + ' (' + domainInfo('id') + ')')
    if hasSubdomains(domainInfo):
        subdomains = domainInfo['subdomains']['domain':]
        for subdomain in subdomains:
            printDomainDetails (subdomain)
    else:
        indexInfos = domainInfo['indexInfos']['indexInfo':]
        for indexInfo in indexInfos:
            print (indexInfo('name') + ': ' + str(indexInfo))
        print
        fieldInfos = domainInfo['fieldInfos']['fieldInfo':]
        print 'field_id\tsearchable\tretrievable\tsortable\tfacet\talias\tref_domain\tref_field\ttype'
        fieldStr = ''
        for fieldInfo in fieldInfos:
            fieldStr = fieldInfo('id') + '\t'
            options = fieldInfo['options']['option':]
            for option in options:
                fieldStr += str(option) + '\t'
            print fieldStr
        print
    printDebugMessage('printDomainDetails', 'End', 1)

# Get search results
def getResults(domain, query, fields, size='', start='', fieldurl='', viewurl='', sortfield='', order=''):
    printDebugMessage('getResults', 'Begin', 1)
    requestUrl = baseUrl + '/' + domain + '?query=' + query +'&fields=' + fields + '&size=' + size + '&start=' + start + '&fieldurl=' + fieldurl + '&viewurl=' + viewurl + '&sortfield=' + sortfield + '&order=' + order
    printDebugMessage('getResults', requestUrl, 2)
    xmlDoc = restRequest(requestUrl)
    doc = xmltramp.parse(xmlDoc)
    entries = doc['entries']['entry':]
    printEntries(entries)
    printDebugMessage('getResults', 'End', 1)

def printEntries(entries):
    printDebugMessage('printEntries', 'Begin', 1)
    for entry in entries:
        for field in entry['fields']['field':]:
            fields = field['values']['value':]
            if len(fields) > 0:
                for value in field['values']['value':]:
                    print (value)
            else:
                print
        if hasFieldUrls(entry):
           for fieldurl in entry['fieldURLs']['fieldURL':]:
              print (str(fieldurl))
        if hasViewUrls(entry):
            for viewurl in entry['viewURLs']['viewURL':]:
               print (str(viewurl))
    printDebugMessage('printEntries', 'End', 1)

def hasFieldUrls(entry):
    for dir in entry._dir:
        if dir._name == 'fieldURLs':
            return True
    return False

def hasViewUrls(entry):
    for dir in entry._dir:
        if dir._name == 'viewURLs':
            return True
    return False

def printFacets(facets):
    printDebugMessage('printFacets', 'Begin', 1)
    for facet in facets:
        print facet('label') + ': ' + facet('id')
        for facetValue in facet['facetValues']['facetValue':]:
            print str(facetValue['label']) + ' (' + str(facetValue['value']) + '): ' + str(facetValue['count'])
        print
    printDebugMessage('printFacets', 'End', 1)

# Get search results with facets
def getFacetedResults(domain, query, fields, size='', start='', fieldurl='', viewurl='', sortfield='', order='', facetcount='10', facetfields=''):
    printDebugMessage('getFacetedResults', 'Begin', 1)
    requestUrl = baseUrl + '/' + domain + '?query=' + query +'&fields=' + fields + '&size=' + size + '&start=' + start + '&fieldurl=' + fieldurl + '&viewurl=' + viewurl + '&sortfield=' + sortfield + '&order=' + order + '&facetcount=' + facetcount + '&facetfields=' + facetfields
    printDebugMessage('getFacetedResults', requestUrl, 2)
    xmlDoc = restRequest(requestUrl)
    doc = xmltramp.parse(xmlDoc)
    entries = doc['entries']['entry':]
    printEntries(entries)
    print
    facets = doc['facets']['facet':]
    printFacets(facets)
    printDebugMessage('getFacetedResults', 'End', 1)

# Get entry details
def getEntries(domain, entryids, fields, fieldurl='', viewurl=''):
    printDebugMessage('getEntries', 'Begin', 1)
    requestUrl = baseUrl + '/' + domain + '/entry/' + entryids +'?fields=' + fields + '&fieldurl=' + fieldurl + '&viewurl=' + viewurl
    printDebugMessage('getEntries', requestUrl, 2)
    xmlDoc = restRequest(requestUrl)
    doc = xmltramp.parse(xmlDoc)
    entries = doc['entries']['entry':]
    printEntries(entries)    
    printDebugMessage('getEntries', 'End', 1)

# Get domain ids referenced in a domain
def getDomainsReferencedInDomain(domain):
    printDebugMessage('getDomainsReferencedInDomain', 'Begin', 1)
    requestUrl = baseUrl + '/' + domain + '/xref/'
    printDebugMessage('getDomainsReferencedInDomain', requestUrl, 2)
    xmlDoc = restRequest(requestUrl)
    doc = xmltramp.parse(xmlDoc)
    for domain in doc['domains']['domain':]:
        print domain('id')
    printDebugMessage('getDomainsReferencedInDomain', 'End', 1)

# Get domain ids referenced in an entry
def getDomainsReferencedInEntry(domain, entryid):
    printDebugMessage('getDomainsReferencedInEntry', 'Begin', 1)
    requestUrl = baseUrl + '/' + domain + '/entry/'+ entryid + '/xref/'
    printDebugMessage('getDomainsReferencedInEntry', requestUrl, 2)
    xmlDoc = restRequest(requestUrl)
    doc = xmltramp.parse(xmlDoc)
    for domain in doc['domains']['domain':]:
        print domain('id')
    printDebugMessage('getDomainsReferencedInEntry', 'End', 1)

# Get cross-references
def getReferencedEntries(domain, entryids, referenceddomain, fields, size='', start='', fieldurl='', viewurl=''):
    printDebugMessage('getReferencedEntries', 'Begin', 1)
    requestUrl = baseUrl + '/' + domain + '/entry/' + entryids + '/xref/' + referenceddomain +'?fields=' + fields + '&size=' + size + '&start=' + start + '&fieldurl=' + fieldurl + '&viewurl=' + viewurl
    printDebugMessage('getReferencedEntries', requestUrl, 2)
    xmlDoc = restRequest(requestUrl)
    doc = xmltramp.parse(xmlDoc)
    entries = doc['entries']['entry':]
    for entry in entries:
        printEntries(entry['references']['reference':])
        print
    printDebugMessage('getEntries', 'End', 1)

# No arguments, print usage
if len(args) < 1:
    parser.print_help()
# Get domain hierarchy
elif args[0] == 'getDomainHierarchy':
    getDomainHierarchy()
# Get domain details
elif args[0] == 'getDomainDetails' and len(args) > 1:
    getDomainDetails(args[1])
# Get search results
elif args[0] == 'getResults' and len(args) > 3:
    if len(args) > 9:
        getResults(args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9])
    elif len(args) > 8:
        getResults(args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8])
    elif len(args) > 7:
        getResults(args[1], args[2], args[3], args[4], args[5], args[6], args[7])
    elif len(args) > 6:
        getResults(args[1], args[2], args[3], args[4], args[5], args[6])
    elif len(args) > 5:
        getResults(args[1], args[2], args[3], args[4], args[5])
    elif len(args) > 4:
        getResults(args[1], args[2], args[3], args[4])
    elif len(args) > 3:
        getResults(args[1], args[2], args[3])
    else:
        print 'domain, query and fields should be given.'
# Get search results with facets
elif args[0] == 'getFacetedResults' and len(args) > 3:
    if len(args) > 11:
        getFacetedResults(args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11])
    elif len(args) > 10:
        getFacetedResults(args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10])
    elif len(args) > 9:
        getFacetedResults(args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9])
    elif len(args) > 8:
        getFacetedResults(args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8])
    elif len(args) > 7:
        getFacetedResults(args[1], args[2], args[3], args[4], args[5], args[6], args[7])
    elif len(args) > 6:
        getFacetedResults(args[1], args[2], args[3], args[4], args[5], args[6])
    elif len(args) > 5:
        getFacetedResults(args[1], args[2], args[3], args[4], args[5])
    elif len(args) > 4:
        getFacetedResults(args[1], args[2], args[3], args[4])
    elif len(args) > 3:
        getFacetedResults(args[1], args[2], args[3])
    else:
        print 'domain, query and fields should be given.'
# Get entry details.
elif args[0] == 'getEntries' and len(args) > 3:
    if len(args) > 5:
        getEntries(args[1], args[2], args[3], args[4], args[5])
    elif len(args) > 4:
        getEntries(args[1], args[2], args[3], args[4])
    elif len(args) > 3:
        getEntries(args[1], args[2], args[3])
    else:
        print 'domain, entry ids and fields should be given.'
# Get domain ids referenced in a domain
elif args[0] == 'getDomainsReferencedInDomain' and len(args) > 1:
    getDomainsReferencedInDomain(args[1])
# Get domain ids referenced in an entry
elif args[0] == 'getDomainsReferencedInEntry' and len(args) > 2:
    getDomainsReferencedInEntry(args[1], args[2])
# Fetch a set of entries
elif args[0] == 'getReferencedEntries' and len(args) > 4:
    if len(args) > 8:
        getReferencedEntries(args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8])
    elif len(args) > 7:
        getReferencedEntries(args[1], args[2], args[3], args[4], args[5], args[6], args[7])
    elif len(args) > 6:
        getReferencedEntries(args[1], args[2], args[3], args[4], args[5], args[6])
    elif len(args) > 5:
        getReferencedEntries(args[1], args[2], args[3], args[4], args[5])
    elif len(args) > 4:
        getReferencedEntries(args[1], args[2], args[3], args[4])
    else:
        print 'domain, entryids, referencedDomain and fields should be given.'
# Unknown argument combination, display usage
else:
    print 'Error: unrecognised argument combination'
    parser.print_help()
