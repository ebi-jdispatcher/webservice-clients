#!/bin/bash

./rest_curl_getResults.sh	 	 > 	out/rest_curl_getResults_out.txt
./rest_perl_getResults.sh		 > 	out/rest_perl_getResults_out.txt
./rest_py2_getResults.sh		 > 	out/rest_py2_getResults_out.txt
./rest_py3_getResults.sh	 	 > 	out/rest_py3_getResults_out.txt
./soap_axis_getResults.sh		 > 	out/soap_axis_getResults_out.txt
./soap_jaxws_getResults.sh		 > 	out/soap_jaxws_getResults_out.txt
./soap_perl_getResults.sh	 	 > 	out/soap_perl_getResults_out.txt
./soap_perl_xml_getResults.sh	         > 	out/soap_perl_xml_getResults_out.txt
./soap_py2_getResults.sh	         > 	out/soap_py2_getResults_out.txt
