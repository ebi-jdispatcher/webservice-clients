FROM perl:latest 
MAINTAINER EMBL-EBI, Wep production Team support@ebi.ac.uk

# Dependencies
RUN apt-get update  

#RUN chown -R www-data:www-data /var/lib/nginx

#RUN apt-get  Bundle::LWP REST::Client XML::Simple YAML::Syck JSON::XS  
#RUN cpanm Bundle::LWP REST::Client XML::Simple YAML::Syck JSON::XS  
  
WORKDIR /usr/src/ebi-webservice-clients
ENV PATH="/usr/src/ebi-webservice-clients/:${PATH}"

COPY ./perl/lwp/*.pl /usr/src/ebi-webservice-clients/perl/
# package secondary tools for linking the perl scripts
#COPY ./*.sh /usr/src/ebi-webservice-clients/
#RUN chmod +x /usr/src/ebi-webservice-clients/*.*
