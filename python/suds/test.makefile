# $Id$
# ======================================================================
# 
# Copyright 2008-2018 EMBL - European Bioinformatics Institute
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# 
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
iprscan5 \
ncbiblast

clean: \
dbfetch_clean \
iprscan5_clean \
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

# InterProScan
iprscan5: iprscan5_params iprscan5_param_detail iprscan5_file iprscan5_dbid iprscan5_stdin_stdout iprscan5_id_list_file iprscan5_id_list_file_stdin_stdout iprscan5_multifasta_file iprscan5_multifasta_file_stdin_stdout

iprscan5_params:
	${PYTHON} iprscan5_suds.py --params

iprscan5_param_detail:
	${PYTHON} iprscan5_suds.py --paramDetail appl

iprscan5_file: test_data
	${PYTHON} iprscan5_suds.py --email ${EMAIL} ../test_data/SWISSPROT_ABCC9_HUMAN.fasta

iprscan5_dbid:
	${PYTHON} iprscan5_suds.py --email ${EMAIL} 'UNIPROT:ABCC9_HUMAN'

iprscan5_stdin_stdout: test_data
	echo 'TODO:' $@

iprscan5_id_list_file: test_data
	echo 'TODO:' $@

iprscan5_id_list_file_stdin_stdout: test_data
	echo 'TODO:' $@

iprscan5_multifasta_file: test_data
	echo 'TODO:' $@

iprscan5_multifasta_file_stdin_stdout: test_data
	echo 'TODO:' $@

iprscan5_clean:
	rm -f iprscan5-*

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
