' $Id$
' ======================================================================
' WSDbfetch Visual Basic .NET client.
'
' See:
' http://www.ebi.ac.uk/Tools/webservices/services/dbfetch
' http://www.ebi.ac.uk/Tools/webservices/tutorials/vb.net
' ======================================================================

Option Explicit On
Option Strict On

Imports System
Imports EbiWS.WSDbfetchWs ' "Web Reference" or wsdl.exe generated stubs.

Namespace EbiWS
	Public Class WSDbfetchClient
		' Output level
		Public Property OutputLevel() As Integer
			Get
				Return _outputLevel
			End Get
			Set (ByVal value As Integer)
				If value > -1 Then
					_outputLevel = value
				End If
			End Set
		End Property
		Private _outputLevel As Integer = 1
		' Debug output level.
		Public Property DebugLevel() As Integer
			Get
			Return _debugLevel
		End Get
			Set (ByVal value As Integer)
				If value > -1 Then
					_debugLevel = value
				End If
			End Set
		End Property
		Private _debugLevel As Integer = 0
		' SOAP service endpoint for requests.
		Public Property ServiceEndPoint() As String
			Get
				Return _serviceEndPoint
			End Get
			Set (ByVal value As String)
				_serviceEndPoint = value
			End Set
		End Property
		Private _serviceEndPoint As String = Nothing
		' Web service proxy
		Public Property SrvProxy() As EbiWS.WSDbfetchWs.WSDBFetchDoclitServerService
			Get
				Return _srvProxy
			End Get
			Set (ByVal value As EbiWS.WSDbfetchWs.WSDBFetchDoclitServerService)
				_srvProxy = value
			End Set
		End Property
		Private _srvProxy As EbiWS.WSDbfetchWs.WSDBFetchDoclitServerService = Nothing
		' Client object revision/version.
		Private revision As String = "$Revision$"
		
		' Default constructor.
		Public Sub New()
			MyBase.New
			Me.OutputLevel = 1 ' Normal output.
			Me.DebugLevel = 0  ' Debug output off.
		End Sub
		
		' Print a debug message at the specified level.
		Sub PrintDebugMessage(ByVal methodName As String, ByVal message As String, ByVal level As Integer)
			If level <= Me.DebugLevel Then
				Console.Error.WriteLine("[{0}()] {1}", methodName, message)
			End If
		End Sub

		' Print a progress message, at the specified output level.
		Sub PrintProgressMessage(ByVal message As String, ByVal level As Integer)
			If level <= Me.OutputLevel Then
				Console.WriteLine(message)
			End If
		End Sub

		' Get the service connection. Has to be called before attempting to use any of the service operations.
		Protected Sub ServiceProxyConnect()
			PrintDebugMessage("ServiceProxyConnect", "Begin", 11)
			If Me.SrvProxy Is Nothing Then
				Me.SrvProxy = New EbiWS.WSDbfetchWs.WSDBFetchDoclitServerService()
				If Me.ServiceEndPoint IsNot Nothing And Me.ServiceEndPoint.Length > 0 Then
					Me.SrvProxy.Url = Me.ServiceEndPoint
				End If
				Me.ServiceEndPoint = Me.SrvProxy.Url
				PrintDebugMessage("ServiceProxyConnect", "ServiceEndPoint: " & Me.ServiceEndPoint, 12)
				PrintDebugMessage("ServiceProxyConnect", "SrvProxy: " & Me.SrvProxy.ToString(), 12)
				SetProxyUserAgent() ' Set user-agent for client.
			End If
			PrintDebugMessage("ServiceProxyConnect", "End", 11)
		End Sub
		
		' Set User-agent for web service proxy.
		Private Sub SetProxyUserAgent()
			PrintDebugMessage("SetProxyUserAgent", "Begin", 11)
			Dim userAgent As String = constuctUserAgentStr(revision, Me.GetType().Name, Me.SrvProxy.UserAgent)
			PrintDebugMessage("SetProxyUserAgent", "userAgent: " & userAgent, 12)
			Me.SrvProxy.UserAgent = userAgent
			PrintDebugMessage("SetProxyUserAgent", "End", 11)
		End Sub

		' Construct a User-agent string for the client.
		Protected Function constuctUserAgentStr(ByVal revision As String, ByVal clientClassName As String, ByVal userAgent As String) As String
			PrintDebugMessage("constuctUserAgentStr", "Begin", 31)
			Dim retUserAgent As String = "EBI-Sample-Client"
			Dim clientVersion As String = "0"
			' Client version.
			If revision IsNot Nothing And revision.Length > 0 Then
				' CVS/Subversion revision tag.
				If revision.StartsWith("$") Then
					' Populated tag, extract revision number.
					If revision.Length > 13 Then
						clientVersion = revision.Substring(11, (revision.Length - 13))
					End If
				' Alternative revision/version string.
				Else
					clientVersion = revision
				End If
			End If
			Dim strBuilder As StringBuilder = New StringBuilder()
			strBuilder.Append(retUserAgent & "/" & clientVersion)
			strBuilder.Append(" (" & clientClassName & "; VB.NET; " & Environment.OSVersion.ToString)
			If userAgent Is Nothing Or userAgent.Length < 1 Then ' No agent
				strBuilder.Append(")")
			ElseIf userAgent.Contains("(") Then ' MS .NET
				strBuilder.Append(") " & userAgent)
			Else ' Mono
				strBuilder.Append("; " & userAgent & ")")
			End If
			retUserAgent = strBuilder.ToString
			PrintDebugMessage("constuctUserAgentStr", "retUserAgent: " & retUserAgent, 32)
			PrintDebugMessage("constuctUserAgentStr", "End", 31)
			Return retUserAgent
		End Function
	
		' Get list of database names from sevice.
		Public Function GetSupportedDBs() As String()
			PrintDebugMessage("GetSupportedDBs", "Begin", 1)
			ServiceProxyConnect()
			Dim dbNameList() As String
			dbNameList = Me.SrvProxy.getSupportedDBs()
			If dbNameList Is Nothing Then
				Console.Error.WriteLine("Error: Null returned by web service")
				dbNameList = New String() {} ' Replace with an empty array.
			End If
			PrintDebugMessage("GetSupportedDBs", "got " & dbNameList.Length & " db names", 2)
			PrintDebugMessage("GetSupportedDBs", "End", 1)
			Return dbNameList
		End Function
		
		' Print list of available search databases.
		Public Sub PrintGetSupportedDBs()
			PrintDebugMessage("PrintGetSupportedDBs", "Begin", 1)
			Dim result As String()
			result = Me.GetSupportedDBs()
			PrintStrList(result)
			PrintDebugMessage("PrintGetSupportedDBs", "End", 1)
		End Sub
		
		' Get list of database and format names from sevice.
		Public Function GetSupportedFormats() As String()
			PrintDebugMessage("GetSupportedFormats", "Begin", 1)
			ServiceProxyConnect()
			Dim nameList As String()
			nameList = Me.SrvProxy.getSupportedFormats()
			If nameList Is Nothing Then
				Console.Error.WriteLine("Error: Null returned by web service.")
				nameList = New String() {} ' Replace with an empty array.
			End If
			PrintDebugMessage("GetSupportedFormats", "got " & nameList.Length & " names", 2)
			PrintDebugMessage("GetSupportedFormats", "End", 1)
			Return nameList
		End Function
		
		' Print list of available search databases and formats.
		Public Sub PrintGetSupportedFormats()
			PrintDebugMessage("PrintGetSupportedFormats", "Begin", 1)
			Dim result As String()
			result = Me.GetSupportedFormats()
			PrintStrList(result)
			PrintDebugMessage("PrintGetSupportedFormats", "End", 1)
		End Sub
		
		' Get list of database and style names from sevice.
		Public Function GetSupportedStyles() As String()
			PrintDebugMessage("GetSupportedStyles", "Begin", 1)
			ServiceProxyConnect()
			Dim nameList As String()
			nameList = Me.SrvProxy.getSupportedStyles()
			If nameList Is Nothing Then
				Console.Error.WriteLine("Error: Null returned by web service.")
				nameList = New String() {} ' Replace with an empty array.
			End If
			PrintDebugMessage("GetSupportedStyles", "got " & nameList.Length & " names", 2)
			Return nameList
		End Function
		
		' Print list of available search databases and styles.
		Public Sub PrintGetSupportedStyles()
			PrintDebugMessage("PrintGetSupportedStyles", "Begin", 1)
			Dim result As String()
			result = Me.GetSupportedStyles()
			PrintStrList(result)
			PrintDebugMessage("PrintGetSupportedStyles", "End", 1)
		End Sub

		' Get list of format names for a database.
		Public Function GetDbFormats(ByVal dbName As String) As String()
			PrintDebugMessage("GetDbFormats", "Begin", 1)
			ServiceProxyConnect()
			Dim nameList As String()
			nameList = Me.SrvProxy.getDbFormats(dbName)
			If nameList Is Nothing Then
				Console.Error.WriteLine("Error: Null returned by web service.")
				nameList = New String() {} ' Replace with an empty array.
			End If
			PrintDebugMessage("GetDbFormats", "got " & nameList.Length & " names", 2)
			PrintDebugMessage("GetDbFormats", "End", 1)
			Return nameList
		End Function

		' Print list of available format names for a database.
		Public Sub PrintGetDbFormats(ByVal dbName As String)
			PrintDebugMessage("PrintGetDbFormats", "Begin", 1)
			Dim result As String()
			result = Me.GetDbFormats(dbName)
			PrintStrList(result)
			PrintDebugMessage("PrintGetDbFormats", "End", 1)
		End Sub
		
		' Get list of style names for a format of a database.
		Public Function GetFormatStyles(ByVal dbName As String, ByVal formatName As String) As String()
			PrintDebugMessage("GetFormatStyles", "Begin", 1)
			ServiceProxyConnect()
			Dim nameList As String()
			nameList = Me.SrvProxy.getFormatStyles(dbName, formatName)
			If nameList Is Nothing Then
				Console.Error.WriteLine("Error: Null returned by web service.")
				nameList = New String() {} ' Replace with an empty array.
			End If
			PrintDebugMessage("GetFormatStyles", "got " & nameList.Length & " names", 2)
			PrintDebugMessage("GetFormatStyles", "End", 1)
			Return nameList
		End Function
		
		' Print list of available style names for a format of a database.
		Public Sub PrintGetFormatStyles(ByVal dbName As String, ByVal formatName As String)
			PrintDebugMessage("PrintGetFormatStyles", "Begin", 1)
			Dim result As String()
			result = Me.GetFormatStyles(dbName, formatName)
			PrintStrList(result)
			PrintDebugMessage("PrintGetFormatStyles", "End", 1)
		End Sub
		
		' Fetch an entry.
		Public Function FetchData(ByVal query As String, ByVal formatName As String, ByVal styleName As String) As String
			PrintDebugMessage("FetchData", "Begin", 1)
			ServiceProxyConnect()
			Dim entryStr As String
			entryStr = Me.SrvProxy.fetchData(query, formatName, styleName)
			If entryStr Is Nothing Then
				Console.Error.WriteLine("Error: Null returned by web service.")
			End If
			PrintDebugMessage("FetchData", "End", 1)
			Return entryStr
		End Function
		
		' Print an entry.
		Public Sub PrintFetchData(ByVal query As String, ByVal formatName As String, ByVal styleName As String)
			PrintDebugMessage("PrintFetchData", "Begin", 1)
			Dim result As String
			result = Me.FetchData(query, formatName, styleName)
			Console.WriteLine(result)
			PrintDebugMessage("PrintFetchData", "End", 1)
		End Sub

		' Fetch a set of entries.
		Public Function FetchBatch(ByVal dbName As String, ByVal idListStr As String, ByVal formatName As String, ByVal styleName As String) As String
			PrintDebugMessage("FetchBatch", "Begin", 1)
			ServiceProxyConnect()
			Dim entriesStr As String
			entriesStr = Me.SrvProxy.fetchBatch(dbName, idListStr, formatName, styleName)
			If entriesStr Is Nothing Then
				Console.Error.WriteLine("Error: Null returned by web service.")
			End If
			PrintDebugMessage("FetchBatch", "End", 1)
			Return entriesStr
		End Function
		
		' Print a set of entries.
		Public Sub PrintFetchBatch(ByVal dbName As String, ByVal idListStr As String, ByVal formatName As String, ByVal styleName As String)
			PrintDebugMessage("PrintFetchBatch", "Begin", 1)
			Dim result As String
			result = Me.FetchBatch(dbName, idListStr, formatName, styleName)
			Console.WriteLine(result)
			PrintDebugMessage("PrintFetchBatch", "End", 1)
		End Sub

		' Print a list of strings
		Private Sub PrintStrList(ByVal strList As String())
			PrintDebugMessage("PrintStrList", "Begin", 21)
			If strList IsNot Nothing AndAlso strList.Length > 0 Then
				For Each item As String In strList
					If item IsNot Nothing AndAlso item <> "" Then
						Console.WriteLine(item)
					End If
				Next
			End If
			PrintDebugMessage("PrintStrList", "End", 21)
		End Sub
	End Class
End Namespace