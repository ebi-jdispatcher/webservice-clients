/* $Id$
 * ======================================================================
 * SOAP command-line client for EB-eye
 * ====================================================================== */
using System;
using System.IO;
using EbiWS.EBeyeWs;

namespace EbiWS
{
	class EBeyeCliClient : EbiWS.EBeyeClient
	{
		/// <summary>Tool specific usage</summary>
		private string usageMsg = @"EB-eye
======

--listDomains
  Returns a list of all the domains identifiers which can be used in a query.

--getNumberOfResults <domain> <query>
  Executes a query and returns the number of results found.

--getResultsIds <domain> <query> <start> <size>
  Executes a query and returns the list of identifiers for the entries found.

--getAllResultsIds <domain> <query>
  Executes a query and returns the list of all the identifiers for the entries
  found. 

--listFields <domain>
  Returns the list of fields that can be retrieved for a particular domain.

--getResults <domain> <query> <fields> <start> <size>
  Executes a query and returns a list of results. Each result contains the 
  values for each field specified in the ""fields"" argument in the same order 
  as they appear in the ""fields"" list.
 
--getEntry <domain> <entry> <fields>
  Search for a particular entry in a domain and returns the values for some 
  of the fields of this entry. The result contains the values for each field 
  specified in the ""fields"" argument in the same order as they appear in the 
  ""fields"" list.
 
--getEntries <domain> <entries> <fields>
  Search for entries in a domain and returns the values for some of the 
  fields of these entries. The result contains the values for each field 
  specified in the ""fields"" argument in the same order as they appear in the 
  ""fields"" list. 

--getEntryFieldUrls <domain> <entry> <fields>
  Search for a particular entry in a domain and returns the urls configured 
  for some of the fields of this entry. The result contains the urls for each 
  field specified in the ""fields"" argument in the same order as they appear 
  in the ""fields"" list. 

--getEntriesFieldUrls <domain> <entries> <fields>
  Search for a list of entries in a domain and returns the urls configured for
  some of the fields of these entries. Each result contains the url for each 
  field specified in the ""fields"" argument in the same order as they appear in
  the ""fields"" list. 

--getDomainsReferencedInDomain <domain>
  Returns the list of domains with entries referenced in a particular domain. 
  These domains are indexed in the EB-eye. 

--getDomainsReferencedInEntry <domain> <entry>
  Returns the list of domains with entries referenced in a particular domain 
  entry. These domains are indexed in the EB-eye. 

--listAdditionalReferenceFields <domain>
  Returns the list of fields corresponding to databases referenced in the 
  domain but not included as a domain in the EB-eye. 
  
--getReferencedEntries <domain> <entry> <referencedDomain>
  Returns the list of referenced entry identifiers from a domain referenced 
  in a particular domain entry. 
  
--getReferencedEntriesSet <domain> <entries> <referencedDomain> <fields>
  Returns the list of referenced entries from a domain referenced in a set of
  entries. The result will be returned as a list of objects, each representing
  an entry reference.

--getReferencedEntriesFlatSet <domain> <entries> <referencedDomain> <fields>
  Returns the list of referenced entries from a domain referenced in a set of 
  entries. The result will be returned as a flat table corresponding to the 
  list of results where, for each result, the first value is the original 
  entry identifier and the other values correspond to the fields values. 

--getDomainsHierarchy
  Returns the hierarchy of the domains available.

--getDetailledNumberOfResults <domain> <query> <flat>
  Executes a query and returns the number of results found per domain.

--listFieldsInformation <domain>
  Returns the list of fields that can be retrievedand/or searched for a 
  particular domain. 

Further information:

  http://www.ebi.ac.uk/Tools/webservices/services/eb-eye
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
			EBeyeCliClient wsApp = new EBeyeCliClient();
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
					
					case "--listDomains": // Domains available to search
						this.PrintListDomains();
						break;
					case "--listdomains":
						goto case "--listDomains";

					case "--getNumberOfResults": // get the number of results for a query
						if(args.Length > i + 2) {
							this.PrintGetNumberOfResults(args[++i], args[++i]);
						}
						else {
							Console.Error.WriteLine("Error: insufficent arguments for " + args[i]);
							retVal = 1;
						}
						break;
					case "--getnumberofresults":
						goto case "--getNumberOfResults";


					case "--getResultsIds": // get result Ids for query
						if(args.Length > i + 4) {
							this.PrintGetResultsIds(args[++i], args[++i], args[++i], args[++i]);
						}
						else {
							Console.Error.WriteLine("Error: insufficent arguments for " + args[i]);
							retVal = 1;
						}
						break;
					case "--getresultsids":
						goto case "--getResultsIds";

					case "--getAllResultsIds": // get all result Ids for query
						if(args.Length > i + 2) {
							this.PrintGetAllResultsIds(args[++i], args[++i]);
						}
						else {
							Console.Error.WriteLine("Error: insufficent arguments for " + args[i]);
							retVal = 1;
						}
						break;
					case "--getallresultsids":
						goto case "--getAllResultsIds";

					case "--listFields": // Fields available for domain
						if(args.Length > i + 1) {
							this.PrintListFields(args[++i]);
						}
						else {
							Console.Error.WriteLine("Error: insufficent arguments for " + args[i]);
							retVal = 1;
						}
						break;
					case "--listfields":
						goto case "--listFields";
	      
					case "--getResults": // get results for query starting a result 'start' and in pages of size 'size'
						if(args.Length > i + 5) {
							PrintGetResults(args[++i], args[++i], args[++i], args[++i], args[++i]);
						}
						else {
							Console.Error.WriteLine("Error: insufficent arguments for " + args[i]);
							retVal = 1;
						}
						break;
					case "--getresults":
						goto case "--getResults";

					case "--getEntry": // get an entry (metadata indexed in EB-eye)
						if(args.Length > i + 3) {
							PrintGetEntry(args[++i], args[++i], args[++i]);
						}
						else {
							Console.Error.WriteLine("Error: insufficent arguments for " + args[i]);
							retVal = 1;
						}
						break;
					case "--getentry":
						goto case "--getEntry";

					case "--getEntries": // get multiple entries (metadata indexed in EB-eye)
						if(args.Length > i + 3) {
							PrintGetEntries(args[++i], args[++i], args[++i]);
						}
						else {
							Console.Error.WriteLine("Error: insufficent arguments for " + args[i]);
							retVal = 1;
						}
						break; 
					case "--getentries":
						goto case "--getEntries";

					case "--getEntryFieldUrls": // get URLs for fields for an entry
						if(args.Length > i + 3) {
							PrintGetEntryFieldUrls(args[++i], args[++i], args[++i]);
						}
						else {
							Console.Error.WriteLine("Error: insufficent arguments for " + args[i]);
							retVal = 1;
						}
						break;
					case "--getentryfieldurls":
						goto case "--getEntryFieldUrls";

					case "--getEntriesFieldUrls": // get URLs for fields for a set of entries
						if(args.Length > i + 3) {
							PrintGetEntriesFieldUrls(args[++i], args[++i], args[++i]);
						}
						else {
							Console.Error.WriteLine("Error: insufficent arguments for " + args[i]);
							retVal = 1;
						}
						break; 
					case "--getentriesfieldurls":
						goto case "--getEntriesFieldUrls";

					case "--getDomainsReferencedInDomain": // get domains references from a specific domain
						if(args.Length > i + 1) {
							PrintGetDomainsReferencedInDomain(args[++i]);
						}
						else {
							Console.Error.WriteLine("Error: insufficent arguments for " + args[i]);
							retVal = 1;
						}
						break;
					case "--getdomainsreferencedindomain":
						goto case "--getDomainsReferencedInDomain";

					case "--getDomainsReferencedInEntry": // get all domains referenced by an entry
						if(args.Length > i + 2) {
							PrintGetDomainsReferencedInEntry(args[++i], args[++i]);
						}
						else {
							Console.Error.WriteLine("Error: insufficent arguments for " + args[i]);
							retVal = 1;
						}
						break;
					case "--getdomainsreferencedinentry":
						goto case "--getDomainsReferencedInEntry";

					case "--listAdditionalReferenceFields": // Additional (external) cross-references
						if(args.Length > i + 1) {
							PrintListAdditionalReferenceFields(args[++i]);
						}
						else {
							Console.Error.WriteLine("Error: insufficent arguments for " + args[i]);
							retVal = 1;
						}
						break;
					case "--listadditionalreferencefields":
						goto case "--listAdditionalReferenceFields";

					case "--getReferencedEntries": // get all entries references for a domain
						if(args.Length > i + 3) {
							PrintGetReferencedEntries(args[++i], args[++i], args[++i]);
						}
						else {
							Console.Error.WriteLine("Error: insufficent arguments for " + args[i]);
							retVal = 1;
						}
						break;
					case "--getreferencedentries":
						goto case "--getReferencedEntries";

					case "--getReferencedEntriesSet": // get references for entries (set)
						if(args.Length > i + 4) {
							PrintGetReferencedEntriesSet(args[++i], args[++i], args[++i], args[++i]);
						}
						else {
							Console.Error.WriteLine("Error: insufficent arguments for " + args[i]);
							retVal = 1;
						}
						break;
					case "--getreferencedentriesset":
						goto case "--getReferencedEntriesSet";

					case "--getReferencedEntriesFlatSet":
						if(args.Length > i + 4) {
							PrintGetReferencedEntriesFlatSet(args[++i], args[++i], args[++i], args[++i]);
						}
						else {
							Console.Error.WriteLine("Error: insufficent arguments for " + args[i]);
							retVal = 1;
						}
						break;
					case "--getreferencedentriesflatset":
						goto case "--getReferencedEntriesFlatSet";
	      
					case "--getDomainsHierarchy": // list the EB-eye domain hierarchy
						PrintGetDomainsHierarchy();
						break;
					case "--getdomainshierarchy":
						goto case "--getDomainsHierarchy";

					case "--getDetailledNumberOfResults": // get detailed counts for number of results for a query in domains/subdomains
						if(args.Length > i + 3) {
							PrintGetDetailledNumberOfResults(args[++i], args[++i], args[++i]);
						}
						else {
							Console.Error.WriteLine("Error: insufficent arguments for " + args[i]);
							retVal = 1;
						}
						break;
					case "--getdetaillednumberofresults":
						goto case "--getDetailledNumberOfResults";
					case "--getDetailedNumberOfResults":
						goto case "--getDetailledNumberOfResults";
					case "--getdetailednumberofresults":
						goto case "--getDetailledNumberOfResults";
  
					case "--listFieldsInformation": // Field information
						if(args.Length > i + 1) {
							PrintListFieldsInformation(args[++i]);
						}
						else {
							Console.Error.WriteLine("Error: insufficent arguments for " + args[i]);
							retVal = 1;
						}
						break;
					case "--listfieldsinformation":
						goto case "--listFieldsInformation";

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
