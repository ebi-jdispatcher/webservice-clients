# EBI Web Services Clients

This repository provides a collection of Sample Web Service Clients to consume EBI's Job Dispatcher Web Service tools via REST and SOAP APIs.

**New:** RESTful API interface is available at https://www.ebi.ac.uk/Tools/common/tools/help/

## Sample Clients

A collection of sample clients for the EBI Job Dispatcher Web Services in a range of
programming languages:

* [C#](csharp/)
* [Java](java/)
* [Visual Basic .NET](vb.net/)
* [Perl](perl/) > [Perl (lwp)](perl/lwp) | [Perl (soaplite)](perl/soaplite) | [Perl (xmlcompile)](perl/xmlcompile)
* [Python](python/) > [Python (auto-generated)](python/auto-generated) | [Python (urllib)](python/urllib) | [Python (requests)](python/requests) | [Python (soappy)](python/soappy) | [Python (zsi20)](python/zsi20) | [Python (suds)](python/suds)
* [PHP](php/) > [PHP (nusoap)](php/nusoap) | [PHP (php_file)](php/php_file) | [PHP (php_soap)](php/php_soap)
* [Ruby](ruby/) > [Ruby (net_http)](ruby/net_http) | [Ruby (open-uri)](ruby/open-uri) | [Ruby (soap4r)](ruby/soap4r)


A selection of utility scripts are provided in the [util](util/) directory.

Users are encouraged to develop their own clients. Feel free to share them with us! Those will be listed in [thirdparty](thirdparty) directory.

## Sample Workflows

A selection of sample workflow descriptions showing how to use the
services can be found in the following directories:

* [Taverna](workflows/taverna/)


## Run Perl Clients with Docker

You can prefer to run the Perl Sample Clients with Docker. We provide a docker container at https://hub.docker.com/r/ebiwp/webservice-clients/.

Pull the `webservice-clients` container from Docker Hub:
```
docker pull ebiwp/webservice-clients
```

Then run the Perl Clients with:
```
# example
docker run --rm -it ebiwp/webservice-clients ncbiblast_lwp.pl --help
```

You can control input/output with `--volumes` or simply `-v`:
```
# example
docker run --rm -it -v `pwd`:/results -w /results ebiwp/webservice-clients ncbiblast_lwp.pl  \
  --email your@email.com --stype protein --database uniprotkb_swissprot --program blastp sp:pak4_human
```

## Perl Clients in BioContainers

EBI Web Service Perl Clients are also available through [BioContainers](http://biocontainers.pro/).

```
docker pull biocontainers/ebi-webservice
```

## Auto-generation of Python Clients

We have got a new project that allows auto-generation of Python clients. See https://github.com/ebi-wp/webservice-client-generator for more details.

## Contact and Support

If you have any problems, suggestions or comments for our services please
contact us via [EBI Support](http://www.ebi.ac.uk/support/index.php?query=WebServices).
