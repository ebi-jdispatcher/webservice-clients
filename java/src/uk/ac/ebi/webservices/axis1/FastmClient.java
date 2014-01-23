/* $Id$
 * ======================================================================
 * 
 * Copyright 2009-2014 EMBL - European Bioinformatics Institute
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
 * JDispatcher FASTM (SOAP) web service Java client using Axis 1.x.
 * ----------------------------------------------------------------------
 * Tested with:
 *   Sun Java 1.5.0_17 with Apache Axis 1.4 on CentOS 5.2.
 * ====================================================================== */
package uk.ac.ebi.webservices.axis1;

import java.io.File;
import java.io.IOException;
import java.rmi.RemoteException;
import javax.xml.rpc.Call;
import javax.xml.rpc.ServiceException;
import org.apache.axis.transport.http.HTTPConstants;
import org.apache.commons.cli.*;
import uk.ac.ebi.webservices.axis1.stubs.fastm.*;

/** <p>JDispatcher FASTM (SOAP) web service Java client using Apache Axis 
 * 1.x.</p>
 * 
 * <p>See:</p>
 * <ul>
 * <li><a href="http://www.ebi.ac.uk/Tools/webservices/services/sss/fastm_soap">http://www.ebi.ac.uk/Tools/webservices/services/sss/fastm_soap</a></li>
 * <li><a href="http://www.ebi.ac.uk/Tools/webservices/tutorials/06_programming/java">http://www.ebi.ac.uk/Tools/webservices/tutorials/06_programming/java</a></li>
 * <li><a href="http://ws.apache.org/axis/">http://ws.apache.org/axis/</a></li>
 * </ul>
 */
public class FastmClient extends uk.ac.ebi.webservices.AbstractWsToolClient {
	/** Service proxy */
	private JDispatcherService_PortType srvProxy = null;
	/** Client version/revision */
	private String revision = "$Revision$";
	/** Tool specific usage message */
	private static final String usageMsg = "FASTM\n"
		+ "=====\n"
		+ "\n"
		+ "Search a set of sequence fragments against a database.\n"
		+ "\n"
		+ "[Required]\n"
		+ "\n"
		+ "      --program        : str  : FASTA program to use: see --paramDetail program\n"
		+ "      --database       : str  : database(s) to search, space seperated: see\n"
		+ "                                --paramDetail database\n"
		+ "      --stype          : str  : query sequence type\n"
		+ "  seqFile              : file : query sequence (\"-\" for STDIN)\n"
		+ "\n"
		+ "[Optional]\n"
		+ "\n"
		+ "  -s, --matrix       : str  : scoring matrix, see --paramDetail matrix\n"
		+ "  -r, --match_scores : str  : match/missmatch scores, see --paramDetail \n"
		+ "                              match_scores\n"
		+ "  -f, --gapopen      : int  : penalty for gap opening\n"
		+ "  -g, --gapext       : int  : penalty for additional residues in a gap\n"
		+ "      --hsps         :      : enable multiple alignments per-hit, see \n"
		+ "                              --paramDetail hsps\n"
		+ "      --nohsps       :      : disable multiple alignments per-hit, see \n"
		+ "                              --paramDetail hsps\n"
		+ "  -E, --expupperlim  : real : E-value upper limit for hit display\n"
		+ "  -F, --explowlim    : real : E-value lower limit for hit display\n"
		+ "      --strand       : str  : query strand to use for search (DNA only)\n"
		+ "  -H, --histogram    :      : turn off histogram display\n"
		+ "  -b, --scores       : int  : maximum number of scores\n"
		+ "  -d, --alignments   : int  : maximum number of alignments\n"
		+ "      --scoreformat  : str  : score table format for FASTA output\n"
		+ "  -z, --stats        : int  : statistical model for search,\n"
		+ "                              see --paramDetail stats\n"
		+ "  -S, --seqrange     : str  : search with specified region of query sequence\n"
		+ "  -R, --dbrange      : str  : define a subset database by sequence length\n"
		+ "      --filter       : str  : filter the query sequence for low complexity \n"
		+ "                              regions, see --paramDetail filter\n"
		+ "      --ktup         : int  : word size (DNA 1-6, Protein 1-2)\n";

	/** Default constructor.
	 */
	public FastmClient() {
		// Set the HTTP user agent string for (java.net) requests.
		this.setUserAgent();
	}
	
	/** <p>Get a user-agent string for this client.</p>
	 * 
	 * <p><b>Note</b>: this affects all java.net based requests, but not the 
	 * Axis requests. The user-agent used by Axis is set from the 
	 * /org/apache/axis/i18n/resource.properties file included in the Axis 
	 * JAR.</p>
	 * 
	 * @return Client user-agent string.
	 */
	protected String getClientUserAgentString() {
		printDebugMessage("getClientUserAgent", "Begin", 11);
		String clientVersion = this.revision.substring(11, this.revision.length() - 2);
		String clientUserAgent = "EBI-Sample-Client/" + clientVersion 
			+ " (" + this.getClass().getName() + "; " 
			+ System.getProperty("os.name") + ")";
		printDebugMessage("getClientUserAgent", "End", 11);
		return clientUserAgent;
	}

	/** Print usage message. */
	private static void printUsage() {
		System.out.println(usageMsg);
		printGenericOptsUsage();
	}
	
	/** Ensure that a service proxy is available to call the web service.
	 * 
	 * @throws ServiceException
	 */
	protected void srvProxyConnect() throws ServiceException {
		printDebugMessage("srvProxyConnect", "Begin", 11);
		if (this.srvProxy == null) {
			JDispatcherService_Service service = new JDispatcherService_ServiceLocatorExtended();
			if (this.getServiceEndPoint() != null) {
				try {
					this.srvProxy = service
							.getJDispatcherServiceHttpPort(new java.net.URL(
									this.getServiceEndPoint()));
				} catch (java.net.MalformedURLException ex) {
					System.err.println(ex.getMessage());
					System.err
							.println("Warning: problem with specified endpoint URL. Default endpoint used.");
					this.srvProxy = service.getJDispatcherServiceHttpPort();
				}
			} else {
				this.srvProxy = service.getJDispatcherServiceHttpPort();
			}
		}
		printDebugMessage("srvProxyConnect", "End", 11);
	}
	
	/** Wrapper for JDispatcherService_ServiceLocator to enable HTTP 
	 * compression.
	 * 
	 * Compression requires Commons HttpClient and a client-config.wsdd which 
	 * specifies that Commons HttpClient should be used as the HTTP transport.
	 * See http://wiki.apache.org/ws/FrontPage/Axis/GzipCompression.
	 */
	private class JDispatcherService_ServiceLocatorExtended extends JDispatcherService_ServiceLocator {
		private static final long serialVersionUID = 1L;

		public Call createCall() throws ServiceException {
			Call call = super.createCall();
			// Enable response compression.
			call.setProperty(HTTPConstants.MC_ACCEPT_GZIP, Boolean.TRUE);
			return call;
		}
	}

	/** Get the web service proxy so it can be called directly.
	 * 
	 * @return The web service proxy.
	 * @throws javax.xml.rpc.ServiceException
	 */
	public JDispatcherService_PortType getSrvProxy() throws javax.xml.rpc.ServiceException {
		printDebugMessage("getSrvProxy", "", 1);
		this.srvProxyConnect(); // Ensure the service proxy exists
		return this.srvProxy;
	}
	
	/** Get list of tool parameter names.
	 * 
	 * @return String array containing list of parameter names
	 * @throws ServiceException
	 * @throws RemoteException
	 */
	public String[] getParams() throws ServiceException, RemoteException {
		printDebugMessage("getParams", "Begin", 1);
		String[] retVal = null;
		this.srvProxyConnect(); // Ensure the service proxy exists
		retVal = this.srvProxy.getParameters();
		printDebugMessage("getParams", retVal.length + " params", 2);
		printDebugMessage("getParams", "End", 1);
		return retVal;
	}

	/** Get detailed information about the specified tool parameter.
	 * 
	 * @param paramName Tool parameter name
	 * @return Object describing tool parameter
	 * @throws ServiceException
	 * @throws RemoteException
	 */
	public WsParameterDetails getParamDetail(String paramName) throws ServiceException, RemoteException {
		printDebugMessage("getParamDetail", paramName, 1);
		this.srvProxyConnect(); // Ensure the service proxy exists
		return this.srvProxy.getParameterDetails(paramName);
	}

	/** Print detailed information about a tool parameter.
	 * 
	 * @param paramName Name of the tool parameter to get information for.
	 * @throws RemoteException
	 * @throws ServiceException
	 */
	protected void printParamDetail(String paramName) throws RemoteException, ServiceException {
		printDebugMessage("printParamDetail", "Begin", 1);
		WsParameterDetails paramDetail = getParamDetail(paramName);
		// Print object
		System.out.println(paramDetail.getName() + "\t" + paramDetail.getType());
		System.out.println(paramDetail.getDescription());
		WsParameterValue[] valueList = paramDetail.getValues();
		if(valueList!=null) {
			for(int i = 0; i < valueList.length; i++) {
				System.out.print(valueList[i].getValue());
				if(valueList[i].isDefaultValue()) {
					System.out.println("\tdefault");
				}
				else {
					System.out.println();
				}
				System.out.println("\t" + valueList[i].getLabel());
				WsProperty[] valuePropertiesList = valueList[i].getProperties();
				if(valuePropertiesList != null) {
					for(int j = 0; j < valuePropertiesList.length; j++) {
						System.out.println("\t" + valuePropertiesList[j].getKey() + "\t" + valuePropertiesList[j].getValue());
					}
				}
			}
		}
		printDebugMessage("printParamDetail", "End", 1);
	}

	/** Get the status of a submitted job given its job identifier.
	 * 
	 * @param jobid The job identifier.
	 * @return Job status as a string.
	 * @throws IOException
	 * @throws ServiceException
	 */
	public String checkStatus(String jobid) throws IOException, ServiceException {
		printDebugMessage("checkStatus", jobid, 1);
		this.srvProxyConnect(); // Ensure the service proxy exists
		return this.srvProxy.getStatus(jobid);
	}

	/** Get details of the available result types for a job.
	 * 
	 * @param jobId Job identifier to check for results types.
	 * @return Array of objects describing result types.
	 * @throws ServiceException
	 * @throws RemoteException
	 */
	public WsResultType[] getResultTypes(String jobId) throws ServiceException, RemoteException {
		printDebugMessage("getResultTypes", "Begin", 1);
		printDebugMessage("getResultTypes", "jobId: " + jobId , 2);
		WsResultType[] retVal = null;
		this.srvProxyConnect(); // Ensure the service proxy exists
		retVal = this.srvProxy.getResultTypes(jobId);
		printDebugMessage("getResultTypes", retVal.length + " result types", 2);
		printDebugMessage("getResultTypes", "End", 1);
		return retVal;
	}
	
	/** Print details of the available result types for a job.
	 * 
	 * @param jobId Job identifier to check for result types.
	 * @throws ServiceException
	 * @throws RemoteException
	 */
	protected void printResultTypes(String jobId) throws ServiceException, RemoteException {
		printDebugMessage("printResultTypes", "Begin", 1);
		WsResultType[] typeList = getResultTypes(jobId);
		for(int i = 0; i < typeList.length; i++) {
			System.out.print(
					typeList[i].getIdentifier() + "\n\t"
					+ typeList[i].getLabel() + "\n\t"
					+ typeList[i].getDescription() + "\n\t"
					+ typeList[i].getMediaType() + "\n\t"
					+ typeList[i].getFileSuffix() + "\n"
					);
		}
		printDebugMessage("printResultTypes", "End", 1);
	}
	
	/** Get the results for a job and save them to files.
	 * 
	 * @param jobid The job identifier.
	 * @param outfile The base name of the file to save the results to. If
	 * null the jobid will be used.
	 * @param outformat The name of the data format to save, e.g. toolraw 
	 * or toolxml. If null all available data formats will be saved.
	 * @return Array of filenames
	 * @throws IOException
	 * @throws javax.xml.rpc.ServiceException
	 */
	public String[] getResults(String jobid, String outfile, String outformat) throws IOException, javax.xml.rpc.ServiceException {
		printDebugMessage("getResults", "Begin", 1);
		printDebugMessage("getResults", "jobid: " + jobid + " outfile: " + outfile + " outformat: " + outformat, 2);
		String[] retVal = null;
		this.srvProxyConnect(); // Ensure the service proxy exists
		//clientPoll(jobid); // Wait for job to finish
		// Set the base name for the output file.
		String basename = (outfile != null) ? outfile : jobid;
		// Get result types
		WsResultType[] resultTypes = getResultTypes(jobid);
		int retValN = 0;
		if(outformat == null) {
			retVal = new String[resultTypes.length];
		} else {
			retVal = new String[1];
		}
		for(int i = 0; i < resultTypes.length; i++) {
			printProgressMessage("File type: " + resultTypes[i].getIdentifier(), 2);
			// Get the results
			if(outformat == null || outformat.equals(resultTypes[i].getIdentifier())) {
				byte[] resultbytes = this.srvProxy.getResult(jobid, resultTypes[i].getIdentifier(), null);
				if(resultbytes == null) {
					System.err.println("Null result for " + resultTypes[i].getIdentifier() + "!");
				}
				else {
					printProgressMessage("Result bytes length: " + resultbytes.length, 2);
					// Write the results to a file
					String result = new String(resultbytes);
					if(basename.equals("-")) { // STDOUT
						if(resultTypes[i].getMediaType().startsWith("text")) { // String
							System.out.print(result);
						}
						else { // Binary
							System.out.print(resultbytes);
						}
					}
					else { // File
						String filename = basename + "." + resultTypes[i].getIdentifier() + "." + resultTypes[i].getFileSuffix();
						if(resultTypes[i].getMediaType().startsWith("text")) { // String
							writeFile(new File(filename), result);
						}
						else { // Binary
							writeFile(new File(filename), resultbytes);
						}
						retVal[retValN] = filename;
						retValN++;
					}
				}
			}
		}
		printDebugMessage("getResults", retVal.length + " file names", 2);
		printDebugMessage("getResults", "End", 1);
		return retVal;
	}

	/** Submit a job to the service.
	 * 
	 * @param params Input parameters for the job.
	 * @param content Data to run the job on.
	 * @return The job identifier.
	 * @throws RemoteException
	 * @throws ServiceException
	 */
	public String runApp(String email, String title, InputParameters params) throws RemoteException, ServiceException {
		printDebugMessage("runApp", "Begin", 1);
		printDebugMessage("runApp", "email: " + email + " title: " + title, 2);
		printDebugMessage("runApp", "params:\n" + objectFieldsToString(params), 2);
		String jobId = null;
		this.srvProxyConnect(); // Ensure the service proxy exists
		jobId = srvProxy.run(email, title, params);
		printDebugMessage("runApp", "jobId: " + jobId, 2);
		printDebugMessage("runApp", "End", 1);
		return jobId;
	}

	/** Populate input parameters structure from command-line options.
	 * 
	 * @param line Command line options
	 * @return input Input parameters structure for use with runApp().
	 * @throws IOException
	 */
	public InputParameters loadParams(CommandLine line) throws IOException {
		printDebugMessage("loadParams", "Begin", 1);
		InputParameters params = new InputParameters();
		// Tool specific options
		if (line.hasOption("program"))
			params.setProgram(line.getOptionValue("program"));
		if (line.hasOption("stype"))
			params.setStype(line.getOptionValue("stype"));
		else if (line.hasOption("dna"))
			params.setStype("dna");
		else if (line.hasOption("n"))
			params.setStype("dna");
		else if (line.hasOption("p"))
			params.setStype("protein");
		else if (line.hasOption("U"))
			params.setStype("rna");
		else
			params.setStype("protein");
		if (line.hasOption("s"))
			params.setMatrix(line.getOptionValue("s"));
		if(line.hasOption("r"))
			params.setMatch_scores(line.getOptionValue("r"));
		if (line.hasOption("f"))
			params.setGapopen(new Integer(line.getOptionValue("f")));
		if (line.hasOption("g"))
			params.setGapext(new Integer(line.getOptionValue("g")));
		if(line.hasOption("hsps"))
			params.setHsps(new Boolean(true));
		else if(line.hasOption("nohsps"))
			params.setHsps(new Boolean(false));
		if (line.hasOption("E"))
			params.setExpupperlim(new Double(line.getOptionValue("E")));
		if (line.hasOption("F"))
			params.setExplowlim(new Double(line.getOptionValue("F")));
		if(line.hasOption("strand"))
			params.setStrand(line.getOptionValue("strand"));
		else {
			if (line.hasOption("3"))
				params.setStrand("top");
			if (line.hasOption("i"))
				params.setStrand("bottom");
		}
		if (line.hasOption("H"))
			params.setHist(new Boolean(false));
		else
			params.setHist(new Boolean(true));
		if (line.hasOption("b"))
			params.setScores(new Integer(line.getOptionValue("b")));
		if (line.hasOption("d"))
			params.setAlignments(new Integer(line.getOptionValue("d")));
		if (line.hasOption("scoreformat"))
			params.setScoreformat(line.getOptionValue("scoreformat"));
		if (line.hasOption("z"))
			params.setStats(line.getOptionValue("z"));
		if (line.hasOption("S"))
			params.setSeqrange(line.getOptionValue("S"));
		if (line.hasOption("R"))
			params.setDbrange(line.getOptionValue("R"));
		if (line.hasOption("filter"))
			params.setFilter(line.getOptionValue("filter"));
		if (line.hasOption("database")) {
			String[] dbList = line.getOptionValue("database").split(" +");
			params.setDatabase(dbList);
		}
		if (line.hasOption("k"))
			params.setKtup(new Integer(line.getOptionValue("k")));

		printDebugMessage("loadParams", "End", 1);
		return params;
	}

	/**
	 * Submit a job using the command-line information to construct the input.
	 * 
	 * @param cli
	 *            Command-line parameters.
	 * @param inputData
	 *            Data input.
	 * @throws ServiceException
	 * @throws IOException
	 */
	public String submitJobFromCli(CommandLine cli, String inputData)
			throws ServiceException, IOException {
		this.printDebugMessage("submitJobFromCli", "Begin", 1);
		// Create job submission parameters from command-line
		InputParameters params = this.loadParams(cli);
		params.setSequence(inputData);
		// Submit the job
		String email = null, title = null;
		if (cli.hasOption("email"))
			email = cli.getOptionValue("email");
		if (cli.hasOption("title"))
			title = cli.getOptionValue("title");
		String jobid = this.runApp(email, title, params);
		// Asynchronous submission.
		if (cli.hasOption("async")) {
			System.out.println(jobid); // Output the job id.
			System.err
					.println("To get status: java -jar Fastm_Axis1.jar --status --jobid "
							+ jobid);
		}
		//  Parallel submission mode.
		else if(cli.hasOption("maxJobs") && Integer.parseInt(cli.getOptionValue("maxJobs")) > 1) {
			this.printProgressMessage(jobid, 1);
		}
		// Simulate synchronous submission, serial mode.
		else {
			this.clientPoll(jobid);
			this.getResults(jobid, cli);
		}
		this.printDebugMessage("submitJobFromCli", "End", 1);
		return jobid;
	}

	/** Entry point for running as an application.
	 * 
	 * @param args list of command-line options
	 */
	public static void main(String[] args) {
		int exitVal = 0; // Exit value
		int argsLength = args.length; // Number of command-line arguments

		// Configure the command-line options
		Options options = new Options();
		// Common options for EBI clients
		addGenericOptions(options);
		// Application specific options
		options.addOption("program", true, "Search program");
		options.addOption("stype", true, "Sequence type");
		options.addOption("n", "nucleotide", false, "DNA query");
		options.addOption("p", "protein", false, "Protein query");
		options.addOption("U", "rna", false, "RNA query");
		options.addOption("s", "matrix", true, "Scoring matrix");
		options.addOption("r", "match_scores", true, "Match/missmatch score");
		options.addOption("f", "gapopen", true, "Gap creation penalty");
		options.addOption("g", "gapext", true, "Gap extension penalty");
		options.addOption("hsps", false, "Enable HSPs");
		options.addOption("nohsps", false, "Disable HSPs");
		options.addOption("E", "expupperlim", true, "Upper expectation value");
		options.addOption("F", "explowlim", true, "Lower expectation value");
		options.addOption("strand", true, "Query DNA strand");
		options.addOption("3", "topstrand", false, "DNA top strand");
		options.addOption("i", "bottomstrand", false, "DNA bottom strand");
		options.addOption("H", "histogram", false, "Output histogram");
		options.addOption("b", "scores", true, "Maximum number of reported scores");
		options.addOption("d", "alignments", true, "Maximum number of reported alignments");
		options.addOption("scoreformat", true, "Score table format");
		options.addOption("z", "stats", true, "Statistical model for search");
		options.addOption("S", "seqrange", true, "Region within the query sequence to search with");
		options.addOption("R", "dbrange", true, "Range of sequence lengths in database to search");
		options.addOption("filter", true, "Low complexity sequence filter");
		options.addOption("sequence", true, "sequence file");
		options.addOption("database", true, "Database to search");
		options.addOption("k", "ktup", true, "Word length");

		CommandLineParser cliParser = new GnuParser(); // Create the command line parser    
		// Create an instance of the client
		FastmClient client = new FastmClient();
		try {
			// Parse the command-line
			CommandLine cli = cliParser.parse(options, args);
			// User asked for usage info
			if(argsLength == 0 || cli.hasOption("help")) {
				printUsage();
				System.exit(0);
			}
			// Modify output level according to the quiet and verbose options
			if(cli.hasOption("quiet")) {
				client.outputLevel--;
			}
			if(cli.hasOption("verbose")) {
				client.outputLevel++;
			}
			// Set debug level
			if(cli.hasOption("debugLevel")) {
				client.setDebugLevel(Integer.parseInt(cli.getOptionValue("debugLevel")));
			}
			// Alternative service endpoint
			if(cli.hasOption("endpoint")) {
				client.setServiceEndPoint(cli.getOptionValue("endpoint"));
			}
			// Tool meta-data
			// List parameters
			if(cli.hasOption("params")) {
				client.printParams();
			}
			// Details of a parameter
			else if(cli.hasOption("paramDetail")) {
				client.printParamDetail(cli.getOptionValue("paramDetail"));
			}
			// Job related actions
			else if(cli.hasOption("jobid")) {
				String jobid = cli.getOptionValue("jobid");
				// Get results for job
				if(cli.hasOption("polljob")) {
					client.clientPoll(jobid);
					boolean resultContainContent = client.getResults(jobid, cli);
					if (resultContainContent == false) {
						System.err.println("Error: requested result type " + cli.getOptionValue("outformat") + " not available!");
					}
				}
				// Get status of job
				else if(cli.hasOption("status")) {
					System.out.println(client.checkStatus(jobid));
				}
				// Get result types for job
				else if(cli.hasOption("resultTypes")) {
					client.clientPoll(jobid);
					client.printResultTypes(jobid);
				}
				// Unknown...
				else {
					System.err.println("Error: jobid specified without related action option");
					printUsage();
					exitVal = 2;
				}
			}
			// Submit a job
			else if(cli.hasOption("email") && (cli.hasOption("sequence") || cli.getArgs().length > 0)) {
				// Input sequence, data file or entry identifier.
				String dataOption = (cli.hasOption("sequence")) ? cli
						.getOptionValue("sequence") : cli.getArgs()[0];
				// Multi-fasta like sequence input.
				if (cli.hasOption("multifasta")) {
					client.multifastaSubmitCli(dataOption, cli);
				}
				// Submit a job
				else {
					client.printDebugMessage("main", "Mode: sequence", 11);
					client.submitJobFromCli(cli, new String(client
							.loadData(dataOption)));
				}
			}
			// Unknown action
			else {
				System.err.println("Error: unknown combination of arguments. See --help.");
				exitVal = 2;
			}
		}
		catch(UnrecognizedOptionException ex) {
			System.err.println("ERROR: " + ex.getMessage());
			printUsage();
			exitVal = 1;
		}
		// Catch all exceptions
		catch(Exception e) {
			System.err.println ("ERROR: " + e.getMessage());
			if(client.getDebugLevel() > 0) {
				e.printStackTrace();
			}
			exitVal = 3;
		}
		System.exit(exitVal);
	}

}
