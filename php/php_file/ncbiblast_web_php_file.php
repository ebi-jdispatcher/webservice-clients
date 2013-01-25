<html>
<!-- $Id$ -->
<body>
<?php
# ======================================================================
# 
# Copyright 2009-2013 EMBL - European Bioinformatics Institute
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
# PHP NCBI BLAST REST web client
#
# Tested with:
#   PHP 5.2.6 (Ubuntu 9.04)
#
# See:
# http://www.ebi.ac.uk/Tools/webservices/services/sss/ncbi_blast_rest
# http://www.ebi.ac.uk/Tools/webservices/tutorials/php
# ======================================================================
// Load library
require_once('ncbiblast_lib_php_file.php');

// Extend client class
class NcbiBlastWebClient extends NcbiBlastClient {
  // Print list of tool parameters
  function printGetParameters() {
    $this->printDebugMessage('printGetParameters', 'Begin', 1);
    $paramList = $this->getParameters();
    print "<ul>\n";
    foreach($paramList as $paramName) {
      print '<li>' . $paramName . "</li>\n";
    }
    print "</ul>\n";
    $this->printDebugMessage('printGetParameters', 'End', 1);
  }

  // Print details of a parameter
  function printGetParameterDetails($parameterId) {
    $this->printDebugMessage('printGetParameterDetails', 'Begin', 1);
    $paramDetail = $this->getParameterDetails($parameterId);
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
	if($val->defaultValue && $val->defaultValue == 'true') print 'default';
	else print '&nbsp;';
	print "</td></tr>\n";
      }
      print "</table>\n";
    }
    $this->printDebugMessage('printGetParameterDetails', 'Begin', 1);
  }
  
  // Label for an option, generated from the parameter details.
  function paramDetailToLabelStr($parameterId, $paramDetail) {
    $this->printDebugMessage('paramDetailToLabelStr', 'Begin', 1);
    $helpUrl = '?paramDetail=' . $parameterId;
    $retStr = '<a href="' . $helpUrl . '">' . $paramDetail->name .'</a>: ';
    $this->printDebugMessage('paramDetailToLabelStr', 'End', 1);
    return $retStr;
  }
  
  // Generate HTML option tags for a parameter detail.
  function paramDetailToOptionStr($paramDetail) {
    $this->printDebugMessage('paramDetailToOptionStr', 'Begin', 1);
    $retStr = '';
    if(isset($paramDetail->values)) {
      foreach($paramDetail->values->value as $val) {
	if($val->defaultValue && $val->defaultValue == 'true') {
	  $retStr .= "<option selected=\"1\" value=\"$val->value\">$val->label</option>\n";
	}
	else {
	  $retStr .= "<option value=\"$val->value\">$val->label</option>\n";
	}
      }
    }
    $this->printDebugMessage('paramDetailToOptionStr', 'End', 1);
    return $retStr;
  }

  // Generate HTML tags for a parameter detail. menu or text input.
  function paramDetailToStr($parameterId, $multi=FALSE) {
    $this->printDebugMessage('paramDetailToStr', 'Begin', 1);
    $paramDetail = $this->getParameterDetails($parameterId);
    $retStr = $this->paramDetailToLabelStr($parameterId, $paramDetail);
    if(isset($paramDetail->values)) {
      if($multi) {
	// Multi-select menu
	$retStr .= '<select name="' . $parameterId .'[]"  multiple="1">';
      }
      else {
	// Drop-down list
	$retStr .= '<select name="' . $parameterId .'">';
      }
      $retStr .= $this->paramDetailToOptionStr($paramDetail);
      $retStr .= '</select>';
    }
    else {
      // Input box
      $retStr .= '<input type="text" name="' . $parameterId . '" />';
    }
    $this->printDebugMessage('paramDetailToStr', 'End', 1);
    return $retStr;
  }

  // Output a submission form
  function printForm() {
    $this->printDebugMessage('printForm', 'Begin', 1);
    $stypeStr = $this->paramDetailToStr('stype');
    $programStr = $this->paramDetailToStr('program');
    $databaseStr =  $this->paramDetailToStr('database', TRUE);
    $scoresStr = $this->paramDetailToStr('scores');
    $alignmentsStr = $this->paramDetailToStr('alignments');
    $expStr = $this->paramDetailToStr('exp');
    
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
    $this->printDebugMessage('printForm', 'End', 1);
  }
  
  // Submit a job to the service.
  function submitJob($options) {
    $this->printDebugMessage('submitJob', 'Begin', 1);
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
    $jobId = $this->run(
			$options['email'],
			$options['title'],
			$params
			);
    echo "<p>Job Id: <a href=\"?jobId=$jobId\">$jobId</a></p>";
    echo "<p>Please wait...</p>";
    $this->printDebugMessage('submitJob', 'End', 1);
    return $this->genMetaRefresh($jobId);
  }

  // Get the status of a job.
  function printStatus($jobId) {
    $this->printDebugMessage('printStatus', 'Begin', 1);
    $retVal = '';
    $status = $this->getStatus($jobId);
    echo "<p>Status for job <a href=\"?jobId=$jobId\">$jobId</a>: $status</p>\n";
    if($status == 'FINISHED') {
      $this->printResultsSummary($jobId);
    }
    else {
      $retVal = $this->genMetaRefresh($jobId);
    }
    $this->printDebugMessage('printStatus', 'End', 1);
    return $retVal;
  }

  // Print details of available results for a job
  function printResultsSummary($jobId) {
    $this->printDebugMessage('printResultsSummary', 'Begin', 1);
    echo "<p>Results:</p>\n";
    echo "<ul>\n";
    $resultTypes = $this->getResultTypes($jobId);
    foreach($resultTypes as $resultType) {
      $resultUrl = "?jobId=$jobId&resultType=" . $resultType->identifier;
      print "<li><a href=\"$resultUrl\">" . $resultType->label . "</a>";
      if(isset($resultType->description)) {
	print ": " . $resultType->description . "\n";
      }
      print "</li>\n";
    }
    echo "</ul>\n";
    $this->printDebugMessage('printResultsSummary', 'End', 1);
  }

  // Get a job result.
  function printResult($jobId, $resultType) {
    $this->printDebugMessage('printResult', 'Begin', 1);
    echo "<p>Result for job <a href=\"?jobId=$jobId\">$jobId</a>:</p>\n";
    $resultTypeObjs = $this->getResultTypes($jobId);
    foreach($resultTypeObjs as $resultTypeObj) {
      if($resultTypeObj->identifier == $resultType) {
	$selResultTypeObj = $resultTypeObj;
      }
    }
    // Plain text
    if($selResultTypeObj->mediaType == 'text/plain') {
      $resultStr = $this->getResult($jobId, $resultType);
      echo "<p><pre>$resultStr</pre></p>\n";
    }
    // Image, embed using img tag using service REST API for document
    elseif(strpos($selResultTypeObj->mediaType, 'image') === 0 &&
	   strpos($selResultTypeObj->mediaType, 'xml') == 0) {
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
    $this->printDebugMessage('printResult', 'Begin', 1);
  }

  // Generate meta-refresh tag for a job.
  function genMetaRefresh($jobId) {
    $this->printDebugMessage('genMetaRefresh', 'Begin', 2);
    $statusUrl = "?jobId=$jobId";
    $retVal = "<meta http-equiv=\"refresh\" content=\"10;url=$statusUrl\">";
    $this->printDebugMessage('genMetaRefresh', 'Begin', 2);
    return $retVal;
  }
}
?>

<h1 align="center">NCBI BLAST (REST)</h1>
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
    $client = new NcbiBlastWebClient();
    // HTTP proxy config (modify for your local configuration).
    //$client->setHttpProxy('proxy.example.org', '8080');

    // Debug
    if(array_key_exists('debug', $inputParams)) $client->debugLevel = 2;

    // Get a result
    if(array_key_exists('jobId', $inputParams) &&
       array_key_exists('resultType', $inputParams)) {
      $client->printResult($inputParams['jobId'],
			   $inputParams['resultType']);
    }
    // Get job status, and poll
    elseif(array_key_exists('jobId', $inputParams)) {
      $metaRefresh = $client->printStatus($inputParams['jobId']);
    }
    // Option/parameter details/help.
    elseif(array_key_exists('paramDetail', $inputParams)) {
      $client->printGetParameterDetails($inputParams['paramDetail']);
    }
    // Submit a job
    elseif(array_key_exists('stype', $inputParams)) {
      $metaRefresh = $client->submitJob($inputParams);
    }
    // Input form
    else {
      $client->printForm();
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
<title>NCBI BLAST (REST)</title>
</head>
<?php
// Meta refresh
print $metaRefresh;
?>
</html>
