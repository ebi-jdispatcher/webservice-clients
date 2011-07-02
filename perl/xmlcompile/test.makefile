# $Id$
# ======================================================================
#
# Test sample SOAP::Lite clients run.
#
# ======================================================================

PERL = perl
#PERL = /ebi/extserv/bin/perl/bin/perl
#PERL = /sw/arch/bin/perl
#EMAIL = email@example.org
EMAIL = support@ebi.ac.uk

# Run all test sets
all: dbfetch ebeye iprscan ncbiblast

clean: dbfetch_clean ebeye_clean iprscan_clean ncbiblast_clean

# WSDbfetch Document/literal SOAP
dbfetch: dbfetch_getSupportedDBs dbfetch_getSupportedFormats dbfetch_getSupportedStyles dbfetch_getDbFormats dbfetch_getFormatStyles dbfetch_fetchData dbfetch_fetchBatch

dbfetch_getSupportedDBs:
	${PERL} wsdbfetch_xmlcompile.pl getSupportedDBs > dbfetch-getSupportedDBs.txt

dbfetch_getSupportedFormats:
	${PERL} wsdbfetch_xmlcompile.pl getSupportedFormats > dbfetch-getSupportedFormats.txt

dbfetch_getSupportedStyles:
	${PERL} wsdbfetch_xmlcompile.pl getSupportedStyles > dbfetch-getSupportedStyles.txt

dbfetch_getDbFormats:
	${PERL} wsdbfetch_xmlcompile.pl getDbFormats uniprotkb > dbfetch-getDbFormats.txt

dbfetch_getFormatStyles:
	${PERL} wsdbfetch_xmlcompile.pl getFormatStyles uniprotkb default > dbfetch-getFormatStyles.txt

dbfetch_fetchData:
	${PERL} wsdbfetch_xmlcompile.pl fetchData 'uniprotkb:wap_rat' > dbfetch-fetchData.txt

dbfetch_fetchBatch:
	${PERL} wsdbfetch_xmlcompile.pl fetchBatch uniprotkb 'wap_rat,wap_mouse' > dbfetch-fetchBatch.txt

dbfetch_clean:
	rm -f dbfetch-*

# EB-eye
ebeye: ebeye_listDomains ebeye_getNumberOfResults ebeye_getResultsIds ebeye_getAllResultsIds ebeye_listFields ebeye_getResults ebeye_getEntry \
ebeye_getEntries ebeye_getEntryFieldUrls ebeye_getEntriesFieldUrls ebeye_getDomainsReferencedInDomain ebeye_getDomainsReferencedInEntry \
ebeye_listAdditionalReferenceFields ebeye_getReferencedEntries ebeye_getReferencedEntriesSet ebeye_getReferencedEntriesFlatSet \
ebeye_getDomainsHierarchy ebeye_getDetailledNumberOfResult ebeye_listFieldsInformation

ebeye_listDomains:
	${PERL} ebeye_xmlcompile.pl --listDomains

ebeye_getNumberOfResults:
	${PERL} ebeye_xmlcompile.pl --getNumberOfResults uniprot 'azurin'

ebeye_getResultsIds:
	${PERL} ebeye_xmlcompile.pl --getResultsIds uniprot 'azurin' 1 10

ebeye_getAllResultsIds:
	${PERL} ebeye_xmlcompile.pl --getAllResultsIds uniprot 'azurin'

ebeye_listFields:
	${PERL} ebeye_xmlcompile.pl --listFields uniprot

ebeye_getResults:
	${PERL} ebeye_xmlcompile.pl --getResults uniprot 'azurin' 'id,acc,name,status' 1 10

ebeye_getEntry:
	${PERL} ebeye_xmlcompile.pl --getEntry uniprot 'WAP_RAT' 'id,acc,name,status'

ebeye_getEntries:
	${PERL} ebeye_xmlcompile.pl --getEntries uniprot 'WAP_RAT,WAP_MOUSE' 'id,acc,name,status'

ebeye_getEntryFieldUrls:
	${PERL} ebeye_xmlcompile.pl --getEntryFieldUrls uniprot 'WAP_RAT' 'id'

ebeye_getEntriesFieldUrls:
	${PERL} ebeye_xmlcompile.pl --getEntriesFieldUrls uniprot 'WAP_RAT,WAP_MOUSE' 'id'

ebeye_getDomainsReferencedInDomain:
	${PERL} ebeye_xmlcompile.pl --getDomainsReferencedInDomain uniprot

ebeye_getDomainsReferencedInEntry:
	${PERL} ebeye_xmlcompile.pl --getDomainsReferencedInEntry uniprot 'WAP_RAT'

ebeye_listAdditionalReferenceFields:
	${PERL} ebeye_xmlcompile.pl --listAdditionalReferenceFields uniprot

ebeye_getReferencedEntries:
	${PERL} ebeye_xmlcompile.pl --getReferencedEntries uniprot 'WAP_RAT' interpro

ebeye_getReferencedEntriesSet:
	${PERL} ebeye_xmlcompile.pl --getReferencedEntriesSet uniprot 'WAP_RAT,WAP_MOUSE' interpro 'id,name'

ebeye_getReferencedEntriesFlatSet:
	${PERL} ebeye_xmlcompile.pl --getReferencedEntriesFlatSet uniprot 'WAP_RAT,WAP_MOUSE' interpro 'id,name'

ebeye_getDomainsHierarchy:
	${PERL} ebeye_xmlcompile.pl --getDomainsHierarchy

ebeye_getDetailledNumberOfResult: ebeye_getDetailledNumberOfResult_flat ebeye_getDetailledNumberOfResult_tree

ebeye_getDetailledNumberOfResult_flat:
	${PERL} ebeye_xmlcompile.pl --getDetailledNumberOfResult allebi 'azurin' true

ebeye_getDetailledNumberOfResult_tree:
	${PERL} ebeye_xmlcompile.pl --getDetailledNumberOfResult allebi 'azurin' false

ebeye_listFieldsInformation:
	${PERL} ebeye_xmlcompile.pl --listFieldsInformation uniprot

ebeye_clean:

# InterProScan
iprscan: iprscan_params iprscan_param_detail iprscan_file iprscan_dbid iprscan_stdin_stdout iprscan_id_list_file iprscan_multifasta_file

iprscan_params:
	${PERL} iprscan_xmlcompile.pl --params

iprscan_param_detail:
	${PERL} iprscan_xmlcompile.pl --paramDetail appl

iprscan_file:
	${PERL} iprscan_xmlcompile.pl --email ${EMAIL} ../test_data/SWISSPROT_ABCC9_HUMAN.fasta

iprscan_dbid:
	${PERL} iprscan_xmlcompile.pl --email ${EMAIL} UNIPROT:ABCC9_HUMAN

iprscan_stdin_stdout:
	cat ../test_data/SWISSPROT_ABCC9_HUMAN.fasta | ${PERL} iprscan_xmlcompile.pl --email ${EMAIL} --quiet --outformat out --outfile - - > iprscan-blah.txt

iprscan_id_list_file:
	${PERL} iprscan_xmlcompile.pl --email ${EMAIL} --outformat out --outfile - @../test_data/uniprot_id_list.txt

iprscan_multifasta_file:
	${PERL} iprscan_xmlcompile.pl --email ${EMAIL} --outformat out --outfile - --multifasta  ../test_data/multi_prot.tfa

iprscan_clean:
	rm -f iprscan-*

# NCBI BLAST
ncbiblast: ncbiblast_params ncbiblast_param_detail ncbiblast_file ncbiblast_dbid ncbiblast_stdin_stdout

ncbiblast_params:
	${PERL} ncbiblast_xmlcompile.pl --params

ncbiblast_param_detail:
	${PERL} ncbiblast_xmlcompile.pl --paramDetail program

ncbiblast_file:
	${PERL} ncbiblast_xmlcompile.pl --email ${EMAIL} --program blastp --database uniprotkb_swissprot --scores 10 --alignments 10 --stype protein ../test_data/SWISSPROT_ABCC9_HUMAN.fasta

ncbiblast_dbid:
	${PERL} ncbiblast_xmlcompile.pl --email ${EMAIL} --program blastp --database uniprotkb_swissprot --scores 10 --alignments 10 --stype protein UNIPROT:ABCC9_HUMAN

ncbiblast_stdin_stdout:
	cat ../test_data/SWISSPROT_ABCC9_HUMAN.fasta | ${PERL} ncbiblast_xmlcompile.pl --email ${EMAIL} --program blastp --database uniprotkb_swissprot --scores 10 --alignments 10 --stype protein --quiet --outformat out --outfile - - > ncbiblast-blah.txt

ncbiblast_clean:
	rm -f ncbiblast-*
