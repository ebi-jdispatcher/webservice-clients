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
 * WSDbfetch web service Java client using Axis 1.x.
 * ----------------------------------------------------------------------
 * Tested with:
 *   Sun Java 1.5.0_17 with Apache Axis 1.4 on CentOS 5.2.
 * ====================================================================== */
package uk.ac.ebi.webservices.axis1;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.rmi.RemoteException;

import javax.xml.rpc.ServiceException;

import javax.xml.rpc.Call;
import org.apache.axis.transport.http.HTTPConstants;
import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.GnuParser;
import org.apache.commons.cli.Options;
import uk.ac.ebi.webservices.axis1.stubs.wsdbfetch.*;

/** <p>WSDbfetch document/literal SOAP web service Java client using Apache Axis 1.x.</p>
 * 
 * <p>See:</p>
 * <ul>
 * <li><a href="http://www.ebi.ac.uk/Tools/webservices/services/dbfetch">http://www.ebi.ac.uk/Tools/webservices/services/dbfetch</a></li>
 * <li><a href="http://www.ebi.ac.uk/Tools/webservices/tutorials/06_programming/java">http://www.ebi.ac.uk/Tools/webservices/tutorials/06_programming/java</a></li>
 * <li><a href="http://ws.apache.org/axis/">http://ws.apache.org/axis/</a></li>
 * </ul>
 */
public class WSDbfetchClient {
	/** Output level. Controlled by the --verbose and --quiet options. */
	protected int outputLevel = 1;
	/** Debug level. Controlled by the --debugLevel option. */
	private int debugLevel = 0;
	/** URL for service endpoint. */
	private String serviceEndPoint = null;
	/** Service proxy */
	private WSDBFetchServer srvProxy = null;
	/** Chunk size to use when fetching multiple entries with fetchBatch. */
	private int fetchChunkSize = 100;
	/** Client version/revision */
	private String revision = "$Revision$";
	/** Usage message */
	private static final String usageMsg = "WSDbfetch\n"
		+ "=========\n"
		+ "\n"
		+ "Usage: java -jar WSDbfetch.jar [options...] <method> [arguments...]\n"
		+ "\n"
		+ "Options\n"
		+ "-------\n"
		+ "\n"
		+ "  -h, --help            Help/usage message.\n"
		//+ "  -q, --quiet           Decrease output messages.\n"
		//+ "  -v, --verbose         Increase output messages.\n"
		+ "  --debugLevel <level>  Set debug output level.\n"
		+ "  --endpoint <endpoint> Override service endpoint used.\n"
		+ "\n"
		+ "Methods\n"
		+ "-------\n"
		+ "\n"
		+ "A number of methods are available:\n"
		+ "\n"
		+ "  getSupportedDBs       - list available databases\n"
		+ "  getSupportedFormats   - list available databases with formats\n"
		+ "  getSupportedStyles    - list available databases with styles\n"
		+ "  getDbFormats <db>     - list formats for a specifed database\n"
		+ "  getFormatStyles <db> <format>\n"
		+ "    - list styles for a specified database and format\n"
		+ "  fetchData <query> <format> <style>\n"
		+ "    - retrive an database entry. See below for details of arguments.\n"
		+ "  fetchBatch <db> <idList> <format> <style>\n"
		+ "    - retrive database entries. See below for details of arguments.\n"
		+ "\n"
		+ "Fetching an entry: fetchData\n"
		+ "\n"
		+ "  java -jar WSDbfetch.jar fetchData <dbName:id> [format [style]]\n"
		+ "\n"
		+ "  dbName:id  database name and entry ID or accession (e.g. UNIPROT:WAP_RAT)\n"
		+ "  format     format to retrive (e.g. uniprot)\n"
		+ "  style      style to retrive (e.g. raw)\n"
		+ "\n"
		+ "Fetching entries: fetchBatch\n"
		+ "\n"
		+ "  java -jar WSDbfetch.jar fetchBatch <dbName> <idList> [format [style]]\n"
		+ "\n"
		+ "  dbName     database name (e.g. UNIPROT)\n"
		+ "  idList     list of entry IDs or accessions (e.g. 1433T_RAT,WAP_RAT).\n"
		+ "             Maximum of 200 IDs or accessions.\n"
		+ "  format     format to retrive (e.g. uniprot)\n"
		+ "  style      style to retrive (e.g. raw)\n"
		+ "\n"
		+ "Further Information\n"
		+ "-------------------\n"
		+ "\n"
		+ "  http://www.ebi.ac.uk/Tools/webservices/services/dbfetch\n"
		+ "  http://www.ebi.ac.uk/Tools/webservices/tutorials/java\n"
		+ "\n"
		+ "Support/Feedback\n"
		+ "----------------\n"
		+ "\n"
		+ "  http://www.ebi.ac.uk/support/\n" 
		+ "\n";

	/** Default constructor.
	 */
	public WSDbfetchClient() {
		// Set the HTTP user agent string for (java.net) requests.
		this.setUserAgent();
	}

	/** <p>Set the HTTP User-agent header string for the client.</p>
	 * 
	 * <p><b>Note</b>: this affects all java.net based requests, but not the 
	 * Axis requests. The user-agent used by Axis is set from the 
	 * /org/apache/axis/i18n/resource.properties file included in the JAR.</p>
	 */
	private void setUserAgent() {
		printDebugMessage("setUserAgent", "Begin", 1);
		// Java web calls use the http.agent property as a prefix to the default user-agent.
		String clientVersion = this.revision.substring(11, this.revision.length() - 2);
		String clientUserAgent = "EBI-Sample-Client/" + clientVersion + " (" + this.getClass().getName() + "; " + System.getProperty("os.name") +")";
		if(System.getProperty("http.agent") != null) {
			System.setProperty("http.agent", clientUserAgent + " " + System.getProperty("http.agent"));
		}
		else System.setProperty("http.agent", clientUserAgent);
		printDebugMessage("setUserAgent", "End", 1);
	}

	/** Print the usage message to STDOUT.
	 */
	private static void printUsage() {
		System.out.print(usageMsg);
	}

	/** Set debug level.
	 * 
	 * @param level Debug level. 0 = off.
	 */
	public void setDebugLevel(int level) {
		printDebugMessage("setDebugLevel", "Begin " + level, 1);
		if (level > -1) {
			debugLevel = level;
		}
		printDebugMessage("setDebugLevel", "End", 1);
	}

	/** Get current debug level.
	 * 
	 * @return Debug level.
	 */
	public int getDebugLevel() {
		printDebugMessage("getDebugLevel", new Integer(debugLevel).toString(),
				1);
		return debugLevel;
	}

	/** Output debug message at specified level
	 * 
	 * @param methodName Name of the method to appear in the message
	 * @param message The message
	 * @param level Level at which to output message
	 */
	protected void printDebugMessage(String methodName, String message,	int level) {
		if (level <= debugLevel) {
			System.err.println("[" + methodName + "()] " + message);
		}
	}

	/** Set the output level.
	 * 
	 * @param level Output level. 0 = quiet, 1 = normal and 2 = verbose.
	 */
	public void setOutputLevel(int level) {
		printDebugMessage("setOutputLevel", "Begin " + level, 1);
		if (level > -1) {
			this.outputLevel = level;
		}
		printDebugMessage("setOutputLevel", "End", 1);
	}

	/** Get the current output level.
	 * 
	 * @return Output level.
	 */
	public int getOutputLevel() {
		printDebugMessage("getOutputLevel", new Integer(this.outputLevel).toString(), 1);
		return this.outputLevel;
	}

	/** Set the service endpoint URL for generating the service connection.
	 * 
	 * @param urlStr Service endpoint URL as a string.
	 */
	public void setServiceEndPoint(String urlStr) {
		printDebugMessage("setServiceEndpoint", "urlStr: " + urlStr, 1);
		this.serviceEndPoint = urlStr;
	}

	/** Get the current service endpoint URL.
	 * 
	 * @return The service endpoint URL as a string.
	 */
	public String getServiceEndPoint() {
		printDebugMessage("getServiceEndpoint", "serviceEndPoint: "	+ this.serviceEndPoint, 1);
		return this.serviceEndPoint;
	}

	/** Print a progress message.
	 * 
	 * @param msg The message to print.
	 * @param level The output level at or above which this message should be displayed.
	 */
	protected void printProgressMessage(String msg, int level) {
		if (outputLevel >= level) {
			System.err.println(msg);
		}
	}

	/** Ensure that a service proxy is available to call the web service.
	 * 
	 * @throws ServiceException
	 */
	protected void srvProxyConnect() throws ServiceException {
		printDebugMessage("srvProxyConnect", "Begin", 2);
		if(this.srvProxy == null) {
			WSDBFetchDoclitServerService service = new WSDBFetchDoclitServerServiceLocatorExtended();
			if(this.getServiceEndPoint() != null) {
				try {
					this.srvProxy = service.getWSDbfetchDoclit(new java.net.URL(this.getServiceEndPoint()));
				}
				catch(java.net.MalformedURLException ex) {
					System.err.println(ex.getMessage());
					System.err.println("Warning: problem with specified endpoint URL. Default endpoint used.");
					this.srvProxy = service.getWSDbfetchDoclit();
				}
			}
			else {
				this.srvProxy = service.getWSDbfetchDoclit();
			}
		}
		printDebugMessage("srvProxyConnect", "End", 2);
	}
	
	/** Wrapper for WSDBFetchDoclitServerServiceLocator to enable HTTP 
	 * compression.
 	 * 
	 * Compression requires Commons HttpClient and a client-config.wsdd which 
	 * specifies that Commons HttpClient should be used as the HTTP transport.
	 * See http://wiki.apache.org/ws/FrontPage/Axis/GzipCompression.
	 */
	private class WSDBFetchDoclitServerServiceLocatorExtended extends WSDBFetchDoclitServerServiceLocator {
		private static final long serialVersionUID = 1L;

		public Call createCall() throws ServiceException {
			Call call = super.createCall();
			// Enable response compression.
			call.setProperty(HTTPConstants.MC_ACCEPT_GZIP, Boolean.TRUE);
			// Enable request compression (requires service support)
			call.setProperty(HTTPConstants.MC_GZIP_REQUEST, Boolean.TRUE);
			return call;
		}
	}

	/** Get the web service proxy.
	 * 
	 * @return The web service proxy.
	 * @throws javax.xml.rpc.ServiceException
	 */
	public WSDBFetchServer getSrvProxy() throws javax.xml.rpc.ServiceException {
		printDebugMessage("getSrvProxy", "Begin", 2);
		this.srvProxyConnect(); // Ensure the service proxy exists
		printDebugMessage("getSrvProxy", "End", 2);
		return this.srvProxy;
	}

	/** Print an array of strings to STDOUT.
	 * 
	 * @param strList Array of strings to print.
	 */
	private void printStrList(String[] strList) {
		printDebugMessage("printStrList", "Begin", 1);
		for (int i = 0; i < strList.length; i++) {
			System.out.println(strList[i]);
		}
		printDebugMessage("printStrList", "End", 1);
	}

	/** Get a list of supported domain names.
	 * 
	 * @return an array of domain names
	 * @throws java.rmi.RemoteException
	 * @throws javax.xml.rpc.ServiceException
	 */
	public String[] getSupportedDBs() throws RemoteException, ServiceException {
		printDebugMessage("getSupportedDBs", "Begin", 1);
		String[] retVal = null;
		srvProxyConnect(); // Ensure we have a service proxy
		retVal = this.srvProxy.getSupportedDBs();
		printDebugMessage("getSupportedDBs", "End", 1);
		return retVal;
	}

	/** Print list of supported domain names to STDOUT.
	 * 
	 * @throws java.rmi.RemoteException
	 * @throws javax.xml.rpc.ServiceException
	 */
	public void printGetSupportedDBs() throws RemoteException,	ServiceException {
		printDebugMessage("printGetSupportedDBs", "Begin", 1);
		printStrList(getSupportedDBs());
		printDebugMessage("printGetSupportedDBs", "End", 1);
	}

	/** Get list of supported formats and databases.
	 * 
	 * @return Array of database and format names.
	 * @throws ServiceException
	 * @throws RemoteException
	 */
	public String[] getSupportedFormats() throws ServiceException, RemoteException {
		printDebugMessage("getSupportedFormats", "Begin", 1);
		String[] retVal = null;
		srvProxyConnect(); // Ensure we have a service proxy
		retVal = this.srvProxy.getSupportedFormats();
		printDebugMessage("getSupportedFormats", "End", 1);
		return retVal;
	}
	
	/** Print list of supported formats and databases.
	 * 
	 * @throws RemoteException
	 * @throws ServiceException
	 */
	public void printGetSupportedFormats() throws RemoteException, ServiceException {
		printDebugMessage("printGetSupportedFormats", "Begin", 1);
		printStrList(getSupportedFormats());
		printDebugMessage("printGetSupportedFormats", "End", 1);
	}
	
	/** Get list of supported styles and databases.
	 * 
	 * @return
	 * @throws ServiceException
	 * @throws RemoteException
	 */
	public String[] getSupportedStyles() throws ServiceException, RemoteException {
		printDebugMessage("getSupportedStyles", "Begin", 1);
		String[] retVal = null;
		srvProxyConnect(); // Ensure we have a service proxy
		retVal = this.srvProxy.getSupportedStyles();
		printDebugMessage("getSupportedStyles", "End", 1);
		return retVal;
	}
	
	/** Print list of supported styles and databases.
	 * 
	 * @throws RemoteException
	 * @throws ServiceException
	 */
	public void printGetSupportedStyles() throws RemoteException, ServiceException {
		printDebugMessage("printGetSupportedStyles", "Begin", 1);
		printStrList(getSupportedStyles());
		printDebugMessage("printGetSupportedStyles", "End", 1);
	}
	
	/** Get list of data format names for a database.
	 * 
	 * @param dbName Database name.
	 * @return Array of data format names.
	 * @throws ServiceException
	 * @throws DbfParamsException
	 * @throws RemoteException
	 */
	public String[] getDbFormats(String dbName) throws ServiceException, DbfParamsException, RemoteException {
		printDebugMessage("getDbFormats", "Begin", 1);
		printDebugMessage("getDbFormats", "dbName: " + dbName, 2);
		String[] retVal = null;
		srvProxyConnect(); // Ensure we have a service proxy
		retVal = this.srvProxy.getDbFormats(dbName);
		printDebugMessage("getDbFormats", "End", 1);
		return retVal;
	}
	
	/** Print list of data format names for a database.
	 * 
	 * @param dbName Database name.
	 * @throws DbfParamsException
	 * @throws RemoteException
	 * @throws ServiceException
	 */
	public void printGetDbFormats(String dbName) throws DbfParamsException, RemoteException, ServiceException {
		printDebugMessage("printGetDbFormats", "Begin", 1);
		if(dbName == null || dbName.length() < 1) dbName = "default";
		printStrList(getDbFormats(dbName));
		printDebugMessage("printGetDbFormats", "End", 1);
	}
	
	/** Get list of result style names for a format of a database.
	 *  
	 * @param dbName Database name.
	 * @param formatName Data format name.
	 * @return Array of result style names.
	 * @throws DbfParamsException
	 * @throws RemoteException
	 * @throws ServiceException
	 */
	public String[] getFormatStyles(String dbName, String formatName) throws DbfParamsException, RemoteException, ServiceException {
		printDebugMessage("getFormatStyles", "Begin", 1);
		printDebugMessage("getFormatStyles", "dbName: " + dbName, 2);
		printDebugMessage("getFormatStyles", "formatName: " + formatName, 2);
		String[] retVal = null;
		srvProxyConnect(); // Ensure we have a service proxy
		retVal = this.srvProxy.getFormatStyles(dbName, formatName);
		printDebugMessage("getFormatStyles", "End", 1);
		return retVal;
	}
	
	/** Print list of styles for a format of a database.
	 * 
	 * @param dbName Database name.
	 * @param formatName Data format name.
	 * @throws DbfParamsException
	 * @throws RemoteException
	 * @throws ServiceException
	 */
	public void printGetFormatStyles(String dbName, String formatName) throws DbfParamsException, RemoteException, ServiceException {
		printDebugMessage("printGetFormatStyles", "Begin", 1);
		if(dbName == null || dbName.length() < 1) dbName = "default";
		if(formatName == null || formatName.length() < 1) formatName = "default";
		String[] formatNameArray = this.getFormatStyles(dbName, formatName);
		printStrList(formatNameArray);
		printDebugMessage("printGetFormatStyles", "End", 1);
	}
	
	/** Get an entry.
	 * 
	 * @param query Entry identifier in DB:ID format.
	 * @param formatName Data format name.
	 * @param styleName Result style name.
	 * @return Entry data.
	 * @throws ServiceException
	 * @throws DbfConnException
	 * @throws DbfNoEntryFoundException
	 * @throws DbfParamsException
	 * @throws DbfException
	 * @throws InputException
	 * @throws RemoteException
	 */
	public String fetchData(String query, String formatName, String styleName) throws ServiceException, DbfConnException, DbfNoEntryFoundException, DbfParamsException, DbfException, InputException, RemoteException {
		printDebugMessage("fetchData", "Begin", 1);
		printDebugMessage("fetchData", "query: " + query, 2);
		printDebugMessage("fetchData", "formatName: " + formatName, 2);
		printDebugMessage("fetchData", "styleName: " + styleName, 2);
		if(formatName == null || formatName.length() < 1) formatName = "default";
		if(styleName == null || styleName.length() < 1) styleName = "default";
		String retVal = null;
		srvProxyConnect(); // Ensure we have a service proxy
		retVal = this.srvProxy.fetchData(query, formatName, styleName);
		printDebugMessage("fetchData", "End", 1);
		return retVal;
	}
	
	/** Print an entry.
	 * 
	 * @param query Entry identifier in DB:ID format.
	 * @param formatName Data format name.
	 * @param styleName Result style name.
	 * @throws ServiceException
	 * @throws IOException 
	 */
	public void printFetchData(String query, String formatName, String styleName) throws ServiceException, IOException {
		printDebugMessage("printFetchData", "Begin", 1);
		// Direct query or file?
		if ( query.startsWith("@") || query.equals("-") ) {
			// List input from file or STDIN.
			BufferedReader inRead = readerFromFile(query);
			if(inRead != null) {
				String line = null;
				while((line = inRead.readLine()) != null) {
					String dbIdStr = line.trim();
					String entryStr = this.fetchData(dbIdStr, formatName, styleName);
					System.out.println(entryStr);
				}
				inRead.close();
			}
		}
		else {
			// Directly specified query.
			String entryStr = this.fetchData(query, formatName, styleName);
			System.out.println(entryStr);
		}
		printDebugMessage("printFetchData", "End", 1);
	}
	
	/** Fetch a set of entries.
	 * 
	 * @param dbName Database name.
	 * @param idListStr Comma or space separated list of entry identifiers.
	 * @param formatName Data format name.
	 * @param styleName Result style name.
	 * @return Entries.
	 * @throws ServiceException
	 * @throws DbfConnException
	 * @throws DbfNoEntryFoundException
	 * @throws DbfParamsException
	 * @throws DbfException
	 * @throws InputException
	 * @throws RemoteException
	 */
	public String fetchBatch(String dbName, String idListStr, String formatName, String styleName) throws ServiceException, DbfConnException, DbfNoEntryFoundException, DbfParamsException, DbfException, InputException, RemoteException {
		printDebugMessage("fetchBatch", "Begin", 1);
		printDebugMessage("fetchBatch", "dbName: " + dbName, 2);
		printDebugMessage("fetchBatch", "idListStr: " + idListStr, 2);
		printDebugMessage("fetchBatch", "formatName: " + formatName, 2);
		printDebugMessage("fetchBatch", "styleName: " + styleName, 2);
		String retVal = null;
		if(dbName == null || dbName.length() < 1) dbName = "default";
		if(formatName == null || formatName.length() < 1) formatName = "default";
		if(styleName == null || styleName.length() < 1) styleName = "default";
		srvProxyConnect(); // Ensure we have a service proxy
		retVal = this.srvProxy.fetchBatch(dbName, idListStr, formatName, styleName);
		printDebugMessage("fetchBatch", "End", 1);
		return retVal;
		
	}
	
	/** Print a set of entries.
	 * 
	 * @param dbName Database name.
	 * @param idListStr Comma or space separated list of entry identifiers.
	 * @param formatName Data format name.
	 * @param styleName Result style name.
	 * @throws ServiceException
	 * @throws IOException 
	 */
	public void printFetchBatch(String dbName, String idListStr, String formatName, String styleName) throws ServiceException, IOException {
		printDebugMessage("printFetchBatch", "Begin", 1);
		// Directly specified list or list file?
		if ( idListStr.startsWith("@") || idListStr.equals("-") ) {
			// List input from file or STDIN.
			BufferedReader inRead = readerFromFile(idListStr);
			if(inRead != null) {
				String line = null;
				StringBuffer idListStrBuf = new StringBuffer();
				int idNum = 0;
				while((line = inRead.readLine()) != null) {
					String idStr = line.trim();
					if(idNum > 0) idListStrBuf.append(",");
					idListStrBuf.append(idStr);
					idNum++;
					if(idNum >= fetchChunkSize) { // Chunk identifiers.
						String entryStr = this.fetchBatch(dbName, idListStrBuf.toString(), formatName, styleName);
						System.out.println(entryStr);
						idNum = 0;
						idListStrBuf = new StringBuffer();
					}
				}
				// Last chunk.
				if(idNum > 0) {
					String entryStr = this.fetchBatch(dbName, idListStrBuf.toString(), formatName, styleName);
					System.out.println(entryStr);
				}
				inRead.close();
			}
		}
		else {
			// Directly specified list.
			String entriesStr = this.fetchBatch(dbName, idListStr, formatName, styleName);
			System.out.println(entriesStr);
		}
		printDebugMessage("printFetchBatch", "End", 1);
	}
	
	/** Get a BufferedReader for a file or standard input (STDIN) given a 
	 * file name string.
	 * 
	 * @param inFileNameStr File name string or '-' for STDIN.
	 * @return A BufferedReader for the input stream.
	 * @throws FileNotFoundException
	 */
	private BufferedReader readerFromFile(String inFileNameStr) throws FileNotFoundException {
		String fileNameStr = null;
		if(inFileNameStr.startsWith("@")) {
			fileNameStr = inFileNameStr.substring(1);
		}
		InputStreamReader inRead = null;
		if(fileNameStr.equals("-")) { // STDIN
			InputStream inStream = System.in;
			inRead = new InputStreamReader(inStream);
		}
		else { // File.
			File file = new File(fileNameStr);
			inRead = new FileReader(file);
		}
		BufferedReader inBufRead = new BufferedReader(inRead);
		return inBufRead;
	}
	
	/** Build the option descriptions for processing the command-line arguments.
	 * 
	 * @param options Command-line options description.
	 */
	public static void addCliOptions(Options options) {
		// --help
		options.addOption("h", "help", false, "Help/usage message");
		// --quiet
		options.addOption("q", "quiet", false, "Decrease output");
		// --verbose
		options.addOption("v", "verbose", false, "Increase output");
		// --debugLevel
		options.addOption("debugLevel", true, "Level of debug output");
		// --endpoint
		options.addOption("endpoint", true, "Alternative server endpoint");
	}

	/** Entry point for running as an application
	 * 
	 * @param args List of command-line options
	 */
	public static void main(String[] args) {
		int exitVal = 0; // Exit value

		// Configure the command-line options
		Options options = new Options();
		addCliOptions(options);
		CommandLineParser cliParser = new GnuParser(); // Create the command

		// Create the client object.
		WSDbfetchClient dbfetch = new WSDbfetchClient();
		try {
			// Parse the command-line
			CommandLine cli = cliParser.parse(options, args);
			int argsLength = cli.getArgList().size(); // Number of command-line arguments
			// Usage info
			if (argsLength == 0 || cli.hasOption("help")) {
				printUsage();
				System.exit(0);
			}
			// Modify output level according to the quiet and verbose options
			if (cli.hasOption("q")) {
				dbfetch.outputLevel--;
			}
			if (cli.hasOption("v")) {
				dbfetch.outputLevel++;
			}
			// Set debug level
			if (cli.hasOption("debugLevel")) {
				dbfetch.setDebugLevel(Integer.parseInt(cli
						.getOptionValue("debugLevel")));
			}
			// Alternative service endpoint
			if (cli.hasOption("endpoint")) {
				dbfetch.setServiceEndPoint(cli.getOptionValue("endpoint"));
			}

			// getSupportedDBs
			if (cli.getArgs()[0].equals("getSupportedDBs")) {
				dbfetch.printGetSupportedDBs();
			}
			// getSupportedFormats
			else if (cli.getArgs()[0].equals("getSupportedFormats")) {
				dbfetch.printGetSupportedFormats();
			}
			// getSupportedStyles
			else if (cli.getArgs()[0].equals("getSupportedStyles")) {
				dbfetch.printGetSupportedStyles();
			}
			// getDbFormats <db>
			else if (cli.getArgs()[0].equals("getDbFormats") && cli.getArgs().length > 1) {
				String dbName = cli.getArgs()[1];
				dbfetch.printGetDbFormats(dbName);
			}
			// getFormatStyles <db> <format>
			else if (cli.getArgs()[0].equals("getFormatStyles") && cli.getArgs().length > 2) {
				String dbName = cli.getArgs()[1];
				String formatName = cli.getArgs()[2];
				dbfetch.printGetFormatStyles(dbName, formatName);
			}
			// fetchData <query> [format [style]]
			else if (cli.getArgs()[0].equals("fetchData") && cli.getArgs().length > 1) {
				String query = cli.getArgs()[1];
				String formatName = (cli.getArgs().length > 2) ? cli.getArgs()[2] : "default";
				String styleName = (cli.getArgs().length > 3) ? cli.getArgs()[3] : "raw";
				dbfetch.printFetchData(query, formatName, styleName);
			}
			// fetchBatch <db> <ids> [format [style]]
			else if (cli.getArgs()[0].equals("fetchBatch") && cli.getArgs().length > 2) {
				String dbName = cli.getArgs()[1];
				String idListStr = cli.getArgs()[2];
				String formatName = (cli.getArgs().length > 3) ? cli.getArgs()[3] : "default";
				String styleName = (cli.getArgs().length > 4) ? cli.getArgs()[4] : "raw";
				dbfetch.printFetchBatch(dbName, idListStr, formatName, styleName);
			}
			// Unknown option
			else {
				System.err.println("Error: unknown action, see --help");
				exitVal = 1;
			}
		} catch (Exception ex) {
			System.err.println("ERROR: " + ex.getMessage());
			if (dbfetch.getOutputLevel() > 1) {
				ex.printStackTrace();
			}
			exitVal = 1;
		}
		System.exit(exitVal);
	}
}
