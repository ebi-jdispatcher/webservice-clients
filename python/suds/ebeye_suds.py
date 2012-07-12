#!/usr/bin/env python
# $Id$
# ======================================================================
# EB-eye SOAP service, Python client using suds.
#
# Tested with:
#   Python 2.6.5 with suds 0.3.9 (Ubuntu 10.04 LTS)
#   Python 2.7.3 with suds 0.4.1 (Ubuntu 12.04 LTS)
#
# See:
# http://www.ebi.ac.uk/Tools/webservices/services/eb-eye
# http://www.ebi.ac.uk/Tools/webservices/tutorials/python
# ======================================================================
# WSDL URL for service.
wsdlUrl = 'http://www.ebi.ac.uk/ebisearch/service.ebi?wsdl'

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
# Number of option arguments.
numOpts = len(sys.argv)

# Usage message
usage = """
  %prog --help

  %prog --listDomains
  %prog --getNumberOfResults <domain> <query>
  %prog --getResultsIds <domain> <query> <start> <size>
  %prog --getAllResultsIds <domain> <query>
  %prog --listFields <domain>
  %prog --getResults <domain> <query> <fields> <start> <size>
  %prog --getEntry <domain> <entry> <fields>
  %prog --getEntries <domain> <entries> <fields>
  %prog --getEntryFieldUrls <domain> <entry> <fields>
  %prog --getEntriesFieldUrls <domain> <entries> <fields>
  %prog --getDomainsReferencedInDomain <domain>
  %prog --getDomainsReferencedInEntry <domain> <entry>
  %prog --listAdditionalReferenceFields <domain>
  %prog --getReferencedEntries <domain> <entry> <referencedDomain>
  %prog --getReferencedEntriesSet <domain> <entries> <referencedDomain> <fields>
  %prog --getReferencedEntriesFlatSet <domain> <entries> <referencedDomain> <fields>
  %prog --getDomainsHierarchy
  %prog --getDetailledNumberOfResults <domain> <query> <flat>
  %prog --listFieldsInformation <domain>
"""
description = """Query EBI Search using the EB-eye web services.
"""
epilog = """For further information about the EB-eye web service, see 
http://www.ebi.ac.uk/Tools/webservices/services/eb-eye
"""
version = "$Id$"
# Process command-line options
parser = OptionParser(usage=usage, description=description, epilog=epilog, version=version)
# EB-eye specific options.
parser.add_option('--listDomains', action="store_true", help='Returns a list of all the domains identifiers which can be used in a query.')
parser.add_option('--getNumberOfResults', action="store", nargs=2, help='Executes a query and returns the number of results found.')
parser.add_option('--getResultsIds', action="store", nargs=4, help="Executes a query and returns the list of identifiers for the entries found.")
parser.add_option('--getAllResultsIds', action="store", nargs=2, help="Executes a query and returns the list of all the identifiers for the entries found.")
parser.add_option('--listFields', action="store", help="Returns the list of fields that can be retrieved for a particular domain.")
parser.add_option('--getResults', action="store", nargs=5, help="Executes a query and returns a list of results. Each result contains the values for each field specified in the 'fields' argument in the same order as they appear in the 'fields' list.")
parser.add_option('--getEntry', action="store", nargs=3, help="Search for a particular entry in a domain and returns the values for some of the fields of this entry. The result contains the values for each field specified in the 'fields' argument in the same order as they appear in the 'fields' list.")
parser.add_option('--getEntries', action="store", nargs=3, help="Search for entries in a domain and returns the values for some of the fields of these entries. The result contains the values for each field specified in the 'fields' argument in the same order as they appear in the 'fields' list.")
parser.add_option('--getEntryFieldUrls', action="store", nargs=3, help="Search for a particular entry in a domain and returns the urls configured for some of the fields of this entry. The result contains the urls for each field specified in the 'fields' argument in the same order as they appear in the 'fields' list.")
parser.add_option('--getEntriesFieldUrls', action="store", nargs=3, help="Search for a list of entries in a domain and returns the urls configured for some of the fields of these entries. Each result contains the url for each field specified in the 'fields' argument in the same order as they appear in the 'fields' list.")
parser.add_option('--getDomainsReferencedInDomain', action="store", help="Returns the list of domains with entries referenced in a particular domain. These domains are indexed in the EB-eye.")
parser.add_option('--getDomainsReferencedInEntry', action="store", nargs=2, help="Returns the list of domains with entries referenced in a particular domain entry. These domains are indexed in the EB-eye.")
parser.add_option('--listAdditionalReferenceFields', action="store", help="Returns the list of fields corresponding to databases referenced in the domain but not included as a domain in the EB-eye. ")
parser.add_option('--getReferencedEntries', action="store", nargs=3, help="Returns the list of referenced entry identifiers from a domain referenced in a particular domain entry.")
parser.add_option('--getReferencedEntriesSet', action="store", nargs=4, help="Returns the list of referenced entries from a domain referenced in a set of entries. The result will be returned as a list of objects, each representing an entry reference.")
parser.add_option('--getReferencedEntriesFlatSet', action="store", nargs=4, help="Returns the list of referenced entries from a domain referenced in a set of entries. The result will be returned as a flat table corresponding to the list of results where, for each result, the first value is the original entry identifier and the other values correspond to the fields values.")
parser.add_option('--getDomainsHierarchy', action="store_true", help="Returns the hierarchy of the domains available.")
parser.add_option('--getDetailledNumberOfResults', action="store", nargs=3, help="Executes a query and returns the number of results found per domain.")
parser.add_option('--listFieldsInformation', action="store", help="List of fields that can be retrieved and/or searched for a particular domain.")
# Generic options.
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

### Functions ###

# Debug print
def printDebugMessage(functionName, message, level):
    if(level <= debugLevel):
        print >>sys.stderr, '[' + functionName + '] ' + message

# Print an array/list of strings
def printArrayOfString(stringArray):
    for string in stringArray:
        print string

# Print an array of arrays of strings.
def printArrayOfArrayOfString(stringArrayArray):
    for stringArray in stringArrayArray:
        printArrayOfString(stringArray['string'])

# Get list of domains.
def soapListDomains():
    printDebugMessage('soapListDomains', 'Begin', 1)
    result = server.listDomains()
    printDebugMessage('soapListDomains', 'End', 1)
    return result['string']

# Print list of domains.
def printListDomains():
    printDebugMessage('printListDomains', 'Begin', 1)
    domainList = soapListDomains()
    printArrayOfString(domainList)
    printDebugMessage('printListDomains', 'End', 1)

# Get number of results.
def soapGetNumberOfResults(domain, query):
    printDebugMessage('soapGetNumberOfResults', 'Begin', 1)
    printDebugMessage('soapGetNumberOfResults', 'domain: %s' % (domain), 2)
    printDebugMessage('soapGetNumberOfResults', 'query: %s' % (query), 2)
    result = server.getNumberOfResults(domain, query)
    printDebugMessage('soapGetNumberOfResults', 'End', 1)
    return result

# Print number of results.
def printGetNumberOfResults(domain, query):
    printDebugMessage('printGetNumberOfResults', 'Begin', 1)
    numberOfResults = soapGetNumberOfResults(domain, query)
    print numberOfResults
    printDebugMessage('printGetNumberOfResults', 'End', 1)

# Get result identifiers.
def soapGetResultsIds(domain, query, start, size):
    printDebugMessage('soapGetResultsIds', 'Begin', 1)
    result = server.getResultsIds(domain, query, start, size)
    printDebugMessage('soapGetResultsIds', 'End', 1)
    return result['string']

# Print results identifiers.
def printGetResultsIds(domain, query, start, size):
    printDebugMessage('printGetResultsIds', 'Begin', 1)
    resultIdList = soapGetResultsIds(domain, query, start, size)
    printArrayOfString(resultIdList)
    printDebugMessage('printGetResultsIds', 'End', 1)

# Get all result identifiers (use with care)
def soapGetAllResultsIds(domain, query):
    printDebugMessage('soapGetAllResultsIds', 'Begin', 1)
    result = server.getAllResultsIds(domain, query)
    printDebugMessage('soapGetAllResultsIds', 'End', 1)
    return result['string']

# Print all results identifiers.
def printGetAllResultsIds(domain, query):
    printDebugMessage('printGetAllResultsIds', 'Begin', 1)
    resultIdList = soapGetAllResultsIds(domain, query)
    printArrayOfString(resultIdList)
    printDebugMessage('printGetAllResultsIds', 'End', 1)

# List fields.
def soapListFields(domain):
    printDebugMessage('soapListFields', 'Begin', 1)
    result = server.listFields(domain)
    printDebugMessage('soapListFields', 'End', 1)
    return result['string']

# Print list of fields.
def printListFields(domain):
    printDebugMessage('printListFields', 'Begin', 1)
    fieldNameList = soapListFields(domain)
    printArrayOfString(fieldNameList)
    printDebugMessage('printListFields', 'End', 1)

# Get results.
def soapGetResults(domain, query, fields, start, size):
    printDebugMessage('soapGetResults', 'Begin', 1)
    if isinstance(fields, basestring):
        fieldsArray = {'string':fields.split(',')}
    else:
        fieldsArray = fields
    result = server.getResults(domain, query, fieldsArray, start, size)
    printDebugMessage('soapGetResults', 'End', 1)
    return result['ArrayOfString']

def printGetResults(domain, query, field, start, size):
    printDebugMessage('printGetResults', 'Begin', 1)
    results = soapGetResults(domain, query, field, start, size)
    printArrayOfArrayOfString(results)
    printDebugMessage('printGetResults', 'End', 1)

# Get entry.
def soapGetEntry(domain, entry, fields):
    printDebugMessage('soapGetEntry', 'Begin', 1)
    if isinstance(fields, basestring):
        fieldsArray = {'string':fields.split(',')}
    else:
        fieldsArray = fields
    result = server.getEntry(domain, entry, fieldsArray)
    printDebugMessage('soapGetEntry', 'End', 1)
    return result['string']

def printGetEntry(domain, entry, fields):
    printDebugMessage('printGetEntry', 'Begin', 1)
    entry = soapGetEntry(domain, entry, fields)
    printArrayOfString(entry)
    printDebugMessage('printGetEntry', 'End', 1)

# Get entries.
def soapGetEntries(domain, entries, fields):
    printDebugMessage('soapGetEntries', 'Begin', 1)
    if isinstance(entries, basestring):
        entryArray = {'string':entries.split(',')}
    else:
        entryArray = entries
    if isinstance(fields, basestring):
        fieldsArray = {'string':fields.split(',')}
    else:
        fieldsArray = fields
    result = server.getEntries(domain, entryArray, fieldsArray)
    printDebugMessage('soapGetEntries', 'End', 1)
    return result['ArrayOfString']

def printGetEntries(domain, entries, fields):
    printDebugMessage('printGetEntries', 'Begin', 1)
    entries = soapGetEntries(domain, entries, fields)
    printArrayOfArrayOfString(entries)
    printDebugMessage('printGetEntries', 'End', 1)

# Get URL(s) for entry fields.
def soapGetEntryFieldUrls(domain, entry, fields):
    printDebugMessage('soapGetEntryFieldUrls', 'Begin', 1)
    if isinstance(fields, basestring):
        fieldsArray = {'string':fields.split(',')}
    else:
        fieldsArray = fields
    result = server.getEntryFieldUrls(domain, entry, fieldsArray)
    printDebugMessage('soapGetEntryFieldUrls', 'End', 1)
    return result['string']

def printGetEntryFieldUrls(domain, entry, fields):
    printDebugMessage('printGetEntryFieldUrls', 'Begin', 1)
    entryFieldUrls = soapGetEntryFieldUrls(domain, entry, fields)
    printArrayOfString(entryFieldUrls)
    printDebugMessage('printGetEntryFieldUrls', 'End', 1)

# Get URL(s) for entries fields.
def soapGetEntriesFieldUrls(domain, entries, fields):
    printDebugMessage('soapGetEntriesFieldUrls', 'Begin', 1)
    if isinstance(entries, basestring):
        entryArray = {'string':entries.split(',')}
    else:
        entryArray = entries
    if isinstance(fields, basestring):
        fieldsArray = {'string':fields.split(',')}
    else:
        fieldsArray = fields
    result = server.getEntriesFieldUrls(domain, entryArray, fieldsArray)
    printDebugMessage('soapGetEntriesFieldUrls', 'End', 1)
    return result['ArrayOfString']

def printGetEntriesFieldUrls(domain, entries, fields):
    printDebugMessage('printGetEntriesFieldUrls', 'Begin', 1)
    entriesFieldUrls = soapGetEntriesFieldUrls(domain, entries, fields)
    printArrayOfArrayOfString(entriesFieldUrls)
    printDebugMessage('printGetEntriesFieldUrls', 'End', 1)

# Get list of domains referenced by a domain.
def soapGetDomainsReferencedInDomain(domain):
    printDebugMessage('soapGetDomainsReferencedInDomain', 'Begin', 1)
    result = server.getDomainsReferencedInDomain(domain)
    printDebugMessage('soapGetDomainsReferencedInDomain', 'End', 1)
    return result['string']

def printGetDomainsReferencedInDomain(domain):
    printDebugMessage('printGetDomainsReferencedInDomain', 'Begin', 1)
    domainList = soapGetDomainsReferencedInDomain(domain)
    printArrayOfString(domainList)
    printDebugMessage('printGetDomainsReferencedInDomain', 'End', 1)

# Get list of domains references in an entry.
def soapGetDomainsReferencedInEntry(domain, entry):
    printDebugMessage('soapGetDomainsReferencedInEntry', 'Begin', 1)
    result = server.getDomainsReferencedInEntry(domain, entry)
    printDebugMessage('soapGetDomainsReferencedInEntry', 'End', 1)
    return result['string']

def printGetDomainsReferencedInEntry(domain, entry):
    printDebugMessage('printGetDomainsReferencedInEntry', 'Begin', 1)
    domainList = soapGetDomainsReferencedInEntry(domain, entry)
    printArrayOfString(domainList)
    printDebugMessage('printGetDomainsReferencedInEntry', 'End', 1)

# List additional reference fields.
def soapListAdditionalReferenceFields(domain):
    printDebugMessage('soapListAdditionalReferenceFields', 'Begin', 1)
    result = server.listAdditionalReferenceFields(domain)
    printDebugMessage('soapListAdditionalReferenceFields', 'End', 1)
    return result['string']

def printListAdditionalReferenceFields(domain):
    printDebugMessage('printListAdditionalReferenceFields', 'Begin', 1)
    fieldsList = soapListAdditionalReferenceFields(domain)
    printArrayOfString(fieldsList)
    printDebugMessage('printListAdditionalReferenceFields', 'End', 1)

# Get referenced entries for an entry.
def soapGetReferencedEntries(domain, entry, referencedDomain):
    printDebugMessage('soapGetReferencedEntries', 'Begin', 1)
    result = server.getReferencedEntries(domain, entry, referencedDomain)
    printDebugMessage('soapGetReferencedEntries', 'End', 1)
    return result['string']

def printGetReferencedEntries(domain, entry, referencedDomain):
    printDebugMessage('printGetReferencedEntries', 'Begin', 1)
    entries = soapGetReferencedEntries(domain, entry, referencedDomain)
    printArrayOfString(entries)
    printDebugMessage('printGetReferencedEntries', 'End', 1)

# Get referenced entries for a set of entries.
def soapGetReferencedEntriesSet(domain, entries, referencedDomain, fields):
    printDebugMessage('soapGetReferencedEntriesSet', 'Begin', 1)
    if isinstance(entries, basestring):
        entryArray = {'string':entries.split(',')}
    else:
        entryArray = entries
    if isinstance(fields, basestring):
        fieldsArray = {'string':fields.split(',')}
    else:
        fieldsArray = fields
    result = server.getReferencedEntriesSet(domain, entryArray, referencedDomain, fieldsArray)
    printDebugMessage('soapGetReferencedEntriesSet', 'End', 1)
    return result['EntryReferences']

def printGetReferencedEntriesSet(domain, entries, referencedDomain, fields):
    printDebugMessage('printGetReferencedEntriesSet', 'Begin', 1)
    entries = soapGetReferencedEntriesSet(domain, entries, referencedDomain, fields)
    for entry in entries:
        print entry.entry
        for reference in entry.references.ArrayOfString:
            for fieldData in reference['string']:
                print "\t%s" %(fieldData),
            print
    printDebugMessage('printGetReferencedEntriesSet', 'End', 1)

# Get referenced entries for a set of entries (flattened result)
def soapGetReferencedEntriesFlatSet(domain, entries, referencedDomain, fields):
    printDebugMessage('soapGetReferencedEntriesFlatSet', 'Begin', 1)
    if isinstance(entries, basestring):
        entryArray = {'string':entries.split(',')}
    else:
        entryArray = entries
    if isinstance(fields, basestring):
        fieldsArray = {'string':fields.split(',')}
    else:
        fieldsArray = fields
    result = server.getReferencedEntriesFlatSet(domain, entryArray, referencedDomain, fieldsArray)
    printDebugMessage('soapGetReferencedEntriesFlatSet', 'End', 1)
    return result['ArrayOfString']

def printGetReferencedEntriesFlatSet(domain, entries, referencedDomain, fields):
    printDebugMessage('printGetReferencedEntriesFlatSet', 'Begin', 1)
    entries = soapGetReferencedEntriesFlatSet(domain, entries, referencedDomain, fields)
    for entry in entries:
        for fieldData in entry['string']:
            print "%s\t" % (fieldData),
        print
    printDebugMessage('printGetReferencedEntriesFlatSet', 'End', 1)

# Get domain hierarchy.
def soapGetDomainsHierarchy():
    printDebugMessage('soapGetDomainsHierarchy', 'Begin', 1)
    result = server.getDomainsHierarchy()
    printDebugMessage('soapGetDomainsHierarchy', 'End', 1)
    return result

# Recursive printing of a tree of DomainDescriptions
def printDomainDescription(domainDes, level):
    indent = ''
    for i in range(level):
        indent += "\t"
    print "%s%s : %s" % (indent, domainDes.id, domainDes.name)
    if domainDes.subDomains:
        level += 1
        for subDomainDes in domainDes.subDomains.DomainDescription:
            printDomainDescription(subDomainDes, level)

# Print domain hierarchy
def printGetDomainsHierarchy():
    printDebugMessage('printGetDomainsHierarchy', 'Begin', 1)
    domainHierarchy = soapGetDomainsHierarchy()
    printDomainDescription(domainHierarchy, 0)
    printDebugMessage('printGetDomainsHierarchy', 'End', 1)

# Get detailed number of results.
def soapGetDetailledNumberOfResults(domain, query, flat):
    printDebugMessage('soapGetDetailledNumberOfResults', 'Begin', 1)
    result = server.getDetailledNumberOfResults(domain, query, flat)
    printDebugMessage('soapGetDetailledNumberOfResults', 'End', 1)
    return result

# Recursive printing of a tree or list of DomainResult.
def printDomainResult(domainRes, level):
    indent = ''
    for i in range(level):
        indent += "\t"
    print "%s%s : %s" % (indent, domainRes.domainId, domainRes.numberOfResults)
    if domainRes.subDomainsResults:
        level += 1
        for subDomainRes in domainRes.subDomainsResults.DomainResult:
            printDomainResult(subDomainRes, level)

def printGetDetailledNumberOfResults(domain, query, flat):
    printDebugMessage('printGetDetailledNumberOfResults', 'Begin', 1)
    detailedResults = soapGetDetailledNumberOfResults(domain, query, flat)
    printDomainResult(detailedResults, 0)
    printDebugMessage('printGetDetailledNumberOfResults', 'End', 1)

# List field information.
def soapListFieldsInformation(domain):
    printDebugMessage('soapListFieldsInformation', 'Begin', 1)
    result = server.listFieldsInformation(domain)
    printDebugMessage('soapListFieldsInformation', 'End', 1)
    return result['FieldInfo']

def printListFieldsInformation(domain):
    printDebugMessage('printListFieldsInformation', 'Begin', 1)
    fieldInfoList = soapListFieldsInformation(domain)
    for fieldInfo in fieldInfoList:
        print "%s\t%s\t%s\t%s\t%s" % (
            fieldInfo.id, fieldInfo.name, fieldInfo.description, 
            fieldInfo.retrievable, fieldInfo.searchable)
    printDebugMessage('printListFieldsInformation', 'End', 1)

### End Functions ###

# If required enable SOAP message trace
if options.trace:
    logging.getLogger('suds.client').setLevel(logging.DEBUG)

# Create the service interface
printDebugMessage('main', 'WSDL: ' + options.WSDL, 1)
client = Client(options.WSDL)
if outputLevel > 1:
    print client
server = client.service

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

# Configure HTTP proxy from OS environment 
# (e.g. http_proxy="http://proxy.example.com:8080")
proxyOpts = dict()
if os.environ.has_key('http_proxy'):
    proxyOpts['http'] = os.environ['http_proxy'].replace('http://', '')
elif os.environ.has_key('HTTP_PROXY'):
    proxyOpts['http'] = os.environ['HTTP_PROXY'].replace('http://', '')
if 'http' in proxyOpts:
    client.set_options(proxy=proxyOpts)

# No options... print help.
if numOpts < 2:
    parser.print_help()
# List domains
elif options.listDomains:
    printListDomains()
# Get number of results.
elif options.getNumberOfResults:
    printGetNumberOfResults(options.getNumberOfResults[0], options.getNumberOfResults[1])
# Get result identifiers.
elif options.getResultsIds:
    printGetResultsIds(options.getResultsIds[0], options.getResultsIds[1], options.getResultsIds[2], options.getResultsIds[3])
# Get all result identifiers.
elif options.getAllResultsIds:
    printGetAllResultsIds(options.getAllResultsIds[0], options.getAllResultsIds[1])
# List fields.
elif options.listFields:
    printListFields(options.listFields)
# Get results.
elif options.getResults:
    printGetResults(options.getResults[0], options.getResults[1], options.getResults[2], options.getResults[3], options.getResults[4])
# Get entry.
elif options.getEntry:
    printGetEntry(options.getEntry[0], options.getEntry[1], options.getEntry[2])
# Get entries.
elif options.getEntries:
    printGetEntries(options.getEntries[0], options.getEntries[1], options.getEntries[2])
# Get URL(s) for entry fields.
elif options.getEntryFieldUrls:
    printGetEntryFieldUrls(options.getEntryFieldUrls[0], options.getEntryFieldUrls[1], options.getEntryFieldUrls[2])
# Get URL(s) for entries fields.
elif options.getEntriesFieldUrls:
    printGetEntriesFieldUrls(options.getEntriesFieldUrls[0], options.getEntriesFieldUrls[1], options.getEntriesFieldUrls[2])
# Get list of domains referenced by a domain.
elif options.getDomainsReferencedInDomain:
    printGetDomainsReferencedInDomain(options.getDomainsReferencedInDomain)
# Get list of domains references in an entry.
elif options.getDomainsReferencedInEntry:
    printGetDomainsReferencedInEntry(options.getDomainsReferencedInEntry[0], options.getDomainsReferencedInEntry[1])
# List additional reference fields.
elif options.listAdditionalReferenceFields:
    printListAdditionalReferenceFields(options.listAdditionalReferenceFields)
# Get referenced entries for an entry.
elif options.getReferencedEntries:
    printGetReferencedEntries(options.getReferencedEntries[0], options.getReferencedEntries[1], options.getReferencedEntries[2])
# Get referenced entries for a set of entries.
elif options.getReferencedEntriesSet:
    printGetReferencedEntriesSet(options.getReferencedEntriesSet[0], options.getReferencedEntriesSet[1], options.getReferencedEntriesSet[2], options.getReferencedEntriesSet[3])
# Get referenced entries for a set of entries (flattened result)
elif options.getReferencedEntriesFlatSet:
    printGetReferencedEntriesFlatSet(options.getReferencedEntriesFlatSet[0], options.getReferencedEntriesFlatSet[1], options.getReferencedEntriesFlatSet[2], options.getReferencedEntriesFlatSet[3])
# Get domain hierarchy.
elif options.getDomainsHierarchy:
    printGetDomainsHierarchy()
# Get detailed number of results.
elif options.getDetailledNumberOfResults:
    printGetDetailledNumberOfResults(options.getDetailledNumberOfResults[0], options.getDetailledNumberOfResults[1], options.getDetailledNumberOfResults[2])
# List field information.
elif options.listFieldsInformation:
    printListFieldsInformation(options.listFieldsInformation)
else:
    print 'Error: unrecognised argument combination'
    parser.print_help()
