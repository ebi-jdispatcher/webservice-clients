/* $Id$
 * ======================================================================
 * 
 * Copyright 2011-2014 EMBL - European Bioinformatics Institute
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
 * JDispatcher Pratt (SOAP) web service Java client using Axis 1.x.
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
import uk.ac.ebi.webservices.axis1.stubs.pratt.*;

/** <p>JDispatcher Pratt (SOAP) web service Java client using Apache 
 * Axis 1.x.</p>
 * 
 * <p>See:</p>
 * <ul>
 * <li><a href="http://www.ebi.ac.uk/Tools/webservices/services/msa/pratt_soap">http://www.ebi.ac.uk/Tools/webservices/services/msa/pratt_soap</a></li>
 * <li><a href="http://www.ebi.ac.uk/Tools/webservices/tutorials/06_programming/java">http://www.ebi.ac.uk/Tools/webservices/tutorials/06_programming/java</a></li>
 * <li><a href="http://ws.apache.org/axis/">http://ws.apache.org/axis/</a></li>
 * </ul>
 */
public class PrattClient extends uk.ac.ebi.webservices.AbstractWsToolClient {
	/** Proxy object for web service. */
	private JDispatcherService_PortType srvProxy = null;
	/** Client version/revision for use in user-agent string. */
	private String revision = "$Revision$";
	/** Tool specific usage for help. */
	private static final String usageMsg = "Pratt\n"
		+ "=============\n"
		+ "\n"
		+ "Searching for patterns conserved in sets of unaligned protein sequences.\n"
		+ "\n"    
		+ "[Required]\n"
		+ "\n"
		+ "  seqFile                : file : a set of sequences to align (\"-\" for STDIN)\n"
		+ "\n"
		+ "[Optional]\n"
		+ "\n"
		+ "  --minPerc              : int  : minimum percentage of input sequence to match, \n" 
		+ "                                  see --paramDetail minPerc\n"
		+ "  --patternPosition      : str  : pattern position in sequence, \n"
		+ "                                  see --paramDetail patternPosition\n"
		+ "  --maxPatternLength     : int  : maximum pattern length, \n" 
		+ "                                  see --paramDetail maxPatternLength\n"
		+ "  --maxNumPatternSymbols : int  : maximum number Of pattern symbols, \n" 
		+ "                                  see --paramDetail maxNumPatternSymbols\n"
		+ "  --maxNumWildcard       : int  : maximum length of a widecard (x), \n" 
		+ "                                  see --paramDetail maxNumWildcard\n"
		+ "  --maxNumFlexSpaces     : int  : maximum length of flexible spaces, \n" 
		+ "                                  see --paramDetail maxNumFlexSpaces\n"
		+ "  --maxFlexibility       : int  : maximum flexibility, \n" 
		+ "                                  see --paramDetail maxFlexibility\n"
		+ "  --maxFlexProduct       : int  : maximum flex. product, \n" 
		+ "                                  see --paramDetail maxFlexProduct\n"		
		+ "  --patternSymbolFile    :      : enable pattern symbol file.\n"
		+ "  --noPatternSymbolFile  :      : disable pattern symbol file.\n"
		+ "  --numPatternSymbols    : int  : number of pattern symbols used, \n" 
		+ "                                  see --paramDetail numPatternSymbols\n"
		+ "  --patternScoring       : str  : pattern scoring, \n" 
		+ "                                  see --paramDetail patternScoring\n"
		+ "  --patternGraph         : str  : pattern graph allows the use of an alignmen or \n" 
		+ "                                  a query sequence to restrict the pattern search, \n" 
		+ "                                  see --paramDetail patternGraph\n"
		+ "  --searchGreediness     : int  : greediness of the search, \n" 
		+ "                                  see --paramDetail searchGreediness\n"
		+ "  --patternRefinement    :      : enable pattern refinement.\n"
		+ "  --noPatternRefinement  :      : disable pattern refinement.\n"
		+ "  --genAmbigSymbols      :      : enable generalise ambiguous symbols.\n"
		+ "  --noGenAmbigSymbols    :      : disable generalise ambiguous symbols.\n"
		+ "  --patternFormat        :      : enable PROSITE pattern format.\n"
		+ "  --noPatternFormat      :      : disable PROSITE pattern format.\n"		
		+ "  --maxNumPatterns       : int  : maximum number of patterns, \n" 
		+ "                                  see --paramDetail maxNumPatterns\n"
		+ "  --maxNumAlignments     : int  : maximum number of alignments between 1 and 100, \n" 
		+ "                                  see --paramDetail maxNumAlignments\n"
		+ "  --printPatterns        :      : enable print patterns in sequences.\n"
		+ "  --noPrintPatterns      :      : disable print patterns in sequences.\n"
		+ "  --printingRatio        : int  : printing ratio , see --paramDetail printingRatio\n"
		+ "  --printVertically      :      : enable print vertically.\n"
		+ "  --noPrintVertically    :      : disable print vertically.\n";
	
	
	/** Default constructor.
	 */
	public PrattClient() {
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
		String clientVersion = "0";
		if (this.revision.length() > 13) this.revision.substring(11, this.revision.length() - 2);
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
		clientPoll(jobid); // Wait for job to finish
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
		if (line.hasOption("patternSymbolFile")) {
			params.setPatternSymbolFile(new Boolean(true));
		}
		else if (line.hasOption("noPatternSymbolFile")) {
			params.setPatternSymbolFile(new Boolean(false));
		}		
		if (line.hasOption("patternRefinement")) {
			params.setPatternRefinement(new Boolean(true));
		}
		else if (line.hasOption("noPatternRefinement")) {
			params.setPatternRefinement(new Boolean(false));
		}		
		if (line.hasOption("genAmbigSymbols")) {
			params.setGenAmbigSymbols(new Boolean(true));
		}
		else if (line.hasOption("noGenAmbigSymbols")) {
			params.setGenAmbigSymbols(new Boolean(false));
		}		
		if (line.hasOption("patternFormat")) {
			params.setPatternFormat(new Boolean(true));
		}
		else if (line.hasOption("noPatternFormat")) {
			params.setPatternFormat(new Boolean(false));
		}		
		if (line.hasOption("printPatterns")) {
			params.setPrintPatterns(new Boolean(true));
		}
		else if (line.hasOption("noPrintPatterns")) {
			params.setPrintPatterns(new Boolean(false));
		}		
		if (line.hasOption("printVertically")) {
			params.setPrintVertically(new Boolean(true));
		}
		else if (line.hasOption("noPrintVertically")) {
			params.setPrintVertically(new Boolean(false));
		}
		
		if (line.hasOption("minPerc")) params.setMinPerc(new Integer(line.getOptionValue("minPerc")));
		if (line.hasOption("patternPosition")) params.setPatternPosition(line.getOptionValue("patternPosition"));
		if (line.hasOption("maxPatternLength")) params.setMaxPatternLength(new Integer(line.getOptionValue("maxPatternLength")));
		if (line.hasOption("maxNumPatternSymbols")) params.setMaxNumPatternSymbols(new Integer(line.getOptionValue("maxNumPatternSymbols")));		
		if (line.hasOption("maxNumWildcard")) params.setMaxNumWildcard(new Integer(line.getOptionValue("maxNumWildcard")));		
		if (line.hasOption("maxNumFlexSpaces")) params.setMaxNumFlexSpaces(new Integer(line.getOptionValue("maxNumFlexSpaces")));		
		if (line.hasOption("maxFlexibility")) params.setMaxFlexibility(new Integer(line.getOptionValue("maxFlexibility")));		
		if (line.hasOption("maxFlexProduct")) params.setMaxFlexProduct(new Integer(line.getOptionValue("maxFlexProduct")));		
		if (line.hasOption("numPatternSymbols")) params.setNumPatternSymbols(new Integer(line.getOptionValue("numPatternSymbols")));		
		if (line.hasOption("patternScoring")) params.setPatternScoring(line.getOptionValue("patternScoring"));		
		if (line.hasOption("patternGraph")) params.setPatternGraph(line.getOptionValue("patternGraph"));		
		if (line.hasOption("searchGreediness")) params.setSearchGreediness(new Integer(line.getOptionValue("searchGreediness")));		
		if (line.hasOption("maxNumPatterns")) params.setMaxNumPatterns(new Integer(line.getOptionValue("maxNumPatterns")));		
		if (line.hasOption("maxNumAlignments")) params.setMaxNumAlignments(new Integer(line.getOptionValue("maxNumAlignments")));		
		if (line.hasOption("printingRatio")) params.setPrintingRatio(new Integer(line.getOptionValue("printingRatio")));
		
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
		// For asynchronous mode
		if (cli.hasOption("async")) {
			System.out.println(jobid); // Output the job id.
			System.err
					.println("To get status: java -jar Pratt_Axis1.jar --status --jobid "
							+ jobid);
		} else {
			// In synchronous mode try to get the results
			this.printProgressMessage(jobid, 1);
			String[] resultFilenames = this
					.getResults(jobid, cli.getOptionValue("outfile"), cli
							.getOptionValue("outformat"));
			for (int i = 0; i < resultFilenames.length; i++) {
				if (resultFilenames[i] != null) {
					System.out.println("Wrote file: " + resultFilenames[i]);
				}
			}
		}
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
		options.addOption("minPerc", true, "Minimum percentage of input sequence to match");
		options.addOption("patternPosition", true, "Pattern position in sequence");
		options.addOption("maxPatternLength", true, "Maximum pattern length");
		options.addOption("maxNumPatternSymbols", true, "Maximum number Of pattern symbols");
		options.addOption("maxNumWildcard", true, "Maximum length of a widecard (x)");
		options.addOption("maxNumFlexSpaces", true, "Maximum length of flexible spaces");
		options.addOption("maxFlexibility", true, "Maximum flexibility");
		options.addOption("maxFlexProduct", true, "Maximum flex. product");
		options.addOption("patternSymbolFile", false, "Enable pattern symbol file");
		options.addOption("noPatternSymbolFile", false, "Disable pattern symbol file");
		options.addOption("numPatternSymbols", true, "Number of pattern symbols used");
		options.addOption("patternScoring", true, "Pattern scoring");
		options.addOption("patternGraph", true, "Pattern graph allows the use of an alignment or a query sequence to restrict the pattern search");
		options.addOption("searchGreediness", true, "Greediness of the search");
		options.addOption("patternRefinement", false, "Enable pattern refinement");
		options.addOption("noPatternRefinement", false, "Disable pattern refinement");
		options.addOption("genAmbigSymbols", false, "Enable generalise ambiguous symbols");
		options.addOption("noGenAmbigSymbols", false, "Disable generalise ambiguous symbols");
		options.addOption("patternFormat", false, "Enable PROSITE pattern format");
		options.addOption("noPatternFormat", false, "Disable PROSITE pattern format");
		options.addOption("maxNumPatterns", true, "Maximum number of patterns");
		options.addOption("maxNumAlignments", true, "Maximum number of alignments between 1 and 100");
		options.addOption("printPatterns", false, "Enable print Patterns in sequences");
		options.addOption("noPrintPatterns", false, "Disable print Patterns in sequences");
		options.addOption("printingRatio", true, "Printing ratio");
		options.addOption("printVertically", false, "Enable print vertically");
		options.addOption("noPrintVertically", false, "Disable print vertically");
		options.addOption("sequence", true, "Input sequences");
		
		CommandLineParser cliParser = new GnuParser(); // Create the command line parser    
		// Create an instance of the client
		PrattClient client = new PrattClient();
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
					String[] resultFilenames = client.getResults(jobid, cli.getOptionValue("outfile"), cli.getOptionValue("outformat"));
					boolean resultContainContent = false;
					for(int i = 0; i < resultFilenames.length; i++) {
						if(resultFilenames[i] != null) {
							System.out.println("Wrote file: " + resultFilenames[i]);
							resultContainContent = true;
						}
					}
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
				String dataOption = (cli.hasOption("sequence")) ? cli.getOptionValue("sequence") : cli.getArgs()[0];
				client.submitJobFromCli(cli, new String(client
						.loadData(dataOption)));
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
