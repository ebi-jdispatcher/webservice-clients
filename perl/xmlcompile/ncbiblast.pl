#!/usr/bin/env perl
# ======================================================================
# Example jDispatcher NCBI BLAST client using XML::Compile::SOAP
#
# See:
# http://www.ebi.ac.uk/Tools/webservices/services/ncbiblast
# http://www.ebi.ac.uk/Tools/webservices/tutorials/perl
# ======================================================================
# Service WSDL
my $WSDL = 'http://wwwdev.ebi.ac.uk/Tools/jdispatcher/services/soap/ncbiblast?wsdl';

# Enable Perl warnings
use strict;
use warnings;

# XML::Compile::SOAP modules
use XML::Compile;
use XML::Compile::WSDL11;
use XML::Compile::Transport::SOAPHTTP;
use MIME::Base64;

# Comand-line parser
use Getopt::Long qw(:config no_ignore_case bundling);

# File name manipulation
use File::Basename qw(basename);

# Dump a Perl data structure to a string
use Data::Dumper;

# Output level
my $outputLevel = 1;

# Process command-line options
my $numOpts = scalar(@ARGV);
my ( $help, $traceFlag, $quiet, $verbose );    # General
my ($getParameters, $getParameterDetails, $parameterId);  # Specific
my (%runParams) = ();
my (%inputParams) = (
	'matrix' => 'BLOSUM62',
	'numal' => 50,
	'scores' => 50,
	'exp' => '10',
	#'match_scores' => '-1,-1',
	'opengap' => -1,
	'extendgap' => -1,
	'filter' => 'F',
	'seqrange' => 'START-END',
);
GetOptions(
	'help|h'      => \$help,                   # Usage info
	'quiet'       => \$quiet,                  # Decrease output level
	'verbose'     => \$verbose,                # Increase output level
	'trace'       => \$traceFlag,              # Show SOAP messages
	'getParameters' => \$getParameters,            # Get parameter names
	'getParameterDetails' => \$getParameterDetails,            # Get parameter information
	'parameterId=s' => \$parameterId, # Parameter name
	# Run parameters
	'email=s' => \$runParams{'email'},
	'title=s' => \$runParams{'title'},
	# Input parameters
	'program=s' => \$inputParams{'program'},
	'matrix=s' => \$inputParams{'matrix'},
    'numal=i' => \$inputParams{'numal'},
    'scores=i' => \$inputParams{'scores'},
    'exp=s' => \$inputParams{'exp'},
	'dropoff=i' => \$inputParams{'dropoff'},
	'match_scores=s' => \$inputParams{'match_scores'},
	'opengap=i' => \$inputParams{'opengap'},
	'extendgap=i' => \$inputParams{'extendgap'},
	'filter=s' => \$inputParams{'filter'},
	'seqrange=s' => \$inputParams{'seqrange'},
	'gapalign' => \$inputParams{'gapalign'},
	'align=i' => \$inputParams{'align'},
	'format' => \$inputParams{'format'},
	'sequence=s' => \$inputParams{'sequence'},
	'database=s' => \$inputParams{'database'},
);
if ($verbose) { $outputLevel++ }
if ($quiet)   { $outputLevel-- }

# Get the script filename for use in usage messages
my $scriptName = basename($0);

# Print usage and exit if requested
if ( $help || $numOpts == 0 ) {
	&usage();
	exit(0);
}

# Create service proxy for web service
my $wsdlXml = XML::LibXML->new->parse_file($WSDL);
my $soapSrv = XML::Compile::WSDL11->new($wsdlXml);

# Compile service methods
my (%soapOps);
foreach my $soapOp ( $soapSrv->operations ) {
	$soapOps{ $soapOp->{operation} } =
	  $soapSrv->compileClient( $soapOp->{operation} );
}

# getParameters(toolName)
if ($getParameters) {
	my $response = &soapRequest( 'getParameters', {'tool' => 'ncbiblast'} );
	foreach my $param (@{$response->{'output'}->{'parameters'}->{'id'}}) {
		print $param, "\n";
	}
}

# getParameterDetails(toolName, parameterId)
if ($getParameterDetails) {
	my $response = &soapRequest( 'getParameterDetails',
		 {
		 	'tool' => 'ncbiblast',
		 	'parameterId' => $parameterId
		 } );
	print Dumper($response->{'output'}->{'parameterDetails'});
}

# getRawResultOutput()
# getResultTypes()
# getStatus()
# run()
if($runParams{'email'} ne '' && $inputParams{'program'} ne '' && $inputParams{'database'} ne '') {
	# Clean input params
	foreach my $key (keys(%inputParams)) {
		if(!$inputParams{$key}) {
			delete $inputParams{$key};
		}
	}
	print Dumper(%inputParams);
	$runParams{'parameters'} = \%inputParams;
	my $response = &soapRequest( 'run', \%runParams);
	print Dumper($response);
}

# Wrapper for SOAP requests
sub soapRequest($$) {
	my $serviceMethod = shift;    # Method name
	my $serviceParams = shift;    # Method parameters

	# Call the method
	my ( $response, $trace ) =
	  $soapOps{$serviceMethod}->( 'parameters' => $serviceParams );
	if ($traceFlag) { &printTrace($trace); }    # SOAP message trace
	if ( $response->{'Fault'} ) {               # Check for server/SOAP fault
		die "Server fault: " . $response->{'Fault'}->{'faultstring'};
	}
	return $response;
}

# Print request/response trace
sub printTrace($) {
	my $trace = shift;
	$trace->printTimings;
	$trace->printRequest;
	$trace->printResponse;
}

# Print program usage
sub usage {
	print STDERR <<EOF
NCBI BLAST
==========

[Examples]

  $scriptName --getParameters
  $scriptName --getParameterDetails -parameterId <paramName>
  $scriptName --email <your\@email> --program <prog> --database <db> --sequence <seqFile>

EOF
;
}

