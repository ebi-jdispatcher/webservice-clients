#!/usr/bin/env perl
# $Id$
# ======================================================================
# NCBI BLAST jDispatcher Perl client using XML::Compile::SOAP
#
# See:
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

# Command-line parser
use Getopt::Long qw(:config no_ignore_case bundling);

# File name manipulation
use File::Basename qw(basename);

# Dump a Perl data structure to a string
use Data::Dumper;

# Set interval for checking status
my $checkInterval = 5;

# Output level
my $outputLevel = 1;

# Process command-line options
my $numOpts = scalar(@ARGV);
my %params = ('title' => 'Sequence');
my %tool_params = (
	'match_scores' => 'NIL',
	'gapalign' => 0,
	'format' => 0,
	'seqrange' => 'NIL',
	'align' => 'NIL',
);
GetOptions(
	# Tool specific options
	"program|p=s"   => \$tool_params{'program'},      # blastp, blastn, blastx, etc.
	"database|D=s"  => \$tool_params{'database'},     # Database to search
	"matrix|m=s"    => \$tool_params{'matrix'},       # Scoring martix to use
	"exp|E=f"       => \$tool_params{'exp'},          # E-value threshold
	"filter|f"      => \$tool_params{'filter'},       # Low complexity filter
	"align|A=i"     => \$tool_params{'numal'},        # Number of alignments
	"scores|s=i"    => \$tool_params{'scores'},       # Number of scores
	"numal|n=i"     => \$tool_params{'numal'},        # Number of alignments
	"dropoff|d=i"   => \$tool_params{'dropoff'},      # Dropoff score
	"match_score=s" => \$tool_params{'match_scores'},  # Match/missmatch scores
	"match|u=i"     => \$params{'match'},             # Match score
	"mismatch|v=i"  => \$params{'mismatch'},          # Mismatch score
	"opengap|o=i"   => \$tool_params{'opengap'},      # Open gap penalty
	"extendgap|x=i" => \$tool_params{'extendgap'},    # Gap extension penality
	"gapalign|g"    => \$tool_params{'gapalign'},     # Optimise gap alignments
	"sequence=s"    => \$params{'sequence'},          # Query sequence file or DB:ID
	# Generic options
	'email=s'       => \$params{'email'},             # User e-mail address
	'title=s'       => \$params{'title'},             # Job title
	'outfile=s'     => \$params{'outfile'},           # Output file name
	'outformat=s'   => \$params{'outformat'},         # Output file type
	'jobid=s'       => \$params{'jobid'},             # JobId
	'help|h'        => \$params{'help'},              # Usage help
	'async'         => \$params{'async'},             # Asynchronous submission
	'polljob'       => \$params{'polljob'},           # Get results
	'status'        => \$params{'status'},            # Get status
	'params'        => \$params{'params'},            # List input parameters
	'paramDetail=s' => \$params{'paramDetail'},       # Get details for parameter
	'quiet'         => \$params{'quiet'},             # Decrease output level
	'verbose'       => \$params{'verbose'},           # Increase output level
	'trace'         => \$params{'trace'},             # SOAP message debug
);
if ($params{'verbose'}) { $outputLevel++ }
if ($params{'quiet'})   { $outputLevel-- }

# Get the script filename for use in usage messages
my $scriptName = basename($0);

# Print usage and exit if requested
if ( $params{'help'} || $numOpts == 0 ) {
	&usage();
	exit(0);
}

# Create service proxy for web service
my $wsdlXml = XML::LibXML->new->parse_file($WSDL);
my $soapSrv = XML::Compile::WSDL11->new($wsdlXml);

# Compile service methods
my (%soapOps);
foreach my $soapOp ( $soapSrv->operations ) {
	# Allow nil elements to be skipped (needed for submission)
	$soapOps{ $soapOp->{operation} } =
	  $soapSrv->compileClient( $soapOp->{operation}, interpret_nillable_as_optional=>1 );
}

# Print usage if bad argument combination
if (   !( $params{'polljob'} || $params{'status'} || $params{'params'} || $params{'paramDetail'} )
	&& !( defined( $ARGV[0] ) || defined($params{'sequence'}) ) )
{
	print STDERR 'Error: bad option combination', "\n";
	&usage();
	exit(1);
}

# Get parameters list
elsif ( $params{'params'} ) {
	my (@paramList) = &soap_get_parameters('ncbiblast');
	foreach my $param (@paramList) {
		print $param, "\n";
	}
}

# Get parameters list
elsif ( $params{'paramDetail'} ) {
	my $paramDetail = &soap_get_parameter_details('ncbiblast', $params{'paramDetail'});
	print Dumper($paramDetail);
}

# Poll job and get results
elsif ( $params{'polljob'} && defined($params{'jobid'}) ) {
	if ( $outputLevel > 1 ) {
		print 'Getting results for job ', $params{'jobid'}, "\n";
	}
	&getResults($params{'jobid'});
}

# Job status
elsif ( $params{'status'} && defined($params{'jobid'}) ) {
	if ( $outputLevel > 0 ) {
		print STDERR 'Getting status for job ', $params{'jobid'}, "\n";
	}
	my $result = &soap_get_status($params{'jobid'});
	print "$result\n";
	if ( $result eq 'DONE' && $outputLevel > 0 ) {
		print STDERR "To get results: $scriptName --polljob --jobid " . $params{'jobid'} . "\n";
	}
}

# Submit a job
else {
	if ( defined( $ARGV[0] ) ) {    # Bare option
		if ( -f $ARGV[0] || $ARGV[0] eq '-' ) {    # File
			$tool_params{'sequence'} = &read_file( $ARGV[0] );
		}
		else {                                     # DB:ID or sequence
			$tool_params{'sequence'} = $ARGV[0];
		}
	}
	if ($params{'sequence'}) {                               # Via --sequence
		if ( -f $params{'sequence'} || $params{'sequence'} eq '-' ) {    # File
			$tool_params{'sequence'} = &read_file($params{'sequence'});
		}
		else {                                       # DB:ID or sequence
			$tool_params{'sequence'} = $params{'sequence'};
		}
	}

	my $jobid = &soap_run($params{'email'}, $params{'title'}, \%tool_params);

	if ( defined($params{'async'}) ) {
		print STDOUT $params{'jobid'}, "\n";
		if ( $outputLevel > 0 ) {
			print STDERR
			  "To check status: $scriptName --status --jobid $jobid\n";
		}
	}
	else {    # Synchronous mode
		if ( $outputLevel > 0 ) {
			print STDERR "JobId: $jobid\n";
		}
		sleep 1;
		&getResults($jobid);
	}
}

# Submit job
sub soap_run($$$) {
	my $email = shift;
	my $title = shift;
	my $paramsRef = shift;
	my %params = %{$paramsRef};
	# Set NIL for empty elements.
	foreach my $paramName (keys(%params)) {
		if(!defined($params{$paramName})) {
			$params{$paramName} = 'NIL';
		}
	}
	my $response = &soapRequest('run',
		{
			'email' => $email,
			'title' => $title,
			'parameters' => \%params
		}
	);
	return $response->{'output'}->{'jobId'};
}

# Get job status
sub soap_get_status($) {
	my $jobid = shift;
	my $response = &soapRequest('getStatus', {'jobId' => $jobid});
	return $response->{'output'}->{'status'};
}

# Get result types for job
sub soap_get_result_types($) {
	my $jobid = shift;
	my $response = &soapRequest('getResultTypes', {'jobId' => $jobid});
	return @{$response->{'output'}->{'resultTypes'}->{'type'}};
}

# Get result for job
sub soap_get_raw_result_output($$) {
	my $jobid = shift;
	my $type = shift;
	my $response = &soapRequest('getResult', 
		{
			'jobId' => $jobid,
			'type' => $type
		}
	);
	return $response->{'output'}->{'output'};
}

# Get input parameters
sub soap_get_parameters($) {
	my $tool = shift;
	my $response = &soapRequest( 'getParameters', {'tool' => $tool} );
	return @{$response->{'output'}->{'parameters'}->{'id'}};
}

# Get input parameter details
sub soap_get_parameter_details($$) {
	my $tool = shift;
	my $paramName = shift;
	my $response = &soapRequest( 'getParameterDetails',
		 {
		 	'tool' => $tool,
		 	'parameterId' => $paramName
		 } );
	return $response->{'output'}->{'parameterDetails'};
}

# Generic wrapper for SOAP requests
sub soapRequest($$) {
	my $serviceMethod = shift;    # Method name
	my $serviceParams = shift;    # Method parameters

	# Call the method
	my ( $response, $trace ) =
	  $soapOps{$serviceMethod}->( 'parameters' => $serviceParams );
	if ($params{'trace'}) { &printTrace($trace); }    # SOAP message trace
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

# Client-side job polling
sub clientPoll($) {
	my $jobid  = shift;
	my $result = 'PENDING';

	# Check status and wait if not finished
	#print STDERR "Checking status: $jobid\n";
	while ( $result eq 'RUNNING' || $result eq 'PENDING' ) {
		$result = soap_get_status($jobid);
		if ( $outputLevel > 0 ) {
			print STDERR "$result\n";
		}
		if ( $result eq 'RUNNING' || $result eq 'PENDING' ) {

			# Wait before polling again.
			sleep $checkInterval;
		}
	}
}

# Get the results for a jobid
sub getResults($) {
	my $jobid = shift;

	# Check status, and wait if not finished
	clientPoll($jobid);

	# Use JobId if output file name is not defined
	unless ( defined($params{'outfile'}) ) {
		$params{'outfile'} = $jobid;
	}

	# Get list of data types
	my (@resultTypes) = soap_get_result_types($jobid);

	# Get the data and write it to a file
	if ( defined($params{'outformat'}) ) {    # Specified data type
		my $selResultType;
		foreach my $resultType (@resultTypes) {
			if ( $resultType eq $params{'outformat'} ) {
				$selResultType = $resultType;
			}
		}
		if ( defined($selResultType) ) {
			my $result = soap_get_raw_result_output($jobid, $selResultType);
			if ( $params{'outfile'} eq '-' ) {
				write_file( $params{'outfile'}, $result );
			}
			else {
				write_file( $params{'outfile'} . '.' . $selResultType, $result );
			}
		}
		else {
			die 'Error: unknown result format "' . $params{'outformat'} . '"';
		}
	}
	else {    # Data types available
		      # Write a file for each output type
		for my $resultType (@resultTypes) {
			if ( $outputLevel > 1 ) {
				print STDERR "Getting $resultType\n";
			}
			my $result = soap_get_raw_result_output($jobid, $resultType);
			if ( $params{'outfile'} eq '-' ) {
				write_file( $params{'outfile'}, $result );
			}
			else {
				write_file( $params{'outfile'} . '.' . $resultType, $result );
			}
		}
	}
}

# Read a file
sub read_file($) {
	my $filename = shift;
	my ( $content, $buffer );
	if ( $filename eq '-' ) {
		while ( sysread( STDIN, $buffer, 1024 ) ) {
			$content .= $buffer;
		}
	}
	else {    # File
		open( FILE, $filename )
		  or die "Error: unable to open input file $filename ($!)";
		while ( sysread( FILE, $buffer, 1024 ) ) {
			$content .= $buffer;
		}
		close(FILE);
	}
	return $content;
}

# Write a result file
sub write_file($$) {
	my ( $filename, $data ) = @_;
	if ( $outputLevel > 0 ) {
		print STDERR 'Creating result file: ' . $filename . "\n";
	}
	if ( $filename eq '-' ) {
		print STDOUT $data;
	}
	else {
		open( FILE, ">$filename" )
		  or die "Error: unable to open output file $filename ($!)";
		syswrite( FILE, $data );
		close(FILE);
	}
}

# Print program usage
sub usage {
	print STDERR <<EOF
NCBI BLAST
==========
   
Rapid sequence database search programs utilizing the BLAST algorithm
    
For more detailed help information refer to 
http://www.ebi.ac.uk/Tools/blastall/help.html

[Required]

  -p, --program	   : str  : BLAST program to use: blastn, blastp, blastx, 
                            tblastn or tblastx
  -D, --database   : str  : database to search
  seqFile          : file : query sequence ("-" for STDIN)

[Optional]

  -m, --matrix     : str  : scoring matrix
  -e, --exp        : real : 0<E<= 1000. Statistical significance threshold 
                            for reporting database sequence matches.
  -f, --filter	   :      : display the filtered query sequence in the output
  -A, --align	   : int  : number of alignments to be reported
  -s, --scores	   : int  : number of scores to be reported
  -n, --numal	   : int  : Number of alignments
  -u, --match      : int  : Match score
  -v, --mismatch   : int  : Mismatch score
  -o, --opengap	   : int  : Gap open penalty
  -x, --extendgap  : int  : Gap extension penalty
  -d, --dropoff	   : int  : Drop-off
  -g, --gapalign   :      : Optimise gapped alignments
      --seqrange   : str  : region within input to use as query
      --format     :      : Return NCBI BLAST XML format

[General]

  -h, --help       :      : prints this help text
      --async      :      : forces to make an asynchronous query
      --email	   : str  : e-mail address
      --title      : str  : title for job
      --polljob    :      : Poll for the status of a job
      --jobid      : str  : jobid that was returned when an asynchronous job 
                            was submitted.
      --outfile    : str  : file name for results (default is jobid;
                            "-" for STDOUT)
      --outformat  : str  : result format to retrieve
      --params     :      : list input parameters
      --paramDetail: str  : display details for input parameter
      --quiet      :      : decrease output
      --verbose    :      : increase output
      --trace	   :      : show SOAP messages being interchanged 
   
Synchronous job:

  The results/errors are returned as soon as the job is finished.
  Usage: $scriptName --email <your\@email> [options...] seqFile
  Returns: results as an attachment

Asynchronous job:

  Use this if you want to retrieve the results at a later time. The results 
  are stored for up to 24 hours. 	
  Usage: $scriptName --async --email <your\@email> [options...] seqFile
  Returns: jobid

  Use the jobid to query for the status of the job. If the job is finished, 
  it also returns the results/errors.
  Usage: $scriptName --polljob --jobid <jobId> [--outfile string]
  Returns: string indicating the status of the job and if applicable, results 
  as an attachment.

EOF
}
