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
    about.copyright="Copyright EMBL-EBI 2019" \
    about.license="Apache-2.0" \
    about.license_file="/usr/src/doc/LICENSE" \
    about.tags="ebi" \
    extra.identifier.biotools="ebi_tools"

# Dependencies
RUN apt-get update --fix-missing \
  && apt-get install -y build-essential curl unzip make gcc g++
RUN apt-get -y upgrade \
  && apt-get install -y perl libcrypt-ssleay-perl python3-pip default-jdk

# Perl Dependencies
RUN curl -L https://cpanmin.us | perl - App::cpanminus \
 && cpanm Bundle::LWP REST::Client XML::Simple YAML::Syck

# Python Dependencies
RUN ln -s /usr/bin/pip3 /usr/bin/pip \
 && ln -s /usr/bin/python3 /usr/bin/python \
 && pip install --upgrade pip xmltramp2 requests

# Copying clients
RUN mkdir -p /dist
COPY python/*.py /dist/
COPY perl/*.pl /dist/
COPY java/*.jar /dist/

# Adding EBI Search clients
COPY python/requests/ebeye_requests.py /dist/ebisearch.py
COPY perl/lwp/ebeye_lwp.pl /dist/ebisearch.pl
COPY deprecated/java/jar/jaxrs-client-*-jar-with-dependencies.jar /dist/ebisearch.jar
COPY deprecated/java/jar/jaxrs-client-*-dependencies-libs.zip /dist/ebiws-lib.zip
WORKDIR /dist
RUN unzip ebiws-lib.zip
RUN chmod +x *.py *.pl *.jar

ENV PATH="/dist:${PATH}"
