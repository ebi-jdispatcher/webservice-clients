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
		/// <value>
		/// Action to perform
		/// </value>
		public string Action {
			get{return action;}
			set{action = value;}
		}
		private string action = "unknown";
		
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

		// Print domain information used by getDomainsHierarchy
		private void PrintDomains(DomainDescription domain, string pad) {
			PrintDebugMessage("PrintDomains", "Begin", 1);
			foreach (DomainDescription subdomain in domain.subDomains) {
				Console.WriteLine(pad+"domainId:"+subdomain.id);
				Console.WriteLine(pad+"domainName:"+subdomain.name);
				Console.WriteLine(pad+"domainDescription:"+subdomain.description);
				if (subdomain.subDomains != null && subdomain.subDomains.Length > 0) {
					PrintDomains(subdomain, pad+"\t");
				}
			}
			PrintDebugMessage("PrintDomains", "End", 1);
		}

		// Print the domain results used by getDetailedNumberOfResults
		private void PrintDomainResults(DomainResult domain, string pad) {
			PrintDebugMessage("PrintDomainResults", "Begin", 1);
			foreach (DomainResult subdomain in domain.subDomainsResults) {
				Console.WriteLine(pad + "domainId:" + subdomain.domainId);
				Console.WriteLine(pad + "domainResults:" + subdomain.numberOfResults);
				if (subdomain.subDomainsResults != null && subdomain.subDomainsResults.Length > 0)
				{
					PrintDomainResults(subdomain, pad + "\t");
				}
			}
			PrintDebugMessage("PrintDomainResults", "End", 1);
		}

		// Print reference sets used by getReferenceEntriesSet
		private void PrintArrayOfStringList(String[][] arrayList) {
			PrintDebugMessage("PrintArrayOfStringList", "Begin", 1);
			for(int i = 0; i < arrayList.Length; i++) {
				String[] strList = arrayList[i];
				for(int j = 0; j < strList.Length; j++) {
					if(j > 0) {
						Console.Write("\t");
					}
					Console.Write(strList[j]);
				}
				Console.WriteLine("");
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
