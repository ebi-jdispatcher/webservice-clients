#!/bin/bash
for i in `seq 1 100`; do
QUERY="'blood OR soapperlxml$i'"
# echo "$QUERY"
ts=$(date +%s%N)
/ebi/extserv/bin/perl-5.10.1/bin/perl ./ebeye_xmlcompile.pl --getResults uniprot "$QUERY" 'id,acc,name,status' 1 10 > soap_perl_xml_out.txt
tt=$((($(date +%s%N) - $ts)/1000000))
echo "$tt"
done
