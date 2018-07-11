#!/usr/bin/env ruby
# $Id$
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
# InterProScan (SOAP) Ruby client using soap4r.
#
# Tested with:
#   SOAP4R 1.5.5 and Ruby 1.8.6 (Ubuntu 8.04 LTS)
#   SOAP4R 1.5.5 and Ruby 1.8.7 (Ubuntu 10.04 LTS)
#   SOAP4R 1.5.8 and Ruby 1.8.7
#
# See:
# http://www.ebi.ac.uk/Tools/webservices/sss/ncbi_blast_soap
# http://www.ebi.ac.uk/Tools/webservices/tutorials/ruby
# ======================================================================
# Note: stubs need to be generated using:
# wsdl2ruby.rb --type client --wsdl http://www.ebi.ac.uk/Tools/services/soap/iprscan?wsdl
# ======================================================================
# Load libraries 
require 'getoptlong' # Command-line option handling
require 'base64' # Unpack encoded data
require 'iprscanDriver.rb' # Generated stubs

$stderr.puts <<END_OF_STRING
=============================================================================
NB: the service used by this client was decommissioned on Wednesday 9th April 
2014. See http://www.ebi.ac.uk/Tools/webservices/ for replacement services.
=============================================================================
END_OF_STRING

# Usage message
def printUsage(returnCode)
  scriptName = 'iprscan_soap4r.rb'
  puts <<END_OF_STRING
InterProScan
============

Identify protein family, domain and signal signatures in a protein sequence.

[Required]

  seqFile            : file : query sequence ("-" for STDIN)

[Optional]

      --appl         : str  : Comma separated list of signature methods to run,
                              see --paramDetail appl. 
      --nocrc        : bool : disable lookup in InterProScan matches (slower)
      --crc          : bool : enable lookup in InterProScan matches (faster)
      --goterms      : bool : enable retrieval of GO terms for InterPro signatures
      --nogoterms    : bool : disable retrieval of GO terms for InterPro signatures
 
[General]

  -h, --help        :      : prints this help text
      --async       :      : forces to make an asynchronous query
      --email       : str  : e-mail address
      --title       : str  : title for job
      --status      :      : get job status
      --resultTypes :      : get available result types for job
      --polljob     :      : poll for the status of a job
      --jobid       : str  : jobid that was returned when an asynchronous job 
                             was submitted.
      --outfile     : str  : file name for results (default is jobid;
                             "-" for STDOUT)
      --outformat   : str  : result format to retrieve
      --params      :      : list input parameters
      --paramDetail : str  : display details for input parameter
      --quiet       :      : decrease output
      --verbose     :      : increase output
      --trace       :      : show SOAP messages being interchanged 
   
Synchronous job:

  The results/errors are returned as soon as the job is finished.
  Usage: #{scriptName} --email <your\@email> [options...] seqFile
  Returns: results as an attachment

Asynchronous job:

  Use this if you want to retrieve the results at a later time. The results 
  are stored for up to 24 hours.  
  Usage: #{scriptName} --async --email <your\@email> [options...] seqFile
  Returns: jobid

  Use the jobid to query for the status of the job. If the job is finished, 
  it also returns the results/errors.
  Usage: #{scriptName} --polljob --jobid <jobId> [--outfile string]
  Returns: string indicating the status of the job and if applicable, results 
  as an attachment.

Further information:

  http://www.ebi.ac.uk/Tools/pfa/iprscan/
  http://www.ebi.ac.uk/Tools/webservices/pfa/iprscan_soap
  http://www.ebi.ac.uk/Tools/webservices/tutorials/ruby
END_OF_STRING
  exit(returnCode)
end

# Remember the number of command-line arguments before processing.
numArgs = ARGV.length

# Process command-line options
optParser = GetoptLong.new(
                           # Generic options
                           ['--help', '-h', GetoptLong::NO_ARGUMENT],
                           ['--params', GetoptLong::NO_ARGUMENT],
                           ['--paramDetail', GetoptLong::REQUIRED_ARGUMENT],
                           ['--email', GetoptLong::REQUIRED_ARGUMENT],
                           ['--title', GetoptLong::REQUIRED_ARGUMENT],
                           ['--async', GetoptLong::NO_ARGUMENT],
                           ['--jobid', GetoptLong::REQUIRED_ARGUMENT],
                           ['--status', GetoptLong::NO_ARGUMENT],
                           ['--resultTypes', GetoptLong::NO_ARGUMENT],
                           ['--polljob', GetoptLong::NO_ARGUMENT],
                           ['--outformat', GetoptLong::REQUIRED_ARGUMENT],
                           ['--outfile', GetoptLong::REQUIRED_ARGUMENT],
                           ['--quiet', GetoptLong::NO_ARGUMENT],
                           ['--verbose', GetoptLong::NO_ARGUMENT],
                           ['--debugLevel', GetoptLong::REQUIRED_ARGUMENT],
                           ['--timeout', GetoptLong::REQUIRED_ARGUMENT],
                           ['--trace', GetoptLong::NO_ARGUMENT],
                           
                           # Tool specific options
                           ['--appl',  GetoptLong::REQUIRED_ARGUMENT],
                           ['--crc', GetoptLong::NO_ARGUMENT],
                           ['--nocrc', GetoptLong::NO_ARGUMENT],
                           ['--goterms', GetoptLong::NO_ARGUMENT],
                           ['--nogoterms', GetoptLong::NO_ARGUMENT],
                           ['--sequence', GetoptLong::REQUIRED_ARGUMENT]
                           )

# Options to exclude from the options passed to launch the app
excludeOpts = {
  'help' => 1,
  'params' => 1,
  'paramDetail' => 1,
  'email' => 1,
  'title' => 1,
  'async' => 1,
  'jobid' => 1,
  'status' => 1,
  'resultTypes' => 1,
  'polljob' => 1,
  'outformat' => 1,
  'outfile' => 1,
  'quiet' => 1,
  'verbose' => 1,
  'debugLevel' => 1,
  'timeout' => 1,
  'trace' => 1,
  'appl' => 1,
  'crc' => 1,
  'nocrc' => 1,
  'goterms' =>1,
  'nogoterms' => 1
}

# Wrapping class for working with the application
class EbiWsIPRScan
  # Accessor methods for attributes
  attr_reader :timeout, :outputLevel, :debugLevel

  # Constructor
  def initialize(outputLevel, debugLevel, trace, timeout)
    @soap = nil
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
  
  # Get list of input parameters
  def getParams()
    printDebugMessage('getParams', 'Begin', 1)
    soapConnect
    req = GetParameters.new()
    res = @soap.getParameters(req)
    if(2 <= @debugLevel)
      p res
    end
    # 'id' is a restricted attribute name, so a work-around is required to access this attribute
    params = res.parameters.instance_variable_get(:@id)
    printDebugMessage('getParams', 'End', 1)
    return params
  end
  
  # Print list of parameter names
  def printParams()
    printDebugMessage('printParams', 'Begin', 1)
    paramsList = getParams()
    paramsList.each { |param|
      puts param
    }
    printDebugMessage('printParams', 'End', 1)
  end
  
  # Get detail about a parameter
  def getParamDetail(paramName)
    printDebugMessage('getParamDetail', 'Begin', 1)
    soapConnect
    req = GetParameterDetails.new()
    req.parameterId = paramName
    res = @soap.getParameterDetails(req)
    if(2 <= @debugLevel)
      p res
    end
    printDebugMessage('getParamDetail', 'Begin', 1)
    return res.parameterDetails
  end

  # Print detail about a parameter
  def printParamDetail(paramName)
    printDebugMessage('printParamDetail', 'Begin', 1)
    paramDetail = getParamDetail(paramName)
    puts paramDetail.name + "\t" + paramDetail.instance_variable_get(:@type)
    puts paramDetail.description
    paramDetail.values.value.each { |value|
      print value.value
      if(value.defaultValue)
        print "\tdefault"
      end
      puts
      if(value.label)
        puts "\t" + value.label
      end
      if(value.properties)
        value.properties.property.each { |wsProperty|
          puts "\t" + wsProperty.key + "\t" + wsProperty.value
        }
      end
    }
    printDebugMessage('printParamDetail', 'End', 1)
  end

  # Submit a job
  def run(email, title, params)
    printDebugMessage('run', 'Begin', 1)
    printDebugMessage('run', 'email: ' + email, 1)
    printDebugMessage('run', 'title: ' + title, 1)
    soapConnect
    req = Run.new()
    req.email = email
    req.title = title
    req.parameters = params
    res = @soap.run(req)
    printDebugMessage('run', 'End', 1)
    return res.jobId
  end

  # Get job status
  def getStatus(jobId)
    printDebugMessage('getStatus', 'Begin', 1)
    soapConnect
    req = GetStatus.new()
    req.jobId = jobId
    res = @soap.getStatus(req)
    printDebugMessage('getStatus', 'End', 1)
    return res.status
  end
  
  # Print job status
  def printStatus(jobId)
    printDebugMessage('printStatus', 'Begin', 1)
    status = getStatus(jobId)
    puts status
    printDebugMessage('printStatus', 'End', 1)
  end
  
  # Wait for job to finish
  def clientPoll(jobId)
    printDebugMessage('clientPoll', 'Begin', 1)
    status = 'PENDING'
    while(status == 'PENDING' || status == 'RUNNING') do
      status = getStatus(jobId)
      puts status
      sleep(5) if(status == 'PENDING' || status == 'RUNNING')
    end
    printDebugMessage('clientPoll', 'End', 1)
  end
  
  # Get result types
  def getResultTypes(jobId)
    printDebugMessage('getResultTypes', 'Begin', 1)
    clientPoll(jobId)
    soapConnect
    req = GetResultTypes.new()
    req.jobId = jobId
    res = @soap.getResultTypes(req)
    # 'type' is a restricted attribute name, so a work-around is required 
    # to access this attribute
    resultTypes = res.resultTypes.instance_variable_get(:@type)
    printDebugMessage('getResultTypes', 'End', 1)
    return resultTypes
  end

  # Print result types
  def printResultTypes(jobId)
    printDebugMessage('printResultTypes', 'Begin', 1)
    resultTypes = getResultTypes(jobId)
    resultTypes.each { |resultType|
      puts resultType.identifier
      puts "\t" + resultType.label if(resultType.label)
      puts "\t" + resultType.description if(resultType.description)
      puts "\t" + resultType.mediaType if(resultType.mediaType)
      puts "\t" + resultType.fileSuffix if(resultType.fileSuffix)
    }
    printDebugMessage('printResultTypes', 'End', 1)
  end

  # Get result for a job of the specified format
  def getResult(jobId, type, params)
    printDebugMessage('getResult', 'Begin', 1)
    printDebugMessage('getResult', 'jobId: ' + jobId, 1)
    printDebugMessage('getResult', 'type: ' + type, 1)
    soapConnect
    req = GetResult.new()
    req.jobId = jobId
    req.type = type
    req.parameters = params
    res = @soap.getResult(req)
	# As a work-around, we need to double decode
    resultData = Base64.decode64(Base64.decode64(res.output))
    printDebugMessage('getResult', 'End', 1)
    return resultData
  end
  
  def writeResultFile(jobId, outFormat, outFileName)
      result = getResult(jobId, outFormat, nil)
      outFile = File.new(outFileName, 'wb')
      outFile.write(result)
      outFile.close
  end
  
  def getResultFile(jobId, outFormat, outFileBase)
    printDebugMessage('getResultFile', 'Begin', 1)
    printDebugMessage('getResultFile', 'jobId: ' + jobId, 1)
    printDebugMessage('getResultFile', 'outFormat: ' + outFormat, 1)
    printDebugMessage('getResultFile', 'outFileBase: ' + outFileBase, 1)
    resultTypes = getResultTypes(jobId)
    selResultType = nil
    resultTypes.each { |resultType|
      selResultType = resultType if(resultType.identifier == outFormat)
    }
    if(selResultType)
      printDebugMessage('getResultFile', 'selResultType: ' + selResultType.identifier, 2)
      outFileName = "#{outFileBase}.#{selResultType.identifier}.#{selResultType.fileSuffix}"
      writeResultFile(jobId, selResultType.identifier, outFileName)
      puts "Wrote #{outFileName}"
    end
    printDebugMessage('getResultFile', 'End', 1)
  end

  def getResultFiles(jobId, outFileBase)
    printDebugMessage('getResultFiles', 'Begin', 1)
    printDebugMessage('getResultFiles', 'jobId: ' + jobId, 1)
    printDebugMessage('getResultFiles', 'outFileBase: ' + outFileBase, 1)
    resultTypes = getResultTypes(jobId)
    # Write result to file !!!
    resultTypes.each { |resultType|
      printDebugMessage('getResultFiles', 'resultType: ' + resultType.identifier, 2)
      outFileName = "#{outFileBase}.#{resultType.identifier}.#{resultType.fileSuffix}"
      writeResultFile(jobId, resultType.identifier, outFileName)
      puts "Wrote #{outFileName}"
    }    
    printDebugMessage('getResultFiles', 'End', 1)
  end

  private

  # Set the User-agent for client requests.
  # Note: this assumes details about the internals of SOAP4R.
  def soapUserAgent()
    printDebugMessage('soapUserAgent', 'Begin', 11)
    # Construct the User-agent string.
    clientRevision = '$Revision$'
    clientVersion = '0'
    if clientRevision.length > 11
      clientVersion = clientRevision[11..-3]
    end
    userAgent = "EBI-Sample-Client/#{clientVersion} (#{self.class.name}; Ruby #{RUBY_VERSION}; #{RUBY_PLATFORM}) "
    # Check if we can set it.
    begin
      require 'soap/netHttpClient' # SOAP4R HTTP transport
      require 'http-access2' # HTTP transport based on http-access2
      require 'httpclient' # 'http-access2' is now called 'httpclient'
    rescue LoadError => ex
      printDebugMessage('soapUserAgent', 'Unable to load modules', 12)
      if @debugLevel > 12
        $stderr.puts ex
        $stderr.puts ex.backtrace
      end
    end
    if @soap.proxy.streamhandler.client.kind_of? SOAP::NetHttpClient
      # HTTP transport provided with SOAP4R.
      userAgent += @soap.proxy.streamhandler.client.instance_variable_get('@agent')
      printDebugMessage('soapUserAgent', 'userAgent: ' + userAgent, 11)
      @soap.proxy.streamhandler.client.instance_variable_set('@agent', userAgent)
    elsif (@soap.proxy.streamhandler.client.kind_of? HTTPClient) || (@soap.proxy.streamhandler.client.kind_of? HTTPAccess2::Client)
      # Alternative HTTP transport using 'httpclient'/'http-access2'
      userAgent += @soap.proxy.streamhandler.client.agent_name
      printDebugMessage('soapUserAgent', 'userAgent: ' + userAgent, 11)
      @soap.proxy.streamhandler.client.agent_name = userAgent
    else
      # Unknown transport.
      printDebugMessage('soapUserAgent', "Unable to set User-Agent, SOAP client uses #{@soap.proxy.streamhandler.client.class}", 11)
    end
    printDebugMessage('soapUserAgent', 'End', 11)
  end
  
  # Get a SOAP proxy object to access the service.
  def soapConnect
    printDebugMessage('soapConnect', 'Begin', 11)
    if !@soap
      # Create the service proxy
      @soap = JDispatcherService.new()
      @soap.options["protocol.http.connect_timeout"] = @timeout
      @soap.options["protocol.http.receive_timeout"] = @timeout
      @soap.wiredump_dev = STDOUT if @trace
      # Try to set a user-agent.
      begin
	soapUserAgent()
      rescue
        if argHash['debugLevel'].to_i > 10
          $stderr.puts ex
          $stderr.puts ex.backtrace
        end
        printDebugMessage('soapConnect', 'Unable to set User-agent', 11)
      end
    end
    printDebugMessage('soapConnect', 'End', 11)
  end
    
end

# Process command line options
begin
  argHash = {}
  argHash['debugLevel'] = 0
  argHash['title'] = ''
  optParser.each do |name, arg|
    key = name.sub(/^--/, '') # Clean up the argument name
    argHash[key] = arg
  end
  params = InputParameters.new
  argHash.each do |key, arg|
    # For application options add to the params hash
    if !excludeOpts[key]
      if arg != ''
        eval "params.#{key} = arg"
      else
        eval "params.#{key} = 1"
      end
    end
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
  ebiWsApp = EbiWsIPRScan.new(argHash['outputLevel'], argHash['debugLevel'], argHash['trace'], timeout)
  
  # Help info
  if argHash['help'] || numArgs == 0
    printUsage(0)

  # Get list of parameter names
  elsif argHash['params']
    ebiWsApp.printParams()

  # Get details for a parameter
  elsif argHash['paramDetail']
    ebiWsApp.printParamDetail(argHash['paramDetail'])

  # Job based actions
  elsif argHash['jobid']
    puts "JobID: " + argHash['jobid']
    # Get job status
    if argHash['status'] 
      ebiWsApp.printStatus(argHash['jobid'])
    # Get result types
    elsif argHash['resultTypes'] 
      ebiWsApp.printResultTypes(argHash['jobid'])
    # Get job results
    elsif argHash['polljob']
      jobId = argHash['jobid']
      if !argHash['outfile']
        argHash['outfile'] = jobId
      end
      if argHash['outformat']
        ebiWsApp.getResultFile(jobId, argHash['outformat'], argHash['outfile'])
      else
        ebiWsApp.getResultFiles(jobId, argHash['outfile'])
      end
    else
      $stderr.print 'Error: for --jobid requires an action (e.g. --status, --resultTypes, --polljob'
      exit(1)
    end

  # Submit a job
  elsif(ARGV[0] || argHash['sequence'])
    # Get input data to pass to service.
    inputData = ARGV[0] || argHash['sequence']
    if(inputData)
      # TODO: read data from STDIN.
      if File.exist?(inputData)
        # Read input from file.
        inFile = File.open(inputData, 'rb') # Read data in binary mode.
        params.sequence = inFile.read
        inFile.close
      else
        # Use parameter value as input.
        params.sequence = inputData
      end
    end
    # List of applications. Convert into list.
    if(argHash['appl'])
      applList = ArrayOfString.new
      tmpApplList = argHash['appl'].split(/[ ,]+/)
      tmpApplList.each { |applName| applList << applName}
      params.appl = applList
    end
    # Convert flag options.
    if(argHash['crc'])
      params.nocrc = false
    elsif(argHash['nocrc'])
      params.nocrc = true
    end
    if(argHash['goterms'])
      params.goterms = true
    elsif(argHash['nogoterms'])
      params.goterms = false
    end
    jobId = ebiWsApp.run(argHash['email'], argHash['title'], params)
    # In synchronous mode can now get results otherwise print the jobId
    puts 'JobId: ' + jobId
    if !argHash['async']
      if !argHash['outfile']
        argHash['outfile'] = jobId
      end
      if argHash['outformat']
        ebiWsApp.getResultFile(jobId, argHash['outformat'], argHash['outfile'])
      else
        ebiWsApp.getResultFiles(jobId, argHash['outfile'])
      end
    end

  # Unsupported combination of options (or no options)
  else
    $stderr.puts "Error: unknown option combination"
    exit(1)
  end

# Catch any exceptions and display
rescue StandardError => ex
  $stderr.puts 'Exception'
  $stderr.puts ex
  if argHash['debugLevel'].to_i > 0
    $stderr.puts ex.backtrace
  end
  exit(2)
end
