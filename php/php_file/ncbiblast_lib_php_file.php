<?php
# $Id$
# ======================================================================
# PHP NCBI BLAST REST client library
#
# Tested with:
#   PHP 5.2.6 (Ubuntu 9.04)
#
# See:
# http://www.ebi.ac.uk/Tools/webservices/services/sss/ncbi_blast_rest
# http://www.ebi.ac.uk/Tools/webservices/tutorials/php
# ======================================================================

class NcbiBlastClient {
  // Debug level
  public $debugLevel = 0;
  // Base URL for service
  private $baseUrl = 'http://www.ebi.ac.uk/Tools/services/rest/ncbiblast';

  // Debug message
  protected function printDebugMessage($method, $message, $level) {
    if($level <= $this->debugLevel) {
      // Plain text
      if(array_key_exists('argc', $GLOBALS)) print "[$method] $message\n";
      // HTML
      else print "<p>[$method] $message</p>\n";
    }
  }

  // Set the base URL to an alternative server
  function setBaseUrl($baseUrl) {
    $this->printDebugMessage('setBaseUrl', 'Begin', 1);
    $this->printDebugMessage('setBaseUrl', 'baseUrl: ' . $baseUrl, 2);
    $this->baseUrl = $baseUrl;
    $this->printDebugMessage('setBaseUrl', 'End', 1);
  }

  // Get list of tool parameter names
  function getParameters() {
    $this->printDebugMessage('getParameters', 'Begin', 1);
    // Construct the URL
    $paramsUrl = $this->baseUrl . '/parameters/';
    $this->printDebugMessage('getParameters', 'paramsUrl: ' . $paramsUrl, 2);
    // Get the document from the URL
    $xmlDoc = file_get_contents($paramsUrl);
    $doc = new SimpleXMLElement($xmlDoc);
    $this->printDebugMessage('getParameters', 'End', 1);
    // Return the list of parameter names
    return $doc->id;
  }

  // Get detail of a parameter
  function getParameterDetails($parameterId) {
    $this->printDebugMessage('getParameterDetails', 'Begin', 1);
    $this->printDebugMessage('getParameterDetails',
			     "parameterId: $parameterId", 2);
    // Construct the URL
    $paramUrl = $this->baseUrl . '/parameterdetails/' . $parameterId;
    $this->printDebugMessage('getParameterDetails', 'paramUrl: ' . $paramUrl, 2);
    // Get the document from the URL
    $xmlDoc = file_get_contents($paramUrl);
    $doc = new SimpleXMLElement($xmlDoc);
    $this->printDebugMessage('getParameterDetails', 'End', 1);
    return $doc;
  }

  // Submit a job to the service
  function run($email, $title, $params) {
    $this->printDebugMessage('run', 'Begin', 1);
    $this->printDebugMessage('run', 'email: ' . $email, 2);
    $runParams = $params;
    $dbList = $runParams['database'];
    $runParams['database'] = null;
    $runParams['email'] = $email;
    if($title) $runParams['title'] = $title;
    $postdata = http_build_query($runParams);
    foreach($dbList as $db) {
      $postdata .= '&database=' . urlencode($db);
    }
    $opts = array('http' =>
		  array(
			'method'  => 'POST',
			'header'  => 'Content-type: application/x-www-form-urlencoded',
			'content' => $postdata
			)
		  );
    $context  = stream_context_create($opts);
    $runUrl = $this->baseUrl . '/run/';
    $jobId = file_get_contents($runUrl, FALSE, $context);
    $this->printDebugMessage('run', 'jobId: ' . $jobId, 2);
    $this->printDebugMessage('run', 'End', 1);
    return $jobId;
  }

  // Get the status of a job
  function getStatus($jobId) {
    $this->printDebugMessage('getStatus', 'Begin', 1);
    $this->printDebugMessage('getStatus', 'jobId: ' . $jobId, 2);
    // Construct the URL
    $statusUrl = $this->baseUrl . '/status/' . $jobId;
    $this->printDebugMessage('getStatus', 'statusUrl: ' . $statusUrl, 2);
    // Get the document from the URL
    $doc = file_get_contents($statusUrl);
    $this->printDebugMessage('getStatus', 'End', 1);
    return $doc;
  }
  
  // Available result types for a finished job
  function getResultTypes($jobId) {
    $this->printDebugMessage('getResultTypes', 'Begin', 1);
    $this->printDebugMessage('getResultTypes', 'jobId: ' .  $jobId, 2);
    // Construct the URL
    $typesUrl = $this->baseUrl . '/resulttypes/' . $jobId;
    $this->printDebugMessage('getResultTypes', 'typesUrl: ' . $typesUrl, 2);
    // Get the document from the URL
    $xmlDoc = file_get_contents($typesUrl);
    $doc = new SimpleXMLElement($xmlDoc);
    $this->printDebugMessage('getResultTypes', 'End', 1);
    return $doc->type;
  }
  
  // Get job results
  function getResult($jobId, $type) {
    $this->printDebugMessage('getResult', 'Begin', 1);
    $this->printDebugMessage('getResult', 'jobId: ' . $jobId, 2);
    $this->printDebugMessage('getResult', 'type: ' . $type, 2);
    // Construct the URL
    $resultUrl = $this->baseUrl . '/result/' . $jobId . '/' . $type;
    $this->printDebugMessage('getResult', 'resultUrl: ' . $resultUrl, 2);
    // Get the document from the URL
    $doc = file_get_contents($resultUrl);
    $this->printDebugMessage('getResult', 'End', 1);
    return $doc;
  }
}
?>
