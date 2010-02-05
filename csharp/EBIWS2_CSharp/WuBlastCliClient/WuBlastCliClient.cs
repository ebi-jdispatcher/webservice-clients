/* $Id$
 * ======================================================================
 * jDispatcher SOAP command-line client for WU-BLAST
 * ====================================================================== */
using System;
using System.IO;
using EbiWS.WuBlastWs;

namespace EbiWS
{
	class WuBlastCliClient : EbiWS.WuBlastClient
	{
		// TODO: update for WU-BLAST service options
		/// <summary>Tool specific usage</summary>
		private string usageMsg = @"WU-BLAST
==========

Rapid sequence database search programs utilizing the BLAST algorithm
    
[Required]

  -p, --program      : str  : BLAST program to use, see --paramDetail program
  -D, --database     : str  : database(s) to search, space separated. See
                              --paramDetail database
      --stype        : str  : query sequence type, see --paramDetail stype
  seqFile            : file : query sequence (""-"" for STDIN, @filename for
                              identifier list file)

[Optional]

  -m, --matrix       : str  : scoring matrix, see --paramDetail matrix
  -e, --exp          : real : 0<E<=1000. Statistical significance threshold 
                              for reporting database sequence matches.
  -e, --viewfilter   :      : display the filtered query sequence
  -f, --filter       : str  : filter the query sequence for low complexity 
                              regions, see --paramDetail filter
  -A, --align        : int  : pairwise alignment format, see --paramDetail align
  -s, --scores       : int  : number of scores to be reported
  -b, --alignments   : int  : number of alignments to report
  -S, --sensitivity  : str  : sensitivity of the search, 
                              see --paramDetail sensitivity
  -t, --sort         : str  : sort order for hits, see --paramDetail sort
  -T, --stats        : str  : statistical model, see --paramDetail stats
  -d, --strand       : str  : DNA strand to search with,
                              see --paramDetail strand
  -c, --topcombon    : str  : consistent sets of HSPs
";

		/// <summary>Execution entry point</summary>
		/// <param name="args">Command-line parameters</param>
		/// <returns>Exit status</returns>
		public static int Main(string[] args)
		{
			int retVal = 0; // Return value
			// Create an instance of the wrapper object
			WuBlastCliClient wsApp = new WuBlastCliClient();
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
			// Force default values
			InParams.stype = "protein";
			InParams.program = null;
			InParams.database = null;
			InParams.exp = "10";
			InParams.alignments = 50;
			InParams.alignmentsSpecified = true;
			InParams.scores = 50;
			InParams.scoresSpecified = true;
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
					case "--stype": // Query sequence type
						InParams.stype = args[++i];
						break;
					case "/stype":
						goto case "--stype";
					case "--matrix": // Scoring matrix
						InParams.matrix = args[++i];
						Action = "submit";
						break;
					case "-m":
						goto case "--matrix";
					case "/matrix":
						goto case "--matrix";
					case "/m":
						goto case "--matrix";
					case "--exp": // E-value threshold
						InParams.exp = args[++i];
						Action = "submit";
						break;
					case "-e":
						goto case "--exp";
					case "/exp":
						goto case "--exp";
					case "/e":
						goto case "--exp";
					case "--viewfilter": // Report filtered sequence in output
						InParams.viewfilter = true;
						InParams.viewfilterSpecified = true;
						break;
					case "/viewfilter":
						goto case "--viewfilter";
					case "--filter": // Low complexity filter name
						InParams.filter = args[++i];
						Action = "submit";
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
						Action = "submit";
						break;
					case "/align":
						goto case "--align";
					case "-A":
						goto case "--align";
					case "/A":
						goto case "--align";
					case "--scores": // Maximum number of scores to report
						InParams.scores = Convert.ToInt32(args[++i]);
						InParams.scoresSpecified = true;
						Action = "submit";
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
						Action = "submit";
						break;
					case "/alignments":
						goto case "--alignments";
					case "-b":
						goto case "--alignments";
					case "/b":
						goto case "--alignments";
					case "--numal": // Compatibility option
						goto case "--alignments";
					case "/numal":
						goto case "--alignments";
					case "-n":
						goto case "--alignments";
					case "/n":
						goto case "--alignments";
					case "--sensitivity": // Search sensitivity
						InParams.sensitivity = args[++i];
						break;
					case "/sensitivity":
						goto case "--sensitivity";
					case "-S":
						goto case "--sensitivity";
					case "/S":
						goto case "--sensitivity";
					case "--sort": // Sort order for hits
						InParams.sort = args[++i];
						break;
					case "/sort":
						goto case "--sort";
					case "-t":
						goto case "--sort";
					case "/t":
						goto case "--sort";
					case "--stats": // Statistical model
						InParams.stats = args[++i];
						break;
					case "/stats":
						goto case "--stats";
					case "-T":
						goto case "--stats";
					case "/T":
						goto case "--stats";
					case "--strand": // Query strand for nucleotide searches
						InParams.strand = args[++i];
						break;
					case "/strand":
						goto case "--strand";
					case "-d":
						goto case "--strand";
					case "/d":
						goto case "--strand";
					case "--topcombon": // consistent sets of HSPs
						InParams.topcombon = args[++i];
						break;
					case "/topcombon":
						goto case "--topcombon";
					case "-c":
						goto case "--topcombon";
					
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
