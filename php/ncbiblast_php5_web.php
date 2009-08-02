<html>
<!-- $Id$ -->
<body>
<?php
// Load library
require_once('ncbiblast_php5.php');

// Output a submission form
function printForm($client) {
  $stypeStr = paramDetailToStr($client, 'stype');
  $programStr = paramDetailToStr($client, 'program');
  $databaseStr =  paramDetailToStr($client, 'database', TRUE);
  $scoresStr = paramDetailToStr($client, 'scores');
  $alignmentsStr = paramDetailToStr($client, 'alignments');
  $expStr = paramDetailToStr($client, 'exp');

  print <<<EOF
<form method="POST">
<p>E-mail: <input type="text" name="email" />&nbsp;
Job title: <input type="text" name="title" /></p>

<p>$stypeStr<br />
<a href="?paramDetail=sequence">Sequence</a>:<br />
<textarea name="sequence" rows="5" cols="80">
</textarea></p>

<p>$programStr $databaseStr</p>

<p>$scoresStr $alignmentsStr $expStr</p>

<p align="right">
<input type="submit" value="Submit" />
<input type="reset" value="Reset" />
</p>
</form>
EOF
    ;
}

// Generate HTML tags for a parameter detail. menu or text input.
function paramDetailToStr($client, $parameterId, $multi=FALSE) {
  $paramDetail = $client->getParameterDetails($parameterId);
  $retStr = paramDetailToLabelStr($parameterId, $paramDetail);
  if(isset($paramDetail->values)) {
    if($multi) {
      // Multi-select menu
      $retStr .= '<select name="' . $parameterId .'[]"  multiple="1">';
    }
    else {
      // Drop-down list
      $retStr .= '<select name="' . $parameterId .'">';
    }
    $retStr .= paramDetailToOptionStr($paramDetail);
    $retStr .= '</select>';
  }
  else {
    // Input box
    $retStr .= '<input type="text" name="' . $parameterId . '" />';
  }
  return $retStr;
}

// Label for an option, generated from the parameter details.
function paramDetailToLabelStr($parameterId, $paramDetail) {
  $helpUrl = '?paramDetail=' . $parameterId;
  $retStr = '<a href="' . $helpUrl . '">' . $paramDetail->name .'</a>: ';
  return $retStr;
}

// Generate HTML option tags for a parameter detail.
function paramDetailToOptionStr($paramDetail) {
  $retStr = '';
  if(isset($paramDetail->values)) {
    foreach($paramDetail->values->value as $val) {
      if($val->defaultValue) {
	$retStr .= "<option selected=\"1\" value=\"$val->value\">$val->label</option>\n";
      }
      else {
	$retStr .= "<option value=\"$val->value\">$val->label</option>\n";
      }
    }
  }
  return $retStr;
}

// Submit a job to the service.
function submitJob($client, $options) {
    echo "Submit job...<br />\n";
    $params  = array();
    foreach($options as $key => $val) {
      switch($key) {
      case 'stype':
	$params[$key] = $val;
	break;
      case 'sequence':
	$params[$key] = $val;
	break;
      case 'program':
	$params[$key] = $val;
	break;
      case 'database':
	$params[$key] = $val;
	break;
      case 'scores':
	$params[$key] = $val;
	break;
      case 'alignments':
	$params[$key] = $val;
	break;
      }
    }
    $jobId = $client->run(
			  $options['email'],
			  $options['title'],
			  $params
			  );
    echo "<p>Job Id: <a href=\"?jobId=$jobId\">$jobId</a></p>";
    return genMetaRefresh($jobId);
}

// Get the status of a job.
function getStatus($client, $jobId) {
  $retVal = '';
  $status = $client->getStatus($jobId);
  echo "<p>Status for job <a href=\"?jobId=$jobId\">$jobId</a>: $status</p>\n";
  if($status == 'FINISHED') {
    printResultsSummary($client, $jobId);
  }
  else {
    $retVal = genMetaRefresh($jobId);
  }
  return $retVal;
}

// Print details of available results for a job
function printResultsSummary($client, $jobId) {
  echo "<p>Results:</p>\n";
  echo "<ul>\n";
  $resultTypes = $client->getResultTypes($jobId);
  foreach($resultTypes as $resultType) {
    $resultUrl = "?jobId=$jobId&resultType=" . $resultType->identifier;
    print "<li><a href=\"$resultUrl\">" . $resultType->label . "</a>";
    if(isset($resultType->description)) {
      print ": " . $resultType->description . "\n";
    }
    print "</li>\n";
  }
  echo "</ul>\n";
}

// Get a job result.
function getResult($client, $jobId, $resultType) {
  echo "<p>Result for job <a href=\"?jobId=$jobId\">$jobId</a>:</p>\n";
  $resultTypeObjs = $client->getResultTypes($jobId);
  foreach($resultTypeObjs as $resultTypeObj) {
    if($resultTypeObj->identifier == $resultType) {
       $selResultTypeObj = $resultTypeObj;
    }
  }
  // Plain text
  if($selResultTypeObj->mediaType == 'text/plain') {
    $resultStr = $client->getResult($jobId, $resultType);
    echo "<p><pre>$resultStr</pre></p>\n";
  }
  // Image, embed using img tag using service REST API for document
  elseif(strpos($selResultTypeObj->mediaType, 'image') === 0 && strpos($selResultTypeObj->mediaType, 'xml') == 0) {
    $resultUrl = 'http://www.ebi.ac.uk/Tools/services/rest/ncbiblast/result/';
    $resultUrl .= $jobId . '/' . $resultType;
    echo "<img src=\"$resultUrl\"></img>";
  }
  // Other, embed in iframe using service REST API for document
  else {
    $resultUrl = 'http://www.ebi.ac.uk/Tools/services/rest/ncbiblast/result/';
    $resultUrl .= $jobId . '/' . $resultType;
    echo "<iframe src=\"$resultUrl\" width=\"100%\" height=\"100%\"></iframe>";
  }
}

// Generate meta-refresh tag for a job.
function genMetaRefresh($jobId) {
  $statusUrl = "?jobId=$jobId";
  return "<meta http-equiv=\"refresh\" content=\"10;url=$statusUrl\">";
}
?>

<h1 align="center">NCBI BLAST</h1>
<hr />

<?php
// No refresh.
$metaRefresh = '';
// Check PHP version...
if(floatval(phpversion()) < 5.0) {
  echo "<p>PHP 5 is required for this page. This is PHP " . phpversion() . "</p>";
}
else {

  // Map PHP errors to exceptions
  if(class_exists('ErrorException')) {
    function exception_error_handler($errno, $errstr, $errfile, $errline ) {
      throw new ErrorException($errstr, 0, $errno, $errfile, $errline);
    }
    set_error_handler("exception_error_handler");
  }
  
  try {
    // Grab input params
    $inputParams = array();
    if(isset($_POST) && count($_POST) > 0) {
      $inputParams = $_POST;
    }
    elseif(isset($_GET) && count($_GET) > 0) {
      $inputParams = $_GET;
    }

    // Create an instance of the client.
    $client = new NcbiBlastClient();
    // HTTP proxy config.
    //$client->setHttpProxy($proxy_host, $proxy_port);

    // Debug
    if(array_key_exists('debug', $inputParams)) {
      $client->debugLevel = 2;
    }

    // Get a result
    if(array_key_exists('jobId', $inputParams) &&
       array_key_exists('resultType', $inputParams)) {
      getResult($client, $inputParams['jobId'], $inputParams['resultType']);
    }
    // Get job status, and poll
    elseif(array_key_exists('jobId', $inputParams)) {
      $metaRefresh = getStatus($client, $inputParams['jobId']);
    }
    // Option/parameter details/help.
    elseif(array_key_exists('paramDetail', $inputParams)) {
      $client->printGetParameterDetails($inputParams['paramDetail']);
    }
    // Submit a job
    elseif(array_key_exists('stype', $inputParams)) {
      $metaRefresh = submitJob($client, $inputParams);
    }
    // Input form
    else {
      printForm($client);
    }
  }
  catch(SoapFault $ex) {
    echo '<p><b>Error</b>: ';
    if($ex->getMessage() != '') echo $ex->getMessage();
    else echo $ex;
    echo "</p>\n";
    // In debug mode, output message trace for exception.
    if(array_key_exists('debug', $inputParams)) {
      print '<p><pre>';
      $client->soapTrace();
      print '</pre></p>';
    }
  }
  catch(Exception $ex) {
    echo '<p><b>Error</b>: ';
    if($ex->getMessage() != '') echo $ex->getMessage();
    else echo $ex;
    echo "</p>\n";
  }
}
?>
<hr />
<p>Powered by <a href="http://www.ebi.ac.uk/Tools/webservices/">EMBL-EBI Web Services</a></p>
</body>

<head>
<title>NCBI BLAST</title>
</head>
<?php
// Meta refresh
print $metaRefresh;
?>
</html>
