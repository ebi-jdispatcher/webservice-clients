# $Id: test.makefile 2804 2015-03-13 11:59:27Z uludag $
# ======================================================================
# 
# Copyright 2008-2013 EMBL - European Bioinformatics Institute
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
# Test sample EBI Search urllib based web services clients.
#
# ======================================================================

# Python installation to use (each installation contains different versions
# of the required libraries).
PYTHON=/ebi/extserv/projects/ebinocle/tools/python2.7/bin/python
PYTHON3=/ebi/extserv/projects/ebinocle/tools/python3.4/bin/python3

# Run all test sets
all: \
ebeye2 \
ebeye3

# EBI Search client for python2
ebeye2: \
getDomainHierarchy \
getDomainDetails \
getResults \
getFacetedResults \
getEntries \
getDomainsReferencedInDomain \
getDomainsReferencedInEntry \
getReferencedEntries \
getTopTerms \
getMoreLikeThis

getDomainHierarchy:
	${PYTHON} ebeye_urllib2.py getDomainHierarchy

getDomainDetails:
	${PYTHON} ebeye_urllib2.py getDomainDetails uniprot

getResults:
	${PYTHON} ebeye_urllib2.py getResults uniprot 'brca1 OR (breast cancer)' id,descRecName --size=5 --start=5 --fieldurl=true --viewurl=true --sortfield=length --order=descending

getFacetedResults:
	${PYTHON} ebeye_urllib2.py getFacetedResults  uniprot 'brca1 OR (breast cancer)' id,descRecName --size=5 --start=5 --fieldurl=true --viewurl=true --sortfield=length --order=descending --facetcount=5 --facetfields=TAXONOMY,status --facets=status:Reviewed

getEntries:
	${PYTHON} ebeye_urllib2.py getEntries uniprot WAP_MOUSE,WAP_RAT id,descRecName --fieldurl=true --viewurl=true

getDomainsReferencedInDomain:
	${PYTHON} ebeye_urllib2.py getDomainsReferencedInDomain uniprot

getDomainsReferencedInEntry:
	${PYTHON} ebeye_urllib2.py getDomainsReferencedInEntry uniprot WAP_MOUSE

getReferencedEntries:
	${PYTHON} ebeye_urllib2.py getReferencedEntries uniprot WAP_MOUSE,WAP_RAT interpro id,description --size=1 --start=0 --fieldurl=true --viewurl=true

getTopTerms:
	${PYTHON} ebeye_urllib2.py getTopTerms pride description --size=30 --excludes=proteome --excludesets=omics_stopwords

getMoreLikeThis:
	${PYTHON} ebeye_urllib2.py getMoreLikeThis uniprot TPIS_HUMAN descRecName --size=20 --start=0 --fieldurl=true --viewurl=true --mltfields=descRecName --mintermfreq=1 --mindocfreq=5 --maxqueryterm=10 --excludes=state --excludesets=lucene_stopwords

# EBI Search client for python3

ebeye3: \
getDomainHierarchy3 \
getDomainDetails3 \
getResults3 \
getFacetedResults3 \
getEntries3 \
getDomainsReferencedInDomain3 \
getDomainsReferencedInEntry3 \
getReferencedEntries3 \
getTopTerms3 \
getMoreLikeThis3

getDomainHierarchy3:
	${PYTHON3} ebeye_urllib3.py getDomainHierarchy

getDomainDetails3:
	${PYTHON3} ebeye_urllib3.py getDomainDetails uniprot

getResults3:
	${PYTHON3} ebeye_urllib3.py getResults uniprot 'brca1 OR (breast cancer)' id,descRecName --size=5 --start=5 --fieldurl=true --viewurl=true --sortfield=length --order=descending

getFacetedResults3:
	${PYTHON3} ebeye_urllib3.py getFacetedResults  uniprot 'brca1 OR (breast cancer)' id,descRecName --size=5 --start=5 --fieldurl=true --viewurl=true --sortfield=length --order=descending --facetcount=5 --facetfields=TAXONOMY,status --facets=status:Reviewed

getEntries3:
	${PYTHON3} ebeye_urllib3.py getEntries uniprot WAP_MOUSE,WAP_RAT id,descRecName --fieldurl=true --viewurl=true

getDomainsReferencedInDomain3:
	${PYTHON3} ebeye_urllib3.py getDomainsReferencedInDomain uniprot

getDomainsReferencedInEntry3:
	${PYTHON3} ebeye_urllib3.py getDomainsReferencedInEntry uniprot WAP_MOUSE

getReferencedEntries3:
	${PYTHON3} ebeye_urllib3.py getReferencedEntries uniprot WAP_MOUSE,WAP_RAT interpro id,description --size=1 --start=0 --fieldurl=true --viewurl=true

getTopTerms3:
	${PYTHON} ebeye_urllib2.py getTopTerms pride description --size=30 --excludes=proteome --excludesets=omics_stopwords

getMoreLikeThis3:
	${PYTHON} ebeye_urllib2.py getMoreLikeThis uniprot TPIS_HUMAN descRecName --size=20 --start=0 --fieldurl=true --viewurl=true --mltfields=descRecName --mintermfreq=1 --mindocfreq=5 --maxqueryterm=10 --excludes=state --excludesets=lucene_stopwords
