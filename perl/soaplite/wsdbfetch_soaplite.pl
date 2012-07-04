#!/usr/bin/env perl

=head1 NAME

dbfetch_soaplite.pl

=head1 DESCRIPTION

WSDbfetch document/literal SOAP web service Perl client using L<SOAP::Lite>.

Tested with:

=over

=item *
L<SOAP::Lite> 0.60 and Perl 5.8.3

=item *
L<SOAP::Lite> 0.69 and Perl 5.8.8 (Ubuntu 8.04 LTS)

=item *
L<SOAP::Lite> 0.710.10 and Perl 5.10.1 (Ubuntu 10.04 LTS)

=item *
L<SOAP::Lite> 0.711 and Perl 5.10.1 (Cygwin 1.7.2; MS Windows 7)

=back

For further information see:

=over

=item *
L<http://www.ebi.ac.uk/Tools/webservices/services/dbfetch>

=item *
L<http://www.ebi.ac.uk/Tools/webservices/tutorials/perl>

=back

=head1 VERSION

$Id$

=cut

# ======================================================================
# Enable Perl warnings
use strict;
use warnings;

# Load libraries
use English;
use SOAP::Lite;
use LWP::Simple;
use Getopt::Long qw(:config no_ignore_case bundling);
use File::Basename;
use Data::Dumper;

# Maximum connection retries.
use constant MAX_RETRIES => 3;

# WSDL URL for service
my $WSDL = 'http://www.ebi.ac.uk/ws/services/WSDbfetchDoclit?wsdl';

# Output level
my $outputLevel = 1;

# Process command-line options
my %params = ( 'debugLevel' => 0 );

# Command-line options
my $trace;
GetOptions(
	'quiet'         => \$params{'quiet'},          # Decrease output level
	'verbose'       => \$params{'verbose'},        # Increase output level
	'debugLevel=i'  => \$params{'debugLevel'},     # Debug output level
	'trace'         => \$params{'trace'},          # SOAP message debug
	'endpoint=s'    => \$params{'endpoint'},       # SOAP service endpoint
	'namespace=s'   => \$params{'namespace'},      # SOAP service namespace
	'WSDL=s'        => \$WSDL,                     # SOAP service WSDL
);
if ( $params{'verbose'} ) { $outputLevel++ }
if ( $params{'quiet'} )  { $outputLevel-- }
my $numOpts = scalar(@ARGV);

# Get the script filename for use in usage messages
my $scriptName = basename( $0, () );

# Derive a user-agent string for the client.
'$Revision$' =~ m/(\d+)/;
my $client_agent = "EBI-Sample-Client/$1 ($scriptName; $OSNAME) ";

# Debug mode: SOAP::Lite version
&print_debug_message( 'MAIN', 'SOAP::Lite::VERSION: ' . $SOAP::Lite::VERSION,
	1 );

# Debug mode: print the input parameters
&print_debug_message( 'MAIN', "params:\n" . Dumper( \%params ),           11 );

# Print usage and exit if requested
if ( $params{'help'} || $numOpts == 0 ) {
	&usage();
	exit(0);
}

# If required enable SOAP message trace
if ( $params{'trace'} ) {
	print STDERR "Tracing active\n";
	SOAP::Lite->import( +trace => 'debug' );
}

# Debug mode: show the WSDL, service endpoint and namespace being used.
&print_debug_message( 'MAIN', 'WSDL: ' . $WSDL, 1 );

# For a document/literal service which has types with repeating elements
# namespace and endpoint need to be used instead of the WSDL. By default
# these are extracted from the WSDL.
my ( $serviceEndpoint, $serviceNamespace ) = &from_wsdl($WSDL);

# User specified endpoint and namespace
$serviceEndpoint  = $params{'endpoint'}  if ( $params{'endpoint'} );
$serviceNamespace = $params{'namespace'} if ( $params{'namespace'} );

# Debug mode: show the WSDL, service endpoint and namespace being used.
&print_debug_message( 'MAIN', 'endpoint: ' . $serviceEndpoint,   11 );
&print_debug_message( 'MAIN', 'namespace: ' . $serviceNamespace, 11 );


# Create the service interface, setting the fault handler to throw exceptions
my $soap = SOAP::Lite->proxy(
	$serviceEndpoint,
	timeout => 6000,    # HTTP connection timeout.
	#proxy => ['http' => 'http://your.proxy.server/'], # HTTP proxy.
	options => {
		# HTTP compression (requires Compress::Zlib)
		compress_threshold => 100000000, # Large to prevent request compression.
	},
  )->uri($serviceNamespace)->on_fault(

	# Map SOAP faults to Perl exceptions (i.e. die).
	sub {
		my $soap = shift;
		my $res  = shift;
		if ( ref($res) eq '' ) {
			die($res);
		}
		else {
			die( $res->faultstring );
		}
		return new SOAP::SOM;
	}
  );
# Modify the user-agent to add a more specific prefix (see RFC2616 section 14.43)
$soap->transport->agent($client_agent . $soap->transport->agent());
&print_debug_message( 'MAIN', 'user-agent: ' . $soap->transport->agent(), 11 );

# Process command-line and perfom action
# List supported databases
if ( $ARGV[0] eq 'getSupportedDBs' ) {
	&print_supported_dbs();
}

# List supported databases and formats
elsif ( $ARGV[0] eq 'getSupportedFormats' ) {
	&print_supported_formats();
}

# List supported databases and styles
elsif ( $ARGV[0] eq 'getSupportedStyles' ) {
	&print_supported_styles();
}

# List supported formats for a database
elsif ( $ARGV[0] eq 'getDbFormats' && $numOpts == 2 ) {
	&print_db_formats($ARGV[1]);
}

# List supported styles for a database and format
elsif ( $ARGV[0] eq 'getFormatStyles' && $numOpts == 3 ) {
	&print_format_styles($ARGV[1], $ARGV[2]);
}

# Fetch an entry
elsif ( $ARGV[0] eq 'fetchData' && $numOpts > 1 && $numOpts < 5 ) {
	my $query  = $ARGV[1];
	my $formatName = defined( $ARGV[2] ) ? $ARGV[2] : 'default';
	my $styleName  = defined( $ARGV[3] ) ? $ARGV[3] : 'raw';
	&print_fetch_data($query, $formatName, $styleName);
}

# Fetch a set of entries
elsif ( $ARGV[0] eq 'fetchBatch' && $numOpts > 1 && $numOpts < 6 ) {
	my $dbName = $ARGV[1];
	my $idListStr = $ARGV[2];
	if ( $idListStr eq '-' ) {    # Read from STDIN
		my $buffer;
		$idListStr = '';
		while ( sysread( STDIN, $buffer, 1024 ) ) {
			$idListStr .= $buffer;
		}
	}
	$idListStr =~ s/[ \t\n\r;]+/,/g;    # Id list should be comma seperated
	$idListStr =~ s/,+/,/g;             # Remove any empty items
	my $formatName = defined( $ARGV[3] ) ? $ARGV[3] : 'default';
	my $styleName  = defined( $ARGV[4] ) ? $ARGV[4] : 'raw';
	&print_fetch_batch($dbName, $idListStr, $formatName, $styleName);
}

# Unrecgnised method, or too many/few arguments so print usage
else {
	print STDERR
	  "Error: unrecognised method ($ARGV[0]) or too many arguments\n";
	usage();
	exit(2);
}

=head1 FUNCTIONS

=cut

### Wrappers for SOAP operations ###

=head2 soap_get_supported_dbs()

Get the list of supported databases.

  my (@supported_dbs) = &soap_get_supported_dbs();

=cut

sub soap_get_supported_dbs {
	print_debug_message( 'soap_get_supported_dbs', 'Begin', 1 );
	my $supported_dbs_xml = $soap->getSupportedDBs();
	my (@supported_dbs) = $supported_dbs_xml->valueof('//getSupportedDBsReturn');
	print_debug_message( 'soap_get_supported_dbs', 'End', 1 );
	return @supported_dbs;
}

=head2 print_supported_dbs()

Print the list of supported databases.

  &print_supported_dbs();

=cut

sub print_supported_dbs {
	print_debug_message( 'print_supported_dbs', 'Begin', 1 );
	my (@supported_dbs) = soap_get_supported_dbs();
	foreach my $item (@supported_dbs) {
		print $item, "\n";
	}
	print_debug_message( 'print_supported_dbs', 'End', 1 );
}

=head2 soap_get_supported_formats()

Get the list of supported formats for each database.

  my (@supported_formats) = &soap_get_supported_formats();

=cut

sub soap_get_supported_formats {
	print_debug_message( 'soap_get_supported_formats', 'Begin', 1 );
	my $supported_formats_xml = $soap->getSupportedFormats();
	my (@supported_formats) = $supported_formats_xml->valueof('//getSupportedFormatsReturn');
	print_debug_message( 'soap_get_supported_formats', 'End', 1 );
	return @supported_formats;
}

=head2 print_supported_formats()

Print the list of supported formats for each database.

  &print_supported_formats();

=cut

sub print_supported_formats {
	print_debug_message( 'print_supported_formats', 'Begin', 1 );
	my (@supported_formats) = soap_get_supported_formats();
	foreach my $item (@supported_formats) {
		print $item, "\n";
	}
	print_debug_message( 'print_supported_formats', 'End', 1 );
}

=head2 soap_get_supported_styles()

Get the list of supported styles for each database.

  my (@supported_styles) = &soap_get_supported_styles();

=cut

sub soap_get_supported_styles {
	print_debug_message( 'soap_get_supported_styles', 'Begin', 1 );
	my $supported_styles_xml = $soap->getSupportedStyles();
	my (@supported_styles) = $supported_styles_xml->valueof('//getSupportedStylesReturn');
	print_debug_message( 'soap_get_supported_styles', 'End', 1 );
	return @supported_styles;
}

=head2 print_supported_styles()

Print the list of supported styles for each database.

  &print_supported_styles();

=cut

sub print_supported_styles {
	print_debug_message( 'print_supported_styles', 'Begin', 1 );
	my (@supported_styles) = soap_get_supported_styles();
	foreach my $item (@supported_styles) {
		print $item, "\n";
	}
	print_debug_message( 'print_supported_styles', 'End', 1 );
}

=head2 soap_get_db_formats($dbName)

Get the list of supported formats for a database.

  my (@supported_formats) = &soap_get_db_formats();

=cut

sub soap_get_db_formats {
	print_debug_message( 'soap_get_db_formats', 'Begin', 1 );
	my $dbName = shift;
	my $supported_formats_xml = $soap->getDbFormats(SOAP::Data->name( 'db' => $dbName ));
	my (@supported_formats) = $supported_formats_xml->valueof('//getDbFormatsReturn');
	print_debug_message( 'soap_get_db_formats', 'End', 1 );
	return @supported_formats;
}

=head2 print_db_formats()

Print the list of supported formats for a database.

  &print_db_formats($dbName);

=cut

sub print_db_formats {
	print_debug_message( 'print_db_formats', 'Begin', 1 );
	my $dbName = shift;
	my (@supported_formats) = soap_get_db_formats($dbName);
	foreach my $item (@supported_formats) {
		print $item, "\n";
	}
	print_debug_message( 'print_db_formats', 'End', 1 );
}

=head2 soap_get_format_styles()

Get the list of supported styles for a format of a database.

  my (@supported_styles) = &soap_get_format_styles($dbName, $formatName);

=cut

sub soap_get_format_styles {
	print_debug_message( 'soap_get_format_styles', 'Begin', 1 );
	my $dbName = shift;
	my $formatName = shift;
	my $supported_styles_xml = $soap->getFormatStyles(
		SOAP::Data->name( 'db' => $dbName ),
		SOAP::Data->name( 'format' => $formatName )
	);
	my (@supported_styles) = $supported_styles_xml->valueof('//getFormatStylesReturn');
	print_debug_message( 'soap_get_format_styles', 'End', 1 );
	return @supported_styles;
}

=head2 print_format_styles()

Print the list of supported styles for a format of a database.

  &print_format_styles($dbName, $formatName);

=cut

sub print_format_styles {
	print_debug_message( 'print_format_styles', 'Begin', 1 );
	my $dbName = shift;
	my $formatName = shift;
	my (@supported_styles) = soap_get_format_styles($dbName, $formatName);
	foreach my $item (@supported_styles) {
		print $item, "\n";
	}
	print_debug_message( 'print_format_styles', 'End', 1 );
}

=head2 soap_fetch_data()

Fetch an entry.

  my $entryStr = &soap_fetch_data($query, $formatName, $styleName);

=cut

sub soap_fetch_data {
	print_debug_message( 'soap_fetch_data', 'Begin', 1 );
	my $query = shift;
	my $formatName = shift;
	my $styleName = shift;
	my $result_xml = $soap->fetchData(
		SOAP::Data->name( 'query' => $query ),
		SOAP::Data->name( 'format' => $formatName ),
		SOAP::Data->name( 'style' => $styleName )
	);
	my $entryStr = $result_xml->valueof('//fetchDataReturn');
	print_debug_message( 'soap_fetch_data', 'End', 1 );
	return $entryStr;
}

=head2 print_fetch_data()

Fetch an entry and print it.

=cut

sub print_fetch_data {
	print_debug_message( 'print_fetch_data', 'Begin', 1 );
	my $query = shift;
	my $formatName = shift;
	my $styleName = shift;
	# Read identifiers from file?
	if($query eq '-' || $query =~ m/^@/) {
		my $FH;
		my $filename = $query;
		$filename =~ s/^@//;
		if($filename eq '-') {
			$FH = *STDIN;
		}
		else {
			open($FH, '<', $filename) or die "Error: unable to open file $filename ($!)";
		}
		while(<$FH>) {
			chomp;
			my $entryId = $_;
			if($entryId =~ m/^\S+:\S+/) {
				my $entryStr = &soap_fetch_data($entryId, $formatName, $styleName);
				print $entryStr, "\n" if($entryStr);
			}
		}
		close($FH) unless($filename eq '-');
	}
	else {
		my $entryStr = &soap_fetch_data($query, $formatName, $styleName);
		print $entryStr, "\n" if($entryStr);
	}
	print_debug_message( 'print_fetch_data', 'End', 1 );
}

=head2 soap_fetch_batch()

Fetch a set of entries.

  my $entriesStr = &soap_fetch_batch($dbName, $idListStr, $formatName, $styleName);

=cut

sub soap_fetch_batch {
	print_debug_message( 'soap_fetch_batch', 'Begin', 1 );
	my $dbName = shift;
	my $idListStr = shift;
	my $formatName = shift;
	my $styleName = shift;
	my $result_xml = $soap->fetchBatch(
		SOAP::Data->name( 'db' => $dbName ),
		SOAP::Data->name( 'ids' => $idListStr ),
		SOAP::Data->name( 'format' => $formatName ),
		SOAP::Data->name( 'style' => $styleName )
	);
	my $entriesStr = $result_xml->valueof('//fetchBatchReturn');
	print_debug_message( 'soap_fetch_batch', 'End', 1 );
	return $entriesStr;
}

=head2 print_fetch_batch()

Fetch a set of entries an print them.

  &print_fetch_batch($dbName, $idListStr, $formatName, $styleName);

=cut

sub print_fetch_batch {
	print_debug_message( 'print_fetch_batch', 'Begin', 1 );
	my $dbName = shift;
	my $idListStr = shift;
	my $formatName = shift;
	my $styleName = shift;
	# Read identifiers from file?
	if ( $idListStr eq '-' || $idListStr =~ m/^@/) {
		my $tmpIdListStr = '';
		my $FH;
		my $filename = $idListStr;
		$filename =~ s/^@//;
		if($filename eq '-') {
			$FH = *STDIN;
		}
		else {
			open($FH, '<', $filename) or die "Error: unable to open file $filename ($!)";
		}
		while(<$FH>) {
			chomp;
			$tmpIdListStr .= ',' if(length($tmpIdListStr) > 0);
			$tmpIdListStr .= $_;
		}
		$idListStr = $tmpIdListStr;
		close($FH) unless($filename eq '-');
	}
	my $entriesStr = &soap_fetch_batch($dbName, $idListStr, $formatName, $styleName);
	print $entriesStr, "\n" if($entriesStr);
	print_debug_message( 'print_fetch_batch', 'End', 1 );
}

### Service actions and utility functions ###

=head2 print_debug_message()

Print a debug message at the specified debug level.

  &print_debug_message($function_name, $message, $level);

=cut

sub print_debug_message {
	my $function_name = shift;
	my $message       = shift;
	my $level         = shift;
	if ( $level <= $params{'debugLevel'} ) {
		print STDERR '[', $function_name, '()] ', $message, "\n";
	}
}

=head2 from_wsdl()

Extract the service namespace and endpoint from the service WSDL document 
for use when creating the service interface.

This function assumes that the WSDL contains a single service using a single
namespace and endpoint.

The namespace and endpoint are required to create a service interface, using 
SOAP::Lite->proxy(), that supports repeating elements (maxOcurrs > 1) as used 
in many document/literal services. Using SOAP::Lite->service() with the WSDL
gives an interface where the data structures returned by the service are 
mapped into hash structures and repeated elements are collapsed to a single
instance.

Note: rpc/encoded services are handled  as expected by SOAP::Lite->service() 
since repeating data structures are encoded using arrays by the service.  

  my ($serviceEndpoint, $serviceNamespace) = &from_wsdl($WSDL);

=cut

sub from_wsdl {
	&print_debug_message( 'from_wsdl', 'Begin', 1 );
	my (@retVal) = ();
	my $wsdlStr;
	my $fetchAttemptCount = 0;
	# Create a user agent
	my $ua = LWP::UserAgent->new();
	$ua->agent( $client_agent . $ua->agent() ); # User-agent.
	$ua->env_proxy; # HTTP proxy.
	my $can_accept = HTTP::Message::decodable; # Available encodings.
	while(scalar(@retVal) != 2 && $fetchAttemptCount < MAX_RETRIES) {
		# Fetch WSDL document.
		my $response = $ua->get($WSDL, 
			'Accept-Encoding' => $can_accept, # HTTP compression.
		);
		if ( $params{'trace'} ) { # Request/response trace.
			print( $response->request()->as_string(), "\n" );
			print( $response->as_string(), "\n" );
		}
		$wsdlStr = $response->decoded_content();
		$wsdlStr = $response->content() if (!defined($wsdlStr));
		$fetchAttemptCount++;
		if(defined($wsdlStr) && $wsdlStr ne '') {
			# Extract service endpoint.
			if ( $wsdlStr =~ m/<(\w+:)?address\s+location=["']([^'"]+)['"]/ ) {
				$retVal[0] = $2;
			}
			# Extract service namespace.
			if ( $wsdlStr =~
				m/<(\w+:)?definitions\s*[^>]*\s+targetNamespace=['"]([^"']+)["']/ )
			{
				$retVal[1] = $2;
			}
		}
	}
	# Check endpoint and namespace have been obtained.
	if(scalar(@retVal) != 2 || $retVal[0] eq '' || $retVal[1] eq '') {
		die "Error: Unable to determine service endpoint and namespace for requests.";
	}
	&print_debug_message( 'from_wsdl', 'End', 1 );
	return @retVal;
}

=head2 usage()

Print program usage.

  &usage();

=cut

sub usage {
	print STDERR <<EOF
Usage:
  $scriptName <method> [arguments...] [--trace] [--WSDL <wsdlUrl>]

A number of methods are available:

  getSupportedDBs - list available databases
  getSupportedFormats - list available databases with formats
  getSupportedStyles - list available databases with styles
  getDbFormats - list formats for a specifed database
  getFormatStyles - list styles for a specified database and format
  fetchData - retrive an database entry. See below for details of arguments.
  fetchBatch - retrive database entries. See below for details of arguments.

Fetching an entry: fetchData

  $scriptName fetchData <dbName:id> [format [style]]

  dbName:id  database name and entry ID or accession (e.g. UNIPROT:WAP_RAT)
  format     format to retrive (e.g. uniprot)
  style      style to retrive (e.g. raw)

Fetching entries: fetchBatch

  $scriptName fetchBatch <dbName> <idList> [format [style]]

  dbName     database name (e.g. UNIPROT)
  idList     list of entry IDs or accessions (e.g. 1433T_RAT,WAP_RAT).
             Maximum of 200 IDs or accessions. "-" for STDIN.
  format     format to retrive (e.g. uniprot)
  style      style to retrive (e.g. raw)

EOF
	  ;
}
