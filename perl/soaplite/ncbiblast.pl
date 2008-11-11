#!/usr/bin/env perl
# $Id$
# ======================================================================
# NCBI BLAST jDispatcher SOAP web service Perl client
#
# Requires SOAP::Lite. Tested with versions 0.60, 0.69 and 0.71.
#
# See:
# http://www.ebi.ac.uk/Tools/Webservices/tutorials/soaplite
# ======================================================================
# WSDL URL for service
#my $WSDL = 'http://wwwdev.ebi.ac.uk/Tools/jdispatcher/services/soap/ncbiblast?wsdl';
my $NAMESPACE = 'http://soap.webservice.jdispatcher.ebi.ac.uk/';
my $ENDPOINT  =
  'http://wwwdev.ebi.ac.uk/Tools/jdispatcher/services/soap/ncbiblast';

# Enable Perl warnings
use strict;
use warnings;

# Load libraries
use SOAP::Lite;
use Getopt::Long qw(:config no_ignore_case bundling);
use File::Basename;
use MIME::Base64;

use Data::Dumper;

# Set interval for checking status
my $checkInterval = 15;

# Output level
my $outputLevel = 1;

# Process command-line options
my $numOpts = scalar(@ARGV);
my (
	$sequence, $outfile, $outformat, $help,  $polljob, $status,
	$jobid,    $async,   $trace,     $quiet, $verbose
);
my %params = (
	'exp'   => 1.0,    # Default value
	'async' => '1',    # Use async mode and simulate sync mode in client
);
GetOptions(
	"program|p=s"   => \$params{'program'},      # blastp, blastn, blastx, etc.
	"database|D=s"  => \$params{'database'},     # Database to search
	"matrix|m=s"    => \$params{'matrix'},       # Scoring martix to use
	"exp|E=f"       => \$params{'exp'},          # E-value threshold
	"filter|f"      => \$params{'filter'},       # Low complexity filter
	"align|A=i"     => \$params{'numal'},        # Number of alignments
	"scores|s=i"    => \$params{'scores'},       # Number of scores
	"numal|n=i"     => \$params{'numal'},        # Number of alignments
	"dropoff|d=i"   => \$params{'dropoff'},      # Dropoff score
	"match|u=i"     => \$params{'match'},        # Match score
	"mismatch|v=i"  => \$params{'mismatch'},     # Mismatch score
	"opengap|o=i"   => \$params{'opengap'},      # Open gap penalty
	"extendgap|x=i" => \$params{'extendgap'},    # Gap extension penality
	"gapalign|g"    => \$params{'gapalign'},     # Optimise gap alignments
	"sequence=s"    => \$sequence,               # Query sequence file or DB:ID
	"outfile|O=s"   => \$outfile,                # Output file name
	"outformat=s"   => \$outformat,              # Output file type
	"help|h"        => \$help,                   # Usage help
	"async|a"       => \$async,                  # Asynchronous submission
	"polljob"       => \$polljob,                # Get results
	"status"        => \$status,                 # Get status
	"jobid|j=s"     => \$jobid,                  # JobId
	"email|S=s"     => \$params{'email'},        # E-mail address
	'quiet'         => \$quiet,                  # Decrease output level
	'verbose'       => \$verbose,                # Increase output level
	'trace'         => \$trace,                  # SOAP message debug

	#	'WSDL=s'        => \$WSDL,                   # Alternative WSDL
);
if ($verbose) { $outputLevel++ }
if ($quiet)   { $outputLevel-- }

# Get the script filename for use in usage messages
my $scriptName = basename( $0, () );

# Print usage and exit if requested
if ( $help || $numOpts == 0 ) {
	&usage();
	exit(0);
}

# If required enable SOAP message trace
if ($trace) {
	print STDERR "Tracing active\n";
	SOAP::Lite->import( +trace => 'debug' );
}

# Create the service interface, setting the fault handler to throw exceptions
my $soap = SOAP::Lite
	#->service($WSDL)
	->proxy($ENDPOINT,
	#proxy => ['http' => 'http://your.proxy.server/'], # HTTP proxy
	timeout => 6000,    # HTTP connection timeout
	)
	->uri($NAMESPACE)
  	->on_fault(
	sub {
		my $soap = shift;
		my $res  = shift;

		# Throw an exception for all faults
		if ( ref($res) eq '' ) {
			die($res);
		}
		else {
			die( $res->faultstring );
		}
		return new SOAP::SOM;
	}
  );

# Print usage if bad argument combination
if (   !( $polljob || $status )
	&& !( defined( $ARGV[0] ) || defined($sequence) ) )
{
	print STDERR 'Error: bad option combination', "\n";
	&usage();
	exit(1);
}

# Poll job and get results
elsif ( $polljob && defined($jobid) ) {
	if ( $outputLevel > 1 ) {
		print "Getting results for job $jobid\n";
	}
	&getResults($jobid);
}

# Job status
elsif ( $status && defined($jobid) ) {
	if ( $outputLevel > 0 ) {
		print STDERR "Getting status for job $jobid\n";
	}
	my $result = &getStatus($jobid);
	print "$result\n";
	if ( $result eq 'DONE' && $outputLevel > 0 ) {
		print STDERR "To get results: $scriptName --polljob --jobid $jobid\n";
	}
}

# Submit a job
else {
	my $content;
	if ( defined( $ARGV[0] ) ) {    # Bare option
		if ( -f $ARGV[0] || $ARGV[0] eq '-' ) {    # File
			$content = &read_file( $ARGV[0] );
		}
		else {                                     # DB:ID or sequence
			$content = $ARGV[0];
		}
	}
	if ($sequence) {                               # Via --sequence
		if ( -f $sequence || $sequence eq '-' ) {    # File
			$content = &read_file($sequence);
		}
		else {                                       # DB:ID or sequence
			$content = $sequence;
		}
	}
	$params{'sequence'} = $content;

	my $paramsData = SOAP::Data->name('params')->type( map => \%params );

	# For SOAP::Lite 0.60 and earlier parameters are passed directly
	if ( $SOAP::Lite::VERSION eq '0.60' || $SOAP::Lite::VERSION =~ /0\.[1-5]/ ) {
		$jobid = $soap->run(%params);
	}

	# For SOAP::Lite 0.69 and later parameter handling is different, so pass
	# undef's for templated params, and then pass the formatted args.
	else {
		$jobid = $soap->run( undef, undef, $paramsData );
	}

	if ( defined($async) ) {
		print STDOUT $jobid, "\n";
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

# Status check
sub getStatus($) {
	my $jobid  = shift;
	my $result =
	  $soap->getStatus( SOAP::Data->name('jobId')->type( string => $jobid ) );
	return $result;
}

# Client-side poll
sub clientPoll($) {
	my $jobid  = shift;
	my $result = 'PENDING';

	# Check status and wait if not finished
	#print STDERR "Checking status: $jobid\n";
	while ( $result eq 'RUNNING' || $result eq 'PENDING' ) {
		$result = &getStatus($jobid);
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
	unless ( defined($outfile) ) {
		$outfile = $jobid;
	}

	# Get list of data types
	my $resultTypesXml =
	  $soap->getResultTypes(
		SOAP::Data->name('jobId')->type( string => $jobid ) );
	my (@resultTypes) = $resultTypesXml->valueof('//resultTypes/type');

	# Get the data and write it to a file
	if ( defined($outformat) ) {    # Specified data type
		my $selResultType;
		foreach my $resultType (@resultTypes) {
			if ( $resultType eq $outformat ) {
				$selResultType = $resultType;
			}
		}
		if ( defined($selResultType) ) {
			my $res = $soap->getRawResultOutput( SOAP::Data->name('jobId')->type( string => $jobid ), SOAP::Data->name('type')->type( string => $selResultType ));
			my $result = decode_base64($res->valueof('//output'));
			if ( $outfile eq '-' ) {
				write_file( $outfile, $result );
			}
			else {
				write_file( $outfile . '.' . $selResultType, $result );
			}
		}
		else {
			die "Error: unknown result format \"$outformat\"";
		}
	}
	else {    # Data types available
		      # Write a file for each output type
		for my $resultType (@resultTypes) {
			if ( $outputLevel > 1 ) {
				print STDERR "Getting $resultType\n";
			}
			my $res = $soap->getRawResultOutput( SOAP::Data->name('jobId')->type( string => $jobid ), SOAP::Data->name('type')->type( string => $resultType ) );
			my $result = decode_base64($res->valueof('//output'));
			if ( $outfile eq '-' ) {
				write_file( $outfile, $result );
			}
			else {
				write_file( $outfile . '.' . $resultType, $result );
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
http://www.ebi.ac.uk/blastall/blastall_help_frame.html

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

[General]

  -h, --help       :      : prints this help text
  -a, --async      :      : forces to make an asynchronous query
  -S, --email	   : str  : e-mail address 
      --polljob    :      : Poll for the status of a job
  -j, --jobid      : str  : jobid that was returned when an asynchronous job 
                            was submitted.
  -O, --outfile    : str  : file name for results (default is jobid;
                            "-" for STDOUT)
      --outformat  : str  : result format to retrieve
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
