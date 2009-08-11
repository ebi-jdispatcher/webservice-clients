#!/usr/bin/env ruby
# $Id$
# ======================================================================
# NCBI BLAST REST web service Ruby client using net/http.
#
# Tested with:
#   Ruby 1.8.7
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
  -f, --filter      :      : filter the query sequence for low complexity 
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
  Usage: ncbiblast_net_http.rb --email <your\@email> [options...] seqFile
  Returns: results as an attachment

Asynchronous job:

  Use this if you want to retrieve the results at a later time. The results 
  are stored for up to 24 hours.  
  Usage: ncbiblast_net_http.rb --async --email <your\@email> [options...] seqFile
  Returns: jobid

  Use the jobid to query for the status of the job. If the job is finished, 
  it also returns the results/errors.
  Usage: ncbiblast_net_http.rb --polljob --jobid <jobId> [--outfile string]
  Returns: string indicating the status of the job and if applicable, results 
  as an attachment.

Further information:

  http://www.ebi.ac.uk/Tools/ncbiblast/
  http://www.ebi.ac.uk/Tools/webservices/sss/ncbi_blast_rest
  http://www.ebi.ac.uk/Tools/webservices/tutorials/ruby
END_OF_STRING
  exit(returnCode)
end

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

# Tool specific options
['--program', '-p', GetoptLong::REQUIRED_ARGUMENT],
['--database', '-D', GetoptLong::REQUIRED_ARGUMENT],
['--matrix', '-m', GetoptLong::REQUIRED_ARGUMENT],
['--exp', '-E', GetoptLong::REQUIRED_ARGUMENT],
['--filter', '-f', GetoptLong::NO_ARGUMENT],
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
}

# Wrapping class for working with the application
class EbiWsAppl
  # Accessor methods for attributes
  attr_reader :timeout, :outputLevel, :debugLevel, :baseUrl

  # Constructor
  def initialize(outputLevel, debugLevel, timeout)
    @baseUrl = 'http://www.ebi.ac.uk/Tools/services/rest/ncbiblast'
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
  
  # Perform an HTTP GET request
  def restRequest(url)
    printDebugMessage('restRequest', 'Begin', 11)
    printDebugMessage('restRequest', 'url: ' + url, 12)
    # Split URL into components
    uri = URI.parse(url)
    # Create a HTTP connection
    httpConn = Net::HTTP.new(uri.host, uri.port)
    # Get the resource
    resp, data = httpConn.get(uri.path)
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
    # Submit the job
    uri = URI.parse(submitUrl)
    httpConn = Net::HTTP.new(uri.host, uri.port)
    resp, jobId = httpConn.post(uri.path, post_data)
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
      puts status
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
      outFileName = "#{outFileBase}.#{selResultType.elements['identifier'].text}.#{selResultType.elements['fileSuffix'].text}"
      writeResultFile(jobId, selResultType.elements['identifier'].text, outFileName)
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
    resultTypes.each_element('type') { |resultType|
      printDebugMessage('getResultFiles', 'resultType: ' + resultType.elements['identifier'].text, 2)
      outFileName = "#{outFileBase}.#{resultType.elements['identifier'].text}.#{resultType.elements['fileSuffix'].text}"
      writeResultFile(jobId, resultType.elements['identifier'].text, outFileName)
      puts "Wrote #{outFileName}"
    }    
    printDebugMessage('getResultFiles', 'End', 1)
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
  ebiWsApp = EbiWsAppl.new(argHash['outputLevel'], argHash['debugLevel'], timeout)
  
  # Help info
  if argHash['help']
    printUsage(0)

  # Get list of parameter names
  elsif argHash['params']
    ebiWsApp.printParameters()

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
    if(ARGV[0])
      params['sequence'] = ARGV[0]
    end
    if(params['database'])
      params['database'] = params['database'].split(/[ ,]+/)
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
    $stderr.print "Error: unknown option combination\n"
    exit(1)
  end

# Catch any exceptions and display
rescue StandardError => ex
  puts ex
end
