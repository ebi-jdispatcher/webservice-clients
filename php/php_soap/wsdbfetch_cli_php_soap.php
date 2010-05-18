<?php
# $Id$
# ======================================================================
# WSDbfetch document/literal SOAP service PHP command-line client using 
# PHP SOAP.
#
# Note: this is a command-line program, call using:
#  php wsdbfetch_cli_php_soap.php [options...]
#
# Tested with:
#   PHP 5.0.4 (CentOS 4)
#   PHP 5.1.6 (CentOS 5)
#   PHP 5.2.4 (Ubuntu 8.04 LTS)
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
      $options = array('trace' => $this->trace);
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
  
  // Get list of available databases.
  function soapGetSupportedDBs() {
    $this->printDebugMessage('soapGetSupportedDBs', 'Begin', 2);
    $this->serviceProxyConnect();
    $result = $this->srvProxy->getSupportedDBs();
    if($this->trace) $this->soapTrace();
    $this->printDebugMessage('soapGetSupportedDBs', 'End', 2);
    return $result->getSupportedDBsReturn;
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

  // Get list of available databases and formats.
  function soapGetSupportedFormats() {
    $this->printDebugMessage('soapGetSupportedFormats', 'Begin', 2);
    $this->serviceProxyConnect();
    $result = $this->srvProxy->getSupportedFormats();
    if($this->trace) $this->soapTrace();
    $this->printDebugMessage('soapGetSupportedFormats', 'End', 2);
    return $result->getSupportedFormatsReturn;
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

  // Get list of available databases and styles.
  function soapGetSupportedStyles() {
    $this->printDebugMessage('soapGetSupportedStyles', 'Begin', 2);
    $this->serviceProxyConnect();
    $result = $this->srvProxy->getSupportedStyles();
    if($this->trace) $this->soapTrace();
    $this->printDebugMessage('soapGetSupportedStyles', 'End', 2);
    return $result->getSupportedStylesReturn;
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

  // Get list of available formats for a database.
  function soapGetDbFormats($dbName) {
    $this->printDebugMessage('soapGetDbFormats', 'Begin', 2);
    $this->serviceProxyConnect();
    $result = $this->srvProxy->getDbFormats(array('db' => $dbName));
    if($this->trace) $this->soapTrace();
    $this->printDebugMessage('soapGetDbFormats', 'End', 2);
    return $result->getDbFormatsReturn;
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
  
  // Print list of available styles for a format of a database.
  function printGetFormatStyles($dbName, $formatName) {
    $this->printDebugMessage('printGetFormatStyles', 'Begin', 1);
    $result = $this->soapGetFormatStyles($dbName, $formatName);
    foreach($result as $item) {
      echo $item . "\n";
    }
    $this->printDebugMessage('printGetFormatStyles', 'End', 1);
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
  
  // Print an entry.
  function printFetchData($query, $formatName, $styleName) {
    $this->printDebugMessage('printFetchData', 'Begin', 1);
    $result = $this->soapFetchData($query, $formatName, $styleName);
    echo $result . "\n";
    $this->printDebugMessage('printFetchData', 'End', 1);
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
  $client = new WSDbfetchClient();
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
      
      // List databases
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
  $scriptName = 'wsdbfetch_cli_php_soap.php';
  print <<<EOF
Usage:
  wsdbfetch_cli_php_soap.php fetchData <dbName:ID> [format] [style]
  wsdbfetch_cli_php_soap.php fetchBatch <dbName> <idList> [format] [style]
  wsdbfetch_cli_php_soap.php getSupportedDBs | getSupportedFormats | getSupportedStyles
  wsdbfetch_cli_php_soap.php getDbFormats <dbName>
  wsdbfetch_cli_php_soap.php getFormatStyles <dbName> <formatName>

Further information:

  http://www.ebi.ac.uk/Tools/webservices/services/dbfetch
  http://www.ebi.ac.uk/Tools/webservices/tutorials/php

Support/Feedback:

  http://www.ebi.ac.uk/support/

EOF;
}
?>
