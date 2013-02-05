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
 * jDispatcher SOAP command-line client for CENSOR
 * ====================================================================== */
using System;
using System.IO;
using EbiWS.CensorWs;

namespace EbiWS
{
	class CensorCliClient : EbiWS.CensorClient
	{
		/// <summary>Tool specific usage</summary>
		private string usageMsg = @"CENSOR
======

CENSOR is a software tool which screens query sequences against a reference 
collection of repeats and ""censors"" (masks) homologous portions with 
masking symbols, as well as generating a report classifying all found repeats.

For more information see:
- http://www.ebi.ac.uk/Tools/so/censor
- http://www.ebi.ac.uk/Tools/webservices/services/so/censor_soap

[Required]

  -l, --database     : str  : database to search, see --paramDetail database
  seqFile            : file : input sequence (""-"" for STDIN, @filename for 
                              identifier list file)

[Optional]

  -b, --mode         : str  : search sensitivity mode, see --paramDetail mode
  -t, --translate    :      : translate input sequence
      --notranslate  :      : do not translate input sequence
  -m, --maskpseudo   :      : mask pseuso genes
      --nomaskpseudo :      : do not mask pseuso genes
  -d, --identity     :      : identical matches only
      --noidentity   :      : identical and similar matches
  -s, --showsimple   :      : show simple repeats
      --noshowsimple :      : do not show simple repeats
      --multifasta   :      : treat input as a set of fasta formatted sequences
";

		/// <summary>Execution entry point</summary>
		/// <param name="args">Command-line parameters</param>
		/// <returns>Exit status</returns>
		public static int Main(string[] args)
		{
			int retVal = 0; // Return value
			// Create an instance of the wrapper object
			CensorCliClient wsApp = new CensorCliClient();
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
					case "version": // Version information.
						wsApp.PrintVersionMessage();
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

		/// <summary>
		/// Print the version message.
		/// </summary>
		private void PrintVersionMessage()
		{
			PrintDebugMessage("PrintVersionMessage", "Begin", 1);
			PrintClientVersion(this.GetType().Assembly);
			PrintClientLicense();
			PrintDebugMessage("PrintVersionMessage", "End", 1);
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
					case "--version": // Version info
						Action = "version";
						break;
					case "/version":
						goto case "--version";
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
					case "--database": // Database to search
						InParams.database = args[++i];
						Action = "submit";
						break;
					case "/database":
						goto case "--database";
					case "--mode": // Search mode
						InParams.mode = args[++i];
						Action = "submit";
						break;
					case "/mode":
						goto case "--mode";
					case "-b":
						goto case "--mode";
					case "/b":
						goto case "--mode";
					case "--translate": // Translate input
						InParams.translate = true;
						InParams.translateSpecified = true;
						break;
					case "/translate":
						goto case "--translate";
					case "-t":
						goto case "--translate";
					case "/t":
						goto case "--translate";
					case "--notranslate": // Do not translate input.
						InParams.translate = false;
						InParams.translateSpecified = true;
						break;
					case "/notranslate":
						goto case "--notranslate";
					case "--maskpseudo": // Mask pseudogenes
						InParams.maskpseudo = true;
						InParams.maskpseudoSpecified = true;
						break;
					case "/maskpseudo":
						goto case "--maskpseudo";
					case "-m":
						goto case "--maskpseudo";
					case "/m":
						goto case "--maskpseudo";
					case "--nomaskpseudo":
						InParams.maskpseudo = false;
						InParams.maskpseudoSpecified = true;
						break;
					case "/nomaskpseudo":
						goto case "--nomaskpseudo";
					case "--identity": // Identical matches only
						InParams.identity = true;
						InParams.identitySpecified = true;
						break;
					case "/identity":
						goto case "--identity";
					case "-d":
						goto case "--identity";
					case "/d":
						goto case "--identity";
					case "--noidentity": // Not identical only.
						InParams.identity = false;
						InParams.identitySpecified = true;
						break;
					case "/noidentity":
						goto case "--noidentity";
					case "--showsimple": // Show simple repeats
						InParams.showsimple = true;
						InParams.showsimpleSpecified = true;
						break;
					case "/showsimple":
						goto case "--showsimple";
					case "-s":
						goto case "--showsimple";
					case "/s":
						goto case "--showsimple";
					case "--noshowsimple": // Do not show simple repeats.
						InParams.showsimple = false;
						InParams.showsimpleSpecified = true;
						break;
					case "/noshowsimple":
						goto case "--noshowsimple";

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