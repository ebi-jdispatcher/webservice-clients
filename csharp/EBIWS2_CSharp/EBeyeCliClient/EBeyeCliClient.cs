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
				wsApp.ParseCommand(args);
				// Perform the selected action.
				switch (wsApp.Action)
				{
					case "listDomains": // List domain names
						wsApp.PrintListDomains();
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
			PrintDebugMessage("PrintUsageMessage", "End", 1);
		}

		/// <summary>Parse command-line options</summary>
		/// <param name="args">Command-line options</param>
		private void ParseCommand(string[] args)
		{
			PrintDebugMessage("ParseCommand", "Begin", 1);
			// Loop over command-line options
			for (int i = 0; i < args.Length; i++)
			{
				PrintDebugMessage("parseCommand", "arg: " + args[i], 2);
				switch (args[i])
				{
						// Generic options
					case "--help": // Usage info
						this.Action = "help";
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
					
						/*
	    case "--listFields": // Fields available for domain
	      result = wsApp.srvProxy.listFields(args[++i]);
	      wsApp.PrintStrList(result);
	      i += 1;
	      break;
	    case "--listfields":
	      goto case "--listFields";
	      
	    case "--listFieldsInformation": // Field information
	      FieldInfo[] fieldList = wsApp.srvProxy.listFieldsInformation(args[++i]);
	      for (int x = 0; x < fieldList.Length; x++) {
		FieldInfo a = fieldList[x];
		Console.WriteLine("ID: " + a.id);
		Console.WriteLine("\tName: " + a.name);
		Console.WriteLine("\tDescription: " + a.description);
		Console.WriteLine("\tRetrievable: " + a.retrievable);
		Console.WriteLine("\tSearchable: " + a.searchable);
	      }
	      i += 1;
	      break;
	    case "--listfieldsinformation":
	      goto case "--listFieldsInformation";

	    case "--listAdditionalReferenceFields": // Additional (external) cross-references
	      string domain1 = args[1];
	      result = wsApp.srvProxy.listAdditionalReferenceFields(domain1);
	      wsApp.PrintStrList(result);
	      i += 1;
	      break;
	    case "--listadditionalreferencefields":
	      goto case "--listAdditionalReferenceFields";

	    case "--getDomainsReferencedInDomain": // get domains references from a specific domain
	      result = wsApp.srvProxy.getDomainsReferencedInDomain(args[++i]);
	      wsApp.PrintStrList(result);
	      i += 1;
	      break;
	    case "--getdomainsreferencedindomain":
	      goto case "--getDomainsReferencedInDomain";

 	    case "--getEntry": // get an entry (metadata indexed in EB-eye)
	      string domain = args[1];
	      string id = args[2];
	      char[] sep0 = {',', '+'};
	      string[] fields = args[3].Split(sep0);
	      result = wsApp.srvProxy.getEntry(domain, id, fields);
	      wsApp.PrintStrList(result);
	      i += 3;
	      break;
	    case "--getentry":
	      goto case "--getEntry";

	    case "--getEntries": // get multiple entries (metadata indexed in EB-eye)
	      domain = args[1];
	      fields = wsApp.srvProxy.listFields(domain);
	      char[] sep1 = { ',', '+' };
	      string[]entries = args[2].Split(sep1);
	      string[][] stuffList1 = null;
	      stuffList1 = wsApp.srvProxy.getEntries(domain,entries,fields);
	      foreach (string[] blah in stuffList1) {
		wsApp.PrintStrList(blah);
	      }
	      i += 3;
	      break; 
	    case "--getentries":
	      goto case "--getEntries";

	    case "--getDomainsReferencesInEntry": // get all domains referenced by an entry
	      domain = args[1];
	      string entry = args[2];
	      result = wsApp.srvProxy.getDomainsReferencedInEntry(domain, entry);
	      wsApp.PrintStrList(result);
	      i += 2;
	      break;
	    case "--getdomainsreferencedinentry":
	      goto case "--getDomainsReferencesInEntry";

	    case "--getEntriesReferencedInDomain": // get entries references in a domain
	      domain = args[1];
	      char[] sep2 = {',', '+'};
	      entries = args[2].Split(sep2);
	      string refDomain = args[3];
	      fields = wsApp.srvProxy.listFields(refDomain);
	      EntryReferences[] stuffList = null;
	      stuffList = wsApp.srvProxy.getReferencedEntriesSet(domain, entries, refDomain, fields);
	      foreach(EntryReferences blah in stuffList) {
		foreach (string[] foo in blah.references) {
		  wsApp.PrintStrList(foo);
		}
	      }
	      i += 3;
	      break;
	    case "--getentriesreferencedindomain":
	      goto case "--getEntriesReferencedInDomain";

	    case "--getEntriesFieldUrls": // get URLs for entry fields
	      domain = args[1];
	      char[] sep3 = {',', '+'};
	      entries = args[2].Split(sep3);
	      string[] fieldsId = {"id"};
	      string[][] stuffList2 = null;
	      stuffList2 = wsApp.srvProxy.getEntriesFieldUrls(domain, entries, fieldsId);
	      foreach (string[] blah in stuffList2) {
		wsApp.PrintStrList(blah);
	      }
	      i += 3;
	      break;
	    case "--getentriesfieldurls":
	      goto case "--getentriesfieldurls";

	    case "--getAllResultsIds": // get all result Ids for query
	      domain = args[1];
	      string query = args[2].Replace('+', ' ');
	      result = wsApp.srvProxy.getAllResultsIds(domain, query);
	      wsApp.PrintStrList(result);
	      i += 2;
	      break;
	    case "--getallresultsids":
	      goto case "--getAllResultsIds";

	    case "--getNumberOfResults": // get the number of results for a query
	      int res = 0;
	      domain = args[1];
	      query = args[2].Replace('+', ' ');
	      res = wsApp.srvProxy.getNumberOfResults(domain, query);
	      Console.WriteLine(res);
	      i += 2;
	      break;
	    case "--getnumberofresults":
	      goto case "--getNumberOfResults";

	    case "--getDetailedNumberOfResults": // get detailed counts for number of results for a query in domains/subdomains
	      domain = args[1];
	      query = args[2];
	      bool isFlat = false;
	      if (args.Length > 3) {
		isFlat = true;
		i++;
	      }
	      DomainResult resultCount = wsApp.srvProxy.getDetailledNumberOfResults(domain, query, isFlat);
	      wsApp.PrintDomainResults(resultCount, "");
	      i += 2;
	      break;
	    case "--getdetailednumberofresults":
	      goto case "--getDetailedNumberOfResults";
  
	    case "--getReferencedEntries": // get all entries references for a domain
	      domain = args[1];
	      query = args[2].Replace('+', ' ');
	      refDomain = args[3];
	      result = wsApp.srvProxy.getReferencedEntries(domain, query, refDomain);
	      wsApp.PrintStrList(result);
	      i += 3;
	      break;
	    case "--getreferencedentries":
	      goto case "--getReferencedEntries";

	    case "--getReferencedEntriesFlatSet":
	      domain = args[1];
	      refDomain = args[3];
	      fields = wsApp.srvProxy.listFields(refDomain);
	      char[] sep8 = {',', '+'};
	      entries = args[2].Split(sep8);
	      string[][] entriesList = null;
	      entriesList = wsApp.srvProxy.getReferencedEntriesFlatSet(domain, entries, refDomain, fields);
	      foreach (string[] blah in entriesList) {
		wsApp.PrintStrList(blah);
	      }
	      i += 3;
	      break;
	    case "--getreferencedentriesflatset":
	      goto case "--getReferencedEntriesFlatSet";
	      
	    case "--getReferencedEntriesSet": // get references for entries (set)
	      domain = args[1];
	      char[] sep4 = {',', '+'};
	      string[] entries1 = args[2].Split(sep4);
	      refDomain = args[3];
	      fields = wsApp.srvProxy.listFields(refDomain);
	      EntryReferences[] entryreferences = wsApp.srvProxy.getReferencedEntriesSet(domain, entries1, refDomain, fields);
	      foreach (EntryReferences reference in entryreferences) {
		wsApp.printArrayOfStringList(reference.references);
	      }
	      i += 3;
	      break;
	    case "--getreferencedentriesset":
	      goto case "--getReferencedEntriesSet";

	    case "--getDomainsHierarchy": // list the EB-eye domain hierarchy
	      DomainDescription domainsDes = wsApp.srvProxy.getDomainsHierarchy();
	      Console.WriteLine("RootDomain:" + domainsDes.name);
	      wsApp.PrintDomains(domainsDes, "");
	      i += 1;
	      break;
	    case "--getdomainshierarchy":
	      goto case "--getDomainsHierarchy";

	    case "--getResults": // get results for query starting a result 'start' and in pages of size 'size'
	      domain = args[1];
	      string query1 = args[2].Replace('+', ' ');
	      char[] sep01 = { ',', '+' };
	      string[] fields1 = args[3].Split(sep01);
	      string startStr = args[4];
	      string sizeStr = args[5];
	      int start = int.Parse(startStr);
	      int size = int.Parse(sizeStr);
	      string[][] entriesResult = null;
	      entriesResult = wsApp.srvProxy.getResults(domain, query1, fields1, start, size);
	      foreach (string[] entryResult in entriesResult) {
		wsApp.PrintStrList(entryResult);
	      }
	      i += 5;
	      break;
	    case "--getresults":
	      goto case "--getResults";

	    case "--getResultsIds": // get result Ids for query starting at result 'start' with page size 'size'
	      domain = args[1];
	      string query2 = args[2].Replace('+', ' ');
	      string startStr1 = args[3];
	      string sizeStr1 = args[4];
	      int start1 = int.Parse(startStr1);
	      int size1 = int.Parse(sizeStr1);
	      string[] entriesResult1 = null;
	      entriesResult1 = wsApp.srvProxy.getResultsIds(domain, query2, start1, size1);
	      foreach (string entres in entriesResult1) {
		Console.WriteLine(entres);
	      }
	      i += 4;
	      break;
	    case "--getresultids":
	      goto case "--getResultsIds";
 	      */
					default: // Don't know what to do, so print error message
						Console.Error.WriteLine("Error: unknown option: " + args[i] + "\n");
						break;
				}
			}
			PrintDebugMessage("ParseCommand", "End", 1);
		}
    }
}
