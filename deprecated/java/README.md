# EBI Search REST Webservice client Sample [![java](https://img.shields.io/badge/java-1.8-blue.svg?style=flat)]()

A sample client written in java Java.

See https://www.ebi.ac.uk/ebisearch/swagger.ebi

## Building Clients

Apache Maven is required to build the project

### 1. Compile and packaging

The client can be compiled and packaged with the command:

```
mvn install
```

packaged archive will be copied in the folder ./jar/


### 1. Clean

To clean the project folder, run the command:

```
mvn clean
```
The `target` and `jar` folders will be deleted



## Running Clients

To run the client, run the command

```
java -jar jar/jaxrs-client-<version>-with-dependencies.jar
```

## Client integration

In case the user want to integrate the client in another application it can use the following artifacts:

 * jar/jaxrs-client-<version>.jar: it contain the EBI Search client code
 * jar/jaxrs-client-<version>-dependencies-libs.zip: it's a list of all the libraries needed to run the client

As an alternative the user can integrate the client using the maven `pom.xml` file to resolve the dependencies


## Contact and Support

If you have problems with the clients or any suggestions for our Web Services
then please contact us via the Support form http://www.ebi.ac.uk/support/
