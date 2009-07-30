/* $Id$
 * ======================================================================
 * EB-eye web services C# client.
 *
 * See:
 * http://www.ebi.ac.uk/Tools/webservices/services/eb-eye
 * http://www.ebi.ac.uk/Tools/webservices/tutorials/csharp
 * ====================================================================== */
using System;
using System.IO;
using System.Reflection;
using System.Text;
using EbiWS.EBeyeWs;

namespace EbiWS {
	/// <summary>EB-eye web services C# client.</summary>
	public class EBeyeClient {
		/// <value>
		/// Level of output produced. Used to implment --quiet and --verbose.
		/// </value>
		public int OutputLevel {
			get{return outputLevel;}
			set{
				if(value > -1) outputLevel = value;
			}
		}
		private int outputLevel = 1;
		/// <value>
		/// Level of debug output (default off).
		/// </value>
		public int DebugLevel {
			get{return debugLevel;}
			set{
				if(value > -1) debugLevel = value;
			}
		}
		private int debugLevel = 0;
		/// <value>
		/// Specified endpoint for the SOAP service. If null the default 
		/// endpoint specified in the WSDL (and thus in the generated 
		/// stubs) is used.
		/// </value>
		public string ServiceEndPoint {
			get{return serviceEndPoint;}
			set{serviceEndPoint = value;}
		}
		private string serviceEndPoint = null;
		/// <summary>Webservice proxy object</summary>
		public EBISearchService SrvProxy
		{
			get { return srvProxy; }
			set { srvProxy = value; }
		}
		private EBISearchService srvProxy = null;
		
		/// <summary>
		/// Default constructor.
		/// </summary>
		public EBeyeClient()
		{
			OutputLevel = 1; // Normal output
			DebugLevel = 0; // Debug output off.
		}
		
		/// <summary>
		/// Print a debug message at the specified level.
		/// </summary>
		/// <param name="methodName">Method name to use in output.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="message">Message to output.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="level">Debug level at which to output.
		/// A <see cref="System.Int32"/>
		/// </param>
		protected void PrintDebugMessage(string methodName, string message, int level) {
			if(level <= DebugLevel) Console.Error.WriteLine("[{0}()] {1}", methodName, message);
		}

		/// <summary>
		/// Construct a string of the values of an object, both fields and properties.
		/// </summary>
		/// <param name="obj">
		/// Object to get values from. A <see cref="System.Object"/>
		/// </param>
		/// <returns>
		/// Name and the contents of values as a string. A <see cref="System.String"/>
		/// </returns>
		protected string ObjectValueToString(Object obj)
		{
			PrintDebugMessage("ObjectValueToString", "Begin", 31);
			StringBuilder strBuilder = new StringBuilder();
			strBuilder.Append(ObjectFieldsToString(obj));
			strBuilder.Append(ObjectPropertiesToString(obj));
			PrintDebugMessage("ObjectValueToString", "End", 31);
			return strBuilder.ToString();
		}

		/// <summary>
		/// Construct a string of the fields of an object.
		/// </summary>
		/// <param name="obj">
		/// Object to get fields from. A <see cref="System.Object"/>
		/// </param>
		/// <returns>
		/// Name and the contents of fields as a string. A <see cref="System.String"/>
		/// </returns>
		protected string ObjectFieldsToString(Object obj) {
			PrintDebugMessage("ObjectFieldsToString", "Begin", 32);
			StringBuilder strBuilder = new StringBuilder();
			Type objType = obj.GetType();
			PrintDebugMessage("ObjectFieldsToString", "objType: " + objType, 33);
			foreach(System.Reflection.FieldInfo info in objType.GetFields()) {
				PrintDebugMessage("ObjectFieldsToString", "info: " + info.Name, 33);
				if (info.FieldType.IsArray)
				{
					strBuilder.Append(info.Name + ":\n");
					foreach(Object subObj in (Object[])info.GetValue(obj)) {
						strBuilder.Append("\t" + subObj);
					}
				}
				else {
					strBuilder.Append(info.Name + ": " + info.GetValue(obj) + "\n");
				}
			}
			PrintDebugMessage("ObjectFieldsToString", "End", 32);
			return strBuilder.ToString();
		}
		
		/// <summary>
		/// Construct a string of the properties of an object.
		/// </summary>
		/// <param name="obj">
		/// Object to get properties from. A <see cref="System.Object"/>
		/// </param>
		/// <returns>
		/// Name and the contents of properties as a string. A <see cref="System.String"/>
		/// </returns>
		protected string ObjectPropertiesToString(Object obj)
		{
			PrintDebugMessage("ObjectPropertiesToString", "Begin", 31);
			StringBuilder strBuilder = new StringBuilder();
			Type objType = obj.GetType();
			PrintDebugMessage("ObjectPropertiesToString", "objType: " + objType, 32);
			foreach (PropertyInfo info in objType.GetProperties())
			{
				PrintDebugMessage("ObjectPropertiesToString", "info: " + info.Name, 32);
				if (info.PropertyType.IsArray)
				{
					strBuilder.Append(info.Name + ":\n");
					foreach (Object subObj in (Object[])info.GetValue(obj, null))
					{
						strBuilder.Append("\t" + subObj);
					}
				}
				else
				{
					strBuilder.Append(info.Name + ": " + info.GetValue(obj, null) + "\n");
				}
			}
			PrintDebugMessage("ObjectPropertiesToString", "End", 31);
			return strBuilder.ToString();
		}
		
		/// <summary>
		/// Print a progress message, at the specified output level.
		/// </summary>
		/// <param name="msg">Message to print.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="level">Output level at which to print the message.
		/// A <see cref="System.Int32"/>
		/// </param>
		protected void PrintProgressMessage(String msg, int level) {
			if(OutputLevel >= level) Console.Error.WriteLine(msg);
		}

		/// <summary>
		/// Get the service connection. Has to be called before attempting to use any of the service operations.
		/// </summary>
		protected void ServiceProxyConnect()
		{
			PrintDebugMessage("ServiceProxyConnect", "Begin", 11);
			if (SrvProxy == null) {
				if(ServiceEndPoint == null) {
					SrvProxy = new EBISearchService();
				}
				else {
					SrvProxy = new EBISearchService();
					SrvProxy.Url = ServiceEndPoint;
				}
				PrintDebugMessage("ServiceProxyConnect", "Service endpoint: " + SrvProxy.Url, 12);
			}
			PrintDebugMessage("ServiceProxyConnect", "SrvProxy: " + SrvProxy, 12);
			PrintDebugMessage("ServiceProxyConnect", "End", 11);
		}

		
		/// <summary>
		/// Get list of search domain names from sevice.
		/// </summary>
		/// <returns>An array of domain names.
		/// A <see cref="System.String"/>
		/// </returns>
		public string[] ListDomains()
		{
			PrintDebugMessage("ListDomains", "Begin", 1);
			ServiceProxyConnect();
			string[] domainNameList = SrvProxy.listDomains();
			PrintDebugMessage("ListDomains", "got " + domainNameList.Length + " domain names", 2);
			PrintDebugMessage("ListDomains", "End", 1);
			return domainNameList;
		}
		
		/// <summary>
		/// Print list of available search domains.
		/// </summary>
		public void PrintListDomains() {
			PrintDebugMessage("PrintListDomains", "Begin", 1);
			string[] result = ListDomains();
			PrintStrList(result);
			PrintDebugMessage("PrintListDomains", "End", 1);
		}
		
		public int GetNumberOfResults(string domain, string query) {
			PrintDebugMessage("GetNumberOfResults", "Begin", 1);
			ServiceProxyConnect();
			int retVal = SrvProxy.getNumberOfResults(domain, query);
			PrintDebugMessage("GetNumberOfResults", "retVal: " + retVal, 1);
			PrintDebugMessage("GetNumberOfResults", "End", 1);
			return retVal;
		}
		
		public void PrintGetNumberOfResults(string domain, string query) {
			PrintDebugMessage("PrintGetNumberOfResults", "Begin", 1);
			int numResults = GetNumberOfResults(domain, query);
			Console.WriteLine(numResults);
			PrintDebugMessage("PrintGetNumberOfResults", "End", 1);
		}
		
		public string[] GetResultsIds(string domain, string query, int start, int size) {
			PrintDebugMessage("GetResultsIds", "Begin", 1);
			ServiceProxyConnect();
			string[] result = SrvProxy.getResultsIds(domain, query, start, size);
			PrintDebugMessage("GetResultsIds", "End", 1);
			return result;
		}
		
		public void PrintGetResultsIds(string domain, string query, int start, int size) {
			PrintDebugMessage("PrintGetResultsIds", "Begin", 1);
			string[] result = GetResultsIds(domain, query, start, size);
			PrintStrList(result);
			PrintDebugMessage("PrintGetResultsIds", "End", 1);
		}
		
		public void PrintGetResultsIds(string domain, string query, string start, string size) {
			PrintDebugMessage("PrintGetResultsIds", "Begin", 1);
			PrintGetResultsIds(domain, query, Convert.ToInt32(start), Convert.ToInt32(size));
			PrintDebugMessage("PrintGetResultsIds", "End", 1);
		}
		
		public string[] GetAllResultsIds(string domain, string query) {
			PrintDebugMessage("GetAllResultsIds", "Begin", 1);
			ServiceProxyConnect();
			string[] result = SrvProxy.getAllResultsIds(domain, query);
			PrintDebugMessage("GetAllResultsIds", "End", 1);
			return result;
		}
		
		public void PrintGetAllResultsIds(string domain, string query) {
			PrintDebugMessage("PrintGetAllResultsIds", "Begin", 1);
			string[] result = GetAllResultsIds(domain, query);
			PrintStrList(result);
			PrintDebugMessage("PrintGetAllResultsIds", "End", 1);
		}
		
		public string[] ListFields(string domain) {
			PrintDebugMessage("ListFields", "Begin", 1);
			ServiceProxyConnect();
			string[] result = SrvProxy.listFields(domain);
			PrintDebugMessage("ListFields", "End", 1);
			return result;
		}

		public void PrintListFields(string domain) {
			PrintDebugMessage("PrintListFields", "Begin", 1);
			string[] results = ListFields(domain);
			PrintStrList(results);
			PrintDebugMessage("PrintListFields", "End", 1);
		}
		
		public string[][] GetResults(string domain, string query, string[] fields, int start, int size) {
			PrintDebugMessage("GetResults", "Begin", 1);
			ServiceProxyConnect();
			string[][] results = SrvProxy.getResults(domain, query, fields, start, size);
			PrintDebugMessage("GetResults", "End", 1);
			return results;
		}
		
		public void PrintGetResults(string domain, string query, string[] fields, int start, int size) {
			PrintDebugMessage("PrintGetResults", "Begin", 1);
			string[][] results = GetResults(domain, query, fields, start, size);
			PrintArrayOfStringList(results, false);
			PrintDebugMessage("PrintGetResults", "End", 1);
		}
		
		public void PrintGetResults(string domain, string query, string fields, string start, string size) {
			PrintDebugMessage("PrintGetResults", "Begin", 1);
			string[] fieldNames = SplitString(fields);
			PrintGetResults(domain, query, fieldNames, Convert.ToInt32(start), Convert.ToInt32(size));
			PrintDebugMessage("PrintGetResults", "Begin", 1);
		}
		
		public string[] GetEntry(string domain, string entry, string[] fields) {
			PrintDebugMessage("GetEntry", "Begin", 1);
			ServiceProxyConnect();
			string[] result = SrvProxy.getEntry(domain, entry, fields);
			PrintDebugMessage("GetEntry", "End", 1);
			return result;
		}
		
		public void PrintGetEntry(string domain, string entry, string[] fields) {
			PrintDebugMessage("PrintGetEntry", "Begin", 1);
			string[] result = GetEntry(domain, entry, fields);
			PrintStrList(result);
			PrintDebugMessage("PrintGetEntry", "End", 1);
		}
		
		public void PrintGetEntry(string domain, string entry, string fields) {
			PrintDebugMessage("PrintGetEntry", "Begin", 1);
			string[] fieldNames = SplitString(fields);
			PrintGetEntry(domain, entry, fieldNames);
			PrintDebugMessage("PrintGetEntry", "End", 1);
		}
		
		public string[][] GetEntries(string domain, string[] entries, string[] fields) {
			PrintDebugMessage("GetEntries", "Begin", 1);
			ServiceProxyConnect();
			string[][] result = SrvProxy.getEntries(domain, entries, fields);
			PrintDebugMessage("GetEntries", "End", 1);
			return result;
		}
		
		public void PrintGetEntries(string domain, string[] entries, string[] fields) {
			PrintDebugMessage("PrintGetEntries", "Begin", 1);
			string[][] result = GetEntries(domain, entries, fields);
			PrintArrayOfStringList(result, false);
			PrintDebugMessage("PrintGetEntries", "End", 1);
		}
		
		public void PrintGetEntries(string domain, string entries, string fields) {
			PrintDebugMessage("PrintGetEntries", "Begin", 1);
			string[] entryIdentifiers = SplitString(entries);
			string[] fieldNames = SplitString(fields);
			PrintGetEntries(domain, entryIdentifiers, fieldNames);
			PrintDebugMessage("PrintGetEntry", "End", 1);
		}
		
		public string[] GetEntryFieldUrls(string domain, string entry, string[] fields) {
			PrintDebugMessage("GetEntryFieldUrls", "Begin", 1);
			ServiceProxyConnect();
			string[] result = SrvProxy.getEntryFieldUrls(domain, entry, fields);
			PrintDebugMessage("GetEntryFieldUrls", "End", 1);
			return result;
		}
		
		public void PrintGetEntryFieldUrls(string domain, string entry, string[] fields) {
			PrintDebugMessage("PrintGetEntryFieldUrls", "Begin", 1);
			string[] result = GetEntryFieldUrls(domain, entry, fields);
			PrintStrList(result);
			PrintDebugMessage("PrintGetEntryFieldUrls", "End", 1);
		}
		
		public void PrintGetEntryFieldUrls(string domain, string entry, string fields) {
			PrintDebugMessage("PrintGetEntryFieldUrls", "Begin", 1);
			string[] fieldNames = SplitString(fields);
			PrintGetEntryFieldUrls(domain, entry, fieldNames);
			PrintDebugMessage("PrintGetEntryFieldUrls", "End", 1);
		}
		
		public string[][] GetEntriesFieldUrls(string domain, string[] entries, string[] fields) {
			PrintDebugMessage("GetEntriesFieldUrls", "Begin", 1);
			ServiceProxyConnect();
			string[][] result = SrvProxy.getEntriesFieldUrls(domain, entries, fields);
			PrintDebugMessage("GetEntriesFieldUrls", "End", 1);
			return result;
		}
		
		public void PrintGetEntriesFieldUrls(string domain, string[] entries, string[] fields) {
			PrintDebugMessage("PrintGetEntriesFieldUrls", "Begin", 1);
			string[][] result = GetEntriesFieldUrls(domain, entries, fields);
			PrintArrayOfStringList(result, false);
			PrintDebugMessage("PrintGetEntriesFieldUrls", "End", 1);
		}
		
		public void PrintGetEntriesFieldUrls(string domain, string entries, string fields) {
			PrintDebugMessage("PrintGetEntriesFieldUrls", "Begin", 1);
			string[] entryIdentifiers = SplitString(entries);
			string[] fieldNames = SplitString(fields);
			PrintGetEntriesFieldUrls(domain, entryIdentifiers, fieldNames);
			PrintDebugMessage("PrintGetEntryFieldUrls", "End", 1);
		}
		
		public string[] GetDomainsReferencedInDomain(string domain) {
			PrintDebugMessage("GetDomainsReferencedInDomain", "Begin", 1);
			ServiceProxyConnect();
			string[] result = SrvProxy.getDomainsReferencedInDomain(domain);
			PrintDebugMessage("GetDomainsReferencedInDomain", "End", 1);
			return result;
		}
		
		public void PrintGetDomainsReferencedInDomain(string domain) {
			PrintDebugMessage("PrintGetDomainsReferencedInDomain", "Begin", 1);
			string[] result = GetDomainsReferencedInDomain(domain);
			PrintStrList(result);
			PrintDebugMessage("PrintGetDomainsReferencedInDomain", "End", 1);
		}
		
		public string[] GetDomainsReferencedInEntry(string domain, string entry) {
			PrintDebugMessage("GetDomainsReferencedInEntry", "Begin", 1);
			ServiceProxyConnect();
			string[] result = SrvProxy.getDomainsReferencedInEntry(domain, entry);
			PrintDebugMessage("GetDomainsReferencedInEntry", "End", 1);
			return result;
		}
		
		public void PrintGetDomainsReferencedInEntry(string domain, string entry) {
			PrintDebugMessage("PrintGetDomainsReferencedInEntry", "Begin", 1);
			string[] result = GetDomainsReferencedInEntry(domain, entry);
			PrintStrList(result);
			PrintDebugMessage("PrintGetDomainsReferencedInEntry", "End", 1);
		}
		
		public string[] ListAdditionalReferenceFields(string domain) {
			PrintDebugMessage("ListAdditionalReferenceFields", "Begin", 1);
			ServiceProxyConnect();
			string[] result = SrvProxy.listAdditionalReferenceFields(domain);
			PrintDebugMessage("ListAdditionalReferenceFields", "End", 1);
			return result;
		}
		
		public void PrintListAdditionalReferenceFields(string domain) {
			PrintDebugMessage("PrintListAdditionalReferenceFields", "Begin", 1);
			string[] result = ListAdditionalReferenceFields(domain);
			PrintStrList(result);
			PrintDebugMessage("PrintListAdditionalReferenceFields", "End", 1);
		}
		
		public string[] GetReferencedEntries(string domain, string entry, string referencedDomain) {
			PrintDebugMessage("GetReferencedEntries", "Begin", 1);
			ServiceProxyConnect();
			string[] result = SrvProxy.getReferencedEntries(domain, entry, referencedDomain);
			PrintDebugMessage("GetReferencedEntries", "End", 1);
			return result;
		}
		
		public void PrintGetReferencedEntries(string domain, string entry, string referencedDomain) {
			PrintDebugMessage("PrintGetReferencedEntries", "Begin", 1);
			string[] result = GetReferencedEntries(domain, entry, referencedDomain);
			PrintStrList(result);
			PrintDebugMessage("PrintGetReferencedEntries", "End", 1);
		}
		
		public EntryReferences[] GetReferencedEntriesSet(string domain, string[] entries, string referencedDomain, string[] fields) {
			PrintDebugMessage("GetReferencedEntriesSet", "Begin", 1);
			ServiceProxyConnect();
			EntryReferences[] result = SrvProxy.getReferencedEntriesSet(domain, entries, referencedDomain, fields);
			PrintDebugMessage("GetReferencedEntriesSet", "End", 1);
			return result;
		}
		
		public void PrintGetReferencedEntriesSet(string domain, string[] entries, string referencedDomain, string[] fields) {
			PrintDebugMessage("PrintGetReferencedEntriesSet", "Begin", 1);
			EntryReferences[] result = GetReferencedEntriesSet(domain, entries, referencedDomain, fields);
			foreach(EntryReferences entry in result) {
				Console.WriteLine(entry.entry);
				foreach(string[] xrefs in entry.references) {
					foreach(string xref in xrefs) {
						Console.Write("\t" + xref);
					}
					Console.WriteLine();
				}
				Console.WriteLine();
			}
			PrintDebugMessage("PrintGetReferencedEntriesSet", "End", 1);
		}
		
		public void PrintGetReferencedEntriesSet(string domain, string entries, string referencedDomain, string fields) {
			PrintDebugMessage("PrintGetReferencedEntriesSet", "Begin", 1);
			string[] entryIdentifiers = SplitString(entries);
			string[] fieldNames = SplitString(fields);
			PrintGetReferencedEntriesSet(domain, entryIdentifiers, referencedDomain, fieldNames);
			PrintDebugMessage("PrintGetReferencedEntriesSet", "End", 1);
		}
		
		public string[][] GetReferencedEntriesFlatSet(string domain, string[] entries, string referencedDomain, string[] fields) {
			PrintDebugMessage("GetReferencedEntriesFlatSet", "Begin", 1);
			ServiceProxyConnect();
			string[][] result = SrvProxy.getReferencedEntriesFlatSet(domain, entries, referencedDomain, fields);
			PrintDebugMessage("GetReferencedEntriesFlatSet", "End", 1);
			return result;
		}
		
		public void PrintGetReferencedEntriesFlatSet(string domain, string[] entries, string referencedDomain, string[] fields) {
			PrintDebugMessage("PrintGetReferencedEntriesFlatSet", "Begin", 1);
			string[][] result = GetReferencedEntriesFlatSet(domain, entries, referencedDomain, fields);
			PrintArrayOfStringList(result, true);
			PrintDebugMessage("PrintGetReferencedEntriesFlatSet", "End", 1);
		}
		
		public void PrintGetReferencedEntriesFlatSet(string domain, string entries, string referencedDomain, string fields) {
			PrintDebugMessage("PrintGetReferencedEntriesFlatSet", "Begin", 1);
			string[] entryIdentifiers = SplitString(entries);
			string[] fieldNames = SplitString(fields);
			PrintGetReferencedEntriesFlatSet(domain, entryIdentifiers, referencedDomain, fieldNames);
			PrintDebugMessage("PrintGetReferencedEntriesFlatSet", "End", 1);
		}
		
		public DomainDescription GetDomainsHierarchy() {
			PrintDebugMessage("GetDomainsHierarchy", "Begin", 1);
			ServiceProxyConnect();
			DomainDescription result = SrvProxy.getDomainsHierarchy();
			PrintDebugMessage("GetDomainsHierarchy", "Begin", 1);
			return result;
		}
		
		public void PrintGetDomainsHierarchy() {
			PrintDebugMessage("PrintGetDomainsHierarchy", "Begin", 1);
			DomainDescription rootDomain = GetDomainsHierarchy();
			PrintDomainDescription(rootDomain, "");
			PrintDebugMessage("PrintGetDomainsHierarchy", "Begin", 1);
		}
		
		public DomainResult GetDetailledNumberOfResults(string domain, string query, Boolean flat) {
			PrintDebugMessage("GetDetailledNumberOfResults", "Begin", 1);
			ServiceProxyConnect();
			DomainResult result = SrvProxy.getDetailledNumberOfResults(domain, query, flat);
			PrintDebugMessage("GetDetailledNumberOfResults", "End", 1);
			return result;
		}
		
		public void PrintGetDetailledNumberOfResults(string domain, string query, Boolean flat) {
			PrintDebugMessage("PrintGetDetailledNumberOfResults", "Begin", 1);
			DomainResult results = GetDetailledNumberOfResults(domain, query, flat);
			PrintDomainResults(results, "");
			PrintDebugMessage("PrintGetDetailledNumberOfResults", "End", 1);
		}
		
		public void PrintGetDetailledNumberOfResults(string domain, string query, string flat) {
			PrintDebugMessage("PrintGetDetailledNumberOfResults", "Begin", 1);
			Boolean isFlat = false;
			string tmpflat = flat.ToLower();
			if(tmpflat == "t" || tmpflat == "true" || tmpflat == "y" || tmpflat == "yes" || tmpflat == "1") {
				isFlat = true;
			}
			PrintGetDetailledNumberOfResults(domain, query, isFlat);
			PrintDebugMessage("PrintGetDetailledNumberOfResults", "End", 1);
		}
		
		public EbiWS.EBeyeWs.FieldInfo[] ListFieldsInformation(string domain) {
			PrintDebugMessage("ListFieldsInformation", "Begin", 1);
			ServiceProxyConnect();
			EbiWS.EBeyeWs.FieldInfo[] result = SrvProxy.listFieldsInformation(domain);
			PrintDebugMessage("ListFieldsInformation", "End", 1);
			return result;
		}
		
		public void PrintListFieldsInformation(string domain) {
			PrintDebugMessage("PrintListFieldsInformation", "Begin", 1);
			EbiWS.EBeyeWs.FieldInfo[] result = ListFieldsInformation(domain);
			foreach(EbiWS.EBeyeWs.FieldInfo field in result) {
				Console.WriteLine(field.id + "\t" + field.name + "\t" + field.description + "\t" + field.searchable + "\t" + field.retrievable);
			}
			PrintDebugMessage("PrintListFieldsInformation", "End", 1);
		}
		
		// ******
		
		private string[] SplitString(string inStr, char[] seperators) {
			PrintDebugMessage("SplitString", "Begin", 11);
			string[] retVal = inStr.Split(seperators);
			PrintDebugMessage("SplitString", "End", 11);
			return retVal;
		}

		private string[] SplitString(string inStr) {
			PrintDebugMessage("SplitString", "Begin", 11);
			char[] sepList = {' ', '+', ',', ';'};
			string[] retVal = SplitString(inStr, sepList);
			PrintDebugMessage("SplitString", "End", 11);
			return retVal;
		}

		// Print domain information used by getDomainsHierarchy
		private void PrintDomainDescription(DomainDescription domain, string indent) {
			PrintDebugMessage("PrintDomainDescription", "Begin", 1);
			Console.WriteLine(indent + domain.id + " : " + domain.name);
			if(domain.subDomains != null && domain.subDomains.Length > 0) {
				foreach (DomainDescription subdomain in domain.subDomains) {
					PrintDomainDescription(subdomain, indent + "\t");
				}
			}
			PrintDebugMessage("PrintDomainDecription", "End", 1);
		}

		// Print the domain results used by getDetailedNumberOfResults
		private void PrintDomainResults(DomainResult domain, string indent) {
			PrintDebugMessage("PrintDomainResults", "Begin", 1);
			Console.WriteLine(indent + domain.domainId + " : " + domain.numberOfResults);
			if(domain.subDomainsResults != null && domain.subDomainsResults.Length > 0) {
				foreach (DomainResult subdomain in domain.subDomainsResults) {
					PrintDomainResults(subdomain, indent + "\t");
				}
			}
			PrintDebugMessage("PrintDomainResults", "End", 1);
		}

		// Print reference sets used by getReferenceEntriesSet
		private void PrintArrayOfStringList(String[][] arrayList, Boolean table) {
			PrintDebugMessage("PrintArrayOfStringList", "Begin", 1);
			for(int i = 0; i < arrayList.Length; i++) {
				String[] strList = arrayList[i];
				for(int j = 0; j < strList.Length; j++) {
					if(table && j > 0) Console.Write("\t");
					Console.Write(strList[j]);
					if(!table) Console.WriteLine("");
				}
				if(table) Console.WriteLine("");
			}
			PrintDebugMessage("PrintArrayOfStringList", "End", 1);
		}

		// Print a list of strings
		private void PrintStrList(string[] strList) {
			foreach (string item in strList) {
				if (item != null && item != "") {
					Console.WriteLine(item);
				}
			}
		}
	}
}
