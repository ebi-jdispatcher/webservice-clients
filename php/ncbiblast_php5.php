<?php
# ======================================================================
# PHP NCBI BLAST SOAP client library
#
# See:
# http://www.ebi.ac.uk/Tools/webservices/services/sss/ncbiblast
# http://www.ebi.ac.uk/Tools/webservices/tutorials/php
# ======================================================================

class NcbiBlastClient {
  // Service WSDL
  private $wsdlUrl = 'http://www.ebi.ac.uk/Tools/services/soap/ncbiblast?wsdl';
  // Service proxy
  private $proxy;
  // Trace flag
  public $trace = 0;

  // Get a service proxy
  function serviceProxyConnect() {
    // Get service proxy
    if($this->proxy == null) {
      $this->proxy = new SoapClient($this->wsdlUrl,
				    array('trace' => $this->trace));
    }
  }

  function soapTrace() {
    echo "REQUEST:\n" . $this->proxy->__getLastRequest() . "\n";
    echo "RESPONSE:\n" . $this->proxy->__getLastResponse() . "\n";
  }

  // Get list of tool parameter names
  function getParameters() {
    $this->serviceProxyConnect();
    $parameters = $this->proxy->getParameters();
    if($this->trace) $this->soapTrace();
    return $parameters->parameters->id;
  }

  // Print list of tool parameters
  function printGetParameters() {
    foreach($this->getParameters() as $paramName) {
      print $paramName . "\n";
    }
  }

  // Get detail of a parameter
  function getParameterDetails($parameterId) {
    $this->serviceProxyConnect();
    $res = $this->proxy->getParameterDetails(array('parameterId' => $parameterId));
    if($this->trace) $this->soapTrace();
    return $res->parameterDetails;
  }

  // Print details of a parameter
  function printGetParameterDetails($parameterId) {
    $paramDetail = $this->getParameterDetails($parameterId);
    print $paramDetail->name . "\t" . $paramDetail->type . "\n";
    print $paramDetail->description . "\n";
    foreach($paramDetail->values->value as $val) {
      print $val->value . "\t";
      if($val->defaultValue) print 'default';
      print "\n";
      print "\t" . $val->label . "\n";
    }
  }
  
  // Submit a job to the service
  function run($email, $title, $params) {
    $this->serviceProxyConnect();
    $res = $this->proxy->run(
			     array('email' => $email,
				   'title' => $title,
				   'parameters' => $params)
			     );
    if($this->trace) $this->soapTrace();
    return $res->jobId;
  }

  // Get the status of a job
  function getStatus($jobId) {
    $res = $this->proxy->getStatus(array('jobId' => $jobId));
    if($this->trace) $this->soapTrace();
    return $res->status;
  }
  
  // Available result types for a finished job
  function getResultTypes($jobId) {
    $res = $this->proxy->getResultTypes(array('jobId' => $jobId));
    if($this->trace) $this->soapTrace();
    return $res->resultTypes->type;
  }
  
  // Print available result types for a job
  function printGetResultTypes($jobId) {
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
  }
  
  // Get job results
  function getResult($jobId, $type) {
    $res = $this->proxy->getResult(array('jobId' => $jobId,
					 'type' => $type,
					 'parameters' => array()
					 )
				   );
    if($this->trace) $this->soapTrace();
    return $res->output;
  }

  function submit($options) {
    $jobId = $this->run(
			$options['email'],
			$options['title'],
			$options['params']);
    // Async submission
    if($options['async']) {
      echo "$jobId\n";
    }
    // Get results
    else {
      $options['jobId'] = $jobId;
      $this->poll($options);
    }
  }

  // Client-side job polling.
  function clientPoll($jobId) {
    // Get status
    $status = 'PENDING';
    while(strcmp($status, 'PENDING') == 0 || strcmp($status, 'RUNNING') == 0) {
      $status = $this->getStatus($jobId);
      echo "$status\n";
      if(strcmp($status, 'PENDING') == 0 || strcmp($status, 'RUNNING') == 0) {
	sleep(15);
      }
    }
  }

  function poll($options) {
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
  }
}
?>
