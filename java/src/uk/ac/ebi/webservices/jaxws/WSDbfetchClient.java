/* $Id$
 * ======================================================================
 * WSDbfetchDoclit Java client.
 * ====================================================================== */
package uk.ac.ebi.webservices.jaxws;

import java.util.List;
import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.GnuParser;
import org.apache.commons.cli.Options;

import uk.ac.ebi.webservices.jaxws.stubs.wsdbfetch.*;

/**
 * Java WSDbfetch document/literal SOAP web service client using JAX-WS RI.
 * 
 * See:
 * <a href="http://www.ebi.ac.uk/Tools/Webservices/services/dbfetch">http://www.ebi.ac.uk/Tools/Webservices/services/dbfetch</a>
 * <a href="http://www.ebi.ac.uk/Tools/Webservices/tutorials/java">http://www.ebi.ac.uk/Tools/Webservices/tutorials/java</a>
 */
public class WSDbfetchClient {
	/** Output level. Controlled by the --verbose and --quiet options. */
	protected int outputLevel = 1;
	/** Debug level. Controlled by the --debugLevel option. */
	private int debugLevel = 0;
	/** URL for service WSDL. */
	private String serviceWsdl = null;
	/** Service proxy */
	private WSDBFetchServer srvProxy = null;
	/** Client version/revision */
	private String revision = "$Revision$";
	/** Usage message */
	private static final String usageMsg = "WSDbfetch\n"
		+ "=========\n"
		+ "\n"
		+ "Usage: java -jar WSDbfetch.jar <method> [arguments...]\n"
		+ "\n"
		+ "A number of methods are available:\n"
		+ "\n"
		+ "  getSupportedDBs - list available databases\n"
		+ "  getSupportedFormats - list available databases with formats\n"
		+ "  getSupportedStyles - list available databases with styles\n"
		+ "  getDbFormats - list formats for a specifed database\n"
		+ "  getFormatStyles - list styles for a specified database and format\n"
		+ "  fetchData - retrive an database entry. See below for details of arguments.\n"
		+ "  fetchBatch - retrive database entries. See below for details of arguments.\n"
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
		+ "  style      style to retrive (e.g. raw)\n";

	/** Default constructor
	 */
	public WSDbfetchClient() {
		// Set the HTTP user agent string for requests
		this.setUserAgent();
	}
	
	/** Set the HTTP User-agent header string for the client.
	 * 
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
		if (level > -1) debugLevel = level;
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
		if (level > -1) this.outputLevel = level;
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

	/** Set the service WSDL URL for generating the service connection.
	 * 
	 * @param urlStr Service WSDL URL as a string.
	 */
	public void setServiceWsdl(String urlStr) {
		printDebugMessage("setServiceWsdl", "urlStr: " + urlStr, 1);
		this.serviceWsdl = urlStr;
	}

	/** Get the current service WSDL URL.
	 * 
	 * @return The service WSDL URL as a string.
	 */
	public String getServiceWsdl() {
		printDebugMessage("getServiceWsdl", "serviceWsdl: " + this.serviceWsdl, 1);
		return this.serviceWsdl;
	}

	/** Print a progress message.
	 * 
	 * @param msg The message to print.
	 * @param level The output level at or above which this message should be displayed.
	 */
	protected void printProgressMessage(String msg, int level) {
		if (outputLevel >= level) System.err.println(msg);
	}

	/** Ensure that a service proxy is available to call the web service.
	 */
	protected void srvProxyConnect() {
		printDebugMessage("srvProxyConnect", "Begin", 2);
		if(this.srvProxy == null) {
			WSDBFetchDoclitServerService service = null;
			if(this.getServiceWsdl() != null) {
				try {
					service = new WSDBFetchDoclitServerService(new java.net.URL(this.getServiceWsdl()), 
							new javax.xml.namespace.QName("http://www.ebi.ac.uk/ws/services/WSDbfetchDoclit", "WSDBFetchDoclitServerService"));
				}
				catch(java.net.MalformedURLException ex) {
					System.err.println(ex.getMessage());
					System.err.println("Warning: problem with specified WSDL URL. Default WSDL used.");
					service = new WSDBFetchDoclitServerService();
				}
			}
			else {
				service = new WSDBFetchDoclitServerService();
			}
			this.srvProxy = service.getWSDbfetchDoclit();
		}
		printDebugMessage("srvProxyConnect", "End", 2);
	}

	/** Get the web service proxy.
	 * 
	 * @return The web service proxy.
	 */
	public WSDBFetchServer getSrvProxy() {
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

	/** Get a list of supported database names.
	 * 
	 * @return Array of database names.
	 */
	public String[] getSupportedDBs() {
		printDebugMessage("getSupportedDBs", "Begin", 1);
		String[] retVal = null;
		srvProxyConnect(); // Ensure we have a service proxy
		List<String> result = this.srvProxy.getSupportedDBs();
		retVal = result.toArray(new String[0]);
		printDebugMessage("getSupportedDBs", "End", 1);
		return retVal;
	}

	/** Print list of supported database names to STDOUT.
	 */
	public void printGetSupportedDBs() {
		printDebugMessage("printGetSupportedDBs", "Begin", 1);
		printStrList(getSupportedDBs());
		printDebugMessage("printGetSupportedDBs", "End", 1);
	}
	
	/** Get a list of supported database and format names.
	 * 
	 * @return Array of database and format names.
	 */
	public String[] getSupportedFormats() {
		printDebugMessage("getSupportedFormats", "Begin", 1);
		String[] retVal = null;
		srvProxyConnect(); // Ensure we have a service proxy
		List<String> result = this.srvProxy.getSupportedFormats();
		retVal = result.toArray(new String[0]);
		printDebugMessage("getSupportedFormats", "End", 1);
		return retVal;
	}

	/** Print list of supported database and format names to STDOUT.
	 */
	public void printGetSupportedFormats() {
		printDebugMessage("printGetSupportedFormats", "Begin", 1);
		printStrList(getSupportedFormats());
		printDebugMessage("printGetSupportedFormats", "End", 1);
	}
	
	/** Get a list of supported database and style names.
	 * 
	 * @return Array of database and style names.
	 */
	public String[] getSupportedStyles() {
		printDebugMessage("getSupportedStyles", "Begin", 1);
		String[] retVal = null;
		srvProxyConnect(); // Ensure we have a service proxy
		List<String> result = this.srvProxy.getSupportedStyles();
		retVal = result.toArray(new String[0]);
		printDebugMessage("getSupportedStyles", "End", 1);
		return retVal;
	}

	/** Print list of supported database and style names to STDOUT.
	 */
	public void printGetSupportedStyles() {
		printDebugMessage("printGetSupportedStyles", "Begin", 1);
		printStrList(getSupportedStyles());
		printDebugMessage("printGetSupportedStyles", "End", 1);
	}
	
	/** Get a list of supported format names for a database.
	 * 
	 * @param dbName Database name.
	 * @return Array of data format names.
	 * @throws DbfParamsException_Exception 
	 */
	public String[] getDbFormats(String dbName) throws DbfParamsException_Exception {
		printDebugMessage("getDbFormats", "Begin", 1);
		if(dbName == null || dbName.length() < 1) dbName = "default";
		String[] retVal = null;
		srvProxyConnect(); // Ensure we have a service proxy
		List<String> result = this.srvProxy.getDbFormats(dbName);
		retVal = result.toArray(new String[0]);
		printDebugMessage("getDbFormats", "End", 1);
		return retVal;
	}

	/** Print list of supported format names for a database to STDOUT.
	 * 
	 * @param dbName Database name.
	 * @throws DbfParamsException_Exception 
	 */
	public void printGetDbFormats(String dbName) throws DbfParamsException_Exception {
		printDebugMessage("printGetDbFormats", "Begin", 1);
		printStrList(getDbFormats(dbName));
		printDebugMessage("printGetDbFormats", "End", 1);
	}
	
	/** Get a list of supported style names for a format of a database.
	 * 
	 * @param dbName Database name.
	 * @param formatName Data format name.
	 * @return Array of result style names.
	 * @throws DbfParamsException_Exception 
	 */
	public String[] getFormatStyles(String dbName, String formatName) throws DbfParamsException_Exception {
		printDebugMessage("getFormatStyles", "Begin", 1);
		if(dbName == null || dbName.length() < 1) dbName = "default";
		if(formatName == null || formatName.length() < 1) formatName = "default";
		String[] retVal = null;
		srvProxyConnect(); // Ensure we have a service proxy
		List<String> result = this.srvProxy.getFormatStyles(dbName, formatName);
		retVal = result.toArray(new String[0]);
		printDebugMessage("getFormatStyles", "End", 1);
		return retVal;
	}

	/** Print list of supported style names for a format of a database to STDOUT.
	 * 
	 * @param dbName Database name.
	 * @param formatName Data format name.
	 * @throws DbfParamsException_Exception 
	 */
	public void printGetFormatStyles(String dbName, String formatName) throws DbfParamsException_Exception {
		printDebugMessage("printGetFormatStyles", "Begin", 1);
		printStrList(getFormatStyles(dbName, formatName));
		printDebugMessage("printGetFormatStyles", "End", 1);
	}
	
	/** Get an entry.
	 * 
	 * @param query Entry identifier in DB:ID format.
	 * @param formatName Data format name.
	 * @param styleName Result style name.
	 * @return Entry data.
	 * @throws InputException_Exception 
	 * @throws DbfParamsException_Exception 
	 * @throws DbfNoEntryFoundException_Exception 
	 * @throws DbfException_Exception 
	 * @throws DbfConnException_Exception 
	 */
	public String fetchData(String query, String formatName, String styleName) throws DbfConnException_Exception, DbfException_Exception, DbfNoEntryFoundException_Exception, DbfParamsException_Exception, InputException_Exception {
		printDebugMessage("fetchData", "Begin", 1);
		if(formatName == null || formatName.length() < 1) formatName = "default";
		if(styleName == null || styleName.length() < 1) styleName = "default";
		String retVal = null;
		srvProxyConnect(); // Ensure we have a service proxy
		retVal = this.srvProxy.fetchData(query, formatName, styleName);
		printDebugMessage("fetchData", "End", 1);
		return retVal;
	}

	/** Print an entry to STDOUT.
	 * 
	 * @param query Entry identifier in DB:ID format.
	 * @param formatName Data format name.
	 * @param styleName Result style name.
	 * @throws InputException_Exception 
	 * @throws DbfParamsException_Exception 
	 * @throws DbfNoEntryFoundException_Exception 
	 * @throws DbfException_Exception 
	 * @throws DbfConnException_Exception 
	 */
	public void printFetchData(String query, String formatName, String styleName) throws DbfConnException_Exception, DbfException_Exception, DbfNoEntryFoundException_Exception, DbfParamsException_Exception, InputException_Exception {
		printDebugMessage("printFetchData", "Begin", 1);
		System.out.println(fetchData(query, formatName, styleName));
		printDebugMessage("printFetchData", "End", 1);
	}
	
	/** Get a set of entries.
	 * 
	 * @param dbName Database name.
	 * @param idListStr Comma or space separated list of entry identifiers.
	 * @param formatName Data format name.
	 * @param styleName Result style name.
	 * @return Entry data.
	 * @throws InputException_Exception 
	 * @throws DbfParamsException_Exception 
	 * @throws DbfNoEntryFoundException_Exception 
	 * @throws DbfException_Exception 
	 * @throws DbfConnException_Exception 
	 */
	public String fetchBatch(String dbName, String idListStr, String formatName, String styleName) throws DbfConnException_Exception, DbfException_Exception, DbfNoEntryFoundException_Exception, DbfParamsException_Exception, InputException_Exception {
		printDebugMessage("fetchBatch", "Begin", 1);
		if(dbName == null || dbName.length() < 1) dbName = "default";
		if(formatName == null || formatName.length() < 1) formatName = "default";
		if(styleName == null || styleName.length() < 1) styleName = "default";
		String retVal = null;
		srvProxyConnect(); // Ensure we have a service proxy
		retVal = this.srvProxy.fetchBatch(dbName, idListStr, formatName, styleName);
		printDebugMessage("fetchBatch", "End", 1);
		return retVal;
	}

	/** Print a set of entries STDOUT.
	 * 
	 * @param dbName Database name.
	 * @param idListStr Comma or space separated list of entry identifiers.
	 * @param formatName Data format name.
	 * @param styleName Result style name.
	 * @throws InputException_Exception 
	 * @throws DbfParamsException_Exception 
	 * @throws DbfNoEntryFoundException_Exception 
	 * @throws DbfException_Exception 
	 * @throws DbfConnException_Exception 
	 */
	public void printFetchBatch(String dbName, String idListStr, String formatName, String styleName) throws DbfConnException_Exception, DbfException_Exception, DbfNoEntryFoundException_Exception, DbfParamsException_Exception, InputException_Exception {
		printDebugMessage("printFetchBatch", "Begin", 1);
		System.out.println(fetchBatch(dbName, idListStr, formatName, styleName));
		printDebugMessage("printFetchBatch", "End", 1);
	}
	
	/** Build the option descriptions for processing the command-line arguments.
	 * 
	 * @param options Command-line options description.
	 */
	public static void addCliOptions(Options options) {
		// --help or -h
		options.addOption("h", "help", false, "Usage");
		// --quiet or -q
		options.addOption("q", "quiet", false, "Decrease output");
		// --verbose or -v
		options.addOption("v", "verbose", false, "Increase output");
		// --debugLevel <level>
		options.addOption("debugLevel", true, "Level of debug output");
		// --WSDL <wsdlUrl>
		options.addOption("WSDL", true, "Alternative server WSDL");
	}

	/** Entry point for running as an application
	 * 
	 * @param args List of command-line options.
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
			// -h or --help : usage info
			if (argsLength == 0 || cli.hasOption("h")) {
				printUsage();
				System.exit(0);
			}
			// -q or --quiet : reduce output level
			if (cli.hasOption("q")) {
				dbfetch.outputLevel--;
			}
			// -v or --verbose : increase output level
			if (cli.hasOption("v")) {
				dbfetch.outputLevel++;
			}
			// --debugLevel <level> : set debug level
			if (cli.hasOption("debugLevel")) {
				dbfetch.setDebugLevel(Integer.parseInt(cli
						.getOptionValue("debugLevel")));
			}
			// --WSDL <wsdlUrl> : alternative service WSDL
			if (cli.hasOption("WSDL")) {
				dbfetch.setServiceWsdl(cli.getOptionValue("WSDL"));
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
