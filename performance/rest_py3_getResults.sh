#!/bin/bash
for i in `seq 1 100`; do
QUERY="'blood OR restpy3$i'"
#echo "$QUERY"
ts=$(date +%s%N)
/ebi/extserv/local_work/ympark/tests/ebinocle/tools/Python-3.4.3/python ./ebeye_urllib3.py  --baseUrl 'http://ves-hx-27.ebi.ac.uk:8080/ebisearch/ws/rest' getResults uniprot "$QUERY" 'id,acc,name,status' --size 10 --start 1 > rest_py3_out.txt
tt=$((($(date +%s%N) - $ts)/1000000))
echo "$tt"
done
