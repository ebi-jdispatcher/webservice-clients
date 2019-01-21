################################################################################
# Dockerfile
# Software: EMBL-EBI Web Service Clients
# Website:  https://github.com/ebi-wp/webservice-clients
# Build:    docker build -t webservice-clients:latest .
# Run:      docker run --rm -it --entrypoint /bin/bash webservice-clients:latest
################################################################################

FROM ubuntu:16.04

MAINTAINER EBI, Web Production Team, webprod <webprod@ebi.ac.uk>
LABEL    base_image="ebi-wp:EMBL-EBI Web Service Clients" \
    software="ebi-webservice-clients" \
    container="ebiwp/webservice-clients" \
    about.summary="A collection of Web Service Clients to consume EBI's tools" \
    about.home="https://www.ebi.ac.uk/services" \
    about.documentation="https://www.ebi.ac.uk/Tools/webservices" \
    software.version="1.0.0" \
    version="1" \
    about.copyright="Copyright EMBL-EBI 2018" \
    about.license="Apache-2.0" \
    about.license_file="/usr/src/doc/LICENSE" \
    about.tags="ebi" \
    extra.identifier.biotools="ebi_tools"

# Dependencies
RUN apt-get update --fix-missing \
  && apt-get install -y build-essential wget curl unzip git make gcc g++
RUN apt-get -y upgrade \
  && apt-get install -y perl libcrypt-ssleay-perl python3-pip python-virtualenv default-jdk ant

# Perl Dependencies
RUN curl -L https://cpanmin.us | perl - App::cpanminus \
 && cpanm Bundle::LWP REST::Client XML::Simple YAML::Syck

# Python Dependencies
RUN rm -rf /usr/bin/python && ln -s /usr/bin/pip3 /usr/bin/pip \
 && ln -s /usr/bin/python3 /usr/bin/python \
 && pip install --upgrade pip xmltramp2

# Generating and building the clients
RUN git clone https://github.com/ebi-wp/webservice-clients-generator.git
WORKDIR /webservice-clients-generator
RUN pip install -r requirements.txt
RUN python clientsgenerator.py python,perl,java
WORKDIR /webservice-clients-generator/dist
RUN wget https://raw.githubusercontent.com/ebi-wp/webservice-clients/master/python/dbfetch.py \
 && wget https://raw.githubusercontent.com/ebi-wp/webservice-clients/master/perl/dbfetch.pl

# Adding EBI Search clients
RUN wget https://raw.githubusercontent.com/ebi-wp/webservice-clients/master/python/requests/ebeye_requests.py \
 && wget https://raw.githubusercontent.com/ebi-wp/webservice-clients/master/perl/lwp/ebeye_lwp.pl \
 && wget https://raw.githubusercontent.com/ebi-wp/webservice-clients/master/java/jar/EBeye_JAXRS-source.jar \
 && wget https://raw.githubusercontent.com/ebi-wp/webservice-clients/master/java/jar/EBeye_JAXRS.jar \
 && wget https://raw.githubusercontent.com/ebi-wp/webservice-clients/master/java/jar/ebiws-lib.zip
RUN ln -s ebeye_requests.py ebisearch.py \
 && ln -s ebeye_lwp.pl ebisearch.pl \
 && ln -s EBeye_JAXRS.jar ebisearch.jar
RUN unzip ebiws-lib.zip

# TODO Get dbfetch Java client
RUN ant; exit 0
RUN ant -lib lib && rm -rf bin
RUN chmod +x *.py *.pl *.jar
ENV PATH="/webservice-clients-generator/dist:${PATH}"
