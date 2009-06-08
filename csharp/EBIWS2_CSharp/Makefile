# $Id$
# ======================================================================
#
# Makefile to build C# EBI Web Services clients using Mono.
#
# ======================================================================

all: EbiWS \
FastaCliClient/bin/Release/FastaCliClient.exe \
NcbiBlastCliClient/bin/Release/NcbiBlastCliClient.exe \
WuBlastCliClient/bin/Release/WuBlastCliClient.exe

EbiWS:
	cd EbiWS && $(MAKE)

FastaCliClient/bin/Release/FastaCliClient.exe: EbiWS
	cd FastaCliClient && $(MAKE)

NcbiBlastCliClient/bin/Release/NcbiBlastCliClient.exe: EbiWS
	cd NcbiBlastCliClient && $(MAKE)

WuBlastCliClient/bin/Release/WuBlastCliClient.exe: EbiWS
	cd WuBlastCliClient && $(MAKE)
