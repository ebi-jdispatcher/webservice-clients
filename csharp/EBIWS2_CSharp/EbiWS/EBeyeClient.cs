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
		
		/// <summary>
		/// Get the number of entries matching a query.
		/// </summary>
		/// <param name="domain">
		/// The name of the domain to search.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="query">
		/// The query string.
		/// A <see cref="System.String"/>
		/// </param>
		/// <returns>
		/// The number of results.
		/// A <see cref="System.Int32"/>
		/// </returns>
		public int GetNumberOfResults(string domain, string query) {
			PrintDebugMessage("GetNumberOfResults", "Begin", 1);
			ServiceProxyConnect();
			int retVal = SrvProxy.getNumberOfResults(domain, query);
			PrintDebugMessage("GetNumberOfResults", "retVal: " + retVal, 1);
			PrintDebugMessage("GetNumberOfResults", "End", 1);
			return retVal;
		}
		
		/// <summary>
		/// Print the number of entries matching a query.
		/// </summary>
		/// <param name="domain">
		/// The domain to search.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="query">
		/// The query to perform.
		/// A <see cref="System.String"/>
		/// </param>
		public void PrintGetNumberOfResults(string domain, string query) {
			PrintDebugMessage("PrintGetNumberOfResults", "Begin", 1);
			int numResults = GetNumberOfResults(domain, query);
			Console.WriteLine(numResults);
			PrintDebugMessage("PrintGetNumberOfResults", "End", 1);
		}
		
		/// <summary>
		/// Get the list of entry identifiers matching a query.
		/// </summary>
		/// <param name="domain">
		/// The domain to search.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="query">
		/// The query to perform.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="start">
		/// Number of the starting entry of the set of results to return.
		/// A <see cref="System.Int32"/>
		/// </param>
		/// <param name="size">
		/// Number of identifiers to return.
		/// A <see cref="System.Int32"/>
		/// </param>
		/// <returns>
		/// Array of identifiers of entries matched by the query.
		/// A <see cref="System.String"/>
		/// </returns>
		public string[] GetResultsIds(string domain, string query, int start, int size) {
			PrintDebugMessage("GetResultsIds", "Begin", 1);
			ServiceProxyConnect();
			string[] result = SrvProxy.getResultsIds(domain, query, start, size);
			PrintDebugMessage("GetResultsIds", "End", 1);
			return result;
		}
		
		/// <summary>
		/// Print the set of entry identifiers matching a query.
		/// </summary>
		/// <param name="domain">
		/// The domain to search.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="query">
		/// The query to perform.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="start">
		/// Number of the starting entry of the set of results to return.
		/// A <see cref="System.Int32"/>
		/// </param>
		/// <param name="size">
		/// Number of identifiers to return.
		/// A <see cref="System.Int32"/>
		/// </param>
		public void PrintGetResultsIds(string domain, string query, int start, int size) {
			PrintDebugMessage("PrintGetResultsIds", "Begin", 1);
			string[] result = GetResultsIds(domain, query, start, size);
			PrintStrList(result);
			PrintDebugMessage("PrintGetResultsIds", "End", 1);
		}
		
		/// <summary>
		/// Print the set of entry identifiers matching a query.
		/// </summary>
		/// <param name="domain">
		/// The domain to search.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="query">
		/// The query to perform.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="start">
		/// Number of the starting entry of the set of results to return.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="size">
		/// Number of identifiers to return.
		/// A <see cref="System.String"/>
		/// </param>
		public void PrintGetResultsIds(string domain, string query, string start, string size) {
			PrintDebugMessage("PrintGetResultsIds", "Begin", 1);
			PrintGetResultsIds(domain, query, Convert.ToInt32(start), Convert.ToInt32(size));
			PrintDebugMessage("PrintGetResultsIds", "End", 1);
		}

		/// <summary>
		/// Get the set of entry identifiers matching a query.
		/// </summary>
		/// <param name="domain">
		/// The domain to search.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="query">
		/// The query to perform.
		/// A <see cref="System.String"/>
		/// </param>
		/// <returns>
		/// Arry of entry identifiers.
		/// A <see cref="System.String"/>
		/// </returns>
		public string[] GetAllResultsIds(string domain, string query) {
			PrintDebugMessage("GetAllResultsIds", "Begin", 1);
			ServiceProxyConnect();
			string[] result = SrvProxy.getAllResultsIds(domain, query);
			PrintDebugMessage("GetAllResultsIds", "End", 1);
			return result;
		}
		
		/// <summary>
		/// Print the set of entry identifiers matching a query.
		/// </summary>
		/// <param name="domain">
		/// The domain to search.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="query">
		/// The query to perform.
		/// A <see cref="System.String"/>
		/// </param>
		public void PrintGetAllResultsIds(string domain, string query) {
			PrintDebugMessage("PrintGetAllResultsIds", "Begin", 1);
			string[] result = GetAllResultsIds(domain, query);
			PrintStrList(result);
			PrintDebugMessage("PrintGetAllResultsIds", "End", 1);
		}
		
		/// <summary>
		/// Get the list of fields available for retrieval.
		/// </summary>
		/// <param name="domain">
		/// Domain to obtain the set of fields for.
		/// A <see cref="System.String"/>
		/// </param>
		/// <returns>
		/// Array of feild names.
		/// A <see cref="System.String"/>
		/// </returns>
		public string[] ListFields(string domain) {
			PrintDebugMessage("ListFields", "Begin", 1);
			ServiceProxyConnect();
			string[] result = SrvProxy.listFields(domain);
			PrintDebugMessage("ListFields", "End", 1);
			return result;
		}

		/// <summary>
		/// Print the list of fields available for retrieval.
		/// </summary>
		/// <param name="domain">
		/// The domain to get the list of feilds from.
		/// A <see cref="System.String"/>
		/// </param>
		public void PrintListFields(string domain) {
			PrintDebugMessage("PrintListFields", "Begin", 1);
			string[] results = ListFields(domain);
			PrintStrList(results);
			PrintDebugMessage("PrintListFields", "End", 1);
		}
		
		/// <summary>
		/// Get data from retrievable fields for a query.
		/// </summary>
		/// <param name="domain">
		/// The domain to search.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="query">
		/// The query to perform.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="fields">
		/// List of field names to retrive data from.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="start">
		/// Number of first entry in set of entries matching query to retrive.
		/// A <see cref="System.Int32"/>
		/// </param>
		/// <param name="size">
		/// Number of entries to retrive data from.
		/// A <see cref="System.Int32"/>
		/// </param>
		/// <returns>
		/// Array of entries, each containging an array of field data.
		/// A <see cref="System.String"/>
		/// </returns>
		public string[][] GetResults(string domain, string query, string[] fields, int start, int size) {
			PrintDebugMessage("GetResults", "Begin", 1);
			ServiceProxyConnect();
			string[][] results = SrvProxy.getResults(domain, query, fields, start, size);
			PrintDebugMessage("GetResults", "End", 1);
			return results;
		}
		
		/// <summary>
		/// Print data from retrievable fields for a query.
		/// </summary>
		/// <param name="domain">
		/// The domain to search.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="query">
		/// The query to perform.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="fields">
		/// List of field names to retrive data from.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="start">
		/// Number of first entry in set of entries matching query to retrive.
		/// A <see cref="System.Int32"/>
		/// </param>
		/// <param name="size">
		/// Number of entries to retrive data from.
		/// A <see cref="System.Int32"/>
		/// </param>
		public void PrintGetResults(string domain, string query, string[] fields, int start, int size) {
			PrintDebugMessage("PrintGetResults", "Begin", 1);
			string[][] results = GetResults(domain, query, fields, start, size);
			PrintArrayOfStringList(results, false);
			PrintDebugMessage("PrintGetResults", "End", 1);
		}

		/// <summary>
		/// Print data from retrievable fields for a query.
		/// </summary>
		/// <param name="domain">
		/// The domain to search.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="query">
		/// The query to perform.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="fields">
		/// Comma seperated list of field names to retrive data from.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="start">
		/// Number of first entry in set of entries matching query to retrive.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="size">
		/// Number of entries to retrive data from.
		/// A <see cref="System.String"/>
		/// </param>
		public void PrintGetResults(string domain, string query, string fields, string start, string size) {
			PrintDebugMessage("PrintGetResults", "Begin", 1);
			string[] fieldNames = SplitString(fields);
			PrintGetResults(domain, query, fieldNames, Convert.ToInt32(start), Convert.ToInt32(size));
			PrintDebugMessage("PrintGetResults", "Begin", 1);
		}
		
		/// <summary>
		/// Get data for a specific entry.
		/// </summary>
		/// <param name="domain">
		/// The domain containing the entry.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="entry">
		/// The entry identifier.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="fields">
		/// List of fields to get data from.
		/// A <see cref="System.String"/>
		/// </param>
		/// <returns>
		/// Array of data from fields.
		/// A <see cref="System.String"/>
		/// </returns>
		public string[] GetEntry(string domain, string entry, string[] fields) {
			PrintDebugMessage("GetEntry", "Begin", 1);
			ServiceProxyConnect();
			string[] result = SrvProxy.getEntry(domain, entry, fields);
			PrintDebugMessage("GetEntry", "End", 1);
			return result;
		}
		
		/// <summary>
		/// Print data for a specific entry.
		/// </summary>
		/// <param name="domain">
		/// The domain containing the entry.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="entry">
		/// The entry identifier.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="fields">
		/// List of fields to get data from.
		/// A <see cref="System.String"/>
		/// </param>
		public void PrintGetEntry(string domain, string entry, string[] fields) {
			PrintDebugMessage("PrintGetEntry", "Begin", 1);
			string[] result = GetEntry(domain, entry, fields);
			PrintStrList(result);
			PrintDebugMessage("PrintGetEntry", "End", 1);
		}
		
		/// <summary>
		/// Print data for a specific entry.
		/// </summary>
		/// <param name="domain">
		/// The domain containing the entry.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="entry">
		/// The entry identifier.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="fields">
		/// Comma seperated list of fields to get data from.
		/// A <see cref="System.String"/>
		/// </param>
		public void PrintGetEntry(string domain, string entry, string fields) {
			PrintDebugMessage("PrintGetEntry", "Begin", 1);
			string[] fieldNames = SplitString(fields);
			PrintGetEntry(domain, entry, fieldNames);
			PrintDebugMessage("PrintGetEntry", "End", 1);
		}
		
		/// <summary>
		/// Get data for a specified set of entries.
		/// </summary>
		/// <param name="domain">
		/// The domain containing the entries.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="entries">
		/// List of entry identifiers.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="fields">
		/// List of fields to get data from.
		/// A <see cref="System.String"/>
		/// </param>
		/// <returns>
		/// Array of entries, each contining an array of data from the fields.
		/// A <see cref="System.String"/>
		/// </returns>
		public string[][] GetEntries(string domain, string[] entries, string[] fields) {
			PrintDebugMessage("GetEntries", "Begin", 1);
			ServiceProxyConnect();
			string[][] result = SrvProxy.getEntries(domain, entries, fields);
			PrintDebugMessage("GetEntries", "End", 1);
			return result;
		}
		
		/// <summary>
		/// Print data for a specified set of entries.
		/// </summary>
		/// <param name="domain">
		/// The domain containing the entries.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="entries">
		/// List of entry identifiers.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="fields">
		/// List of fields to get data from.
		/// A <see cref="System.String"/>
		/// </param>
		public void PrintGetEntries(string domain, string[] entries, string[] fields) {
			PrintDebugMessage("PrintGetEntries", "Begin", 1);
			string[][] result = GetEntries(domain, entries, fields);
			PrintArrayOfStringList(result, false);
			PrintDebugMessage("PrintGetEntries", "End", 1);
		}

		/// <summary>
		/// Print data for a specified set of entries.
		/// </summary>
		/// <param name="domain">
		/// The domain containing the entries.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="entries">
		/// Comma seperated list of entry identifiers.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="fields">
		/// Comma seperated list of fields to get data from.
		/// A <see cref="System.String"/>
		/// </param>
		public void PrintGetEntries(string domain, string entries, string fields) {
			PrintDebugMessage("PrintGetEntries", "Begin", 1);
			string[] entryIdentifiers = SplitString(entries);
			string[] fieldNames = SplitString(fields);
			PrintGetEntries(domain, entryIdentifiers, fieldNames);
			PrintDebugMessage("PrintGetEntry", "End", 1);
		}
		
		/// <summary>
		/// Get URL(s) associated with fields for a specified entry.
		/// </summary>
		/// <param name="domain">
		/// The domain containing the entry.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="entry">
		/// The entry identifier.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="fields">
		/// List of fields to retrive URLs from.
		/// A <see cref="System.String"/>
		/// </param>
		/// <returns>
		/// Array containing the set of URLs.
		/// A <see cref="System.String"/>
		/// </returns>
		public string[] GetEntryFieldUrls(string domain, string entry, string[] fields) {
			PrintDebugMessage("GetEntryFieldUrls", "Begin", 1);
			ServiceProxyConnect();
			string[] result = SrvProxy.getEntryFieldUrls(domain, entry, fields);
			PrintDebugMessage("GetEntryFieldUrls", "End", 1);
			return result;
		}
		
		/// <summary>
		/// Print URL(s) associated with fields for a specified entry.
		/// </summary>
		/// <param name="domain">
		/// The domain containing the entry.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="entry">
		/// The entry identifier.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="fields">
		/// List of fields to retrive URLs from.
		/// A <see cref="System.String"/>
		/// </param>
		public void PrintGetEntryFieldUrls(string domain, string entry, string[] fields) {
			PrintDebugMessage("PrintGetEntryFieldUrls", "Begin", 1);
			string[] result = GetEntryFieldUrls(domain, entry, fields);
			PrintStrList(result);
			PrintDebugMessage("PrintGetEntryFieldUrls", "End", 1);
		}

		/// <summary>
		/// Print URL(s) associated with fields for a specified entry.
		/// </summary>
		/// <param name="domain">
		/// The domain containing the entry.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="entry">
		/// The entry identifier.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="fields">
		/// Comma seperated list of fields to retrive URLs from.
		/// A <see cref="System.String"/>
		/// </param>
		public void PrintGetEntryFieldUrls(string domain, string entry, string fields) {
			PrintDebugMessage("PrintGetEntryFieldUrls", "Begin", 1);
			string[] fieldNames = SplitString(fields);
			PrintGetEntryFieldUrls(domain, entry, fieldNames);
			PrintDebugMessage("PrintGetEntryFieldUrls", "End", 1);
		}
		
		/// <summary>
		/// Get URL(s) associated with fields for a specified set of entries.
		/// </summary>
		/// <param name="domain">
		/// The domain containing the entries.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="entries">
		/// List of entry identifiers.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="fields">
		/// List of fields to retrive URLs from.
		/// A <see cref="System.String"/>
		/// </param>
		/// <returns>
		/// Array of entries, each containing an array of URLs obtained for the specified fields.
		/// A <see cref="System.String"/>
		/// </returns>
		public string[][] GetEntriesFieldUrls(string domain, string[] entries, string[] fields) {
			PrintDebugMessage("GetEntriesFieldUrls", "Begin", 1);
			ServiceProxyConnect();
			string[][] result = SrvProxy.getEntriesFieldUrls(domain, entries, fields);
			PrintDebugMessage("GetEntriesFieldUrls", "End", 1);
			return result;
		}
		
		/// <summary>
		/// Print URL(s) associated with fields for a specified set of entries.
		/// </summary>
		/// <param name="domain">
		/// The domain containing the entries.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="entries">
		/// List of entry identifiers.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="fields">
		/// List of fields to retrive URLs from.
		/// A <see cref="System.String"/>
		/// </param>
		public void PrintGetEntriesFieldUrls(string domain, string[] entries, string[] fields) {
			PrintDebugMessage("PrintGetEntriesFieldUrls", "Begin", 1);
			string[][] result = GetEntriesFieldUrls(domain, entries, fields);
			PrintArrayOfStringList(result, false);
			PrintDebugMessage("PrintGetEntriesFieldUrls", "End", 1);
		}

		/// <summary>
		/// Print URL(s) associated with fields for a specified set of entries.
		/// </summary>
		/// <param name="domain">
		/// The domain containing the entries.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="entries">
		/// Comma seperated list of entry identifiers.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="fields">
		/// Comma seperated list of fields to retrive URLs from.
		/// A <see cref="System.String"/>
		/// </param>
		public void PrintGetEntriesFieldUrls(string domain, string entries, string fields) {
			PrintDebugMessage("PrintGetEntriesFieldUrls", "Begin", 1);
			string[] entryIdentifiers = SplitString(entries);
			string[] fieldNames = SplitString(fields);
			PrintGetEntriesFieldUrls(domain, entryIdentifiers, fieldNames);
			PrintDebugMessage("PrintGetEntryFieldUrls", "End", 1);
		}
		
		/// <summary>
		/// Get list of domains cross-referenced in a specified domain.
		/// </summary>
		/// <param name="domain">
		/// The domain.
		/// A <see cref="System.String"/>
		/// </param>
		/// <returns>
		/// List of domain names.
		/// A <see cref="System.String"/>
		/// </returns>
		public string[] GetDomainsReferencedInDomain(string domain) {
			PrintDebugMessage("GetDomainsReferencedInDomain", "Begin", 1);
			ServiceProxyConnect();
			string[] result = SrvProxy.getDomainsReferencedInDomain(domain);
			PrintDebugMessage("GetDomainsReferencedInDomain", "End", 1);
			return result;
		}
		
		/// <summary>
		/// Print list of domains cross-referenced in a specified domain.
		/// </summary>
		/// <param name="domain">
		/// The domain.
		/// A <see cref="System.String"/>
		/// </param>
		public void PrintGetDomainsReferencedInDomain(string domain) {
			PrintDebugMessage("PrintGetDomainsReferencedInDomain", "Begin", 1);
			string[] result = GetDomainsReferencedInDomain(domain);
			PrintStrList(result);
			PrintDebugMessage("PrintGetDomainsReferencedInDomain", "End", 1);
		}
		
		/// <summary>
		/// Get list of domains cross-referenced in an entry.
		/// </summary>
		/// <param name="domain">
		/// The domain containing the entry.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="entry">
		/// The entry identifier.
		/// A <see cref="System.String"/>
		/// </param>
		/// <returns>
		/// List of domain names.
		/// A <see cref="System.String"/>
		/// </returns>
		public string[] GetDomainsReferencedInEntry(string domain, string entry) {
			PrintDebugMessage("GetDomainsReferencedInEntry", "Begin", 1);
			ServiceProxyConnect();
			string[] result = SrvProxy.getDomainsReferencedInEntry(domain, entry);
			PrintDebugMessage("GetDomainsReferencedInEntry", "End", 1);
			return result;
		}
		
		/// <summary>
		/// Print list of domains cross-referenced in an entry.
		/// </summary>
		/// <param name="domain">
		/// The domain containing the entry.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="entry">
		/// The entry identifier.
		/// A <see cref="System.String"/>
		/// </param>
		public void PrintGetDomainsReferencedInEntry(string domain, string entry) {
			PrintDebugMessage("PrintGetDomainsReferencedInEntry", "Begin", 1);
			string[] result = GetDomainsReferencedInEntry(domain, entry);
			PrintStrList(result);
			PrintDebugMessage("PrintGetDomainsReferencedInEntry", "End", 1);
		}

		/// <summary>
		/// Get list of fields containing cross-references to external sources for a specified domain.
		/// </summary>
		/// <param name="domain">
		/// The domain.
		/// A <see cref="System.String"/>
		/// </param>
		/// <returns>
		/// List of field names.
		/// A <see cref="System.String"/>
		/// </returns>
		public string[] ListAdditionalReferenceFields(string domain) {
			PrintDebugMessage("ListAdditionalReferenceFields", "Begin", 1);
			ServiceProxyConnect();
			string[] result = SrvProxy.listAdditionalReferenceFields(domain);
			PrintDebugMessage("ListAdditionalReferenceFields", "End", 1);
			return result;
		}
		
		/// <summary>
		/// Print list of fields containing cross-references to external sources for a specified domain.
		/// </summary>
		/// <param name="domain">
		/// The domain.
		/// A <see cref="System.String"/>
		/// </param>
		public void PrintListAdditionalReferenceFields(string domain) {
			PrintDebugMessage("PrintListAdditionalReferenceFields", "Begin", 1);
			string[] result = ListAdditionalReferenceFields(domain);
			PrintStrList(result);
			PrintDebugMessage("PrintListAdditionalReferenceFields", "End", 1);
		}
		
		/// <summary>
		/// Get entry identifiers for entries in a specified domain cross-referenced by an entry.
		/// </summary>
		/// <param name="domain">
		/// The domain containing the entry.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="entry">
		/// The entry identifier.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="referencedDomain">
		/// The domain to get identifiers from.
		/// A <see cref="System.String"/>
		/// </param>
		/// <returns>
		/// List of entry identifiers from referenced domain.
		/// A <see cref="System.String"/>
		/// </returns>
		public string[] GetReferencedEntries(string domain, string entry, string referencedDomain) {
			PrintDebugMessage("GetReferencedEntries", "Begin", 1);
			ServiceProxyConnect();
			string[] result = SrvProxy.getReferencedEntries(domain, entry, referencedDomain);
			PrintDebugMessage("GetReferencedEntries", "End", 1);
			return result;
		}
		
		/// <summary>
		/// Print entry identifiers for entries in a specified domain cross-referenced by an entry.
		/// </summary>
		/// <param name="domain">
		/// The domain containing the entry.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="entry">
		/// The entry identifier.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="referencedDomain">
		/// The domain to get identifiers from.
		/// A <see cref="System.String"/>
		/// </param>
		public void PrintGetReferencedEntries(string domain, string entry, string referencedDomain) {
			PrintDebugMessage("PrintGetReferencedEntries", "Begin", 1);
			string[] result = GetReferencedEntries(domain, entry, referencedDomain);
			PrintStrList(result);
			PrintDebugMessage("PrintGetReferencedEntries", "End", 1);
		}
		
		/// <summary>
		///  Get data from entries in a specified domain cross-referenced by set of entries.
		/// </summary>
		/// <param name="domain">
		/// The domain containing the specified entries.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="entries">
		/// List of entry identifers to get cross-referenced data for.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="referencedDomain">
		/// Domain to get data from.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="fields">
		/// List of fields in referenced domain to get data from.
		/// A <see cref="System.String"/>
		/// </param>
		/// <returns>
		/// Array of entries containing the source entry identifier and an array of data from referenced entries.
		/// A <see cref="EntryReferences"/>
		/// </returns>
		public EntryReferences[] GetReferencedEntriesSet(string domain, string[] entries, string referencedDomain, string[] fields) {
			PrintDebugMessage("GetReferencedEntriesSet", "Begin", 1);
			ServiceProxyConnect();
			EntryReferences[] result = SrvProxy.getReferencedEntriesSet(domain, entries, referencedDomain, fields);
			PrintDebugMessage("GetReferencedEntriesSet", "End", 1);
			return result;
		}
		
		/// <summary>
		/// Print  data from entries in a specified domain cross-referenced by set of entries.
		/// </summary>
		/// <param name="domain">
		/// The domain containing the specified entries.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="entries">
		/// List of entry identifers to get cross-referenced data for.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="referencedDomain">
		/// Domain to get data from.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="fields">
		/// List of fields in referenced domain to get data from.
		/// A <see cref="System.String"/>
		/// </param>
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

		/// <summary>
		/// Print data from entries in a specified domain cross-referenced by set of entries.
		/// </summary>
		/// <param name="domain">
		/// The domain containing the specified entries.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="entries">
		/// Comma seperated list of entry identifers to get cross-referenced data for.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="referencedDomain">
		/// Domain to get data from.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="fields">
		/// Comma seperated list of fields in referenced domain to get data from.
		/// A <see cref="System.String"/>
		/// </param>
		public void PrintGetReferencedEntriesSet(string domain, string entries, string referencedDomain, string fields) {
			PrintDebugMessage("PrintGetReferencedEntriesSet", "Begin", 1);
			string[] entryIdentifiers = SplitString(entries);
			string[] fieldNames = SplitString(fields);
			PrintGetReferencedEntriesSet(domain, entryIdentifiers, referencedDomain, fieldNames);
			PrintDebugMessage("PrintGetReferencedEntriesSet", "End", 1);
		}
		
		/// <summary>
		/// Get data from entries in a specified domain cross-referenced by set of entries.
		/// </summary>
		/// <param name="domain">
		/// The domain containing the specified entries.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="entries">
		/// List of entry identifers to get cross-referenced data for.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="referencedDomain">
		/// Domain to get data from.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="fields">
		/// List of fields in referenced domain to get data from.
		/// A <see cref="System.String"/>
		/// </param>
		/// <returns>
		/// Array of cross-referenced entries containing source entry identifer, and data from fields.
		/// A <see cref="System.String"/>
		/// </returns>
		public string[][] GetReferencedEntriesFlatSet(string domain, string[] entries, string referencedDomain, string[] fields) {
			PrintDebugMessage("GetReferencedEntriesFlatSet", "Begin", 1);
			ServiceProxyConnect();
			string[][] result = SrvProxy.getReferencedEntriesFlatSet(domain, entries, referencedDomain, fields);
			PrintDebugMessage("GetReferencedEntriesFlatSet", "End", 1);
			return result;
		}
		
		/// <summary>
		/// Print data from entries in a specified domain cross-referenced by set of entries.
		/// </summary>
		/// <param name="domain">
		/// The domain containing the specified entries.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="entries">
		/// List of entry identifers to get cross-referenced data for.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="referencedDomain">
		/// Domain to get data from.
		/// A <see cref="System.String"/>
		/// </param>
		/// List of fields in referenced domain to get data from.
		/// <param name="fields">
		/// A <see cref="System.String"/>
		/// </param>
		public void PrintGetReferencedEntriesFlatSet(string domain, string[] entries, string referencedDomain, string[] fields) {
			PrintDebugMessage("PrintGetReferencedEntriesFlatSet", "Begin", 1);
			string[][] result = GetReferencedEntriesFlatSet(domain, entries, referencedDomain, fields);
			PrintArrayOfStringList(result, true);
			PrintDebugMessage("PrintGetReferencedEntriesFlatSet", "End", 1);
		}

		/// <summary>
		/// Print data from entries in a specified domain cross-referenced by set of entries.
		/// </summary>
		/// <param name="domain">
		/// The domain containing the specified entries.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="entries">
		/// Comma seperated list of entry identifers to get cross-referenced data for.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="referencedDomain">
		/// Domain to get data from.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="fields">
		/// Comma seperated list of fields in referenced domain to get data from.
		/// A <see cref="System.String"/>
		/// </param>
		public void PrintGetReferencedEntriesFlatSet(string domain, string entries, string referencedDomain, string fields) {
			PrintDebugMessage("PrintGetReferencedEntriesFlatSet", "Begin", 1);
			string[] entryIdentifiers = SplitString(entries);
			string[] fieldNames = SplitString(fields);
			PrintGetReferencedEntriesFlatSet(domain, entryIdentifiers, referencedDomain, fieldNames);
			PrintDebugMessage("PrintGetReferencedEntriesFlatSet", "End", 1);
		}
		
		/// <summary>
		/// Get tree of domain decriptions.
		/// </summary>
		/// <returns>
		/// Domain description for root domain, containg description of the domain and of subdomains.
		/// A <see cref="DomainDescription"/>
		/// </returns>
		public DomainDescription GetDomainsHierarchy() {
			PrintDebugMessage("GetDomainsHierarchy", "Begin", 1);
			ServiceProxyConnect();
			DomainDescription result = SrvProxy.getDomainsHierarchy();
			PrintDebugMessage("GetDomainsHierarchy", "Begin", 1);
			return result;
		}
		
		/// <summary>
		/// Print tree of domains.
		/// </summary>
		public void PrintGetDomainsHierarchy() {
			PrintDebugMessage("PrintGetDomainsHierarchy", "Begin", 1);
			DomainDescription rootDomain = GetDomainsHierarchy();
			PrintDomainDescription(rootDomain, "");
			PrintDebugMessage("PrintGetDomainsHierarchy", "Begin", 1);
		}
		
		// Print domain information used by getDomainsHierarchy
		
		/// <summary>
		/// Print identifier and name for a domain and all of its subdomains.
		/// 
		/// This method is used by PrintGetDomainsHierarchy to print to tree of domains.
		/// </summary>
		/// <param name="domain">
		/// Domain description to print.
		/// A <see cref="DomainDescription"/>
		/// </param>
		/// <param name="indent">
		/// Indent string, usually empty string for root domain and with tab added for each subsequent level.
		/// A <see cref="System.String"/>
		/// </param>
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

		/// <summary>
		/// Get tree of the number of results for each subdomain under the domain searched.
		/// </summary>
		/// <param name="domain">
		/// The domain to search.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="query">
		/// The query to perform.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="flat">
		/// Flag indicating if all nodes in the branch are to be reported or just the leaves.
		/// A <see cref="System.Boolean"/>
		/// </param>
		/// <returns>
		/// A domain result object containing the number of entries found for the searched domain, and a set of domain result objects for each of the subdomains.
		/// A <see cref="DomainResult"/>
		/// </returns>
		public DomainResult GetDetailledNumberOfResults(string domain, string query, Boolean flat) {
			PrintDebugMessage("GetDetailledNumberOfResults", "Begin", 1);
			ServiceProxyConnect();
			DomainResult result = SrvProxy.getDetailledNumberOfResults(domain, query, flat);
			PrintDebugMessage("GetDetailledNumberOfResults", "End", 1);
			return result;
		}
		
		/// <summary>
		/// Print tree of the number of results for each subdomain under the domain searched.
		/// </summary>
		/// <param name="domain">
		/// The domain to search.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="query">
		/// The query to perform.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="flat">
		/// Flag indicating if all nodes in the branch are to be reported or just the leaves.
		/// A <see cref="System.Boolean"/>
		/// </param>
		public void PrintGetDetailledNumberOfResults(string domain, string query, Boolean flat) {
			PrintDebugMessage("PrintGetDetailledNumberOfResults", "Begin", 1);
			DomainResult results = GetDetailledNumberOfResults(domain, query, flat);
			PrintDomainResults(results, "");
			PrintDebugMessage("PrintGetDetailledNumberOfResults", "End", 1);
		}
		
		/// <summary>
		/// Print tree of the number of results for each subdomain under the domain searched.
		/// </summary>
		/// <param name="domain">
		/// The domain to search.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="query">
		/// The query to perform.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="flat">
		/// Flag indicating if all nodes in the branch are to be reported or just the leaves.
		/// A <see cref="System.String"/>
		/// </param>
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
		
		// Print the domain results used by g
		
		/// <summary>
		/// Print domain identifier and number of results for a domain result, as returned by GetDetailledNumberOfResults(), and print all results for all subdomains.
		/// 
		/// Used in PrintGetDetailledNumberOfResults().
		/// </summary>
		/// <param name="domain">
		/// The domain result to print.
		/// A <see cref="DomainResult"/>
		/// </param>
		/// <param name="indent">
		/// The string to use as indenting. Usually empty for the root node and with a tab added per-level.
		/// A <see cref="System.String"/>
		/// </param>
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

		/// <summary>
		/// Get detailed information about the search and retrievalable fields available for a domain.
		/// </summary>
		/// <param name="domain">
		/// The domain.
		/// A <see cref="System.String"/>
		/// </param>
		/// <returns>
		/// List of field descriptions.
		/// A <see cref="EbiWS.EBeyeWs.FieldInfo"/>
		/// </returns>
		public EbiWS.EBeyeWs.FieldInfo[] ListFieldsInformation(string domain) {
			PrintDebugMessage("ListFieldsInformation", "Begin", 1);
			ServiceProxyConnect();
			EbiWS.EBeyeWs.FieldInfo[] result = SrvProxy.listFieldsInformation(domain);
			PrintDebugMessage("ListFieldsInformation", "End", 1);
			return result;
		}
		
		/// <summary>
		/// Print details about hte search and retrivable fields available for a domain.
		/// </summary>
		/// <param name="domain">
		/// The domain.
		/// A <see cref="System.String"/>
		/// </param>
		public void PrintListFieldsInformation(string domain) {
			PrintDebugMessage("PrintListFieldsInformation", "Begin", 1);
			EbiWS.EBeyeWs.FieldInfo[] result = ListFieldsInformation(domain);
			foreach(EbiWS.EBeyeWs.FieldInfo field in result) {
				Console.WriteLine(field.id + "\t" + field.name + "\t" + field.description + "\t" + field.searchable + "\t" + field.retrievable);
			}
			PrintDebugMessage("PrintListFieldsInformation", "End", 1);
		}
		
		/// <summary>
		/// Split a string based on a set of seperator characters.
		/// </summary>
		/// <param name="inStr">
		/// The string to split.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="seperators">
		/// The set of seperators.
		/// A <see cref="System.Char"/>
		/// </param>
		/// <returns>
		/// Array of strings.
		/// A <see cref="System.String"/>
		/// </returns>
		private string[] SplitString(string inStr, char[] seperators) {
			PrintDebugMessage("SplitString", "Begin", 11);
			string[] retVal = inStr.Split(seperators);
			PrintDebugMessage("SplitString", "End", 11);
			return retVal;
		}

		/// <summary>
		/// Split a string using newline, tab, space, plus, comma and semicolon as seperators.
		/// </summary>
		/// <param name="inStr">
		/// String to split.
		/// A <see cref="System.String"/>
		/// </param>
		/// <returns>
		/// Array of strings.
		/// A <see cref="System.String"/>
		/// </returns>
		private string[] SplitString(string inStr) {
			PrintDebugMessage("SplitString", "Begin", 11);
			char[] sepList = {'\n', '\t', ' ', '+', ',', ';'};
			string[] retVal = SplitString(inStr, sepList);
			PrintDebugMessage("SplitString", "End", 11);
			return retVal;
		}

		/// <summary>
		/// Print an array of an array of strings, as a list or a table.
		/// </summary>
		/// <param name="arrayList">
		/// Array of array of strings to print.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="table">
		/// Flag indicating if this is to be output as a table or a list.
		/// A <see cref="System.Boolean"/>
		/// </param>
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

		/// <summary>
		/// Print an array of strings as a list.
		/// </summary>
		/// <param name="strList">
		/// Array of string to print.
		/// A <see cref="System.String"/>
		/// </param>
		private void PrintStrList(string[] strList) {
			foreach (string item in strList) {
				if (item != null && item != "") {
					Console.WriteLine(item);
				}
			}
		}
	}
}
