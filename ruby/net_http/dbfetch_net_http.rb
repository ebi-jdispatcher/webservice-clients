#!/usr/bin/env ruby
# $Id$
# ======================================================================
# WSDbfetch (REST) Ruby client using net/http.
#
# Tested with:
#   Ruby 1.8.6 (Ubuntu 8.04 LTS)
#   Ruby 1.8.7 (Ubuntu 10.04 LTS)
#
# See:
# http://www.ebi.ac.uk/Tools/webservices/dbfetch_rest
# http://www.ebi.ac.uk/Tools/webservices/tutorials/ruby
# ======================================================================
# Load libraries 
require 'getoptlong' # Command-line option handling
require 'net/http' # HTTP connections
require 'uri' # URI parsing
require 'rexml/document' # XML parsing

# Usage message
def printUsage(returnCode)
  scriptName = 'dbfetch_net_http.rb'
  puts <<END_OF_STRING
Usage:
  #{scriptName} <method> [arguments...]

A number of methods are available:

  getSupportedDBs - list available databases
  getSupportedFormats - list available databases with formats
  getDbFormats - list formats for a specifed database
  getFormatStyles - list styles for a specified database and format
  fetchData - retrive an database entry. See below for details of arguments.
  fetchBatch - retrive database entries. See below for details of arguments.

Fetching an entry: fetchData

  #{scriptName} fetchData <dbName:id> [format [style]]

  dbName:id  database name and entry ID or accession (e.g. UNIPROT:WAP_RAT)
  format     format to retrive (e.g. uniprot)
  style      style to retrive (e.g. raw)

Fetching entries: fetchBatch

  #{scriptName} fetchBatch <dbName> <idList> [format [style]]

  dbName     database name (e.g. UNIPROT)
  idList     list of entry IDs or accessions (e.g. 1433T_RAT,WAP_RAT).
             Maximum of 200 IDs or accessions.
  format     format to retrive (e.g. uniprot)
  style      style to retrive (e.g. raw)
END_OF_STRING
  exit(returnCode)
end

# Wrapping class for working with the application
class EbiWsDbfetchRest
  # Accessor methods for attributes
  attr_reader :timeout, :outputLevel, :debugLevel, :baseUrl

  # Constructor
  def initialize(outputLevel, debugLevel, timeout)
    @baseUrl = 'http://www.ebi.ac.uk/Tools/dbfetch/dbfetch'
    @outputLevel = outputLevel.to_i
    @debugLevel = debugLevel.to_i
    @timeout = timeout
    @dbInfoList = nil
  end

  # Print debug message
  def printDebugMessage(methodName, message, level)
    if(level <= @debugLevel)
      puts '[' + methodName + '] ' + message
    end
  end
  
  # Get the User-agent for client requests.
  def getUserAgent()
    printDebugMessage('getUserAgent', 'Begin', 11)
    clientRevision = '$Revision$'
    clientVersion = '0'
    if clientRevision.length > 11
       clientVersion = clientRevision[11..-3]
    end
    userAgent = "EBI-Sample-Client/#{clientVersion} (#{self.class.name}; Ruby #{RUBY_VERSION}; #{RUBY_PLATFORM}) "
    printDebugMessage('getUserAgent', "userAgent: #{userAgent}", 11)
    printDebugMessage('getUserAgent', 'End', 11)
    return userAgent
  end

  # Get a HTTP connection.
  def getHttpConnection(uri)
    printDebugMessage('getHttpConnection', 'Begin', 11)
    # TODO: HTTP proxy support.
    if(@httpConn == nil)
      # Create a HTTP connection
      @httpConn = Net::HTTP.new(uri.host, uri.port)
    end
    printDebugMessage('getHttpConnection', 'End', 11)
  end

  # Perform an HTTP GET request
  def restRequest(url)
    # TODO: HTTP compression support (for Ruby 1.8, in 1.9 used as standard)
    printDebugMessage('restRequest', 'Begin', 11)
    printDebugMessage('restRequest', 'url: ' + url, 12)
    # Split URL into components
    uri = URI.parse(url)
    # Get the resource
    userAgent = getUserAgent()
    if uri.query
      path = "#{uri.path}?#{uri.query}"
    else
      path = uri.path
    end
    getHttpConnection(uri)
    resp, data = @httpConn.get(path, {'User-agent' => userAgent})
    printDebugMessage('restRequest', 'data: ' + data, 21)
    printDebugMessage('restRequest', 'End', 11)
    return data
  end

  # Get meta-information from the service.
  def restGetMetaInformation()
    printDebugMessage('restGetMetaInformation', 'Begin', 11)
    url = "#{baseUrl}/dbfetch.databases?style=xml"
    xmlDoc = restRequest(url)
    doc = REXML::Document.new(xmlDoc, { :ignore_whitespace_nodes => :all })
    printDebugMessage('restGetMetaInformation', 'End', 11)
    return doc.root.elements['//databaseInfoList']
  end

  # Get list of database information.
  # Web service result is cached for future requests.
  def getDatabaseInfoList()
    printDebugMessage('getDatabaseInfoList', 'Begin', 11)
    if @dbInfoList == nil
      @dbInfoList = restGetMetaInformation()
    end
    printDebugMessage('getDatabaseInfoList', 'End', 11)
    return @dbInfoList
  end

  # Get database info for a database.
  def getDatabaseInfo(dbName)
    printDebugMessage('getDatabaseInfo', 'Begin', 11)
    dbInfo = nil
    dbInfoList = getDatabaseInfoList()
    dbInfoList.each{ |tmpDbInfo|
      if tmpDbInfo.elements['name'].text == dbName
        dbInfo = tmpDbInfo
      else
        tmpDbInfo.each_element('aliasList/alias') { |value|
          if value.text == dbName
            dbInfo = tmpDbInfo
          end
        }
      end
    }
    printDebugMessage('getDatabaseInfo', 'End', 11)
    return dbInfo
  end

  # Get information about a format of a database.
  def getFormatInfo(dbName, formatName)
    printDebugMessage('getFormatInfo', 'Begin', 11)
    formatInfo = nil
    dbInfo = getDatabaseInfo(dbName)
    dbInfo.each_element('formatInfoList/formatInfo') { |tmpFormatInfo|
      if tmpFormatInfo.elements['name'].text == formatName
        formatInfo = tmpFormatInfo
      else
        tmpFormatInfo.each_element('aliases/alias') { |value|
          if value.text == formatName
            formatInfo = tmpFormatInfo
          end
        }
      end
    }
    printDebugMessage('getFormatInfo', 'End', 11)
    return formatInfo
  end
  
  # Print list of database names.
  def printGetSupportedDBs()
    printDebugMessage('printGetSupportedDBs', 'Begin', 1)
    dbInfoList = getDatabaseInfoList()
    dbInfoList.each{ |dbInfo|
      puts dbInfo.elements['name'].text
    }
    printDebugMessage('printGetSupportedDBs', 'End', 1)
  end

  # Print list of database and format names.
  def printGetSupportedFormats()
    printDebugMessage('printGetSupportedFormats', 'Begin', 1)
    dbInfoList = getDatabaseInfoList()
    dbInfoList.each{ |dbInfo|
      fmtStr = ''
      itemNum = 0
      dbInfo.each_element('formatInfoList/formatInfo') { |formatInfo|
        fmtStr += ',' if(itemNum > 0)
        fmtStr += formatInfo.elements['name'].text
        itemNum += 1
      }
      
      puts dbInfo.elements['name'].text + "\t" + fmtStr
    }
    printDebugMessage('printGetSupportedFormats', 'End', 1)
  end

  # Print list of format names for a database.
  def printGetDbFormats(dbName)
    printDebugMessage('printGetDbFormats', 'Begin', 1)
    dbInfo = getDatabaseInfo(dbName)
    if dbInfo != nil
      dbInfo.each_element('formatInfoList/formatInfo') { |formatInfo|
        puts formatInfo.elements['name'].text
      }
    end
    printDebugMessage('printGetDbFormats', 'End', 1)
  end

  # Print list of style names for a format of a database.
  def printGetFormatStyles(dbName, formatName)
    printDebugMessage('printGetFormatStyles', 'Begin', 1)
    formatInfo = getFormatInfo(dbName, formatName)
    if formatInfo != nil
      formatInfo.each_element('styleInfoList/styleInfo') { |styleInfo|
        puts styleInfo.elements['name'].text
      }
    end
    printDebugMessage('printGetFormatStyles', 'End', 1)
  end

  # Fetch an entry.
  # retStr = restFetchData('uniprot:wap_rat', 'default', 'default')
  def restFetchData(query, formatName='default', styleName='default')
    printDebugMessage('restFetchData', 'Begin', 1)
    partList = query.split(':')
    retVal = restFetchBatch(partList[0], partList[1], formatName, styleName)
    printDebugMessage('restFetchData', 'End', 1)
    return retVal
  end

  # Print an entry.
  def printFetchData(query, formatName='default', styleName='default')
    printDebugMessage('printFetchData', 'Begin', 1)
    entryStr = restFetchData(query, formatName, styleName)
    puts entryStr
    printDebugMessage('printFetchData', 'End', 1)
  end

  # Fetch a set of entries.
  def restFetchBatch(dbName, idListStr, formatName='default', styleName='default')
    printDebugMessage('restFetchBatch', 'Begin', 1)
    url = "#{baseUrl}/#{dbName}/#{idListStr}/#{formatName}?style=#{styleName}"
    retVal = restRequest(url)
    printDebugMessage('restFetchBatch', 'End', 1)
    return retVal
  end

  # Print a set of entryies.
  def printFetchBatch(dbName, idListStr, formatName='default', styleName='default')
    printDebugMessage('printFetchBatch', 'Begin', 1)
    entriesStr = restFetchBatch(dbName, idListStr, formatName, styleName)
    puts entriesStr
    printDebugMessage('printFetchBatch', 'End', 1)
  end

end

# Process command-line options
optParser = GetoptLong.new(
                           # Generic options
                           ['--help', '-h', GetoptLong::NO_ARGUMENT],
                           ['--quiet', GetoptLong::NO_ARGUMENT],
                           ['--verbose', GetoptLong::NO_ARGUMENT],
                           ['--debugLevel', GetoptLong::REQUIRED_ARGUMENT],
                           ['--timeout', GetoptLong::REQUIRED_ARGUMENT],
                           ['--baseUrl', GetoptLong::REQUIRED_ARGUMENT]
                           )

# Process command line options
begin
  argHash = {}
  argHash['debugLevel'] = 0
  optParser.each do |name, arg|
    key = name.sub(/^--/, '') # Clean up the argument name
    argHash[key] = arg
  end
rescue
  $stderr.print 'Error: command line parsing failed: ' + $!
  exit(1)
end

# Do the requested actions
begin
  # Set timeout for connection
  if argHash['timeout']
    timeout = argHash['timeout'].to_i
  else
    timeout = 120
  end
  ebiWsApp = EbiWsDbfetchRest.new(argHash['outputLevel'], argHash['debugLevel'], timeout)
  if argHash['baseUrl']
    ebiWsApp.baseUrl = argHash['baseUrl']
  end
  
  # Help info
  if argHash['help']
    printUsage(0)

  # Get list of database names
  elsif ARGV[0] == 'getSupportedDBs'
    ebiWsApp.printGetSupportedDBs()

  # Get list of database and format names
  elsif ARGV[0] == 'getSupportedFormats'
    ebiWsApp.printGetSupportedFormats()

  # Get list of format names for a database.
  elsif ARGV[0] == 'getDbFormats' && ARGV.length > 1
    ebiWsApp.printGetDbFormats(ARGV[1])

  # Get list of style names for a format of a database.
  elsif ARGV[0] == 'getFormatStyles' && ARGV.length > 2
    ebiWsApp.printGetFormatStyles(ARGV[1], ARGV[2])

  # Fetch an entry.
  elsif ARGV[0] == 'fetchData' && ARGV.length > 1
    formatName = 'default'
    if ARGV.length > 2
      formatName = ARGV[2]
    end
    styleName = 'raw'
    if ARGV.length > 3
      styleName = ARGV[3]
    end
    ebiWsApp.printFetchData(ARGV[1], formatName, styleName)

  # Fetch a set of entries.
  elsif ARGV[0] == 'fetchBatch' && ARGV.length > 2
    formatName = 'default'
    if ARGV.length > 3
      formatName = ARGV[3]
    end
    styleName = 'raw'
    if ARGV.length > 4
      styleName = ARGV[4]
    end
    ebiWsApp.printFetchBatch(ARGV[1], ARGV[2], formatName, styleName)

  # Unsupported combination of options (or no options)
  else
    $stderr.print "Error: unknown option combination\n"
    exit(1)
  end

# Catch any exceptions and display
rescue StandardError => ex
  puts ex
end
