#!/usr/bin/env perl
# $Id$
# ======================================================================
# EB-eye SOAP client using SOAP::Lite
#
# Tested with:
#   SOAP::Lite 0.60 and Perl 5.8.3
#   SOAP::Lite 0.69 and Perl 5.8.8
#   SOAP::Lite 0.71 and Perl 5.8.8
#   SOAP::Lite 0.710.08 and Perl 5.10.0 (Ubuntu 9.04)
#
# See:
# http://www.ebi.ac.uk/Tools/webservices/services/eb-eye
# http://www.ebi.ac.uk/Tools/Webservices/tutorials/perl
# ======================================================================
# WSDL URL for service
#my $WSDL = 'http://www.ebi.ac.uk/ebisearch/service.ebi?wsdl';
my $NAMESPACE = 'http://webservice.ebinocle.ebi.ac.uk';
my $ENDPOINT  = 'http://www.ebi.ac.uk/ebisearch/service.ebi';

# Enable Perl warnings
use strict;
use warnings;

# Load libraries
use SOAP::Lite;
use Getopt::Long qw(:config no_ignore_case bundling);
use File::Basename;
use MIME::Base64;
use Data::Dumper;

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
	'getDetailledNumberOfResults'  => \$params{'getDetailledNumberOfResults'},
	'listFieldsInformation'       => \$params{'listFieldsInformation'},

	# Generic
	'quiet'        => \$params{'quiet'},         # Decrease output level
	'verbose'      => \$params{'verbose'},       # Increase output level
	'debugLevel=i' => \$params{'debugLevel'},    # Debug output level
	'trace'        => \$params{'trace'},         # SOAP message debug
	'endpoint=s'   => \$ENDPOINT,                # SOAP service endpoint
);

# Adjust output level for options
if ( $params{'verbose'} ) { $outputLevel++ }
if ( $params{'$quiet'} )  { $outputLevel-- }

# Get the script filename for use in usage messages
my $scriptName = basename( $0, () );

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

# In debug mode show the service endpoint being used.
&print_debug_message( 'MAIN', 'endpoint: ' . $ENDPOINT, 11 );

# Create the service interface, setting the fault handler to throw exceptions
my $soap = SOAP::Lite->proxy(
	$ENDPOINT,
	timeout => 6000,    # HTTP connection timeout
	     #proxy => ['http' => 'http://your.proxy.server/'], # HTTP proxy
  )->uri($NAMESPACE)->on_fault(

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

### Wrappers for SOAP operations ###

# listDomains()
sub soap_list_domains() {
	print_debug_message( 'soap_list_domains', 'Begin', 1 );
	my $domainList = $soap->listDomains();
	print_debug_message( 'soap_list_domains', 'End', 1 );
	return $domainList->valueof('//arrayOfDomainNames/string');
}

# getNumberOfResults(domain, query)
sub soap_get_number_of_results($$) {
	print_debug_message( 'soap_get_number_of_results', 'Begin', 1 );
	my $domain = shift;
	my $query  = shift;
	print_debug_message( 'soap_get_number_of_results', 'domain: ' . $domain,
		2 );
	print_debug_message( 'soap_get_number_of_results', 'query: ' . $query, 2 );
	my $res = $soap->getNumberOfResults( $domain, $query );
	print_debug_message( 'soap_get_number_of_results', 'End', 1 );
	return $res->valueof('//numberOfResults');
}

# getResultsIds(domain, query, start, size)
sub soap_get_results_ids($$$$) {
	print_debug_message( 'soap_get_results_ids', 'Begin', 1 );
	my ( $domain, $query, $start, $size ) = @_;
	print_debug_message( 'soap_get_results_ids', 'domain: ' . $domain, 2 );
	print_debug_message( 'soap_get_results_ids', 'query: ' . $query,   2 );
	print_debug_message( 'soap_get_results_ids', 'start: ' . $start,   2 );
	print_debug_message( 'soap_get_results_ids', 'size: ' . $size,     2 );
	my $res = $soap->getResultsIds( $domain, $query, $start, $size );
	print_debug_message( 'soap_get_results_ids', 'End', 1 );
	return $res->valueof('//arrayOfIds/string');
}

# getAllResultsIds(domain, query)
sub soap_get_all_results_ids($$) {
	print_debug_message( 'soap_get_all_results_ids', 'Begin', 1 );
	my ( $domain, $query ) = @_;
	print_debug_message( 'soap_get_all_results_ids', 'domain: ' . $domain, 2 );
	print_debug_message( 'soap_get_all_results_ids', 'query: ' . $query,   2 );
	my $res = $soap->getAllResultsIds( $domain, $query );
	print_debug_message( 'soap_get_all_results_ids', 'End', 1 );
	return $res->valueof('//arrayOfIds/string');
}

# listFields(domain)
sub soap_list_fields($) {
	print_debug_message( 'soap_list_fields', 'Begin', 1 );
	my $domain = shift;
	print_debug_message( 'soap_list_fields', 'domain: ' . $domain, 2 );
	my $res = $soap->listFields($domain);
	print_debug_message( 'soap_list_fields', 'End', 1 );
	return $res->valueof('//arrayOfFieldNames/string');
}

# getResults(domain, query, fields, start, size)
sub soap_get_results($$$$$) {
	print_debug_message( 'soap_get_results', 'Begin', 1 );
	my ( $domain, $query, $fields, $start, $size ) = @_;
	my $res = $soap->getResults( $domain, $query, $fields, $start, $size );
	print_debug_message( 'soap_get_results', 'End', 1 );
	return &toNestedArray( '//arrayOfEntryValues', $res );
}

# getEntry(domain, entry, fields)
sub soap_get_entry($$$) {
	print_debug_message( 'soap_get_entry', 'Begin', 1 );
	my ( $domain, $entry, $fields ) = @_;
	print_debug_message( 'soap_get_entry', 'domain: ' . $domain,          2 );
	print_debug_message( 'soap_get_entry', 'entry: ' . $entry,            2 );
	print_debug_message( 'soap_get_entry', "fields:\n" . Dumper($fields), 2 );
	my $res = $soap->getEntry( $domain, $entry, $fields );
	print_debug_message( 'soap_get_entry', 'End', 1 );
	return $res->valueof('//entryValues/string');
}

# getEntries(domain, entries, fields)
sub soap_get_entries($$$) {
	print_debug_message( 'soap_get_entries', 'Begin', 1 );
	my ( $domain, $entries, $fields ) = @_;
	print_debug_message( 'soap_get_entries', 'domain: ' . $domain, 2 );
	print_debug_message( 'soap_get_entries', "entries:\n" . Dumper($entries),
		2 );
	print_debug_message( 'soap_get_entries', "fields:\n" . Dumper($fields), 2 );
	my $res = $soap->getEntries( $domain, $entries, $fields );
	print_debug_message( 'soap_get_entries', 'End', 1 );
	return &toNestedArray( '//arrayOfEntryValues', $res );
}

# getEntryFieldUrls(domain, entry, fields)
sub soap_get_entry_field_urls($$$) {
	print_debug_message( 'soap_get_entry_field_urls', 'Begin', 1 );
	my ( $domain, $entry, $fields ) = @_;
	print_debug_message( 'soap_get_entry_field_urls', 'domain: ' . $domain, 2 );
	print_debug_message( 'soap_get_entry_field_urls', 'entry: ' . $entry,   2 );
	print_debug_message( 'soap_get_entry_field_urls',
		"fields:\n" . Dumper($fields), 2 );
	my $res = $soap->getEntryFieldUrls( $domain, $entry, $fields );
	print_debug_message( 'soap_get_entry_field_urls', 'End', 1 );
	return $res->valueof('//entryUrlsValues/string');
}

# getEntriesFieldUrls(domain, entries, fields)
sub soap_get_entries_field_urls($$$) {
	print_debug_message( 'soap_get_entries_field_urls', 'Begin', 1 );
	my ( $domain, $entries, $fields ) = @_;
	print_debug_message( 'soap_get_entries_field_urls', 'domain: ' . $domain,
		2 );
	print_debug_message( 'soap_get_entries_field_urls',
		"entries:\n" . Dumper($entries), 2 );
	print_debug_message( 'soap_get_entries_field_urls',
		"fields:\n" . Dumper($fields), 2 );
	my $res = $soap->getEntriesFieldUrls( $domain, $entries, $fields );
	print_debug_message( 'soap_get_entries_field_urls', 'End', 1 );
	return &toNestedArray( '//arrayOfEntryUrlsValues', $res );
}

# getDomainsReferencedInDomain(domain)
sub soap_get_domains_referenced_in_domain($) {
	print_debug_message( 'soap_get_domains_referenced_in_domain', 'Begin', 1 );
	my $domain = shift;
	print_debug_message( 'soap_get_domains_referenced_in_domain',
		'domain: ' . $domain, 2 );
	my $res = $soap->getDomainsReferencedInDomain($domain);
	print_debug_message( 'soap_get_domains_referenced_in_domain', 'End', 1 );
	return $res->valueof('//arrayOfDomainNames/string');
}

# getDomainsReferencedInEntry(domain, entry)
sub soap_get_domains_referenced_in_entry($$) {
	print_debug_message( 'soap_get_domains_referenced_in_entry', 'Begin', 1 );
	my $domain = shift;
	my $entry  = shift;
	print_debug_message( 'soap_get_domains_referenced_in_entry',
		'domain: ' . $domain, 2 );
	print_debug_message( 'soap_get_domains_referenced_in_entry',
		'entry: ' . $entry, 2 );
	my $res = $soap->getDomainsReferencedInEntry( $domain, $entry );
	print_debug_message( 'soap_get_domains_referenced_in_entry', 'End', 1 );
	return $res->valueof('//arrayOfDomainNames/string');
}

# listAdditionalReferenceFields(domain)
sub soap_list_additional_reference_fields($) {
	print_debug_message( 'soap_list_additional_reference_fields', 'Begin', 1 );
	my $domain = shift;
	my $res    = $soap->listAdditionalReferenceFields($domain);
	print_debug_message( 'soap_list_additional_reference_fields', 'End', 1 );
	return $res->valueof('//arrayOfFieldNames/string');
}

# getReferencedEntries(domain, entry, referencedDomain)
sub soap_get_referenced_entries($$$) {
	print_debug_message( 'soap_get_referenced_entries', 'Begin', 1 );
	my ( $domain, $entry, $referencedDomain ) = @_;
	my $res = $soap->getReferencedEntries( $domain, $entry, $referencedDomain );
	print_debug_message( 'soap_get_referenced_entries', 'End', 1 );
	return $res->valueof('//arrayOfEntryIds/string');
}

# getReferencedEntriesSet(domain, entries, referencedDomain, fields)
sub soap_get_referenced_entries_set($$$$) {
	print_debug_message( 'soap_get_referenced_entries_set', 'Begin', 1 );
	my ( $domain, $entries, $referencedDomain, $fields ) = @_;
	my $res =
	  $soap->getReferencedEntriesSet( $domain, $entries, $referencedDomain,
		$fields );
	print_debug_message( 'soap_get_referenced_entries_set', 'End', 1 );
	return $res;
}

# getReferencedEntriesFlatSet(domain, entries, referencedDomain, fields)
sub soap_get_referenced_entries_flat_set($$$$) {
	print_debug_message( 'soap_get_referenced_entries_flat_set', 'Begin', 1 );
	my ( $domain, $entries, $referencedDomain, $fields ) = @_;
	my $res =
	  $soap->getReferencedEntriesFlatSet( $domain, $entries, $referencedDomain,
		$fields );
	print_debug_message( 'soap_get_referenced_entries_flat_set', 'End', 1 );
	return &toNestedArray( '//arrayOfEntryValues', $res );
}

# getDomainsHierarchy()
sub soap_get_domains_hierarchy() {
	print_debug_message( 'soap_get_domains_hierarchy', 'Begin', 1 );
	my $res = $soap->getDomainsHierarchy();
	print_debug_message( 'soap_get_domains_hierarchy', 'End', 1 );
	return $res;
}

# getDetailledNumberOfResults(domain, query, flat)
sub soap_get_detailled_number_of_results($$$) {
	print_debug_message( 'soap_get_detailled_number_of_results', 'Begin', 1 );
	my ( $domain, $query, $flat ) = @_;
	my $res = $soap->getDetailledNumberOfResults( $domain, $query, $flat );
	print_debug_message( 'soap_get_detailled_number_of_results', 'End', 1 );
	return $res;
}

# listFieldsInformation(domain)
sub soap_list_fields_information($) {
	print_debug_message( 'soap_list_fields_information', 'Begin', 1 );
	my $domain = shift;
	my $res    = $soap->listFieldsInformation($domain);
	print_debug_message( 'soap_list_fields_information', 'End', 1 );
	return $res;
}

### Service actions and utility functions ###

# Print debug message
sub print_debug_message($$$) {
	my $function_name = shift;
	my $message       = shift;
	my $level         = shift;
	if ( $level <= $params{'debugLevel'} ) {
		print STDERR '[', $function_name, '()] ', $message, "\n";
	}
}

# Convert an ArrayOfArrayOfString result into a nested array
sub toNestedArray($$) {
	print_debug_message( 'toNestedArray', 'Begin', 11 );
	my ( $xpath, $obj ) = @_;
	my (@returnArray) = ();
	my (@tmpArray)    = $obj->dataof("$xpath/ArrayOfString");
	foreach my $item (@tmpArray) {
		push @returnArray, $item->value()->{'string'};
	}
	print_debug_message( 'toNestedArray', 'End', 11 );
	return \@returnArray;
}

# Print the list of domains available in EB-eye
sub print_list_domains() {
	print_debug_message( 'print_list_domains', 'Begin', 1 );
	my (@domainNameList) = soap_list_domains();
	foreach my $domainName (@domainNameList) {
		print $domainName, "\n";
	}
	print_debug_message( 'print_list_domains', 'End', 1 );
}

# Print the number of results found for a query
sub print_get_number_of_results($$) {
	print_debug_message( 'print_get_number_of_results', 'Begin', 1 );
	my $domain = shift;
	my $query  = shift;
	print soap_get_number_of_results( $domain, $query ), "\n";
	print_debug_message( 'print_get_number_of_results', 'End', 1 );
}

# Print identifiers of results found
sub print_get_results_ids($$$$) {
	print_debug_message( 'print_get_results_ids', 'Begin', 1 );
	my ( $domain, $query, $start, $size ) = @_;
	my (@idList) = soap_get_results_ids( $domain, $query, $start, $size );
	foreach my $id (@idList) {
		print $id, "\n";
	}
	print_debug_message( 'print_get_results_ids', 'End', 1 );
}

# Print identifiers of all results found
sub print_get_all_results_ids($$$$) {
	print_debug_message( 'print_get_all_results_ids', 'Begin', 1 );
	my ( $domain, $query ) = @_;
	my (@idList) = soap_get_all_results_ids( $domain, $query );
	foreach my $id (@idList) {
		print $id, "\n";
	}
	print_debug_message( 'print_get_all_results_ids', 'End', 1 );
}

# Print fields available for a domain
sub print_list_fields($) {
	print_debug_message( 'print_list_fields', 'Begin', 1 );
	my $domain = shift;
	my (@fieldNameList) = soap_list_fields($domain);
	foreach my $fieldName (@fieldNameList) {
		print $fieldName, "\n";
	}
	print_debug_message( 'print_list_fields', 'End', 1 );
}

# Print query results
sub print_get_results($$$$$) {
	print_debug_message( 'print_get_results', 'Begin', 1 );
	my ( $domain, $query, $fields, $start, $size ) = @_;
	my $resultList =
	  soap_get_results( $domain, $query, $fields, $start, $size );
	foreach my $entry (@$resultList) {
		foreach my $field (@$entry) {
			print $field, "\n";
		}
	}
	print_debug_message( 'print_get_results', 'End', 1 );
}

# Print an entry
sub print_get_entry($$$) {
	print_debug_message( 'print_get_entry', 'Begin', 1 );
	my ( $domain, $query, $fields ) = @_;
	my (@fieldDataArray) = soap_get_entry( $domain, $query, $fields );
	foreach my $fieldData (@fieldDataArray) {
		print $fieldData, "\n";
	}
	print_debug_message( 'print_get_entry', 'End', 1 );
}

# Print an entry
sub print_get_entries($$$) {
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

sub print_get_entry_field_urls($$$) {
	print_debug_message( 'print_get_entry_field_urls', 'Begin', 1 );
	my ( $domain, $entry, $fields ) = @_;
	my (@urlList) = soap_get_entry_field_urls( $domain, $entry, $fields );
	foreach my $url (@urlList) {
		print $url if defined($url);
		print "\n";
	}
	print_debug_message( 'print_get_entry_field_urls', 'End', 1 );
}

# Print an entry
sub print_get_entries_field_urls($$$) {
	print_debug_message( 'print_get_entries_field_urls', 'Begin', 1 );
	my ( $domain, $entries, $fields ) = @_;
	my $entryList = soap_get_entries_field_urls( $domain, $entries, $fields );
	foreach my $entry (@$entryList) {
		foreach my $url (@$entry) {
			print $url if defined($url);
			print "\n";
		}
	}
	print_debug_message( 'print_get_entries_field_urls', 'End', 1 );
}

sub print_get_domains_referenced_in_domain($) {
	print_debug_message( 'print_get_domains_referenced_in_domain', 'Begin', 1 );
	my $domain = shift;
	my (@domainNameList) = soap_get_domains_referenced_in_domain($domain);
	foreach my $domainName (@domainNameList) {
		print $domainName, "\n";
	}
	print_debug_message( 'print_get_domains_referenced_in_domain', 'End', 1 );
}

sub print_get_domains_referenced_in_entry($$) {
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

sub print_list_additional_reference_fields($) {
	print_debug_message( 'print_list_additional_reference_fields', 'Begin', 1 );
	my $domain = shift;
	my (@fieldNameList) = soap_list_additional_reference_fields($domain);
	foreach my $fieldName (@fieldNameList) {
		print $fieldName, "\n";
	}
	print_debug_message( 'print_list_additional_reference_fields', 'End', 1 );
}

sub print_get_referenced_entries($$$) {
	print_debug_message( 'print_get_referenced_entries', 'Begin', 1 );
	my ( $domain, $entry, $referencedDomain ) = @_;
	my (@entryIdList) =
	  soap_get_referenced_entries( $domain, $entry, $referencedDomain );
	foreach my $entryId (@entryIdList) {
		print $entryId, "\n";
	}
	print_debug_message( 'print_get_referenced_entries', 'End', 1 );
}

# TODO: print resulting tree.
sub print_get_referenced_entries_set($$$$) {
	print_debug_message( 'print_get_referenced_entries_set', 'Begin', 1 );
	my ( $domain, $entries, $referencedDomain, $fields ) = @_;
	print Dumper(
		soap_get_referenced_entries_set(
			$domain, $entries, $referencedDomain, $fields
		)
	);
	print_debug_message( 'print_get_referenced_entries_set', 'End', 1 );
}

sub print_get_referenced_entries_flat_set($$$$) {
	print_debug_message( 'print_get_referenced_entries_flat_set', 'Begin', 1 );
	my ( $domain, $entries, $referencedDomain, $fields ) = @_;
	my $entryList = soap_get_referenced_entries_flat_set( $domain, $entries,
		$referencedDomain, $fields );
	foreach my $entry (@$entryList) {
		foreach my $fieldData (@$entry) {
			print $fieldData, "\n";
		}
	}
	print_debug_message( 'print_get_referenced_entries_flat_set', 'Begin', 1 );
}

# TODO: print tree of domains
sub print_get_domains_hierarchy() {
	print_debug_message( 'print_get_domains_hierarchy', 'Begin', 1 );
	print Dumper( soap_get_domains_hierarchy() );
	print_debug_message( 'print_get_domains_hierarchy', 'Begin', 1 );
}

# TODO: print tree of domain results
sub print_get_detailled_number_of_results($$$) {
	print_debug_message( 'print_get_detailled_number_of_results', 'Begin', 1 );
	my ( $domain, $query, $flat ) = @_;
	print Dumper(
		soap_get_detailled_number_of_results( $domain, $query, $flat ) );
	print_debug_message( 'print_get_detailled_number_of_results', 'End', 1 );
}

# TODO: print field information objects
sub print_list_fields_information($) {
	print_debug_message( 'print_list_fields_information', 'Begin', 1 );
	my $domain = shift;
	print Dumper( soap_list_fields_information($domain) );
	print_debug_message( 'print_list_fields_information', 'End', 1 );
}

# Print program usage
sub usage {
	print STDERR <<EOF
EB-eye
======


EOF
}
