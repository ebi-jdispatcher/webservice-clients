Java Clients
============

A set of sample EBI Web Services clients developed in Java.

See http://www.ebi.ac.uk/Tools/webservices/

Building Clients
----------------

To keep the build process simple we use Apache ant to perform the build.

1. Generate the stubs from the WSDLs.

Generate all the stubs:

  ant stubs-all

Generate stubs for a specific service, e.g. WSWUBlast:

  ant stubs-wswublast

Note: since ant does not support remote dependency checking the stubs will
be re-generated each time this target is called.

2. Compile and package into jars:

  ant

or

  ant jars

Running Clients
---------------

To run a client the required jars (lib/) need to be added to the classpath. A
simple way to do this is to set the java.ext.dirs property to include the
directory containing the jars. For example:

  java -Djava.ext.dirs=lib/ -jar bin/WSDbfetch.jar

Support
-------

If you have problems with the clients or any suggestions for our web services
then please contact us via the Support form http://www.ebi.ac.uk/support/
