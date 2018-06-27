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
# Test sample EMBL-EBI ZSI 2.0 based web services clients.
#
# NB: ZSI 2.1alpha (from Ubuntu) is incompatible with these clients.
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
ncbiblast

clean: \
ncbiblast_clean

# Fetch/update test data.
test_data:
	-if [ -d ../test_data ]; then svn update ../test_data ; else svn co ${TEST_DATA_SVN} ../test_data ; fi

# NCBI BLAST or NCBI BLAST+
ncbiblast: ncbiblast_params ncbiblast_param_detail ncbiblast_file ncbiblast_dbid ncbiblast_stdin_stdout ncbiblast_id_list_file ncbiblast_id_list_file_stdin_stdout ncbiblast_multifasta_file ncbiblast_multifasta_file_stdin_stdout

# Generate stubs for NCBI BLAST (SOAP).
ncbiblast_services.py: 
	wsdl2py -u 'http://www.ebi.ac.uk/Tools/services/soap/ncbiblast?wsdl'

ncbiblast_params: ncbiblast_services.py
	${PYTHON} ncbiblast_zsi_stubs.py --params

ncbiblast_param_detail: ncbiblast_services.py
	${PYTHON} ncbiblast_zsi_stubs.py --paramDetail program

ncbiblast_file: test_data ncbiblast_services.py
	${PYTHON} ncbiblast_zsi_stubs.py --email ${EMAIL} --program blastp --database uniprotkb_swissprot --scores 10 --alignments 10 --stype protein ../test_data/SWISSPROT_ABCC9_HUMAN.fasta

ncbiblast_dbid: ncbiblast_services.py
	${PYTHON} ncbiblast_zsi_stubs.py --email ${EMAIL} --program blastp --database uniprotkb_swissprot --scores 10 --alignments 10 --stype protein 'UNIPROT:ABCC9_HUMAN'

ncbiblast_stdin_stdout: test_data ncbiblast_services.py
	echo 'TODO:' $@

ncbiblast_id_list_file: test_data ncbiblast_services.py
	echo 'TODO:' $@

ncbiblast_id_list_file_stdin_stdout: test_data ncbiblast_services.py
	echo 'TODO:' $@

ncbiblast_multifasta_file: test_data ncbiblast_services.py
	echo 'TODO:' $@

ncbiblast_multifasta_file_stdin_stdout: test_data ncbiblast_services.py
	echo 'TODO:' $@

ncbiblast_clean:
	rm -f ncbiblast-*
