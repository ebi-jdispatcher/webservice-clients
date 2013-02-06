' $Id$
' ======================================================================
' 
' Copyright 2011-2013 EMBL - European Bioinformatics Institute
'
' Licensed under the Apache License, Version 2.0 (the "License");
' you may not use this file except in compliance with the License.
' You may obtain a copy of the License at
'
'     http://www.apache.org/licenses/LICENSE-2.0
'
' Unless required by applicable law or agreed to in writing, software
' distributed under the License is distributed on an "AS IS" BASIS,
' WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
' See the License for the specific language governing permissions and
' limitations under the License.
' 
' ======================================================================
' EB-eye web services VB.NET client.
'
' See:
' http://www.ebi.ac.uk/Tools/webservices/services/eb-eye
' http://www.ebi.ac.uk/Tools/webservices/tutorials/vb.net
' ======================================================================
Option Explicit On
Option Strict On

Imports Microsoft.VisualBasic.ControlChars ' Character constants (e.g. Tab).
Imports System
Imports System.IO
Imports System.Reflection
Imports System.Text
Imports System.Text.RegularExpressions
Imports EbiWS.EBeyeWs ' "Web Reference" or wsdl.exe generated stubs.

Namespace EbiWS
	' EB-eye web services C# client.
	Public Class EBeyeClient
		' Level of output produced. Used to implment --quiet and --verbose.
		Private _outputLevel As Integer = 1
		Public Property OutputLevel As Integer
			Get
				Return _outputLevel
			End Get
			Set (ByVal value As Integer)
				If value > -1 Then
					_outputLevel = value
				End If
			End Set
		End Property
		' Level of debug output (default off).
		Private _debugLevel As Integer = 0
		Public Property DebugLevel As Integer
			Get
				Return _debugLevel
			End Get
			Set (ByVal value As Integer)
				If value > -1 Then
					_debugLevel = value
				End If
			End Set
		End Property
		' Specified endpoint for the SOAP service. If null the default 
		' endpoint specified in the WSDL (and thus in the generated 
		' stubs) is used.
		Private _serviceEndPoint As String = Nothing
		Public Property ServiceEndPoint As String
			Get
				Return _serviceEndPoint
			End Get
			Set (ByVal value As String)
				_serviceEndPoint = value
			End Set
		End Property
		' Webservice proxy object.
		Private _srvProxy As EBISearchService = Nothing
		Public Property SrvProxy As EBISearchService
			Get
				Return _srvProxy
			End Get
			Set (ByVal value As EBISearchService)
				_srvProxy = value
			End Set
		End Property
		' Client object revision.
		Private revision As String = "$Revision$"
		
		' Default constructor.
		Public Sub New()
			MyBase.New
			OutputLevel = 1 ' Normal output
			DebugLevel = 0 ' Debug output off.
		End Sub
		
		' Print a debug message at the specified level.
        Protected Sub PrintDebugMessage(ByVal methodName As String, ByVal message As String, ByVal level As Integer)
            If level <= DebugLevel Then
                Console.Error.WriteLine("[{0}()] {1}", methodName, message)
            End If
        End Sub

		' Construct a string of the values of an object, both fields and properties.
		Protected Function ObjectValueToString(ByVal obj As Object) As String
			PrintDebugMessage("ObjectValueToString", "Begin", 31)
			Dim strBuilder As StringBuilder = New StringBuilder()
			strBuilder.Append(ObjectFieldsToString(obj))
			strBuilder.Append(ObjectPropertiesToString(obj))
			PrintDebugMessage("ObjectValueToString", "End", 31)
			Return strBuilder.ToString()
		End Function

		' Construct a string of the fields of an object.
		Protected Function ObjectFieldsToString(ByVal obj As Object) As String
			PrintDebugMessage("ObjectFieldsToString", "Begin", 32)
			Dim strBuilder As StringBuilder = New StringBuilder()
			Dim objType As Type = obj.GetType()
			PrintDebugMessage("ObjectFieldsToString", "objType: " & objType.ToString, 33)
			For Each info As System.Reflection.FieldInfo In objType.GetFields()
				PrintDebugMessage("ObjectFieldsToString", "info: " & info.Name, 33)
				If info.FieldType.IsArray Then
                    strBuilder.Append(info.Name & ":" & Environment.NewLine)
                    Dim subObjList As Object() = TryCast(info.GetValue(obj), Object())
                    For Each subObj As Object In subObjList
                        strBuilder.Append(Tab & subObj.ToString)
                    Next subObj
				Else
					strBuilder.Append(info.Name & ": " & info.GetValue(obj).ToString & Environment.Newline)
				End If
			Next info
			PrintDebugMessage("ObjectFieldsToString", "End", 32)
			Return strBuilder.ToString()
		End Function
		
		' Construct a string of the properties of an object.
		Protected Function ObjectPropertiesToString(ByVal obj As Object) As String
			PrintDebugMessage("ObjectPropertiesToString", "Begin", 31)
			Dim strBuilder As StringBuilder = New StringBuilder()
			Dim objType As Type = obj.GetType()
			PrintDebugMessage("ObjectPropertiesToString", "objType: " & objType.ToString, 32)
			For Each info As PropertyInfo In objType.GetProperties()
				PrintDebugMessage("ObjectPropertiesToString", "info: " & info.Name, 32)
				If info.PropertyType.IsArray Then
                    strBuilder.Append(info.Name & ":" & Environment.NewLine)
                    Dim subObjList As Object() = TryCast(info.GetValue(obj, Nothing), Object())
                    For Each subObj As Object In subObjList
                        strBuilder.Append(Tab & subObj.ToString)
                    Next subObj
				Else
                    strBuilder.Append(info.Name & ": " & info.GetValue(obj, Nothing).ToString & Environment.NewLine)
				End If
			Next info
			PrintDebugMessage("ObjectPropertiesToString", "End", 31)
			Return strBuilder.ToString()
		End Function
		
		' Print a progress message, at the specified output level.
		Protected Sub PrintProgressMessage(ByVal msg As String, ByVal level As Integer)
			If OutputLevel >= level Then
				Console.Error.WriteLine(msg)
			End If
		End Sub

		' Get the service connection. Has to be called before attempting to use any of the service operations.
		Protected Sub ServiceProxyConnect()
			PrintDebugMessage("ServiceProxyConnect", "Begin", 11)
			If SrvProxy Is Nothing Then
				SrvProxy = New EBISearchService()
                SrvProxy.EnableDecompression = True  ' Support HTTP compression.
                SetProxyEndPoint() ' Set explicit service endpoint, if defined.
				SetProxyUserAgent() ' Set user-agent for client.
				PrintDebugMessage("ServiceProxyConnect", "SrvProxy: " & SrvProxy.ToString, 12)
			End If
			PrintDebugMessage("ServiceProxyConnect", "End", 11)
		End Sub

		' Set service proxy endpoint.
		Private Sub SetProxyEndPoint()
			PrintDebugMessage("SetProxyEndPoint", "Begin", 11)
			If ServiceEndPoint IsNot Nothing AndAlso ServiceEndPoint.Length > 0 Then
				SrvProxy.Url = ServiceEndPoint
			End If
			ServiceEndPoint = SrvProxy.Url
			PrintDebugMessage("SetProxyEndPoint", "Service endpoint: " & SrvProxy.Url, 12)
			PrintDebugMessage("SetProxyEndPoint", "End", 11)
		End Sub

		' Set User-agent for web service proxy.
		Private Sub SetProxyUserAgent()
			PrintDebugMessage("SetProxyUserAgent", "Begin", 11)
			Dim userAgent As String = ConstuctUserAgentStr(revision, Me.GetType().Name, SrvProxy.UserAgent)
			PrintDebugMessage("SetProxyUserAgent", "userAgent: " & userAgent, 12)
			SrvProxy.UserAgent = userAgent
			PrintDebugMessage("SetProxyUserAgent", "End", 11)
		End Sub
		
		' Construct a User-agent string for the client. See RFC2616 for details of HTTP user-agent strings.
		Private Function ConstuctUserAgentStr(ByVal revision As String, ByVal clientClassName As String, ByVal userAgent As String) As String
			PrintDebugMessage("constuctUserAgentStr", "Begin", 31)
			Dim retUserAgent As String = "EBI-Sample-Client"
			Dim clientVersion As String = "0"
			' Client version.
			If revision IsNot Nothing AndAlso revision.Length > 0 Then
				' CVS/Subversion revision tag.
				If revision.StartsWith("$") AndAlso revision.EndsWith("$") Then
					' Populated tag, extract revision number.
					If revision.Length > 13 Then
						clientVersion = revision.Substring(11, (revision.Length - 13))
					End If
				' Alternative revision/version string.
				Else
					clientVersion = revision
				End If
			End If
			' Agent name and version.
			Dim strBuilder As StringBuilder = New StringBuilder()
			strBuilder.Append(retUserAgent & "/" & clientVersion)
			' Agent comment (additional information).
			strBuilder.Append(" (")
			If clientClassName IsNot Nothing AndAlso clientClassName.Length > 0 Then
				' Provided class/client name.
				strBuilder.Append(clientClassName & "; ")
			Else
				' Use current class name.
				strBuilder.Append(Me.GetType().Name & "; ")
			End If
			strBuilder.Append("VB.NET; " & Environment.OSVersion.ToString())
			If userAgent Is Nothing OrElse userAgent.Length < 1 Then ' No previous agent.
				strBuilder.Append(")")
			ElseIf userAgent.StartsWith("Mono ") Then ' Mono agent.
				' Malformed so add to comments.
				strBuilder.Append("; " & userAgent & ")")
			Else ' MS .NET or other user-agent.
				' Append after comments.
				strBuilder.Append(") " & userAgent)
			End If
			retUserAgent = strBuilder.ToString()
			PrintDebugMessage("constuctUserAgentStr", "retUserAgent: " & retUserAgent, 32)
			PrintDebugMessage("constuctUserAgentStr", "End", 31)
			Return retUserAgent
		End Function
		
		' Get list of search domain names from sevice.
		Public Function ListDomains() As String()
			PrintDebugMessage("ListDomains", "Begin", 1)
			ServiceProxyConnect()
			Dim domainNameList As String() = SrvProxy.listDomains()
            PrintDebugMessage("ListDomains", "got " & domainNameList.Length & " domain names", 2)
			PrintDebugMessage("ListDomains", "End", 1)
			Return domainNameList
		End Function
		
		' Print list of available search domains.
		Public Sub PrintListDomains()
			PrintDebugMessage("PrintListDomains", "Begin", 1)
			Dim result As String() = ListDomains()
			PrintStrList(result)
			PrintDebugMessage("PrintListDomains", "End", 1)
		End Sub
		
		' Get the number of entries matching a query.
		Public Function GetNumberOfResults(ByVal domain As String, ByVal query As String) As Integer
			PrintDebugMessage("GetNumberOfResults", "Begin", 1)
			ServiceProxyConnect()
			Dim retVal As Integer = SrvProxy.getNumberOfResults(domain, query)
			PrintDebugMessage("GetNumberOfResults", "retVal: " & retVal, 1)
			PrintDebugMessage("GetNumberOfResults", "End", 1)
			Return retVal
		End Function
		
		' Print the number of entries matching a query.
		Public Sub PrintGetNumberOfResults(ByVal domain As String, ByVal query As String)
			PrintDebugMessage("PrintGetNumberOfResults", "Begin", 1)
			Dim numResults As Integer = GetNumberOfResults(domain, query)
			Console.WriteLine(numResults)
			PrintDebugMessage("PrintGetNumberOfResults", "End", 1)
		End Sub
		
		' Get the list of entry identifiers matching a query.
		Public Function GetResultsIds(ByVal domain As String, ByVal query As String, ByVal start As Integer, ByVal size As Integer) As String()
			PrintDebugMessage("GetResultsIds", "Begin", 1)
			ServiceProxyConnect()
			Dim result As String() = SrvProxy.getResultsIds(domain, query, start, size)
			PrintDebugMessage("GetResultsIds", "End", 1)
			Return result
		End Function
		
		' Print the set of entry identifiers matching a query.
		Public Sub PrintGetResultsIds(ByVal domain As String, ByVal query As String, ByVal start As Integer, ByVal size As Integer)
			PrintDebugMessage("PrintGetResultsIds", "Begin", 1)
			Dim result As String() = GetResultsIds(domain, query, start, size)
			PrintStrList(result)
			PrintDebugMessage("PrintGetResultsIds", "End", 1)
		End Sub
		
		' Print the set of entry identifiers matching a query.
		Public Sub PrintGetResultsIds(ByVal domain As String, ByVal query As String, ByVal start As String, ByVal size As String)
			PrintDebugMessage("PrintGetResultsIds", "Begin", 1)
			PrintGetResultsIds(domain, query, Convert.ToInt32(start), Convert.ToInt32(size))
			PrintDebugMessage("PrintGetResultsIds", "End", 1)
		End Sub

		' Get the set of entry identifiers matching a query.
		Public Function GetAllResultsIds(ByVal domain As String, ByVal query As String) As String()
			PrintDebugMessage("GetAllResultsIds", "Begin", 1)
			ServiceProxyConnect()
			Dim result As String() = SrvProxy.getAllResultsIds(domain, query)
			PrintDebugMessage("GetAllResultsIds", "End", 1)
			Return result
		End Function
		
		' Print the set of entry identifiers matching a query.
		Public Sub PrintGetAllResultsIds(ByVal domain As String, ByVal query As String)
			PrintDebugMessage("PrintGetAllResultsIds", "Begin", 1)
			Dim result As String() = GetAllResultsIds(domain, query)
			PrintStrList(result)
			PrintDebugMessage("PrintGetAllResultsIds", "End", 1)
		End Sub
		
		' Get the list of fields available for retrieval.
		Public Function ListFields(ByVal domain As String) As String()
			PrintDebugMessage("ListFields", "Begin", 1)
			ServiceProxyConnect()
			Dim result As String() = SrvProxy.listFields(domain)
			PrintDebugMessage("ListFields", "End", 1)
			Return result
		End Function

		' Print the list of fields available for retrieval.
		Public Sub PrintListFields(ByVal domain As String)
			PrintDebugMessage("PrintListFields", "Begin", 1)
			Dim results As String() = ListFields(domain)
			PrintStrList(results)
			PrintDebugMessage("PrintListFields", "End", 1)
		End Sub
		
		' Get data from retrievable fields for a query.
		Public Function GetResults(ByVal domain As String, ByVal query As String, ByVal fields As String(), ByVal start As Integer, ByVal size As Integer) As String()()
			PrintDebugMessage("GetResults", "Begin", 1)
			ServiceProxyConnect()
			Dim results As String()() = SrvProxy.getResults(domain, query, fields, start, size)
			PrintDebugMessage("GetResults", "End", 1)
			Return results
		End Function
		
		' Print data from retrievable fields for a query.
		Public Sub PrintGetResults(ByVal domain As String, ByVal query As String, ByVal fields As String(), ByVal start As Integer, ByVal size As Integer)
			PrintDebugMessage("PrintGetResults", "Begin", 1)
			Dim results As String()() = GetResults(domain, query, fields, start, size)
			PrintArrayOfStringList(results, false)
			PrintDebugMessage("PrintGetResults", "End", 1)
		End Sub

		' Print data from retrievable fields for a query.
		Public Sub PrintGetResults(ByVal domain As String, ByVal query As String, ByVal fields As String, ByVal start As String, ByVal size As String)
			PrintDebugMessage("PrintGetResults", "Begin", 1)
			Dim fieldNames As String() = SplitString(fields)
			PrintGetResults(domain, query, fieldNames, Convert.ToInt32(start), Convert.ToInt32(size))
			PrintDebugMessage("PrintGetResults", "Begin", 1)
		End Sub
		
		' Get data for a specific entry.
		Public Function GetEntry(ByVal domain As String, ByVal entry As String, ByVal fields As String()) As String()
			PrintDebugMessage("GetEntry", "Begin", 1)
			ServiceProxyConnect()
			Dim result As String() = SrvProxy.getEntry(domain, entry, fields)
			PrintDebugMessage("GetEntry", "End", 1)
			Return result
		End Function
		
		' Print data for a specific entry.
		Public Sub PrintGetEntry(ByVal domain As String, ByVal entry As String, ByVal fields As String())
			PrintDebugMessage("PrintGetEntry", "Begin", 1)
			Dim result As String() = GetEntry(domain, entry, fields)
			PrintStrList(result)
			PrintDebugMessage("PrintGetEntry", "End", 1)
		End Sub
		
		' Print data for a specific entry.
		Public Sub PrintGetEntry(ByVal domain As String, ByVal entry As String, ByVal fields As String)
			PrintDebugMessage("PrintGetEntry", "Begin", 1)
			Dim fieldNames As String() = SplitString(fields)
			PrintGetEntry(domain, entry, fieldNames)
			PrintDebugMessage("PrintGetEntry", "End", 1)
		End Sub
		
		' Get data for a specified set of entries.
		Public Function GetEntries(ByVal domain As String, ByVal entries As String(), ByVal fields As String()) As String()()
			PrintDebugMessage("GetEntries", "Begin", 1)
			ServiceProxyConnect()
			Dim result As String()() = SrvProxy.getEntries(domain, entries, fields)
			PrintDebugMessage("GetEntries", "End", 1)
			Return result
		End Function
		
		' Print data for a specified set of entries.
		Public Sub PrintGetEntries(ByVal domain As String, ByVal entries As String(), ByVal fields As String())
			PrintDebugMessage("PrintGetEntries", "Begin", 1)
			Dim result As String()() = GetEntries(domain, entries, fields)
			PrintArrayOfStringList(result, false)
			PrintDebugMessage("PrintGetEntries", "End", 1)
		End Sub

		' Print data for a specified set of entries.
		Public Sub PrintGetEntries(ByVal domain As String, ByVal entries As String, ByVal fields As String)
			PrintDebugMessage("PrintGetEntries", "Begin", 1)
			Dim entryIdentifiers As String() = SplitString(entries)
			Dim fieldNames As String() = SplitString(fields)
			PrintGetEntries(domain, entryIdentifiers, fieldNames)
			PrintDebugMessage("PrintGetEntry", "End", 1)
		End Sub
		
		' Get URL(s) associated with fields for a specified entry.
		Public Function GetEntryFieldUrls(ByVal domain As String, ByVal entry As String, ByVal fields As String()) As String()
			PrintDebugMessage("GetEntryFieldUrls", "Begin", 1)
			ServiceProxyConnect()
			Dim result As String() = SrvProxy.getEntryFieldUrls(domain, entry, fields)
			PrintDebugMessage("GetEntryFieldUrls", "End", 1)
			Return result
		End Function
		
		' Print URL(s) associated with fields for a specified entry.
		Public Sub PrintGetEntryFieldUrls(ByVal domain As String, ByVal entry As String, ByVal fields As String())
			PrintDebugMessage("PrintGetEntryFieldUrls", "Begin", 1)
			Dim result As String() = GetEntryFieldUrls(domain, entry, fields)
			PrintStrList(result)
			PrintDebugMessage("PrintGetEntryFieldUrls", "End", 1)
		End Sub

		' Print URL(s) associated with fields for a specified entry.
		Public Sub PrintGetEntryFieldUrls(ByVal domain As String, ByVal entry As String, ByVal fields As String)
			PrintDebugMessage("PrintGetEntryFieldUrls", "Begin", 1)
			Dim fieldNames As String() = SplitString(fields)
			PrintGetEntryFieldUrls(domain, entry, fieldNames)
			PrintDebugMessage("PrintGetEntryFieldUrls", "End", 1)
		End Sub
		
		' Get URL(s) associated with fields for a specified set of entries.
		Public Function GetEntriesFieldUrls(ByVal domain As String, ByVal entries As String(), ByVal fields As String()) As String()()
			PrintDebugMessage("GetEntriesFieldUrls", "Begin", 1)
			ServiceProxyConnect()
			Dim result As String()() = SrvProxy.getEntriesFieldUrls(domain, entries, fields)
			PrintDebugMessage("GetEntriesFieldUrls", "End", 1)
			Return result
		End Function
		
		' Print URL(s) associated with fields for a specified set of entries.
		Public Sub PrintGetEntriesFieldUrls(ByVal domain As String, ByVal entries As String(), ByVal fields As String())
			PrintDebugMessage("PrintGetEntriesFieldUrls", "Begin", 1)
			Dim result As String()() = GetEntriesFieldUrls(domain, entries, fields)
			PrintArrayOfStringList(result, false)
			PrintDebugMessage("PrintGetEntriesFieldUrls", "End", 1)
		End Sub

		' Print URL(s) associated with fields for a specified set of entries.
		Public Sub PrintGetEntriesFieldUrls(ByVal domain As String, ByVal entries As String, ByVal fields As String)
			PrintDebugMessage("PrintGetEntriesFieldUrls", "Begin", 1)
			Dim entryIdentifiers As String() = SplitString(entries)
			Dim fieldNames As String() = SplitString(fields)
			PrintGetEntriesFieldUrls(domain, entryIdentifiers, fieldNames)
			PrintDebugMessage("PrintGetEntryFieldUrls", "End", 1)
		End Sub
		
		' Get list of domains cross-referenced in a specified domain.
		Public Function GetDomainsReferencedInDomain(ByVal domain As String) As String()
			PrintDebugMessage("GetDomainsReferencedInDomain", "Begin", 1)
			ServiceProxyConnect()
			Dim result As String() = SrvProxy.getDomainsReferencedInDomain(domain)
			PrintDebugMessage("GetDomainsReferencedInDomain", "End", 1)
			return result
		End Function
		
		' Print list of domains cross-referenced in a specified domain.
		Public Sub PrintGetDomainsReferencedInDomain(ByVal domain As String)
			PrintDebugMessage("PrintGetDomainsReferencedInDomain", "Begin", 1)
			Dim result As String() = GetDomainsReferencedInDomain(domain)
			PrintStrList(result)
			PrintDebugMessage("PrintGetDomainsReferencedInDomain", "End", 1)
		End Sub
		
		' Get list of domains cross-referenced in an entry.
		Public Function GetDomainsReferencedInEntry(ByVal domain As String, ByVal entry As String) As String()
			PrintDebugMessage("GetDomainsReferencedInEntry", "Begin", 1)
			ServiceProxyConnect()
			Dim result As String() = SrvProxy.getDomainsReferencedInEntry(domain, entry)
			PrintDebugMessage("GetDomainsReferencedInEntry", "End", 1)
			Return result
		End Function
		
		' Print list of domains cross-referenced in an entry.
		Public Sub PrintGetDomainsReferencedInEntry(ByVal domain As String, ByVal entry As String)
			PrintDebugMessage("PrintGetDomainsReferencedInEntry", "Begin", 1)
			Dim result As String() = GetDomainsReferencedInEntry(domain, entry)
			PrintStrList(result)
			PrintDebugMessage("PrintGetDomainsReferencedInEntry", "End", 1)
		End Sub

		' Get list of fields containing cross-references to external sources for a specified domain.
		Public Function ListAdditionalReferenceFields(ByVal domain As String) As String()
			PrintDebugMessage("ListAdditionalReferenceFields", "Begin", 1)
			ServiceProxyConnect()
			Dim result As String() = SrvProxy.listAdditionalReferenceFields(domain)
			PrintDebugMessage("ListAdditionalReferenceFields", "End", 1)
			Return result
		End Function
		
		' Print list of fields containing cross-references to external sources for a specified domain.
		Public Sub PrintListAdditionalReferenceFields(ByVal domain As String)
			PrintDebugMessage("PrintListAdditionalReferenceFields", "Begin", 1)
			Dim result As String() = ListAdditionalReferenceFields(domain)
			PrintStrList(result)
			PrintDebugMessage("PrintListAdditionalReferenceFields", "End", 1)
		End Sub
		
		' Get entry identifiers for entries in a specified domain cross-referenced by an entry.
		Public Function GetReferencedEntries(ByVal domain As String, ByVal entry As String, ByVal referencedDomain As String) As String()
			PrintDebugMessage("GetReferencedEntries", "Begin", 1)
			ServiceProxyConnect()
			Dim result As String() = SrvProxy.getReferencedEntries(domain, entry, referencedDomain)
			PrintDebugMessage("GetReferencedEntries", "End", 1)
			Return result
		End Function
		
		' Print entry identifiers for entries in a specified domain cross-referenced by an entry.
		Public Sub PrintGetReferencedEntries(ByVal domain As String, ByVal entry As String, ByVal referencedDomain As String)
			PrintDebugMessage("PrintGetReferencedEntries", "Begin", 1)
			Dim result As String() = GetReferencedEntries(domain, entry, referencedDomain)
			PrintStrList(result)
			PrintDebugMessage("PrintGetReferencedEntries", "End", 1)
		End Sub
		
		'  Get data from entries in a specified domain cross-referenced by set of entries.
		Public Function GetReferencedEntriesSet(ByVal domain As String, ByVal entries As String(), ByVal referencedDomain As String, ByVal fields As String()) As EntryReferences()
			PrintDebugMessage("GetReferencedEntriesSet", "Begin", 1)
			ServiceProxyConnect()
			Dim result As EntryReferences() = SrvProxy.getReferencedEntriesSet(domain, entries, referencedDomain, fields)
			PrintDebugMessage("GetReferencedEntriesSet", "End", 1)
			Return result
		End Function
		
		' Print  data from entries in a specified domain cross-referenced by set of entries.
		Public Sub PrintGetReferencedEntriesSet(ByVal domain As String, ByVal entries As String(), ByVal referencedDomain As String, ByVal fields As String())
			PrintDebugMessage("PrintGetReferencedEntriesSet", "Begin", 1)
			Dim result As EntryReferences() = GetReferencedEntriesSet(domain, entries, referencedDomain, fields)
			For Each entry As EntryReferences In result
				Console.WriteLine(entry.entry)
				For Each xrefs As String() In entry.references
					For Each xref As String In xrefs
						Console.Write(Tab & xref)
					Next xref
					Console.WriteLine()
				Next xrefs
				Console.WriteLine()
			Next entry
			PrintDebugMessage("PrintGetReferencedEntriesSet", "End", 1)
		End Sub

		' Print data from entries in a specified domain cross-referenced by set of entries.
		Public Sub PrintGetReferencedEntriesSet(ByVal domain As String, ByVal entries As String, ByVal referencedDomain As String, ByVal fields As String)
			PrintDebugMessage("PrintGetReferencedEntriesSet", "Begin", 1)
			Dim entryIdentifiers As String() = SplitString(entries)
			Dim fieldNames As String() = SplitString(fields)
			PrintGetReferencedEntriesSet(domain, entryIdentifiers, referencedDomain, fieldNames)
			PrintDebugMessage("PrintGetReferencedEntriesSet", "End", 1)
		End Sub
		
		' Get data from entries in a specified domain cross-referenced by set of entries.
		Public Function GetReferencedEntriesFlatSet(ByVal domain As String, ByVal entries As String(), ByVal referencedDomain As String, ByVal fields As String()) As String()()
			PrintDebugMessage("GetReferencedEntriesFlatSet", "Begin", 1)
			ServiceProxyConnect()
			Dim result As String()() = SrvProxy.getReferencedEntriesFlatSet(domain, entries, referencedDomain, fields)
			PrintDebugMessage("GetReferencedEntriesFlatSet", "End", 1)
			Return result
		End Function
		
		' Print data from entries in a specified domain cross-referenced by set of entries.
		Public Sub PrintGetReferencedEntriesFlatSet(ByVal domain As String, ByVal entries As String(), ByVal referencedDomain As String, ByVal fields As String())
			PrintDebugMessage("PrintGetReferencedEntriesFlatSet", "Begin", 1)
			Dim result As String()() = GetReferencedEntriesFlatSet(domain, entries, referencedDomain, fields)
			PrintArrayOfStringList(result, true)
			PrintDebugMessage("PrintGetReferencedEntriesFlatSet", "End", 1)
		End Sub

		' Print data from entries in a specified domain cross-referenced by set of entries.
		Public Sub PrintGetReferencedEntriesFlatSet(ByVal domain As String, ByVal entries As String, ByVal referencedDomain As String, ByVal fields As String)
			PrintDebugMessage("PrintGetReferencedEntriesFlatSet", "Begin", 1)
			Dim entryIdentifiers As String() = SplitString(entries)
			Dim fieldNames As String() = SplitString(fields)
			PrintGetReferencedEntriesFlatSet(domain, entryIdentifiers, referencedDomain, fieldNames)
			PrintDebugMessage("PrintGetReferencedEntriesFlatSet", "End", 1)
		End Sub
		
		' Get tree of domain decriptions.
		Public Function GetDomainsHierarchy() As DomainDescription
			PrintDebugMessage("GetDomainsHierarchy", "Begin", 1)
			ServiceProxyConnect()
			Dim result As DomainDescription = SrvProxy.getDomainsHierarchy()
			PrintDebugMessage("GetDomainsHierarchy", "Begin", 1)
			Return result
		End Function
		
		' Print identifier and name for a domain and all of its subdomains.
		' 
		' This method is used by PrintGetDomainsHierarchy to print to tree of domains.
		Private Sub PrintDomainDescription(ByVal domain As DomainDescription, ByVal indent As String)
			PrintDebugMessage("PrintDomainDescription", "Begin", 1)
			Console.WriteLine(indent & domain.id & " : " & domain.name)
			If domain.subDomains IsNot Nothing AndAlso domain.subDomains.Length > 0 Then
				For Each subdomain As DomainDescription In domain.subDomains
					PrintDomainDescription(subdomain, indent & Tab)
				Next subdomain
			End If
			PrintDebugMessage("PrintDomainDecription", "End", 1)
		End Sub

		' Print tree of domains.
		Public Sub PrintGetDomainsHierarchy()
			PrintDebugMessage("PrintGetDomainsHierarchy", "Begin", 1)
			Dim rootDomain As DomainDescription = GetDomainsHierarchy()
			PrintDomainDescription(rootDomain, "")
			PrintDebugMessage("PrintGetDomainsHierarchy", "Begin", 1)
		End Sub
		
		' Get tree of the number of results for each subdomain under the domain searched.
		Public Function GetDetailledNumberOfResults(ByVal domain As String, ByVal query As String, ByVal flat As Boolean) As DomainResult
			PrintDebugMessage("GetDetailledNumberOfResults", "Begin", 1)
			ServiceProxyConnect()
			Dim result As DomainResult = SrvProxy.getDetailledNumberOfResults(domain, query, flat)
			PrintDebugMessage("GetDetailledNumberOfResults", "End", 1)
			Return result
		End Function
		
		' Print tree of the number of results for each subdomain under the domain searched.
		Public Sub PrintGetDetailledNumberOfResults(ByVal domain As String, ByVal query As String, ByVal flat As Boolean)
			PrintDebugMessage("PrintGetDetailledNumberOfResults", "Begin", 1)
			Dim results As DomainResult = GetDetailledNumberOfResults(domain, query, flat)
			PrintDomainResults(results, "")
			PrintDebugMessage("PrintGetDetailledNumberOfResults", "End", 1)
		End Sub
		
		' Print tree of the number of results for each subdomain under the domain searched.
		Public Sub PrintGetDetailledNumberOfResults(ByVal domain As String, ByVal query As String, ByVal flat As String)
			PrintDebugMessage("PrintGetDetailledNumberOfResults", "Begin", 1)
			Dim isFlat As Boolean = false
			Dim tmpflat As String = flat.ToLower()
			If tmpflat = "t" OrElse tmpflat = "true" OrElse tmpflat = "y" OrElse tmpflat = "yes" OrElse tmpflat = "1" Then
				isFlat = true
			End If
			PrintGetDetailledNumberOfResults(domain, query, isFlat)
			PrintDebugMessage("PrintGetDetailledNumberOfResults", "End", 1)
		End Sub
		
		' Print the domain results used by getDetailledNumberOfResults
		
		' Print domain identifier and number of results for a domain result, as returned by GetDetailledNumberOfResults(), and print all results for all subdomains.
		' 
		' Used in PrintGetDetailledNumberOfResults().
		Private Sub PrintDomainResults(ByVal domain As DomainResult, ByVal indent As String)
			PrintDebugMessage("PrintDomainResults", "Begin", 1)
			Console.WriteLine(indent & domain.domainId & " : " & domain.numberOfResults)
			If domain.subDomainsResults IsNot Nothing AndAlso domain.subDomainsResults.Length > 0 Then
				For Each subdomain As DomainResult In domain.subDomainsResults
					PrintDomainResults(subdomain, indent & Tab)
				Next subdomain
			End If
			PrintDebugMessage("PrintDomainResults", "End", 1)
		End Sub

		' Get detailed information about the search and retrievalable fields available for a domain.
		Public Function ListFieldsInformation(ByVal domain As String) As EbiWS.EBeyeWs.FieldInfo()
			PrintDebugMessage("ListFieldsInformation", "Begin", 1)
			ServiceProxyConnect()
			Dim result As EbiWS.EBeyeWs.FieldInfo() = SrvProxy.listFieldsInformation(domain)
			PrintDebugMessage("ListFieldsInformation", "End", 1)
			Return result
		End Function
		
		' Print details about hte search and retrivable fields available for a domain.
		Public Sub PrintListFieldsInformation(ByVal domain As String)
			PrintDebugMessage("PrintListFieldsInformation", "Begin", 1)
            Dim result As EbiWS.EBeyeWs.FieldInfo() = ListFieldsInformation(domain)
            Console.WriteLine("#Id" & Tab & "Name" & Tab & "Description" & Tab & "Searchable" & Tab & "Retrievable")
			For Each field As EbiWS.EBeyeWs.FieldInfo In result
                Console.WriteLine(field.id & Tab & field.name & Tab & field.description & Tab & field.searchable & Tab & field.retrievable)
			Next field
			PrintDebugMessage("PrintListFieldsInformation", "End", 1)
		End Sub
		
		' Split a string based on a set of seperator characters.
		Private Function SplitString(ByVal inStr As String, ByVal seperators As Char()) As String()
			PrintDebugMessage("SplitString", "Begin", 11)
			Dim retVal As String() = inStr.Split(seperators)
			PrintDebugMessage("SplitString", "End", 11)
			Return retVal
		End Function

		' Split a string using newline, tab, space, plus, comma and semicolon as seperators.
		Private Function SplitString(ByVal inStr As String) As String()
			PrintDebugMessage("SplitString", "Begin", 11)
			Dim sre As RegEx = New RegEx("[ \t\r\n;,+]+")
			Dim retVal As String() = sre.Split(inStr)
			PrintDebugMessage("SplitString", "End", 11)
			Return retVal
		End Function

		' Print an array of an array of strings, as a list or a table.
		Private Sub PrintArrayOfStringList(ByVal arrayList As String()(), ByVal table As Boolean)
			PrintDebugMessage("PrintArrayOfStringList", "Begin", 1)
			For i As Integer = 0 To (arrayList.Length - 1) Step 1
				Dim strList As String() = arrayList(i)
				For j As Integer = 0 To (strList.Length - 1) Step 1
					If table AndAlso j > 0 Then
						Console.Write(Tab)
					End If
					Console.Write(strList(j))
					If Not table Then
						Console.WriteLine("")
					End If
				Next j
				If table Then
					Console.WriteLine("")
				End If
			Next i
			PrintDebugMessage("PrintArrayOfStringList", "End", 1)
		End Sub

		' Print an array of strings as a list.
		Private Sub PrintStrList(ByVal strList As String())
			For Each item As String In strList
				If item IsNot Nothing AndAlso item <> "" Then
					Console.WriteLine(item)
				End If
			Next item
		End Sub

	End Class
End Namespace
