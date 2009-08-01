<html>
<!-- $Id$ -->
<head>
<?php
// Load library
require('ncbiblast_php5.php');

// Generate HTML option tags for a parameter detail.
function paramDetailToOptionStr($paramDetail) {
  $retStr = '';
  foreach($paramDetail->values->value as $val) {
    if($val->defaultValue) {
      $retStr .= "<option selected=\"1\" value=\"$val->value\">$val->label</option>\n";
    }
    else {
      $retStr .= "<option value=\"$val->value\">$val->label</option>\n";
    }
  }
  return $retStr;
}
// Output a submission form
function printForm($client) {
  $paramDetail = $client->getParameterDetails('stype');
  $stypeOptions = paramDetailToOptionStr($paramDetail);
  $paramDetail = $client->getParameterDetails('program');
  $programOptions = paramDetailToOptionStr($paramDetail);
  $paramDetail = $client->getParameterDetails('database');
  $databaseOptions = paramDetailToOptionStr($paramDetail);
  $paramDetail = $client->getParameterDetails('scores');
  $scoresOptions = paramDetailToOptionStr($paramDetail);
  $paramDetail = $client->getParameterDetails('alignments');
  $alignmentsOptions = paramDetailToOptionStr($paramDetail);
  $paramDetail = $client->getParameterDetails('exp');
  $expOptions = paramDetailToOptionStr($paramDetail);

  print <<<EOF
<form method="POST">
<p>
E-mail: <input type="text" name="email" /><br />
Job title: <input type="text" name="title" />
</p>

<p>
Query
<select name="stype">
$stypeOptions
</select>
sequence:<br />
<textarea name="sequence" rows="5" cols="80">
</textarea>
</p>

<p>
Program:
<select name="program">
$programOptions
</select>
<br />
Database:
<select name="database[]" multiple="1">
$databaseOptions
</select>
<br />
Scores:
<select name="scores">
$scoresOptions
</select>
<br />
Alignments:
<select name="alignments">
$alignmentsOptions
</select>
<br />
E-value threshold:
<select name="exp">
$expOptions
</select>
</p>

<p align="right">
<input type="submit" value="Submit" />
<input type="reset" value="Reset" />
</p>
</form>
EOF
    ;
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
}

// Get the status of a job.
function getStatus($client, $jobId) {
  $status = $client->getStatus($jobId);
  echo "<p>Status for job <a href=\"?jobId=$jobId\">$jobId</a>: $status</p>\n";
  if($status == 'FINISHED') {
    printResultsSummary($client, $jobId);
  }
}

// Print details of available results for a job
function printResultsSummary($client, $jobId) {
  echo "<p>Results:</p>\n";
  echo "<ul>\n";
  $resultTypes = $client->getResultTypes($jobId);
  foreach($resultTypes as $resultType) {
    $resultUrl = "?jobId=$jobId&resultType=" . $resultType->identifier;
    print "<li><a href=\"$resultUrl\">" . $resultType->label . "</a>";
    if($resultType->description) {
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
    echo "<pre>$resultStr</pre>\n";
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
?>
<title>NCBI BLAST</title>
</head>

<body>
<h1 align="center">NCBI BLAST</h1>
<hr />

<?php
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
    $inputParams = (count($HTTP_POST_VARS)) ? $HTTP_POST_VARS : $HTTP_GET_VARS;
    
    // Create an instance of the client.
    $client = new NcbiBlastClient();
    
    // Get a result
    if(array_key_exists('jobId', $inputParams) &&
       array_key_exists('resultType', $inputParams)) {
      getResult($client, $inputParams['jobId'], $inputParams['resultType']);
    }
    // Get job status, and poll
    elseif(array_key_exists('jobId', $inputParams)) {
      getStatus($client, $inputParams['jobId']);
    }
    // Submit a job
    elseif(array_key_exists('stype', $inputParams)) {
      submitJob($client, $inputParams);
    }
    // Input form
    else {
      printForm($client);
    }
  }
  catch(SoapFault $ex) {
    echo '<p><b>Error</b>: ';
    if($ex->getMessage() != '') {
      echo $ex->getMessage();
    }
    else {
      echo $ex;
    }
    echo "</p>\n";
  }
  catch(Exception $ex) {
    echo '<p><b>Error</b>: ';
    if($ex->getMessage() != '') {
      echo $ex->getMessage();
    }
    else {
      echo $ex;
    }
    echo "</p>\n";
  }
}
?>
<hr />
<p>Powered by <a href="http://www.ebi.ac.uk/Tools/webservices/">EMBL-EBI Web Services</a></p>
</body>
</html>
