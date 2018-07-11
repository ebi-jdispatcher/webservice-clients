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
# Test sample EMBL-EBI soap4r based web services clients.
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
	${RUBY} wsdbfetch_soap4r.rb getSupportedDBs > dbfetch-getSupportedDBs.txt

dbfetch_getSupportedFormats:
	${RUBY} wsdbfetch_soap4r.rb getSupportedFormats > dbfetch-getSupportedFormats.txt

dbfetch_getSupportedStyles:
	${RUBY} wsdbfetch_soap4r.rb getSupportedStyles > dbfetch-getSupportedStyles.txt

dbfetch_getDbFormats:
	${RUBY} wsdbfetch_soap4r.rb getDbFormats uniprotkb > dbfetch-getDbFormats.txt

dbfetch_getFormatStyles:
	${RUBY} wsdbfetch_soap4r.rb getFormatStyles uniprotkb default > dbfetch-getFormatStyles.txt

dbfetch_fetchData: dbfetch_fetchData_string dbfetch_fetchData_file dbfetch_fetchData_stdin

dbfetch_fetchData_string:
	${RUBY} wsdbfetch_soap4r.rb fetchData 'UNIPROTKB:WAP_RAT' > dbfetch-fetchData.txt

dbfetch_fetchData_file: test_data
	echo 'TODO:' $@

dbfetch_fetchData_stdin: test_data
	echo 'TODO:' $@

dbfetch_fetchBatch: dbfetch_fetchBatch_string dbfetch_fetchBatch_file dbfetch_fetchBatch_stdin

dbfetch_fetchBatch_string:
	${RUBY} wsdbfetch_soap4r.rb fetchBatch uniprotkb 'WAP_RAT,WAP_MOUSE' > dbfetch-fetchBatch.txt

dbfetch_fetchBatch_file: test_data
	echo 'TODO:' $@

dbfetch_fetchBatch_stdin: test_data
	echo 'TODO:' $@

dbfetch_clean:
	rm -f dbfetch-*

# InterProScan
iprscan5: iprscan5_params iprscan5_param_detail iprscan5_file iprscan5_dbid iprscan5_stdin_stdout iprscan5_id_list_file iprscan5_id_list_file_stdin_stdout iprscan5_multifasta_file iprscan5_multifasta_file_stdin_stdout

iprscan5_stubs_generation: iprscan5Driver.rb

iprscan5Driver.rb:
	wsdl2ruby.rb --type client --wsdl 'http://www.ebi.ac.uk/Tools/services/soap/iprscan5?wsdl'

iprscan5_params: iprscan5_stubs_generation
	${RUBY} iprscan5_soap4r.rb --params ${JDispatcher_params_suffix}

iprscan5_param_detail: iprscan5_stubs_generation
	${RUBY} iprscan5_soap4r.rb --paramDetail appl

iprscan5_file: test_data iprscan5_stubs_generation
	${RUBY} iprscan5_soap4r.rb --email ${EMAIL} ../test_data/SWISSPROT_ABCC9_HUMAN.fasta

iprscan5_dbid: iprscan5_stubs_generation
	${RUBY} iprscan5_soap4r.rb --email ${EMAIL} 'UNIPROT:ABCC9_HUMAN'

iprscan5_stdin_stdout: test_data iprscan5_stubs_generation
	echo 'TODO:' $@

iprscan5_id_list_file: test_data iprscan5_stubs_generation
	echo 'TODO:' $@

iprscan5_id_list_file_stdin_stdout: test_data iprscan5_stubs_generation
	echo 'TODO:' $@

iprscan5_multifasta_file: test_data iprscan5_stubs_generation
	echo 'TODO:' $@

iprscan5_multifasta_file_stdin_stdout: test_data iprscan5_stubs_generation
	echo 'TODO:' $@

iprscan5_clean:
	rm -f iprscan5-*

# NCBI BLAST or NCBI BLAST+
ncbiblast: ncbiblast_params ncbiblast_param_detail ncbiblast_file ncbiblast_dbid ncbiblast_stdin_stdout ncbiblast_id_list_file ncbiblast_id_list_file_stdin_stdout ncbiblast_multifasta_file ncbiblast_multifasta_file_stdin_stdout

ncbiblast_stubs_generation: ncbiblastDriver.rb

ncbiblastDriver.rb:
	wsdl2ruby.rb --type client --wsdl 'http://www.ebi.ac.uk/Tools/services/soap/ncbiblast?wsdl'

ncbiblast_params: ncbiblast_stubs_generation
	${RUBY} ncbiblast_soap4r.rb --params ${JDispatcher_params_suffix}

ncbiblast_param_detail: ncbiblast_stubs_generation
	${RUBY} ncbiblast_soap4r.rb --paramDetail program

ncbiblast_file: test_data ncbiblast_stubs_generation
	${RUBY} ncbiblast_soap4r.rb --email ${EMAIL} --program blastp --database uniprotkb_swissprot --scores 10 --alignments 10 --stype protein ../test_data/SWISSPROT_ABCC9_HUMAN.fasta

ncbiblast_dbid: ncbiblast_stubs_generation
	${RUBY} ncbiblast_soap4r.rb --email ${EMAIL} --program blastp --database uniprotkb_swissprot --scores 10 --alignments 10 --stype protein 'UNIPROT:ABCC9_HUMAN'

ncbiblast_stdin_stdout: test_data ncbiblast_stubs_generation
	echo 'TODO:' $@
	#cat ../test_data/SWISSPROT_ABCC9_HUMAN.fasta | ${RUBY} ncbiblast_soap4r.rb --email ${EMAIL} --program blastp --database uniprotkb_swissprot --scores 10 --alignments 10 --stype protein --quiet --outformat out --outfile - - > ncbiblast-blah.txt

ncbiblast_id_list_file: test_data ncbiblast_stubs_generation
	echo 'TODO:' $@

ncbiblast_id_list_file_stdin_stdout: test_data ncbiblast_stubs_generation
	echo 'TODO:' $@

ncbiblast_multifasta_file: test_data ncbiblast_stubs_generation
	echo 'TODO:' $@

ncbiblast_multifasta_file_stdin_stdout: test_data ncbiblast_stubs_generation
	echo 'TODO:' $@

ncbiblast_clean:
	rm -f ncbiblast-*
