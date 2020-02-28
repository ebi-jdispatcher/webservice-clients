# EMBL-EBI Web Services Clients

This repository provides a collection of Sample Web Service Clients to consume
EBI's Job Dispatcher Web Service tools APIs. If you are looking after EBI Search REST clients check the following
repository: https://github.com/ebi-wp/EBISearch-webservice-clients

*Note:* A number of "older" REST and SOAP clients in a range of programming languages are now deprecated
but [still available](https://github.com/ebi-wp/webservice-clients/tree/deprecated) for those who might be interested.
In addition to Perl, Python and Java, clients are available
in C#, Visual Basic .NET, Ruby and PHP, using a variety of different REST/SOAP libraries.

## Sample Clients

A collection of REST sample clients for the EBI Job Dispatcher Web Services in Python, Perl and Java.
These clients are generated from the service (XML) description with
[https://github.com/ebi-wp/webservice-clients-generator](https://github.com/ebi-wp/webservice-clients-generator)

* [Perl](perl)
* [Python](python)
* [Java](java)

The RESTful API interface for the Job Dispatcher Web Services is available at
[https://www.ebi.ac.uk/Tools/common/tools/help/](https://www.ebi.ac.uk/Tools/common/tools/help/)

## Running the clients

[Download the clients](https://github.com/ebi-wp/webservice-clients/archive/master.zip)
or clone the repository:

```bash
git clone https://github.com/ebi-wp/webservice-clients.git
```

### Perl clients [![perl](https://img.shields.io/badge/perl-5.22.0+-blue.svg?style=flat)]()

In order to run Perl clients, Perl (tested version 5.22.0) needs to installed as well as Perl dependencies. Additional instructions on how to install Perl and its dependencies are [provided here](https://www.ebi.ac.uk/seqdb/confluence/display/JDSAT/Environment+setup+for+REST+Web+Services).

Install dependencies with:
```bash
# To install Perl dependencies run (you might need sudo)
cpan LWP
cpan XML::Simple
cpan YAML::Syck
```

An example test for Clustal Omega Perl client:

```bash
perl clustalo.pl --email <your@email.com> --sequence sp:wap_rat,sp:wap_mouse,sp:wap_pig
```

### Python clients [![python](https://img.shields.io/badge/python-3.5+-blue.svg?style=flat)]()

Specially if you have no root access to your machine, you might need to
use [virtualenv](http://docs.python-guide.org/en/latest/dev/virtualenvs/).
Prepare a virtual environment where all the Python (tested version 3.6.5) dependencies will be installed. Additional instructions on how to install Python and its dependencies are [provided here](https://www.ebi.ac.uk/seqdb/confluence/display/JDSAT/Environment+setup+for+REST+Web+Services).

```bash
virtualenv -p `which python` env
source ./env/bin/activate
# deactivate
```

Install dependencies with:
```bash
pip install --upgrade pip xmltramp2 requests
```

An example test for Clustal Omega Python client:

```bash
python clustalo.py --email <your@email.com> --sequence sp:wap_rat,sp:wap_mouse,sp:wap_pig
```

### Java clients [![java](https://img.shields.io/badge/java-openJDK8-blue.svg?style=flat)]()

In order to run Java clients, OpenJDK 8 (tested version 1.8.0_161") as well as ant (tested version 1.10.5),
needs to installed. *Note OpenJDK 9 and above are currently not supported.* Additional instructions on how to install Java and its dependencies are [provided here](https://www.ebi.ac.uk/seqdb/confluence/display/JDSAT/Environment+setup+for+REST+Web+Services).

The clients are provided here as self-contained JAR files. (The source code is available in the [webservice-clients-generator repository](https://github.com/ebi-wp/webservice-clients-generator)) To run them on all platforms, an example for the Clustal Omega Java client is:

```bash
java -jar clustalo.jar --email <your@email.com> --sequence sp:wap_rat,sp:wap_mouse,sp:wap_pig
```

On Linux and OSX you can use the simpler:

```bash
./clustalo.jar --email <your@email.com> --sequence sp:wap_rat,sp:wap_mouse,sp:wap_pig
```

## Running clients with Docker

You can run the Sample Clients with Docker. We provide a docker container at
https://hub.docker.com/r/ebiwp/webservice-clients/. Pull the `webservice-clients` container from Docker Hub:

```
docker pull ebiwp/webservice-clients
```

Then run the Perl (or Python and Java) Clients with:
```
docker run --rm -it ebiwp/webservice-clients ncbiblast.pl --help
```

You can control input/output with `--volumes` or simply `-v`:
```
docker run --rm -it -v `pwd`:/results -w /results ebiwp/webservice-clients ncbiblast.pl  \
  --email <your@email.com> --stype protein --database uniprotkb_swissprot --program blastp sp:pak4_human
```

## Perl clients in BioContainers

EBI Web Service Perl Clients are also available through [BioContainers](http://biocontainers.pro/).

```
docker pull biocontainers/ebi-webservice
```

## Contact and Support

If you have any problems, suggestions or comments for our services please
contact us via [EBI Support](https://www.ebi.ac.uk/support/index.php?query=WebServices).
