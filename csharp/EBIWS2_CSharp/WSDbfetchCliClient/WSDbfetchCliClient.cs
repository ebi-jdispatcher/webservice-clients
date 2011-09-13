/* $Id$
 * ======================================================================
 * SOAP command-line client for WSDbfetch.
 * ====================================================================== */
using System;
using System.IO;
using EbiWS.WSDbfetchWs;

namespace EbiWS
{
	class WSDbfetchCliClient : EbiWS.WSDbfetchClient
	{
		/// <summary>Tool specific usage</summary>
		private string usageMsg = @"WSDbfetch
======

WSDbfetchCliClient.exe <method> [arguments...]

A number of methods are available:

getSupportedDBs - list available databases
getSupportedFormats - list available databases with formats
getSupportedStyles - list available databases with styles
getDbFormats - list formats for a specifed database
getFormatStyles - list styles for a specified database and format
fetchData - retrive an database entry. See below for details of arguments.
fetchBatch - retrive database entries. See below for details of arguments.

Fetching an entry: fetchData

WSDbfetchCliClient.exe fetchData <dbName:id> [format [style]]

dbName:id  Database name and entry ID or accession (e.g. UNIPROT:WAP_RAT).
           Use '-' to read from STDIN or '@fileName' to read from a file.
format     Data format to retrive (e.g. fasta).
style      Result style to retrive (e.g. raw).

Fetching entries: fetchBatch

WSDbfetchCliClient.exe fetchBatch <dbName> <idList> [format [style]]

dbName     Database name (e.g. UNIPROT)
idList     List of entry IDs or accessions (e.g. 1433T_RAT,WAP_RAT).
           Maximum of 200 IDs or accessions.
           Use '-' to read from STDIN or '@fileName' to read from a file.
format     Data format to retrive (e.g. fasta).
style      Result style to retrive (e.g. raw).

Further information:

  http://www.ebi.ac.uk/Tools/webservices/services/dbfetch
  http://www.ebi.ac.uk/Tools/webservices/tutorials/csharp

Support/Feedback:

  http://www.ebi.ac.uk/support/
";

		/// <summary>Execution entry point</summary>
		/// <param name="args">Command-line parameters</param>
		/// <returns>Exit status</returns>
		public static int Main(string[] args)
		{
			int retVal = 0; // Return value
			// Create an instance of the wrapper object
			WSDbfetchCliClient wsApp = new WSDbfetchCliClient();
			// If no arguments print usage and return
			if (args.Length < 1)
			{
				wsApp.PrintUsageMessage();
				return retVal;
			}
			try
			{
				// Parse the command line
				retVal = wsApp.ParseCommand(args);
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
			PrintDebugMessage("PrintUsageMessage", "End", 1);
		}

		/// <summary>Parse command-line options</summary>
		/// <param name="args">Command-line options</param>
		private int ParseCommand(string[] args)
		{
			PrintDebugMessage("ParseCommand", "Begin", 1);
			// Return value
			int retVal = 0;
			string formatName = "default";
			string styleName = "default";
			// Loop over command-line options
			for (int i = 0; (retVal == 0 && i < args.Length); i++)
			{
				PrintDebugMessage("parseCommand", "arg: " + args[i], 2);
				switch (args[i])
				{
						// Generic options
					case "--help": // Usage info
						this.PrintUsageMessage();
						break;
					case "-h":
						goto case "--help";
					case "/help":
						goto case "--help";
					case "/h":
						goto case "--help";
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
					
					case "getSupportedDBs": // Databases available to search
						this.PrintGetSupportedDBs();
						break;
					case "getSupportedFormats": // Databases and formats available
						this.PrintGetSupportedFormats();
						break;
					case "getSupportedStyles": // Databases and styles available
						this.PrintGetSupportedStyles();
						break;
					case "getDbFormats": // Formats for a database.
						this.PrintGetDbFormats(args[++i]);
						break;
					case "getFormatStyles": // Styles for a format of a database.
						this.PrintGetFormatStyles(args[++i], args[++i]);
						break;
					case "fetchData": // Fetch an entry.
						string query = args[++i];
						if(args.Length > (i + 1)) formatName = args[++i];
						if(args.Length > (i + 1)) styleName = args[++i];
						this.PrintFetchData(query, formatName, styleName);
						break;
					case "fetchBatch": // Fetch a set of entries.
						string dbName = args[++i];
						string idListStr = args[++i];
						if(args.Length > (i + 1)) formatName = args[++i];
						if(args.Length > (i + 1)) styleName = args[++i];
						this.PrintFetchBatch(dbName, idListStr, formatName, styleName);
						break;

					default: // Don't know what to do, so print error message
						Console.Error.WriteLine("Error: unknown option: " + args[i] + "\n");
						retVal = 1;
						break;
				}
			}
			PrintDebugMessage("ParseCommand", "End", 1);
			return retVal;
		}
    }
}
