#!/bin/bash
for i in `seq 1 100`; do
QUERY="'blood OR restperl$i'"
#echo "$QUERY"
ts=$(date +%s%N)
/ebi/extserv/bin/perl/bin/perl ./ebeye_lwp.pl --baseUrl 'http://ves-hx-27.ebi.ac.uk:8080/ebisearch/ws/rest' getResults uniprot "$QUERY" 'id,acc,name,status' --size 10 --start 1 > rest_perl_out.txt
tt=$((($(date +%s%N) - $ts)/1000000))
echo "$tt"
done
