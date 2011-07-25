/* $Id$
 * ======================================================================
 * jDispatcher SOAP command-line client for ClustalO (SOAP).
 * ====================================================================== */
using System;
using System.IO;
using EbiWS.ClustalOWs;

namespace EbiWS
{
	class ClustalOCliClient : EbiWS.ClustalOClient
	{
		/// <summary>Tool specific usage</summary>
		private string usageMsg = @"Clustal Omega
=============

Multiple sequence alignment using Clustal Omega.

[Required]

  seqFile            : file : sequences to align (""-"" for STDIN)

[Optional]

  --guidetreeout     :      : enable output of guide tree.
  --noguidetreeout   :      : disable output of guide tree.
  --dismatout        :      : enable output of distance matrix.
  --nodismatout      :      : disable output of distance matrix.
  --dealign          :      : enable de-alignment of input sequences.
  --nodealign        :      : disable de-alignment of input sequences.
  --mbed             :      : enable mbed-like clustering guide-tree.
  --nombed           :      : disable mbed-like clustering guide-tree.
  --mbediteration    :      : enable mbed-like clustering iteration.
  --nombediteration  :      : disable mbed-like clustering iteration.
  --iterations       : int  : number of iterations, see 
                              --paramDetail iterations.
  --gtiterations     : int  : maximum guild tree iterations, see 
                              --paramDetail gtiterations.
  --hmmiterations    : int  : maximum HMM iterations, see 
                              --paramDetail hmmiterations.
  --outfmt           : str  : output alignment format, see 
                              --paramDetail outfmt.
";

		/// <summary>Execution entry point</summary>
		/// <param name="args">Command-line parameters</param>
		/// <returns>Exit status</returns>
		public static int Main(string[] args)
		{
			int retVal = 0; // Return value
			// Create an instance of the wrapper object
			ClustalOCliClient wsApp = new ClustalOCliClient();
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
				case "--guidetreeout": // Enable output of guide tree.
					InParams.guidetreeout = true;
					InParams.guidetreeoutSpecified = true;
					break;
				case "/guidetreeout":
					goto case "--guidetreeout";
				case "--noguidetreeout": // Disable output of guide tree.
					InParams.guidetreeout = false;
					InParams.guidetreeoutSpecified = true;
					break;
				case "/noguidetreeout":
					goto case "--noguidetreeout";
				case "--dismatout": // Enable output of distance matrix.
					InParams.dismatout = true;
					InParams.dismatoutSpecified = true;
					break;
				case "/dismatout":
					goto case "--dismatout";
				case "--nodismatout": // Disable output of distance matrix.
					InParams.dismatout = false;
					InParams.dismatoutSpecified = true;
					break;
				case "/nodismatout":
					goto case "--nodismatout";
				case "--dealign": // Enable de-alignment of input sequences.
					InParams.dealign = true;
					InParams.dealignSpecified = true;
					break;
				case "/dealign":
					goto case "--dealign";
				case "--nodealign": // Disable de-alignment of input sequences.
					InParams.dealign = false;
					InParams.dealignSpecified = true;
					break;
				case "/nodealign":
					goto case "--nodealign";
				case "--mbed": // Enable mBed-like clustering guide-tree.
					InParams.mbed = true;
					InParams.mbedSpecified = true;
					break;
				case "/mbed":
					goto case "--mbed";
				case "--nombed": // Disable mBed-like clustering guide-tree.
					InParams.mbed = false;
					InParams.mbedSpecified = true;
					break;
				case "/nombed":
					goto case "--nombed";
				case "--mbediteration": // Enable mbed-like clustering iteration.
					InParams.mbediteration = true;
					InParams.mbediterationSpecified = true;
					break;
				case "/mbediteration":
					goto case "--mbediteration";
				case "--nombediteration": // Disable mbed-like clustering iteration.
					InParams.mbediteration = false;
					InParams.mbediterationSpecified = true;
					break;
				case "/nombediteration":
					goto case "--nombediteration";
				case "--iterations": // Number of iterations.
					InParams.iterations = Convert.ToInt32(args[++i]);
					InParams.iterationsSpecified = true;
					break;
				case "/iterations":
					goto case "--iterations";
				case "--gtiterations": // Maximum guild tree iterations.
					InParams.gtiterations = Convert.ToInt32(args[++i]);
					InParams.gtiterationsSpecified = true;
					break;
				case "/gtiterations":
					goto case "--gtiterations";
				case "--hmmiterations": // Maximum HMM iterations.
					InParams.hmmiterations = Convert.ToInt32(args[++i]);
					InParams.hmmiterationsSpecified = true;
					break;
				case "/hmmiterations":
					goto case "--hmmiterations";
				case "--outfmt": // Output alignment format.
					InParams.outfmt = args[++i];
					break;
				case "/outfmt":
					goto case "--outfmt";

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