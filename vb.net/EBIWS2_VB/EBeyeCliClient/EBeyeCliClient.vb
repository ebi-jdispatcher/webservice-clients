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
' Sample VB.NET ommand-line client for EB-eye (SOAP)
'
' See:
' http://www.ebi.ac.uk/Tools/webservices/services/eb-eye
' http://www.ebi.ac.uk/Tools/webservices/tutorials/vb.net
' ======================================================================
Option Explicit On
Option Strict On

Imports System
Imports System.IO
Imports EbiWS.EBeyeWs

Namespace EbiWS
    Public Class EBeyeCliClient
        Inherits EbiWS.EBeyeClient
        ' Tool specific usage.
        Private usageMsg As String = _
      "EB-eye" & Environment.NewLine & _
      "======" & Environment.NewLine & _
      Environment.NewLine & _
      "--listDomains" & Environment.NewLine & _
      "  Returns a list of all the domains identifiers which can be used in a query." & Environment.NewLine & _
      Environment.NewLine & _
"--getNumberOfResults <domain> <query>" & Environment.NewLine & _
"  Executes a query and returns the number of results found." & Environment.NewLine & _
Environment.NewLine & _
"--getResultsIds <domain> <query> <start> <size>" & Environment.NewLine & _
"  Executes a query and returns the list of identifiers for the entries found." & Environment.NewLine & _
Environment.NewLine & _
"--getAllResultsIds <domain> <query>" & Environment.NewLine & _
"  Executes a query and returns the list of all the identifiers for the entries" & Environment.NewLine & _
"  found. " & Environment.NewLine & _
Environment.NewLine & _
"--listFields <domain>" & Environment.NewLine & _
"  Returns the list of fields that can be retrieved for a particular domain." & Environment.NewLine & _
Environment.NewLine & _
"--getResults <domain> <query> <fields> <start> <size>" & Environment.NewLine & _
"  Executes a query and returns a list of results. Each result contains the " & Environment.NewLine & _
"  values for each field specified in the ""fields"" argument in the same order " & Environment.NewLine & _
"  as they appear in the ""fields"" list." & Environment.NewLine & _
Environment.NewLine & _
"--getEntry <domain> <entry> <fields>" & Environment.NewLine & _
"  Search for a particular entry in a domain and returns the values for some " & Environment.NewLine & _
"  of the fields of this entry. The result contains the values for each field " & Environment.NewLine & _
"  specified in the ""fields"" argument in the same order as they appear in the " & Environment.NewLine & _
"  ""fields"" list." & Environment.NewLine & _
Environment.NewLine & _
"--getEntries <domain> <entries> <fields>" & Environment.NewLine & _
"  Search for entries in a domain and returns the values for some of the " & Environment.NewLine & _
"  fields of these entries. The result contains the values for each field " & Environment.NewLine & _
"  specified in the ""fields"" argument in the same order as they appear in the " & Environment.NewLine & _
"  ""fields"" list. " & Environment.NewLine & _
Environment.NewLine & _
"--getEntryFieldUrls <domain> <entry> <fields>" & Environment.NewLine & _
"  Search for a particular entry in a domain and returns the urls configured " & Environment.NewLine & _
"  for some of the fields of this entry. The result contains the urls for each " & Environment.NewLine & _
"  field specified in the ""fields"" argument in the same order as they appear " & Environment.NewLine & _
"  in the ""fields"" list. " & Environment.NewLine & _
Environment.NewLine & _
"--getEntriesFieldUrls <domain> <entries> <fields>" & Environment.NewLine & _
"  Search for a list of entries in a domain and returns the urls configured for" & Environment.NewLine & _
"  some of the fields of these entries. Each result contains the url for each " & Environment.NewLine & _
"  field specified in the ""fields"" argument in the same order as they appear in" & Environment.NewLine & _
"  the ""fields"" list. " & Environment.NewLine & _
Environment.NewLine & _
"--getDomainsReferencedInDomain <domain>" & Environment.NewLine & _
"  Returns the list of domains with entries referenced in a particular domain. " & Environment.NewLine & _
"  These domains are indexed in the EB-eye. " & Environment.NewLine & _
Environment.NewLine & _
"--getDomainsReferencedInEntry <domain> <entry>" & Environment.NewLine & _
"  Returns the list of domains with entries referenced in a particular domain " & Environment.NewLine & _
"  entry. These domains are indexed in the EB-eye. " & Environment.NewLine & _
Environment.NewLine & _
"--listAdditionalReferenceFields <domain>" & Environment.NewLine & _
"  Returns the list of fields corresponding to databases referenced in the " & Environment.NewLine & _
"  domain but not included as a domain in the EB-eye. " & Environment.NewLine & _
Environment.NewLine & _
"--getReferencedEntries <domain> <entry> <referencedDomain>" & Environment.NewLine & _
"  Returns the list of referenced entry identifiers from a domain referenced " & Environment.NewLine & _
"  in a particular domain entry. " & Environment.NewLine & _
Environment.NewLine & _
"--getReferencedEntriesSet <domain> <entries> <referencedDomain> <fields>" & Environment.NewLine & _
"  Returns the list of referenced entries from a domain referenced in a set of" & Environment.NewLine & _
"  entries. The result will be returned as a list of objects, each representing" & Environment.NewLine & _
"  an entry reference." & Environment.NewLine & _
Environment.NewLine & _
"--getReferencedEntriesFlatSet <domain> <entries> <referencedDomain> <fields>" & Environment.NewLine & _
"  Returns the list of referenced entries from a domain referenced in a set of " & Environment.NewLine & _
"  entries. The result will be returned as a flat table corresponding to the " & Environment.NewLine & _
"  list of results where, for each result, the first value is the original " & Environment.NewLine & _
"  entry identifier and the other values correspond to the fields values. " & Environment.NewLine & _
Environment.NewLine & _
"--getDomainsHierarchy" & Environment.NewLine & _
"  Returns the hierarchy of the domains available." & Environment.NewLine & _
Environment.NewLine & _
"--getDetailledNumberOfResults <domain> <query> <flat>" & Environment.NewLine & _
"  Executes a query and returns the number of results found per domain." & Environment.NewLine & _
Environment.NewLine & _
"--listFieldsInformation <domain>" & Environment.NewLine & _
"  Returns the list of fields that can be retrievedand/or searched for a " & Environment.NewLine & _
"  particular domain. " & Environment.NewLine & _
Environment.NewLine & _
"Further information:" & Environment.NewLine & _
Environment.NewLine & _
"  http://www.ebi.ac.uk/Tools/webservices/services/eb-eye" & Environment.NewLine & _
"  http://www.ebi.ac.uk/Tools/webservices/tutorials/vb.net" & Environment.NewLine & _
Environment.NewLine & _
"Support/Feedback:" & Environment.NewLine & _
Environment.NewLine & _
"  http://www.ebi.ac.uk/support/" & Environment.NewLine

        ' Execution entry point.
        Public Shared Function Main(ByVal args As String()) As Integer
            Dim retVal As Integer = 0 ' Return value
            ' Create an instance of the wrapper object
            Dim wsApp As EBeyeCliClient = New EBeyeCliClient()
            ' If no arguments print usage and return
            If args.Length < 1 Then
                wsApp.PrintUsageMessage()
                Return retVal
            End If
            Try
                ' Parse the command line
                retVal = wsApp.ParseCommand(args)
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
            PrintDebugMessage("PrintUsageMessage", "End", 1)
        End Sub

        ' Parse command-line options.
        Private Function ParseCommand(ByVal args As String()) As Integer
            PrintDebugMessage("ParseCommand", "Begin", 1)
            ' Return value.
            Dim retVal As Integer = 0
            ' Loop over command-line options.
            Dim i As Integer = 0
            While i < args.Length AndAlso retVal = 0
                PrintDebugMessage("parseCommand", "arg: " & args(i), 2)
                Select args(i)
                    ' Generic options
                    Case "--help" ' Usage info
                        PrintUsageMessage()
                        Exit Select
                    Case "-h"
                        PrintUsageMessage()
                        Exit Select
                    Case "/help"
                        PrintUsageMessage()
                        Exit Select
                    Case "/h"
                        PrintUsageMessage()
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
                    Case "--debugLevel" ' Debug output level.
                        i += 1
                        DebugLevel = Convert.ToInt32(args(i))
                        Exit Select
                    Case "/debugLevel"
                        i += 1
                        DebugLevel = Convert.ToInt32(args(i))
                        Exit Select
                    Case "--endpoint" ' Alternative service endpoint
                        i += 1
                        ServiceEndPoint = args(i)
                        Exit Select
                    Case "/endpoint"
                        i += 1
                        ServiceEndPoint = args(i)
                        Exit Select

                    Case "--listDomains" ' Domains available to search
                        PrintListDomains()
                        Exit Select
                    Case "--listdomains"
                        PrintListDomains()
                        Exit Select

                    Case "--getNumberOfResults" ' Get the number of results for a query
                        Dim paramList As String() = GetOptionParameters(args, i, retVal, 2)
                        If paramList.Length > 0 Then
                            PrintGetNumberOfResults(paramList(0), paramList(1))
                        End If
                        Exit Select
                    Case "--getnumberofresults"
                        Dim paramList As String() = GetOptionParameters(args, i, retVal, 2)
                        If paramList.Length > 0 Then
                            PrintGetNumberOfResults(paramList(0), paramList(1))
                        End If
                        Exit Select

                    Case "--getResultsIds" ' get result Ids for query
                        Dim paramList As String() = GetOptionParameters(args, i, retVal, 4)
                        If paramList.Length > 0 Then
                            PrintGetResultsIds(paramList(0), paramList(1), paramList(2), paramList(3))
                        End If
                        Exit Select
                    Case "--getresultsids"
                        Dim paramList As String() = GetOptionParameters(args, i, retVal, 4)
                        If paramList.Length > 0 Then
                            PrintGetResultsIds(paramList(0), paramList(1), paramList(2), paramList(3))
                        End If
                        Exit Select

                    Case "--getAllResultsIds" ' get all result Ids for query
                        Dim paramList As String() = GetOptionParameters(args, i, retVal, 2)
                        If paramList.Length > 0 Then
                            PrintGetAllResultsIds(paramList(0), paramList(1))
                        End If
                        Exit Select
                    Case "--getallresultsids"
                        Dim paramList As String() = GetOptionParameters(args, i, retVal, 2)
                        If paramList.Length > 0 Then
                            PrintGetAllResultsIds(paramList(0), paramList(1))
                        End If
                        Exit Select

                    Case "--listFields" ' Fields available for domain
                        Dim paramList As String() = GetOptionParameters(args, i, retVal, 1)
                        If paramList.Length > 0 Then
                            PrintListFields(paramList(0))
                        End If
                        Exit Select
                    Case "--listfields"
                        Dim paramList As String() = GetOptionParameters(args, i, retVal, 1)
                        If paramList.Length > 0 Then
                            PrintListFields(paramList(0))
                        End If
                        Exit Select

                    Case "--getResults" ' get results for query starting a result 'start' and in pages of size 'size'
                        Dim paramList As String() = GetOptionParameters(args, i, retVal, 5)
                        If paramList.Length > 0 Then
                            PrintGetResults(paramList(0), paramList(1), paramList(2), paramList(3), paramList(4))
                        End If
                        Exit Select
                    Case "--getresults"
                        Dim paramList As String() = GetOptionParameters(args, i, retVal, 5)
                        If paramList.Length > 0 Then
                            PrintGetResults(paramList(0), paramList(1), paramList(2), paramList(3), paramList(4))
                        End If
                        Exit Select

                    Case "--getEntry" ' get an entry (metadata indexed in EB-eye)
                        Dim paramList As String() = GetOptionParameters(args, i, retVal, 3)
                        If paramList.Length > 0 Then
                            PrintGetEntry(paramList(0), paramList(1), paramList(2))
                        End If
                        Exit Select
                    Case "--getentry"
                        Dim paramList As String() = GetOptionParameters(args, i, retVal, 3)
                        If paramList.Length > 0 Then
                            PrintGetEntry(paramList(0), paramList(1), paramList(2))
                        End If
                        Exit Select

                    Case "--getEntries" ' get multiple entries (metadata indexed in EB-eye)
                        Dim paramList As String() = GetOptionParameters(args, i, retVal, 3)
                        If paramList.Length > 0 Then
                            PrintGetEntries(paramList(0), paramList(1), paramList(2))
                        End If
                        Exit Select
                    Case "--getentries"
                        Dim paramList As String() = GetOptionParameters(args, i, retVal, 3)
                        If paramList.Length > 0 Then
                            PrintGetEntries(paramList(0), paramList(1), paramList(2))
                        End If
                        Exit Select

                    Case "--getEntryFieldUrls" ' get URLs for fields for an entry
                        Dim paramList As String() = GetOptionParameters(args, i, retVal, 3)
                        If paramList.Length > 0 Then
                            PrintGetEntryFieldUrls(paramList(0), paramList(1), paramList(2))
                        End If
                        Exit Select
                    Case "--getentryfieldurls"
                        Dim paramList As String() = GetOptionParameters(args, i, retVal, 3)
                        If paramList.Length > 0 Then
                            PrintGetEntryFieldUrls(paramList(0), paramList(1), paramList(2))
                        End If
                        Exit Select

                    Case "--getEntriesFieldUrls" ' get URLs for fields for a set of entries
                        Dim paramList As String() = GetOptionParameters(args, i, retVal, 3)
                        If paramList.Length > 0 Then
                            PrintGetEntriesFieldUrls(paramList(0), paramList(1), paramList(2))
                        End If
                        Exit Select
                    Case "--getentriesfieldurls"
                        Dim paramList As String() = GetOptionParameters(args, i, retVal, 3)
                        If paramList.Length > 0 Then
                            PrintGetEntriesFieldUrls(paramList(0), paramList(1), paramList(2))
                        End If
                        Exit Select

                    Case "--getDomainsReferencedInDomain" ' get domains references from a specific domain
                        Dim paramList As String() = GetOptionParameters(args, i, retVal, 1)
                        If paramList.Length > 0 Then
                            PrintGetDomainsReferencedInDomain(paramList(0))
                        End If
                        Exit Select
                    Case "--getdomainsreferencedindomain"
                        Dim paramList As String() = GetOptionParameters(args, i, retVal, 1)
                        If paramList.Length > 0 Then
                            PrintGetDomainsReferencedInDomain(paramList(0))
                        End If
                        Exit Select

                    Case "--getDomainsReferencedInEntry" ' get all domains referenced by an entry
                        Dim paramList As String() = GetOptionParameters(args, i, retVal, 2)
                        If paramList.Length > 0 Then
                            PrintGetDomainsReferencedInEntry(paramList(0), paramList(1))
                        End If
                        Exit Select
                    Case "--getdomainsreferencedinentry"
                        Dim paramList As String() = GetOptionParameters(args, i, retVal, 2)
                        If paramList.Length > 0 Then
                            PrintGetDomainsReferencedInEntry(paramList(0), paramList(1))
                        End If
                        Exit Select

                    Case "--listAdditionalReferenceFields" ' Additional (external) cross-references
                        Dim paramList As String() = GetOptionParameters(args, i, retVal, 1)
                        If paramList.Length > 0 Then
                            PrintListAdditionalReferenceFields(paramList(0))
                        End If
                        Exit Select
                    Case "--listadditionalreferencefields"
                        Dim paramList As String() = GetOptionParameters(args, i, retVal, 1)
                        If paramList.Length > 0 Then
                            PrintListAdditionalReferenceFields(paramList(0))
                        End If
                        Exit Select

                    Case "--getReferencedEntries" ' get all entries references for a domain
                        Dim paramList As String() = GetOptionParameters(args, i, retVal, 3)
                        If paramList.Length > 0 Then
                            PrintGetReferencedEntries(paramList(0), paramList(1), paramList(2))
                        End If
                        Exit Select
                    Case "--getreferencedentries"
                        Dim paramList As String() = GetOptionParameters(args, i, retVal, 3)
                        If paramList.Length > 0 Then
                            PrintGetReferencedEntries(paramList(0), paramList(1), paramList(2))
                        End If
                        Exit Select

                    Case "--getReferencedEntriesSet" ' get references for entries (set)
                        Dim paramList As String() = GetOptionParameters(args, i, retVal, 4)
                        If paramList.Length > 0 Then
                            PrintGetReferencedEntriesSet(paramList(0), paramList(1), paramList(2), paramList(3))
                        End If
                        Exit Select
                    Case "--getreferencedentriesset"
                        Dim paramList As String() = GetOptionParameters(args, i, retVal, 4)
                        If paramList.Length > 0 Then
                            PrintGetReferencedEntriesSet(paramList(0), paramList(1), paramList(2), paramList(3))
                        End If
                        Exit Select

                    Case "--getReferencedEntriesFlatSet"
                        Dim paramList As String() = GetOptionParameters(args, i, retVal, 4)
                        If paramList.Length > 0 Then
                            PrintGetReferencedEntriesFlatSet(paramList(0), paramList(1), paramList(2), paramList(3))
                        End If
                        Exit Select
                    Case "--getreferencedentriesflatset"
                        Dim paramList As String() = GetOptionParameters(args, i, retVal, 4)
                        If paramList.Length > 0 Then
                            PrintGetReferencedEntriesFlatSet(paramList(0), paramList(1), paramList(2), paramList(3))
                        End If
                        Exit Select

                    Case "--getDomainsHierarchy" ' list the EB-eye domain hierarchy
                        PrintGetDomainsHierarchy()
                        Exit Select
                    Case "--getdomainshierarchy"
                        PrintGetDomainsHierarchy()
                        Exit Select

                    Case "--getDetailledNumberOfResults" ' get detailed counts for number of results for a query in domains/subdomains
                        Dim paramList As String() = GetOptionParameters(args, i, retVal, 3)
                        If paramList.Length > 0 Then
                            PrintGetDetailledNumberOfResults(paramList(0), paramList(1), paramList(2))
                        End If
                        Exit Select
                    Case "--getdetaillednumberofresults"
                        Dim paramList As String() = GetOptionParameters(args, i, retVal, 3)
                        If paramList.Length > 0 Then
                            PrintGetDetailledNumberOfResults(paramList(0), paramList(1), paramList(2))
                        End If
                        Exit Select
                    Case "--getDetailedNumberOfResults"
                        Dim paramList As String() = GetOptionParameters(args, i, retVal, 3)
                        If paramList.Length > 0 Then
                            PrintGetDetailledNumberOfResults(paramList(0), paramList(1), paramList(2))
                        End If
                        Exit Select
                    Case "--getdetailednumberofresults"
                        Dim paramList As String() = GetOptionParameters(args, i, retVal, 3)
                        If paramList.Length > 0 Then
                            PrintGetDetailledNumberOfResults(paramList(0), paramList(1), paramList(2))
                        End If
                        Exit Select

                    Case "--listFieldsInformation" ' Field information
                        Dim paramList As String() = GetOptionParameters(args, i, retVal, 1)
                        If paramList.Length > 0 Then
                            PrintListFieldsInformation(paramList(0))
                        End If
                        Exit Select
                    Case "--listfieldsinformation"
                        Dim paramList As String() = GetOptionParameters(args, i, retVal, 1)
                        If paramList.Length > 0 Then
                            PrintListFieldsInformation(paramList(0))
                        End If
                        Exit Select

                    Case Else ' Don't know what to do, so print error message
                        Console.Error.WriteLine("Error: unknown option: " & args(i) & Environment.NewLine)
                        retVal = 1
                        Exit Select
                End Select
                i += 1
            End While
            PrintDebugMessage("ParseCommand", "End", 1)
            Return retVal
        End Function

        ' Get option parameters from command-line.
        Private Function GetOptionParameters(ByVal args As String(), ByRef position As Integer, ByRef retVal As Integer, ByVal numParam As Integer) As String()
            PrintDebugMessage("GetOptionParameters", "Begin", 11)
            Dim lastParamPosition As Integer = position + numParam
            Dim retList As String()
            If args.Length > lastParamPosition Then
                Dim tmpList(0 To numParam) As String
                Dim i As Integer = 0
                While position < lastParamPosition
                    position += 1
                    tmpList(i) = args(position)
                    i += 1
                End While
                retList = tmpList
            Else
            	retList = Nothing
                Console.Error.WriteLine("Error: insufficent arguments for " & args(position))
                retVal = 1
            End If
            PrintDebugMessage("GetOptionParameters", "End", 11)
            Return retList
        End Function
    End Class
End Namespace
