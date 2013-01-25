<?php
# $Id$
# ======================================================================
# 
# Copyright 2008-2013 EMBL - European Bioinformatics Institute
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
  // HTTP proxy host.
  private $proxy_host;
  // HTTP proxy port.
  private $proxy_port = '8080';

  // Debug message
  protected function printDebugMessage($method, $message, $level) {
    if($level <= $this->debugLevel) {
      // Plain text
      if(array_key_exists('argc', $GLOBALS)) print "[$method] $message\n";
      // HTML
      else print "<p>[$method] $message</p>\n";
    }
  }

  // Get user-agent string for client.
  function getUserAgent() {
    $this->printDebugMessage('getUserAgent', 'Begin', 2);
    $clientVersion = trim(substr('$Revision$', 11), ' $');
    if($clientVersion == '') $clientVersion = '0';
    $uname  = posix_uname();
    $userAgent = 'EBI-Sample-Client/' . $clientVersion . 
      ' (' . get_class($this) . '; ' . $uname['sysname'] . ') PHP/' . phpversion();
    $this->printDebugMessage('getUserAgent', 'User-agent: ' . $userAgent, 2);
    $this->printDebugMessage('getUserAgent', 'End', 2);
    return $userAgent;
  }

  // Set the base URL to an alternative server
  function setBaseUrl($baseUrl) {
    $this->printDebugMessage('setBaseUrl', 'Begin', 1);
    $this->printDebugMessage('setBaseUrl', 'baseUrl: ' . $baseUrl, 2);
    $this->baseUrl = $baseUrl;
    $this->printDebugMessage('setBaseUrl', 'End', 1);
  }

  // Configure an HTTP proxy.
  //   $client->setHttpProxy('proxy.example.org', '8080');
  function setHttpProxy($proxy_host, $proxy_port) {
    $this->printDebugMessage('setHttpProxy', 'Begin', 1);
    $this->printDebugMessage('setHttpProxy', 'proxy_host: ' . $proxy_host, 2);
    $this->printDebugMessage('setHttpProxy', 'proxy_port: ' . $proxy_port, 2);
    $this->proxy_host = $proxy_host;
    $this->proxy_port = $proxy_port;
    $this->printDebugMessage('setHttpProxy', 'End', 1);    
  }

  // Get proxy string.
  private function getHttpProxyStr() {
    $this->printDebugMessage('getHttpProxyStr', 'Begin', 2);
    $proxyStr = null;
    if($this->proxy_host) {
      $proxyStr = 'tcp://' . $this->proxy_host . ':' . $this->proxy_port;
    }
    $this->printDebugMessage('getHttpProxyStr', 'proxyStr: ' . $proxyStr, 12);
    $this->printDebugMessage('getHttpProxyStr', 'End', 2);
    return $proxyStr;
  }

  // Perform an HTTP GET request.
  function httpGet($url) {
    $this->printDebugMessage('httpGet', 'Begin', 11);
    $contextOpts = array('http' => array(
					 'method' => 'GET',
					 'request_fulluri' => true,
					 'timeout'         => 300,
					 'header' => 'User-agent: ' . $this->getUserAgent() . "\r\n",
					 )
			 );
    if($this->proxy_host) { // Add HTTP proxy.
      $contextOpts['http']['proxy'] = $this->getHttpProxyStr();
    }
    $context = stream_context_create($contextOpts);
    $retVal = file_get_contents($url, false, $context);
    $this->printDebugMessage('httpGet', 'Response: ' . $retVal, 21);
    $this->printDebugMessage('httpGet', 'End', 11);
    return $retVal;
  }

  // Perform an HTTP POST request.
  function httpPost($url, $postdata) {
    $this->printDebugMessage('httpPost', 'Begin', 11);
    $opts = array('http' => array(
				  'method'  => 'POST',
				  'request_fulluri' => true,
				  'timeout'         => 300,
				  'header'  => 'Content-type: application/x-www-form-urlencoded' . "\r\n" .
				  'User-agent: ' . $this->getUserAgent() . "\r\n",
				  'content' => $postdata
				  )
		  );
    if($this->proxy_host) { // Add HTTP proxy.
      $contextOpts['http']['proxy'] = $this->getHttpProxyStr();
    }
    $context  = stream_context_create($opts);
    $retVal = file_get_contents($url, false, $context);
    $this->printDebugMessage('httpPost', 'End', 11);
    return $retVal;
  }

  // Get list of tool parameter names
  function getParameters() {
    $this->printDebugMessage('getParameters', 'Begin', 1);
    // Construct the URL
    $paramsUrl = $this->baseUrl . '/parameters/';
    $this->printDebugMessage('getParameters', 'paramsUrl: ' . $paramsUrl, 2);
    // Get the document from the URL
    $xmlDoc = $this->httpGet($paramsUrl);
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
    $xmlDoc = $this->httpGet($paramUrl);
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
    $runUrl = $this->baseUrl . '/run/';
    $jobId = $this->httpPost($runUrl, $postdata);
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
    $doc = $this->httpGet($statusUrl);
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
    $xmlDoc = $this->httpGet($typesUrl);
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
    $doc = $this->httpGet($resultUrl);
    $this->printDebugMessage('getResult', 'End', 1);
    return $doc;
  }
}
?>
