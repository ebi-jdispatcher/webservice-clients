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
# PHP NCBI BLAST SOAP client library
#
# Tested with:
#   PHP 5.1.6 (CentOS 5)
#   PHP 5.2.6 (Ubuntu 9.04)
#
# See:
# http://www.ebi.ac.uk/Tools/webservices/services/sss/ncbi_blast_soap
# http://www.ebi.ac.uk/Tools/webservices/tutorials/php
# ======================================================================

class NcbiBlastClient {
  // Service WSDL
  private $wsdlUrl = 'http://www.ebi.ac.uk/Tools/services/soap/ncbiblast?wsdl';
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
    // CHeck for SoapClient
    if(!class_exists('SoapClient')) {
      throw new Exception('SoapClient class cannot be found.');
    }
    // Get service proxy
    if($this->srvProxy == null) {
      $options = array('trace' => $this->trace,
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

  function soapTrace() {
    $this->printDebugMessage('soapTrace', 'Begin', 12);
    echo "REQUEST:\n" . $this->srvProxy->__getLastRequest() . "\n";
    echo "RESPONSE:\n" . $this->srvProxy->__getLastResponse() . "\n";
    $this->printDebugMessage('soapTrace', 'End', 12);
  }

  // Get list of tool parameter names
  function getParameters() {
    $this->printDebugMessage('getParameters', 'Begin', 1);
    $this->serviceProxyConnect();
    $parameters = $this->srvProxy->getParameters();
    if($this->trace) $this->soapTrace();
    $this->printDebugMessage('getParameters', 'End', 1);
    return $parameters->parameters->id;
  }

  // Get detail of a parameter
  function getParameterDetails($parameterId) {
    $this->printDebugMessage('getParameterDetails', 'Begin', 1);
    $this->printDebugMessage('getParameterDetails',
			     "parameterId: $parameterId", 2);
    $this->serviceProxyConnect();
    $res = $this->srvProxy->getParameterDetails(array('parameterId' => $parameterId));
    if($this->trace) $this->soapTrace();
    $this->printDebugMessage('getParameterDetails', 'End', 1);
    return $res->parameterDetails;
  }

  // Submit a job to the service
  function run($email, $title, $params) {
    $this->printDebugMessage('run', 'Begin', 1);
    $this->serviceProxyConnect();
    $res = $this->srvProxy->run(
			     array('email' => $email,
				   'title' => $title,
				   'parameters' => $params)
			     );
    if($this->trace) $this->soapTrace();
    $this->printDebugMessage('run', 'End', 1);
    return $res->jobId;
  }

  // Get the status of a job
  function getStatus($jobId) {
    $this->printDebugMessage('getStatus', 'Begin', 1);
    $this->serviceProxyConnect();
    $res = $this->srvProxy->getStatus(array('jobId' => $jobId));
    if($this->trace) $this->soapTrace();
    $this->printDebugMessage('getStatus', 'End', 1);
    return $res->status;
  }
  
  // Available result types for a finished job
  function getResultTypes($jobId) {
    $this->printDebugMessage('getResultTypes', 'Begin', 1);
    $this->serviceProxyConnect();
    $res = $this->srvProxy->getResultTypes(array('jobId' => $jobId));
    if($this->trace) $this->soapTrace();
    $this->printDebugMessage('getResultTypes', 'End', 1);
    return $res->resultTypes->type;
  }
  
  // Get job results
  function getResult($jobId, $type) {
    $this->printDebugMessage('getResult', 'Begin', 1);
    $this->serviceProxyConnect();
    $res = $this->srvProxy->getResult(array('jobId' => $jobId,
					    'type' => $type,
					    'parameters' => array()
					    )
				      );
    if($this->trace) $this->soapTrace();
    $this->printDebugMessage('getResult', 'End', 1);
    return $res->output;
  }
}
?>
