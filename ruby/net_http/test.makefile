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
# Test sample EMBL-EBI net/http based web services clients.
#
# ======================================================================

# Ruby installation to use (each installation contains different versions
# of the required libraries).
RUBY = ruby

# User e-mail address to use for the requests.
#EMAIL = email@example.org
EMAIL = support@ebi.ac.uk

# Source for test data used by the tests.
TEST_DATA_SVN=https://svn.ebi.ac.uk/webservices/webservices-2.0/trunk/test_data/

# Run all test sets
all: \
dbfetch \
iprscan \
ncbiblast

clean: \
dbfetch_clean \
iprscan_clean \
ncbiblast_clean

# Fetch/update test data.
test_data:
	-if [ -d ../test_data ]; then svn update ../test_data ; else svn co ${TEST_DATA_SVN} ../test_data ; fi

# dbfetch
dbfetch: dbfetch_getSupportedDBs dbfetch_getSupportedFormats dbfetch_getSupportedStyles dbfetch_getDbFormats dbfetch_getFormatStyles dbfetch_fetchData dbfetch_fetchBatch

dbfetch_getSupportedDBs:
	${RUBY} dbfetch_net_http.rb getSupportedDBs > dbfetch-getSupportedDBs.txt

dbfetch_getSupportedFormats:
	${RUBY} dbfetch_net_http.rb getSupportedFormats > dbfetch-getSupportedFormats.txt

dbfetch_getSupportedStyles:
	echo 'TODO:' $@

dbfetch_getDbFormats:
	${RUBY} dbfetch_net_http.rb getDbFormats uniprotkb > dbfetch-getDbFormats.txt

dbfetch_getFormatStyles:
	${RUBY} dbfetch_net_http.rb getFormatStyles uniprotkb default > dbfetch-getFormatStyles.txt

dbfetch_fetchData: dbfetch_fetchData_string dbfetch_fetchData_file dbfetch_fetchData_stdin

dbfetch_fetchData_string:
	${RUBY} dbfetch_net_http.rb fetchData 'UNIPROTKB:WAP_RAT' > dbfetch-fetchData.txt

dbfetch_fetchData_file: test_data
	echo 'TODO:' $@

dbfetch_fetchData_stdin: test_data
	echo 'TODO:' $@

dbfetch_fetchBatch: dbfetch_fetchBatch_string dbfetch_fetchBatch_file dbfetch_fetchBatch_stdin

dbfetch_fetchBatch_string:
	${RUBY} dbfetch_net_http.rb fetchBatch uniprotkb 'WAP_RAT,WAP_MOUSE' fasta raw > dbfetch-fetchBatch.txt

dbfetch_fetchBatch_file: test_data
	echo 'TODO:' $@

dbfetch_fetchBatch_stdin: test_data
	echo 'TODO:' $@

dbfetch_clean:
	rm -f dbfetch-*

# InterProScan
iprscan: iprscan_params iprscan_param_detail iprscan_file iprscan_dbid iprscan_stdin_stdout iprscan_id_list_file iprscan_id_list_file_stdin_stdout iprscan_multifasta_file iprscan_multifasta_file_stdin_stdout

iprscan_params:
	${RUBY} iprscan_net_http.rb --params

iprscan_param_detail:
	${RUBY} iprscan_net_http.rb --paramDetail appl

iprscan_file: test_data
	-${RUBY} iprscan_net_http.rb --email ${EMAIL} --crc --nogoterms ../test_data/SWISSPROT_ABCC9_HUMAN.fasta

iprscan_dbid:
	${RUBY} iprscan_net_http.rb --email ${EMAIL} --crc --nogoterms 'UNIPROT:ABCC9_HUMAN'

iprscan_stdin_stdout: test_data
	-cat ../test_data/SWISSPROT_ABCC9_HUMAN.fasta | ${RUBY} iprscan_net_http.rb --email ${EMAIL} --crc --nogoterms --quiet --outformat out --outfile - - > iprscan-blah.txt

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
	${RUBY} ncbiblast_net_http.rb --params

ncbiblast_param_detail:
	${RUBY} ncbiblast_net_http.rb --paramDetail program

ncbiblast_file: test_data
	-${RUBY} ncbiblast_net_http.rb --email ${EMAIL} --program blastp --database uniprotkb_swissprot --scores 10 --alignments 10 --stype protein ../test_data/SWISSPROT_ABCC9_HUMAN.fasta

ncbiblast_dbid:
	${RUBY} ncbiblast_net_http.rb --email ${EMAIL} --program blastp --database uniprotkb_swissprot --scores 10 --alignments 10 --stype protein 'UNIPROT:ABCC9_HUMAN'

ncbiblast_stdin_stdout: test_data
	-cat ../test_data/SWISSPROT_ABCC9_HUMAN.fasta | ${RUBY} ncbiblast_net_http.rb --email ${EMAIL} --program blastp --database uniprotkb_swissprot --scores 10 --alignments 10 --stype protein --quiet --outformat out --outfile - - > ncbiblast-blah.txt

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
