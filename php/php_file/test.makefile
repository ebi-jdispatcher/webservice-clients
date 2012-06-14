# $Id$
# ======================================================================
#
# Test sample EMBL-EBI PHP file_get_contents based web services clients.
#
# ======================================================================

# PHP installation to use.
PHP = php

# User e-mail address to use for the requests.
#EMAIL = email@example.org
EMAIL = support@ebi.ac.uk

# Source for test data used by the tests.
TEST_DATA_SVN=https://svn.ebi.ac.uk/webservices/webservices-2.0/trunk/test_data/

# Run all test sets
all: \
ncbiblast

clean: \
ncbiblast_clean

# Fetch/update test data.
test_data:
	-if [ -d ../test_data ]; then svn update ../test_data ; else svn co ${TEST_DATA_SVN} ../test_data ; fi

# NCBI BLAST or NCBI BLAST+
ncbiblast: ncbiblast_params ncbiblast_param_detail ncbiblast_file ncbiblast_dbid ncbiblast_stdin_stdout ncbiblast_id_list_file ncbiblast_id_list_file_stdin_stdout ncbiblast_multifasta_file ncbiblast_multifasta_file_stdin_stdout

ncbiblast_params:
	${PHP} ncbiblast_cli_php_file.php --params

ncbiblast_param_detail:
	${PHP} ncbiblast_cli_php_file.php --paramDetail program

ncbiblast_file: test_data
	${PHP} ncbiblast_cli_php_file.php --email ${EMAIL} --program blastp --database uniprotkb_swissprot --scores 10 --alignments 10 --stype protein ../test_data/SWISSPROT_ABCC9_HUMAN.fasta

ncbiblast_dbid:
	${PHP} ncbiblast_cli_php_file.php --email ${EMAIL} --program blastp --database uniprotkb_swissprot --scores 10 --alignments 10 --stype protein 'UNIPROT:ABCC9_HUMAN'

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
