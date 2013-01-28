/* $Id$
 * ======================================================================
 * 
 * Copyright 2009-2013 EMBL - European Bioinformatics Institute
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * 
 * ======================================================================
 * jDispatcher SOAP command-line client for NCBI BLAST
 * ====================================================================== */
using System;
using System.IO;
using EbiWS.NcbiBlastWs;

namespace EbiWS
{
	class NcbiBlastCliClient : EbiWS.NcbiBlastClient
	{
		/// <summary>Tool specific usage</summary>
		private string usageMsg = @"NCBI BLAST
==========

Rapid sequence database search programs utilizing the BLAST algorithm

For more information see:
- http://www.ebi.ac.uk/Tools/sss/ncbiblast
- http://www.ebi.ac.uk/Tools/webservices/services/sss/ncbi_blast_soap

[Required]

  -p, --program        : str  : BLAST program to use: see --paramDetail program
  -D, --database       : str  : database(s) to search, space seperated: see
                                --paramDetail database
      --stype          : str  : query sequence type
  seqFile              : file : query sequence (""-"" for STDIN)

[Optional]

  -m, --matrix         : str  : scoring matrix, see --paramDetail matrix
  -e, --exp            : real : 0<E<= 1000. Statistical significance threshold
                                for reporting database sequence matches.
  -f, --filter         : str  : low complexity sequence filter, see
                                --paramDetail filter
  -A, --align          : int  : alignment format, see --paramDetail align
  -s, --scores         : int  : maximum number of scores to report
  -n, --alignments     : int  : maximum number of alignments to report
  -u, --match          : int  : score for a match (BLASTN only)
  -v, --mismatch       : int  : score for a missmatch (BLASTN only)
  -o, --gapopen        : int  : gap open penalty
  -x, --gapext         : int  : gap extension penalty
  -d, --dropoff        : int  : drop-off score
  -g, --gapalign       :      : optimise gapped alignments
      --seqrange       : str  : region in query sequence to use for search
      --multifasta     :      : treat input as a set of fasta formatted 
                                sequences.
";

		/// <summary>Execution entry point</summary>
		/// <param name="args">Command-line parameters</param>
		/// <returns>Exit status</returns>
		public static int Main(string[] args)
		{
			int retVal = 0; // Return value
			// Create an instance of the wrapper object
			NcbiBlastCliClient wsApp = new NcbiBlastCliClient();
			// If no arguments print usage and return
			if (args.Length < 1)
			{
				wsApp.PrintUsageMessage();
				return retVal;
			}
			try
			{
				// Parse the command line
				wsApp.ParseCommand(args);
				// Perform the selected action
				switch (wsApp.Action)
				{
					case "paramList": // List parameter names
						wsApp.PrintParams();
						break;
					case "paramDetail": // Parameter detail
						wsApp.PrintParamDetail(wsApp.ParamName);
						break;
					case "submit": // Submit a job
						wsApp.SubmitJobs();
						break;
					case "status": // Get job status
						wsApp.PrintStatus();
						break;
					case "resultTypes": // Get result types
						wsApp.PrintResultTypes();
						break;
					case "polljob": // Get job results
						wsApp.GetResults();
						break;
					case "getids": // Get IDs from job result
						wsApp.PrintGetIds();
						break;
					case "help": // Do help
						wsApp.PrintUsageMessage();
						break;
					default: // Any other action.
						Console.WriteLine("Error: unknown action " + wsApp.Action);
						retVal = 1;
						break;
				}
			}
			catch (System.Exception ex)
			{ // Catch all exceptions
				Console.Error.WriteLine("Error: " + ex.Message);
				Console.Error.WriteLine(ex.StackTrace);
				retVal = 2;
			}
			return retVal;
		}

		/// <summary>
		/// Print the usage message.
		/// </summary>
		private void PrintUsageMessage()
		{
			PrintDebugMessage("PrintUsageMessage", "Begin", 1);
			Console.WriteLine(usageMsg);
			PrintGenericOptsUsage();
			PrintDebugMessage("PrintUsageMessage", "End", 1);
		}

		/// <summary>Parse command-line options</summary>
		/// <param name="args">Command-line options</param>
		private void ParseCommand(string[] args)
		{
			PrintDebugMessage("ParseCommand", "Begin", 1);
			InParams = new InputParameters();
			// Force default values
			InParams.stype = "protein";
			for (int i = 0; i < args.Length; i++)
			{
				PrintDebugMessage("parseCommand", "arg: " + args[i], 2);
				switch (args[i])
				{
						// Generic options
					case "--help": // Usage info
						Action = "help";
						break;
					case "-h":
						goto case "--help";
					case "/help":
						goto case "--help";
					case "/h":
						goto case "--help";
					case "--params": // List input parameters
						Action = "paramList";
						break;
					case "/params":
						goto case "--params";
					case "--paramDetail": // Parameter details
						ParamName = args[++i];
						Action = "paramDetail";
						break;
					case "/paramDetail":
						goto case "--paramDetail";
					case "--jobid": // Job Id to get status or results
						JobId = args[++i];
						break;
					case "/jobid":
						goto case "--jobid";
					case "--status": // Get job status
						Action = "status";
						break;
					case "/status":
						goto case "--status";
					case "--resultTypes": // Get result types
						Action = "resultTypes";
						break;
					case "/resultTypes":
						goto case "--resultTypes";
					case "--polljob": // Get results for job
						Action = "polljob";
						break;
					case "/polljob":
						goto case "--polljob";
					case "--outfile": // Base name for results file(s)
						OutFile = args[++i];
						break;
					case "/outfile":
						goto case "--outfile";
					case "--outformat": // Only save results of this format
						OutFormat = args[++i];
						break;
					case "/outformat":
						goto case "--outformat";
					case "--ids": // Get entry IDs from result
						Action = "getids";
						break;
					case "/ids":
						goto case "--ids";
					case "--verbose": // Output level
						OutputLevel++;
						break;
					case "/verbose":
						goto case "--verbose";
					case "--quiet": // Output level
						OutputLevel--;
						break;
					case "/quiet":
						goto case "--quiet";
					case "--email": // User e-mail address
						Email = args[++i];
						break;
					case "/email":
						goto case "--email";
					case "--title": // Job title
						JobTitle = args[++i];
						break;
					case "/title":
						goto case "--title";
					case "--async": // Async submission
						Action = "submit";
						Async = true;
						break;
					case "/async":
						goto case "--async";
					case "--debugLevel":
						DebugLevel = Convert.ToInt32(args[++i]);
						break;
					case "/debugLevel":
						goto case "--debugLevel";
					case "--endpoint": // Service endpoint
						ServiceEndPoint = args[++i];
						break;
					case "/endpoint":
						goto case "--endpoint";
					case "--multifasta":
						this.multifasta = true;
						break;
					case "/multifasta":
						goto case "--multifasta";

						// Tool specific options
					case "--program": // BLAST program
						InParams.program = args[++i];
						Action = "submit";
						break;
					case "-p":
						goto case "--program";
					case "/program":
						goto case "--program";
					case "/p":
						goto case "--program";
					case "--database": // Database to search
						char[] sepList = { ' ', ',' };
						InParams.database = args[++i].Split(sepList);
						Action = "submit";
						break;
					case "-D":
						goto case "--database";
					case "/database":
						goto case "--database";
					case "/D":
						goto case "--database";
					case "--stype": // Input sequence type
						InParams.stype = args[++i];
						break;
					case "/stype":
						goto case "--stype";
					case "--matrix": // Scoring matrix
						InParams.matrix = args[++i];
						break;
					case "-m":
						goto case "--matrix";
					case "/matrix":
						goto case "--matrix";
					case "/m":
						goto case "--matrix";
					case "--exp": // E-value threshold
						InParams.exp = args[++i];
						break;
					case "-E":
						goto case "--exp";
					case "/exp":
						goto case "--exp";
					case "/E":
						goto case "--exp";
					case "--filter": // Low complexity filter
						InParams.filter = args[++i];
						break;
					case "-f":
						goto case "--filter";
					case "/filter":
						goto case "--filter";
					case "/f":
						goto case "--filter";
					case "--align": // Alignment format
						InParams.align = Convert.ToInt32(args[++i]);
						InParams.alignSpecified = true;
						break;
					case "/align":
						goto case "--align";
					case "--scores": // Maximum number of scores to report
						InParams.scores = Convert.ToInt32(args[++i]);
						InParams.scoresSpecified = true;
						break;
					case "-s":
						goto case "--scores";
					case "/scores":
						goto case "--scores";
					case "/s":
						goto case "--scores";
					case "--alignments": // Maximum number of alignments to report
						InParams.alignments = Convert.ToInt32(args[++i]);
						InParams.alignmentsSpecified = true;
						break;
					case "/alignments":
						goto case "--alignments";
					case "--numal":
						goto case "--alignments";
					case "/numal":
						goto case "--alignments";
					case "-n":
						goto case "--alignments";
					case "/n":
						goto case "--alignments";
					case "--dropoff": // Drop-off score
						InParams.dropoff = Convert.ToInt32(args[++i]);
						InParams.dropoffSpecified = true;
						break;
					case "-d":
						goto case "--dropoff";
					case "/dropoff":
						goto case "--dropoff";
					case "/d":
						goto case "--dropoff";
					case "--opengap": // Gap open penalty
						InParams.gapopen = Convert.ToInt32(args[++i]);
						InParams.gapopenSpecified = true;
						break;
					case "-o":
						goto case "--opengap";
					case "/opengap":
						goto case "--opengap";
					case "/o":
						goto case "--opengap";
					case "--extendgap": // Gap extension penalty
						InParams.gapext = Convert.ToInt32(args[++i]);
						InParams.gapextSpecified = true;
						break;
					case "-e":
						goto case "--extendgap";
					case "/extendgap":
						goto case "--extendgap";
					case "/e":
						goto case "--extendgap";
					case "--gapalign": // Enable gapped alignments.
						InParams.gapalign = true;
						break;
					case "-g":
						goto case "--gapalign";
					case "/gapalign":
						goto case "--gapalign";
					case "/g":
						goto case "--gapalign";
					case "--nogapalign": // Disable gapped alignments.
						InParams.gapalign = false;
						break;
					case "/nogapalign":
						goto case "--gapalign";

						// Input data/sequence option
					case "--sequence": // Input sequence
						i++;
						goto default;
					default:
						// Check for unknown option
						if (args[i].StartsWith("--") || args[i].LastIndexOf('/') == 0)
						{
							Console.Error.WriteLine("Error: unknown option: " + args[i] + "\n");
							Action = "exit";
							return;
						}
						// Must be data argument
						InParams.sequence = args[i];
						Action = "submit";
						break;
				}
			}
			PrintDebugMessage("ParseCommand", "End", 1);
		}
	}
}
