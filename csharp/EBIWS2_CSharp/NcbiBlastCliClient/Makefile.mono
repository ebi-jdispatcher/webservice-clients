# $Id$
# ======================================================================
#
# Makefile to build C# NCBI BLAST client using Mono.
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

all: NcbiBlastCliClient

### NCBI BLAST command-line client ###

NcbiBlastCliClient: $(DEBUGBINDIR)/NcbiBlastCliClient.exe $(RELEASEBINDIR)/NcbiBlastCliClient.exe

$(DEBUGBINDIR)/NcbiBlastCliClient.exe: NcbiBlastCliClient.cs $(DEBUGBINDIR)/EbiWS.dll
	mkdir -p $(DEBUGBINDIR)
	$(CSC) $(CSFLAGS) -debug -target:exe -reference:$(DEBUGBINDIR)/EbiWS.dll -out:$@ NcbiBlastCliClient.cs

$(DEBUGBINDIR)/EbiWS.dll: $(EBIWS)/$(DEBUGBINDIR)/EbiWS.dll
	mkdir -p $(DEBUGBINDIR)
	cp $(EBIWS)/$(DEBUGBINDIR)/EbiWS.dll* $(DEBUGBINDIR)/

$(RELEASEBINDIR)/NcbiBlastCliClient.exe: NcbiBlastCliClient.cs $(RELEASEBINDIR)/EbiWS.dll
	mkdir -p $(RELEASEBINDIR)
	$(CSC) $(CSFLAGS) -target:exe -reference:$(RELEASEBINDIR)/EbiWS.dll -out:$@ NcbiBlastCliClient.cs

$(RELEASEBINDIR)/EbiWS.dll: $(EBIWS)/$(RELEASEBINDIR)/EbiWS.dll
	mkdir -p $(RELEASEBINDIR)
	cp $(EBIWS)/$(RELEASEBINDIR)/EbiWS.dll* $(RELEASEBINDIR)/

clean:
	find . -name '*~' -exec rm {} \;

distclean: clean
	rm -rf $(DEBUGBINDIR) $(RELEASEBINDIR) bin/
