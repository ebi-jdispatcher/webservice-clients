
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
# Test sample EMBL-EBI urllib based web services clients.
#
# ======================================================================

# Python installation to use (each installation contains different versions
# of the required libraries).
PYTHON=python
PYTHON3=python3

# User e-mail address to use for the requests.
#EMAIL = email@example.org
EMAIL = support@ebi.ac.uk

# Source for test data used by the tests.
TEST_DATA_SVN=https://svn.ebi.ac.uk/webservices/webservices-2.0/trunk/test_data/

# Run all test sets
all: \
dbfetch \
iprscan5 \
iprscan5.py3 \
ncbiblast \
ncbiblast.py3 \
psisearch \
psiblast


clean: \
dbfetch_clean \
iprscan_clean \
ncbiblast_clean \
psiblast_clean \
psisearch_clean \
iprscan5_clean \
clustalo_clean

# Fetch/update test data.
test_data:
	-if [ -d ../test_data ]; then svn update ../test_data ; else svn co ${TEST_DATA_SVN} ../test_data ; fi

# dbfetch
dbfetch: dbfetch_getSupportedDBs dbfetch_getSupportedFormats dbfetch_getSupportedStyles dbfetch_getDbFormats dbfetch_getFormatStyles dbfetch_fetchData dbfetch_fetchBatch

dbfetch_getSupportedDBs:
	${PYTHON} dbfetch_urllib2.py getSupportedDBs > dbfetch-getSupportedDBs.txt

dbfetch_getSupportedFormats:
	echo 'TODO:' $@

dbfetch_getSupportedStyles:
	echo 'TODO:' $@

dbfetch_getDbFormats:
	${PYTHON} dbfetch_urllib2.py getDbFormats uniprotkb > dbfetch-getDbFormats.txt

dbfetch_getFormatStyles:
	${PYTHON} dbfetch_urllib2.py getFormatStyles uniprotkb default > dbfetch-getFormatStyles.txt

dbfetch_fetchData: dbfetch_fetchData_string dbfetch_fetchData_file dbfetch_fetchData_stdin

dbfetch_fetchData_string:
	${PYTHON} dbfetch_urllib2.py fetchData 'UNIPROTKB:WAP_RAT' > dbfetch-fetchData.txt

dbfetch_fetchData_file: test_data
	echo 'TODO:' $@

dbfetch_fetchData_stdin: test_data
	echo 'TODO:' $@

dbfetch_fetchBatch: dbfetch_fetchBatch_string dbfetch_fetchBatch_file dbfetch_fetchBatch_stdin

dbfetch_fetchBatch_string:
	${PYTHON} dbfetch_urllib2.py fetchBatch uniprotkb 'WAP_RAT,WAP_MOUSE' fasta raw > dbfetch-fetchBatch.txt

dbfetch_fetchBatch_file: test_data
	echo 'TODO:' $@

dbfetch_fetchBatch_stdin: test_data
	echo 'TODO:' $@

dbfetch_clean:
	rm -f dbfetch-*

# InterProScan
iprscan5: iprscan_params iprscan_param_detail iprscan_file iprscan_dbid iprscan_stdin_stdout iprscan_id_list_file iprscan_id_list_file_stdin_stdout iprscan_multifasta_file iprscan_multifasta_file_stdin_stdout

iprscan_params:
	${PYTHON} iprscan5_urllib2.py --params

iprscan_param_detail:
	${PYTHON} iprscan5_urllib2.py --paramDetail appl

iprscan_file: test_data
	${PYTHON} iprscan5_urllib2.py --email ${EMAIL} --crc --nogoterms ../test_data/SWISSPROT_ABCC9_HUMAN.fasta

iprscan_dbid:
	${PYTHON} iprscan5_urllib2.py --email ${EMAIL} --crc --nogoterms 'UNIPROT:ABCC9_HUMAN'

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
	${PYTHON} ncbiblast_urllib2.py --params

ncbiblast_param_detail:
	${PYTHON} ncbiblast_urllib2.py --paramDetail program

ncbiblast_file: test_data
	${PYTHON} ncbiblast_urllib2.py --email ${EMAIL} --program blastp --database uniprotkb_swissprot --scores 10 --alignments 10 --stype protein ../test_data/SWISSPROT_ABCC9_HUMAN.fasta

ncbiblast_dbid:
	${PYTHON} ncbiblast_urllib2.py --email ${EMAIL} --program blastp --database uniprotkb_swissprot --scores 10 --alignments 10 --stype protein 'UNIPROT:ABCC9_HUMAN'

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
	
	
# NCBI BLAST (python3)
ncbiblast.py3: ncbiblast_params.py3 ncbiblast_param_detail.py3 ncbiblast_file.py3 ncbiblast_dbid.py3

ncbiblast_params.py3:
	${PYTHON3} ncbiblast_urllib3.py --params

ncbiblast_param_detail.py3:
	${PYTHON3} ncbiblast_urllib3.py --paramDetail program

ncbiblast_file.py3: #test_data
	${PYTHON3} ncbiblast_urllib3.py --email ${EMAIL} --program blastp --database uniprotkb_swissprot --scores 10 --alignments 10 --stype protein ../test_data/SWISSPROT_ABCC9_HUMAN.fasta

ncbiblast_dbid.py3:
	${PYTHON3} ncbiblast_urllib3.py --email ${EMAIL} --program blastp --database uniprotkb_swissprot --scores 10 --alignments 10 --stype protein 'UNIPROT:ABCC9_HUMAN'


# PSI-BLAST
psiblast: psiblast_params psiblast_param_detail psiblast_file psiblast_dbid

psiblast_params:
	${PYTHON3} psiblast_urllib3.py --params

psiblast_param_detail:
	${PYTHON3} psiblast_urllib3.py --paramDetail matrix

psiblast_file: #test_data
	${PYTHON3} psiblast_urllib3.py --email ${EMAIL} --database uniprotkb_swissprot --scores 10 --alignments 10 --stype protein ../test_data/SWISSPROT_ABCC9_HUMAN.fasta

psiblast_dbid:
	${PYTHON3} psiblast_urllib3.py --email ${EMAIL} --database uniprotkb_swissprot --scores 10 --alignments 10 --stype protein 'UNIPROT:ABCC9_HUMAN'

psiblast_clean:
	rm -f psiblast-*
	

# PSI-Search
psisearch: psisearch_params psisearch_param_detail psisearch_file psisearch_dbid

psisearch_params:
	${PYTHON3} psisearch_urllib3.py --params

psisearch_param_detail:
	${PYTHON3} psisearch_urllib3.py --paramDetail matrix

psisearch_file: #test_data
	${PYTHON3} psisearch_urllib3.py --email ${EMAIL} --database uniprotkb_swissprot --scores 10 --alignments 10 --stype protein ../test_data/SWISSPROT_ABCC9_HUMAN.fasta

psisearch_dbid:
	${PYTHON3} psisearch_urllib3.py --email ${EMAIL} --database uniprotkb_swissprot --scores 10 --alignments 10 --stype protein 'UNIPROT:ABCC9_HUMAN'

psisearch_clean:
	rm -f psisearch-*


# IPRSCAN5
iprscan5.py3: iprscan5_params.py3 iprscan5_param_detail.py3 iprscan5_file.py3 iprscan5_dbid.py3

iprscan5_params.py3:
	${PYTHON3} iprscan5_urllib3.py --params

iprscan5_param_detail.py3:
	${PYTHON3} iprscan5_urllib3.py --paramDetail goterms

iprscan5_file.py3: #test_data
	${PYTHON3} iprscan5_urllib3.py --email ${EMAIL} --crc --nogoterms ../test_data/SWISSPROT_ABCC9_HUMAN.fasta

iprscan5_dbid.py3:
	${PYTHON3} iprscan5_urllib3.py --email ${EMAIL} --crc --nogoterms 'UNIPROT:ABCC9_HUMAN'

iprscan5_clean:
	rm -f iprscan5-*
		

# CLUSTALO
clustalo.py3: clustalo_params.py3 clustalo_param_detail.py3 clustalo_file.py3

clustalo_params.py3:
	${PYTHON3} clustalo_urllib3.py --params

clustalo_param_detail.py3:
	${PYTHON3} clustalo_urllib3.py --paramDetail outfmt

clustalo_file.py3: #test_data
	${PYTHON3} clustalo_urllib3.py --email ${EMAIL} ../test_data/multi_prot.tfa


clustalo_clean:
	rm -f clustalo-*
