/* $Id$
 * ======================================================================
 * 
 * Copyright 2010-2018 EMBL - European Bioinformatics Institute
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
 * WSDbfetch web services C# client.
 *
 * See:
 * http://www.ebi.ac.uk/Tools/webservices/services/dbfetch
 * http://www.ebi.ac.uk/Tools/webservices/tutorials/csharp
 * ====================================================================== */
using System;
using System.Collections.Generic;
using System.IO;
using System.Reflection;
using System.Text;
using EbiWS.WSDbfetchWs; // "Web Reference" or wsdl.exe generated stubs.

namespace EbiWS {
	/// <summary>WSDbfetch web services C# client.</summary>
	public class WSDbfetchClient {
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
		public WSDBFetchDoclitServerService SrvProxy
		{
			get { return srvProxy; }
			set { srvProxy = value; }
		}
		private WSDBFetchDoclitServerService srvProxy = null;
		// Client object revision.
		private string revision = "$Revision$";
		
		/// <summary>
		/// Default constructor.
		/// </summary>
		public WSDbfetchClient()
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
					strBuilder.Append("\n");
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
					strBuilder.Append("\n");
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
				SrvProxy = new WSDBFetchDoclitServerService();
				SetProxyEndPoint(); // Set explicit service endpoint, if defined.
				SetProxyUserAgent(); // Set user-agent for client.
				// Enable HTTP response compression (MS .NET 2.0 or Mono 2.4.1 onward).
				SrvProxy.EnableDecompression = true;
			}
			PrintDebugMessage("ServiceProxyConnect", "SrvProxy: " + SrvProxy.ToString(), 12);
			PrintDebugMessage("ServiceProxyConnect", "End", 11);
		}

		// Set service proxy endpoint.
		private void SetProxyEndPoint() {
			PrintDebugMessage("SetProxyEndPoint", "Begin", 11);
			if(ServiceEndPoint != null && ServiceEndPoint.Length > 0) {
				// For .NET discovery document.
				if(ServiceEndPoint.EndsWith("?DISCO") || ServiceEndPoint.EndsWith(".disco")) {
					SrvProxy.Url = ServiceEndPoint;
					SrvProxy.Discover();
				}
				// Sepecification of a service endpoint.
				else {
					SrvProxy.Url = ServiceEndPoint;
				}
			}
			ServiceEndPoint = SrvProxy.Url;
			PrintDebugMessage("SetProxyEndPoint", "Service endpoint: " + SrvProxy.Url, 12);
			PrintDebugMessage("SetProxyEndPoint", "End", 11);
		}

		// Set User-agent for web service proxy.
		private void SetProxyUserAgent() {
			PrintDebugMessage("SetProxyUserAgent", "Begin", 11);
			String userAgent = ConstuctUserAgentStr(revision, this.GetType().Name, SrvProxy.UserAgent);
			PrintDebugMessage("SetProxyUserAgent", "userAgent: " + userAgent, 12);
			SrvProxy.UserAgent = userAgent;
			PrintDebugMessage("SetProxyUserAgent", "End", 11);
		}
		
		// Construct a User-agent string for the client. See RFC2616 for details of HTTP user-agent strings.
		private string ConstuctUserAgentStr(string revision, string clientClassName, string userAgent) {
			PrintDebugMessage("constuctUserAgentStr", "Begin", 31);
			string retUserAgent = "EBI-Sample-Client";
			string clientVersion = "0";
			// Client version.
			if(revision != null && revision.Length > 0) {
				// CVS/Subversion revision tag.
				if(revision.StartsWith("$") && revision.EndsWith("$")) {
					// Populated tag, extract revision number.
					if(revision.Length > 13) {
						clientVersion = revision.Substring(11, (revision.Length - 13));
					}
				}
				// Alternative revision/version string.
				else {
					clientVersion = revision;
				}
			}
			// Agent name and version.
			StringBuilder strBuilder = new StringBuilder();
			strBuilder.Append(retUserAgent + "/" + clientVersion);
			// Agent comment (additional information).
			strBuilder.Append(" (");
			if(clientClassName != null && clientClassName.Length > 0) {
				// Provided class/client name.
				strBuilder.Append(clientClassName + "; ");
			}
			else {
				// Use current class name.
				strBuilder.Append(this.GetType().Name + "; ");
			}
			strBuilder.Append("C#; " + Environment.OSVersion.ToString());
			if(userAgent == null || userAgent.Length < 1) { // No previous agent.
				strBuilder.Append(")");
			}
			else if(userAgent.StartsWith("Mono ")) { // Mono agent.
				// Malformed so add to comments.
				strBuilder.Append("; " + userAgent + ")");
			}
			else { // MS .NET or other user-agent.
				// Append after comments.
				strBuilder.Append(") " + userAgent);
			}
			retUserAgent = strBuilder.ToString();
			PrintDebugMessage("constuctUserAgentStr", "retUserAgent: " + retUserAgent, 32);
			PrintDebugMessage("constuctUserAgentStr", "End", 31);
			return retUserAgent;
		}
		
		/// <summary>
		/// Get list of database names from sevice.
		/// </summary>
		/// <returns>An array of database names.
		/// A <see cref="System.String"/>
		/// </returns>
		public string[] GetSupportedDBs()
		{
			PrintDebugMessage("GetSupportedDBs", "Begin", 1);
			ServiceProxyConnect();
			string[] dbNameList = SrvProxy.getSupportedDBs();
			PrintDebugMessage("GetSupportedDBs", "got " + dbNameList.Length + " db names", 2);
			PrintDebugMessage("GetSupportedDBs", "End", 1);
			return dbNameList;
		}
		
		/// <summary>
		/// Print list of available search databases.
		/// </summary>
		public void PrintGetSupportedDBs() {
			PrintDebugMessage("PrintGetSupportedDBs", "Begin", 1);
			string[] result = GetSupportedDBs();
			PrintStrList(result);
			PrintDebugMessage("PrintGetSupportedDBs", "End", 1);
		}
		
		/// <summary>
		/// Get list of database and format names from sevice.
		/// </summary>
		/// <returns>An array of database and format names.
		/// A <see cref="System.String"/>
		/// </returns>
		public string[] GetSupportedFormats()
		{
			PrintDebugMessage("GetSupportedFormats", "Begin", 1);
			ServiceProxyConnect();
			string[] nameList = SrvProxy.getSupportedFormats();
			PrintDebugMessage("GetSupportedFormats", "got " + nameList.Length + " names", 2);
			PrintDebugMessage("GetSupportedFormats", "End", 1);
			return nameList;
		}
		
		/// <summary>
		/// Print list of available search databases and formats.
		/// </summary>
		public void PrintGetSupportedFormats() {
			PrintDebugMessage("PrintGetSupportedFormats", "Begin", 1);
			string[] result = GetSupportedFormats();
			PrintStrList(result);
			PrintDebugMessage("PrintGetSupportedFormats", "End", 1);
		}
		
		/// <summary>
		/// Get list of database and style names from sevice.
		/// </summary>
		/// <returns>An array of database and style names.
		/// A <see cref="System.String"/>
		/// </returns>
		public string[] GetSupportedStyles()
		{
			PrintDebugMessage("GetSupportedStyles", "Begin", 1);
			ServiceProxyConnect();
			string[] nameList = SrvProxy.getSupportedStyles();
			PrintDebugMessage("GetSupportedStyles", "got " + nameList.Length + " names", 2);
			return nameList;
		}
		
		/// <summary>
		/// Print list of available search databases and styles.
		/// </summary>
		public void PrintGetSupportedStyles() {
			PrintDebugMessage("PrintGetSupportedStyles", "Begin", 1);
			string[] result = GetSupportedStyles();
			PrintStrList(result);
			PrintDebugMessage("PrintGetSupportedStyles", "End", 1);
		}
		
		/// <summary>
		/// Get detailed information about a database.
		/// </summary>
		/// <param name="dbName">Database name.
		/// A <see cref="System.String"/>
		/// </param>
		/// <returns>
		/// A <see cref="DatabaseInfo"/>
		/// </returns>
		public DatabaseInfo GetDatabaseInfo(string dbName) {
			PrintDebugMessage("GetDatabaseInfo", "Begin", 1);
			ServiceProxyConnect();
			DatabaseInfo result = SrvProxy.getDatabaseInfo(dbName);
			PrintDebugMessage("GetDatabaseInfo", this.ObjectValueToString(result), 11);
			PrintDebugMessage("GetDatabaseInfo", "End", 1);
			return result;
		}
		
		/// <summary>
		/// Output details of a database.
		/// </summary>
		/// <param name="dbName">
		/// Database name.
		/// A <see cref="System.String"/>
		/// </param>
		public void PrintGetDatabaseInfo(string dbName) {
			PrintDebugMessage("PrintGetDatabaseInfo", "Begin", 1);
			DatabaseInfo dbInfo = GetDatabaseInfo(dbName);
			PrintDatabaseInfo(dbInfo);
			PrintDebugMessage("PrintGetDatabaseInfo", "End", 1);
		}
		
		/// <summary>
		/// Output detailed information about a database. Used in 
		/// PrintGetDatabaseInfo and PrintGetDatabaseInfoList.
		/// </summary>
		/// <param name="dbInfo">
		/// Database information.
		/// A <see cref="DatabaseInfo"/>
		/// </param>
		protected void PrintDatabaseInfo(DatabaseInfo dbInfo) {
			PrintDebugMessage("PrintDatabaseInfo", "Begin", 11);
			// TODO: specific output for DatabaseInfo.
			Console.WriteLine(this.ObjectValueToString(dbInfo));
			PrintDebugMessage("PrintDatabaseInfo", "End", 11);
		}
		
		/// <summary>
		/// Get detailed information about the available databases.
		/// </summary>
		/// <returns>
		/// A <see cref="DatabaseInfo[]"/>
		/// </returns>
		public DatabaseInfo[] GetDatabaseInfoList() {
			PrintDebugMessage("GetDatabaseInfoList", "Begin", 1);
			ServiceProxyConnect();
			DatabaseInfo[] result = SrvProxy.getDatabaseInfoList();
			PrintDebugMessage("GetDatabaseInfoList", this.ObjectValueToString(result), 11);
			PrintDebugMessage("GetDatabaseInfoList", "End", 1);
			return result;
		}
		
		/// <summary>
		/// Output detailed information about the available databases.
		/// </summary>
		public void PrintGetDatabaseInfoList() {
			PrintDebugMessage("PrintGetDatabaseInfoList", "Begin", 1);
			DatabaseInfo[] dbInfoList = GetDatabaseInfoList();
			foreach(DatabaseInfo dbInfo in dbInfoList) {
				PrintDatabaseInfo(dbInfo);
			}
			PrintDebugMessage("PrintGetDatabaseInfoList", "End", 1);
		}
		
		/// <summary>
		/// Get list of format names for a database.
		/// </summary>
		/// <param name="dbName">
		/// Database name.
		/// A <see cref="System.String"/>
		/// </param>
		/// <returns>An array of format names.
		/// A <see cref="System.String"/>
		/// </returns>
		public string[] GetDbFormats(string dbName)
		{
			PrintDebugMessage("GetDbFormats", "Begin", 1);
			ServiceProxyConnect();
			string[] nameList = SrvProxy.getDbFormats(dbName);
			PrintDebugMessage("GetDbFormats", "got " + nameList.Length + " names", 2);
			PrintDebugMessage("GetDbFormats", "End", 1);
			return nameList;
		}
		
		/// <summary>
		/// Print list of available format names for a database.
		/// </summary>
		/// <param name="dbName">
		/// Database name.
		/// A <see cref="System.String"/>
		/// </param>
		public void PrintGetDbFormats(string dbName) {
			PrintDebugMessage("PrintGetDbFormats", "Begin", 1);
			string[] result = GetDbFormats(dbName);
			PrintStrList(result);
			PrintDebugMessage("PrintGetDbFormats", "End", 1);
		}
		
		/// <summary>
		/// Get list of style names for a format of a database.
		/// </summary>
		/// <param name="dbName">
		/// Database name.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="formatName">
		/// Data format name.
		/// A <see cref="System.String"/>
		/// </param>
		/// <returns>An array of style names.
		/// A <see cref="System.String"/>
		/// </returns>
		public string[] GetFormatStyles(string dbName, string formatName)
		{
			PrintDebugMessage("GetFormatStyles", "Begin", 1);
			ServiceProxyConnect();
			string[] nameList = SrvProxy.getFormatStyles(dbName, formatName);
			PrintDebugMessage("GetFormatStyles", "got " + nameList.Length + " names", 2);
			PrintDebugMessage("GetFormatStyles", "End", 1);
			return nameList;
		}
		
		/// <summary>
		/// Print list of available style names for a format of a database.
		/// </summary>
		/// <param name="dbName">
		/// Database name.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="formatName">
		/// Data format name.
		/// A <see cref="System.String"/>
		/// </param>
		public void PrintGetFormatStyles(string dbName, string formatName) {
			PrintDebugMessage("PrintGetFormatStyles", "Begin", 1);
			string[] result = GetFormatStyles(dbName, formatName);
			PrintStrList(result);
			PrintDebugMessage("PrintGetFormatStyles", "End", 1);
		}
		
		/// <summary>
		/// Fetch an entry.
		/// </summary>
		/// <param name="query">
		/// Entry identifier in DB:ID format.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="formatName">
		/// Data format name.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="styleName">
		/// Result style name.
		/// A <see cref="System.String"/>
		/// </param>
		/// <returns>Entry data.
		/// A <see cref="System.String"/>
		/// </returns>
		public string FetchData(string query, string formatName, string styleName)
		{
			PrintDebugMessage("FetchData", "Begin", 1);
			ServiceProxyConnect();
			string entryStr = SrvProxy.fetchData(query, formatName, styleName);
			PrintDebugMessage("FetchData", "End", 1);
			return entryStr;
		}
		
		/// <summary>
		/// Fetch database entries on-by-one using identifiers, in DB:ID 
		/// format, read from a file or STDIN. Unlike FetchBatch this 
		/// ensures that the order of the entries returned is the same as 
		/// the order of the identifiers, but at the cost of making 
		/// multiple requests and thus is slower that FetchBatch.
		/// </summary>
		/// <param name="fileName">
		/// Name of the file containing the identifiers to fetch. If the file 
		/// name is '-' then identifers are read from STDIN, If the file name
		/// begins with an '@' it is removed before the file is opened.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="formatName">
		/// Data format name to use for fetched data.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="styleName">
		/// Result style to use for fetched data.
		/// A <see cref="System.String"/>
		/// </param>
		/// <returns>
		/// An array of fetched entry data.
		/// A <see cref="System.String[]"/>
		/// </returns>
		public string[] FetchFileData(string fileName, string formatName, string styleName) {
			PrintDebugMessage("FetchFileData", "Begin", 1);
			// Trim '@' from start of file name, if present.
			if(fileName.StartsWith("@")) fileName = fileName.Substring(1);
			// Open file.
			TextReader inFile = null;
			if(fileName.Equals("-")) { // STDIN.
				inFile = Console.In;
			}
			else { // Data file.
				inFile = new StreamReader(fileName);
			}
			// Identifier per line, so read each line, trim, fetch the entry and add to the list.
			List<string> resultList = new List<string>();
			string line = null;
			while((line = inFile.ReadLine()) != null) {
				PrintDebugMessage("FetchFileData", line, 21);
				if(line.Contains(":") && line.Length > 3) {
					string query = line.Trim();
					PrintDebugMessage("FetchFileData", "query: " + query, 2);
					resultList.Add(FetchData(query, formatName, styleName));
				}
			}
			// Close the file.
			if(inFile != null && inFile != Console.In) {
				inFile.Close();
			}
			PrintDebugMessage("FetchFileData", "End", 1);
			return resultList.ToArray();
		}
		
		/// <summary>
		/// Print an entry.
		/// </summary>
		/// <param name="query">
		/// Entry identifier in DB:ID format.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="formatName">
		/// Data format name.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="styleName">
		/// Result style name.
		/// A <see cref="System.String"/>
		/// </param>
		public void PrintFetchData(string query, string formatName, string styleName) {
			PrintDebugMessage("PrintFetchData", "Begin", 1);
			// Get identifers from STDIN or file.
			if(query.Equals("-") || query.StartsWith("@")) {
				string[] resultList = FetchFileData(query, formatName, styleName);
				PrintStrList(resultList);
			}
			// Supplied identifier.
			else {
				string result = FetchData(query, formatName, styleName);
				Console.WriteLine(result);
			}
			PrintDebugMessage("PrintFetchData", "End", 1);
		}
		
		/// <summary>
		/// Fetch a set of entries.
		/// </summary>
		/// <param name="dbName">
		/// Database name.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="idListStr">
		/// Comma or space separated list of entry identifiers.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="formatName">
		/// Data format name.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="styleName">
		/// Result style name.
		/// A <see cref="System.String"/>
		/// </param>
		/// <returns>Entries data.
		/// A <see cref="System.String"/>
		/// </returns>
		public string FetchBatch(string dbName, string idListStr, string formatName, string styleName)
		{
			PrintDebugMessage("FetchBatch", "Begin", 1);
			ServiceProxyConnect();
			string entriesStr = SrvProxy.fetchBatch(dbName, idListStr, formatName, styleName);
			PrintDebugMessage("FetchBatch", "End", 1);
			return entriesStr;
		}
		
		/// <summary>
		/// Read a list of identifers from a file or STDIN. Used in 
		/// PrintFetchBatch.
		/// </summary>
		/// <param name="fileName">
		/// Name of the file to read from. If '-' STDIN is used. An initial 
		/// '@' is trimed before opening the file.
		/// A <see cref="System.String"/>
		/// </param>
		/// <returns>
		/// Comma separated list of identifers.
		/// A <see cref="System.String"/>
		/// </returns>
		public string GetIdentifierListFromFile(string fileName) {
			PrintDebugMessage("GetIdentifierListFromFile", "Begin", 11);
			string retVal = null;
			// Trim '@' from start of file name, if present.
			if(fileName.StartsWith("@")) fileName = fileName.Substring(1);
			// Open file.
			TextReader inFile = null;
			if(fileName.Equals("-")) { // STDIN.
				inFile = Console.In;
			}
			else { // Data file.
				inFile = new StreamReader(fileName);
			}
			// Identifier per line, so read each line, trim and add to Id list.
			StringBuilder strBuf = new StringBuilder();
			string line = null;
			while((line = inFile.ReadLine()) != null) {
				PrintDebugMessage("GetIdentifierListFromFile", line, 21);
				line = line.Trim();
				if(line.Length > 0) {
					if(strBuf.Length > 0) strBuf.Append(",");
					strBuf.Append(line);
				}
			}
			// Close the file.
			if(inFile != null && inFile != Console.In) {
				inFile.Close();
			}
			retVal = strBuf.ToString();
			PrintDebugMessage("GetIdentifierListFromFile", "retVal: " + retVal, 12);
			PrintDebugMessage("GetIdentifierListFromFile", "End", 11);
			return retVal;
		}
		
		/// <summary>
		/// Print a set of entries.
		/// </summary>
		/// <param name="dbName">
		/// Database name.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="idListStr">
		/// Comma or space separated list of entry identifiers.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="formatName">
		/// Data format name.
		/// A <see cref="System.String"/>
		/// </param>
		/// <param name="styleName">
		/// Result style name.
		/// A <see cref="System.String"/>
		/// </param>
		public void PrintFetchBatch(string dbName, string idListStr, string formatName, string styleName) {
			PrintDebugMessage("PrintFetchBatch", "Begin", 1);
			string fetchIdListStr = null;
			// Identifier list from STDIN or file.
			if(idListStr.Equals("-") || idListStr.StartsWith("@")) {
				fetchIdListStr = GetIdentifierListFromFile(idListStr);
			}
			// Supplied identifier list.
			else {
				fetchIdListStr = idListStr;
			}
			string result = FetchBatch(dbName, fetchIdListStr, formatName, styleName);
			Console.WriteLine(result);
			PrintDebugMessage("PrintFetchBatch", "End", 1);
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
