#!/bin/bash
for i in `seq 1 100`; do
QUERY="'blood OR restpy2$i'"
#echo "$QUERY"
ts=$(date +%s%N)
/usr/local/bin/python  ./ebeye_urllib2.py --baseUrl 'http://ves-hx-27.ebi.ac.uk:8080/ebisearch/ws/rest' getResults uniprot "$QUERY" 'id,acc,name,status' 10 1 > rest_py2_out.txt
tt=$((($(date +%s%N) - $ts)/1000000))
echo "$tt"
done
