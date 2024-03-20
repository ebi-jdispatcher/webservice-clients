################################################################################
# Dockerfile
# Software: EMBL-EBI Job Dispatcher Web Service Clients
# Website:  https://github.com/ebi-jdispatcher/webservice-clients
# Build:    docker build -t webservice-clients:latest .
# Run:      docker run --rm -it --entrypoint /bin/bash webservice-clients:latest
################################################################################

FROM ubuntu:20.04

LABEL base_image="EMBL-EBI Job Dispatcher Web Service Clients" \
    software="ebi-webservice-clients" \
    container="ebiwp/webservice-clients" \
    about.summary="A collection of Web Service Clients to consume EBI's Job Dispatcher tools" \
    about.home="https://www.ebi.ac.uk/jdispatcher" \
    about.documentation="https://www.ebi.ac.uk/jdispatcher/docs" \
    software.version="1.0.0" \
    version="1" \
    about.copyright="Copyright EMBL-EBI 2024" \
    about.license="Apache-2.0" \
    about.license_file="/usr/src/doc/LICENSE" \
    about.tags="ebi" \
    extra.identifier.biotools="jdispatcher"

ENV TZ=Europe/London \
  DEBIAN_FRONTEND=noninteractive

# Dependencies
RUN apt-get update --fix-missing \
  && apt-get install -y build-essential curl unzip make gcc g++
RUN apt-get -y upgrade \
  && apt-get install -y perl libcrypt-ssleay-perl python3-pip default-jdk

# Perl Dependencies
RUN apt-get install -y cpanminus \
 && cpanm XML::Parser Bundle::LWP REST::Client XML::Simple YAML::Syck

# Python Dependencies
RUN ln -s /usr/bin/pip3 /usr/bin/pip \
 && ln -s /usr/bin/python3 /usr/bin/python \
 && pip install --upgrade pip xmltramp2 requests

# Copying clients
RUN mkdir -p /dist
WORKDIR /dist
COPY python/*.py ./
COPY perl/*.pl ./
COPY java/*.jar ./
RUN chmod +x *.py *.pl *.jar

ENV PATH="/dist:${PATH}"
