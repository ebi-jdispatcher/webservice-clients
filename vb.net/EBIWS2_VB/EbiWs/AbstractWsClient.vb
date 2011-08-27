' $Id$
' ======================================================================
' Common structure and methods for JDispatcher SOAP clients.
'
' See:
' http://www.ebi.ac.uk/Tools/webservices/
' http://www.ebi.ac.uk/Tools/webservices/tutorials/vb.net
' ======================================================================

Option Explicit On
Option Strict On

Imports System


Namespace EbiWs
	Public MustInherit Class AbstractWsClient
	
		Public Sub New()
			MyBase.New
		End Sub
	End Class
End Namespace
