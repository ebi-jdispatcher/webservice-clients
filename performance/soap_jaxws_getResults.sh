#!/bin/bash
for i in `seq 1 100`; do
QUERY="'blood OR soapjaxws$i'"
# echo "$QUERY"
ts=$(date +%s%N)
java -Djava.ext.dirs=jaxws-ri/lib:lib-1.4 -jar jar/EBeye_JAXWS.jar --endpoint 'http://ves-hx-27.ebi.ac.uk:8080/ebisearch/service.ebi' --getResults uniprot "$QUERY" 'id,acc,name,status' 1 10  > soap_jaxws_out.txt
tt=$((($(date +%s%N) - $ts)/1000000))
echo "$tt"
done
