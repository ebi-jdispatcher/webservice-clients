# $Id$
# ======================================================================
#
# Makefile to build C# WU-BLAST client using Mono.
#
# ======================================================================

# C# compiler
CSC = gmcs
# C# compiler flags
CSFLAGS = -r:System.Web.Services

# Directory for compiled binaries
BINDIR = bin
DEBUGBINDIR = $(BINDIR)/Debug
RELEASEBINDIR = $(BINDIR)/Release

# Core assembly project
EBIWS = ../EbiWS

all: WuBlastCliClient

### WU-BLAST command-line client ###

WuBlastCliClient: $(DEBUGBINDIR)/WuBlastCliClient.exe $(RELEASEBINDIR)/WuBlastCliClient.exe

$(DEBUGBINDIR)/WuBlastCliClient.exe: WuBlastCliClient.cs $(DEBUGBINDIR)/EbiWS.dll
	mkdir -p $(DEBUGBINDIR)
	$(CSC) $(CSFLAGS) -debug -target:exe -reference:$(DEBUGBINDIR)/EbiWS.dll -out:$@ WuBlastCliClient.cs

$(DEBUGBINDIR)/EbiWS.dll: $(EBIWS)/$(DEBUGBINDIR)/EbiWS.dll
	mkdir -p $(DEBUGBINDIR)
	cp $(EBIWS)/$(DEBUGBINDIR)/EbiWS.dll* $(DEBUGBINDIR)/

$(RELEASEBINDIR)/WuBlastCliClient.exe: WuBlastCliClient.cs $(RELEASEBINDIR)/EbiWS.dll
	mkdir -p $(RELEASEBINDIR)
	$(CSC) $(CSFLAGS) -target:exe -reference:$(RELEASEBINDIR)/EbiWS.dll -out:$@ WuBlastCliClient.cs

$(RELEASEBINDIR)/EbiWS.dll: $(EBIWS)/$(RELEASEBINDIR)/EbiWS.dll
	mkdir -p $(RELEASEBINDIR)
	cp $(EBIWS)/$(RELEASEBINDIR)/EbiWS.dll* $(RELEASEBINDIR)/
