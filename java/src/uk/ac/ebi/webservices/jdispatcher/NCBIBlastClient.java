/* $Id$
 * ======================================================================
 * jDispatcher NCBI BLAST SOAP web service Java client using Axis 1.4.
 * ----------------------------------------------------------------------
 * Tested with:
 *   Sun Java 1.5.0_17 with Apache Axis 1.4 on CentOS 5.2.
 * ====================================================================== */
package uk.ac.ebi.webservices.jdispatcher;

import java.io.*;
import java.rmi.RemoteException;

import javax.xml.rpc.ServiceException;

import org.apache.commons.cli.*;
import uk.ac.ebi.webservices.jdispatcher.ncbiblast.*;

/** jDispatcher NCBI BLAST SOAP web service Java client.
 * 
 * See:
 * <a href="http://www.ebi.ac.uk/Tools/Webservices/services/ncbiblast">http://www.ebi.ac.uk/Tools/Webservices/services/ncbiblast</a>
 * <a href="http://www.ebi.ac.uk/Tools/Webservices/clients/ncbiblast">http://www.ebi.ac.uk/Tools/Webservices/clients/ncbiblast</a>
 * <a href="http://www.ebi.ac.uk/Tools/Webservices/tutorials/java">http://www.ebi.ac.uk/Tools/Webservices/tutorials/java</a>
 */
public class NCBIBlastClient extends uk.ac.ebi.webservices.jdispatcher.AbstractWsClient {
	/** Service proxy */
	private JDispatcherService_PortType srvProxy = null;
	/** Usage message */
	private static final String usageMsg = "NCBI BLAST\n"
		+ "==========\n"
		+ "   \n"
		+ "Rapid sequence database search programs utilizing the BLAST algorithm\n"
		+ "    \n"
		+ "For more detailed help information refer to \n"
		+ "http://www.ebi.ac.uk/Tools/blastall/help.html\n"
		+ "\n"
		+ "[Required]\n"
		+ "\n"
		+ "  -p, --program        : str  : BLAST program to use: see --paramDetail program\n"
		+ "  -D, --database       : str  : database(s) to search, space seperated: see\n"
		+ "                                --paramDetail database\n"
		+ "      --stype          : str  : query sequence type\n"
		+ "  seqFile              : file : query sequence (\"-\" for STDIN)\n"
		+ "\n"
		+ "[Optional]\n"
		+ "\n"
		+ "  -m, --matrix         : str  : scoring matrix, see --paramDetail matrix\n"
		+ "  -e, --exp            : real : 0<E<= 1000. Statistical significance threshold \n"
		+ "                                for reporting database sequence matches.\n"
		+ "  -f, --filter         :      : display the filtered query sequence in the output,\n"
		+ "                                see --paramDetail filter"
		+ "  -A, --align          : int  : alignment format, see --paramDetail align\n"
		+ "  -s, --scores         : int  : number of scores to be reported\n"
		+ "  -n, --alignments     : int  : Number of alignments\n"
		+ "  -u, --match          : int  : Match score\n"
		+ "  -v, --mismatch       : int  : Mismatch score\n"
		+ "  -o, --gapopen        : int  : Gap open penalty\n"
		+ "  -x, --gapext         : int  : Gap extension penalty\n"
		+ "  -d, --dropoff        : int  : Drop-off\n"
		+ "  -g, --gapalign       :      : Optimise gapped alignments\n"
		+ "      --seqrange       : str  : Region of query sequence to use\n";

	/** Print usage message */
	private static void printUsage() {
		System.out.println(usageMsg);
		printGenericOptsUsage();
	}
	
	/** Get an instance of the service proxy to use with other methods.
	 * 
	 * @throws javax.xml.rpc.ServiceException
	 */
	private void srvProxyConnect() throws javax.xml.rpc.ServiceException {
		printDebugMessage("srvProxyConnect", "Begin", 11);
		if(this.srvProxy == null) {
			JDispatcherService_Service service =  new JDispatcherService_ServiceLocator();
			this.srvProxy = service.getJDispatcherServiceHttpPort();
		}
		printDebugMessage("srvProxyConnect", "End", 11);
	}

	/** Get the web service proxy.
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

	/** Print list of parameter names for tool.
	 * 
	 * @throws RemoteException
	 * @throws ServiceException
	 */
	private void printParams() throws RemoteException, ServiceException {
		printDebugMessage("printParams", "Begin", 1);
		String[] paramList = getParams();
		for(int i = 0; i < paramList.length; i++) {
			System.out.println(paramList[i]);
		}
		printDebugMessage("printParams", "End", 1);
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

	/** Print information about a tool parameter
	 * 
	 * @param paramName Name of the tool parameter to get information for.
	 * @throws RemoteException
	 * @throws ServiceException
	 */
	private void printParamDetail(String paramName) throws RemoteException, ServiceException {
		printDebugMessage("printParamDetail", "Begin", 1);
		WsParameterDetails paramDetail = getParamDetail(paramName);
		// Print object...!
		System.out.println(paramDetail.getName() + "\t" + paramDetail.getType());
		System.out.println(paramDetail.getDescription());
		WsParameterValue[] valueList = paramDetail.getValues();
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
		printDebugMessage("printParamDetail", "End", 1);
	}

	/** Get the status of a submitted job given its job identifier.
	 * 
	 * @param jobid The job identifier
	 * @return Job status as a string.
	 * @throws IOException
	 * @throws javax.xml.rpc.ServiceException
	 */
	public String checkStatus(String jobid) throws IOException, javax.xml.rpc.ServiceException {
		printDebugMessage("checkStatus", jobid, 1);
		this.srvProxyConnect(); // Ensure the service proxy exists
		return this.srvProxy.getStatus(jobid);
	}

	/* Get entry identifiers from tool result
	 * 
	 * @param jobid The ID of the tool job.
	 * @return An array of entry identifiers.
	 * @throws javax.xml.rpc.ServiceException
	 * @throws java.rmi.RemoteException
	 */
	/* public String[] getIds(String jobid) throws javax.xml.rpc.ServiceException, java.rmi.RemoteException {
		printDebugMessage("getIds", jobid, 1);
		this.srvProxyConnect(); // Ensure the service proxy exists
		return this.srvProxy.;	
	} */

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
	private void printResultTypes(String jobId) throws ServiceException, RemoteException {
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
				} else {
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
	 * @throws java.rmi.RemoteException
	 * @throws javax.xml.rpc.ServiceException
	 */
	public String runApp(String email, String title, InputParameters params) throws java.rmi.RemoteException, javax.xml.rpc.ServiceException {
		printDebugMessage("runApp", "Begin", 1);
		printDebugMessage("runApp", "email: " + email + " title: " + title, 2);
		String jobId = null;
		this.srvProxyConnect(); // Ensure the service proxy exists
		jobId = srvProxy.run(email, title, params);
		printDebugMessage("runApp", "jobId: " + jobId, 2);
		printDebugMessage("runApp", "End", 1);
		return jobId;
	}

	/** Poll the job status until the job completes.
	 * 
	 * @param jobid The job identifier.
	 * @throws javax.xml.rpc.ServiceException
	 */
	public void clientPoll(String jobId) throws javax.xml.rpc.ServiceException {
		printDebugMessage("clientPoll", "Begin", 1);
		printDebugMessage("clientPoll", "jobId: " + jobId, 2);
		String status = "PENDING";
		// Check status and wait if not finished
		while(status.equals("RUNNING") || status.equals("PENDING")) {
			try {
				status = this.checkStatus(jobId);
				printProgressMessage(status, 1);
				if(status.equals("RUNNING") || status.equals("PENDING")) {
					// Wait before polling again.
					Thread.sleep(15000);
				}
			}
			catch(InterruptedException ex) {
				// Ignore
			}
			catch(IOException ex) {
				// Report and continue
				System.err.println("Warnning: " + ex.getMessage());
			}
		}
		printDebugMessage("clientPoll", "End", 1);
	}

	/** Create data input structure from the option value.
	 * 
	 * The option can be either an entry identifier in the 
	 * format dbname:id or a filename. If a filename is used
	 * the contents of the file will be used as the input data. 
	 * This method makes no attempt to parse the input file to 
	 * handle it as individual sequences.
	 * 
	 * @param fileOptionStr Filename or entry identifier.
	 * @return Data structure for use with runApp().
	 * @throws IOException
	 */
	public String loadData(String fileOptionStr) throws IOException {
		printDebugMessage("loadData", "Begin", 1);
		printDebugMessage("loadData", "fileOptionStr: " + fileOptionStr, 2);
		String retVal = null;
		if(fileOptionStr != null) {
			if(fileOptionStr.equals("-")) { // STDIN
				String fileContent = readStream(System.in);
				retVal = fileContent;
			}
			else if(new File(fileOptionStr).exists()) { // File
				String fileContent = readFile(new File(fileOptionStr));
				retVal = fileContent;
			} else { // Entry Id
				retVal = fileOptionStr;
			}
		}
		printDebugMessage("loadData", "End", 1);
		return retVal;
	}

	/** Build input parameters structure from command-line options
	 * 
	 * @param line Command line options
	 * @return input Input parameters structure for use with runApp().
	 * @throws IOException
	 */
	public InputParameters loadParams(CommandLine line) throws IOException {
		printDebugMessage("loadParams", "Begin", 1);
		InputParameters params = new InputParameters();
		// Tool specific options
		if (line.hasOption("stype")) params.setStype(line.getOptionValue("stype"));
		else params.setStype("protein");
		if (line.hasOption("p")) params.setProgram(line.getOptionValue("p"));
		if (line.hasOption("D")) {
			String[] dbList = line.getOptionValue("D").split(" +");
			params.setDatabase(dbList);
		}
		if (line.hasOption("m")) params.setMatrix(line.getOptionValue("m"));
		if (line.hasOption("e")) params.setExp(line.getOptionValue("e"));
		else params.setExp("10");
		if (line.hasOption("u") && line.hasOption("v")) {
			params.setMatch_scores(line.getOptionValue("u") + "," + line.getOptionValue("v"));
		}
		if (line.hasOption("o")) params.setGapopen(new Integer(line.getOptionValue("o"))); 
		if (line.hasOption("x")) params.setGapext(new Integer(line.getOptionValue("x")));
		if (line.hasOption("d")) params.setDropoff(new Integer(line.getOptionValue("d"))); 
		if (line.hasOption("A")) params.setAlign(new Integer(line.getOptionValue("A"))); 
		if (line.hasOption("s")) params.setScores(new Integer(line.getOptionValue("s")));
		else params.setScores(new Integer(50));
		if (line.hasOption("n")) params.setAlignments(new Integer(line.getOptionValue("n")));
		else params.setAlignments(new Integer(50));
		if (line.hasOption("g")) params.setGapalign(new Boolean(true)); 
		if (line.hasOption("f")) params.setFilter(line.getOptionValue("f"));
		//if (line.hasOption("F")) params.setFormat(new Boolean(true));
		if (line.hasOption("S")) params.setSeqrange(line.getOptionValue("S"));
		printDebugMessage("loadParams", "End", 1);
		return params;
	}

	/** Entry point for running as an application
	 * 
	 * @param args list of command-line options
	 */
	public static void main(String[] args) {
		int exitVal = 0; // Exit value
		int argsLength = args.length; // Number of command-line arguments

		// Configure the command-line options
		Options options = new Options();
		// Common options for EBI clients 
		options.addOption("help", "help", false, "help on using this client");
		options.addOption("async", "async", false, "perform an asynchronous job");
		options.addOption("polljob", "polljob", false, "poll for the status of an asynchronous job and get the results");
		options.addOption("status", "status", false, "poll for the status of an asynchronous job");        
		options.addOption("email", "email", true, "Your email address");
		options.addOption("jobid", "jobid", true, "Job identifier of an asynchronous job");
		options.addOption("stdout", "stdout", false, "print to standard output");
		options.addOption("outfile", "outfile", true, "file name to save the results");
		options.addOption("outformat", "outformat", true, "Output format (txt or xml)");
		options.addOption("quiet", "quiet", false, "Decrease output messages");
		options.addOption("verbose", "verbose", false, "Increase output messages");
		options.addOption("ids", "ids", false, "retrieve only identifiers"); // TBI
		options.addOption("params", "params", false, "List parameters");
		options.addOption("paramDetail", "paramDetail", true, "List parameter information");
		options.addOption("resultTypes", "resultTypes", false, "List result types for job");
		options.addOption("debugLevel", "debugLevel", true, "Debug output");
		// Application specific options
		options.addOption("p", "program", true, "Program to use");
		options.addOption("D", "database", true, "Database to search");
		options.addOption("m", "matrix", true, "Scoring matrix");
		options.addOption("e", "exp", true, "Expectation value threshold");
		options.addOption("f", "filter", true, "Low complexity sequence filter");
		options.addOption("g", "gapalign", true, "Perform gapped alignments");
		options.addOption("A", "align", true, "Alignment format");
		options.addOption("s", "scores", true, "Maximum number of scores to display");
		options.addOption("n", "alignments", true, "Maximum number of alignments to display");
		options.addOption("u", "match", true, "Match score");
		options.addOption("v", "mismatch", true, "Mismatch score");
		options.addOption("o", "gapopen", true, "Gap creation penalty");
		options.addOption("x", "gapext", true, "Gap extension penalty");
		options.addOption("d", "dropoff", true, "Drop off score");
		options.addOption("seqrange", true, "Region in query sequence to use for search");
		options.addOption("stype", "stype", true, "Sequence type");
		options.addOption("sequence", "sequence", true, "Query sequence");

		CommandLineParser cliParser = new GnuParser(); // Create the command line parser    
		try {
			// Parse the command-line
			CommandLine cli = cliParser.parse(options, args);
			// User asked for usage info
			if(argsLength == 0 || cli.hasOption("help")) {
				printUsage();
				System.exit(0);
			}
			// Create an instance of the client
			NCBIBlastClient client = new NCBIBlastClient();
			// Modify output level according to the quiet and verbose options
			if(cli.hasOption("quiet")) {
				client.outputLevel--;
			}
			if(cli.hasOption("verbose")) {
				client.outputLevel++;
			}
			// Set debug level
			if(cli.hasOption("debugLevel")) {
				client.setDebugLevel(Integer.valueOf(cli.getOptionValue("debugLevel")));
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
				// Get entry Ids from result
				else if(cli.hasOption("ids")) {
					client.getResults(jobid, "-", "ids");
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
					System.err.println("Error: jobid specified without releated action option");
					printUsage();
					exitVal = 2;
				}
			}
			// Submit a job
			else if(cli.hasOption("email")) {
				// Create job submission parameters from command-line
				InputParameters params = client.loadParams(cli);
				String dataOption = (cli.hasOption("sequence")) ? cli.getOptionValue("sequence") : cli.getArgs()[0];
				params.setSequence(client.loadData(dataOption));
				// Submit the job
				String email = null, title = null;
				if (cli.hasOption("email")) email = cli.getOptionValue("email"); 
				if (cli.hasOption("title")) title = cli.getOptionValue("title"); 
				String jobid = client.runApp(email, title, params);
				// For asynchronous mode
				if (cli.hasOption("async")) {
					System.out.println(jobid); // Output the job id.
					System.err.println("To get status: java -jar WSNCBIBlast.jar --status --jobid " + jobid);
				} else {
					// In synchronous mode try to get the results
					client.printProgressMessage(jobid, 1);
					String[] resultFilenames = client.getResults(jobid, cli.getOptionValue("outfile"), cli.getOptionValue("outformat"));
					for(int i = 0; i < resultFilenames.length; i++) {
						if(resultFilenames[i] != null) {
							System.out.println("Wrote file: " + resultFilenames[i]);
						}
					}
				}	
			}
			// Unknown action
			else {
				printUsage();
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
			//e.printStackTrace();
			exitVal = 3;
		}
		System.exit(exitVal);
	}

}
