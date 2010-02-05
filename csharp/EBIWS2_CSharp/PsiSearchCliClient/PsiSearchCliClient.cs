/* $Id$
 * ======================================================================
 * jDispatcher SOAP command-line client for NCBI PSI-Search
 * ====================================================================== */
using System;
using System.IO;
using EbiWS.PsiSearchWs;

namespace EbiWS
{
	class PsiSearchCliClient : EbiWS.PsiSearchClient
	{
		/// <summary>Tool specific usage</summary>
		private string usageMsg = @"PSI-Search
==============

Iterative profile search using Smith-Waterman (SSEARCH) and PSI-BLAST.

[Required]

      --database      : str  : database to search, see --paramDetail database
  seqFile             : file : query sequence (""-"" for STDIN)

[Optional]

  -f, --gapopen       : int  : penalty for gap opening
  -g, --gapext        : int  : penalty for additional residues in a gap
  -b, --scores        : int  : maximum number of scores
  -d, --alignments    : int  : maximum number of alignments
  -s, --matrix        : str  : scoring matrix, see --paramDetail matrix
  -E, --expthr        : real : E-value limit for hit display
      --psithr        : real : E-value limit for inclusion in PSSM
      --previousjobid : str  : job identifier from previous iteration
      --selectedHits  : str  : file containing list of hits selected to 
                               create PSSM.
      --cpfile        : str  : checkpoint file, ASN.1 binary
";

		/// <summary>Execution entry point</summary>
		/// <param name="args">Command-line parameters</param>
		/// <returns>Exit status</returns>
		public static int Main(string[] args)
		{
			int retVal = 0; // Return value
			// Create an instance of the wrapper object
			PsiSearchCliClient wsApp = new PsiSearchCliClient();
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
						wsApp.SubmitJob();
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
			for (int i = 0; i < args.Length; i++)
			{
				PrintDebugMessage("parseCommand", "arg: " + args[i], 2);
				switch (args[i])
				{
						// Generic options
					case "--help": // Usage info
						Action = "help";
						break;
					case "/help":
						goto case "--help";
				case "-h":
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

						// Tool specific options
					case "--database": // Database to search
						InParams.database = args[++i];
						Action = "submit";
						break;
					case "/database":
						goto case "--database";
					case "--matrix": // Scoring matrix
						InParams.matrix = args[++i];
						Action = "submit";
						break;
					case "-s":
						goto case "--matrix";
					case "/matrix":
						goto case "--matrix";
					case "/s":
						goto case "--matrix";
					case "--expthr": // E-value threshold
						InParams.expthr = Convert.ToDouble(args[++i]);
						InParams.expthrSpecified = true;
						Action = "submit";
						break;
					case "-E":
						goto case "--expthr";
					case "/expthr":
						goto case "--expthr";
					case "/E":
						goto case "--expthr";
				case "--psithr": // PSI E-value threshold
					InParams.psithr = Convert.ToDouble(args[++i]);
					InParams.psithrSpecified = true;
					break;
				case "/psithr":
					goto case "--psithr";
					case "--scores": // Maximum number of scores to report
						InParams.scores = Convert.ToInt32(args[++i]);
						Action = "submit";
						break;
					case "-b":
						goto case "--scores";
					case "/scores":
						goto case "--scores";
					case "/b":
						goto case "--scores";
					case "--alignments": // Maximum number of alignments to report
						InParams.alignments = Convert.ToInt32(args[++i]);
						Action = "submit";
						break;
				case "-d":
					goto case "--alignments";
					case "/alignments":
						goto case "--alignments";
				case "/d":
					goto case "--alignments";
					case "--gapopen": // Gap open penalty
						InParams.gapopen = Convert.ToInt32(args[++i]);
						Action = "submit";
						break;
					case "-f":
						goto case "--gapopen";
					case "/gapopen":
						goto case "--gapopen";
					case "/f":
						goto case "--gapopen";
					case "--gapext": // Gap extension penalty
						InParams.gapext = Convert.ToInt32(args[++i]);
						Action = "submit";
						break;
					case "-g":
						goto case "--gapext";
					case "/gapext":
						goto case "--gapext";
					case "/g":
						goto case "--gapext";
				case "--previousjobid": // Job identifier for prev. iteration
					InParams.previousjobid = args[++i];
					break;
				case "/previousjobid":
					goto case "--previousjobid";
				case "--selectedHits": // List of selected hits for PSSM
					InParams.selectedHits = ReadFile(args[++i]);
					break;
				case "/selectedHits":
					goto case "--selectedHits";
				case "--cpfile": // Checkpoint file from prev. iteration
					InParams.cpfile = ReadFile(args[++i]);
					break;
				case "/cpfile":
					goto case "--cpfile";

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
						InParams.sequence = LoadData(args[i]);
						Action = "submit";
						break;
				}
			}
			PrintDebugMessage("ParseCommand", "End", 1);
		}
	}
}
