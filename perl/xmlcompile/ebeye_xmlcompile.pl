#!/usr/bin/env perl

=head1 NAME

ebeye_xmlcompile.pl

=head1 DESCRIPTION

EB-eye SOAP client using L<XML::Compile::SOAP>

Tested with:

=over

=item *
L<XML::Compile::SOAP> 0.77, L<XML::Compile> 0.94 and Perl 5.8.8 (Ubuntu 8.10)

=item *
L<XML::Compile::SOAP> 2.04, L<XML::Compile> 1.05 and Perl 5.10.0 (Ubuntu 9.04)

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
use XML::Compile;
use XML::Compile::WSDL11;
use XML::Compile::SOAP11;
use XML::Compile::Transport::SOAPHTTP;
use Getopt::Long qw(:config no_ignore_case bundling);
use File::Basename qw(basename);
use MIME::Base64;
use Data::Dumper;

# WSDL describing service
my $WSDL    = 'http://www.ebi.ac.uk/ebisearch/service.ebi?wsdl';

# Output level
my $outputLevel = 1;

# Chunk size for getting results
my $chunkSize = 100;

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
	'quiet'        => \$params{'quiet'},         # Decrease output level
	'verbose'      => \$params{'verbose'},       # Increase output level
	'debugLevel=i' => \$params{'debugLevel'},    # Debug output level
	'trace'        => \$params{'trace'},         # SOAP message debug
	'WSDL=s'       => \$WSDL,                    # SOAP service WSDL
);

# Adjust output level for options
if ( $params{'verbose'} ) { $outputLevel++ }
if ( $params{'$quiet'} )  { $outputLevel-- }

# Debug mode: SOAP::Lite version
&print_debug_message( 'MAIN', 'XML::Compile::SOAP: ' . $XML::Compile::SOAP::VERSION,
	1 );

# Debug mode: print the parameters
&print_debug_message( 'MAIN', "params:\n" . Dumper( \%params ), 11 );

# Get the script filename for use in usage messages
my $scriptName = basename( $0, () );

# Print usage and exit if requested
if ( $params{'help'} || $numOpts == 0 ) {
	&usage();
	exit(0);
}

# Debug mode: show the WSDL being used.
&print_debug_message( 'MAIN', 'WSDL: ' . $WSDL, 1 );

# Create service proxy for web service
&print_debug_message( 'MAIN', 'Create service proxy', 11 );
my $wsdlXml = XML::LibXML->new->parse_file($WSDL);
my $soapSrv = XML::Compile::WSDL11->new($wsdlXml);

# Compile service methods
&print_debug_message( 'MAIN', 'Compile operations from WSDL', 11 );
my (%soapOps);
foreach my $soapOp ( $soapSrv->operations ) {

	# XML::Compile::SOAP 2.x
	if ( $XML::Compile::SOAP::VERSION > 1.99 ) {
		&print_debug_message( 'MAIN', 'Operation: ' . $soapOp->name, 12 );

		# Allow nil elements to be skipped (needed for submission)
		$soapOps{ $soapOp->name } = $soapSrv->compileClient( $soapOp->name,
			interpret_nillable_as_optional => 1 );
	}

	# XML::Compile::SOAP 0.7x
	else {
		&print_debug_message( 'MAIN', 'Operation: ' . $soapOp->{operation},
			12 );
		$soapOps{ $soapOp->{operation} } =
		  $soapSrv->compileClient( $soapOp->{operation},
			interpret_nillable_as_optional => 1 );
	}
}

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

### Wrappers for SOAP operations ###

=head2 soap_request()

Generic wrapper for SOAP requests.

If SOAP trace ($params{'trace'}) is enabled the details of the SOAP messages 
exchanged will be output using &print_soap_trace().

  my $response = soap_request($service_method, \%method_params);

=cut

sub soap_request {
	&print_debug_message( 'soap_request', 'Begin', 11 );
	my $service_method = shift;    # Method name
	my $service_params = shift;    # Method parameters
	&print_debug_message( 'soap_request', 'service_method: ' . $service_method,
		12 );
	&print_debug_message( 'soap_request',
		'service_params: ' . Dumper($service_params), 21 );

	# Call the method
	my ( $response, $trace ) =
	  $soapOps{$service_method}->( 'parameters' => $service_params );
	if ( $params{'trace'} ) {
		&print_soap_trace($trace);
	}                              # SOAP message trace
	if ( $response->{'Fault'} ) {  # Check for server/SOAP fault
		die "Server fault: " . $response->{'Fault'}->{'faultstring'};
	}
	&print_debug_message( 'soap_request', 'response: ' . Dumper($response),
		21 );
	&print_debug_message( 'soap_request', 'End', 11 );
	return $response;
}

=head2 print_soap_trace()

Print SOAP request/response trace obtained when making a service request.

  &print_soap_trace($trace);

=cut

sub print_soap_trace {
	&print_debug_message( 'print_soap_trace', 'Begin', 11 );
	my $trace = shift;
	$trace->printTimings;
	$trace->printRequest;
	$trace->printResponse;
	&print_debug_message( 'print_soap_trace', 'End', 11 );
}

=head2 soap_list_domains()

Returns a list of all the domains identifiers which can be used in a query.

  my (@domain_name_list) = &soap_list_domains();

=cut

sub soap_list_domains {
	print_debug_message( 'soap_list_domains', 'Begin', 1 );
	my $response = &soap_request( 'listDomains', {} );
	my (@domainList) = @{ $response->{'parameters'}->{'arrayOfDomainNames'}->{'string'} };
	print_debug_message( 'soap_list_domains', 'End', 1 );
	return @domainList;
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
	my $response = &soap_request( 'getNumberOfResults', {'domain' => $domain, 'query' => $query_str} );
	print_debug_message( 'soap_get_number_of_results', 'End', 1 );
	return $response->{'parameters'}->{'numberOfResults'};
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
	my $response = &soap_request('getResultsIds', {'domain' => $domain, 'query' => $query, 'start' => $start, 'size' => $size});
	print_debug_message( 'soap_get_results_ids', 'End', 1 );
	return @{$response->{'parameters'}->{'arrayOfIds'}->{'string'}};
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
	my $response = &soap_request('getAllResultsIds', {'domain' => $domain, 'query' => $query});
	print_debug_message( 'soap_get_all_results_ids', 'End', 1 );
	return @{$response->{'parameters'}->{'arrayOfIds'}->{'string'}};
}

=head2 soap_list_fields()

Returns the list of fields that can be retrieved for a particular domain.

  my (@field_name_list) = soap_list_fields($domain);

=cut

sub soap_list_fields {
	print_debug_message( 'soap_list_fields', 'Begin', 1 );
	my $domain = shift;
	print_debug_message( 'soap_list_fields', 'domain: ' . $domain, 2 );
	my $response = &soap_request('listFields', {'domain' => $domain});
	print_debug_message( 'soap_list_fields', 'End', 1 );
	return @{$response->{'parameters'}->{'arrayOfFieldNames'}->{'string'}};
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
	my $response = &soap_request('getResults', {'domain' => $domain, 'query' => $query, 'fields' => {'string' => $fields}, 'start' => $start, 'size' => $size});
	print_debug_message( 'soap_get_results', "response:\n" . Dumper($response), 11 );
	my (@tmpArray) = ();
	foreach my $item (@{$response->{'parameters'}->{'arrayOfEntryValues'}->{'ArrayOfString'}}) {
		push(@tmpArray, $item->{'string'});
	}
	print_debug_message( 'soap_get_results', 'End', 1 );
	return \@tmpArray;
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
	my $response = &soap_request('getEntry', {'domain' => $domain, 'entry' => $entry, 'fields' => {'string' => $fields}});
	print_debug_message( 'soap_get_entry', 'End', 1 );
	return @{$response->{'parameters'}->{'entryValues'}->{'string'}};
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
	my $response = &soap_request('getEntries', {'domain' => $domain, 'entries' => {'string' => $entries}, 'fields' => {'string' => $fields}});
	print_debug_message( 'soap_get_entries', "response:\n" . Dumper($response), 11 );
	my (@tmpArray) = ();
	foreach my $item (@{$response->{'parameters'}->{'arrayOfEntryValues'}->{'ArrayOfString'}}) {
		push(@tmpArray, $item->{'string'});
	}
	print_debug_message( 'soap_get_entries', 'End', 1 );
	return \@tmpArray;
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
	my $response = &soap_request('getEntryFieldUrls', {'domain' => $domain, 'entry' => $entry, 'fields' => {'string' => $fields}});
	print_debug_message( 'soap_get_entry_field_urls', 'End', 1 );
	return @{$response->{'parameters'}->{'entryUrlsValues'}->{'string'}};
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
	my $response = &soap_request('getEntriesFieldUrls', {'domain' => $domain, 'entries' => {'string' => $entries}, 'fields' => {'string' => $fields}});
	print_debug_message( 'soap_get_entries', "response:\n" . Dumper($response), 11 );
	my (@tmpArray) = ();
	foreach my $item (@{$response->{'parameters'}->{'arrayOfEntryUrlsValues'}->{'ArrayOfString'}}) {
		push(@tmpArray, $item->{'string'});
	}
	print_debug_message( 'soap_get_entries_field_urls', 'End', 1 );
	return \@tmpArray;
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
	my $response = &soap_request('getDomainsReferencedInDomain', {'domain' => $domain});
	print_debug_message( 'soap_get_domains_referenced_in_domain', 'End', 1 );
	return @{$response->{'parameters'}->{'arrayOfDomainNames'}->{'string'}};
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
	my $response = &soap_request('getDomainsReferencedInEntry', {'domain' => $domain, 'entry' => $entry});
	print_debug_message( 'soap_get_domains_referenced_in_entry', 'End', 1 );
	return @{$response->{'parameters'}->{'arrayOfDomainNames'}->{'string'}};
}

=head2 soap_list_additional_reference_fields()

Returns the list of fields corresponding to databases referenced in the 
domain but not included as a domain in the EB-eye. 

  my (@field_list) = soap_list_additional_reference_fields($domain);

=cut

sub soap_list_additional_reference_fields {
	print_debug_message( 'soap_list_additional_reference_fields', 'Begin', 1 );
	my $domain = shift;
	my $response = &soap_request('listAdditionalReferenceFields', {'domain' => $domain});
	print_debug_message( 'soap_list_additional_reference_fields', 'End', 1 );
	return @{$response->{'parameters'}->{'arrayOfFieldNames'}->{'string'}};
}

=head2 soap_get_referenced_entries()

Returns the list of referenced entry identifiers from a domain referenced in 
a particular domain entry.

  my (@entry_id_list) = soap_get_referenced_entries($domain, $entry_id, $referenced_domain);

=cut

sub soap_get_referenced_entries {
	print_debug_message( 'soap_get_referenced_entries', 'Begin', 1 );
	my ( $domain, $entry, $referencedDomain ) = @_;
	my $response = &soap_request('getReferencedEntries', {'domain' => $domain, 'entry' => $entry, 'referencedDomain' => $referencedDomain});
	print_debug_message( 'soap_get_referenced_entries', 'End', 1 );
	return @{$response->{'parameters'}->{'arrayOfEntryIds'}->{'string'}};
}

=head2 soap_get_referenced_entries_set()

Returns the list of referenced entries from a domain referenced in a set of 
entries. The result will be returned as a list of objects, each representing 
an entry reference. 

  my (@entry_list) = soap_get_referenced_entries_set($domain, \@entry_id_list, $referenced_domain, \@fields);

=cut

# TODO: object conversion to use display code unchanged.
sub soap_get_referenced_entries_set {
	print_debug_message( 'soap_get_referenced_entries_set', 'Begin', 1 );
	my (@retVal) = ();
	my ( $domain, $entries, $referencedDomain, $fields ) = @_;
	my $response = &soap_request('getReferencedEntriesSet', {'domain' => $domain, 'entries' => {'string' => $entries}, 'referencedDomain' => $referencedDomain, 'fields' => {'string' => $fields}});
	print_debug_message( 'soap_get_referenced_entries_set', "response:\n" . Dumper($response), 11 );
	print_debug_message( 'soap_get_referenced_entries_set', 'End', 1 );
	return @{$response->{'parameters'}->{'arrayOfEntryValues'}->{'EntryReferences'}};
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
	my $response = &soap_request('getReferencedEntriesFlatSet', {'domain' => $domain, 'entries' => {'string' => $entries}, 'referencedDomain' => $referencedDomain, 'fields' => {'string' => $fields}});
	print_debug_message( 'soap_get_referenced_entries_flat_set', "response:\n" . Dumper($response), 11 );
	my (@tmpArray) = ();
	foreach my $item (@{$response->{'parameters'}->{'arrayOfEntryValues'}->{'ArrayOfString'}}) {
		push(@tmpArray, $item->{'string'});
	}
	print_debug_message( 'soap_get_referenced_entries_flat_set', 'End', 1 );
	return \@tmpArray;
}

=head2 soap_get_domains_hierarchy()

Returns the hierarchy of the domains available.

  my $res = soap_get_domains_hierarchy();

=cut

sub soap_get_domains_hierarchy {
	print_debug_message( 'soap_get_domains_hierarchy', 'Begin', 1 );
	my $response = &soap_request('getDomainsHierarchy', {});
	print_debug_message( 'soap_get_domains_hierarchy', "response:\n" . Dumper($response), 11 );
	print_debug_message( 'soap_get_domains_hierarchy', 'End', 1 );
	return $response->{'parameters'}->{'rootDomain'};
}

=head2 soap_get_detailled_number_of_results()

Executes a query and returns the number of results found per domain.

  my $res = soap_get_detailled_number_of_results($domain, $query_str, $flat);

=cut 

sub soap_get_detailled_number_of_results {
	print_debug_message( 'soap_get_detailled_number_of_results', 'Begin', 1 );
	my ( $domain, $query, $flat ) = @_;
	my $response = &soap_request('getDetailledNumberOfResults', {'domain' => $domain, 'query' => $query, 'flat' => $flat});
	print_debug_message( 'soap_get_detailled_number_of_results', "response:\n" . Dumper($response), 11 );
	print_debug_message( 'soap_get_detailled_number_of_results', 'End', 1 );
	return $response->{'parameters'}->{'detailledNumberOfResults'};
}

=head2 soap_list_fields_information()

Returns the list of fields that can be retrieved and/or searched for a 
particular domain.

  my (@field_info_list) = soap_list_fields_information($domain);

=cut

sub soap_list_fields_information {
	print_debug_message( 'soap_list_fields_information', 'Begin', 1 );
	my $domain = shift;
	my $response = &soap_request('listFieldsInformation', {'domain' => $domain});
	print_debug_message( 'soap_list_fields_information', "response:\n" . Dumper($response), 11 );
	print_debug_message( 'soap_list_fields_information', 'End', 1 );
	return @{$response->{'parameters'}->{'arrayOfFieldInformation'}->{'FieldInfo'}};
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
				print $field, "\n";
			}
		}
		else {
			print $entry, "\n";
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
		print $fieldData, "\n";
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
			print $field, "\n";
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
	if(defined($domainDes->{'subDomains'}) && $domainDes->{'subDomains'} ne 'NIL' && defined($domainDes->{'subDomains'}->{'DomainDescription'})) {
		if(ref($domainDes->{'subDomains'}->{'DomainDescription'}) eq 'ARRAY') {
			foreach my $subDomainDes (@{$domainDes->{'subDomains'}->{'DomainDescription'}}) {
				&print_domain_description($subDomainDes, $level);
			}
		}
		else {
			&print_domain_description($domainDes->{'subDomains'}->{'DomainDescription'}, $level);
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
	if(defined(	$domainResult->{'subDomainsResults'}) && $domainResult->{'subDomainsResults'} ne 'NIL' && defined($domainResult->{'subDomainsResults'}->{'DomainResult'}) ) {
		if(ref($domainResult->{'subDomainsResults'}->{'DomainResult'}) eq 'ARRAY') {
			foreach my $subDomainResult (@{$domainResult->{'subDomainsResults'}->{'DomainResult'}}) {
				print_domain_result($subDomainResult, $level);
			}
		}
		else {
			print_domain_result($domainResult->{'subDomainsResults'}->{'DomainResult'}, $level);
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

--getDetailledNumberOfResult <domain> <query> <flat>
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
