<?php
# $Id$
# ======================================================================
# PHP NCBI BLAST SOAP client.
#
# Note: this is a command-line program, call using:
#  php ncbiblast_php5.php [options...]
#
# See:
# http://www.ebi.ac.uk/Tools/webservices/services/sss/ncbiblast
# http://www.ebi.ac.uk/Tools/webservices/tutorials/php
# ======================================================================
# Load NCBI BLAST client library
require('ncbiblast_php5.php');

// Map PHP errors to exceptions
function exception_error_handler($errno, $errstr, $errfile, $errline ) {
    throw new ErrorException($errstr, 0, $errno, $errfile, $errline);
}
set_error_handler("exception_error_handler");

try {
  # Parse command-line options
  $options = parseCommandLine($argv);

  # For no options or explict help request
  if($argc == 1 || strcmp($options['action'], 'help') == 0) {
    printUsage();
    exit(0);
  }

  # Get service proxy
  $client = new NcbiBlastClient();
  if($options['trace'] == 1) $client->trace = 1;

  # Perform requested action
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
catch(SoapFault $ex) {
  echo $ex . "\n";
}

// Parse command-line options
function parseCommandLine($argList) {
  $options = array(
    'action' => 'unknown',
    'async' => FALSE,
    'params' => array(),
  );
  for($i=0; $i<count($argList); $i++) {
    $arg = $argList[$i];
    switch($arg) {
      // Help/usage
      case '--help':
        $options['action'] = 'help';
        break;
      // SOAP message trace
      case '--trace':
        $options['trace'] = 1;
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
      --trace        :      : show SOAP messages being interchanged 

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
