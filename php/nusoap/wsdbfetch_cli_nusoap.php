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
# PHP WSDbfetch document/literal SOAP service command-line client.
#
# Uses nuSOAP (http://sourceforge.net/projects/nusoap/)
#
# Note: this is a command-line program, call using:
#  php wsdbfetch_cli_nusoap.php [options...]
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
# Load WSDbfetch client library
require_once('wsdbfetch_lib_nusoap.php');

class WSDbfetchCliClient extends WSDbfetchClient {
  // Print database information.
  function printGetDatabaseInfo($dbName) {
    $this->printDebugMessage('printGetDatabaseInfo', 'Begin', 1);
    $result = $this->soapGetDatabaseInfo($dbName);
    print_r($result);
    $this->printDebugMessage('printGetDatabaseInfo', 'End', 1);
  }

  // Print database information for all databases.
  function printGetDatabaseInfoList() {
    $this->printDebugMessage('printGetDatabaseInfoList', 'Begin', 1);
    $result = $this->soapGetDatabaseInfoList();
    print_r($result);
    $this->printDebugMessage('printGetDatabaseInfoList', 'End', 1);
  }

  // Print list of available databases.
  function printGetSupportedDBs() {
    $this->printDebugMessage('printGetSupportedDBs', 'Begin', 1);
    $result = $this->soapGetSupportedDBs();
    foreach($result as $item) {
      echo $item . "\n";
    }
    $this->printDebugMessage('printGetSupportedDBs', 'End', 1);
  }

  // Print list of available databases and formats.
  function printGetSupportedFormats() {
    $this->printDebugMessage('printGetSupportedFormats', 'Begin', 1);
    $result = $this->soapGetSupportedFormats();
    foreach($result as $item) {
      echo $item . "\n";
    }
    $this->printDebugMessage('printGetSupportedFormats', 'End', 1);
  }
  
  // Print list of available databases and styles.
  function printGetSupportedStyles() {
    $this->printDebugMessage('printGetSupportedStyles', 'Begin', 1);
    $result = $this->soapGetSupportedStyles();
    foreach($result as $item) {
      echo $item . "\n";
    }
    $this->printDebugMessage('printGetSupportedStyles', 'End', 1);
  }

  // Print list of available formats for a database.
  function printGetDbFormats($dbName) {
    $this->printDebugMessage('printGetDbFormats', 'Begin', 1);
    $result = $this->soapGetDbFormats($dbName);
    foreach($result as $item) {
      echo $item . "\n";
    }
    $this->printDebugMessage('printGetDbFormats', 'End', 1);
  }

  // Print list of available styles for a format of a database.
  function printGetFormatStyles($dbName, $formatName) {
    $this->printDebugMessage('printGetFormatStyles', 'Begin', 1);
    $result = $this->soapGetFormatStyles($dbName, $formatName);
    foreach($result as $item) {
      echo $item . "\n";
    }
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
}

try {
  // Parse command-line options
  $options = parseCommandLine($argv);

  // For no options or explict help request
  if($argc == 1 || strcmp($options['action'], 'help') == 0) {
    printUsage();
    exit(0);
  }

  // Get service proxy
  $client = new WSDbfetchCliClient();
  // HTTP proxy config.
  //$client->setHttpProxy($proxy_host, $proxy_port);

  // Debug options
  if(array_key_exists('trace', $options)) $client->trace = 1;
  if(array_key_exists('debugLevel', $options)) {
    $client->debugLevel = $options['debugLevel'];
  }
  if(array_key_exists('WSDL', $options)) {
    $client->setWsdlUrl($options['WSDL']);
  }

  // Perform requested action
  switch($options['action']) {
  case 'getDatabaseInfo':
    if(array_key_exists('dbName', $options)) {
      $client->printGetDatabaseInfo($options['dbName']);
    }
    else {
      echo "Error: a database must be specified\n";
      printUsage();
    }
    break;
  case 'getDatabaseInfoList':
    $client->printGetDatabaseInfoList();
    break;
  case 'getSupportedDBs':
    $client->printGetSupportedDBs();
    break;
  case 'getSupportedFormats':
    $client->printGetSupportedFormats();
    break;
  case 'getSupportedStyles':
    $client->printGetSupportedStyles();
    break;
  case 'getDbFormats':
    if(array_key_exists('dbName', $options)) {
      $client->printGetDbFormats($options['dbName']);
    }
    else {
      echo "Error: a database must be specified\n";
      printUsage();
    }
    break;
  case 'getFormatStyles':
    if(array_key_exists('dbName', $options) && array_key_exists('formatName', $options)) {
      $client->printGetFormatStyles($options['dbName'], $options['formatName']);
    }
    else {
      echo "Error: a database and format must be specified\n";
      printUsage();
    }
    break;
  case 'fetchData':
    if(array_key_exists('query', $options)) {
      if(!array_key_exists('formatName', $options)) $options['formatName'] = 'default';
      if(!array_key_exists('styleName', $options)) $options['styleName'] = 'default';
      $client->printFetchData($options['query'], $options['formatName'], $options['styleName']);
    }
    else {
      echo "Error: an entry ID must be specified\n";
      printUsage();
    }
    break;
  case 'fetchBatch':
    if(array_key_exists('dbName', $options) && array_key_exists('idListStr', $options)) {
      if(!array_key_exists('formatName', $options)) $options['formatName'] = 'default';
      if(!array_key_exists('styleName', $options)) $options['styleName'] = 'default';
      $client->printFetchBatch($options['dbName'], $options['idListStr'], $options['formatName'], $options['styleName']);
    }
    else {
      echo "Error: an database and entry ID must be specified\n";
      printUsage();
    }
    break;
  default:
    // Unknown arguments, just show usage
    printUsage();
    break;
  }
}
// Catch SoapFault exceptions, and report the message.
catch(SoapFault $ex) {
  echo 'Error: ';
  if($ex->getMessage() != '') echo $ex->getMessage();
  else echo $ex;
  echo "\n";
}

// Parse command-line options
function parseCommandLine($argList) {
  $options = array(
		   'action' => 'unknown',
		   );
  for($i=0; $i<count($argList); $i++) {
    $arg = $argList[$i];
    switch($arg) {
      // Help/usage
    case '-h':
    case '--help':
      $options['action'] = 'help';
      break;
      // SOAP message trace
    case '--trace':
      $options['trace'] = 1;
      break;
      // Debug output
    case '--debugLevel':
      $i++;
      if(array_key_exists($i, $argList)) $options['debugLevel'] = $argList[$i];
      break;
      // Service WSDL location
    case '--WSDL':
      $i++;
      if(array_key_exists($i, $argList)) $options['WSDL'] = $argList[$i];
      break;
      
      // Database information.
    case 'getDatabaseInfo':
      $i++;
      if(array_key_exists($i, $argList)) $options['dbName'] =  $argList[$i];
      $options['action'] = 'getDatabaseInfo';
      break;
      // List database information.
    case 'getDatabaseInfoList':
      $options['action'] = 'getDatabaseInfoList';
      break;
      // List database names
    case 'getSupportedDBs':
      $options['action'] = 'getSupportedDBs';
      break;
      // List databases and formats
    case 'getSupportedFormats':
      $options['action'] = 'getSupportedFormats';
      break;
      // List databases and styles.
    case 'getSupportedStyles':
      $options['action'] = 'getSupportedStyles';
      break;
      // Formats for a database. 
    case 'getDbFormats':
      $i++;
      if(array_key_exists($i, $argList)) $options['dbName'] =  $argList[$i];
      $options['action'] = 'getDbFormats';
      break;
      // Styles for a formats of a database. 
    case 'getFormatStyles':
      $i++;
      if(array_key_exists($i, $argList)) $options['dbName'] =  $argList[$i];
      $i++;
      if(array_key_exists($i, $argList)) $options['formatName'] =  $argList[$i];
      $options['action'] = 'getFormatStyles';
      break;
      // Get an entry. 
    case 'fetchData':
      $i++;
      if(array_key_exists($i, $argList)) $options['query'] =  $argList[$i];
      $i++;
      if(array_key_exists($i, $argList)) $options['formatName'] =  $argList[$i];
      $i++;
      if(array_key_exists($i, $argList)) $options['styleName'] =  $argList[$i];
      $options['action'] = 'fetchData';
      break;
      // Get a set of entries.
    case 'fetchBatch':
      $i++;
      if(array_key_exists($i, $argList)) $options['dbName'] =  $argList[$i];
      $i++;
      if(array_key_exists($i, $argList)) $options['idListStr'] =  $argList[$i];
      $i++;
      if(array_key_exists($i, $argList)) $options['formatName'] =  $argList[$i];
      $i++;
      if(array_key_exists($i, $argList)) $options['styleName'] =  $argList[$i];
      $options['action'] = 'fetchBatch';
      break;
    }
  }
  return $options;
}

// Print usage message
function printUsage() {
  $scriptName = 'wsdbfetch_cli_nusoap.php';
  print <<<EOF
Usage:
  wsdbfetch_cli_nusoap.php fetchData <dbName:ID> [format] [style]
  wsdbfetch_cli_nusoap.php fetchBatch <dbName> <idList> [format] [style]
  wsdbfetch_cli_nusoap.php getSupportedDBs | getSupportedFormats | getSupportedStyles
  wsdbfetch_cli_nusoap.php getDbFormats <dbName>
  wsdbfetch_cli_nusoap.php getFormatStyles <dbName> <formatName>

Further information:

  http://www.ebi.ac.uk/Tools/webservices/services/dbfetch
  http://www.ebi.ac.uk/Tools/webservices/tutorials/php

Support/Feedback:

  http://www.ebi.ac.uk/support/

EOF;
}
?>
