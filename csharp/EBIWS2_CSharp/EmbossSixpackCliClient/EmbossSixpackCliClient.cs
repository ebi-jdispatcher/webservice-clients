/* $Id$
 * ======================================================================
 * 
 * Copyright 2011-2013 EMBL - European Bioinformatics Institute
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
 * jDispatcher EMBOSS sixpack (SOAP) command-line client.
 * ====================================================================== */
using System;
using System.IO;
using EbiWS.EmbossSixpackWs;

namespace EbiWS
{
	class EmbossSixpackCliClient : EbiWS.EmbossSixpackClient
	{
		/// <summary>Tool specific usage</summary>
		private string usageMsg = @"EMBOSS sixpack
================

Global pairwise sequence alignment using EMBOSS sixpack.

[Required]

  --sequence       : file : input sequences

[Optional]


  --codontable   : str  : codon table, see --paramDetail codontable
  --firstorf     :      : enable to count the beginning of a sequence as a 
                          possible ORF
  --nofirstorf   :      : disable counting the beginning of a sequence as a 
                          possible ORF
  --lastorf      :      : enable to count the end of a sequence as a possible 
                          ORF
  --nolastorf    :      : disable counting the end of a sequence as a possible 
                          ORF
  --reverse      :      : enable to reverse
  --noreverse    :      : disable reversing
  --orfminsize   : str  : minimum size of Open Reading Frames (ORFs) to display 
                          in the translations
";

		/// <summary>Execution entry point</summary>
		/// <param name="args">Command-line parameters</param>
		/// <returns>Exit status</returns>
		public static int Main(string[] args)
		{
			int retVal = 0; // Return value
			// Create an instance of the wrapper object
			EmbossSixpackCliClient wsApp = new EmbossSixpackCliClient();
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
					case "--multifasta": // Multiple sequence input (fasta format)
						this.multifasta = true;
						break;
					case "/multifasta":
						goto case "--multifasta";
  
						// Tool specific options
				case "--codontable": // Codon table
					InParams.codontable = args[++i];
					break;
				case "/codontable":
					goto case "--codontable";
				case "--orfminsize": // min orf size
					InParams.orfminsize = args[++i];
					break;
				case "/orfminsize":
					goto case "--orfminsize";
				case "--firstorf": // first orf
					InParams.firstorf = true;
					InParams.firstorfSpecified = true;
					break;
				case "/firstorf":
					goto case "--firstorf";
				case "--nofirstorf": // no first orf
					InParams.firstorf = false;
					InParams.firstorfSpecified = true;
					break;
				case "/nofirstorf":
					goto case "--nofirstorf";
				case "--lastorf": // last orf
					InParams.lastorf = true;
					InParams.lastorfSpecified = true;
					break;
				case "/lastorf":
					goto case "--lastorf";
				case "--nolastorf": // no last orf
					InParams.lastorf = false;
					InParams.lastorfSpecified = true;
					break;
				case "/nolastorf":
					goto case "--nolastorf";
				case "--reverse": // Enable to reverse
					InParams.reverse = true;
					InParams.reverseSpecified = true;
					break;
				case "/reverse":
					goto case "--reverse";
				case "--noreverse": // Disable reversing
					InParams.reverse = false;
					InParams.reverseSpecified = true;
					break;
				case "/noreverse":
					goto case "--noreverse";
				
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