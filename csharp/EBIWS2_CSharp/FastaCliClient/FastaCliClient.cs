/* $Id$
 * ======================================================================
 * jDispatcher SOAP command-line client for FASTA
 * ====================================================================== */
using System;
using System.IO;
using EbiWS.FastaWs;

namespace EbiWS
{
	class FastaCliClient : EbiWS.FastaClient
	{
		// TODO: update options for FASTA service.
		/// <summary>Tool specific usage</summary>
		private string usageMsg = @"FASTA
==========

Rapid sequence database search programs utilizing the FASTA algorithm

For more detailed help information refer to
http://www.ebi.ac.uk/Tools/fasta/help.html
                
[Required]

      --program       : str  : FASTA program to use: see --paramDetail program
      --database      : str  : database(s) to search, space seperated: see
                               --paramDetail database
      --stype         : str  : query sequence type
  seqFile             : file : query sequence (""-"" for STDIN)

[Optional]

  -f, --gapopen       : int  : penalty for gap opening
  -g, --gapext        : int  : penalty for additional residues in a gap
  -b, --scores        : int  : maximum number of scores
  -d, --alignments    : int  : maximum number of alignments
  -k, --ktup          : int  : word size (DNA 1-6, Protein 1-2)
  -s, --matrix        : str  : scoring matrix name, see --paramDetail matrix
  -E, --eupper        : real : E-value upper limit for hit display
  -F, --elower        : real : E-value lower limit for hit display
  -H, --histogram     :      : turn off histogram display
  -n, --nucleotide    :      : force query to nucleotide sequence
  -3, --topstrand     :      : use only forward frame translations (DNA only)
  -i, --bottomstrand  :      : reverse complement query sequence (DNA only)
      --filter        : str  : low complexity input sequence filter,
                               see --paramDetail filter
  -z, --stats         : int  : statistical model for search,
                               see --paramDetail stats
  -M, --dbrange       : str  : define a subset database by sequence length
      --seqrange      : str  : search with a region of the query (START-END)
";

		/// <summary>Execution entry point</summary>
		/// <param name="args">Command-line parameters</param>
		/// <returns>Exit status</returns>
		public static int Main(string[] args)
		{
			int retVal = 0; // Return value
			// Create an instance of the wrapper object
			FastaCliClient wsApp = new FastaCliClient();
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
			InParams.hist = true;
			InParams.histSpecified = true;
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
					case "--program": // FASTA program
						InParams.program = args[++i];
						Action = "submit";
						break;
					case "/program":
						goto case "--program";
					case "--database": // Database to search
						char[] sepList = { ' ', ',' };
						InParams.database = args[++i].Split(sepList);
						Action = "submit";
						break;
					case "/database":
						goto case "--database";
					case "--stype": // Input sequence type
						InParams.stype = args[++i];
						Action = "submit";
						break;
					case "/stype":
						goto case "--stype";
					case "--matrix": // Scoring matrix
						InParams.matrix = args[++i];
						break;
					case "/matrix":
						goto case "--matrix";
					case "-s":
						goto case "--matrix";
					case "/s":
						goto case "--matrix";
					case "--eupper": // Upper E-value threshold
						InParams.expupperlim = Convert.ToDouble(args[++i]);
						InParams.expupperlimSpecified = true;
						break;
					case "/eupper":
						goto case "--eupper";
					case "-E":
						goto case "--eupper";
					case "/E":
						goto case "--eupper";
					case "--elower": // Lower E-value threshold
						InParams.explowlim = Convert.ToDouble(args[++i]);
						InParams.explowlimSpecified = true;
						break;
					case "/elower":
						goto case "--elower";
					case "-F":
						goto case "--elower";
					case "/F":
						goto case "--elower";
					case "--filter": // Low complexity filter
						InParams.filter = args[++i];
						break;
					case "/filter":
						goto case "--filter";
					case "--scores": // Maximum number of scores to report
						InParams.scores = Convert.ToInt32(args[++i]);
						InParams.scoresSpecified = true;
						break;
					case "/scores":
						goto case "--scores";
					case "-b":
						goto case "--scores";
					case "/b":
						goto case "--scores";
					case "--alignments": // Maximum number of alignments to report
						InParams.alignments = Convert.ToInt32(args[++i]);
						InParams.alignmentsSpecified = true;
						break;
					case "/alignments":
						goto case "--alignments";
					case "-d":
						goto case "--alignments";
					case "/d":
						goto case "--alignments";
					case "--gapopen": // Gap open penalty
						InParams.gapopen = Convert.ToInt32(args[++i]);
						InParams.gapopenSpecified = true;
						break;
					case "/gapopen":
						goto case "--gapopen";
					case "--opengap":
						goto case "--gapopen";
					case "/opengap":
						goto case "--gapopen";
					case "-f":
						goto case "--gapopen";
					case "/f":
						goto case "--gapopen";
					case "--gapext": // Gap extension penalty
						InParams.gapext = Convert.ToInt32(args[++i]);
						InParams.gapextSpecified = true;
						break;
					case "/gapext":
						goto case "--gapext";
					case "--extendgap":
						goto case "--gapext";
					case "/extendgap":
						goto case "--gapext";
					case "-g":
						goto case "--gapext";
					case "/g":
						goto case "--gapext";
					case "--ktup": // Word length (ktup)
						InParams.ktup = Convert.ToInt32(args[++i]);
						InParams.ktupSpecified = true;
						break;
					case "/ktup":
						goto case "--ktup";
					case "-k":
						goto case "--ktup";
					case "/k":
						goto case "--ktup";
					case "--histogram": // Suppress histogram
						InParams.hist = false;
						break;
					case "/histogram":
						goto case "--histogram";
					case "-H":
						goto case "--histogram";
					case "/H":
						goto case "--histogram";
					case "--nucleotide": // Nucleotide query sequence
						InParams.stype = "dna";
						break;
					case "/nucleotide":
						goto case "--nucleotide";
					case "-n":
						goto case "--nucleotide";
					case "/n":
						goto case "--nucleotide";
					case "--protein": // Protein query sequence
						InParams.stype = "protein";
						break;
					case "/protein":
						goto case "--nucleotide";
					case "-p":
						goto case "--nucleotide";
					case "/p":
						goto case "--nucleotide";
					case "--rna": // RNA query sequence
						InParams.stype = "rna";
						break;
					case "/rna":
						goto case "--rna";
					case "-r":
						goto case "--rna";
					case "/r":
						goto case "--rna";
					case "--topstrand": // TFAST[XY] use only forward frame translations
						InParams.strand = "top";
						break;
					case "/topstrand":
						goto case "--topstrand";
					case "-3":
						goto case "--topstrand";
					case "/3":
						goto case "--topstrand";
					case "--bottomstrand": // Search with reverse complement of sequence.
						InParams.strand = "bottom";
						break;
					case "/bottomstrand":
						goto case "--bottomstrand";
					case "-i":
						goto case "--bottomstrand";
					case "/i":
						goto case "--bottomstrand";
					case "--stats": // Statistical model
						InParams.stats = args[++i];
						break;
					case "/stats":
						goto case "--stats";
					case "-z":
						goto case "--stats";
					case "/z":
						goto case "--stats";
					case "--dbrange": // Range of lengths in database to search.
						InParams.dbrange = args[++i];
						break;
					case "/dbrange":
						goto case "--dbrange";
					case "-M":
						goto case "--dbrange";
					case "/M":
						goto case "--dbrange";
					case "--seqrange": // Region in sequence to use for search.
						InParams.seqrange = args[++i];
						break;
					case "/seqrange":
						goto case "--seqrange";

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