' $Id$
' ======================================================================
' NCBI BLAST (SOAP) Visual Basic .NET command-line client.
'
' See:
' http://www.ebi.ac.uk/Tools/webservices/services/sss/ncbi_blast_soap
' http://www.ebi.ac.uk/Tools/webservices/tutorials/vb.net
' ======================================================================

Option Explicit On
Option Strict On

Imports System
Imports EbiWS ' Service wrapper classes.
Imports EbiWS.NcbiBlastWs ' "Web Reference" or wsdl.exe generated stubs.

Namespace EbiWS
	' NCBI BLAST (SOAP) command-line client class.
	Public Class NcbiBlastCliClient
		Inherits NcbiBlastClient
		' Tool specific usage.
		Private usageMsg As String = _
"NCBI BLAST" & Environment.NewLine & _
"==========" & Environment.NewLine & _
Environment.NewLine & _
"Rapid sequence database search programs utilizing the BLAST algorithm" & Environment.NewLine & _
Environment.NewLine & _
"For more information see:" & Environment.NewLine & _
"- http://www.ebi.ac.uk/Tools/sss/ncbiblast" & Environment.NewLine & _
"- http://www.ebi.ac.uk/Tools/webservices/services/sss/ncbi_blast_soap" & Environment.NewLine & _
Environment.NewLine & _
"[Required]" & Environment.NewLine & _
Environment.NewLine & _
"  -p, --program        : str  : BLAST program to use: see --paramDetail program" & Environment.NewLine & _
"  -D, --database       : str  : database(s) to search, space seperated: see" & Environment.NewLine & _
"                                --paramDetail database" & Environment.NewLine & _
"      --stype          : str  : query sequence type" & Environment.NewLine & _
"  seqFile              : file : query sequence (""-"" for STDIN)" & Environment.NewLine & _
Environment.NewLine & _
"[Optional]" & Environment.NewLine & _
Environment.NewLine & _
"  -m, --matrix         : str  : scoring matrix, see --paramDetail matrix" & Environment.NewLine & _
"  -e, --exp            : real : 0<E<= 1000. Statistical significance threshold" & Environment.NewLine & _
"                                for reporting database sequence matches." & Environment.NewLine & _
"  -f, --filter         : str  : low complexity sequence filter, see" & Environment.NewLine & _
"                                --paramDetail filter" & Environment.NewLine & _
"  -A, --align          : int  : alignment format, see --paramDetail align" & Environment.NewLine & _
"  -s, --scores         : int  : maximum number of scores to report" & Environment.NewLine & _
"  -n, --alignments     : int  : maximum number of alignments to report" & Environment.NewLine & _
"  -u, --match          : int  : score for a match (BLASTN only)" & Environment.NewLine & _
"  -v, --mismatch       : int  : score for a missmatch (BLASTN only)" & Environment.NewLine & _
"  -o, --gapopen        : int  : gap open penalty" & Environment.NewLine & _
"  -x, --gapext         : int  : gap extension penalty" & Environment.NewLine & _
"  -d, --dropoff        : int  : drop-off score" & Environment.NewLine & _
"  -g, --gapalign       :      : optimise gapped alignments" & Environment.NewLine & _
"      --seqrange       : str  : region in query sequence to use for search" & Environment.NewLine & _
"      --multifasta     :      : treat input as a set of fasta formatted " & Environment.NewLine & _
"                                sequences." & Environment.NewLine

		' Execution entry point.
		Public Shared Function Main(ByVal args As String()) As Integer
			Dim retVal As Integer = 0 ' Return value
			' Create an instance of the wrapper object
			Dim wsApp As NcbiBlastCliClient = New NcbiBlastCliClient()
			' If no arguments print usage and return.
			If args.Length < 1 Then
				wsApp.PrintUsageMessage()
				Return retVal
			End If
			Try
				' Parse the command line
				wsApp.ParseCommand(args)
				' Perform the selected action
				Select Case wsApp.Action
					Case "paramList" ' List parameter names
						wsApp.PrintParams()
						Exit Select
					Case "paramDetail" ' Parameter detail
						wsApp.PrintParamDetail(wsApp.ParamName)
						Exit Select
					Case "submit" ' Submit a job
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
					Case "getids" ' Get IDs from job result
						wsApp.PrintGetIds()
						Exit Select
					Case "help" ' Do help
						wsApp.PrintUsageMessage()
						Exit Select
					Case Else ' Any other action.
						Console.WriteLine("Error: unknown action " & wsApp.Action)
						retVal = 1
						Exit Select
				End Select
			Catch ex As System.Exception ' Catch all exceptions
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
		Private Sub ParseCommand(args As String())
			PrintDebugMessage("ParseCommand", "Begin", 1)
			InParams = New EbiWS.NcbiBlastWs.InputParameters()
			' Force any default values
			InParams.stype = "protein"
			' Loop over command-line options
			For i As Integer = 0 To (args.Length - 1) Step 1
				PrintDebugMessage("parseCommand", "arg: " & args(i), 2)
				Select Case args(i)
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
					Case "--jobid" ' Job Id to get status or results.
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
					Case "--resultTypes" ' Get list of result types.
						Action = "resultTypes"
						Exit Select
					Case "/resultTypes"
						Action = "resultTypes"
						Exit Select
					Case "--polljob" ' Get results for job.
						Action = "polljob"
						Exit Select
					Case "/polljob"
						Action = "polljob"
						Exit Select
					Case "--outfile" ' Base name for results file(s).
						i += 1 ' Shift to parameter value.
						OutFile = args(i)
						Exit Select
					Case "/outfile"
						i += 1 ' Shift to parameter value.
						OutFile = args(i)
						Exit Select
					Case "--outformat" ' Only save results of this format.
						i += 1 ' Shift to parameter value.
						OutFormat = args(i)
						Exit Select
					Case "/outformat"
						i += 1 ' Shift to parameter value.
						OutFormat = args(i)
						Exit Select
					Case "--ids" ' Get entry IDs from result.
						Action = "getids"
						Exit Select
					Case "/ids"
						Action = "getids"
						Exit Select
					Case "--verbose" ' Increase output level
						OutputLevel += 1
						Exit Select
					Case "/verbose"
						OutputLevel += 1
						Exit Select
					Case "--quiet" ' Decrease output level
						OutputLevel -= 1
						Exit Select
					Case "/quiet"
						OutputLevel -= 1
						Exit Select
					Case "--email" ' User e-mail address.
						i += 1 ' Shift to parameter value.
						Email = args(i)
						Exit Select
					Case "/email"
						i += 1 ' Shift to parameter value.
						Email = args(i)
						Exit Select
					Case "--title" ' Job title.
						i += 1 ' Shift to parameter value.
						JobTitle = args(i)
						Exit Select
					Case "/title"
						i += 1 ' Shift to parameter value.
						JobTitle = args(i)
						Exit Select
					Case "--async" ' Async submission.
						Action = "submit"
						Async = True
						Exit Select
					Case "/async"
						Action = "submit"
						Async = true
						Exit Select
					Case "--debugLevel" ' Set debug output level.
						i += 1 ' Shift to parameter value.
						DebugLevel = Convert.ToInt32(args(i))
						Exit Select
					Case "/debugLevel"
						i += 1 ' Shift to parameter value.
						DebugLevel = Convert.ToInt32(args(i))
						Exit Select
					Case "--endpoint" ' Service endpoint.
						i += 1 ' Shift to parameter value.
						ServiceEndPoint = args(i)
						Exit Select
					Case "/endpoint"
						i += 1 ' Shift to parameter value.
						ServiceEndPoint = args(i)
						Exit Select
					case "--multifasta" ' Multiple fasta format input.
						Me.multifasta = True
						Exit Select
					Case "/multifasta"
						Me.multifasta = True
						Exit Select

					' Tool specific options
					Case "--program" ' BLAST program.
						i += 1 ' Shift to parameter value.
						InParams.program = args(i)
						Action = "submit"
						Exit Select
					Case "-p"
						i += 1 ' Shift to parameter value.
						InParams.program = args(i)
						Action = "submit"
						Exit Select
					Case "/program"
						i += 1 ' Shift to parameter value.
						InParams.program = args(i)
						Action = "submit"
						Exit Select
					Case "/p"
						i += 1 ' Shift to parameter value.
						InParams.program = args(i)
						Action = "submit"
						Exit Select
					Case "--database" ' Database to search
						i += 1 ' Shift to parameter value.
						Dim sepList As Char() = {" "C, ","C}
						InParams.database = args(i).Split(sepList)
						Action = "submit"
						Exit Select
					Case "-D"
						i += 1 ' Shift to parameter value.
						Dim sepList As Char() = {" "C, ","C}
						InParams.database = args(i).Split(sepList)
						Action = "submit"
						Exit Select
					Case "/database"
						i += 1 ' Shift to parameter value.
						Dim sepList As Char() = {" "C, ","C}
						InParams.database = args(i).Split(sepList)
						Action = "submit"
						Exit Select
					Case "/D"
						i += 1 ' Shift to parameter value.
						Dim sepList As Char() = {" "C, ","C}
						InParams.database = args(i).Split(sepList)
						Action = "submit"
						Exit Select
					Case "--stype" ' Input sequence type.
						i += 1 ' Shift to parameter value.
						InParams.stype = args(i)
						Exit Select
					Case "/stype"
						i += 1 ' Shift to parameter value.
						InParams.stype = args(i)
						Exit Select
					Case "--matrix" ' Scoring matrix
						i += 1 ' Shift to parameter value.
						InParams.matrix = args(i)
						Action = "submit"
						Exit Select
					Case "-m"
						i += 1 ' Shift to parameter value.
						InParams.matrix = args(i)
						Action = "submit"
						Exit Select
					Case "/matrix"
						i += 1 ' Shift to parameter value.
						InParams.matrix = args(i)
						Action = "submit"
						Exit Select
					Case "/m"
						i += 1 ' Shift to parameter value.
						InParams.matrix = args(i)
						Action = "submit"
						Exit Select
					Case "--exp" ' E-value threshold
						i += 1 ' Shift to parameter value.
						InParams.exp = args(i)
						Action = "submit"
						Exit Select
					Case "-E"
						i += 1 ' Shift to parameter value.
						InParams.exp = args(i)
						Action = "submit"
						Exit Select
					Case "/exp"
						i += 1 ' Shift to parameter value.
						InParams.exp = args(i)
						Action = "submit"
						Exit Select
					Case "/E"
						i += 1 ' Shift to parameter value.
						InParams.exp = args(i)
						Action = "submit"
						Exit Select
					Case "--filter" ' Low complexity filter
						i += 1 ' Shift to parameter value.
						InParams.filter = args(i)
						Action = "submit"
						Exit Select
					Case "-f"
						i += 1 ' Shift to parameter value.
						InParams.filter = args(i)
						Action = "submit"
						Exit Select
					Case "/filter"
						i += 1 ' Shift to parameter value.
						InParams.filter = args(i)
						Action = "submit"
						Exit Select
					Case "/f"
						i += 1 ' Shift to parameter value.
						InParams.filter = args(i)
						Action = "submit"
						Exit Select
					Case "--align" ' Alignment format
						i += 1 ' Shift to parameter value.
                        InParams.align = Convert.ToInt32(args(i))
                        InParams.alignSpecified = True
						Action = "submit"
						Exit Select
					Case "/align"
						i += 1 ' Shift to parameter value.
                        InParams.align = Convert.ToInt32(args(i))
                        InParams.alignSpecified = True
						Action = "submit"
						Exit Select
					Case "--scores" ' Maximum number of scores to report
						i += 1 ' Shift to parameter value.
                        InParams.scores = Convert.ToInt32(args(i))
                        InParams.scoresSpecified = True
						Action = "submit"
						Exit Select
					Case "-s"
						i += 1 ' Shift to parameter value.
						InParams.scores = Convert.ToInt32(args(i))
                        InParams.scoresSpecified = True
                        Action = "submit"
						Exit Select
					Case "/scores"
						i += 1 ' Shift to parameter value.
						InParams.scores = Convert.ToInt32(args(i))
                        InParams.scoresSpecified = True
                        Action = "submit"
						Exit Select
					Case "/s"
						i += 1 ' Shift to parameter value.
						InParams.scores = Convert.ToInt32(args(i))
                        InParams.scoresSpecified = True
                        Action = "submit"
						Exit Select
					Case "--alignments" ' Maximum number of alignments to report
						i += 1 ' Shift to parameter value.
                        InParams.alignments = Convert.ToInt32(args(i))
                        InParams.alignmentsSpecified = True
						Action = "submit"
						Exit Select
					Case "/alignments"
						i += 1 ' Shift to parameter value.
						InParams.alignments = Convert.ToInt32(args(i))
                        InParams.alignmentsSpecified = True
                        Action = "submit"
						Exit Select
					Case "--numal"
						i += 1 ' Shift to parameter value.
						InParams.alignments = Convert.ToInt32(args(i))
                        InParams.alignmentsSpecified = True
                        Action = "submit"
						Exit Select
					Case "/numal"
						i += 1 ' Shift to parameter value.
						InParams.alignments = Convert.ToInt32(args(i))
                        InParams.alignmentsSpecified = True
                        Action = "submit"
						Exit Select
					Case "-n"
						i += 1 ' Shift to parameter value.
						InParams.alignments = Convert.ToInt32(args(i))
                        InParams.alignmentsSpecified = True
                        Action = "submit"
						Exit Select
					Case "/n"
						i += 1 ' Shift to parameter value.
						InParams.alignments = Convert.ToInt32(args(i))
                        InParams.alignmentsSpecified = True
                        Action = "submit"
						Exit Select
					Case "--dropoff" ' Drop-off score.
						i += 1 ' Shift to parameter value.
						InParams.dropoff = Convert.ToInt32(args(i))
                        InParams.dropoffSpecified = True
                        Action = "submit"
						Exit Select
					Case "-d"
						i += 1 ' Shift to parameter value.
						InParams.dropoff = Convert.ToInt32(args(i))
                        InParams.dropoffSpecified = True
                        Action = "submit"
						Exit Select
					Case "/dropoff"
						i += 1 ' Shift to parameter value.
						InParams.dropoff = Convert.ToInt32(args(i))
                        InParams.dropoffSpecified = True
                        Action = "submit"
						Exit Select
					Case "/d"
						i += 1 ' Shift to parameter value.
						InParams.dropoff = Convert.ToInt32(args(i))
                        InParams.dropoffSpecified = True
                        Action = "submit"
						Exit Select
					Case "--opengap" ' Gap open penalty
						i += 1 ' Shift to parameter value.
						InParams.gapopen = Convert.ToInt32(args(i))
                        InParams.gapopenSpecified = True
                        Action = "submit"
						Exit Select
					Case "-o"
						i += 1 ' Shift to parameter value.
						InParams.gapopen = Convert.ToInt32(args(i))
                        InParams.gapopenSpecified = True
                        Action = "submit"
						Exit Select
					Case "/opengap"
						i += 1 ' Shift to parameter value.
						InParams.gapopen = Convert.ToInt32(args(i))
                        InParams.gapopenSpecified = True
                        Action = "submit"
						Exit Select
					Case "/o"
						i += 1 ' Shift to parameter value.
						InParams.gapopen = Convert.ToInt32(args(i))
                        InParams.gapopenSpecified = True
                        Action = "submit"
						Exit Select
					Case "--extendgap" ' Gap extension penalty.
						i += 1 ' Shift to parameter value.
						InParams.gapext = Convert.ToInt32(args(i))
                        InParams.gapextSpecified = True
                        Action = "submit"
						Exit Select
					Case "-e"
						i += 1 ' Shift to parameter value.
						InParams.gapext = Convert.ToInt32(args(i))
                        InParams.gapextSpecified = True
                        Action = "submit"
						Exit Select
					Case "/extendgap"
						i += 1 ' Shift to parameter value.
						InParams.gapext = Convert.ToInt32(args(i))
                        InParams.gapextSpecified = True
                        Action = "submit"
						Exit Select
					Case "/e"
						i += 1 ' Shift to parameter value.
						InParams.gapext = Convert.ToInt32(args(i))
                        InParams.gapextSpecified = True
                        Action = "submit"
						Exit Select
					Case "--gapalign" ' Use gapped alignments
						InParams.gapalign = True
						Action = "submit"
						Exit Select
					Case "-g"
						InParams.gapalign = True
						Action = "submit"
						Exit Select
					Case "/gapalign"
						InParams.gapalign = True
						Action = "submit"
						Exit Select
					Case "/g"
						InParams.gapalign = True
						Action = "submit"
						Exit Select
					Case "--nogapalign" ' Don't use gapped alignments
						InParams.gapalign = False
						Action = "submit"
						Exit Select
					Case "/nogapalign" ' Don't use gapped alignments
						InParams.gapalign = False
						Action = "submit"
						Exit Select

					' Input data/sequence option
					Case "--sequence" ' Input sequence
						i += 1 ' Shift to parameter value.
						InParams.sequence = args(i)
						Action = "submit"
						Exit Select
					Case Else
						' Check for unknown option.
						If args(i).StartsWith("--") Or (args(i).LastIndexOf("/") = 0) Then
							Console.Error.WriteLine("Error: unknown option: " & args(i) & Environment.NewLine)
							Action = "exit"
							Exit For
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
