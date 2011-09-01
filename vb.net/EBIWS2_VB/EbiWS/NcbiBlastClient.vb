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

Imports Microsoft.VisualBasic.ControlChars ' Character constants (e.g. Tab).
Imports System
Imports System.IO
Imports System.Text.RegularExpressions
Imports EbiWS.NcbiBlastWs ' "Web Reference" or wsdl.exe generated stubs.

Namespace EbiWS
	' Client for EMBL-EBI NCBI BLAST SOAP web service.
	Public Class NcbiBlastClient
		Inherits AbstractWsClient
		
		' Webservice proxy object.
		Public Property SrvProxy As EbiWS.NcbiBlastWs.JDispatcherService
			Get
				Return _srvProxy
			End Get
			Set (ByVal value As EbiWS.NcbiBlastWs.JDispatcherService)
				_srvProxy = value
			End Set
		End Property
		Private _srvProxy As EbiWS.NcbiBlastWs.JDispatcherService = Nothing
		' Parameters used for launching jobs.
		Public Property InParams As EbiWS.NcbiBlastWs.InputParameters
			Get
				Return _inParams
			End Get
			Set (ByVal value As EbiWS.NcbiBlastWs.InputParameters)
				_inParams = value
			End Set
		End Property
		Private _inParams As EbiWS.NcbiBlastWs.InputParameters = Nothing
		' Multiple fasta formatted sequences as input.
		Protected multifasta As Boolean = False
		' Client object revision.
		Private revision As String = "$Revision$"
		
		' Default constructor. Required for abstract class constructor.
		Public Sub New()
			MyBase.New
		End Sub
		
		' Implementation of abstract method (AbsractWsClient.ServiceProxyConnect()).
		Protected Overrides Sub ServiceProxyConnect()
			PrintDebugMessage("ServiceProxyConnect", "Begin", 11)
			If SrvProxy Is Nothing Then
				SrvProxy = New EbiWS.NcbiBlastWs.JDispatcherService()
				If ServiceEndPoint IsNot Nothing And ServiceEndPoint.Length > 0 Then
					SrvProxy.Url = ServiceEndPoint
				End If
				PrintDebugMessage("ServiceProxyConnect", "Service endpoint: " & SrvProxy.Url, 12)
				SetProxyUserAgent() ' Set user-agent for client.
			End If
			PrintDebugMessage("ServiceProxyConnect", "SrvProxy: " & SrvProxy.ToString(), 12)
			PrintDebugMessage("ServiceProxyConnect", "End", 11)
		End Sub

		' Set User-agent for web service proxy.
		Private Sub SetProxyUserAgent()
			PrintDebugMessage("SetProxyUserAgent", "Begin", 11)
			Dim userAgent As String = constuctUserAgentStr(revision, Me.GetType().Name, SrvProxy.UserAgent)
			PrintDebugMessage("SetProxyUserAgent", "userAgent: " & userAgent, 12)
			SrvProxy.UserAgent = userAgent
			PrintDebugMessage("SetProxyUserAgent", "End", 11)
		End Sub

		' Implementation of abstract method (AbsractWsClient.GetParams()).
		Public Overrides Function GetParams() As String()
			PrintDebugMessage("GetParams", "Begin", 1)
			Me.ServiceProxyConnect() ' Ensure we have a service proxy
			Dim paramNameList As String() = SrvProxy.getParameters()
			PrintDebugMessage("GetParams", "got " & paramNameList.Length & " parameter names", 2)
			PrintDebugMessage("GetParams", "End", 1)
			Return paramNameList
		End Function

		' Get detailed information about a named parameter. 
		Public Function GetParamDetail(ByVal paramName As String) As EbiWS.NcbiBlastWs.wsParameterDetails 
			PrintDebugMessage("GetParamDetail", "Begin", 1)
			PrintDebugMessage("GetParamDetail", "paramName: " & paramName, 2)
			Me.ServiceProxyConnect() ' Ensure we have a service proxy
			Dim paramDetail As EbiWS.NcbiBlastWs.wsParameterDetails = SrvProxy.getParameterDetails(paramName)
			PrintDebugMessage("GetParamDetail", "End", 1)
			Return paramDetail
		End Function

		' Implementation of abstract method (AbsractWsClient.PrintParammDetail()).
		Protected Overrides Sub PrintParamDetail(ByVal paramName As String)
			PrintDebugMessage("PrintParamDetail", "Begin", 1)
			Dim paramDetail As EbiWS.NcbiBlastWs.wsParameterDetails = GetParamDetail(paramName)
			If paramDetail Is Nothing Then
				Throw New ClientException("Null returned by web service.")
			End If
			Console.WriteLine("{0}{1}{2}", paramDetail.name, Tab, paramDetail.type)
			If paramDetail.description IsNot Nothing Then
				Console.WriteLine(paramDetail.description)
			End If
			If paramDetail.values IsNot Nothing Then
				For Each paramValue As EbiWS.NcbiBlastWs.wsParameterValue In paramDetail.values
					Console.Write(paramValue.value)
					If paramValue.defaultValue Then
						Console.Write("{0}default", Tab)
					End If
					Console.WriteLine()
					If paramValue.label IsNot Nothing Then
						Console.WriteLine("{0}{1}", Tab, paramValue.label)
					End If
					If paramValue.properties IsNot Nothing Then
						For Each valueProperty As EbiWS.NcbiBlastWs.wsProperty In paramValue.properties
							Console.WriteLine("{0}{1}{2}{3}", Tab, valueProperty.key, Tab, valueProperty.value)
						Next valueProperty
					End If
				Next paramValue
			End If
			PrintDebugMessage("PrintParamDetail", "End", 1)
		End Sub

		' Submit job(s) to the service.
		Protected Sub SubmitJobs()
			PrintDebugMessage("SubmitJobs", "Begin", 1)
			' Three modes...
			' 1. Multiple fasta sequence input.
			If Me.multifasta Then
				SetSequenceFile(InParams.sequence)
				Dim inSeq As String = Nothing
				While (inSeq = NextSequence())
					InParams.sequence = inSeq
					SubmitJob()
				End While
				CloseSequenceFile()
			' 2. Entry identifier list input.
			ElseIf InParams.sequence.StartsWith("@") Then
				SetIdentifierFile(InParams.sequence.Substring(1))
				Dim inId As String = Nothing
				While (inId = NextIdentifier())
					InParams.sequence = inId
					SubmitJob()
				End While
				CloseIdentifierFile()
			' 3. Simple sequence input.
			Else
				InParams.sequence = LoadData(InParams.sequence)
				SubmitJob()
			End If
			PrintDebugMessage("SubmitJobs", "End", 1)
		End Sub

		' Implementation of abstract method (AbsractWsClient.SubmitJob()).
		' Submit a job to the service.
		Public Overrides Sub SubmitJob()
			PrintDebugMessage("SubmitJob", "Begin", 1)
			JobId = RunApp(Email, JobTitle, InParams)
			If OutputLevel > 0 Or Async Then
				Console.WriteLine(JobId)
			End If
			' Simulate sync mode
			If Not Async Then
				GetResults()
			End If
			PrintDebugMessage("SubmitJob", "End", 1)
		End Sub
		
		' Submit a job to the service.
		Public Function RunApp(ByVal email As String, ByVal title As String, ByVal input As EbiWS.NcbiBlastWs.InputParameters) As String
			PrintDebugMessage("RunApp", "Begin", 1)
			PrintDebugMessage("RunApp", "email: " & email, 2)
			PrintDebugMessage("RunApp", "title: " & title, 2)
			PrintDebugMessage("RunApp", "input:\n" & ObjectValueToString(input), 2)
			Dim jobId As String = Nothing
			Me.ServiceProxyConnect() ' Ensure we have a service proxy
			' Submit the job
			jobId = SrvProxy.run(email, title, input)
			PrintDebugMessage("RunApp", "jobId: " & jobId, 2)
			PrintDebugMessage("RunApp", "End", 1)
			Return jobId
		End Function

		' Implementation of abstract method (AbsractWsClient.GetStatus()).
		' Get the job status.
		Public Overrides Function GetStatus(ByVal jobId As String) As String
			PrintDebugMessage("GetStatus", "Begin", 1)
			Dim status As String = "PENDING"
			Me.ServiceProxyConnect() ' Ensure we have a service proxy
			status = SrvProxy.getStatus(jobId)
			PrintDebugMessage("GetStatus", "status: " & status, 2)
			PrintDebugMessage("GetStatus", "End", 1)
			Return status
		End Function

		' Get details of the available result types/formats for a completed job. 
		Public Function GetResultTypes(ByVal jobId As String) As EbiWS.NcbiBlastWs.wsResultType()
			PrintDebugMessage("GetResultTypes", "Begin", 2)
			Me.ServiceProxyConnect() ' Ensure we have a service proxy
			Dim resultTypes As EbiWS.NcbiBlastWs.wsResultType() = SrvProxy.getResultTypes(jobId)
			PrintDebugMessage("GetResultTypes", "End", 2)
			Return resultTypes
		End Function

		' Implementation of abstract method (AbsractWsClient.PrintResultTypes()).
		' Print a summary of the result types for a job.
		Public Overrides Sub PrintResultTypes()
			PrintDebugMessage("PrintResultTypes", "Begin", 1)
			PrintDebugMessage("PrintResultTypes", "JobId: " & JobId, 2)
			Dim resultTypes As EbiWS.NcbiBlastWs.wsResultType() = GetResultTypes(JobId)
			If resultTypes Is Nothing Then
				Throw New ClientException("Null returned by web service.")
			End If
			PrintDebugMessage("PrintResultTypes", "resultTypes: " & resultTypes.Length, 2)
			PrintProgressMessage("Getting output formats for job " & JobId, 1)
			For Each resultType As EbiWS.NcbiBlastWs.wsResultType In resultTypes
				Console.WriteLine(resultType.identifier)
				If resultType.label IsNot Nothing Then
					Console.WriteLine("{0}{1}", Tab, resultType.label)
				End If
				If resultType.description IsNot Nothing Then
					Console.WriteLine("{0}{1}", Tab, resultType.description)
				End If
				If resultType.mediaType IsNot Nothing Then
					Console.WriteLine("{0}{1}", Tab, resultType.mediaType)
				End If
				If resultType.fileSuffix IsNot Nothing Then
					Console.WriteLine("{0}{1}", Tab, resultType.fileSuffix)
				End If
			Next resultType
			PrintDebugMessage("PrintResultTypes", "End", 1)
		End Sub

		' Implementation of abstract method (AbsractWsClient.GetResult()).
		Public Overrides Function GetResult(ByVal jobId As String, ByVal format As String) As Byte()
			PrintDebugMessage("GetResult", "Begin", 1)
			PrintDebugMessage("GetResult", "jobId: " & jobId, 1)
			PrintDebugMessage("GetResult", "format: " & format, 1)
			Dim result As Byte() = Nothing
			Me.ServiceProxyConnect() ' Ensure we have a service proxy
			result = SrvProxy.getResult(jobId, format, Nothing)
			PrintDebugMessage("GetResult", "End", 1)
			Return result
		End Function

		' Implementation of abstract method (AbsractWsClient.GetResults()).
		' Get the job results.
		Public Overrides Sub GetResults(ByVal jobId As String, ByVal outformat As String, ByVal outFileBase As String)
			PrintDebugMessage("GetResults", "Begin", 1)
			PrintDebugMessage("GetResults", "jobId: " & jobId, 2)
			PrintDebugMessage("GetResults", "outformat: " & outformat, 2)
			PrintDebugMessage("GetResults", "outFileBase: " & outFileBase, 2)
			' Check status, and wait if not finished
			ClientPoll(jobId)
			' Use JobId if output file name is not defined
			Dim tmpOutFile As String = jobId
			If outFileBase IsNot Nothing Then
				tmpOutFile = outFileBase
			End If
			' Get list of data types.
			Dim resultTypes As EbiWS.NcbiBlastWs.wsResultType() = GetResultTypes(jobId)
			PrintDebugMessage("GetResults", "resultTypes: " & resultTypes.Length & " available", 2)
			' Get the data and write it to a file
			Dim res As Byte() = Nothing
			If outformat IsNot Nothing Then ' Specified data type.
				Dim selResultType As EbiWS.NcbiBlastWs.wsResultType = Nothing
				For Each resultType As EbiWS.NcbiBlastWs.wsResultType In resultTypes
					If resultType.identifier Is outformat Then
						selResultType = resultType
					End If
				Next resultType
				PrintDebugMessage("GetResults", "resultType:\n" & ObjectValueToString(selResultType), 2)
				res = GetResult(jobId, selResultType.identifier)
				' Text data
				If selResultType.mediaType.StartsWith("text") Then
					If tmpOutFile Is "-" Then
						WriteTextFile(tmpOutFile, res)
					Else
						WriteTextFile(tmpOutFile & "." & selResultType.identifier & "." & selResultType.fileSuffix, res)
					End If
				' Binary data
				Else
					If tmpOutFile Is "-" Then
						WriteBinaryFile(tmpOutFile, res)
					Else 
						WriteBinaryFile(tmpOutFile & "." & selResultType.identifier & "." & selResultType.fileSuffix, res)
					End If
				End If
			Else ' Data types available
				' Write a file for each output type.
				For Each resultType As EbiWS.NcbiBlastWs.wsResultType In resultTypes
					PrintDebugMessage("GetResults", "resultType:\n" & ObjectValueToString(resultType), 2)
					res = GetResult(jobId, resultType.identifier)
					' Text data
					If resultType.mediaType.StartsWith("text") Then
						If tmpOutFile Is "-" Then
							WriteTextFile(tmpOutFile, res)
						Else 
							WriteTextFile(tmpOutFile & "." & resultType.identifier & "." & resultType.fileSuffix, res)
						End If
					' Binary data
					Else
						If tmpOutFile Is "-" Then
							WriteBinaryFile(tmpOutFile, res)
						Else
							WriteBinaryFile(tmpOutFile & "." & resultType.identifier & "." & resultType.fileSuffix, res)
						End If
					End If
				Next resultType
			End If
			PrintDebugMessage("GetResults", "End", 1)
		End Sub

		' Get entry Ids from job result.
		Public Function GetIds(ByVal jobId As String) As String()
			PrintDebugMessage("GetIds", "Begin", 1)
			PrintDebugMessage("GetIds", "jobId: " & jobId, 2)
			Dim retVal As String() = Nothing
			' Check status, and wait if not finished
			ClientPoll(jobId)
			' Get the Ids
			Dim content As Byte() = GetResult(jobId, "ids")
			Dim enc As System.Text.ASCIIEncoding = New System.Text.ASCIIEncoding()
			Dim tempStr As String = enc.GetString(content)
			Dim wsre As RegEx = New RegEx("[\r\n]+")
			retVal = wsre.Split(tempStr)
			PrintDebugMessage("GetIds", "got " & retVal.Length & " Ids", 2)
			PrintDebugMessage("GetIds", "End", 1)
			Return retVal
		End Function

		' Print entry Ids from job result.
		Public Sub PrintGetIds()
			PrintDebugMessage("PrintGetIds", "Begin", 1)
			PrintDebugMessage("PrintGetIds", "JobId: " & JobId, 2)
			Dim idList As String() = GetIds(JobId)
			If idList Is Nothing Then
				Throw New ClientException("Null identifier list obtained from service.")
			Else
				For Each id As String In idList
					Console.WriteLine(id)
				Next id
			End If
			PrintDebugMessage("PrintGetIds", "End", 1)
		End Sub

	End Class
End Namespace
