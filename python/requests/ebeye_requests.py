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
# EB-eye (REST) using requests
#
#
# See:
# https://www.ebi.ac.uk/ebisearch/swagger.ebi
#
import os
import requests
import platform
from optparse import OptionParser


# Debug print
def printDebugMessage(functionName, message, level):
    if (level <= debugLevel):
        print('[' + functionName + '] ' + message)


# User-agent for request.
def getUserAgent():
    printDebugMessage('getUserAgent', 'Begin', 11)
    requests_agent = 'Python-requests/%s' % requests.__version__
    clientRevision = '$Revision: 2468 $'
    clientVersion = '0'
    if len(clientRevision) > 11:
        clientVersion = clientRevision[11:-2]
    user_agent = 'EBI-Sample-Client/%s (%s; Python %s; %s) %s' % (
        clientVersion, os.path.basename(__file__),
        platform.python_version(), platform.system(),
        requests_agent
    )
    printDebugMessage('getUserAgent', 'user_agent: ' + user_agent, 12)
    printDebugMessage('getUserAgent', 'End', 11)
    return user_agent


# Wrapper for a REST (HTTP GET) request
def restRequest(url):
    printDebugMessage('restRequest', 'Begin', 11)
    printDebugMessage('restRequest', 'url: ' + url, 11)

    user_agent = getUserAgent()
    http_headers = {
        'User-Agent': user_agent,
        'Accept-Encoding': 'gzip',
        'Accept': 'application/json'
    }

    result = requests.get(url, headers=http_headers)
    result.raise_for_status()

    printDebugMessage('restRequest', 'result: ' + result.text, 11)
    printDebugMessage('restRequest', 'End', 11)
    return result


def hasSubdomains(domainInfo):
    if 'subdomains' in domainInfo:
        return True
    return False


def printDomains(domainInfo, indent):
    printDebugMessage('printDomains', 'Begin', 1)
    print(indent + domainInfo['id'] + ':' + domainInfo['name'])
    if hasSubdomains(domainInfo):
        subdomains = domainInfo['subdomains']
        for subdomain in subdomains:
            printDomains(subdomain, indent + '\t')
    printDebugMessage('printDomains', 'End', 1)


# Get domain Hierarchy
def getDomainHierarchy():
    printDebugMessage('getDomainHierarchy', 'Begin', 1)
    requestUrl = baseUrl + '/allebi'
    printDebugMessage('getDomainHierarchy', requestUrl, 2)

    jsonRes = restRequest(requestUrl).json()

    allebi = jsonRes['domains'][0]
    printDomains(allebi, '')

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
    jsonRes = restRequest(requestUrl).json()
    domainInfo = jsonRes['domains'][0]
    printDomainDetails(domainInfo)
    printDebugMessage('getDomainDetails', 'End', 1)


def printDomainDetails(domainInfo):
    printDebugMessage('printDomainDetails', 'Begin', 1)
    print(domainInfo['name'] + ' (' + domainInfo['id'] + ')')
    if hasSubdomains(domainInfo):
        subdomains = domainInfo['subdomains']
        for subdomain in subdomains:
            printDomainDetails(subdomain)
    else:
        indexInfos = domainInfo['indexInfos']
        for indexInfo in indexInfos:
            print(indexInfo['name'] + ': ' + indexInfo['value'])
        print('')
        fieldInfos = domainInfo['fieldInfos']
        print('field_id\tsearchable\tretrievable\tsortable\tfacet\talias\tref_domain\tref_field\ttype')
        fieldStr = ''
        for fieldInfo in fieldInfos:
            fieldStr = fieldInfo['id'] + '\t'
            options = fieldInfo['options']
            for option in options:
                fieldStr += option['value'] + '\t'
            print(fieldStr)
        print('')
    printDebugMessage('printDomainDetails', 'End', 1)


# Get number of results
def getNumberOfResults(domain, query):
    printDebugMessage('getNumberOfResults', 'Begin', 1)
    requestUrl = baseUrl + '/' + domain + '?query=' + query + '&size=0'
    printDebugMessage('getNumberOfResults', requestUrl, 2)
    jsonRes = restRequest(requestUrl).json()
    numberOfResults = jsonRes['hitCount']
    print(numberOfResults)
    printDebugMessage('getNumberOfResults', 'End', 1)


# Get search results
def getResults(domain, query, fields, size='', start='', fieldurl='',
               viewurl='', sortfield='', order='', sort=''):
    printDebugMessage('getResults', 'Begin', 1)
    requestUrl = baseUrl + '/' + domain + '?query=' + query + '&fields=' + fields + \
                 '&size=' + size + '&start=' + start + '&fieldurl=' + fieldurl + \
                 '&viewurl=' + viewurl + '&sortfield=' + sortfield + '&order=' + \
                 order + '&sort=' + sort
    printDebugMessage('getResults', requestUrl, 2)
    jsonRes = restRequest(requestUrl).json()
    entries = jsonRes['entries']
    printEntries(entries)
    printDebugMessage('getResults', 'End', 1)


def printEntries(entries):
    printDebugMessage('printEntries', 'Begin', 1)
    for entry in entries:
        for field in entry['fields']:
            for v in entry['fields'][field]:
                print(v)

        if hasFieldUrls(entry):
            for fieldurl in entry['fieldURLs']:
                print(fieldurl['value'])
        if hasViewUrls(entry):
            for viewurl in entry['viewURLs']:
                print(viewurl['value'])
    printDebugMessage('printEntries', 'End', 1)


def hasFieldUrls(entry):
    if 'fieldURLs' in entry:
        return True
    return False


def hasViewUrls(entry):
    if 'viewURLs' in entry:
        return True
    return False


def printFacets(facets):
    printDebugMessage('printFacets', 'Begin', 1)
    for facet in facets:
        print(facet['label'] + ': ' + facet['id'])
        for facetValue in facet['facetValues']:
            printFacetValue(facetValue, 0)
        print('')
    printDebugMessage('printFacets', 'End', 1)


def printFacetValue(facetValue, depth=0):
    printDebugMessage('printFacetValue', 'Begin', 1)
    print('\t' * depth + facetValue['label'] + ' (' +
          facetValue['value'] + '): ' + str(facetValue['count']))

    if hasFacetValueChildren(facetValue):
        for child in facetValue['children']:
            printFacetValue(child, depth + 1)

    printDebugMessage('printFacetValue', 'End', 1)


def hasFacetValueChildren(facetValue):
    if 'children' in facetValue:
        return True
    return False


# Get search results with facets
def getFacetedResults(domain, query, fields, size='', start='', fieldurl='',
                      viewurl='', sortfield='', order='', sort='', facetcount='10',
                      facetfields='', facets='', facetsdepth=''):
    printDebugMessage('getFacetedResults', 'Begin', 1)
    requestUrl = baseUrl + '/' + domain + '?query=' + query + '&fields=' + fields + \
                 '&size=' + size + '&start=' + start + '&fieldurl=' + fieldurl + \
                 '&viewurl=' + viewurl + '&sortfield=' + sortfield + '&order=' + order + \
                 '&sort=' + sort + '&facetcount=' + facetcount + \
                 '&facetfields=' + facetfields + '&facets=' + facets + \
                 '&facetsdepth=' + facetsdepth
    printDebugMessage('getFacetedResults', requestUrl, 2)
    jsonRes = restRequest(requestUrl).json()
    printEntries(jsonRes['entries'])
    print('')
    printFacets(jsonRes['facets'])
    printDebugMessage('getFacetedResults', 'End', 1)


# Get entry details
def getEntries(domain, entryids, fields, fieldurl='', viewurl=''):
    printDebugMessage('getEntries', 'Begin', 1)
    requestUrl = baseUrl + '/' + domain + '/entry/' + entryids + '?fields=' + fields + \
                 '&fieldurl=' + fieldurl + '&viewurl=' + viewurl
    printDebugMessage('getEntries', requestUrl, 2)
    jsonRes = restRequest(requestUrl).json()
    printEntries(jsonRes['entries'])
    printDebugMessage('getEntries', 'End', 1)


# Get domain ids referenced in a domain
def getDomainsReferencedInDomain(domain):
    printDebugMessage('getDomainsReferencedInDomain', 'Begin', 1)
    requestUrl = baseUrl + '/' + domain + '/xref/'
    printDebugMessage('getDomainsReferencedInDomain', requestUrl, 2)
    jsonRes = restRequest(requestUrl).json()
    for domain in jsonRes['domains']:
        print(domain['id'])
    printDebugMessage('getDomainsReferencedInDomain', 'End', 1)


# Get domain ids referenced in an entry
def getDomainsReferencedInEntry(domain, entryid):
    printDebugMessage('getDomainsReferencedInEntry', 'Begin', 1)
    requestUrl = baseUrl + '/' + domain + '/entry/' + entryid + '/xref/'
    printDebugMessage('getDomainsReferencedInEntry', requestUrl, 2)
    jsonRes = restRequest(requestUrl).json()
    for domain in jsonRes['domains']:
        print(domain['id'])
    printDebugMessage('getDomainsReferencedInEntry', 'End', 1)


# Get cross-references
def getReferencedEntries(domain, entryids, referenceddomain, fields, size='',
                         start='', fieldurl='', viewurl='', facetcount='',
                         facetfields='', facets=''):
    printDebugMessage('getReferencedEntries', 'Begin', 1)
    requestUrl = baseUrl + '/' + domain + '/entry/' + entryids + '/xref/' + referenceddomain + \
                 '?fields=' + fields + '&size=' + size + '&start=' + start + \
                 '&fieldurl=' + fieldurl + '&viewurl=' + viewurl + '&facetcount=' + facetcount + \
                 '&facetfields=' + facetfields + '&facets=' + facets
    printDebugMessage('getReferencedEntries', requestUrl, 2)
    jsonRes = restRequest(requestUrl).json()
    for entry in jsonRes['entries']:
        printEntries(entry['references'])
        if hasReferenceFacet(entry):
            printFacets(entry['referenceFacets'])
        print('')
    printDebugMessage('getEntries', 'End', 1)


def hasReferenceFacet(entry):
    if 'referenceFacets' in entry:
        return True
    return False


# Get top terms
def getTopTerms(domain, field, size='', excludes='', excludesets=''):
    printDebugMessage('getTopTerms', 'Begin', 1)
    requestUrl = baseUrl + '/' + domain + '/topterms/' + field + '?size=' + size + \
                 '&excludes=' + excludes + '&excludesets=' + excludesets
    printDebugMessage('getTopTerms', requestUrl, 2)
    jsonRes = restRequest(requestUrl).json()
    for term in jsonRes['topTerms']:
        printTerm(term)
    printDebugMessage('getTopTerms', 'End', 1)


def printTerm(term):
    printDebugMessage('printTerm', 'Begin', 1)
    print(term['text'] + ': ' + str(term['docFreq']))
    printDebugMessage('printTerm', 'End', 1)


# Get similar documents to a given one
def getMoreLikeThis(domain, entryid, targetDomain, fields, size='', start='',
                    fieldurl='', viewurl='', mltfields='', mintermfreq='',
                    mindocfreq='', maxqueryterm='', excludes='', excludesets=''):
    printDebugMessage('getMoreLikeThis', 'Begin', 1)
    requestUrl = baseUrl + '/' + domain + '/entry/' + entryid + '/morelikethis/' + targetDomain + \
                 '?size=' + size + '&start=' + start + '&fields=' + fields + \
                 '&fieldurl=' + fieldurl + '&viewurl=' + viewurl + '&mltfields=' + mltfields + \
                 '&mintermfreq=' + mintermfreq + '&mindocfreq=' + maxqueryterm + \
                 '&maxqueryterm=' + mindocfreq + '&excludes=' + excludes + '&excludesets=' + excludesets
    printDebugMessage('getMoreLikeThis', requestUrl, 2)
    jsonRes = restRequest(requestUrl).json()
    entries = jsonRes['entries']
    printEntries(entries)
    printDebugMessage('getMoreLikeThis', 'End', 1)


# Get suggestions
def getAutoComplete(domain, term):
    printDebugMessage('getAutoComplete', 'Begin', 1)
    requestUrl = baseUrl + '/' + domain + '/autocomplete?term=' + term
    printDebugMessage('getAutoComplete', requestUrl, 2)
    jsonRes = restRequest(requestUrl).json()
    printSuggestions(jsonRes['suggestions'])
    printDebugMessage('getAutoComplete', 'End', 1)


def printSuggestions(suggestions):
    printDebugMessage('printSuggestions', 'Begin', 1)
    for suggetion in suggestions:
        print(suggetion['suggestion'])
    print('')
    printDebugMessage('printSuggestions', 'End', 1)


def main(baseUrl, outputLevel, debugLevel, usage):
    """
    Main caller method that sets the CLI.
    """

    # Process command-line options
    parser = OptionParser(usage=usage, description=description)
    parser.add_option('--size', help='number of entries to retrieve')
    parser.add_option('--start', help='index of the first entry in results')
    parser.add_option('--fieldurl', help='whether field links are included')
    parser.add_option('--viewurl', help='whether view links are included')
    parser.add_option('--sortfield', help='field id to sort')
    parser.add_option('--order', help='sort in ascending/descending order')
    parser.add_option('--sort', help='sort criteria')
    parser.add_option('--facetcount', help='number of facet values to retrieve')
    parser.add_option('--facetfields', help='field ids associated with facets to retrieve')
    parser.add_option('--facets', help='list of selected facets')
    parser.add_option('--facetsdepth', help='depth in hierarchical facet')
    parser.add_option('--mltfields', help='field ids  to be used for generating a morelikethis query')
    parser.add_option('--mintermfreq', help=('frequency below which terms will be '
                                             'ignored in the base document'))
    parser.add_option('--mindocfreq',
                      help=('frequency at which words will be ignored which do not '
                            'occur in at least this many documents'))
    parser.add_option('--maxqueryterm',
                      help='maximum number of query terms that will be included in any generated query')
    parser.add_option('--excludes', help='terms to be excluded')
    parser.add_option('--excludesets', help='stop word sets to be excluded')

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
    # No arguments, print usage
    if len(args) < 1:
        parser.print_help()
    # Get domain hierarchy
    elif args[0] == 'getDomainHierarchy':
        getDomainHierarchy()
    # Get domain details
    elif args[0] == 'getDomainDetails':
        if len(args) < 2:
            print('domain should be given.')
        else:
            getDomainDetails(args[1])

    # Get number of results
    elif args[0] == 'getNumberOfResults':
        if len(args) != 3:
            print('domain and query should be given.')
        else:
            getNumberOfResults(args[1], args[2])

    # Get search results
    elif args[0] == 'getResults':
        if len(args) < 4:
            print('domain, query and fields should be given.')
        else:
            size = options.size if options.size else ''
            start = options.start if options.start else ''
            fieldurl = options.fieldurl if options.fieldurl else ''
            viewurl = options.viewurl if options.viewurl else ''
            sortfield = options.sortfield if options.sortfield else ''
            order = options.order if options.order else ''
            sort = options.sort if options.sort else ''
            getResults(args[1], args[2], args[3], size, start, fieldurl,
                       viewurl, sortfield, order, sort)
    # Get search results with facets
    elif args[0] == 'getFacetedResults':
        if len(args) < 4:
            print('domain, query and fields should be given.')
        else:
            size = options.size if options.size else ''
            start = options.start if options.start else ''
            fieldurl = options.fieldurl if options.fieldurl else ''
            viewurl = options.viewurl if options.viewurl else ''
            sortfield = options.sortfield if options.sortfield else ''
            order = options.order if options.order else ''
            sort = options.sort if options.sort else ''
            facetcount = options.facetcount if options.facetcount else ''
            facetfields = options.facetfields if options.facetfields else ''
            facets = options.facets if options.facets else ''
            facetsdepth = options.facetsdepth if options.facetsdepth else ''
            getFacetedResults(args[1], args[2], args[3], size, start, fieldurl,
                              viewurl, sortfield, order, sort,
                              facetcount, facetfields, facets, facetsdepth)
    # Get entry details.
    elif args[0] == 'getEntries':
        if len(args) < 4:
            print('domain, entry ids and fields should be given.')
        else:
            fieldurl = options.fieldurl if options.fieldurl else ''
            viewurl = options.viewurl if options.viewurl else ''
            getEntries(args[1], args[2], args[3], fieldurl, viewurl)
    # Get domain ids referenced in a domain
    elif args[0] == 'getDomainsReferencedInDomain':
        if len(args) < 2:
            print('domain sholud be given.')
        else:
            getDomainsReferencedInDomain(args[1])
    # Get domain ids referenced in an entry
    elif args[0] == 'getDomainsReferencedInEntry':
        if len(args) < 3:
            print('domain and entry id should be given.')
        else:
            getDomainsReferencedInEntry(args[1], args[2])
    # Get cross-references
    elif args[0] == 'getReferencedEntries':
        if len(args) < 5:
            print('domain, entryids, referencedDomain and fields should be given.')
        else:
            size = options.size if options.size else ''
            start = options.start if options.start else ''
            fieldurl = options.fieldurl if options.fieldurl else ''
            viewurl = options.viewurl if options.viewurl else ''
            facetcount = options.facetcount if options.facetcount else ''
            facetfields = options.facetfields if options.facetfields else ''
            facets = options.facets if options.facets else ''
            getReferencedEntries(args[1], args[2], args[3], args[4], size, start,
                                 fieldurl, viewurl, facetcount, facetfields, facets)
    # Get top terms
    elif args[0] == 'getTopTerms':
        if len(args) < 3:
            print('domain and field should be given.')
        else:
            size = options.size if options.size else ''
            excludes = options.excludes if options.excludes else ''
            excludesets = options.excludesets if options.excludesets else ''
            getTopTerms(args[1], args[2], size, excludes, excludesets)
    # Get similar documents to a given one
    elif args[0] == 'getMoreLikeThis':
        if len(args) < 4:
            print('domain, entryid and fields should be given.')
        else:
            size = options.size if options.size else ''
            start = options.start if options.start else ''
            fieldurl = options.fieldurl if options.fieldurl else ''
            viewurl = options.viewurl if options.viewurl else ''
            mltfields = options.mltfields if options.mltfields else ''
            mintermfreq = options.mintermfreq if options.mintermfreq else ''
            mindocfreq = options.mindocfreq if options.mindocfreq else ''
            maxqueryterm = options.maxqueryterm if options.maxqueryterm else ''
            excludes = options.excludes if options.excludes else ''
            excludesets = options.excludesets if options.excludesets else ''
            getMoreLikeThis(args[1], args[2], args[1], args[3], size, start,
                            fieldurl, viewurl, mltfields, mintermfreq,
                            mindocfreq, maxqueryterm, excludes, excludesets)
    # Get similar documents to a given one
    elif args[0] == 'getExtendedMoreLikeThis':
        if len(args) < 5:
            print('domain, entryid, targetDomain and fields should be given.')
        else:
            size = options.size if options.size else ''
            start = options.start if options.start else ''
            fieldurl = options.fieldurl if options.fieldurl else ''
            viewurl = options.viewurl if options.viewurl else ''
            mltfields = options.mltfields if options.mltfields else ''
            mintermfreq = options.mintermfreq if options.mintermfreq else ''
            mindocfreq = options.mindocfreq if options.mindocfreq else ''
            maxqueryterm = options.maxqueryterm if options.maxqueryterm else ''
            excludes = options.excludes if options.excludes else ''
            excludesets = options.excludesets if options.excludesets else ''
            getMoreLikeThis(args[1], args[2], args[3], args[4], size, start,
                            fieldurl, viewurl, mltfields, mintermfreq,
                            mindocfreq, maxqueryterm, excludes, excludesets)

    elif args[0] == 'getAutoComplete':
        if len(args) < 3:
            print('domain and term should be given.')
        else:
            getAutoComplete(args[1], args[2])
    # Unknown argument combination, display usage
    else:
        print('Error: unrecognised argument combination')
        parser.print_help()


if __name__ == "__main__":
    # Service base URL
    baseUrl = 'https://www.ebi.ac.uk/ebisearch/ws/rest'

    # Output level
    outputLevel = 1

    # Debug level
    debugLevel = 0

    # Usage message
    usage = """
      %prog getDomainHierarchy
      %prog getDomainDetails  <domain>

      %prog getNumberOfResults <domain> <query>
      %prog getResults        <domain> <query> <fields> [OPTIONS: --size | --start | --fieldurl | --viewurl | --sortfield | --order | --sort ]
      %prog getFacetedResults <domain> <query> <fields> [OPTIONS: --size | --start | --fieldurl | --viewurl | --sortfield | --order | --sort | --facetcount | --facetfields | --facets | --facetsdepth ]

      %prog getEntries        <domain> <entryids> <fields> [OPTIONS: --fieldurl | --viewurl]

      %prog getDomainsReferencedInDomain <domain>
      %prog getDomainsReferencedInEntry  <domain> <entryid>
      %prog getReferencedEntries         <domain> <entryids> <referencedDomain> <fields> [OPTIONS: --size | --start | --fieldurl | --viewurl | --facetcount | --facetfields | --facets]

      %prog getTopTerms       <domain> <field> [OPTIONS: --size | --excludes | --excludesets]

      %prog getAutoComplete   <domain> <term>

      %prog getMoreLikeThis   <domain> <entryid> <fields> [OPTIONS: --size | --start | --fieldurl | --viewurl | --mltfields | --mintermfreq | --mindocfreq | --maxqueryterm | --excludes | --excludesets]
      %prog getExtendedMoreLikeThis   <domain> <entryid> <targetDomain> <fields> [OPTIONS: --size | --start | --fieldurl | --viewurl | --mltfields | --mintermfreq | --mindocfreq | --maxqueryterm | --excludes | --excludesets]"""

    description = ("Search at EMBL-EBI in All results using the EBI search engine."
                   " For more information on EBI Search refer to https://www.ebi.ac.uk/ebisearch/")

    main(baseUrl, outputLevel, debugLevel, usage)
