<?php
# ======================================================================
# 
# Copyright 2011-2018 EMBL - European Bioinformatics Institute
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
# PHP WSDbfetch document/literal SOAP service command-line client.
#
# Uses PHP SOAP.
#
# Note: install, along with wsdbfetch_lib_php_soap.php, in a directory 
# which is served by a web server with PHP enabled.
#
# Tested with:
#   PHP 5.1.6 (CentOS 5)
#   PHP 5.3.2 (Ubuntu 10.04 LTS)
#
# See:
# http://www.ebi.ac.uk/Tools/webservices/services/dbfetch
# http://www.ebi.ac.uk/Tools/webservices/tutorials/php
# ======================================================================
# Load WSDbfetch client library
require_once('wsdbfetch_lib_php_soap.php');

class WSDbfetchWebClient extends WSDbfetchClient {
  // Print list of available databases.
  function printGetSupportedDBs() {
    $this->printDebugMessage('printGetSupportedDBs', 'Begin', 1);
    $result = $this->soapGetSupportedDBs();
    print "<ul>\n";
    foreach($result as $item) {
      echo "<li>" . $item . "</li>\n";
    }
    print "</ul>\n";
    $this->printDebugMessage('printGetSupportedDBs', 'End', 1);
  }

  // Print list of available databases and formats.
  function printGetSupportedFormats() {
    $this->printDebugMessage('printGetSupportedFormats', 'Begin', 1);
    $result = $this->soapGetSupportedFormats();
    print "<ul>\n";
    foreach($result as $item) {
      echo "<li>" . $item . "</li>\n";
    }
    print "</ul>\n";
    $this->printDebugMessage('printGetSupportedFormats', 'End', 1);
  }
  // Print list of available databases and styles.
  function printGetSupportedStyles() {
    $this->printDebugMessage('printGetSupportedStyles', 'Begin', 1);
    $result = $this->soapGetSupportedStyles();
    print "<ul>\n";
    foreach($result as $item) {
      echo "<li>" . $item . "</li>\n";
    }
    print "</ul>\n";
    $this->printDebugMessage('printGetSupportedStyles', 'End', 1);
  }

  // Print list of available formats for a database.
  function printGetDbFormats($dbName) {
    $this->printDebugMessage('printGetDbFormats', 'Begin', 1);
    $result = $this->soapGetDbFormats($dbName);
    print "<ul>\n";
    foreach($result as $item) {
      echo "<li>" . $item . "</li>\n";
    }
    print "</ul>\n";
    $this->printDebugMessage('printGetDbFormats', 'End', 1);
  }

  // Print list of available styles for a format of a database.
  function printGetFormatStyles($dbName, $formatName) {
    $this->printDebugMessage('printGetFormatStyles', 'Begin', 1);
    $result = $this->soapGetFormatStyles($dbName, $formatName);
    print "<ul>\n";
    foreach($result as $item) {
      echo "<li>" . $item . "</li>\n";
    }
    print "</ul>\n";
    $this->printDebugMessage('printGetFormatStyles', 'End', 1);
  }
  
  // Print an entry.
  function printFetchData($query, $formatName, $styleName) {
    $this->printDebugMessage('printFetchData', 'Begin', 1);
    $result = $this->soapFetchData($query, $formatName, $styleName);
    echo $result . "\n";
    $this->printDebugMessage('printFetchData', 'End', 1);
  }

  // Print a set of entries.
  function printFetchBatch($dbName, $idListStr, $formatName, $styleName) {
    $this->printDebugMessage('printFetchBatch', 'Begin', 1);
    $result = $this->soapFetchBatch($dbName, $idListStr, $formatName, $styleName);
    echo $result . "\n";
    $this->printDebugMessage('printFetchBatch', 'End', 1);
  }

  // Output a submission form
  function printForm() {
    $this->printDebugMessage('printForm', 'Begin', 1);
    print <<<EOF
<form method="GET">
<p>
<a href="?info=database">Database</a>: <input name="database"></input>
Ids: <input name="id"></input>
Format: <input name="format"></input>
Style: <input name="style"></input>
</p>
<p align="right">
<input type="submit" value="Submit" />
<input type="reset" value="Reset" />
</p>
</form>
EOF
  ;
    $this->printDebugMessage('printForm', 'End', 1);
  }

  // Retrive entry and output.
  function printResult($inputParams) {
    $this->printDebugMessage('printResult', 'Begin', 1);
    // Database name.
    $database = 'default';
    if(array_key_exists('database', $inputParams)) {
      $database = $inputParams['database'];
    }
    // Data format.
    $format = 'default';
    if(array_key_exists('format', $inputParams)) {
      $format = $inputParams['format'];
    }
    // Result style.
    $style = 'default';
    if(array_key_exists('style', $inputParams)) {
      $style = $inputParams['style'];
    }
    // Fetch the data.
    $result = $this->soapFetchBatch($database, $inputParams['id'], $format, $style);
    // Output (assumes text/plain)
    print "<pre>\n";
    print $result;
    print "</pre>\n";
    $this->printDebugMessage('printResult', 'End', 1);
  }

  // Identifier list to string.
  function identifierListToString($idList, $dbInfo, $format) {
    $this->printDebugMessage('identifierListToString', 'Begin', 2);
    $idListStr = '';
    if(is_array($idList)) {
      foreach($idList as $id) {
        $idListStr .= "<a href=\"?database=" . $dbInfo->name . "&id=$id&format=" . $format->name . "&style=default\">$id</a>, ";
      }
    }
    else {
      $id = $idList;
      $idListStr .= "<a href=\"?database=" . $dbInfo->name . "&id=$id&format=" . $format->name . "&style=default\">$id</a>, ";
    }
    $idListStr = trim($idListStr, ';, ');
    $idListStr .= "<br />\n";
    $this->printDebugMessage('identifierListToString', 'End', 2);
    return $idListStr;
  }

  // Output database details.
  function printDatabaseInfo() {
    $this->printDebugMessage('printDatabaseInfo', 'Begin', 1);
    $result = $this->soapGetDatabaseInfoList();
    foreach($result as $dbInfo) {
      print "<h3><a name=" . $dbInfo->name . ">" . $dbInfo->displayName . " (<i>" . $dbInfo->name . "</i>)</a></h3>\n";
      print "<p><a href=" . $dbInfo->href . ">" . $dbInfo->href . "</a></p>\n";
      print "<p>" . $dbInfo->description . "</p>\n";
      print "<pre>\n";
      #print_r($dbInfo);
      print "</pre>\n";
      print "<table border=1>\n";
      print "<tr><th>Format</th><th>Styles</th><th>Examples</th></tr>\n";
      foreach($dbInfo->formatInfoList->formatInfo as $format) {
        $styleStr = '';
        foreach($format->styleInfoList->styleInfo as $style) {
          if(is_object($style)) { 
            if($styleStr != '') {
              $styleStr = $styleStr . ', ';
            }
            $styleStr = $styleStr . $style->name;
          }
        }
        $exampleStr = '';
        if(isset($dbInfo->exampleIdentifiers)) {
          // Identifiers
          if(isset($dbInfo->exampleIdentifiers->idList->id)) {
            $exampleStr .= 'Id: ';
            $exampleStr .= $this->identifierListToString($dbInfo->exampleIdentifiers->idList->id, $dbInfo, $format);
          }
          // Accessions
          if(isset($dbInfo->exampleIdentifiers->accessionList->accession)) {
            $exampleStr .= 'Accession: ';
            $exampleStr .= $this->identifierListToString($dbInfo->exampleIdentifiers->accessionList->accession, $dbInfo, $format);
          }
          // Names
          if(isset($dbInfo->exampleIdentifiers->nameList->name)) {
            $exampleStr .= 'Name: ';
            $exampleStr .= $this->identifierListToString($dbInfo->exampleIdentifiers->nameList->name, $dbInfo, $format);
          }
          // Entry versions
          if(isset($dbInfo->exampleIdentifiers->entryVersionList->entryVersion)) {
            $exampleStr .= 'Entry Version: ';
            $exampleStr .= $this->identifierListToString($dbInfo->exampleIdentifiers->entryVersionList->entryVersion, $dbInfo, $format);
          }
          // Sequence versions
          if(isset($dbInfo->exampleIdentifiers->sequenceVersionList->sequenceVersion)) {
            $exampleStr .= 'Sequence Version: ';
            $exampleStr .= $this->identifierListToString($dbInfo->exampleIdentifiers->sequenceVersionList->sequenceVersion, $dbInfo, $format);
          }
        }
        else {
          $exampleStr = '&nbsp;';
        }
        print "<tr><td>" . $format->name . "</td><td>$styleStr</td><td>$exampleStr</td></tr>\n";
      }
      print "</table\n";
      print "<hr >\n";
    }
    $this->printDebugMessage('printDatabaseInfo', 'End', 1);
  }
}
?>

<html>
<!-- $Id$ -->
<body>
<h1 align="center">WSDbfetch (document/literal SOAP)</h1>
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
    $inputParams = array();
    if(isset($_POST) && count($_POST) > 0) {
      $inputParams = $_POST;
    }
    elseif(isset($_GET) && count($_GET) > 0) {
      $inputParams = $_GET;
    }

    // Create an instance of the client.
    $client = new WSDbfetchWebClient();
    // HTTP proxy config.
    //$client->setHttpProxy($proxy_host, $proxy_port);

    // Debug
    if(array_key_exists('debug', $inputParams)) {
      $client->debugLevel = 2;
      print "<pre>\n";
      print_r($inputParams);
      print "</pre>\n";
    }

    // Database information.
    if(array_key_exists('info', $inputParams)) {
      $client->printDatabaseInfo();
    }
    // Data retrieval.
    elseif(array_key_exists('id', $inputParams)) {
      $client->printResult($inputParams);
    }
    // Submission form.
    else {
      $client->printForm();
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

</html>
