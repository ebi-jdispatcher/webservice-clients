#!/usr/bin/env perl

=head1 NAME

ebeye_soaplite.pl

=head1 DESCRIPTION

EB-eye (SOAP) client using L<SOAP::Lite>

Tested with:

=over

=item *
L<SOAP::Lite> 0.60 and Perl 5.8.3

=item *
L<SOAP::Lite> 0.69 and Perl 5.8.8 (Ubuntu 8.04 LTS)

=item *
L<SOAP::Lite> 0.710.10 and Perl 5.10.1 (Ubuntu 10.04 LTS)

=item *
L<SOAP::Lite> 0.714 and Perl 5.14.2 (Ubuntu 12.04 LTS)

=back

For further information see:

=over

=item *
L<http://www.ebi.ac.uk/Tools/webservices/services/eb-eye>

=item *
L<http://www.ebi.ac.uk/Tools/Webservices/tutorials/perl>

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
use LWP;
use Getopt::Long qw(:config no_ignore_case bundling);
use File::Basename;
use MIME::Base64;
use Data::Dumper;

# Maximum connection retries.
use constant MAX_RETRIES => 3;

# WSDL URL for service
my $WSDL = 'http://www.ebi.ac.uk/ebisearch/service.ebi?wsdl';

# Output level
my $outputLevel = 1;

# Process command-line options
my $numOpts = scalar(@ARGV);
my %params = ( 'debugLevel' => 0 );

GetOptions(

	# EB-eye operations
	'listDomains'                  => \$params{'listDomains'},
	'getNumberOfResults'           => \$params{'getNumberOfResults'},
	'getResultsIds'                => \$params{'getResultsIds'},
	'getAllResultsIds'             => \$params{'getAllResultsIds'},
	'listFields'                   => \$params{'listFields'},
	'getResults'                   => \$params{'getResults'},
	'getEntry'                     => \$params{'getEntry'},
	'getEntries'                   => \$params{'getEntries'},
	'getEntryFieldUrls'            => \$params{'getEntryFieldUrls'},
	'getEntriesFieldUrls'          => \$params{'getEntriesFieldUrls'},
	'getDomainsReferencedInDomain' => \$params{'getDomainsReferencedInDomain'},
	'getDomainsReferencedInEntry'  => \$params{'getDomainsReferencedInEntry'},
	'listAdditionalReferenceFields' =>
	  \$params{'listAdditionalReferenceFields'},
	'getReferencedEntries'        => \$params{'getReferencedEntries'},
	'getReferencedEntriesSet'     => \$params{'getReferencedEntriesSet'},
	'getReferencedEntriesFlatSet' => \$params{'getReferencedEntriesFlatSet'},
	'getDomainsHierarchy'         => \$params{'getDomainsHierarchy'},
	'getDetailledNumberOfResults' => \$params{'getDetailledNumberOfResults'},
	'listFieldsInformation'       => \$params{'listFieldsInformation'},

	# Generic
	'help|h'       => \$params{'help'},          # Help/usage message
	'quiet'        => \$params{'quiet'},         # Decrease output level
	'verbose'      => \$params{'verbose'},       # Increase output level
	'debugLevel=i' => \$params{'debugLevel'},    # Debug output level
	'trace'        => \$params{'trace'},         # SOAP message debug
	'endpoint=s'   => \$params{'endpoint'},      # SOAP service endpoint
	'namespace=s'  => \$params{'namespace'},     # SOAP service namespace
	'WSDL=s'       => \$WSDL,                    # SOAP service WSDL
);

# Adjust output level for options
if ( $params{'verbose'} ) { $outputLevel++ }
if ( $params{'quiet'} )  { $outputLevel-- }

# Get the script filename for use in usage messages
my $scriptName = basename( $0, () );

# Debug mode: SOAP::Lite version
&print_debug_message( 'MAIN', 'SOAP::Lite::VERSION: ' . $SOAP::Lite::VERSION,
	1 );

# Debug mode: print the parameters
&print_debug_message( 'MAIN', "params:\n" . Dumper( \%params ), 11 );

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
	timeout => 6000,    # HTTP connection timeout
	#proxy => ['http' => 'http://your.proxy.server/'], # HTTP proxy
	options => {
		# HTTP compression (requires Compress::Zlib)
		compress_threshold => 100000000, # Prevent request compression.
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
$soap->transport->agent(&get_agent_string() . $soap->transport->agent());
&print_debug_message( 'MAIN', 'user-agent: ' . $soap->transport->agent(), 11 );

# Handle command
if ( $params{'listDomains'} ) {
	&print_list_domains();
}
elsif ( $params{'getNumberOfResults'} ) {
	if ( $numOpts > 1 ) {
		&print_get_number_of_results( $ARGV[0], $ARGV[1] );
	}
	else {
		die "Error: insufficent arguments for getNumberOfResults";
	}
}
elsif ( $params{'getResultsIds'} ) {
	if ( $numOpts > 3 ) {
		&print_get_results_ids( $ARGV[0], $ARGV[1], $ARGV[2], $ARGV[3] );
	}
	else {
		die "Error: insufficent arguments for getResultsIds";
	}
}
elsif ( $params{'getAllResultsIds'} ) {
	if ( $numOpts > 1 ) {
		&print_get_all_results_ids( $ARGV[0], $ARGV[1] );
	}
	else {
		die "Error: insufficent arguments for getAllResultsIds";
	}
}
elsif ( $params{'listFields'} ) {
	if ( $numOpts > 0 ) {
		&print_list_fields( $ARGV[0] );
	}
	else {
		die "Error: insufficent arguments for listFields";
	}
}
elsif ( $params{'getResults'} ) {
	if ( $numOpts > 4 ) {
		my (@fieldNameList) = split( /[ ,]+/, $ARGV[2] );
		&print_get_results( $ARGV[0], $ARGV[1], \@fieldNameList, $ARGV[3],
			$ARGV[4] );
	}
	else {
		die "Error: insufficent arguments for getResults";
	}
}
elsif ( $params{'getEntry'} ) {
	if ( $numOpts > 2 ) {
		my (@fieldNameList) = split( /[ ,]+/, $ARGV[2] );
		&print_get_entry( $ARGV[0], $ARGV[1], \@fieldNameList );
	}
	else {
		die "Error: insufficent arguments for getEntry";
	}
}
elsif ( $params{'getEntries'} ) {
	if ( $numOpts > 2 ) {
		my (@entries)       = split( /[ ,]+/, $ARGV[1] );
		my (@fieldNameList) = split( /[ ,]+/, $ARGV[2] );
		&print_get_entries( $ARGV[0], \@entries, \@fieldNameList );
	}
	else {
		die "Error: insufficent arguments for getEntries";
	}
}
elsif ( $params{'getEntryFieldUrls'} ) {
	if ( $numOpts > 2 ) {
		my (@fieldNameList) = split( /[ ,]+/, $ARGV[2] );
		&print_get_entry_field_urls( $ARGV[0], $ARGV[1], \@fieldNameList );
	}
	else {
		die "Error: insufficent arguments for getEntryFieldUrls";
	}
}
elsif ( $params{'getEntriesFieldUrls'} ) {
	if ( $numOpts > 2 ) {
		my (@entries)       = split( /[ ,]+/, $ARGV[1] );
		my (@fieldNameList) = split( /[ ,]+/, $ARGV[2] );
		&print_get_entries_field_urls( $ARGV[0], \@entries, \@fieldNameList );
	}
	else {
		die "Error: insufficent arguments for getEntriesFieldUrls";
	}
}
elsif ( $params{'getDomainsReferencedInDomain'} ) {
	if ( $numOpts > 0 ) {
		&print_get_domains_referenced_in_domain( $ARGV[0] );
	}
	else {
		die "Error: insufficent arguments for getDomainsReferencedInDomain";
	}
}
elsif ( $params{'getDomainsReferencedInEntry'} ) {
	if ( $numOpts > 1 ) {
		&print_get_domains_referenced_in_entry( $ARGV[0], $ARGV[1] );
	}
	else {
		die "Error: insufficent arguments for getDomainsReferencedInEntry";
	}
}
elsif ( $params{'listAdditionalReferenceFields'} ) {
	if ( $numOpts > 1 ) {
		&print_list_additional_reference_fields( $ARGV[0], $ARGV[1] );
	}
	else {
		die "Error: insufficent arguments for listAdditionalReferenceFields";
	}
}
elsif ( $params{'getReferencedEntries'} ) {
	if ( $numOpts > 2 ) {
		&print_get_referenced_entries( $ARGV[0], $ARGV[1], $ARGV[2] );
	}
	else {
		die "Error: insufficent arguments for getReferencedEntries";
	}
}
elsif ( $params{'getReferencedEntriesSet'} ) {
	if ( $numOpts > 3 ) {
		my (@entries)       = split( /[ ,]+/, $ARGV[1] );
		my (@fieldNameList) = split( /[ ,]+/, $ARGV[3] );
		&print_get_referenced_entries_set( $ARGV[0], \@entries, $ARGV[2],
			\@fieldNameList );
	}
	else {
		die "Error: insufficent arguments for getReferencedEntriesSet";
	}
}
elsif ( $params{'getReferencedEntriesFlatSet'} ) {
	if ( $numOpts > 3 ) {
		my (@entries)       = split( /[ ,]+/, $ARGV[1] );
		my (@fieldNameList) = split( /[ ,]+/, $ARGV[3] );
		&print_get_referenced_entries_flat_set( $ARGV[0], \@entries, $ARGV[2],
			\@fieldNameList );
	}
	else {
		die "Error: insufficent arguments for getReferencedEntriesFlatSet";
	}
}
elsif ( $params{'getDomainsHierarchy'} ) {
	&print_get_domains_hierarchy();
}
elsif ( $params{'getDetailledNumberOfResults'} ) {
	if ( $numOpts > 2 ) {
		&print_get_detailled_number_of_results( $ARGV[0], $ARGV[1], $ARGV[2] );
	}
	else {
		die "Error: insufficent arguments for getDetailledNumberOfResult";
	}
}
elsif ( $params{'listFieldsInformation'} ) {
	if ( $numOpts > 0 ) {
		&print_list_fields_information( $ARGV[0] );
	}
	else {
		die "Error: insufficent arguments for listFieldsInformation";
	}
}

# No method specified
else {
	die 'Error: no method specified';
}

=head1 FUNCTIONS

=cut

=head2 get_agent_string()

Get the user agent string for the client.

  my $agent_str = &get_agent_string();

=cut

sub get_agent_string {
	print_debug_message( 'get_agent_string', 'Begin', 11 );
	my $clientVersion = '0';
	if('$Revision$' =~ m/(\d+)/) { # SCM revision tag.
		$clientVersion = $1;
	}
	my $agent_str = "EBI-Sample-Client/$clientVersion ($scriptName; $OSNAME) ";
	print_debug_message( 'get_agent_string', 'End', 11 );
	return 	$agent_str;
}

### Wrappers for SOAP operations ###

=head2 soap_list_domains()

Returns a list of all the domains identifiers which can be used in a query.

  my (@domain_name_list) = &soap_list_domains();

=cut

sub soap_list_domains {
	print_debug_message( 'soap_list_domains', 'Begin', 1 );
	my $domainList = $soap->listDomains();
	print_debug_message( 'soap_list_domains', 'End', 1 );
	return $domainList->valueof('//arrayOfDomainNames/string');
}

=head2 soap_get_number_of_results()

Executes a query and returns the number of results found.

  my $num_results = &soap_get_number_of_results($domain, $query_str);

=cut

sub soap_get_number_of_results {
	print_debug_message( 'soap_get_number_of_results', 'Begin', 1 );
	my $domain    = shift;
	my $query_str = shift;
	print_debug_message( 'soap_get_number_of_results', 'domain: ' . $domain,
		2 );
	print_debug_message( 'soap_get_number_of_results',
		'query_str: ' . $query_str, 2 );
	my $res = $soap->getNumberOfResults( SOAP::Data->name( 'domain' => $domain )->attr( { 'xmlns' => $serviceNamespace } ), 
	                                     SOAP::Data->name( 'query' => $query_str )->attr( { 'xmlns' => $serviceNamespace } ) );
	print_debug_message( 'soap_get_number_of_results', 'End', 1 );
	return $res->valueof('//numberOfResults');
}

=head2 soap_get_results_ids()

Executes a query and returns the list of identifiers for the entries found.

  my (@entry_id_list) = &soap_get_results_ids($domain, $query_str, $start, $size);

=cut

sub soap_get_results_ids {
	print_debug_message( 'soap_get_results_ids', 'Begin', 1 );
	my ( $domain, $query, $start, $size ) = @_;
	print_debug_message( 'soap_get_results_ids', 'domain: ' . $domain, 2 );
	print_debug_message( 'soap_get_results_ids', 'query: ' . $query,   2 );
	print_debug_message( 'soap_get_results_ids', 'start: ' . $start,   2 );
	print_debug_message( 'soap_get_results_ids', 'size: ' . $size,     2 );
	my $res = $soap->getResultsIds( SOAP::Data->name( 'domain' => $domain )->attr( { 'xmlns' => $serviceNamespace } ), 
								    SOAP::Data->name( 'query' => $query )->attr( { 'xmlns' => $serviceNamespace } ), 
								    SOAP::Data->name( 'start' => $start )->attr( { 'xmlns' => $serviceNamespace } ), 
								    SOAP::Data->name( 'size' => $size )->attr( { 'xmlns' => $serviceNamespace } ) );
	print_debug_message( 'soap_get_results_ids', 'End', 1 );
	return $res->valueof('//arrayOfIds/string');
}

=head2 soap_get_all_results_ids()

Executes a query and returns the list of all the identifiers for the entries 
found.

Warning: This method can fail if the number of entries is really huge. The 
method soap_get_results_ids() is a lot safer.

  my (@entry_id_list) = soap_get_all_results_ids($domain, $query_str);

=cut

sub soap_get_all_results_ids {
	print_debug_message( 'soap_get_all_results_ids', 'Begin', 1 );
	my ( $domain, $query ) = @_;
	print_debug_message( 'soap_get_all_results_ids', 'domain: ' . $domain, 2 );
	print_debug_message( 'soap_get_all_results_ids', 'query: ' . $query,   2 );
	my $res = $soap->getAllResultsIds( SOAP::Data->name( 'domain' => $domain )->attr( { 'xmlns' => $serviceNamespace } ), 
								       SOAP::Data->name( 'query' => $query )->attr( { 'xmlns' => $serviceNamespace } ) );
	print_debug_message( 'soap_get_all_results_ids', 'End', 1 );
	return $res->valueof('//arrayOfIds/string');
}

=head2 soap_list_fields()

Returns the list of fields that can be retrieved for a particular domain.

  my (@field_name_list) = soap_list_fields($domain);

=cut

sub soap_list_fields {
	print_debug_message( 'soap_list_fields', 'Begin', 1 );
	my $domain = shift;
	print_debug_message( 'soap_list_fields', 'domain: ' . $domain, 2 );
	my $res = $soap->listFields( SOAP::Data->name( 'domain' => $domain)->attr( { 'xmlns' => $serviceNamespace } ) );
	print_debug_message( 'soap_list_fields', 'End', 1 );
	return $res->valueof('//arrayOfFieldNames/string');
}

=head2 soap_get_results()

Executes a query and returns a list of results. Each result contains the 
values for each field specified in the "fields" argument in the same order as 
they appear in the "fields" list. 

  my (@entry_list) = soap_get_results($domain, $query_str, \@fields, $start, $size);

=cut

sub soap_get_results {
	print_debug_message( 'soap_get_results', 'Begin', 1 );
	my ( $domain, $query, $fields, $start, $size ) = @_;
	my $res = $soap->getResults( SOAP::Data->name( 'domain' => $domain )->attr( { 'xmlns' => $serviceNamespace } ), 
								 SOAP::Data->name( 'query' => $query )->attr( { 'xmlns' => $serviceNamespace } ),
								 SOAP::Data->name( 'fields' => \SOAP::Data->value(soap_to_arrayOfString( $fields ) ) )->attr( { 'xmlns' => $serviceNamespace } ),
								 SOAP::Data->name( 'start' => $start)->attr( { 'xmlns' => $serviceNamespace } ),
								 SOAP::Data->name( 'size' => $size)->attr( { 'xmlns' => $serviceNamespace } ) );
	print_debug_message( 'soap_get_results', 'End', 1 );
	return &toNestedArray( '//arrayOfEntryValues', $res );
}

=head2 soap_get_entry()

Search for a particular entry in a domain and returns the values for some of 
the fields of this entry. The result contains the values for each field 
specified in the "fields" argument in the same order as they appear in the 
"fields" list.

  my $entry = soap_get_entry($domain, $entry_id, \@fields);

=cut

sub soap_get_entry {
	print_debug_message( 'soap_get_entry', 'Begin', 1 );
	my ( $domain, $entry, $fields ) = @_;
	print_debug_message( 'soap_get_entry', 'domain: ' . $domain,          2 );
	print_debug_message( 'soap_get_entry', 'entry: ' . $entry,            2 );
	print_debug_message( 'soap_get_entry', "fields:\n" . Dumper($fields), 2 );
	my $res = $soap->getEntry( SOAP::Data->name( 'domain' => $domain)->attr( { 'xmlns' => $serviceNamespace } ),
							   SOAP::Data->name( 'entry' => $entry)->attr( { 'xmlns' => $serviceNamespace } ), 
							   SOAP::Data->name( 'fields' => \SOAP::Data->value(soap_to_arrayOfString( $fields ) ) )->attr( { 'xmlns' => $serviceNamespace } ) );
	print_debug_message( 'soap_get_entry', 'End', 1 );
	return $res->valueof('//entryValues/string');
}

=head2 soap_get_entries()

Search for entries in a domain and returns the values for some of the fields 
of these entries. The result contains the values for each field specified in 
the "fields" argument in the same order as they appear in the "fields" list.

  my (@entry_list) = soap_get_entries($domain, \@entry_id_list, \@fields);

=cut

sub soap_get_entries {
	print_debug_message( 'soap_get_entries', 'Begin', 1 );
	my ( $domain, $entries, $fields ) = @_;
	print_debug_message( 'soap_get_entries', 'domain: ' . $domain, 2 );
	print_debug_message( 'soap_get_entries', "entries:\n" . Dumper($entries),
		2 );
	print_debug_message( 'soap_get_entries', "fields:\n" . Dumper($fields), 2 );
	my $res = $soap->getEntries( SOAP::Data->name( 'domain' => $domain )->attr( { 'xmlns' => $serviceNamespace } ),
							     SOAP::Data->name( 'entries' => \SOAP::Data->value(soap_to_arrayOfString( $entries ) ) )->attr( { 'xmlns' => $serviceNamespace } ),
							     SOAP::Data->name( 'fields' => \SOAP::Data->value(soap_to_arrayOfString( $fields ) ) )->attr( { 'xmlns' => $serviceNamespace } ) );
	print_debug_message( 'soap_get_entries', 'End', 1 );
	return &toNestedArray( '//arrayOfEntryValues', $res );
}

=head2 soap_get_entry_field_urls()

Search for a particular entry in a domain and returns the urls configured for 
some of the fields of this entry. The result contains the urls for each field 
specified in the "fields" argument in the same order as they appear in the 
"fields" list. 

  my (@entry_url_list) = soap_get_entry_field_urls($domain, $entry_id, \@fields);

=cut

sub soap_get_entry_field_urls {
	print_debug_message( 'soap_get_entry_field_urls', 'Begin', 1 );
	my ( $domain, $entry, $fields ) = @_;
	print_debug_message( 'soap_get_entry_field_urls', 'domain: ' . $domain, 2 );
	print_debug_message( 'soap_get_entry_field_urls', 'entry: ' . $entry,   2 );
	print_debug_message( 'soap_get_entry_field_urls',
		"fields:\n" . Dumper($fields), 2 );
	my $res = $soap->getEntryFieldUrls( SOAP::Data->name( 'domain' => $domain )->attr( { 'xmlns' => $serviceNamespace } ),
							            SOAP::Data->name( 'entry' => $entry )->attr( { 'xmlns' => $serviceNamespace } ), 
							            SOAP::Data->name( 'fields' => \SOAP::Data->value(soap_to_arrayOfString( $fields ) ) )->attr( { 'xmlns' => $serviceNamespace } ) );
	print_debug_message( 'soap_get_entry_field_urls', 'End', 1 );
	return $res->valueof('//entryUrlsValues/string');
}

=head2 soap_get_entries_field_urls()

Search for a list of entries in a domain and returns the urls configured for 
some of the fields of these entries. Each result contains the url for each 
field specified in the "fields" argument in the same order as they appear in 
the "fields" list. 

  my (@entry_url_list_list) = soap_get_entries_field_urls($domain, \@entry_id_list, \@fields);

=cut

sub soap_get_entries_field_urls {
	print_debug_message( 'soap_get_entries_field_urls', 'Begin', 1 );
	my ( $domain, $entries, $fields ) = @_;
	print_debug_message( 'soap_get_entries_field_urls', 'domain: ' . $domain,
		2 );
	print_debug_message( 'soap_get_entries_field_urls',
		"entries:\n" . Dumper($entries), 2 );
	print_debug_message( 'soap_get_entries_field_urls',
		"fields:\n" . Dumper($fields), 2 );
	my $res = $soap->getEntriesFieldUrls( SOAP::Data->name( 'domain' => $domain )->attr( { 'xmlns' => $serviceNamespace } ),
							              SOAP::Data->name( 'entries' => \SOAP::Data->value(soap_to_arrayOfString( $entries ) ) )->attr( { 'xmlns' => $serviceNamespace } ), 
							              SOAP::Data->name( 'fields' => \SOAP::Data->value(soap_to_arrayOfString( $fields ) ) )->attr( { 'xmlns' => $serviceNamespace } ) );
	print_debug_message( 'soap_get_entries_field_urls', 'End', 1 );
	return &toNestedArray( '//arrayOfEntryUrlsValues', $res );
}

=head2 soap_get_domains_referenced_in_domain()

Returns the list of domains with entries referenced in a particular domain. 
These domains are indexed in the EB-eye. 

  my (@domain_list) = soap_get_domains_referenced_in_domain($domain);

=cut

sub soap_get_domains_referenced_in_domain {
	print_debug_message( 'soap_get_domains_referenced_in_domain', 'Begin', 1 );
	my $domain = shift;
	print_debug_message( 'soap_get_domains_referenced_in_domain',
		'domain: ' . $domain, 2 );
	my $res = $soap->getDomainsReferencedInDomain( SOAP::Data->name( 'domain' => $domain )->attr( { 'xmlns' => $serviceNamespace } ) );
	print_debug_message( 'soap_get_domains_referenced_in_domain', 'End', 1 );
	return $res->valueof('//arrayOfDomainNames/string');
}

=head2 soap_get_domains_referenced_in_entry()

Returns the list of domains with entries referenced in a particular domain 
entry. These domains are indexed in the EB-eye. 

  my (@domain_list) = soap_get_domains_referenced_in_entry($domain, $entry_id);

=cut

sub soap_get_domains_referenced_in_entry {
	print_debug_message( 'soap_get_domains_referenced_in_entry', 'Begin', 1 );
	my $domain = shift;
	my $entry  = shift;
	print_debug_message( 'soap_get_domains_referenced_in_entry',
		'domain: ' . $domain, 2 );
	print_debug_message( 'soap_get_domains_referenced_in_entry',
		'entry: ' . $entry, 2 );
	my $res = $soap->getDomainsReferencedInEntry( SOAP::Data->name( 'domain' => $domain )->attr( { 'xmlns' => $serviceNamespace } ),
												  SOAP::Data->name( 'entry' => $entry )->attr( { 'xmlns' => $serviceNamespace } ) );
	print_debug_message( 'soap_get_domains_referenced_in_entry', 'End', 1 );
	return $res->valueof('//arrayOfDomainNames/string');
}

=head2 soap_list_additional_reference_fields()

Returns the list of fields corresponding to databases referenced in the 
domain but not included as a domain in the EB-eye. 

  my (@field_list) = soap_list_additional_reference_fields($domain);

=cut

sub soap_list_additional_reference_fields {
	print_debug_message( 'soap_list_additional_reference_fields', 'Begin', 1 );
	my $domain = shift;
	my $res = $soap->listAdditionalReferenceFields( SOAP::Data->name( 'domain' => $domain )->attr( { 'xmlns' => $serviceNamespace } ) );
	print_debug_message( 'soap_list_additional_reference_fields', 'End', 1 );
	return $res->valueof('//arrayOfFieldNames/string');
}

=head2 soap_get_referenced_entries()

Returns the list of referenced entry identifiers from a domain referenced in 
a particular domain entry.

  my (@entry_id_list) = soap_get_referenced_entries($domain, $entry_id, $referenced_domain);

=cut

sub soap_get_referenced_entries {
	print_debug_message( 'soap_get_referenced_entries', 'Begin', 1 );
	my ( $domain, $entry, $referencedDomain ) = @_;
	my $res = $soap->getReferencedEntries( SOAP::Data->name( 'domain' => $domain )->attr( { 'xmlns' => $serviceNamespace } ),
										   SOAP::Data->name( 'entry' => $entry )->attr( { 'xmlns' => $serviceNamespace } ),
										   SOAP::Data->name( 'referencedDomain' => $referencedDomain )->attr( { 'xmlns' => $serviceNamespace } ) );
	print_debug_message( 'soap_get_referenced_entries', 'End', 1 );
	return $res->valueof('//arrayOfEntryIds/string');
}

=head2 soap_get_referenced_entries_set()

Returns the list of referenced entries from a domain referenced in a set of 
entries. The result will be returned as a list of objects, each representing 
an entry reference. 

  my (@entry_list) = soap_get_referenced_entries_set($domain, \@entry_id_list, $referenced_domain, \@fields);

=cut

sub soap_get_referenced_entries_set {
	print_debug_message( 'soap_get_referenced_entries_set', 'Begin', 1 );
	my (@retVal) = ();
	my ( $domain, $entries, $referencedDomain, $fields ) = @_;
	my $res = $soap->getReferencedEntriesSet( SOAP::Data->name( 'domain' => $domain )->attr( { 'xmlns' => $serviceNamespace } ),
							                  SOAP::Data->name( 'entries' => \SOAP::Data->value(soap_to_arrayOfString( $entries ) ) )->attr( { 'xmlns' => $serviceNamespace } ), 
							                  SOAP::Data->name( 'referencedDomain' => $referencedDomain )->attr( { 'xmlns' => $serviceNamespace } ),						                  
							                  SOAP::Data->name( 'fields' => \SOAP::Data->value(soap_to_arrayOfString( $fields ) ) )->attr( { 'xmlns' => $serviceNamespace } ) );
	# To support SOAP::Lite 0.60, this uses SOAP::SOM rather than the 
	# valueof() hash structure.
	my (@idList) = $res->valueof('//getReferencedEntriesSetResponse/arrayOfEntryValues/EntryReferences/entry');
	print_debug_message( 'soap_get_referenced_entries_set', "idList:\n" . Dumper(\@idList), 11 );
	for(my $idNum = 0; $idNum < scalar(@idList); $idNum++) {
		my (%tmpEntry) = ('entry' => $idList[$idNum]);
		my $idNodeNum = $idNum + 1;
		my (@tmpRefList) = ();
		my (@refs) = $res->valueof("//getReferencedEntriesSetResponse/arrayOfEntryValues/[$idNodeNum]/references/*");
		print_debug_message( 'soap_get_referenced_entries_set', 'refs: ' . @refs, 11 );
		my $tmpObj = $res->match("//getReferencedEntriesSetResponse/arrayOfEntryValues/[$idNodeNum]/*");
		for(my $refNum = 0; $refNum < scalar(@refs); $refNum++) {
			my $refNodeNum = $refNum + 1;
			push(@tmpRefList, [$tmpObj->valueof("[$refNodeNum]/*")]);
		}
		$tmpEntry{'references'} = \@tmpRefList;
		push(@retVal, \%tmpEntry);
	}
	print_debug_message( 'soap_get_referenced_entries_set', "retVal:\n" . Dumper(\@retVal), 11 );
	print_debug_message( 'soap_get_referenced_entries_set', 'End', 1 );
	return @retVal;
}

=head2 soap_get_referenced_entries_flat_set()

Returns the list of referenced entries from a domain referenced in a set of 
entries. The result will be returned as a flat table corresponding to the 
list of results where, for each result, the first value is the original entry 
identifier and the other values correspond to the fields values. 

  my (@entry_list) = soap_get_referenced_entries_flat_set($domain, \@entry_id_list, $referenced_domain, \@fields);

=cut

sub soap_get_referenced_entries_flat_set {
	print_debug_message( 'soap_get_referenced_entries_flat_set', 'Begin', 1 );
	my ( $domain, $entries, $referencedDomain, $fields ) = @_;
	my $res = $soap->getReferencedEntriesFlatSet( SOAP::Data->name( 'domain' => $domain )->attr( { 'xmlns' => $serviceNamespace } ),
							                      SOAP::Data->name( 'entries' => \SOAP::Data->value(soap_to_arrayOfString( $entries ) ) )->attr( { 'xmlns' => $serviceNamespace } ), 
							                      SOAP::Data->name( 'referencedDomain' => $referencedDomain )->attr( { 'xmlns' => $serviceNamespace } ),						                  
							                      SOAP::Data->name( 'fields' => \SOAP::Data->value(soap_to_arrayOfString( $fields ) ) )->attr( { 'xmlns' => $serviceNamespace } ) );
	print_debug_message( 'soap_get_referenced_entries_flat_set', 'End', 1 );
	return &toNestedArray( '//arrayOfEntryValues', $res );
}

=head2 soap_get_domains_hierarchy()

Returns the hierarchy of the domains available.

  my $res = soap_get_domains_hierarchy();

=cut

sub soap_get_domains_hierarchy {
	print_debug_message( 'soap_get_domains_hierarchy', 'Begin', 1 );
	my $res = $soap->getDomainsHierarchy();
	print_debug_message( 'soap_get_domains_hierarchy', "res:\n" . Dumper($res), 21 );
	my $retVal = $res->valueof('//rootDomain');
	&_domain_description_to_hash($res, $retVal, '//rootDomain');
	print_debug_message( 'soap_get_domains_hierarchy', "retVal:\n" . Dumper($retVal), 21 );
	print_debug_message( 'soap_get_domains_hierarchy', 'End', 1 );
	return $retVal;
}

=head2 _domain_description_to_hash

Map a DomainDescription hierarchy into a set of nested hashes.

Used by soap_get_domains_hierarchy().

  &_domain_description_to_hash($soap_obj, \%parent_domain, $xpath);

=cut

sub _domain_description_to_hash {
	print_debug_message( '_domain_description_to_hash', 'Begin', 11 );
	my $soapObj = shift;
	my $parentDomain = shift;
	my $xpath = shift;
	print_debug_message( '_domain_description_to_hash', 'xpath: ' . $xpath, 12 );
	print_debug_message( '_domain_description_to_hash', "parentDomain:\n" . Dumper($parentDomain), 21 );
	my $tmpXpath = $xpath . '/subDomains/DomainDescription';
	print_debug_message( '_domain_description_to_hash', 'tmpXpath: ' . $tmpXpath, 21 );
	if($soapObj->valueof($tmpXpath) && scalar($soapObj->valueof($tmpXpath)) > 1) {
		my (@domainList) = $soapObj->valueof($tmpXpath);
		for(my $i = 0; $i < scalar(@domainList); $i++) {
			my $nodeNum = $i + 1;
			my $tmpXpath2 = $xpath . "/subDomains/[$nodeNum]";
			&_domain_description_to_hash($soapObj, $domainList[$i], $tmpXpath2);
		}
		$parentDomain->{'subDomains'}->{'DomainDescription'} = \@domainList;
	}
	print_debug_message( '_domain_description_to_hash', 'xpath: ' . $xpath, 12 );
	print_debug_message( '_domain_description_to_hash', 'End', 11 );
}

=head2 soap_get_detailled_number_of_results()

Executes a query and returns the number of results found per domain.

  my $res = soap_get_detailled_number_of_results($domain, $query_str, $flat);

=cut 

sub soap_get_detailled_number_of_results {
	print_debug_message( 'soap_get_detailled_number_of_results', 'Begin', 1 );
	my ( $domain, $query, $flat ) = @_;
	my $res = $soap->getDetailledNumberOfResults( SOAP::Data->name( 'domain' => $domain )->attr( { 'xmlns' => $serviceNamespace } ),
							                      SOAP::Data->name( 'query' => $query )->attr( { 'xmlns' => $serviceNamespace } ), 
							                      SOAP::Data->name( 'flat' => $flat )->type('xsi:boolean')->attr( { 'xmlns' => $serviceNamespace } ) );
	print_debug_message( 'soap_get_detailled_number_of_results', "res:\n" . Dumper($res), 21 );
	my $retVal = $res->valueof('//detailledNumberOfResults');
	&_domain_results_to_hash($res, $retVal, '//detailledNumberOfResults');
	print_debug_message( 'soap_get_detailled_number_of_results', "retVal:\n" . Dumper($retVal), 21 );
	print_debug_message( 'soap_get_detailled_number_of_results', 'End', 1 );
	return $retVal;
}

=head2 _domain_results_to_hash

Map a DomainResults hierarchy into a set of nested hashes.

Used by soap_get_detailled_number_of_results().

  &_domain_results_to_hash($soap_obj, \%parent_domain, $xpath);

=cut

sub _domain_results_to_hash {
	print_debug_message( '_domain_results_to_hash', 'Begin', 11 );
	my $soapObj = shift;
	my $parentDomain = shift;
	my $xpath = shift;
	print_debug_message( '_domain_results_to_hash', 'xpath: ' . $xpath, 12 );
	print_debug_message( '_domain_results_to_hash', "parentDomain:\n" . Dumper($parentDomain), 21 );
	my $tmpXpath = $xpath . '/subDomainsResults/DomainResult';
	print_debug_message( '_domain_results_to_hash', 'tmpXpath: ' . $tmpXpath, 21 );
	if($soapObj->valueof($tmpXpath) && scalar($soapObj->valueof($tmpXpath)) > 1) {
		my (@domainList) = $soapObj->valueof($tmpXpath);
		for(my $i = 0; $i < scalar(@domainList); $i++) {
			my $nodeNum = $i + 1;
			my $tmpXpath2 = $xpath . "/subDomainsResults/[$nodeNum]";
			&_domain_results_to_hash($soapObj, $domainList[$i], $tmpXpath2);
		}
		$parentDomain->{'subDomainsResults'}->{'DomainResult'} = \@domainList;
	}
	print_debug_message( '_domain_results_to_hash', 'xpath: ' . $xpath, 12 );
	print_debug_message( '_domain_results_to_hash', 'End', 11 );
}


=head2 soap_list_fields_information()

Returns the list of fields that can be retrieved and/or searched for a 
particular domain.

  my (@field_info_list) = soap_list_fields_information($domain);

=cut

sub soap_list_fields_information {
	print_debug_message( 'soap_list_fields_information', 'Begin', 1 );
	my $domain = shift;
	my $res = $soap->listFieldsInformation( SOAP::Data->name( 'domain' => $domain )->attr( { 'xmlns' => $serviceNamespace } ) );
	print_debug_message( 'soap_list_fields_information', 'End', 1 );
	return $res->valueof('//arrayOfFieldInformation/FieldInfo');
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
	$ua->agent( &get_agent_string() . $ua->agent() ); # User-agent.
	$ua->env_proxy; # HTTP proxy.
	my $can_accept; # Available message encodings.
	eval {
	    $can_accept = HTTP::Message::decodable();
	};
	$can_accept = '' unless defined($can_accept);
	while(scalar(@retVal) != 2 && $fetchAttemptCount < MAX_RETRIES) {
		# Fetch WSDL document.
		my $response = $ua->get($WSDL, 
			'Accept-Encoding' => $can_accept, # HTTP compression.
		);
		if ( $params{'trace'} ) { # Request/response trace.
			print( $response->request()->as_string(), "\n" );
			print( $response->as_string(), "\n" );
		}
		# Unpack possibly compressed response.
		if ( defined($can_accept) && $can_accept ne '') {
	    	$wsdlStr = $response->decoded_content();
		}
		# If unable to decode use orginal content.
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

=head2 toNestedArray()

Convert an ArrayOfArrayOfString result into a nested array

  my (@array) = toNestedArray($xpath, $obj);

=cut

sub toNestedArray {
	print_debug_message( 'toNestedArray', 'Begin', 11 );
	my ( $xpath, $obj ) = @_;
	print_debug_message( 'toNestedArray', 'xpath: ' . $xpath, 12 );
	print_debug_message( 'toNestedArray', "obj:\n" . Dumper($obj), 13 );
	my (@returnArray) = ();
	my (@tmpArray)    = $obj->dataof("$xpath/ArrayOfString");
	print_debug_message( 'toNestedArray', "scalar(tmpArray): " . scalar(@tmpArray), 11 );
	print_debug_message( 'toNestedArray', "tmpArray:\n" . Dumper(\@tmpArray), 13 );
	if($SOAP::Lite::VERSION > 0.60) {
		# SOAP::Lite recent versions... simplify the data structure by 
		# removing a layer of nesting. 
		foreach my $item (@tmpArray) {
			print_debug_message( 'toNestedArray', 'item: ' . $item, 12 );
			my $itemValueRef = ref($item->value());
			my $itemValue = undef;
			if($itemValueRef eq 'REF') {
				my (@tmpArray2) = ();
				my (@subArray) = ${$item->value()}->value();
				print_debug_message( 'toNestedArray', 'scalar(subArray): ' . scalar(@subArray), 12 );
				foreach my $tmpItem (@subArray) {
					push @tmpArray2, $tmpItem->value();
				}
				push(@returnArray, \@tmpArray2);
			}
			else {
				push @returnArray, $item->value()->{'string'};
			}
		}
	}
	else {
		# SOAP::Lite 0.60 doesn't handle dataof() in the same way so an 
		# alternative method needs to be used. Instead assume the sub-lists 
		# are all the same length and split the leaf nodes between the lists 
		# evenly.
		my (@tmpArray1) = $obj->valueof("$xpath/ArrayOfString/string");
		print_debug_message( 'toNestedArray', "tmpArray1:\n" . Dumper(\@tmpArray1), 13 );
		my $numChildItems = scalar(@tmpArray1) / scalar(@tmpArray);
		my $childNum = 0;
		foreach my $parent (@tmpArray) {
			my (@tmpArray2) = ();
			for(my $i =0; $i < $numChildItems; $i++) {
				push(@tmpArray2, $tmpArray1[$childNum]);
				$childNum++;
			}
			push(@returnArray, \@tmpArray2);
		}
	}
	print_debug_message( 'toNestedArray', "returnArray:\n" . Dumper(\@returnArray), 12 );
	print_debug_message( 'toNestedArray', 'End', 11 );
	return \@returnArray;
}

=head2 print_list_domains()

Print the list of domains available in EB-eye.

  &print_list_domains();

=cut

sub print_list_domains {
	print_debug_message( 'print_list_domains', 'Begin', 1 );
	my (@domainNameList) = soap_list_domains();
	foreach my $domainName (@domainNameList) {
		print $domainName, "\n";
	}
	print_debug_message( 'print_list_domains', 'End', 1 );
}

=head2 print_get_number_of_results()

Print the number of results found for a query.

  &print_get_number_of_results($domain, $query_str);

=cut

sub print_get_number_of_results {
	print_debug_message( 'print_get_number_of_results', 'Begin', 1 );
	my $domain = shift;
	my $query  = shift;
	print soap_get_number_of_results( $domain, $query ), "\n";
	print_debug_message( 'print_get_number_of_results', 'End', 1 );
}

=head2 print_get_results_ids()

Print identifiers of results found.

  &print_get_results_ids($domain, $query_str, $start, $size);

=cut

sub print_get_results_ids {
	print_debug_message( 'print_get_results_ids', 'Begin', 1 );
	my ( $domain, $query, $start, $size ) = @_;
	my (@idList) = soap_get_results_ids( $domain, $query, $start, $size );
	foreach my $id (@idList) {
		print $id, "\n";
	}
	print_debug_message( 'print_get_results_ids', 'End', 1 );
}

=head2 print_get_all_results_ids()

Print identifiers of all results found.

  &print_get_all_results_ids($domain, $query_str);

=cut

sub print_get_all_results_ids {
	print_debug_message( 'print_get_all_results_ids', 'Begin', 1 );
	my ( $domain, $query ) = @_;
	my (@idList) = soap_get_all_results_ids( $domain, $query );
	foreach my $id (@idList) {
		print $id, "\n";
	}
	print_debug_message( 'print_get_all_results_ids', 'End', 1 );
}

=head2 print_list_fields()

Print retrievable fields available for a domain.

  &print_list_fields($domain);

=cut

sub print_list_fields {
	print_debug_message( 'print_list_fields', 'Begin', 1 );
	my $domain = shift;
	my (@fieldNameList) = soap_list_fields($domain);
	foreach my $fieldName (@fieldNameList) {
		print $fieldName, "\n";
	}
	print_debug_message( 'print_list_fields', 'End', 1 );
}

=head2 print_get_results()

Print query results.

  &print_get_results($domain, $query_str, \@fields, $start, $size)

=cut

sub print_get_results {
	print_debug_message( 'print_get_results', 'Begin', 1 );
	my ( $domain, $query, $fields, $start, $size ) = @_;
	my $resultList =
	  soap_get_results( $domain, $query, $fields, $start, $size );
	foreach my $entry (@$resultList) {
		if(ref($entry) eq 'ARRAY') {
			foreach my $field (@$entry) {
				if(defined($field)) {
					print $field, "\n";
				} else {
					print "\n";
				}
			}
		}
		else {
			if(defined($entry)) {
				print $entry, "\n";
			} else {
				print "\n";
			}
		}
	}
	print_debug_message( 'print_get_results', 'End', 1 );
}

=head2 print_get_entry()

Print an entry.

  &print_get_entry($domain, $query_str, \@fields)

=cut

sub print_get_entry {
	print_debug_message( 'print_get_entry', 'Begin', 1 );
	my ( $domain, $query, $fields ) = @_;
	my (@fieldDataArray) = soap_get_entry( $domain, $query, $fields );
	foreach my $fieldData (@fieldDataArray) {
		if(defined($fieldData)) {
			print $fieldData, "\n";
		} else {
			print "\n";
		}
	}
	print_debug_message( 'print_get_entry', 'End', 1 );
}

=head2 print_get_entries()

Print a set of entries.

  &print_get_entries($domain, \@entry_id_list, \@fields);

=cut

sub print_get_entries {
	print_debug_message( 'print_get_entries', 'Begin', 1 );
	my ( $domain, $entries, $fields ) = @_;
	my $entryList = soap_get_entries( $domain, $entries, $fields );
	foreach my $entry (@$entryList) {
		foreach my $field (@$entry) {
			if(defined($field)) {
				print $field, "\n";
			} else {
				print "\n";
			}
		}
	}
	print_debug_message( 'print_get_entries', 'End', 1 );
}

=head2 print_get_entry_field_urls()

Print URLs for fields in an entry.

  &print_get_entry_field_urls($domain, $entry_id, \@fields);

=cut

sub print_get_entry_field_urls {
	print_debug_message( 'print_get_entry_field_urls', 'Begin', 1 );
	my ( $domain, $entry, $fields ) = @_;
	my (@urlList) = soap_get_entry_field_urls( $domain, $entry, $fields );
	foreach my $url (@urlList) {
		print $url if defined($url);
		print "\n";
	}
	print_debug_message( 'print_get_entry_field_urls', 'End', 1 );
}

=head2 print_get_entries_field_urls()

Print URLs for fields in a set of entries.

  &print_get_entries_field_urls($domain, \@entry_id_list, \@fields);

=cut

sub print_get_entries_field_urls {
	print_debug_message( 'print_get_entries_field_urls', 'Begin', 1 );
	my ( $domain, $entries, $fields ) = @_;
	my $entryList = soap_get_entries_field_urls( $domain, $entries, $fields );
	foreach my $entry (@$entryList) {
		if(ref($entry) eq 'ARRAY') {
			foreach my $url (@$entry) {
				print $url if defined($url);
				print "\n";
			}
		}
		else {
			print $entry, "\n";
		}
	}
	print_debug_message( 'print_get_entries_field_urls', 'End', 1 );
}

=head2 print_get_domains_referenced_in_domain()

Print EB-eye domains cross-references by a domain.

  &print_get_domains_referenced_in_domain($domain);

=cut

sub print_get_domains_referenced_in_domain {
	print_debug_message( 'print_get_domains_referenced_in_domain', 'Begin', 1 );
	my $domain = shift;
	my (@domainNameList) = soap_get_domains_referenced_in_domain($domain);
	foreach my $domainName (@domainNameList) {
		print $domainName, "\n";
	}
	print_debug_message( 'print_get_domains_referenced_in_domain', 'End', 1 );
}

=head2 print_get_domains_referenced_in_entry()

Print EB-eye domains cross-referenced in an entry.

  &print_get_domains_referenced_in_entry($domain, $entry_id);

=cut

sub print_get_domains_referenced_in_entry {
	print_debug_message( 'print_get_domains_referenced_in_entry', 'Begin', 1 );
	my $domain = shift;
	my $entry  = shift;
	my (@domainNameList) =
	  soap_get_domains_referenced_in_entry( $domain, $entry );
	foreach my $domainName (@domainNameList) {
		print $domainName, "\n";
	}
	print_debug_message( 'print_get_domains_referenced_in_entry', 'End', 1 );
}

=head2 print_list_additional_reference_fields()

Print cross-reference fields which do not point to an EB-eye domain.  

  &print_list_additional_reference_fields($domain);

=cut

sub print_list_additional_reference_fields {
	print_debug_message( 'print_list_additional_reference_fields', 'Begin', 1 );
	my $domain = shift;
	my (@fieldNameList) = soap_list_additional_reference_fields($domain);
	foreach my $fieldName (@fieldNameList) {
		print $fieldName, "\n";
	}
	print_debug_message( 'print_list_additional_reference_fields', 'End', 1 );
}

=head2 print_get_referenced_entries()

Print the set of entries referenced by an entry.

  &print_get_referenced_entries($domain, $entry_id, $referenced_domain);

=cut

sub print_get_referenced_entries {
	print_debug_message( 'print_get_referenced_entries', 'Begin', 1 );
	my ( $domain, $entry, $referencedDomain ) = @_;
	my (@entryIdList) =
	  soap_get_referenced_entries( $domain, $entry, $referencedDomain );
	foreach my $entryId (@entryIdList) {
		print $entryId, "\n";
	}
	print_debug_message( 'print_get_referenced_entries', 'End', 1 );
}

=head2 print_get_referenced_entries_set()

Print the set of entries referenced by a set of entries.

  &print_get_referenced_entries_set($domain, \@entry_id_list, $referenced_domain, \@fields);

=cut

sub print_get_referenced_entries_set {
	print_debug_message( 'print_get_referenced_entries_set', 'Begin', 1 );
	my ( $domain, $entries, $referencedDomain, $fields ) = @_;
	my (@entry_list) = soap_get_referenced_entries_set($domain, $entries, $referencedDomain, $fields);
	foreach my $entry (@entry_list) {
		print $entry->{'entry'}, "\n";
		foreach my $xref (@{$entry->{'references'}}) {
			foreach my $xref_field (@{$xref}) {
				print "\t", $xref_field;
			}
			print "\n";
		}
		print "\n";
	}
	print_debug_message( 'print_get_referenced_entries_set', 'End', 1 );
}

=head2 print_get_referenced_entries_flat_set()

Print the set of entries referenced by a set of entries, flattened.

  &print_get_referenced_entries_flat_set($domain, \@entry_id_list, $referenced_domain, \@fields);

=cut

sub print_get_referenced_entries_flat_set {
	print_debug_message( 'print_get_referenced_entries_flat_set', 'Begin', 1 );
	my ( $domain, $entries, $referencedDomain, $fields ) = @_;
	my $entryList = soap_get_referenced_entries_flat_set( $domain, $entries,
		$referencedDomain, $fields );
	foreach my $entry (@$entryList) {
		foreach my $fieldData (@$entry) {
			print $fieldData, "\t";
		}
		print "\n";
	}
	print_debug_message( 'print_get_referenced_entries_flat_set', 'Begin', 1 );
}

=head2 print_get_domains_hierarchy()

Print hierarchy of EB-eye domains.

  &print_get_domains_hierarchy();

=cut

sub print_get_domains_hierarchy {
	print_debug_message( 'print_get_domains_hierarchy', 'Begin', 1 );
	my $res = soap_get_domains_hierarchy();
	print_debug_message( 'print_get_domains_hierarchy', "res:\n" . Dumper($res), 21 );
	print_domain_description($res, 0);
	print_debug_message( 'print_get_domains_hierarchy', 'End', 1 );
}

=head2 print_domain_description()

Recursive method used to print domain hierarchy.

  &print_domain_description($domain_description, $level);

=cut

sub print_domain_description {
	print_debug_message( 'print_domains_description', 'Begin', 21 );
	my $domainDes = shift;
	my $level = shift;
	my $indent = '';
	for(my $i = 0; $i < $level; $i++) {
		$indent .= "\t";
	}
	$level++;
	print $indent, $domainDes->{'id'}, ' : ', $domainDes->{'name'}, "\n";
	if(defined($domainDes->{'subDomains'} && defined($domainDes->{'subDomains'}->{'DomainDescription'}))) {
		if(ref($domainDes->{'subDomains'}) ne '') {
			if(ref($domainDes->{'subDomains'}->{'DomainDescription'}) eq 'ARRAY') {
				foreach my $subDomainDes (@{$domainDes->{'subDomains'}->{'DomainDescription'}}) {
					&print_domain_description($subDomainDes, $level);
				}
			}
			else {
				&print_domain_description($domainDes->{'subDomains'}->{'DomainDescription'}, $level);
			}
		}
	}
	print_debug_message( 'print_domains_description', 'End', 21 );
}

=head2 print_get_detailled_number_of_results()

Print query results for each domain in the search.

  &print_get_detailled_number_of_results($domain, $query_str, $flat)

=cut

sub print_get_detailled_number_of_results {
	print_debug_message( 'print_get_detailled_number_of_results', 'Begin', 1 );
	my ( $domain, $query, $flat ) = @_;
	my $res = soap_get_detailled_number_of_results( $domain, $query, $flat );
	print_domain_result($res, 0);
	print_debug_message( 'print_get_detailled_number_of_results', 'End', 1 );
}

=head2 print_domain_result()

Recursive method used to print detailed results.

  &print_domain_result($domain_result, $level);

=cut

sub print_domain_result {
	print_debug_message( 'print_domain_result', 'Begin', 1 );
	my $domainResult = shift;
	my $level = shift;
	my $indent = '';
	for(my $i = 0; $i < $level; $i++) {
		$indent .= "\t";
	}
	$level++;
	print $indent, $domainResult->{'domainId'}, ' : ', $domainResult->{'numberOfResults'}, "\n";
	if(defined($domainResult->{'subDomainsResults'} && defined($domainResult->{'subDomainsResults'}->{'DomainResult'}))) {
		if(ref($domainResult->{'subDomainsResults'}) ne '') {
			if(ref($domainResult->{'subDomainsResults'}->{'DomainResult'}) eq 'ARRAY') {
				foreach my $subDomainResult (@{$domainResult->{'subDomainsResults'}->{'DomainResult'}}) {
					print_domain_result($subDomainResult, $level);
				}
			}
			else {
				print_domain_result($domainResult->{'subDomainsResults'}->{'DomainResult'}, $level);
			}
		}
	}
	print_debug_message( 'print_domain_result', 'End', 1 );
}

=head2 print_list_fields_information()

Print detailed information about the fields for a domain.

  &print_list_fields_information($domain);

=cut

sub print_list_fields_information {
	print_debug_message( 'print_list_fields_information', 'Begin', 1 );
	my $domain = shift;
	my (@field_info_list) = soap_list_fields_information($domain);
	foreach my $field_info (@field_info_list) {
		#print Dumper($field_info);
		print $field_info->{'id'}, "\t", $field_info->{'name'}, "\t";
		print $field_info->{'description'} if(defined($field_info->{'description'}));
		print "\t", $field_info->{'searchable'}, "\t", $field_info->{'retrievable'};
		print "\n";
	}
	print_debug_message( 'print_list_fields_information', 'End', 1 );
}

=head2 soap_to_arrayOfString()

Converts an array of plain strings in the suitable XML representation for 
<string xsi:type="xsd:string">x</string>
<string xsi:type="xsd:string">y</string>
...
according to WSDL definition of ArrayOfString
<xsd:complexType name="ArrayOfString">
	<xsd:sequence>
		<xsd:element maxOccurs="unbounded" minOccurs="0" name="string" nillable="true" type="xsd:string"/>
	</xsd:sequence>
</xsd:complexType>

  my (@arrayOfString) = soap_to_arrayOfString(@items);

=cut

sub soap_to_arrayOfString {
	my ( $items ) = @_;
	
	my (@stringArray) = ();
	foreach my $item (@$items) {
		push ( @stringArray, SOAP::Data->type( 'string' => $item)->name('string') );
	}
	return @stringArray;
}

=head2 usage()

Print program usage.

  &usage();

=cut

sub usage {
	print STDERR <<EOF
EB-eye
======

--listDomains
  Returns a list of all the domains identifiers which can be used in a query.

--getNumberOfResults <domain> <query>
  Executes a query and returns the number of results found.

--getResultsIds <domain> <query> <start> <size>
  Executes a query and returns the list of identifiers for the entries found.

--getAllResultsIds <domain> <query>
  Executes a query and returns the list of all the identifiers for the entries
  found. 

--listFields <domain>
  Returns the list of fields that can be retrieved for a particular domain.

--getResults <domain> <query> <fields> <start> <size>
  Executes a query and returns a list of results. Each result contains the 
  values for each field specified in the "fields" argument in the same order 
  as they appear in the "fields" list.
 
--getEntry <domain> <entry> <fields>
  Search for a particular entry in a domain and returns the values for some 
  of the fields of this entry. The result contains the values for each field 
  specified in the "fields" argument in the same order as they appear in the 
  "fields" list.
 
--getEntries <domain> <entries> <fields>
  Search for entries in a domain and returns the values for some of the 
  fields of these entries. The result contains the values for each field 
  specified in the "fields" argument in the same order as they appear in the 
  "fields" list. 

--getEntryFieldUrls <domain> <entry> <fields>
  Search for a particular entry in a domain and returns the urls configured 
  for some of the fields of this entry. The result contains the urls for each 
  field specified in the "fields" argument in the same order as they appear 
  in the "fields" list. 

--getEntriesFieldUrls <domain> <entries> <fields>
  Search for a list of entries in a domain and returns the urls configured for
  some of the fields of these entries. Each result contains the url for each 
  field specified in the "fields" argument in the same order as they appear in
  the "fields" list. 

--getDomainsReferencedInDomain <domain>
  Returns the list of domains with entries referenced in a particular domain. 
  These domains are indexed in the EB-eye. 

--getDomainsReferencedInEntry <domain> <entry>
  Returns the list of domains with entries referenced in a particular domain 
  entry. These domains are indexed in the EB-eye. 

--listAdditionalReferenceFields <domain>
  Returns the list of fields corresponding to databases referenced in the 
  domain but not included as a domain in the EB-eye. 
  
--getReferencedEntries <domain> <entry> <referencedDomain>
  Returns the list of referenced entry identifiers from a domain referenced 
  in a particular domain entry. 
  
--getReferencedEntriesSet <domain> <entries> <referencedDomain> <fields>
  Returns the list of referenced entries from a domain referenced in a set of
  entries. The result will be returned as a list of objects, each representing
  an entry reference.

--getReferencedEntriesFlatSet <domain> <entries> <referencedDomain> <fields>
  Returns the list of referenced entries from a domain referenced in a set of 
  entries. The result will be returned as a flat table corresponding to the 
  list of results where, for each result, the first value is the original 
  entry identifier and the other values correspond to the fields values. 

--getDomainsHierarchy
  Returns the hierarchy of the domains available.

--getDetailledNumberOfResults <domain> <query> <flat>
  Executes a query and returns the number of results found per domain.

--listFieldsInformation <domain>
  Returns the list of fields that can be retrievedand/or searched for a 
  particular domain. 

Further information:

  http://www.ebi.ac.uk/Tools/webservices/services/eb-eye
  http://www.ebi.ac.uk/Tools/webservices/tutorials/perl

Support/Feedback:

  http://www.ebi.ac.uk/support/

EOF
}

=head1 FEEDBACK/SUPPORT

Please contact us at L<http://www.ebi.ac.uk/support/> if you have any 
feedback, suggestions or issues with the service or this client.

=cut
