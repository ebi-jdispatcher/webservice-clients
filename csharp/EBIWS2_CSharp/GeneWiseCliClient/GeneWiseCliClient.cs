/* $Id$
 * ======================================================================
 * jDispatcher SOAP command-line client for GeneWise
 * ====================================================================== */
using System;
using System.IO;
using EbiWS.GeneWiseWs;

namespace EbiWS
{
	class GeneWiseCliClient : EbiWS.GeneWiseClient
	{
		/// <summary>Tool specific usage</summary>
		private string usageMsg = @"GeneWise
==========

GeneWise compares a protein sequence to a genomic DNA sequence, allowing for introns 
and frameshifting errors.


For more information see:
- http://www.ebi.ac.uk/Tools/psa/genewise
- http://www.ebi.ac.uk/Tools/webservices/services/psa/genewise_soap
                
[Required]

      --asequence     : file : first sequence to align
      --bsequence     : file : second sequence to align

[Optional]


      --para          :      : show parameters in output alignmment
      --pretty        :      : show pretty ASCII alignment viewing 
      --genes         :      : show gene structure
      --trans         :      : show protein translation, breaking at frameshifts
      --cdna          :      : show cDNA
      --embl          :      : EMBL feature table format with CDS key
      --ace           :      : show Ace file gene structure
      --gff           :      : show Gene Feature Format file
      --diana         :      : show EMBL FT format suitable for diana
      --init          : str  : model in local/global mode, see --paramDetail init
      --splice        : str  : splice site, see --paramDetail splice
      --null          : str  : null (Random) Model, see --paramDetail null
      --alg           : str  : algorithm , see --paramDetail alg
";

		/// <summary>Execution entry point</summary>
		/// <param name="args">Command-line parameters</param>
		/// <returns>Exit status</returns>
		public static int Main(string[] args)
		{
			int retVal = 0; // Return value
			// Create an instance of the wrapper object
			GeneWiseCliClient wsApp = new GeneWiseCliClient();
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
					case "--para": // Show parameters in output alignmment.
	                                        InParams.para = true;
        	                                InParams.paraSpecified = true;
                	                        break;
                        	        case "/para":
                                	        goto case "--para";
					case "--pretty": // Show pretty ASCII alignment viewing.
                                                InParams.pretty = true;
                                                InParams.prettySpecified = true;
                                                break;
                                        case "/pretty":
                                                goto case "--pretty";
                                        case "--genes": // Show gene structure.
                                                InParams.genes = true;
                                                InParams.genesSpecified = true;
                                                break;
                                        case "/genes":
                                                goto case "--genes";
                                        case "--trans": // Show protein translation, breaking at frameshifts.
                                                InParams.trans = true;
                                                InParams.transSpecified = true;
                                                break;
                                        case "/trans":
                                                goto case "--trans";
                                        case "--cdna": // Show cDNA.
                                                InParams.cdna = true;
                                                InParams.cdnaSpecified = true;
                                                break;
                                        case "/cdna":
                                                goto case "--cdna";
                                        case "--embl": // EMBL feature table format with CDS key.
                                                InParams.embl = true;
                                                InParams.emblSpecified = true;
                                                break;
                                        case "/embl":
                                                goto case "--embl";
                                        case "--ace": // Show Ace file gene structure.
                                                InParams.ace = true;
                                                InParams.aceSpecified = true;
                                                break;
                                        case "/ace":
                                                goto case "--ace";
                                        case "--gff": // Show Gene Feature Format file.
                                                InParams.gff = true;
                                                InParams.gffSpecified = true;
                                                break;
                                        case "/gff":
                                                goto case "--gff";
                                        case "--diana": // Show EMBL FT format suitable for diana.
                                                InParams.diana = true;
                                                InParams.dianaSpecified = true;
                                                break;
                                        case "/diana":
                                                goto case "--diana";
					case "--init": // Model in local/global mode
						InParams.init = args[++i];
						break;
					case "/init":
						goto case "--init";
                                        case "--splice": // Splice site 
                                                InParams.splice = args[++i];
                                                break;
                                        case "/splice":
                                                goto case "--splice";
//                                        case "--null": // Null (Random) Mode
//                                                InParams.null = args[++i];
//                                               break;
//                                        case "/null":
//                                                goto case "--null";
                                        case "--alg": // Algorithm
                                                InParams.alg = args[++i];
                                                break;
                                        case "/alg":
                                                goto case "--alg";


					// Input data/sequence options.
					case "--asequence": // First sequence.
						InParams.asequence = LoadData(args[++i]);
						Action = "submit";
						break;
					case "--bsequence": // Second sequence.
						InParams.bsequence = LoadData(args[++i]);
						Action = "submit";
						break;
					// Unknown and unnamed options
					default:
						// Check for unknown option
						if (args[i].StartsWith("--") || args[i].LastIndexOf('/') == 0)
						{
							Console.Error.WriteLine("Error: unknown option: " + args[i] + "\n");
							Action = "exit";
							return;
						}
						break;
				}
			}
			PrintDebugMessage("ParseCommand", "End", 1);
		}
	}
}
