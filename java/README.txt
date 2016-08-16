Java Clients
============

A set of sample EBI Web Services clients developed in Java.

See http://www.ebi.ac.uk/Tools/webservices/

Building Clients
----------------

An Apache ant (http://ant.apache.org/) build file (build.xml) is used to 
perform the build, with Apache Ivy (http://ant.apache.org/ivy/) being used to 
manage library dependencies (see ivy.xml).

1. Generate the stubs from the WSDLs.

Generate stubs from service description documents (WSDL) for all the SOAP 
toolkits:

  ant stubs

Generate stubs for a specific SOAP library, e.g. Apache Axis 1.x:

  ant axis1-stubs

Generate stubs for a specific service for a specific library, e.g. WU-BLAST 
(SOAP):

  ant axis1-stubs-wublast

Note: since ant does not support remote dependency checking, and many of the 
WSDLs are dynamic documents, the stubs are re-generated each time these 
targets are called.

2. Compile

  ant

or

  ant compile

If compilation fails it might have happened that one of the webservices was retired, in such case:
 - we did not generate correct stub for the tool
 - we need to remobe classes of the tool and references to it in build.xml

To compile just the code for one of the SOAP libraries, e.g. Apache Axis 1.x:

  ant axis1-compile

3. Compile and package into jars:

  ant jar

To package just the code for one of the SOAP libraries, e.g. Apache Axis 1.x:

  ant axis1-jar

4. Package the dependencies downloaded by Apache Ivy:

  ant package-dependencies
  
5. Test the generated client jars:

  ant test
  
To test just the jars for one of the SOAP libraries, e.g. Apache Axis 1.x:

  ant axis1-test

To test just the jar for a specific service and SOAP library, e.g. WU-BLAST 
(SOAP) using Apache Axis 1.x:

  ant axis1-test-wublast

Running Clients
---------------

To run a client the required jars (lib/) need to be added to the classpath. A
simple way to do this is to set the java.ext.dirs property to include the
directory containing the jars. For example:

  java -Djava.ext.dirs=lib/ -jar jar/WSDbfetch.jar

For JAX-WS under Java 5, the JAX-WS libraries also need to be included in the
path list specified for java.ext.dirs, since these are not provided as part 
of the Java installation. The JAX-WS libraries can be obtained from 
https://jax-ws.dev.java.net/.

Support
-------

If you have problems with the clients or any suggestions for our Web Services
then please contact us via the Support form http://www.ebi.ac.uk/support/

---
$Id$
