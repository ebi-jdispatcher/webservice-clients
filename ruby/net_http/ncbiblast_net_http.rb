#!/usr/bin/env ruby
# $Id$
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
# NCBI BLAST (REST) sample Ruby client using net/http and REXML.
#
# Tested with:
#   Ruby 1.8.6 (Ubuntu 8.04 LTS)
#   Ruby 1.8.7 (Ubuntu 10.04 LTS)
#
# See:
# http://www.ebi.ac.uk/Tools/webservices/sss/ncbi_blast_rest
# http://www.ebi.ac.uk/Tools/webservices/tutorials/ruby
# ======================================================================
# Load libraries 
require 'getoptlong' # Command-line option handling
require 'net/http' # HTTP connections
require 'uri' # URI parsing
require 'cgi' # CGI module to escape post data
require 'rexml/document' # XML parsing

# Usage message
def printUsage(returnCode)
  scriptName = 'ncbiblast_net_http.rb'
  puts <<END_OF_STRING
NCBI BLAST
==========
   
Rapid sequence database search programs utilising the BLAST algorithm

[Required]

  -p, --program     : str  : BLAST program to use, see --paramDetail program
  -D, --database    : str  : database(s) to search, space separated. See
                             --paramDetail database
      --stype       : str  : query sequence type, see --paramDetail stype
  seqFile           : file : query sequence ("-" for STDIN)

[Optional]

  -m, --matrix      : str  : scoring matrix, see --paramDetail matrix
  -e, --exp         : real : 0<E<= 1000. Statistical significance threshold 
                             for reporting database sequence matches.
  -f, --filter      : str  : filter the query sequence for low complexity 
                             regions, see --paramDetail filter
  -A, --align       : int  : pairwise alignment format, see --paramDetail align
  -s, --scores      : int  : number of scores to be reported
  -n, --alignments  : int  : number of alignments to report
  -u, --match       : int  : Match score (BLASTN only)
  -v, --mismatch    : int  : Mismatch score (BLASTN only)
  -o, --gapopen     : int  : Gap open penalty
  -x, --gapext      : int  : Gap extension penalty
  -d, --dropoff     : int  : Drop-off
  -g, --gapalign    :      : Optimise gaped alignments
      --compstats   : str  : Compositional adjustment/statistics mode, see
                             --paramDetail compstats
      --seqrange    : str  : region within input to use as query

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

  http://www.ebi.ac.uk/Tools/sss/ncbiblast/
  http://www.ebi.ac.uk/Tools/webservices/sss/ncbi_blast_rest
  http://www.ebi.ac.uk/Tools/webservices/tutorials/ruby
END_OF_STRING
  exit(returnCode)
end

# Wrapping class for working with the application
class EbiWsNcbiBlast
  # Accessor methods for attributes
  attr_reader :timeout, :outputLevel, :debugLevel, :baseUrl

  # Constructor
  def initialize(
                 outputLevel=1,
                 debugLevel=0,
                 timeout=120,
                 baseUrl='http://www.ebi.ac.uk/Tools/services/rest/ncbiblast'
                 )
    @baseUrl = baseUrl
    @outputLevel = outputLevel.to_i
    @debugLevel = debugLevel.to_i
    @timeout = timeout
  end
  
  # Print debug message
  def printDebugMessage(methodName, message, level)
    if(level <= @debugLevel)
      puts '[' + methodName + '] ' + message
    end
  end
  
  # Print output message
  def printOutputMessage(message, level)
    if(level <= @outputLevel)
      puts message
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

  # Perform an HTTP GET request
  def restRequest(url)
    printDebugMessage('restRequest', 'Begin', 11)
    printDebugMessage('restRequest', 'url: ' + url, 12)
    # Split URL into components
    uri = URI.parse(url)
    # Create a HTTP connection
    httpConn = Net::HTTP.new(uri.host, uri.port)
    # Get the resource
    if uri.query
      path = "#{uri.path}?#{uri.query}"
    else
      path = uri.path
    end
    resp, data = httpConn.get(path, {'User-agent' => getUserAgent()})
    case resp
    when Net::HTTPSuccess, Net::HTTPRedirection
      # OK
    else
      $stderr.puts data
      resp.error!
    end
    printDebugMessage('restRequest', 'data: ' + data, 21)
    printDebugMessage('restRequest', 'End', 11)
    return data
  end

  # Get list of input parameters
  def getParameters()
    printDebugMessage('getParameters', 'Begin', 1)
    xmlDoc = restRequest(baseUrl + '/parameters/')
    doc = REXML::Document.new(xmlDoc)
    printDebugMessage('getParameters', 'End', 1)
    return doc.root.elements['//parameters']
  end
  
  # Print list of parameter names
  def printParameters()
    printDebugMessage('printParameters', 'Begin', 1)
    paramNameList = getParameters()
    paramNameList.each_element('id') { |paramName|
      puts paramName.text
    }
    printDebugMessage('printParams', 'End', 1)
  end
  
  # Get detail about a parameter
  def getParamDetail(paramName)
    printDebugMessage('getParamDetail', 'Begin', 1)
    printDebugMessage('getParamDetail', 'paramName: ' + paramName, 2)
    xmlDoc = restRequest(baseUrl + '/parameterdetails/' + paramName)
    doc = REXML::Document.new(xmlDoc)
    printDebugMessage('getParamDetail', 'End', 1)
    return doc.root.elements['//parameter']
  end

  # Print detail about a parameter
  def printParamDetail(paramName)
    printDebugMessage('printParamDetail', 'Begin', 1)
    paramDetail = getParamDetail(paramName)
    puts paramDetail.elements['name'].text + "\t" + paramDetail.elements['type'].text
    puts paramDetail.elements['description'].text
    paramDetail.each_element('values/value') { |value|
      print value.elements['value'].text
      if(value.elements['defaultValue'].has_text? && value.elements['defaultValue'].text == 'true')
        print "\tdefault"
      end
      puts
      if(value.elements['label'].has_text?)
        puts "\t" + value.elements['label'].text
      end
      value.each_element('properties/property') { |wsProperty|
        puts "\t" + wsProperty.elements['key'].text + "\t" + wsProperty.elements['value'].text
      }
    }
    printDebugMessage('printParamDetail', 'End', 1)
  end

  # Submit a job
  def run(email, title, params)
    printDebugMessage('run', 'Begin', 1)
    # Add e-mail and title to params
    printDebugMessage('run', 'email: ' + email, 2)
    params['email'] = email
    if(title != nil)
      printDebugMessage('run', 'title: ' + title, 2)
      params['title'] = title
    end
    # Build the path for the resource
    submitUrl = baseUrl + '/run/'
    # URL encode the parameters
    post_data = ''
    params.each do |key, val|
      # Handle array parameters (i.e. database)
      if(val.is_a?(Array))
        val.each do |subVal|
          post_data += "&#{key}=" + CGI::escape(subVal)
        end
      else
        post_data += "&#{key}=" + CGI::escape(val)
      end
    end
    printDebugMessage('run', 'post_data: ' + post_data, 10)
    # Submit the job (POST)
    uri = URI.parse(submitUrl)
    httpConn = Net::HTTP.new(uri.host, uri.port)
    resp, jobId = httpConn.post(uri.path, post_data, {'User-agent' => getUserAgent()})
    printDebugMessage('run', 'End', 1)
    return jobId
  end

  # Get job status
  def getStatus(jobId)
    printDebugMessage('getStatus', 'Begin', 1)
    status = restRequest(baseUrl + '/status/' + jobId)
    printDebugMessage('getStatus', 'End', 1)
    return status
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
      printOutputMessage(status, 1)
      sleep(5) if(status == 'PENDING' || status == 'RUNNING')
    end
    printDebugMessage('clientPoll', 'End', 1)
  end
  
  # Get result types
  def getResultTypes(jobId)
    printDebugMessage('getResultTypes', 'Begin', 1)
    printDebugMessage('getResultTypes', 'jobId: ' + jobId, 2)
    clientPoll(jobId)
    xmlDoc = restRequest(baseUrl + '/resulttypes/' + jobId)
    doc = REXML::Document.new(xmlDoc)
    printDebugMessage('getResultTypes', 'End', 1)
    return doc.root.elements['//types']
  end

  # Print result types
  def printResultTypes(jobId)
    printDebugMessage('printResultTypes', 'Begin', 1)
    resultTypes = getResultTypes(jobId)
    resultTypes.each_element('type') { |resultType|
      puts resultType.elements['identifier'].text
      puts "\t" + resultType.elements['label'].text if(resultType.elements['label'].has_text?)
      puts "\t" + resultType.elements['description'].text if(resultType.elements['description'].has_text?)
      puts "\t" + resultType.elements['mediaType'].text if(resultType.elements['mediaType'].has_text?)
      puts "\t" + resultType.elements['fileSuffix'].text if(resultType.elements['fileSuffix'].has_text?)
    }
    printDebugMessage('printResultTypes', 'End', 1)
  end

  # Get result for a job of the specified format
  def getResult(jobId, type, params)
    printDebugMessage('getResult', 'Begin', 1)
    printDebugMessage('getResult', 'jobId: ' + jobId, 2)
    printDebugMessage('getResult', 'type: ' + type, 2)
    resultData = restRequest(baseUrl + '/result/' + jobId + '/' + type)
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
    resultTypes.each_element('type') { |resultType|
      selResultType = resultType if(resultType.elements['identifier'].text == outFormat)
    }
    if(selResultType)
      printDebugMessage('getResultFile', 'selResultType: ' + selResultType.elements['identifier'].text, 2)
      if outFileBase != '-'
        outFileName = "#{outFileBase}.#{selResultType.elements['identifier'].text}.#{selResultType.elements['fileSuffix'].text}"
        writeResultFile(jobId, selResultType.elements['identifier'].text, outFileName)
        puts "Wrote #{outFileName}"
      else
        puts getResult(jobId, outFormat, nil)
      end
    end
    printDebugMessage('getResultFile', 'End', 1)
  end

  def getResultFiles(jobId, outFileBase)
    printDebugMessage('getResultFiles', 'Begin', 1)
    printDebugMessage('getResultFiles', 'jobId: ' + jobId, 1)
    printDebugMessage('getResultFiles', 'outFileBase: ' + outFileBase, 1)
    resultTypes = getResultTypes(jobId)
    # Write result to file !!!
    resultTypes.each_element('type') { |resultType|
      printDebugMessage('getResultFiles', 'resultType: ' + resultType.elements['identifier'].text, 2)
      outFileName = "#{outFileBase}.#{resultType.elements['identifier'].text}.#{resultType.elements['fileSuffix'].text}"
      writeResultFile(jobId, resultType.elements['identifier'].text, outFileName)
      puts "Wrote #{outFileName}"
    }    
    printDebugMessage('getResultFiles', 'End', 1)
  end    
end

# Remember the number of command-line arguments before processing.
numArgs = ARGV.length
# Output level (--quiet & --verbose)
outputLevel = 1

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
                           ['--baseUrl', GetoptLong::REQUIRED_ARGUMENT],
                           
                           # Tool specific options
                           ['--program', '-p', GetoptLong::REQUIRED_ARGUMENT],
                           ['--database', '-D', GetoptLong::REQUIRED_ARGUMENT],
                           ['--matrix', '-m', GetoptLong::REQUIRED_ARGUMENT],
                           ['--exp', '-E', GetoptLong::REQUIRED_ARGUMENT],
                           ['--filter', '-f', GetoptLong::REQUIRED_ARGUMENT],
                           ['--align', '-A', GetoptLong::REQUIRED_ARGUMENT],
                           ['--scores', '-s', GetoptLong::REQUIRED_ARGUMENT],
                           ['--alignments', '-n', GetoptLong::REQUIRED_ARGUMENT],
                           ['--dropoff', '-d', GetoptLong::REQUIRED_ARGUMENT],
                           ['--match_scores', GetoptLong::REQUIRED_ARGUMENT],
                           ['--match', '-u', GetoptLong::REQUIRED_ARGUMENT],
                           ['--mismatch', '-v', GetoptLong::REQUIRED_ARGUMENT],
                           ['--gapopen', '-o', GetoptLong::REQUIRED_ARGUMENT],
                           ['--gapext', '-x', GetoptLong::REQUIRED_ARGUMENT],
                           ['--gapalign', '-g', GetoptLong::NO_ARGUMENT],
                           ['--compstats', GetoptLong::REQUIRED_ARGUMENT],
                           ['--stype', GetoptLong::REQUIRED_ARGUMENT],
                           ['--seqrange', GetoptLong::REQUIRED_ARGUMENT],
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
  'baseUrl' => 1,
  'gapalign' => 1
}

# Process command line options
begin
  argHash = {}
  argHash['debugLevel'] = 0
  optParser.each do |name, arg|
    key = name.sub(/^--/, '') # Clean up the argument name
    argHash[key] = arg
  end
  params = {}
  argHash.each do |key, arg|
    # For application options add to the params hash
    if arg != ''
      params[key] = arg unless excludeOpts[key]
    else
      params[key] = 1 unless excludeOpts[key]
    end
  end
rescue
  $stderr.print 'Error: command line parsing failed: ' + $! + "\n"
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
  # Adjust output level.
  outputLevel += 1 if(argHash['verbose'])
  outputLevel -= 1 if(argHash['quiet'])
  if argHash['baseUrl']
    ebiWsApp = EbiWsNcbiBlast.new(outputLevel, argHash['debugLevel'], timeout, baseUrl)
  else
    ebiWsApp = EbiWsNcbiBlast.new(outputLevel, argHash['debugLevel'], timeout)
  end
  
  # Help info
  if argHash['help'] || numArgs == 0
    printUsage(0)

  # Get list of parameter names
  elsif argHash['params']
    ebiWsApp.printParameters()

  # Get details for a parameter
  elsif argHash['paramDetail']
    ebiWsApp.printParamDetail(argHash['paramDetail'])

  # Job based actions
  elsif argHash['jobid']
    ebiWsApp.printOutputMessage("JobID: " + argHash['jobid'], 1)
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
        params['sequence'] = inFile.read
        inFile.close
      else
        # Use parameter value as input.
        params['sequence'] = inputData
      end
    end
    # Convert database into list.
    if(params['database'])
      params['database'] = params['database'].split(/[ ,]+/)
    end
    # Handle boolean options
    if argHash['gapalign']
      params['gapalign'] = '0'
    #else
    #  params['gapalign'] = '1'
    end
    jobId = ebiWsApp.run(argHash['email'], argHash['title'], params)
    # In synchronous mode can now get results otherwise print the jobId
    if !argHash['async']
      ebiWsApp.printOutputMessage('JobId: ' + jobId, 1)
      if !argHash['outfile']
        argHash['outfile'] = jobId
      end
      if argHash['outformat']
        ebiWsApp.getResultFile(jobId, argHash['outformat'], argHash['outfile'])
      else
        ebiWsApp.getResultFiles(jobId, argHash['outfile'])
      end
    else
      ebiWsApp.printOutputMessage('JobId: ' + jobId, 0)
    end

  # Unsupported combination of options (or no options)
  else
    $stderr.print "Error: unknown option combination\n"
    exit(1)
  end

# Catch any exceptions and display
rescue StandardError => ex
  puts ex
  exit(2)
end
