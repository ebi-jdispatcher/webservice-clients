<?php
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
# PHP NCBI BLAST REST command-line client.
#
# Note: this is a command-line program, call using:
#  php ncbiblast_cli_php_file.php [options...]
#
# Tested with:
#   PHP 5.2.4 (Ubuntu 8.04 LTS)
#   PHP 5.3.2 (Ubuntu 10.04 LTS)
#   PHP 5.3.10 (Ubuntu 12.04 LTS)
#
# See:
# http://www.ebi.ac.uk/Tools/webservices/services/sss/ncbi_blast_rest
# http://www.ebi.ac.uk/Tools/webservices/tutorials/php
# ======================================================================
# Load NCBI BLAST client library
require_once('ncbiblast_lib_php_file.php');

// Extend client class
class NcbiBlastCliClient extends NcbiBlastClient {
  // Print list of tool parameters
  function printGetParameters() {
    $this->printDebugMessage('printGetParameters', 'Begin', 1);
    $paramList = $this->getParameters();
    foreach($paramList as $paramName) {
      print $paramName . "\n";
    }
    $this->printDebugMessage('printGetParameters', 'End', 1);
  }

  // Print details of a parameter
  function printGetParameterDetails($parameterId) {
    $this->printDebugMessage('printGetParameterDetails', 'Begin', 1);
    $paramDetail = $this->getParameterDetails($parameterId);
    print $paramDetail->name . "\t" . $paramDetail->type . "\n";
    print $paramDetail->description . "\n";
    if(isset($paramDetail->values)) {
      foreach($paramDetail->values->value as $val) {
	print $val->value . "\t";
	if($val->defaultValue == 'true') print 'default';
	print "\n";
	if($val->label) print "\t" . $val->label . "\n";
	if(isset($val->properties)) {
	  foreach($val->properties->property as $wsProperty) {
	    print "\t" .  $wsProperty->key . "\t" . $wsProperty->value . "\n";
	  }
	}
      }
    }
    $this->printDebugMessage('printGetParameterDetails', 'Begin', 1);
  }

  // Print available result types for a job
  function printGetResultTypes($jobId) {
    $this->printDebugMessage('PrintGetResultTypes', 'Begin', 1);
    $resultTypes = $this->getResultTypes($jobId);
    foreach($resultTypes as $resultType) {
      print $resultType->identifier . "\n";
      print "\t" . $resultType->label . "\n";
      if($resultType->description) {
	print "\t" . $resultType->description . "\n";
      }
      print "\t" . $resultType->mediaType . "\n";
      print "\t" . $resultType->fileSuffix . "\n";
    }
    $this->printDebugMessage('PrintGetResultTypes', 'End', 1);
  }
  
  function submit($options) {
    $this->printDebugMessage('submit', 'Begin', 1);
    if(!array_key_exists('match_scores', $options['params']) &&
       (array_key_exists('match', $options) && array_key_exists('mismatch', $options))) {
      $options['params']['match_scores'] = $options['match'] . ',' . $options['mismatch'];
    }
    if(!array_key_exists('title', $options)) {
      $options['title'] = '';
    }
    $jobId = $this->run(
			$options['email'],
			$options['title'],
			$options['params']);
    // Async submission
    if($options['async'] || $options['outputLevel'] > 0) {
      echo "$jobId\n";
    }
    // Sync submission... get results
    if(!$options['async']) {
      $options['jobId'] = $jobId;
      $this->poll($options);
    }
    $this->printDebugMessage('submit', 'End', 1);
  }

  // Client-side job polling.
  function clientPoll($jobId) {
    $this->printDebugMessage('clientPoll', 'Begin', 1);
    // Get status
    $status = 'PENDING';
    while(strcmp($status, 'PENDING') == 0 || strcmp($status, 'RUNNING') == 0) {
      $status = $this->getStatus($jobId);
      echo "$status\n";
      if(strcmp($status, 'PENDING') == 0 || strcmp($status, 'RUNNING') == 0) {
	sleep(15);
      }
    }
    $this->printDebugMessage('clientPoll', 'End', 1);
  }

  function poll($options) {
    $this->printDebugMessage('poll', 'Begin', 1);
    // Check status and wait if necessary
    $this->clientPoll($options['jobId']);
    // Get the result types
    $resultTypeList = $this->getResultTypes($options['jobId']);
    if(array_key_exists('outfile', $options)) {
      $baseName = $options['outfile'];
    } else {
      $baseName = $options['jobId'];
    }
    foreach($resultTypeList as $resultType) {
      $result = '';
      $filename = $baseName . '.' . $resultType->identifier . '.' . $resultType->fileSuffix;
      if(array_key_exists('input', $options) && array_key_exists('outformat', $options['input'])) {
	if(strcmp($options['input']['outformat'], $resultType->identifier) == 0) {
	  $result = $this->getResult($options['jobId'], $resultType->identifier);
	}
      } else {
	$result = $this->getResult($options['jobId'], $resultType->identifier);
      }
      if($result) {
	print "$filename\n";
	file_put_contents($filename, $result);
      }
    }
    $this->printDebugMessage('poll', 'End', 1);
  }
}

try {
  // Parse command-line options
  $options = parseCommandLine($argv);

  // For no options or explict help request
  if($argc == 1 || strcmp($options['action'], 'help') == 0) {
    printUsage();
    exit(0);
  }

  // Get service proxy
  $client = new NcbiBlastCliClient();
  // HTTP proxy config.
  // Try to get HTTP proxy setting from environment.
  if(getenv('HTTP_PROXY') != '' || getenv('http_proxy') != '') {
    if(getenv('HTTP_PROXY') != '') {
      $tmpArray = parse_url(getenv('HTTP_PROXY'));
    }
    elseif(getenv('http_proxy') != '') {
      $tmpArray = parse_url(getenv('http_proxy'));
    }
    $client->setHttpProxy($tmpArray['host'], $tmpArray['port']);
  }

  // Debug options
  if(array_key_exists('debugLevel', $options)) {
    $client->debugLevel = $options['debugLevel'];
  }
  if(array_key_exists('baseUrl', $options)) {
    $client->setBaseUrl($options['baseUrl']);
  }

  // Perform requested action
  switch($options['action']) {
    // List params
  case 'params':
    $client->printGetParameters();
    break;
    // Parameter information
  case 'paramDetail':
    $client->printGetParameterDetails($options['parameterId']);
    break;
    // Submit job
  case 'submit':
    $client->submit($options);
    break;
    // Get status
  case 'status':
    $status = $client->getStatus($options['jobId']);
    echo "$status\n";
    break;
    // Get result types
  case 'resultTypes':
    $client->printGetResultTypes($options['jobId']);
    break;
    // Get results
  case 'polljob':
    $client->poll($options);
    break;
  }
}
catch(Exception $ex) {
  echo 'Error: ';
  if($ex->getMessage() != '') echo $ex->getMessage();
  else echo $ex;
  echo "\n";
}

// Parse command-line options
function parseCommandLine($argList) {
  $options = array(
    'action' => 'unknown',
    'async' => FALSE,
    'outputLevel' => 1,
    'params' => array(),
  );
  for($i=0; $i<count($argList); $i++) {
    $arg = $argList[$i];
    switch($arg) {
      // Help/usage
      case '--help':
        $options['action'] = 'help';
        break;
      // Debug output
      case '--debugLevel':
	$i++;
        $options['debugLevel'] = $argList[$i];
        break;
      // Service base URL location
      case '--baseUrl':
	$i++;
        $options['baseUrl'] = $argList[$i];
        break;

	// List params
    case '--params':
      $options['action'] = 'params';
      break;
	// List param details
    case '--paramDetail':
      $i++;
      $options['parameterId'] =  $argList[$i];
      $options['action'] = 'paramDetail';
      break;

      // Job identifier
    case '--jobid':
      $i++;
      $options['jobId'] = $argList[$i];
      break;
      // Get job status
    case '--status':
      $options['action'] = 'status';
      break;
      // Get available result types
    case '--resultTypes':
      $options['action'] = 'resultTypes';
      break;
      // Get job results
    case '--polljob':
      $options['action'] = 'polljob';
      break;
      // Output filename
    case '--outfile':
      $i++;
      $options['outfile'] = $argList[$i];
      break;
      // Output format
    case '--outformat':
      $i++;
      $options['input']['outformat'] = $argList[$i];
      break;
      // User e-mail
    case '--email':
      $i++;
      $options['action'] = 'submit';
      $options['email'] = $argList[$i];
      break;
      // Job title
    case '--title':
      $i++;
      $options['title'] = $argList[$i];
      break;
      // Async submission
    case '--async':
      $options['async'] = TRUE;
      break;

      // ### NCBI BLAST parameters ###
      // Search program
    case '--program':
    case '-p':
      $i++;
      $options['params']['program'] = $argList[$i];
      break;
      // Search database
    case '--database':
    case '-D':
      $i++;
      $options['params']['database'] = split('[ ,;]+', $argList[$i]);
      break;
      // Query sequence type
    case '--stype':
      $i++;
      $options['params']['stype'] = $argList[$i];
      break;
      // Scoring matrix
    case '--matrix':
    case '-m':
      $i++;
      $options['params']['matrix'] = $argList[$i];
      break;
      // E-value threshold
    case '--exp':
    case '-e':
      $i++;
      $options['params']['exp'] = $argList[$i];
      break;
      // Low complexity filter
    case '--filter':
    case '-f':
      $i++;
      $options['params']['filter'] = $argList[$i];
      break;
      // Alignment format
    case '--align':
    case '-A':
      $i++;
      $options['params']['align'] = $argList[$i];
      break;
      // Max scores
    case '--scores':
    case '-s':
      $i++;
      $options['params']['scores'] = $argList[$i];
      break;
      // Max alignments
    case '--alignments':
    case '-n':
      $i++;
      $options['params']['alignments'] = $argList[$i];
      break;
      // Match scores
    case '--match_scores':
      $i++;
      $options['params']['match_scores'] = $argList[$i];
      break;
      // Match
    case '--match':
    case '-u':
      $i++;
      $options['match'] = $argList[$i];
      break;
      // Mismatch
    case '--mismatch':
    case '-v':
      $i++;
      $options['mismatch'] = $argList[$i];
      break;
      // Gap open
    case '--gapopen':
    case '-o':
      $i++;
      $options['params']['gapopen'] = $argList[$i];
      break;
      // Gap extend
    case '--gapext':
    case '-x':
      $i++;
      $options['params']['gapext'] = $argList[$i];
      break;
      // Dropoff
    case '--dropoff':
    case '-d':
      $i++;
      $options['params']['dropoff'] = $argList[$i];
      break;
      // Gapped alignments
    case '--gapalign':
    case '-g':
      $options['params']['gapalign'] = TRUE;
      break;
      // Compositional adjustment/statistics.
    case '--compstats':
      $i++;
      $options['params']['compstats'] = $argList[$i];
      break;
      // Query sequence range
    case '--seqrange':
      $i++;
      $options['params']['seqrange'] = $argList[$i];
      break;
      // Query sequence data
    case '--sequence':
        $i++;
    default:
      if($i != 0) {
	if(file_exists($argList[$i])) {
	  // It's a file
	  $options['params']['sequence'] = file_get_contents($argList[$i]);
	}
	else {
	  // Assume it's an ID
	  $options['params']['sequence'] = $argList[$i];
	}
      }
    }
  }
  return $options;
}

// Print usage message
function printUsage() {
  $scriptName = 'ncbiblast_php5_cli.php';
  print <<<EOF
NCBI BLAST
==========
Rapid sequence database search programs utilizing the BLAST algorithm
    
[Required]

  -p, --program      : str  : BLAST program to use, see --paramDetail program
  -D, --database     : str  : database(s) to search, space separated. See
                              --paramDetail database
      --stype        : str  : query sequence type, see --paramDetail stype
  seqFile            : file : query sequence

[Optional]

  -m, --matrix       : str  : scoring matrix, see --paramDetail matrix
  -e, --exp          : real : 0<E<= 1000. Statistical significance threshold 
                              for reporting database sequence matches.
  -f, --filter       :      : filter the query sequence for low complexity 
                              regions, see --paramDetail filter
  -A, --align        : int  : pairwise alignment format, see --paramDetail align
  -s, --scores       : int  : number of scores to be reported
  -n, --alignments   : int  : number of alignments to report
  -u, --match        : int  : Match score (BLASTN only)
  -v, --mismatch     : int  : Mismatch score (BLASTN only)
  -o, --gapopen      : int  : Gap open penalty
  -x, --gapext       : int  : Gap extension penalty
  -d, --dropoff      : int  : Drop-off
  -g, --gapalign     :      : Optimise gapped alignments
      --compstats    : str  : Compositional adjustment/statistics mode, see
                              --paramDetail compstats
      --seqrange     : str  : region within input to use as query

[General]

      --help         :      : prints this help text
      --async        :      : forces to make an asynchronous query
      --email        : str  : e-mail address
      --title        : str  : title for job
      --status       :      : get job status
      --resultTypes  :      : get available result types for job
      --polljob      :      : poll for the status of a job
      --jobid        : str  : jobid that was returned when an asynchronous job 
                              was submitted.
      --outfile      : str  : file name for results (default is jobid)
      --outformat    : str  : result format to retrieve
      --params       :      : list input parameters
      --paramDetail  : str  : display details for input parameter

Synchronous job:

  The results/errors are returned as soon as the job is finished.
  Usage: $scriptName --email <your\@email> [options...] seqFile
  Returns: results as an attachment

Asynchronous job:

  Use this if you want to retrieve the results at a later time. The results 
  are stored for up to 24 hours. 
  Usage: $scriptName --async --email <your\@email> [options...] seqFile
  Returns: jobid

  Use the jobid to query for the status of the job. If the job is finished, 
  it also returns the results/errors.
  Usage: $scriptName --polljob --jobid <jobId> [--outfile string]
  Returns: string indicating the status of the job and if applicable, results 
  as an attachment.

Further information:

  http://www.ebi.ac.uk/Tools/webservices/services/sss/ncbi_blast_soap
  http://www.ebi.ac.uk/Tools/webservices/tutorials/php

Support/Feedback:

  http://www.ebi.ac.uk/support/

EOF;
}
?>
