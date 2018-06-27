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
# PHP WSDbfetch document/literal SOAP service client library.
#
# Uses PHP SOAP.
#
# Tested with:
#   PHP 5.1.6 (CentOS 5)
#   PHP 5.3.2 (Ubuntu 10.04 LTS)
#
# See:
# http://www.ebi.ac.uk/Tools/webservices/services/dbfetch
# http://www.ebi.ac.uk/Tools/webservices/tutorials/php
# ======================================================================

class WSDbfetchClient {
  // Service WSDL URL.
  private $wsdlUrl = 'http://www.ebi.ac.uk/ws/services/WSDbfetchDoclit?wsdl';
  // Service proxy
  private $srvProxy;
  // HTTP proxy details
  private $httpProxy;
  // Trace flag
  public $trace = FALSE;
  // Debug level
  public $debugLevel = 0;
  
  // Debug message
  protected function printDebugMessage($method, $message, $level) {
    if($level <= $this->debugLevel) {
      // Plain text
      if(array_key_exists('argc', $GLOBALS)) print "[$method] $message\n";
      // HTML
      else print "<p>[$method] $message</p>\n";
    }
  }
  
  // Set HTTP proxy details
  function setHttpProxy($host, $port=8080) {
    $this->printDebugMessage('setHttpProxy', 'Begin', 1);
    $this->httpProxy = array('proxy_host' => $host,
			     'proxy_port' => $port);
    $this->printDebugMessage('setHttpProxy', 'End', 1);
  }

  // Get HTTP User-agent string.
  function getUserAgent() {
    $this->printDebugMessage('getUserAgent', 'Begin', 2);
    $clientVersion = trim(substr('$Revision$', 11), ' $');
    if($clientVersion == '') $clientVersion = '0';
    $uname  = posix_uname();
    $userAgent = 'EBI-Sample-Client/' . $clientVersion . 
      ' (' . get_class($this) . '; ' . $uname['sysname'] . ') PHP-SOAP/' . phpversion();
    $this->printDebugMessage('getUserAgent', 'User-agent: ' . $userAgent, 2);
    $this->printDebugMessage('getUserAgent', 'End', 2);
    return $userAgent;
  }
  
  // Set WSDL to an alternative server
  function setWsdlUrl($wsdlUrl) {
    $this->printDebugMessage('setWsdlUrl', 'Begin', 1);
    $this->printDebugMessage('setWsdlUrl', 'wsdlUrl: ' . $wsdlUrl, 2);
    $this->wsdlUrl = $wsdlUrl;
    $this->printDebugMessage('setWsdlUrl', 'End', 1);
  }
  
  // Get a service proxy
  function serviceProxyConnect() {
    $this->printDebugMessage('serviceProxyConnect', 'Begin', 3);
    // Check for SoapClient
    if(!class_exists('SoapClient')) {
      throw new Exception('SoapClient class cannot be found.');
    }
    // Get service proxy
    if($this->srvProxy == null) {
      $options = array(
		       'trace' => $this->trace,
		       'user_agent' => $this->getUserAgent(),
		       'compression' => SOAP_COMPRESSION_ACCEPT | SOAP_COMPRESSION_GZIP
		       );
      if(isset($this->httpProxy)) {
	$options['proxy_host'] = $this->httpProxy['proxy_host'];
	$options['proxy_port'] = $this->httpProxy['proxy_port'];
      }
      $this->srvProxy = new SoapClient($this->wsdlUrl,
				       $options);
    }
    $this->printDebugMessage('serviceProxyConnect', 'End', 3);
  }
 
  // Print SOAP messages exchanged between client and server.
  function soapTrace() {
    $this->printDebugMessage('soapTrace', 'Begin', 12);
    if($this->srvProxy != null) {
      echo "REQUEST:\n" . $this->srvProxy->__getLastRequest() . "\n";
      echo "RESPONSE:\n" . $this->srvProxy->__getLastResponse() . "\n";
    }
    $this->printDebugMessage('soapTrace', 'End', 12);
  }

  // Get database meta-information.
  function soapGetDatabaseInfoList() {
    $this->printDebugMessage('soapGetDatabaseInfoList', 'Begin', 2);
    $this->serviceProxyConnect();
    $result = $this->srvProxy->getDatabaseInfoList();
    if($this->trace) $this->soapTrace();
    $this->printDebugMessage('soapGetDatabaseInfoList', 'End', 2);
    return $result->getDatabaseInfoListReturn;
  }
  
  // Get list of available databases.
  function soapGetSupportedDBs() {
    $this->printDebugMessage('soapGetSupportedDBs', 'Begin', 2);
    $this->serviceProxyConnect();
    $result = $this->srvProxy->getSupportedDBs();
    if($this->trace) $this->soapTrace();
    $this->printDebugMessage('soapGetSupportedDBs', 'End', 2);
    return $result->getSupportedDBsReturn;
  }
  
  // Get list of available databases and formats.
  function soapGetSupportedFormats() {
    $this->printDebugMessage('soapGetSupportedFormats', 'Begin', 2);
    $this->serviceProxyConnect();
    $result = $this->srvProxy->getSupportedFormats();
    if($this->trace) $this->soapTrace();
    $this->printDebugMessage('soapGetSupportedFormats', 'End', 2);
    return $result->getSupportedFormatsReturn;
  }
  
  // Get list of available databases and styles.
  function soapGetSupportedStyles() {
    $this->printDebugMessage('soapGetSupportedStyles', 'Begin', 2);
    $this->serviceProxyConnect();
    $result = $this->srvProxy->getSupportedStyles();
    if($this->trace) $this->soapTrace();
    $this->printDebugMessage('soapGetSupportedStyles', 'End', 2);
    return $result->getSupportedStylesReturn;
  }
  
  // Get list of available formats for a database.
  function soapGetDbFormats($dbName) {
    $this->printDebugMessage('soapGetDbFormats', 'Begin', 2);
    $this->serviceProxyConnect();
    $result = $this->srvProxy->getDbFormats(array('db' => $dbName));
    if($this->trace) $this->soapTrace();
    $this->printDebugMessage('soapGetDbFormats', 'End', 2);
    return $result->getDbFormatsReturn;
  }
  
  // Get list of available styles for a format of a database.
  function soapGetFormatStyles($dbName, $formatName) {
    $this->printDebugMessage('soapGetFormatStyles', 'Begin', 2);
    $this->serviceProxyConnect();
    $result = $this->srvProxy->getFormatStyles(array(
						     'db' => $dbName,
						     'format' => $formatName
						     ));
    if($this->trace) $this->soapTrace();
    $this->printDebugMessage('soapGetFormatStyles', 'End', 2);
    return $result->getFormatStylesReturn;
  }
  
  // Get an entry.
  function soapFetchData($query, $formatName, $styleName) {
    $this->printDebugMessage('soapFetchData', 'Begin', 2);
    $this->serviceProxyConnect();
    $result = $this->srvProxy->fetchData(array(
					       'query' => $query,
					       'format' => $formatName,
					       'style' => $styleName
					       ));
    if($this->trace) $this->soapTrace();
    $this->printDebugMessage('soapFetchData', 'End', 2);
    return $result->fetchDataReturn;
  }
  
  // Get a set of entries.
  function soapFetchBatch($dbName, $idListStr, $formatName, $styleName) {
    $this->printDebugMessage('soapFetchBatch', 'Begin', 2);
    $this->serviceProxyConnect();
    $result = $this->srvProxy->fetchBatch(array(
						'db' => $dbName,
						'ids' => $idListStr,
						'format' => $formatName,
						'style' => $styleName
						));
    if($this->trace) $this->soapTrace();
    $this->printDebugMessage('soapFetchBatch', 'End', 2);
    return $result->fetchBatchReturn;
  }
}
?>
