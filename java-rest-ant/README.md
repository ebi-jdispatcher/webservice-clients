# EBI Web Services JAVA (Ant) Clients

## Quick start

Run default ant target (i.e. main)
```
ant
```

Run selected client (e.g. InterProScan5)

```
java -jar dist/iprscan5.jar
```

## Requirements

* Java 8
* Python 2.7

## Add new tool

All you need to do is modify target named "jar" of build.xml file.

## Description

ant main depends on targets that:
* execute python script which downloads a list of all jdispatcher clients and all parameters of each client
* compiles Java classes
* copies dependencies to JAR
* copies text files with description/parameters of currently generated client to JAR

when JAR is executed it has access only to description file associated with this client


## Change logging

Logging configuration can be changed by specifying your configuration file e.g.:
```
java -Dlogback.configurationFile=config.xml -jar <jarfile>
```

## Test new tool

```
# tool description
java -jar dist/IPRScan5Client.jar
```

```
# <yourjobid>
[java -jar dist/IPRScan5Client.jar --email user@ebi.ac.uk --sequence test-data/testpro.txt
```

```
# RUNNING, or FINISHED, or ...
java -jar dist/IPRScan5Client.jar --status --jobid <yourjobid>
```

```
# Result files are being downloaded to current directory
java -jar dist/IPRScan5Client.jar --polljob --jobid <yourjobid>
```

## Distribute JARS
`es_adm@ves-ebi-24:/nfs/web-hx/es/http/www/Tools/webservices/download_clients/uploaded`


## Setup IntelliJ

* Create new module 'java-rest-ant' (File > New > Module ... (Java))
* Set modules SDK as Java *
* Add lib/ to module dependencies
