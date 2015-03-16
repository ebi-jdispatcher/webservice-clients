#!/bin/bash
for i in `seq 1 100`; do
QUERY="'blood OR soapperl$i'"
# echo "$QUERY"
ts=$(date +%s%N)
/ebi/extserv/bin/perl/bin/perl ./ebeye_soaplite.pl --WSDL 'http://ves-hx-27.ebi.ac.uk:8080/ebisearch/service.ebi?wsdl' --getResults uniprot "$QUERY" 'id,acc,name,status' 1 10 > soap_perl_out.txt
tt=$((($(date +%s%N) - $ts)/1000000))
echo "$tt"
done
