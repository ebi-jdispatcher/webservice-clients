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
 * jDispatcher SOAP command-line client for MView (SOAP).
 * ====================================================================== */
using System;
using System.IO;
using EbiWS.MViewWs;

namespace EbiWS
{
	class MViewCliClient : EbiWS.MViewClient
	{
		/// <summary>Tool specific usage</summary>
		private string usageMsg = @"MView
=====

Colourise and reformat a multiple sequence alignment or generate a multiple 
sequence alignment from a sequence similairity search (SSS) result.

[Required]

  alnFile            : file : aligned sequences or SSS report (""-""  
                              for STDIN)

[Optional]

      --stype        : str  : sequence type, see --paramDetail stype
      --informat     : str  : input alignment format, see 
                              --paramDetail informat
      --outputformat : str  : output alignment format, see 
                              --paramDetail outputformat
      --htmlmarkup   : str  : type of HTML markup to use in output, see 
                              --paramDetail htmlmarkup
      --css          :      : enable Cascading Style Sheets (CSS) for HTML 
                              styles
      --nocss        :      : disable Cascading Style Sheets (CSS) for HTML 
                              styles
      --pcid         : str  : method for percent identity, see --paramDetail 
                              pcid
      --alignment    :      : show alignment
      --noalignment  :      : hide alignment
      --ruler        :      : show ruler
      --noruler      :      : hide ruler
      --width        : int  : output alignment width
      --coloring     : str  : style of coloring, see --paramDetail coloring
      --colormap     : str  : colour map, see --paramDetail colormap
      --groupmap     : str  : group colour map, see --paramDetail groupmap
      --consensus    :      : show consensus
      --noconsensus  :      : hide consensus
      --concoloring  : str  : style of colouring for consensus, see 
                              --paramDetail concoloring
      --concolormap  : str  : colour map for consensus, see --paramDetail 
                              concolormap
      --congroupmap  : str  : group map for consensus, see --paramDetail 
                              congroupmap
      --congaps      :      : include gaps in consensus
      --nocongaps    :      : exclude gaps in consensus

";

		/// <summary>Execution entry point</summary>
		/// <param name="args">Command-line parameters</param>
		/// <returns>Exit status</returns>
		public static int Main(string[] args)
		{
			int retVal = 0; // Return value
			// Create an instance of the wrapper object
			MViewCliClient wsApp = new MViewCliClient();
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
				case "--stype": // Input sequence type.
					InParams.stype = args[++i];
					break;
				case "/stype":
					goto case "--stype";
				case "--informat": // Input data format.
					InParams.informat = args[++i];
					break;
				case "/informat":
					goto case "--informat";
				case "--outputformat": // Output format.
					InParams.outputformat = args[++i];
					break;
				case "/outputformat":
					goto case "--outputformat";
				case "--htmlmarkup": // HTML markup.
					InParams.htmlmarkup = args[++i];
					break;
				case "/htmlmarkup":
					goto case "--htmlmarkup";
				case "--css": // Use CSS.
					InParams.css = true;
					InParams.cssSpecified = true;
					break;
				case "/css":
					goto case "--css";
				case "--nocss": // Don't use CSS.
					InParams.css = false;
					InParams.cssSpecified = true;
					break;
				case "/nocss":
					goto case "--nocss";
				case "--pcid": // Percent identity method.
					InParams.pcid = args[++i];
					break;
				case "--alignment": // Show alignment.
					InParams.alignment = true;
					InParams.alignmentSpecified = true;
					break;
				case "/alignment":
					goto case "--alignment";
				case "--noalignment": // Don't show alignment.
					InParams.alignment = false;
					InParams.alignmentSpecified = true;
					break;
				case "/noalignment":
					goto case "--noalignment";
				case "--ruler": // Show ruler.
					InParams.ruler = true;
					InParams.rulerSpecified = true;
					break;
				case "/ruler":
					goto case "--ruler";
				case "--noruler": // Don't show ruler.
					InParams.ruler = false;
					InParams.rulerSpecified = true;
					break;
				case "/noruler":
					goto case "--noruler";
				case "--width": // Output width.
					InParams.width = Convert.ToInt32(args[++i]);
					InParams.widthSpecified = true;
					break;
				case "/width":
					goto case "--width";
				case "--coloring": // Style of colouring.
					InParams.coloring = args[++i];
					break;
				case "/coloring":
					goto case "--coloring";
				case "--colormap": // Colour map.
					InParams.colormap = args[++i];
					break;
				case "/colormap":
					goto case "--colormap";
				case "--groupmap": // Group colour map.
					InParams.groupmap = args[++i];
					break;
				case "/groupmap":
					goto case "--groupmap";
				case "--consensus": // Show consensus.
					InParams.consensus = true;
					InParams.consensusSpecified = true;
					break;
				case "/consensus":
					goto case "--consensus";
				case "--noconsensus": // Don't show consensus.
					InParams.consensus = false;
					InParams.consensusSpecified = true;
					break;
				case "/noconsensus":
					goto case "--noconsensus";
				case "--concoloring": // Consensus colouring.
					InParams.concoloring = args[++i];
					break;
				case "/concoloring":
					goto case "--concoloring";
				case "--concolormap": // Consensus color map
					InParams.concolormap = args[++i];
					break;
				case "/concolormap":
					goto case "--concolormap";
				case "--congroupmap": // Consensus group color map
					InParams.congroupmap = args[++i];
					break;
				case "/congroupmap":
					goto case "--congroupmap";
				case "--congaps": // Include gaps in consensus.
					InParams.congaps = true;
					InParams.congapsSpecified = true;
					break;
				case "/congaps":
					goto case "--congaps";
				case "--nocongaps": // Don't include gaps in consensus.
					InParams.congaps = false;
					InParams.congapsSpecified = true;
					break;
				case "/nocongaps":
					goto case "--nocongaps";

					// Input data/sequence option
				case "--sequence": // Input sequence
					i++;
					goto default;
				case "/sequence":
					goto case "--sequence";
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