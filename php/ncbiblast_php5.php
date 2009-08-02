<?php
# $Id$
# ======================================================================
# PHP NCBI BLAST SOAP client library
#
# See:
# http://www.ebi.ac.uk/Tools/webservices/services/sss/ncbi_blast_soap
# http://www.ebi.ac.uk/Tools/webservices/services/sss/ncbi_blast_rest
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
  public $trace = 0;
  // Debug level
  public $debugLevel = 0;

  // Debug message
  private function printDebugMessage($method, $message, $level) {
    if($level <= $this->debugLevel) {
      if(array_key_exists('argc', $GLOBALS)) {
	print "[$method] $message\n";
      }
      else {
	print "<p>[$method] $message</p>\n";
      }
    }
  }

  // Set HTTP proxy details
  function setHttpProxy($host, $port=8080) {
    $this->printDebugMessage('setHttpProxy', 'Begin', 1);
    $this->httpProxy = array('proxy_host' => $host,
			     'proxy_port' => $port);
    $this->printDebugMessage('setHttpProxy', 'End', 1);
  }

  // Get a service proxy
  function serviceProxyConnect() {
    $this->printDebugMessage('serviceProxyConnect', 'Begin', 2);
    // Get service proxy
    if($this->srvProxy == null) {
      $options = array('trace' => $this->trace);
      if(isset($this->httpProxy)) {
	$options['proxy_host'] = $this->httpProxy['proxy_host'];
	$options['proxy_port'] = $this->httpProxy['proxy_port'];
      }
      $this->srvProxy = new SoapClient($this->wsdlUrl,
				    $options);
    }
    $this->printDebugMessage('serviceProxyConnect', 'End', 2);
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

  // Print list of tool parameters
  function printGetParameters() {
    $this->printDebugMessage('printGetParameters', 'Begin', 1);
    $paramList = $this->getParameters();
    if(!$GLOBALS['argc']) print "<ul>\n";
    foreach($paramList as $paramName) {
      if($GLOBALS['argc']) {
	print $paramName . "\n";
      }
      else {
	print '<li>' . $paramName . "</li>\n";
      }
    }
    if(!$GLOBALS['argc']) print "</ul>\n";
    $this->printDebugMessage('printGetParameters', 'End', 1);
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

  // Print details of a parameter
  function printGetParameterDetails($parameterId) {
    $this->printDebugMessage('printGetParameterDetails', 'Begin', 1);
    $paramDetail = $this->getParameterDetails($parameterId);
    if(array_key_exists('argc', $GLOBALS)) {
      // Plain text
      print $paramDetail->name . "\t" . $paramDetail->type . "\n";
      print $paramDetail->description . "\n";
      if(isset($paramDetail->values)) {
	foreach($paramDetail->values->value as $val) {
	  print $val->value . "\t";
	  if($val->defaultValue) print 'default';
	  print "\n";
	  if($val->label) print "\t" . $val->label . "\n";
	}
      }
    }
    else {
      // HTML
      print <<<EOF
<h3>$paramDetail->name</h3>

<p>$paramDetail->description</p>
EOF
    ;
      if(isset($paramDetail->values)) {
	print "<table border=\"1\">\n";
	print "<tr><th>Label</th><th>Value</th><th>Default</th></tr>\n";
	foreach($paramDetail->values->value as $val) {
	  print "<tr><td>$val->label</td><td>$val->value</td><td>";
	  if($val->defaultValue) print 'default';
	  else print '&nbsp;';
	  print "</td></tr>\n";
	}
	print "</table>\n";
      }
    }
    $this->printDebugMessage('printGetParameterDetails', 'Begin', 1);
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

  function submit($options) {
    $this->printDebugMessage('submit', 'Begin', 1);
    if(!$options['params']['match_scores'] &&
       ($options['match'] && $options['mismatch'])) {
      $options['params']['match_scores'] = $options['match'] . ',' . $options['mismatch'];
    }
    $jobId = $this->run(
			$options['email'],
			$options['title'],
			$options['params']);
    // Async submission
    if($options['async'] && $options['outputLevel'] > 0) {
      echo "$jobId\n";
    }
    // Get results
    else {
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
    if($options['outfile']) {
      $baseName = $options['outfile'];
    } else {
      $baseName = $options['jobId'];
    }
    foreach($resultTypeList as $resultType) {
      $result = '';
      $filename = $baseName . '.' . $resultType->identifier . '.' . $resultType->fileSuffix;
      if($options['input']['outformat']) {
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
?>
