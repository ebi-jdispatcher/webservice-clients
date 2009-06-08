# $Id$
# ======================================================================
#
# Makefile to build C# EBI Web Services clients using Mono.
#
# ======================================================================

# C# compiler
CSC = gmcs
# C# compiler flags
CSFLAGS = -r:System.Web.Services
# WSDL to C# tool
WSDL2CS = wsdl
# WSDL to C# flags
WSDL2CSFLAGS = -namespace:EbiWS

# Directory for compiled binaries
BINDIR = bin
DEBUGBINDIR = $(BINDIR)/Debug
RELEASEBINDIR = $(BINDIR)/Release
# Directory for generated stubs code
STUBSRCDIR = WebReferences

# Base URL of WSDLs
WSDLBASE = "http://wwwdev.ebi.ac.uk/Tools/services/soap"

all: EbiWS

### EbiWS ###

EbiWS: $(DEBUGBINDIR)/EbiWS.dll $(RELEASEBINDIR)/EbiWS.dll

coreSrc =  AbstractWsClient.cs NcbiBlastClient.cs
stubSrc = \
$(STUBSRCDIR)/FastaWs/Reference.cs \
$(STUBSRCDIR)/NcbiBlastWs/Reference.cs \
$(STUBSRCDIR)/WuBlastWs/Reference.cs

$(DEBUGBINDIR)/EbiWS.dll: $(coreSrc) $(stubSrc)
	mkdir -p $(DEBUGBINDIR)
	$(CSC) $(CSFLAGS) -debug -target:library -out:$@ $(coreSrc) $(stubSrc)

$(RELEASEBINDIR)/EbiWS.dll: $(coreSrc) $(stubSrc)
	mkdir -p $(RELEASEBINDIR)
	$(CSC) $(CSFLAGS) -target:library -out:$@ $(coreSrc) $(stubSrc)

$(STUBSRCDIR)/FastaWs/Reference.cs:
	$(WSDL2CS) $(WSDL2CSFLAGS).FastaWs -out:$@ "$(WSDLBASE)/fasta?wsdl"

$(STUBSRCDIR)/NcbiBlastWs/Reference.cs:
	$(WSDL2CS) $(WSDL2CSFLAGS).NcbiBlastWs -out:$@ "$(WSDLBASE)/ncbiblast?wsdl"
$(STUBSRCDIR)/WuBlastWs/Reference.cs:
	$(WSDL2CS) $(WSDL2CSFLAGS).WuBlastWs -out:$@ "$(WSDLBASE)/wublast?wsdl"
