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
#PYTHON=/nfs/production/extsrv2/projects/local_work/wp-02/bin/python2/bin/python
PYTHON3=/ebi/extserv/projects/ebinocle/tools/python3.4/bin/python3
#PYTHON3=/nfs/production/extsrv2/projects/local_work/wp-02/bin/python3/bin/python3

# Run all test sets
all: \
ebeye2 \
ebeye3

# EBI Search client for python2
ebeye2: \
getDomainHierarchy \
getDomainDetails \
getNumberOfResults \
getResults \
getResults-2 \
getFacetedResults \
getFacetedResults-2 \
getEntries \
getDomainsReferencedInDomain \
getDomainsReferencedInEntry \
getReferencedEntries \
getTopTerms \
getMoreLikeThis \
getExtendedMoreLikeThis \
getAutoComplete

getDomainHierarchy:
	${PYTHON} ebeye_urllib2.py getDomainHierarchy

getDomainDetails:
	${PYTHON} ebeye_urllib2.py getDomainDetails uniprot

getNumberOfResults:
	${PYTHON} ebeye_urllib2.py getNumberOfResults uniprot 'brca1 OR (breast cancer)'

getResults:
	${PYTHON} ebeye_urllib2.py getResults rnacentral 'hotair' id,name --size=5 --start=5 --fieldurl=true --viewurl=true --sortfield=boost --order=descending

getResults-2:
	${PYTHON} ebeye_urllib2.py getResults rnacentral 'hotair' id,name --size=5 --start=5 --fieldurl=true --viewurl=true --sort=boost:descending

getFacetedResults:
	${PYTHON} ebeye_urllib2.py getFacetedResults  rnacentral 'hotair' id,name --size=5 --start=5 --fieldurl=true --viewurl=true --sortfield=boost --order=descending --facetcount=5 --facetfields=TAXONOMY --facets=active:Active

getFacetedResults-2:
	${PYTHON} ebeye_urllib2.py getFacetedResults  rnacentral 'hotair' id,name --size=5 --start=5 --fieldurl=true --viewurl=true --sort=boost:descending --facetcount=5 --facetfields=TAXONOMY --facets=active:Active
	
getEntries:
	${PYTHON} ebeye_urllib2.py getEntries uniprot WAP_MOUSE,WAP_RAT id,descRecName --fieldurl=true --viewurl=true

getDomainsReferencedInDomain:
	${PYTHON} ebeye_urllib2.py getDomainsReferencedInDomain uniprot

getDomainsReferencedInEntry:
	${PYTHON} ebeye_urllib2.py getDomainsReferencedInEntry uniprot WAP_MOUSE

getReferencedEntries:
	${PYTHON} ebeye_urllib2.py getReferencedEntries uniprot WAP_MOUSE,WAP_RAT interpro id,description --size=1 --start=0 --fieldurl=true --viewurl=true --facetcount=5 --facetfields=TAXONOMY,status

getTopTerms:
	${PYTHON} ebeye_urllib2.py getTopTerms pride description --size=30 --excludes=proteome --excludesets=omics_stopwords

getMoreLikeThis:
	${PYTHON} ebeye_urllib2.py getMoreLikeThis uniprot TPIS_HUMAN descRecName --size=20 --start=0 --fieldurl=true --viewurl=true --mltfields=descRecName --mintermfreq=1 --mindocfreq=5 --maxqueryterm=10 --excludes=state --excludesets=lucene_stopwords

getExtendedMoreLikeThis:
	${PYTHON} ebeye_urllib2.py getExtendedMoreLikeThis uniprot TPIS_HUMAN uniprot descRecName --size=20 --start=0 --fieldurl=true --viewurl=true --mltfields=descRecName --mintermfreq=1 --mindocfreq=5 --maxqueryterm=10 --excludes=state --excludesets=lucene_stopwords

getAutoComplete:
	${PYTHON} ebeye_urllib2.py getAutoComplete rnacentral hota

# EBI Search client for python3

ebeye3: \
getDomainHierarchy3 \
getDomainDetails3 \
getNumberOfResults3 \
getResults3 \
getResults3-2 \
getFacetedResults3 \
getFacetedResults3-2 \
getEntries3 \
getDomainsReferencedInDomain3 \
getDomainsReferencedInEntry3 \
getReferencedEntries3 \
getTopTerms3 \
getMoreLikeThis3 \
getExtendedMoreLikeThis3 \
getAutoComplete3 

getDomainHierarchy3:
	${PYTHON3} ebeye_urllib3.py getDomainHierarchy

getDomainDetails3:
	${PYTHON3} ebeye_urllib3.py getDomainDetails uniprot

getNumberOfResults3:
	${PYTHON3} ebeye_urllib3.py getNumberOfResults uniprot 'brca1 OR (breast cancer)'

getResults3:
	${PYTHON3} ebeye_urllib3.py getResults rnacentral 'hotair' id,name --size=5 --start=5 --fieldurl=true --viewurl=true --sortfield=boost --order=descending

getResults3-2:
	${PYTHON3} ebeye_urllib3.py getResults rnacentral 'hotair' id,name --size=5 --start=5 --fieldurl=true --viewurl=true --sort=boost:descending

getFacetedResults3:
	${PYTHON3} ebeye_urllib3.py getFacetedResults  rnacentral 'hotair' id,name --size=5 --start=5 --fieldurl=true --viewurl=true --sortfield=boost --order=descending --facetcount=5 --facetfields=TAXONOMY --facets=active:Active

getFacetedResults3-2:
	${PYTHON3} ebeye_urllib3.py getFacetedResults  rnacentral 'hotair' id,name --size=5 --start=5 --fieldurl=true --viewurl=true --sort=boost:descending --facetcount=5 --facetfields=TAXONOMY --facets=active:Active

getEntries3:
	${PYTHON3} ebeye_urllib3.py getEntries uniprot WAP_MOUSE,WAP_RAT id,descRecName --fieldurl=true --viewurl=true

getDomainsReferencedInDomain3:
	${PYTHON3} ebeye_urllib3.py getDomainsReferencedInDomain uniprot

getDomainsReferencedInEntry3:
	${PYTHON3} ebeye_urllib3.py getDomainsReferencedInEntry uniprot WAP_MOUSE

getReferencedEntries3:
	${PYTHON3} ebeye_urllib3.py getReferencedEntries uniprot WAP_MOUSE,WAP_RAT interpro id,description --size=1 --start=0 --fieldurl=true --viewurl=true --facetcount=5 --facetfields=TAXONOMY,status

getTopTerms3:
	${PYTHON3} ebeye_urllib3.py getTopTerms pride description --size=30 --excludes=proteome --excludesets=omics_stopwords

getMoreLikeThis3:
	${PYTHON3} ebeye_urllib3.py getMoreLikeThis uniprot TPIS_HUMAN descRecName --size=20 --start=0 --fieldurl=true --viewurl=true --mltfields=descRecName --mintermfreq=1 --mindocfreq=5 --maxqueryterm=10 --excludes=state --excludesets=lucene_stopwords
	
getExtendedMoreLikeThis3:
	${PYTHON3} ebeye_urllib3.py getMoreLikeThis uniprot TPIS_HUMAN uniprot descRecName --size=20 --start=0 --fieldurl=true --viewurl=true --mltfields=descRecName --mintermfreq=1 --mindocfreq=5 --maxqueryterm=10 --excludes=state --excludesets=lucene_stopwords

getAutoComplete3:
	${PYTHON3} ebeye_urllib3.py getAutoComplete rnacentral hota