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
 * jDispatcher SOAP command-line client for Pratt (SOAP).
 * ====================================================================== */
using System;
using System.IO;
using EbiWS.PrattWs;

namespace EbiWS
{
	class PrattCliClient : EbiWS.PrattClient
	{
		/// <summary>Tool specific usage</summary>
		private string usageMsg = @"Pratt
=============

Searching for patterns conserved in sets of unaligned protein sequences.

[Required]

      seqFile                  : file : sequences to align (""-"" for STDIN)

[Optional]
                            
      --minPerc                : int  :  Minimum percentage of input sequence to match.
      --patternPosition        : str  :  Pattern position in sequence
      --maxPatternLength       : int  :  Maximum pattern length
      --maxNumPatternSymbols   : int  :  Maximum number Of pattern symbols
      --maxNumWildcard         : int  :  Maximum length of a widecard (x)	
      --maxNumFlexSpaces       : int  :  Maximum length of flexible spaces
      --maxFlexibility         : int  :  Maximum flexibility
      --maxFlexProduct         : int  :  Maximum flex. product
      --patternSymbolFile      :      :  Enable pattern symbol file
      --noPatternSymbolFile    :      :  Disable pattern symbol file
      --numPatternSymbols      : int  :  Number of pattern symbols used
      --patternScoring         : str  :  Pattern scoring
      --patternGraph           : str  :  Pattern graph allows the use of an alignment 
                                          or a query sequence to restrict the pattern search
      --searchGreediness       : int  :  Greediness of the search
      --patternRefinement      :      :  Enable pattern refinement
      --noPatternRefinement    :      :  Disable pattern refinement		
      --genAmbigSymbols        :      :  Enable generalise ambiguous symbols
      --noGenAmbigSymbols      :      :  Disable generalise ambiguous symbols
      --patternFormat          :      :  Enable PROSITE pattern format
      --noPatternFormat        :      :  Disable PROSITE pattern format
      --maxNumPatterns         : int  :  Maximum number of patterns
      --maxNumAlignments       : int  :  Maximum number of alignments between 1 and 100
      --printPatterns          :      :  Enable print patterns in sequences
      --noPrintPatterns        :      :  Disable print patterns in sequences
      --printingRatio          : int  :  Printing ratio
      --printVertically        :      :  Enable print vertically
      --noPrintVertically      :      :  Disable print vertically

";

		/// <summary>Execution entry point</summary>
		/// <param name="args">Command-line parameters</param>
		/// <returns>Exit status</returns>
		public static int Main(string[] args)
		{
			int retVal = 0; // Return value
			// Create an instance of the wrapper object
			PrattCliClient wsApp = new PrattCliClient();
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


					// Tool specific options
					case "--minPerc": // Minimum percentage of input sequence to match
						InParams.minPerc = Convert.ToInt32(args[++i]);
						InParams.minPercSpecified = true;
						break;
					case "/minPerc":
						goto case "--minPerc";
					case "--patternPosition": // Pattern position in sequence
						InParams.patternPosition = args[++i];
						break;
					case "/patternPosition":
						goto case "--patternPosition";
					case "--maxPatternLength": // Maximum pattern length
						InParams.maxPatternLength= Convert.ToInt32(args[++i]);
						InParams.maxPatternLengthSpecified = true;
						break;
					case "/maxPatternLength":
						goto case "--maxPatternLength";
					case "--maxNumPatternSymbols": // Maximum number Of pattern symbols
						InParams.maxNumPatternSymbols = Convert.ToInt32(args[++i]);
						InParams.maxNumPatternSymbolsSpecified = true;
						break;
					case "/maxNumPatternSymbols":
						goto case "--maxNumPatternSymbols";	
					case "--maxNumWildcard": // Maximum length of a widecard (x)
						InParams.maxNumWildcard = Convert.ToInt32(args[++i]);
						InParams.maxNumWildcardSpecified = true;
						break;
					case "/maxNumWildcard":
						goto case "--maxNumWildcard";		
					case "--maxNumFlexSpaces": // Maximum length of flexible spaces
						InParams.maxNumFlexSpaces = Convert.ToInt32(args[++i]);
						InParams.maxNumFlexSpacesSpecified = true;
						break;
					case "/maxNumFlexSpaces":
						goto case "--maxNumFlexSpaces";	
					case "--maxFlexibility": // Maximum flexibility
						InParams.maxFlexibility = Convert.ToInt32(args[++i]);
						InParams.maxFlexibilitySpecified = true;
						break;
					case "/maxFlexibility":
						goto case "--maxFlexibility";	
					case "--maxFlexProduct": // Maximum flex. product
						InParams.maxFlexProduct = Convert.ToInt32(args[++i]);
						InParams.maxFlexProductSpecified = true;
						break;
					case "/maxFlexProduct":
						goto case "--maxFlexProduct";	
					case "--patternSymbolFile": // Enable pattern symbol file
						InParams.patternSymbolFile = true;
						InParams.patternSymbolFileSpecified = true;
						break;
					case "/patternSymbolFile":
						goto case "--patternSymbolFile";					
					case "--noPatternSymbolFile": // Disable pattern symbol file
						InParams.patternSymbolFile = false;
						InParams.patternSymbolFileSpecified = true;
						break;
					case "/noPatternSymbolFile":
						goto case "--noPatternSymbolFile";
					case "--numPatternSymbols": // Number of pattern symbols used
						InParams.numPatternSymbols = Convert.ToInt32(args[++i]);
						InParams.numPatternSymbolsSpecified = true;
						break;
					case "/numPatternSymbols":
						goto case "--numPatternSymbols";	
					case "--patternScoring": // Pattern scoring
						InParams.patternScoring = args[++i];
						break;
					case "/patternScoring":
						goto case "--patternScoring";
					case "--patternGraph": // Pattern graph allows the use of an alignment or a query sequence to restrict the pattern search
						InParams.patternGraph = args[++i];
						break;
					case "/patternGraph":
						goto case "--patternGraph";
					case "--searchGreediness": // Greediness of the search
						InParams.searchGreediness = Convert.ToInt32(args[++i]);
						InParams.searchGreedinessSpecified = true;
						break;
					case "/searchGreediness":
						goto case "--searchGreediness";	
					case "--patternRefinement": // Enable pattern refinement
						InParams.patternRefinement = true;
						InParams.patternRefinementSpecified = true;
						break;
					case "/patternRefinement":
						goto case "--patternRefinement";					
					case "--noPatternRefinement": // Disable pattern refinement
						InParams.patternRefinement = false;
						InParams.patternRefinementSpecified = true;
						break;
					case "/noPatternRefinement":
						goto case "--noPatternRefinement";
					case "--genAmbigSymbols": // Enable generalise ambiguous symbols	
						InParams.genAmbigSymbols = true;
						InParams.genAmbigSymbolsSpecified = true;
						break;
					case "/genAmbigSymbols":
						goto case "--genAmbigSymbols";					
					case "--noGenAmbigSymbols": // Disable generalise ambiguous symbols
						InParams.genAmbigSymbols = false;
						InParams.genAmbigSymbolsSpecified = true;
						break;
					case "/noGenAmbigSymbols":
						goto case "--noGenAmbigSymbols";
					case "--patternFormat": // Enable PROSITE pattern format
						InParams.patternFormat = true;
						InParams.patternFormatSpecified = true;
						break;
					case "/patternFormat":
						goto case "--patternFormat";					
					case "--noPatternFormat": // Disable PROSITE pattern format
						InParams.patternFormat = false;
						InParams.patternFormatSpecified = true;
						break;
					case "/noPatternFormat":
						goto case "--noPatternFormat";
					case "--maxNumPatterns": // Maximum number of patterns
						InParams.maxNumPatterns = Convert.ToInt32(args[++i]);
						InParams.maxNumPatternsSpecified = true;
						break;
					case "/maxNumPatterns":
						goto case "--maxNumPatterns";	
					case "--maxNumAlignments": // Maximum number of alignments between 1 and 100
						InParams.maxNumAlignments = Convert.ToInt32(args[++i]);
						InParams.maxNumAlignmentsSpecified = true;
						break;
					case "/maxNumAlignments":
						goto case "--maxNumAlignments";
					case "--printPatterns": // Enable print Patterns in sequences
						InParams.printPatterns = true;
						InParams.printPatternsSpecified = true;
						break;
					case "/printPatterns":
						goto case "--printPatterns";					
					case "--noPrintPatterns": // Disable print Patterns in sequences
						InParams.printPatterns = false;
						InParams.printPatternsSpecified = true;
						break;
					case "/noPrintPatterns":
						goto case "--noPrintPatterns";
					case "--printingRatio": // Printing ratio
						InParams.printingRatio = Convert.ToInt32(args[++i]);
						InParams.printingRatioSpecified = true;
						break;
					case "/printingRatio":
						goto case "--printingRatio";
					case "--printVertically": // Enable print vertically.
						InParams.printVertically = true;
						InParams.printVerticallySpecified = true;
						break;
					case "/printVertically":
						goto case "--printVertically";					
					case "--noPrintVertically": // Disable print vertically
						InParams.printVertically = false;
						InParams.printVerticallySpecified = true;
						break;
					case "/noPrintVertically":
						goto case "--noPrintVertically";

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