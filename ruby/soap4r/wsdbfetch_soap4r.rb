#!/usr/bin/env ruby
# $Id$
# ======================================================================
# WSDbfetch document/literal SOAP service Ruby client.
#
# Tested with:
#   SOAP4R 1.5.5 and Ruby 1.8.6 (Ubuntu 8.04 LTS)
#
# See:
# http://www.ebi.ac.uk/Tools/webservices/services/dbfetch
# http://www.ebi.ac.uk/Tools/webservices/tutorials/ruby
# ======================================================================
# Load libraries 
require 'getoptlong' # Command-line option handling
require 'soap/wsdlDriver'

# WSDL URL for service
wsdl = 'http://www.ebi.ac.uk/ws/services/WSDbfetchDoclit?wsdl'

# Usage message
def printUsage(returnCode)
  puts <<END_OF_STRING
Usage:
  wsdbfetch.rb <method> [arguments...]

A number of methods are available:

  getSupportedDBs - list available databases
  getSupportedFormats - list available databases with formats
  getSupportedStyles - list available databases with styles
  getDbFormats - list formats for a specifed database
  getFormatStyles - list styles for a specified database and format
  fetchData - retrive an database entry. See below for details of arguments.
  fetchBatch - retrive database entries. See below for details of arguments.

Fetching an entry: fetchData

  wsdbfetch.rb fetchData <dbName:id> [format [style]]

  dbName:id  database name and entry ID or accession (e.g. UNIPROT:WAP_RAT)
  format     format to retrive (e.g. uniprot)
  style      style to retrive (e.g. raw)

Fetching entries: fetchBatch

  wsdbfetch.rb fetchBatch <dbName> <idList> [format [style]]

  dbName     database name (e.g. UNIPROT)
  idList     list of entry IDs or accessions (e.g. 1433T_RAT,WAP_RAT).
             Maximum of 200 IDs or accessions.
  format     format to retrive (e.g. uniprot)
  style      style to retrive (e.g. raw)
END_OF_STRING
  exit(returnCode)
end

# Process command-line options
optParser = GetoptLong.new(
                           ['--help', '-h', GetoptLong::NO_ARGUMENT],
                           ['--quiet', '-q', GetoptLong::NO_ARGUMENT],
                           ['--verbose', '-v', GetoptLong::NO_ARGUMENT],
                           ['--debugLevel', GetoptLong::REQUIRED_ARGUMENT],
                           ['--timeout', GetoptLong::REQUIRED_ARGUMENT],
                           ['--trace', GetoptLong::NO_ARGUMENT],
                           ['--WSDL', GetoptLong::REQUIRED_ARGUMENT]
                           )

# Wrapping class for working with the application
class EbiWsAppl
  # Accessor methods for attributes
  attr_reader :wsdl, :timeout, :outputLevel, :debugLevel

  # Constructor
  def initialize(wsdl, outputLevel, debugLevel, trace, timeout)
    @wsdl = wsdl
    @outputLevel = outputLevel.to_i
    @debugLevel = debugLevel.to_i
    @trace = trace
    @timeout = timeout
  end
  
  # Print debug message
  def printDebugMessage(methodName, message, level)
    if(level <= @debugLevel)
      puts '[' + methodName + '] ' + message
    end
  end
  
  # Get list of database names.
  def soapGetSupportedDBs()
    printDebugMessage('soapGetSupportedDBs', 'Begin', 1)
    soap = soapConnect
    res = soap.getSupportedDBs({})
    if(2 <= @debugLevel)
      p res
    end
    printDebugMessage('soapGetSupportedDBs', 'End', 1)
    return res['getSupportedDBsReturn']
  end

  # Print list of database names.
  def printGetSupportedDBs()
    printDebugMessage('printGetSupportedDBs', 'Begin', 1)
    paramsList = soapGetSupportedDBs()
    paramsList.each { |param|
      puts param
    }
    printDebugMessage('printGetSupportedDBs', 'End', 1)
  end

  # Get list of database and format names.
  def soapGetSupportedFormats()
    printDebugMessage('soapGetSupportedFormats', 'Begin', 1)
    soap = soapConnect
    res = soap.getSupportedFormats({})
    if(2 <= @debugLevel)
      p res
    end
    printDebugMessage('soapGetSupportedFormats', 'End', 1)
    return res['getSupportedFormatsReturn']
  end

  # Print list of database and format names.
  def printGetSupportedFormats()
    printDebugMessage('printGetSupportedFormats', 'Begin', 1)
    paramsList = soapGetSupportedFormats()
    paramsList.each { |param|
      puts param
    }
    printDebugMessage('printGetSupportedFormats', 'End', 1)
  end

  # Get list of database and style names.
  def soapGetSupportedStyles()
    printDebugMessage('soapGetSupportedStyles', 'Begin', 1)
    soap = soapConnect
    res = soap.getSupportedStyles({})
    if(2 <= @debugLevel)
      p res
    end
    printDebugMessage('soapGetSupportedStyles', 'End', 1)
    return res['getSupportedStylesReturn']
  end

  # Print list of database and style names.
  def printGetSupportedStyles()
    printDebugMessage('printGetSupportedStyles', 'Begin', 1)
    paramsList = soapGetSupportedStyles()
    paramsList.each { |param|
      puts param
    }
    printDebugMessage('printGetSupportedStyles', 'End', 1)
  end

  # Get list of format names for a database.
  def soapGetDbFormats(dbName)
    printDebugMessage('soapGetDbFormats', 'Begin', 1)
    soap = soapConnect
    res = soap.getDbFormats(dbName)
    if(2 <= @debugLevel)
      p res
    end
    printDebugMessage('soapGetDbFormats', 'End', 1)
    return res['getDbFormatsReturn']
  end

  # Print list of format names for a database.
  def printGetDbFormats(dbName)
    printDebugMessage('printGetDbFormats', 'Begin', 1)
    paramsList = soapGetDbFormats({'db' => dbName})
    paramsList.each { |param|
      puts param
    }
    printDebugMessage('printGetDbFormats', 'End', 1)
  end

  # Get list of style names for a format of a database.
  def soapGetFormatStyles(dbName, formatName)
    printDebugMessage('soapGetFormatStyles', 'Begin', 1)
    soap = soapConnect
    res = soap.getFormatStyles({'db' => dbName, 'format' => formatName})
    if(2 <= @debugLevel)
      p res
    end
    printDebugMessage('soapGetFormatStyles', 'End', 1)
    return res['getFormatStylesReturn']
  end

  # Print list of style names for a format of a database.
  def printGetFormatStyles(dbName, formatName)
    printDebugMessage('printGetFormatStyles', 'Begin', 1)
    paramsList = soapGetFormatStyles(dbName, formatName)
    paramsList.each { |param|
      puts param
    }
    printDebugMessage('printGetFormatStyles', 'End', 1)
  end

  # Fetch an entry.
  def soapFetchData(query, formatName, styleName)
    printDebugMessage('soapFetchData', 'Begin', 1)
    soap = soapConnect
    res = soap.fetchData({
                           'query' => query, 
                           'format' => formatName,
                           'style' => styleName
                         })
    if(2 <= @debugLevel)
      p res
    end
    printDebugMessage('soapFetchData', 'End', 1)
    return res['fetchDataReturn']
  end

  # Print an entry.
  def printFetchData(query, formatName, styleName)
    printDebugMessage('printFetchData', 'Begin', 1)
    entryStr = soapFetchData(query, formatName, styleName)
    puts entryStr
    printDebugMessage('printFetchData', 'End', 1)
  end

  # Fetch a set of entries.
  def soapFetchBatch(dbName, idListStr, formatName, styleName)
    printDebugMessage('soapFetchBatch', 'Begin', 1)
    soap = soapConnect
    res = soap.fetchBatch({
                            'db' => dbName,
                            'ids' => idListStr, 
                            'format' => formatName,
                            'style' => styleName
                          })
    if(2 <= @debugLevel)
      p res
    end
    printDebugMessage('soapFetchBatch', 'End', 1)
    return res['fetchBatchReturn']
  end

  # Print a set of entryies.
  def printFetchBatch(dbName, idListStr, formatName, styleName)
    printDebugMessage('printFetchBatch', 'Begin', 1)
    entriesStr = soapFetchBatch(dbName, idListStr, formatName, styleName)
    puts entriesStr
    printDebugMessage('printFetchBatch', 'End', 1)
  end

  private
  def soapConnect
    printDebugMessage('soapConnect', 'Begin', 11)
    # Create the service proxy
    soap = SOAP::WSDLDriverFactory.new(@wsdl).create_rpc_driver
    soap.options["protocol.http.connect_timeout"] = @timeout
    soap.options["protocol.http.receive_timeout"] = @timeout
    soap.wiredump_dev = STDOUT if @trace
    printDebugMessage('soapConnect', 'End', 11)
    return soap
  end

end

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
  # Set WSDL URL
  if argHash['WSDL']
    wsdl = argHash['WSDL']
  end
  ebiWsApp = EbiWsAppl.new(
                           wsdl, 
                           argHash['outputLevel'], 
                           argHash['debugLevel'], 
                           argHash['trace'], 
                           timeout)
  
  # Help info
  if argHash['help'] || ARGV.length == 0
    printUsage(0)

  # Get list of database names
  elsif ARGV[0] == 'getSupportedDBs'
    ebiWsApp.printGetSupportedDBs()

  # Get list of database and format names
  elsif ARGV[0] == 'getSupportedFormats'
    ebiWsApp.printGetSupportedFormats()

  # Get list of database and style names
  elsif ARGV[0] == 'getSupportedStyles'
    ebiWsApp.printGetSupportedStyles()

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
    styleName = 'default'
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
    styleName = 'default'
    if ARGV.length > 4
      styleName = ARGV[4]
    end
    ebiWsApp.printFetchBatch(ARGV[1], ARGV[2], formatName, styleName)

  # Unsupported combination of options (or no options)
  else
    $stderr.puts "Error: unknown option combination"
    exit(1)
  end

# Catch any exceptions and display
rescue StandardError => ex
  $stderr.puts 'Exception'
  $stderr.puts ex
end
