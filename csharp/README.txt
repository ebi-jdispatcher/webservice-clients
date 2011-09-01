.NET C# Clients
===============

A set of sample EBI Web Services clients developed in C# for .NET environments.

See http://www.ebi.ac.uk/Tools/webservices/

Development Platform
--------------------

The code base is packaged as a Visual Studio 2005 solution. This is
importable into Visual Studio 2008, and usable in MonoDevelop and SharpDevelop.

The solution contains a number of projects:
  - EbiWS: core clients library
  - EBeyeCliClient: Command-line client for the EB-eye service. 
  - FastaCliClient: Command-line client for the FASTA service. 
  - NcbiBlastCliClient: Command-line client for the NCBI BLAST service. 
  - WuBlastCliClient: Command-line client for the WU-BLAST service. 

Building Clients
----------------

The solution can be built using an IDE which understands Visual Studio
2005 solutions/projects, for example MonoDevelop, SharpDevelop or Visual 
Studio (including Express).

The Microsoft Build Engine (MSBUILD) or the open source xbuild 
(http://www.mono-project.com/Microsoft.Build) can also be able to build the 
solution and its projects.

For plain .NET SDK and Mono environments a set of make files are
provided for MS Windows and Linux which can be invoked as follows:

- MS .NET SDK
From the SDK "CMD Shell"
  nmake -f Makefile.ms_sdk

- Mono
From a terminal
  make -f Makefile.mono

Running Clients
---------------

For the command-line clients, open a shell window and directly run the
exe:
  NcbiBlastCliClient.exe

On Mono based environments it may be necessary to call 'mono' to run
the exe:
  mono NcbiBlastCliClient.exe

Packaging Clients
-----------------

The projects generate a core dll (EbiWS.dll) and a set of command-line clients
which depend on this dll. To make distribution and installation easier the
clients in the bin/ directory are processed using monomerge.exe 
(http://evain.net/blog/articles/2006/11/06/an-introduction-to-mono-merge) to 
create single exe files which include the dll code. A makefile 
(bin/Makefile.mono) to perform this task is provided. A similar taks can be 
performed on MS Windows using ILMerge 
(http://research.microsoft.com/en-us/people/mbarnett/ilmerge.aspx).

Support
-------

If you have problems with the clients or any suggestions for our web services
then please contact us via the Support form http://www.ebi.ac.uk/support/

---
$Id$
