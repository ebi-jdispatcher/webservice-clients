/* $Id$
 * ======================================================================
 * jDispatcher SOAP command-line client for ClustalW2
 * ====================================================================== */
using System;
using System.IO;
using EbiWS.ClustalW2Ws;

namespace EbiWS
{
	class ClustalW2CliClient : EbiWS.ClustalW2Client
	{
		/// <summary>Tool specific usage</summary>
		private string usageMsg = @"ClustalW 2
==========

General purpose multiple sequence alignment program for DNA or protein.

ClustalW uses a progressive alignment approach that consists of three stages:

1. Pairwise (fast or slow) alignment of input sequences.
2. Generation of a guide tree from the pairwise alignments.
3. Multiple alignment using the guide tree to determine how sequences are 
added to the alignment.
    
[Required]

  seqFile            : file : sequences to align (""-"" for STDIN)

[Optional]

  -l, --alignment    : str  : pairwise alignment method, 
                              see --paramDetail alignment
      --type         : str  : sequence type, see --paramDetail type
  -o, --output       : str  : alignment format, see --paramDetail output
  -r, --outorder     : str  : order of sequences in alignment, 
                              see --paramDetail outorder

[Fast Pairwise Alignment]

  -k, --ktup         : int  : word size
  -w, --window       : int  : window size
  -s, --score        : str  : score type, see --paramDetail score
  -d, --topdiags     : int  : number of best diags.
  -p, --pairgap      : int  : gap penalty

[Slow Pairwise Alignment]

      --pwmatrix     : str  : Protein scoring matrix,
                              see --paramDetail pwmatrix
      --pwdnamatrix  : str  : DNA/RNA scoring matrix,
                              see --paramDetail pwdnamatrix
      --pwgapopen    : int  : gap creation penalty
      --pwgapext     : real : gap extension penalty

[Multiple Alignment]

  -m, --matrix       : str  : Protein scoring matrix,
                              see --paramDetail matrix
      --dnamatrix    : str  : DNA/RNA scoring matrix, 
                              see --paramDetail dnamatrix
  -g, --gapopen      : int  : gap creation penalty
      --noendgaps    : bool : no end gap separation penalty
  -x, --gapext       : real : gap extension penalty
  -y, --gapdist      : int  : gap seperation penalty
  -i, --iteration    : str  : iteration strategy, see --paramDetail iteration 
  -N, --numiter      : int  : maximum number of iterations
";

		/// <summary>Execution entry point</summary>
		/// <param name="args">Command-line parameters</param>
		/// <returns>Exit status</returns>
		public static int Main(string[] args)
		{
			int retVal = 0; // Return value
			// Create an instance of the wrapper object
			ClustalW2CliClient wsApp = new ClustalW2CliClient();
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
			InParams.type = "protein";
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
				case "--alignment":
					InParams.alignment = args[++i];
					break;
				case "/alignment": // Pairwise alignment method
					goto case "--alignment";
				case "-l":
					goto case "--alignment";
				case "/l":
					goto case "--alignment";
				case "--type": // Sequence type
					InParams.type = args[++i];
					break;
				case "/type":
					goto case "--type";
				case "--output": // Output format
					InParams.output = args[++i];
					break;
				case "/output":
					goto case "--output";
				case "-o":
					goto case "--output";
				case "/o":
					goto case "--output";
				case "--outorder": // Order of sequences in alignment
					InParams.outorder = args[++i];
					break;
				case "/outorder":
					goto case "--outorder";
				case "-r":
					goto case "--outorder";
				case "/r":
					goto case "--outorder";
				case "--ktup": // Word size (fast)
					InParams.ktup = Convert.ToInt32(args[++i]);
					InParams.ktupSpecified = true;
					break;
				case "/ktup":
					goto case "--ktup";
				case "-k":
					goto case "--ktup";
				case "/k":
					goto case "--ktup";
				case "--window": // Window size (fast)
					InParams.window = Convert.ToInt32(args[++i]);
					InParams.windowSpecified = true;
					break;
				case "/window":
					goto case "--window";
				case "-w":
					goto case "--window";
				case "/w":
					goto case "--window";
				case "--score": // Score type (fast)
					InParams.score = args[++i];
					break;
				case "/score":
					goto case "--score";
				case "-s":
					goto case "--score";
				case "/s":
					goto case "--score";
				case "--topdiags": // Number of best diagonals (fast)
					InParams.topdiags = Convert.ToInt32(args[++i]);
					InParams.topdiagsSpecified = true;
					break;
				case "/topdiags":
					goto case "--topdiags";
				case "-d":
					goto case "--topdiags";
				case "/d":
					goto case "--topdiags";
				case "--pairgap": // Gap penalty (fast)
					InParams.pairgap = Convert.ToInt32(args[++i]);
					InParams.pairgapSpecified = true;
					break;
				case "/pairgap":
					goto case "--pairgap";
				case "-p":
					goto case "--pairgap";
				case "/p":
					goto case "--pairgap";
				case "--pwmatrix": // Protein scoring matrix (slow)
					InParams.pwmatrix = args[++i];
					break;
				case "/pwmatrix":
					goto case "--pwmatrix";
				case "--pwdnamatrix": // DNA scoring matrix (slow)
					InParams.pwdnamatrix = args[++i];
					break;
				case "/pwdnamatrix":
					goto case "--pwdnamatrix";
				case "--pwgapopen": // Gap open penalty (slow)
					InParams.pwgapopen = Convert.ToInt32(args[++i]);
					InParams.pwgapopenSpecified = true;
					break;
				case "/pwgapopen":
					goto case "--pwgapopen";
				case "--pwgapext": // Gap extension penalty (slow)
					InParams.pwgapext = Convert.ToSingle(args[++i]);
					InParams.pwgapextSpecified = true;
					break;
				case "/pwgapext":
					goto case "--pwgapext";
				case "--matrix": // Protein scoring matrix (MSA)
					InParams.matrix = args[++i];
					break;
				case "/matrix":
					goto case "--matrix";
				case "-m":
					goto case "--matrix";
				case "/m":
					goto case "--matrix";
				case "--dnamatrix": // DNA scoring matrix (MSA)
					InParams.dnamatrix = args[++i];
					break;
				case "/dnamatrix":
					goto case "--dnamatrix";
				case "--gapopen": // Gap open penalty (MSA)
					InParams.gapopen = Convert.ToInt32(args[++i]);
					InParams.gapopenSpecified = true;
					break;
				case "/gapopen":
					goto case "--gapopen";
				case "-g":
					goto case "--gapopen";
				case "/g":
					goto case "--gapopen";
				case "--noendgaps": // No end gap separation penalty (MSA)
					InParams.noendgaps = true;
					InParams.noendgapsSpecified = true;
					break;
				case "/noendgaps":
					goto case "--noendgaps";
				case "--gapext": // Gap extension penalty (MSA)
					InParams.gapext = Convert.ToSingle(args[++i]);
					InParams.gapextSpecified = true;
					break;
				case "/gapext":
					goto case "--gapext";
				case "-x":
					goto case "--gapext";
				case "/x":
					goto case "--gapext";
				case "--gapdist": // Gap seperation penalty (MSA)
					InParams.gapdist = Convert.ToInt32(args[++i]);
					InParams.gapdistSpecified = true;
					break;
				case "/gapdist":
					goto case "--gapdist";
				case "-y":
					goto case "--gapdist";
				case "/y":
					goto case "--gapdist";
				case "--iteration": // Iteration strategy
					InParams.iteration = args[++i];
					break;
				case "/iteration":
					goto case "--iteration";
				case "-i":
					goto case "--iteration";
				case "/i":
					goto case "--iteration";
				case "--numiter": // Max. number of iterations
					InParams.numiter = Convert.ToInt32(args[++i]);
					InParams.numiterSpecified = true;
					break;
				case "/numiter":
					goto case "--numiter";
				case "-N":
					goto case "--numiter";
				case "/N":
					goto case "--numiter";

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