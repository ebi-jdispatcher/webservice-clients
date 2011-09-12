Visual Basic .NET Sample Clients
================================

Sample clients for a selection of EMBL-EBI SOAP web services implemented in 
Visual Basic .NET.

Service Stubs
-------------

Due to issues with the Mono versions of wsdl.exe (see Notes) the required 
service stubs have been generated using the Microsoft SDK and checked-in to 
the repository. To regenerate, open an Microsoft SDK environment CMD window, 
change to the root directory of the solution and enter:

  cd EbiWS
  nmake -f Makefile.ms_sdk clean-stubs
  nmake -f Makefile.ms_sdk stubs

The resulting WebReference\*\Reference.vb files will be used in subsequent 
compiles.

Building
--------

For Mono environments (assumes vbnc is on the path). Build with make:

  make -f Makefile.mono

or with xbuild using the MonoDevelop/Visual Studio solution:

  xbuild EBIWS2_VB.sln

For builds using the Microsoft SDK, open a CMD window with the SDK 
environment. To build with make:

  nmake -f Makefile.ms_sdk

or with msbuild using the MonoDevelop/Visual Studio solution:

  msbuild EBIWS2_VB.sln

Notes
-----

A. Issues observed in Mono environments.

1. Mono 2.4 (Ubuntu 10.04 LTS) fails to generate stubs ("Web References") 
using wsdl.exe or wsdl2.exe with a error relating to WS-I Basic Profile 
check R2305. This issue has been reported as a Mono bug, see: 
https://bugzilla.novell.com/show_bug.cgi?id=569533, and appears to be fixed 
in more recent versions (e.g. 2.6.7) although they now incorrectly report that 
the services fail the R2305 compliance check (confirmed with the WS-I tools).

2. While the project builds with Mono 2.x, when using MS SDK generated stubs, 
the clients do not work due to the web service calls all returning null. 
Strangely the equivalent sample clients C# work as expected in these versions, 
suggesting that this is caused by a problem in the Mono VB.NET implementation. 
MS VB.NET compiled clients work as expected, confiriming that this is a 
compiler issue.

3. Generation of client stubs ("Web References") for the document/literal 
wrapper SOAP services using Mono 2.6 wsdl.exe/wsdl2.exe generates VB code 
which fails to compile.

4. Generation of client stubs ("Service References") for the document/literal 
wrapper SOAP services using Mono 2.6 svcutil.exe also generates VB code which 
fails to compile.

5. Provided code will not compile with the Mono 1.2 VB.NET implementation. 
The code uses "Next varName" to close "For" loops and this is not supported 
by the VB compiler used in Mono 1.2. Commenting out the 'varName' will allow 
to compile to complete, However the produced clients so not function 
correctly.

Workaround:
To creste clients that work on both MS .NET and Mono environments, compile 
the project on MS Windows using the MS SDK or Visual Studio. The generated 
.dll and .exe files can then be used on both platforms. Alternativly, since 
the same API is used, the EbiWS.dll from the C# project can be used with the 
VB.NET .exe files to produce working clients.

Support
-------

If you have problems with the clients or any suggestions for our web services
then please contact us via the Support form http://www.ebi.ac.uk/support/

---
$Id$
