' $Id$
' ======================================================================
' NCBI BLAST (SOAP) Visual Basic .NET client.
'
' See:
' http://www.ebi.ac.uk/Tools/webservices/services/sss/ncbi_blast_soap
' http://www.ebi.ac.uk/Tools/webservices/tutorials/vb.net
' ======================================================================

Option Explicit On
Option Strict On

Imports System

Namespace EbiWs
	Public Class NcbiBlastClient
		Inherits AbstractWsClient
	
		Public Sub New()
			MyBase.New
		End Sub
	End Class
End Namespace
