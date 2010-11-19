/* $Id$
 * ======================================================================
 * WSDbfetch web services C# client.
 *
 * See:
 * http://www.ebi.ac.uk/Tools/webservices/services/dbfetch
 * http://www.ebi.ac.uk/Tools/webservices/tutorials/csharp
 * ====================================================================== */
using System;
using System.IO;
using System.Reflection;
using System.Text;
using EbiWS.WSDbfetchWs;

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
					SrvProxy = new WSDBFetchDoclitServerService();
				}
				else {
					SrvProxy = new WSDBFetchDoclitServerService();
					SrvProxy.Url = ServiceEndPoint;
				}
				ServiceEndPoint = SrvProxy.Url;
				PrintDebugMessage("ServiceProxyConnect", "ServiceEndPoint: " + ServiceEndPoint, 12);
				PrintDebugMessage("ServiceProxyConnect", "SrvProxy: " + SrvProxy, 12);
				SetProxyUserAgent(); // Set user-agent for client.
			}
			PrintDebugMessage("ServiceProxyConnect", "End", 11);
		}

		// Set User-agent for web service proxy.
		private void SetProxyUserAgent() {
			PrintDebugMessage("SetProxyUserAgent", "Begin", 11);
			String clientVersion = revision.Substring(11, (revision.Length - 13));
			String userAgent = "EBI-Sample-Client/" + clientVersion + " (" + this.GetType().Name + "; " + System.Environment.OSVersion.ToString();
			if(SrvProxy.UserAgent.Contains("(")) { // MS .NET
				userAgent += ") " + SrvProxy.UserAgent;
			}
			else { // Mono
				userAgent += "; " + SrvProxy.UserAgent + ")";
			}
			PrintDebugMessage("SetProxyUserAgent", "userAgent: " + userAgent, 12);
			SrvProxy.UserAgent = userAgent;
			PrintDebugMessage("SetProxyUserAgent", "End", 11);
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
			string result = FetchData(query, formatName, styleName);
			Console.WriteLine(result);
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
			string result = FetchBatch(dbName, idListStr, formatName, styleName);
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
