<?php

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
# Uses nuSOAP (http://sourceforge.net/projects/nusoap/)
#
# Tested with:
#   PHP 5.1.6 (CentOS 5)
#   PHP 5.3.2 with nuSOAP 0.7.3-2 (Ubuntu 10.04 LTS)
#   PHP 5.3.10 with nuSOAP 0.7.3-4 (Ubuntu 12.04 LTS)
#
# See:
# http://www.ebi.ac.uk/Tools/webservices/services/dbfetch
# http://www.ebi.ac.uk/Tools/webservices/tutorials/php
# ======================================================================
# Load the nuSOAP library (Debian/Ubuntu install location)
require_once('/usr/share/php/nusoap/nusoap.php');

class WSDbfetchClient {
  // Service WSDL URL.
  private $wsdlUrl = 'http://www.ebi.ac.uk/ws/services/WSDbfetchDoclit?wsdl';
  // Service client.
  private $srvClient;
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
    // Get service proxy
    if($this->srvProxy == null) {
      // Get the client object from the WSDL
      if(class_exists('soapclientNusoap')) {
        // nusoap-for-php5
        $this->srvClient = new soapclientNusoap($this->wsdlUrl, true);
      }
      elseif(class_exists('nusoap_client')) {
        // nuSOAP 0.7.3
        $this->srvClient = new nusoap_client($this->wsdlUrl, true);
      }
      elseif(class_exists('soapclient')) {
        // nuSOAP 0.7.2 or earlier (assumes PHP SOAP is not available)
        $this->srvClient = new soapclient($this->wsdlUrl, true);
      }
      else {
      	trigger_error('nuSOAP cannot be found.', E_USER_ERROR);
      }
      $err = $this->srvClient->getError();
      if($err) trigger_error($err, E_USER_ERROR);
      // Configure HTTP proxy.
      if(isset($this->httpProxy)) {
        $this->srvClient->setHTTPProxy(
	  $this->httpProxy['proxy_host'], $this->httpProxy['proxy_port']
        );
      }
      // Set encoding.
      $this->srvClient->soap_defencoding = 'UTF-8';
      // TODO: Override endpoint.
      //$this->srvClient->setEndpoint($endpoint);
      $this->srvProxy = $this->srvClient->getProxy();
      $err = $this->srvProxy->getError();
      if($err) trigger_error($err, E_USER_ERROR);
    }
    $this->printDebugMessage('serviceProxyConnect', 'End', 3);
  }
 
  // Print SOAP messages exchanged between client and server.
  function soapTrace() {
    $this->printDebugMessage('soapTrace', 'Begin', 12);
    if($this->srvProxy != NULL) {
      echo "REQUEST:\n" . $this->srvProxy->request . "\n";
      echo "RESPONSE:\n" . $this->srvProxy->response . "\n";
      //echo "DEBUG:\n" . $this->srvProxy->debug_str . "\n";
    }
    $this->printDebugMessage('soapTrace', 'End', 12);
  }

  // Get database meta-information.
  function soapGetDatabaseInfo($dbName) {
    $this->printDebugMessage('soapGetDatabaseInfo', 'Begin', 2);
    $this->serviceProxyConnect();
    $result = $this->srvProxy->getDatabaseInfo(array('db' => $dbName));
    if($this->trace) $this->soapTrace();
    $this->printDebugMessage('soapGetDatabaseInfo', 'End', 2);
    return $result['getDatabaseInfoReturn'];
  }
  
  // Get database meta-information for all databases.
  function soapGetDatabaseInfoList() {
    $this->printDebugMessage('soapGetDatabaseInfoList', 'Begin', 2);
    $this->serviceProxyConnect();
    $result = $this->srvProxy->getDatabaseInfoList(array());
    if($this->trace) $this->soapTrace();
    $this->printDebugMessage('soapGetDatabaseInfoList', 'End', 2);
    return $result['getDatabaseInfoListReturn'];
  }
  
  // Get list of available databases.
  function soapGetSupportedDBs() {
    $this->printDebugMessage('soapGetSupportedDBs', 'Begin', 2);
    $this->serviceProxyConnect();
    $result = $this->srvProxy->getSupportedDBs(array());
    if($this->trace) $this->soapTrace();
    $this->printDebugMessage('soapGetSupportedDBs', 'End', 2);
    return $result['getSupportedDBsReturn'];
  }
  
  // Get list of available databases and formats.
  function soapGetSupportedFormats() {
    $this->printDebugMessage('soapGetSupportedFormats', 'Begin', 2);
    $this->serviceProxyConnect();
    $result = $this->srvProxy->getSupportedFormats(array());
    if($this->trace) $this->soapTrace();
    $this->printDebugMessage('soapGetSupportedFormats', 'End', 2);
    return $result['getSupportedFormatsReturn'];
  }
  
  // Get list of available databases and styles.
  function soapGetSupportedStyles() {
    $this->printDebugMessage('soapGetSupportedStyles', 'Begin', 2);
    $this->serviceProxyConnect();
    $result = $this->srvProxy->getSupportedStyles(array());
    if($this->trace) $this->soapTrace();
    $this->printDebugMessage('soapGetSupportedStyles', 'End', 2);
    return $result['getSupportedStylesReturn'];
  }
  
  // Get list of available formats for a database.
  function soapGetDbFormats($dbName) {
    $this->printDebugMessage('soapGetDbFormats', 'Begin', 2);
    $this->serviceProxyConnect();
    $result = $this->srvProxy->getDbFormats(array('db' => $dbName));
    if($this->trace) $this->soapTrace();
    $this->printDebugMessage('soapGetDbFormats', 'End', 2);
    return $result['getDbFormatsReturn'];
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
    return $result['getFormatStylesReturn'];
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
    return $result['fetchDataReturn'];
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
    return $result['fetchBatchReturn'];
  }
}
?>
