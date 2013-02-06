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
' jDispatcher SOAP command-line client for InterProScan.
' ======================================================================
Imports System
Imports System.IO
Imports EbiWS.IPRScanWs

Namespace EbiWS
    Public Class IPRScanCliClient
        Inherits EbiWS.IPRScanClient
        ' Tool specific usage.
        Private usageMsg As String = _
"InterProScan" & Environment.NewLine & _
"============" & Environment.NewLine & _
Environment.NewLine & _
"Identify protein family, domain and signal signatures in a protein sequence." & Environment.NewLine & _
Environment.NewLine & _
"For more information see:" & Environment.NewLine & _
"- http://www.ebi.ac.uk/Tools/pfa/iprscan" & Environment.NewLine & _
"- http://www.ebi.ac.uk/Tools/webservices/services/pfa/iprscan_soap" & Environment.NewLine & _
Environment.NewLine & _
"[Required]" & Environment.NewLine & _
Environment.NewLine & _
"  seqFile            : file : query sequence (""-"" for STDIN, @filename for" & Environment.NewLine & _
"                              identifier list file)" & Environment.NewLine & _
Environment.NewLine & _
"[Optional]" & Environment.NewLine & _
Environment.NewLine & _
"      --appl         : str  : Comma separated list of signature methods to run," & Environment.NewLine & _
"                              see --paramDetail appl. " & Environment.NewLine & _
"      --crc          :      : enable lookup in InterProScan matches (faster)." & Environment.NewLine & _
"      --nocrc        :      : disable lookup in InterProScan matches (slower)." & Environment.NewLine & _
"      --goterms      :      : enable retrieval og GO terms." & Environment.NewLine & _
"      --nogoterms    :      : disable retrieval GO terms." & Environment.NewLine & _
"      --multifasta   :      : treat input as a set of fasta formatted " & Environment.NewLine & _
"                              sequences." & Environment.NewLine

        ' Execution entry point.
        Public Shared Function Main(ByVal args As String()) As Integer
            Dim retVal As Integer = 0 ' Return value
            ' Create an instance of the wrapper object
            Dim wsApp As IPRScanCliClient = New IPRScanCliClient()
            ' If no arguments print usage and return
            If args.Length < 1 Then
                wsApp.PrintUsageMessage()
                Return retVal
            End If
            Try
                ' Parse the command line
                wsApp.ParseCommand(args)
                ' Perform the selected action
                Select wsApp.Action
                    Case "paramList" ' List parameter names
                        wsApp.PrintParams()
                        Exit Select
                    Case "paramDetail" ' Parameter detail
                        wsApp.PrintParamDetail(wsApp.ParamName)
                        Exit Select
                    Case "submit" ' Submit job
                        wsApp.SubmitJobs()
                        Exit Select
                    Case "status" ' Get job status
                        wsApp.PrintStatus()
                        Exit Select
                    Case "resultTypes" ' Get result types
                        wsApp.PrintResultTypes()
                        Exit Select
                    Case "polljob" ' Get job results
                        wsApp.GetResults()
                        Exit Select
                    Case "help" ' Do help
                        wsApp.PrintUsageMessage()
                        Exit Select
                    Case Else ' Any other action.
                        Console.WriteLine("Error: unknown action " & wsApp.Action)
                        retVal = 1
                        Exit Select
                End Select
            Catch ex As System.Exception
                ' Catch all exceptions
                Console.Error.WriteLine("Error: " & ex.Message)
                Console.Error.WriteLine(ex.StackTrace)
                retVal = 2
            End Try
            Return retVal
        End Function

        ' Print the usage message.
        Private Sub PrintUsageMessage()
            PrintDebugMessage("PrintUsageMessage", "Begin", 1)
            Console.WriteLine(usageMsg)
            PrintGenericOptsUsage()
            PrintDebugMessage("PrintUsageMessage", "End", 1)
        End Sub

        ' Parse command-line options.
        Private Sub ParseCommand(ByVal args As String())
            PrintDebugMessage("ParseCommand", "Begin", 1)
            InParams = New InputParameters()
            ' Scan through command-line arguments to find options.
            ' TODO: evaluate using command-line parsing library, such as
            ' NDesk.Options (http://www.ndesk.org/Options) or Mono.Options
            ' (http://tirania.org/blog/archive/2008/Oct-14.html) instead.
            For i As Integer = 0 To (args.Length - 1) Step 1
                PrintDebugMessage("parseCommand", "arg: " & args(i), 2)
                Select args(i)
                    ' Generic options
                    Case "--help" ' Usage info
                        Action = "help"
                        Exit Select
                    Case "-h"
                        Action = "help"
                        Exit Select
                    Case "/help"
                        Action = "help"
                        Exit Select
                    Case "/h"
                        Action = "help"
                        Exit Select
                    Case "--params" ' List input parameters
                        Action = "paramList"
                        Exit Select
                    Case "/params"
                        Action = "paramList"
                        Exit Select
                    Case "--paramDetail" ' Parameter details
                        i += 1 ' Shift to parameter value.
                        ParamName = args(i)
                        Action = "paramDetail"
                        Exit Select
                    Case "/paramDetail"
                        i += 1 ' Shift to parameter value.
                        ParamName = args(i)
                        Action = "paramDetail"
                        Exit Select
                    Case "--jobid" ' Job Id to get status or results
                        i += 1 ' Shift to parameter value.
                        JobId = args(i)
                        Exit Select
                    Case "/jobid"
                        i += 1 ' Shift to parameter value.
                        JobId = args(i)
                        Exit Select
                    Case "--status" ' Get job status
                        Action = "status"
                        Exit Select
                    Case "/status"
                        Action = "status"
                        Exit Select
                    Case "--resultTypes" ' Get result types
                        Action = "resultTypes"
                        Exit Select
                    Case "/resultTypes"
                        Action = "resultTypes"
                        Exit Select
                    Case "--polljob" ' Get results for job
                        Action = "polljob"
                        Exit Select
                    Case "/polljob"
                        Action = "polljob"
                        Exit Select
                    Case "--outfile" ' Base name for results file(s)
                        i += 1 ' Shift to parameter value.
                        OutFile = args(i)
                        Exit Select
                    Case "/outfile"
                        i += 1 ' Shift to parameter value.
                        OutFile = args(i)
                        Exit Select
                    Case "--outformat" ' Only save results of this format
                        i += 1 ' Shift to parameter value.
                        OutFormat = args(i)
                        Exit Select
                    Case "/outformat"
                        i += 1 ' Shift to parameter value.
                        OutFormat = args(i)
                        Exit Select
                    Case "--verbose" ' Output level
                        OutputLevel += 1
                        Exit Select
                    Case "/verbose"
                        OutputLevel += 1
                        Exit Select
                    Case "--quiet" ' Output level
                        OutputLevel -= 1
                        Exit Select
                    Case "/quiet"
                        OutputLevel -= 1
                        Exit Select
                    Case "--email" ' User e-mail address
                        i += 1 ' Shift to parameter value.
                        Email = args(i)
                        Exit Select
                    Case "/email"
                        i += 1 ' Shift to parameter value.
                        Email = args(i)
                        Exit Select
                    Case "--title" ' Job title
                        i += 1 ' Shift to parameter value.
                        JobTitle = args(i)
                        Exit Select
                    Case "/title"
                        i += 1 ' Shift to parameter value.
                        JobTitle = args(i)
                        Exit Select
                    Case "--async" ' Async submission
                        Action = "submit"
                        Async = True
                        Exit Select
                    Case "/async"
                        Action = "submit"
                        Async = True
                        Exit Select
                    Case "--debugLevel"
                        i += 1 ' Shift to parameter value.
                        DebugLevel = Convert.ToInt32(args(i))
                        Exit Select
                    Case "/debugLevel"
                        i += 1 ' Shift to parameter value.
                        DebugLevel = Convert.ToInt32(args(i))
                        Exit Select
                    Case "--endpoint" ' Service endpoint
                        i += 1 ' Shift to parameter value.
                        ServiceEndPoint = args(i)
                        Exit Select
                    Case "/endpoint"
                        i += 1 ' Shift to parameter value.
                        ServiceEndPoint = args(i)
                        Exit Select
                    Case "--multifasta" ' Multiple fasta format input.
                        Me.multifasta = True
                        Exit Select
                    Case "/multifasta"
                        Me.multifasta = True
                        Exit Select

                        ' Tool specific options
                    Case "--appl" ' Signature methods
                        i += 1 ' Shift to parameter value.
                        Dim sepList As Char() = {" "c, ","c}
                        InParams.appl = args(i).Split(sepList)
                        Action = "submit"
                        Exit Select
                    Case "/appl"
                        i += 1 ' Shift to parameter value.
                        Dim sepList As Char() = {" "c, ","c}
                        InParams.appl = args(i).Split(sepList)
                        Action = "submit"
                        Exit Select
                    Case "--app"
                        i += 1 ' Shift to parameter value.
                        Dim sepList As Char() = {" "c, ","c}
                        InParams.appl = args(i).Split(sepList)
                        Action = "submit"
                        Exit Select
                    Case "/app"
                        i += 1 ' Shift to parameter value.
                        Dim sepList As Char() = {" "c, ","c}
                        InParams.appl = args(i).Split(sepList)
                        Action = "submit"
                        Exit Select
                    Case "--goterms" ' Enable GO terms in result.
                        InParams.goterms = True
                        Exit Select
                    Case "/goterms"
                        InParams.goterms = True
                        Exit Select
                    Case "--nogoterms" ' Disable GO terms in result.
                        InParams.goterms = False
                        Exit Select
                    Case "/nogoterms"
                        InParams.goterms = False
                        Exit Select
                    Case "--crc" ' Enable InterPro Matches look-up.
                        InParams.nocrc = False
                        Exit Select
                    Case "/crc"
                        InParams.nocrc = False
                        Exit Select
                    Case "--nocrc" ' Disable InterPro Matches look-up.
                        InParams.nocrc = True
                        Exit Select
                    Case "/nocrc"
                        InParams.nocrc = True
                        Exit Select

                        ' Input data/sequence option
                    Case "--sequence" ' Input sequence
                        i += 1
                        Action = "submit"
                        InParams.sequence = args(i)
                        Exit Select
                    Case Else
                        ' Check for unknown option
                        If args(i).StartsWith("--") OrElse args(i).LastIndexOf("/"c) = 0 Then
                            Console.Error.WriteLine("Error: unknown option: " & args(i) + "\n")
                            Action = "exit"
                            Return
                        End If
                        ' Must be data argument
                        InParams.sequence = args(i)
                        Action = "submit"
                        Exit Select
                End Select
			Next i
            PrintDebugMessage("ParseCommand", "End", 1)
        End Sub
    End Class
End Namespace
