# $Id$
# ======================================================================
#
# Test sample EMBL-EBI SUDS based web services clients.
#
# ======================================================================

# Python installation to use (each installation contains different versions
# of the required libraries).
PYTHON=python

# User e-mail address to use for the requests.
#EMAIL = email@example.org
EMAIL = support@ebi.ac.uk

# Source for test data used by the tests.
TEST_DATA_SVN=https://svn.ebi.ac.uk/webservices/webservices-2.0/trunk/test_data/

# Run all test sets
all: \
dbfetch \
ebeye \
iprscan \
ncbiblast

clean: \
dbfetch_clean \
ebeye_clean \
iprscan_clean \
ncbiblast_clean

# Fetch/update test data.
test_data:
	-if [ -d ../test_data ]; then svn update ../test_data ; else svn co ${TEST_DATA_SVN} ../test_data ; fi

# WSDbfetch Document/literal SOAP
dbfetch: dbfetch_getSupportedDBs dbfetch_getSupportedFormats dbfetch_getSupportedStyles dbfetch_getDbFormats dbfetch_getFormatStyles dbfetch_fetchData dbfetch_fetchBatch

dbfetch_getSupportedDBs:
	${PYTHON} wsdbfetch_suds.py getSupportedDBs > dbfetch-getSupportedDBs.txt

dbfetch_getSupportedFormats:
	${PYTHON} wsdbfetch_suds.py getSupportedFormats > dbfetch-getSupportedFormats.txt

dbfetch_getSupportedStyles:
	${PYTHON} wsdbfetch_suds.py getSupportedStyles > dbfetch-getSupportedStyles.txt

dbfetch_getDbFormats:
	${PYTHON} wsdbfetch_suds.py getDbFormats uniprotkb > dbfetch-getDbFormats.txt

dbfetch_getFormatStyles:
	${PYTHON} wsdbfetch_suds.py getFormatStyles uniprotkb default > dbfetch-getFormatStyles.txt

dbfetch_fetchData: dbfetch_fetchData_string dbfetch_fetchData_file dbfetch_fetchData_stdin

dbfetch_fetchData_string:
	${PYTHON} wsdbfetch_suds.py fetchData 'UNIPROTKB:WAP_RAT' > dbfetch-fetchData.txt

dbfetch_fetchData_file: test_data
	echo 'TODO:' $@

dbfetch_fetchData_stdin: test_data
	echo 'TODO:' $@

dbfetch_fetchBatch: dbfetch_fetchBatch_string dbfetch_fetchBatch_file dbfetch_fetchBatch_stdin

dbfetch_fetchBatch_string:
	${PYTHON} wsdbfetch_suds.py fetchBatch uniprotkb 'WAP_RAT,WAP_MOUSE' > dbfetch-fetchBatch.txt

dbfetch_fetchBatch_file: test_data
	echo 'TODO:' $@

dbfetch_fetchBatch_stdin: test_data
	echo 'TODO:' $@

dbfetch_clean:
	rm -f dbfetch-*

# EB-eye
ebeye: ebeye_listDomains ebeye_getNumberOfResults ebeye_getResultsIds ebeye_getAllResultsIds ebeye_listFields ebeye_getResults ebeye_getEntry \
ebeye_getEntries ebeye_getEntryFieldUrls ebeye_getEntriesFieldUrls ebeye_getDomainsReferencedInDomain ebeye_getDomainsReferencedInEntry \
ebeye_listAdditionalReferenceFields ebeye_getReferencedEntries ebeye_getReferencedEntriesSet ebeye_getReferencedEntriesFlatSet \
ebeye_getDomainsHierarchy ebeye_getDetailledNumberOfResults ebeye_listFieldsInformation

ebeye_listDomains:
	${PYTHON} ebeye_suds.py --listDomains

ebeye_getNumberOfResults:
	${PYTHON} ebeye_suds.py --getNumberOfResults uniprot 'azurin'

ebeye_getResultsIds:
	${PYTHON} ebeye_suds.py --getResultsIds uniprot 'azurin' 1 10

ebeye_getAllResultsIds:
	${PYTHON} ebeye_suds.py --getAllResultsIds uniprot 'azurin'

ebeye_listFields:
	${PYTHON} ebeye_suds.py --listFields uniprot

ebeye_getResults:
	${PYTHON} ebeye_suds.py --getResults uniprot 'azurin' 'id,acc,name,status' 1 10

ebeye_getEntry:
	${PYTHON} ebeye_suds.py --getEntry uniprot 'WAP_RAT' 'id,acc,name,status'

ebeye_getEntries:
	${PYTHON} ebeye_suds.py --getEntries uniprot 'WAP_RAT,WAP_MOUSE' 'id,acc,name,status'

ebeye_getEntryFieldUrls:
	${PYTHON} ebeye_suds.py --getEntryFieldUrls uniprot 'WAP_RAT' 'id'

ebeye_getEntriesFieldUrls:
	${PYTHON} ebeye_suds.py --getEntriesFieldUrls uniprot 'WAP_RAT,WAP_MOUSE' 'id'

ebeye_getDomainsReferencedInDomain:
	${PYTHON} ebeye_suds.py --getDomainsReferencedInDomain uniprot

ebeye_getDomainsReferencedInEntry:
	${PYTHON} ebeye_suds.py --getDomainsReferencedInEntry uniprot 'WAP_RAT'

ebeye_listAdditionalReferenceFields:
	${PYTHON} ebeye_suds.py --listAdditionalReferenceFields uniprot

ebeye_getReferencedEntries:
	${PYTHON} ebeye_suds.py --getReferencedEntries uniprot 'WAP_RAT' interpro

ebeye_getReferencedEntriesSet:
	${PYTHON} ebeye_suds.py --getReferencedEntriesSet uniprot 'WAP_RAT,WAP_MOUSE' interpro 'id,name'

ebeye_getReferencedEntriesFlatSet:
	${PYTHON} ebeye_suds.py --getReferencedEntriesFlatSet uniprot 'WAP_RAT,WAP_MOUSE' interpro 'id,name'

ebeye_getDomainsHierarchy:
	${PYTHON} ebeye_suds.py --getDomainsHierarchy

ebeye_getDetailledNumberOfResults: ebeye_getDetailledNumberOfResults_flat ebeye_getDetailledNumberOfResults_tree

ebeye_getDetailledNumberOfResults_flat:
	${PYTHON} ebeye_suds.py --getDetailledNumberOfResults allebi 'azurin' true

ebeye_getDetailledNumberOfResults_tree:
	${PYTHON} ebeye_suds.py --getDetailledNumberOfResults allebi 'azurin' false

ebeye_listFieldsInformation:
	${PYTHON} ebeye_suds.py --listFieldsInformation uniprot

ebeye_clean:

# InterProScan
iprscan: iprscan_params iprscan_param_detail iprscan_file iprscan_dbid iprscan_stdin_stdout iprscan_id_list_file iprscan_id_list_file_stdin_stdout iprscan_multifasta_file iprscan_multifasta_file_stdin_stdout

iprscan_params:
	${PYTHON} iprscan_suds.py --params

iprscan_param_detail:
	${PYTHON} iprscan_suds.py --paramDetail appl

iprscan_file: test_data
	${PYTHON} iprscan_suds.py --email ${EMAIL} ../test_data/SWISSPROT_ABCC9_HUMAN.fasta

iprscan_dbid:
	${PYTHON} iprscan_suds.py --email ${EMAIL} 'UNIPROT:ABCC9_HUMAN'

iprscan_stdin_stdout: test_data
	echo 'TODO:' $@

iprscan_id_list_file: test_data
	echo 'TODO:' $@

iprscan_id_list_file_stdin_stdout: test_data
	echo 'TODO:' $@

iprscan_multifasta_file: test_data
	echo 'TODO:' $@

iprscan_multifasta_file_stdin_stdout: test_data
	echo 'TODO:' $@

iprscan_clean:
	rm -f iprscan-*

# NCBI BLAST or NCBI BLAST+
ncbiblast: ncbiblast_params ncbiblast_param_detail ncbiblast_file ncbiblast_dbid ncbiblast_stdin_stdout ncbiblast_id_list_file ncbiblast_id_list_file_stdin_stdout ncbiblast_multifasta_file ncbiblast_multifasta_file_stdin_stdout

ncbiblast_params:
	${PYTHON} ncbiblast_suds.py --params

ncbiblast_param_detail:
	${PYTHON} ncbiblast_suds.py --paramDetail program

ncbiblast_file: test_data
	${PYTHON} ncbiblast_suds.py --email ${EMAIL} --program blastp --database uniprotkb_swissprot --scores 10 --alignments 10 --stype protein ../test_data/SWISSPROT_ABCC9_HUMAN.fasta

ncbiblast_dbid:
	${PYTHON} ncbiblast_suds.py --email ${EMAIL} --program blastp --database uniprotkb_swissprot --scores 10 --alignments 10 --stype protein 'UNIPROT:ABCC9_HUMAN'

ncbiblast_stdin_stdout: test_data
	echo 'TODO:' $@

ncbiblast_id_list_file: test_data
	echo 'TODO:' $@

ncbiblast_id_list_file_stdin_stdout: test_data
	echo 'TODO:' $@

ncbiblast_multifasta_file: test_data
	echo 'TODO:' $@

ncbiblast_multifasta_file_stdin_stdout: test_data
	echo 'TODO:' $@

ncbiblast_clean:
	rm -f ncbiblast-*
