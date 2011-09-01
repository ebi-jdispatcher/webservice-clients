Visual Basic .NET Sample Clients
================================

Service Stubs
-------------

Due to issues with the Mono versions of wsdl.exe the required service stubs are generated using the Microsoft SDK and checked-in to the repository. To regenerate:

  cd EbiWS
  nmake -f Makefile.ms_sdk clean-stubs
  nmake -f Makefile.ms_sdk

The resulting WebReference\*\Reference.vb files can then be checked-in.

Building
--------

For Mono environments (assumes vbnc is on the path). Build with make:

  make -f Makefile.mono

or with xbuild:

  xbuild EBIWS2_VB.sln

For builds using the Microsoft SDK, open a CMD window with the SDK environment. To build with make:

  nmake -f Makefile.ms_sdk

or using the MS Project build:

  msbuild EBIWS2_VB.sln
