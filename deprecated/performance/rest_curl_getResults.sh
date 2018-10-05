#!/bin/bash
for i in `seq 1 100`; do
QUERY="blood%20OR%20restcurl$i"
#echo "$QUERY"
ts=$(date +%s%N)
curl -s "http://ves-hx-27.ebi.ac.uk:8080/ebisearch/ws/rest/uniprot?query=$QUERY&fields=id,acc,status&size=10&start=1" -o rest_curl_out.txt
tt=$((($(date +%s%N) - $ts)/1000000))
echo "$tt"
done
