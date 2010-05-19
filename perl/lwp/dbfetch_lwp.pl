#!/usr/bin/env perl

=head1 NAME

dbfetch_lwp.pl

=head1 DESCRIPTION

dbfetch REST web service Perl client using L<LWP>.

Tested with:

=over

=item *
L<LWP> 5.79, L<XML::Simple> 2.12 and Perl 5.8.3

=item *
L<LWP> 5.805, L<XML::Simple> 2.14 and Perl 5.8.7

=item *
L<LWP> 5.820, L<XML::Simple> 2.18 and Perl 5.10.0 (Ubuntu 9.04)

=back

For further information see:

=over

=item *
L<http://www.ebi.ac.uk/Tools/webservices/services/dbfetch_rest>

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
use LWP;
use Getopt::Long qw(:config no_ignore_case bundling);
use File::Basename;
use YAML;
use Data::Dumper;

# Base URL for service
my $baseUrl = 'http://wwwdev.ebi.ac.uk/Tools/dbfetch/dbfetch';

# Output level
my $outputLevel = 1;

# Process command-line options
my $numOpts = scalar(@ARGV);
my %params = ( 'debugLevel' => 0 );

# Default parameter values (should get these from the service)
GetOptions(
    'quiet'         => \$params{'quiet'},          # Decrease output level
    'verbose'       => \$params{'verbose'},        # Increase output level
    'debugLevel=i'  => \$params{'debugLevel'},     # Debug output level
    'baseUrl=s'     => \$baseUrl,                  # Base URL for service.
);
if ( $params{'verbose'} ) { $outputLevel++ }
if ( $params{'$quiet'} )  { $outputLevel-- }

# Debug mode: LWP version
&print_debug_message( 'MAIN', 'LWP::VERSION: ' . $LWP::VERSION,
	1 );

# Debug mode: print the input parameters
&print_debug_message( 'MAIN', "params:\n" . Dumper( \%params ),           11 );

# Get the script filename for use in usage messages
my $scriptName = basename( $0, () );

# Print usage and exit if requested
if ( $params{'help'} || $numOpts == 0 ) {
    &usage();
    exit(0);
}

# Debug mode: show the base URL
&print_debug_message( 'MAIN', 'baseUrl: ' . $baseUrl, 1 );

my $method = shift;
# Get supported database names
if($method eq 'getSupportedDBs') {
    &print_get_supported_dbs();
}
# Get supported database and format names
elsif($method eq 'getSupportedFormats') {
    &print_get_supported_formats();
}
# Get supported database and style names
elsif($method eq 'getSupportedStyles') {
    &print_get_supported_styles();
}
# Get formats for a database.
elsif($method eq 'getDbFormats') {
    &print_get_db_formats(@ARGV);
}
# Get styles for a format of a database.
elsif($method eq 'getFormatStyles') {
    &print_get_format_styles(@ARGV);
}
# Fetch an entry
elsif($method eq 'fetchData') {
    &print_fetch_data(@ARGV);
}
# Fetch a set of entries.
elsif($method eq 'fetchBatch') {
    &print_fetch_batch(@ARGV);
}
else {
    &usage();
    exit(1);
}

=head1 FUNCTIONS

=cut

### Wrappers for REST resources ###

=head2 rest_request()

Perform a REST request.

  my $response_str = &rest_request($url);

=cut

sub rest_request {
	print_debug_message( 'rest_request', 'Begin', 11 );
	my $requestUrl = shift;
	print_debug_message( 'rest_request', 'URL: ' . $requestUrl, 11 );

	# Create a user agent
	my $ua = LWP::UserAgent->new();
	'$Revision$' =~ m/(\d+)/;
	$ua->agent("EBI-Sample-Client/$1 ($scriptName; $OSNAME) " . $ua->agent()
);
	$ua->env_proxy;

	# Perform the request
	my $response = $ua->get($requestUrl);
	print_debug_message( 'rest_request', 'HTTP status: ' . $response->code,
		11 );

	# Check for HTTP error codes
	if ( $response->is_error ) {
		$response->content() =~ m/<h1>([^<]+)<\/h1>/;
		die 'http status: ' . $response->code . ' ' . $response->message
 . '  ' . $1;
	}
	print_debug_message( 'rest_request', 'End', 11 );

	# Return the response data
	return $response->content();
}

=head2 rest_get_meta_information()

Get server meta-information.

  my $dbfetch_info = &rest_get_meta_information();

=cut

sub rest_get_meta_information {
    print_debug_message( 'rest_get_meta_information', 'Begin', 1 );
    # Get meta-information
    my $url = $baseUrl . '/dbfetch.databases?style=yaml';
    my $response_str = &rest_request($url);
    my $dbfetch_info = Load($response_str);
    #print Dumper($dbfetch_info);
    print_debug_message( 'rest_get_meta_information', 'End', 1 );
    return $dbfetch_info;
}

=head2 rest_get_supported_dbs()

Get list of supported database names.

  my (@db_list) = &rest_get_supported_dbs();

=cut

sub rest_get_supported_dbs {
	print_debug_message( 'rest_get_supported_dbs', 'Begin', 1 );
	my $dbfetch_info = &rest_get_meta_information();
	my (@retArray) = ();
	foreach my $db_info (@{$dbfetch_info->{'databases'}}) {
	    push(@retArray, $db_info->{'databaseName'});
	}
	print_debug_message( 'rest_get_supported_dbs', 'End', 1 );
	return @retArray;
}

=head2

Print list of supported databases.

  &print_get_supported_dbs();

=cut

sub print_get_supported_dbs {
    print_debug_message( 'print_get_supported_dbs', 'Begin', 1 );
    my (@db_array) = &rest_get_supported_dbs();
    foreach my $dbName (@db_array) {
	print $dbName, "\n";
    }
    print_debug_message( 'print_get_supported_dbs', 'End', 1 );
}

=head2 rest_get_supported_formats()

Get list of supported database and format names.

  my (@format_list) = &rest_get_supported_formats();

=cut

sub rest_get_supported_formats {
	print_debug_message( 'rest_get_supported_formats', 'Begin', 1 );
	my $dbfetch_info = &rest_get_meta_information();
	my (@retArray) = ();
	foreach my $db_info (@{$dbfetch_info->{'databases'}}) {
	    my $tmpStr = $db_info->{'databaseName'} . "\t";
	    foreach my $format (@{$db_info->{'formats'}}) {
		$tmpStr .= $format->{'formatName'} . ',';
	    }
	    $tmpStr =~ s/,$//;
	    push(@retArray, $tmpStr);
	}
	print_debug_message( 'rest_get_supported_formats', 'End', 1 );
	return (@retArray);
}

=head2

Print list of supported database and format names.

  &print_get_supported_formats();

=cut

sub print_get_supported_formats {
    print_debug_message( 'print_get_supported_formats', 'Begin', 1 );
    my (@format_array) = &rest_get_supported_formats();
    foreach my $format (@format_array) {
	print $format, "\n";
    }
    print_debug_message( 'print_get_supported_formats', 'End', 1 );
}

=head2 rest_get_supported_styles()

Get list of supported database and style names.

  my (@style_list) = &rest_get_supported_styles();

=cut

sub rest_get_supported_styles {
	print_debug_message( 'rest_get_supported_styles', 'Begin', 1 );
	my $dbfetch_info = &rest_get_meta_information();
	my (@retArray) = ();
	foreach my $db_info (@{$dbfetch_info->{'databases'}}) {
	    my $tmpStr = $db_info->{'databaseName'} . "\t";
	    my %styleHash = ();
	    foreach my $format (@{$db_info->{'formats'}}) {
		foreach my $style (@{$format->{'styles'}}) {
		    $styleHash{$style->{'styleName'}} = $style->{'styleName'};
		}
	    }
	    foreach my $styleName (sort(keys(%styleHash))) {
		$tmpStr .= $styleName . ',';
	    }
	    $tmpStr =~ s/,$//;
	    push(@retArray, $tmpStr);
	}
	print_debug_message( 'rest_get_supported_styles', 'End', 1 );
	return (@retArray);
}

=head2

Print list of supported database and style names.

  &print_get_supported_styles();

=cut

sub print_get_supported_styles {
    print_debug_message( 'print_get_supported_styles', 'Begin', 1 );
    my (@style_array) = &rest_get_supported_styles();
    foreach my $style (@style_array) {
	print $style, "\n";
    }
    print_debug_message( 'print_get_supported_styles', 'End', 1 );
}

sub rest_get_db_formats {
}

sub print_get_db_formats {
}

sub rest_get_format_styles {
}

sub print_get_format_styles {
}

sub rest_fetch_data {
}

sub print_fetch_data {
}

sub rest_fetch_batch {
    print_debug_message( 'rest_fetch_batch', 'Begin', 1 );
    my $url = $baseUrl . '/' . shift;
    $url .= '/' . shift if(scalar(@_) > 0);
    $url .= '/' . shift if(scalar(@_) > 0);
    $url .= '?style=' . shift if(scalar(@_) > 0);
    print $url, "\n";
    my $response_str = &rest_request($url);
    print_debug_message( 'rest_fetch_batch', 'End', 1 );
    return $response_str;
}

sub print_fetch_batch {
    print_debug_message( 'print_fetch_batch', 'Begin', 1 );
    print &rest_fetch_batch(@_);
    print_debug_message( 'print_fetch_batch', 'End', 1 );
}

### Service actions and utility functions ###

=head2 print_debug_message()

Print debug message at specified debug level.

  &print_debug_message($method_name, $message, $level);

=cut

sub print_debug_message {
	my $function_name = shift;
	my $message       = shift;
	my $level         = shift;
	if ( $level <= $params{'debugLevel'} ) {
		print STDERR '[', $function_name, '()] ', $message, "\n";
	}
}

=head2 usage()

Print program usage message.

  &usage();

=cut

sub usage {
	print STDERR <<EOF
WSDbfetch
=========
Support/Feedback:

  http://www.ebi.ac.uk/support/
EOF
}

=head1 FEEDBACK/SUPPORT

Please contact us at L<http://www.ebi.ac.uk/support/> if you have any 
feedback, suggestions or issues with the service or this client.

=cut
