#!/bin/bash
for i in `seq 1 100`; do
QUERY="'blood OR soappy2$i'"
# echo "$QUERY"
ts=$(date +%s%N)
/ebi/extserv/bin/perl/bin/perl ./ebeye_suds.py --WSDL 'http://ves-hx-27.ebi.ac.uk:8080/ebisearch/service.ebi?wsdl' --getResults uniprot "$QUERY" 'id,acc,name,status' 1 10 > soap_py2_out.txt
tt=$((($(date +%s%N) - $ts)/1000000))
echo "$tt"
done
