C# .NET Sample Clients
======================

Sample clients for a selection of EMBL-EBI SOAP web services implemented in 
C# for .NET.

Service Stubs
-------------

Due to issues with the Mono versions of wsdl.exe (see Notes) the required 
service stubs have been generated using the Microsoft SDK and checked-in to 
the repository. To regenerate, open an Microsoft SDK environment CMD window, 
change to the root directory of the solution and enter:

  cd EbiWS
  nmake -f Makefile.ms_sdk clean-stubs
  nmake -f Makefile.ms_sdk stubs

The resulting WebReference\*\Reference.cs files will be used in subsequent 
compiles.

Building
--------

For Mono environments (assumes gmcs is on the path). Build with make:

  make -f Makefile.mono

or with xbuild using the MonoDevelop/Visual Studio solution:

  xbuild EBIWS2_CSharp.sln

For builds using the Microsoft SDK, open a CMD window with the SDK environment 
and change to the root directory of the solution. Then to build with make:

  nmake -f Makefile.ms_sdk

or using msbuild to compile the MonoDevelop/Visual Studio solution:

  msbuild EBIWS2_CSharp.sln

Notes
-----

A. Issues observed in Mono environments.

1. Mono 2.4 (Ubuntu 10.04 LTS) fails to generate stubs ("Web References") 
using wsdl.exe or wsdl2.exe with a error relating to WS-I Basic Profile 
check R2305. This issue has been reported as a Mono bug, see: 
https://bugzilla.novell.com/show_bug.cgi?id=569533, and appears to be fixed 
in more recent versions (e.g. 2.6.7) although they now incorrectly (confirmed 
with the WS-I tools) report that the services fail the R2305 compliance check.

2. Generation of client stubs ("Web References") for the document/literal 
wrapper SOAP services using Mono 2.6 wsdl.exe/wsdl2.exe generates code 
which fails to compile correctly. Some of the types are incorrectly generated.

Support
-------

If you have problems with the clients or any suggestions for our web services
then please contact us via the Support form http://www.ebi.ac.uk/support/

---
$Id$
