.NET C# Clients
===============

A set of sample EBI Web Services clients developed in C# for .NET environments.

See http://www.ebi.ac.uk/Tools/webservices/

Development Platform
--------------------

Thye code base is packages as a Visual Studio 2005 solution. This is
importable into Visual Studio 2008, and usable in MonoDevelop and SharpDevelop.

The solution contains a number of projects:
  - AbstractWsClient: a abstrct defintion of a tool web service client
  - NcbiBlastClient: client for the NCBI BLAST service. 

Building Clients
----------------

The solution can be built using an IDE which understands Visual Studio
2005 solutions/projects.

For plain .NET SDK and Mono environments a set of make files are
supplied for MS Windows and Linux which can be invoked as follows:

MS .NET SDK

From the SDK "CMD Shell"
  nmake -f Makefile.ms_sdk

Mono

From a terminal
  make -f Makefile.mono

Running Clients
---------------

For the command-line clients, open a shell window and directly run the
exe:
  NcbiBlastClient.exe

On Mono based environments it may be necessary to call 'mono' to run
the exe:
  mono NcbiBlastClient.exe

Support
-------

If you have problems with the clients or any suggestions for our web services
then please contact us via the Support form http://www.ebi.ac.uk/support/
