/* $Id$
 * ======================================================================
 * 
 * Copyright 2008-2013 EMBL - European Bioinformatics Institute
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
 * Abstract jDispatcher web services Java client.
 * ====================================================================== */
package uk.ac.ebi.webservices;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.PrintStream;
import java.io.Reader;
import java.lang.reflect.InvocationTargetException;
import java.rmi.RemoteException;
import javax.xml.rpc.ServiceException;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.Options;

/** Abstract class defining common methods to all jDispatcher SOAP web 
 * service clients.
 * 
 * See:
 * <a href="http://www.ebi.ac.uk/Tools/webservices/">http://www.ebi.ac.uk/Tools/webservices/</a>
 * <a href="http://www.ebi.ac.uk/Tools/webservices/tutorials/java">http://www.ebi.ac.uk/Tools/webservices/tutorials/java</a>
 */
public abstract class AbstractWsToolClient {
	/** Output level. Controlled by the --verbose and --quiet options. */
	protected int outputLevel = 1;
	/** Debug level. Controlled by the --debugLevel option. */
	private int debugLevel = 0;
	/** Maximum interval between polling events (ms). */
	private int maxCheckInterval = 60000;
	/** Temporary line for fasta sequence parsing. */
	private String tmpFastaLine = null;
	/** Buffered reader for fasta sequence input. */
	private BufferedReader fastaInputReader = null;
	/** Buffered reader for identifier list input. */
	private BufferedReader identifierListReader = null;
	/** URL for service endpoint. */
	private String serviceEndPoint = null;
	/** Generic options message. */
	private static final String genericOptsStr = "[General]\n"
	+ "\n"
	+ "      --params         :      : list tool parameters\n"
	+ "      --paramDetail    : str  : information about a parameter\n"
	+ "      --email          : str  : e-mail address, required to submit job\n"
	+ "      --title          : str  : title for the job\n"
	+ "      --async          :      : perform an asynchronous submission\n"
	+ "      --jobid          : str  : job identifier\n"
	+ "      --status         :      : get status of a job\n"
	+ "      --resultTypes    :      : get list of result formats for a job\n"
	+ "      --polljob        :      : get results for a job\n"
	+ "      --outfile        : str  : name of the file results should be written to\n"
	+ "                                (default is based on the jobid; \"-\" for STDOUT)\n"
	+ "      --outformat      : str  : output format, see --resultTypes\n"
	+ "      --help           :      : prints this help text\n"
	+ "      --quiet          :      : decrease output\n"
	+ "      --verbose        :      : increase output\n"
	+ "      --debugLevel     : int  : set debug output level\n"
	+ "\n"
	+ "Synchronous job:\n"
	+ "\n"
	+ "  The results/errors are returned as soon as the job is finished.\n"
	+ "  Usage: java -jar <jarFile> --email <your@email> [options...] seqFile\n"
	+ "  Returns: results as an attachment\n"
	+ "\n"
	+ "Asynchronous job:\n"
	+ "\n"
	+ "  Use this if you want to retrieve the results at a later time. The results \n"
	+ "  are stored for up to 7 days.\n"
	+ "  Usage: java -jar <jarFile> --async --email <your@email> [options...] seqFile\n"
	+ "  Returns: jobid\n"
	+ "\n"
	+ "  Use the jobid to query for the status of the job.\n"
	+ "  Usage: java -jar <jarFile> --status --jobid <jobId>\n"
	+ "  Returns: string indicating the status of the job.\n"
	+ "\n"
	+ "  If the job is finished, get the available result types.\n"
	+ "  Usage: java -jar <jarFile> --resultTypes --jobid <jobId>\n"
	+ "  Returns: details of the available results for the job.\n"
	+ "\n"
	+ "  If the job is finished get the results.\n"
	+ "  Usage:\n"
	+ "   java -jar <jarFile> --polljob --jobid <jobId>\n"
	+ "   java -jar <jarFile> --polljob --jobid <jobId> --outformat <format>\n"
	+ "  Returns: results in the requested format, or if not specified all \n"
	+ "  formats. By default the output file(s) are named after the job, to \n"
	+ "  specify a name for the file(s) use the --outfile option.\n";

	/** Add genetic option to command-line parser.
	 * 
	 * @param options Command-line parser.
	 */
	protected static void addGenericOptions(Options options) {
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
		options.addOption("params", "params", false, "List parameters");
		options.addOption("paramDetail", "paramDetail", true, "List parameter information");
		options.addOption("resultTypes", "resultTypes", false, "List result types for job");
		options.addOption("debugLevel", "debugLevel", true, "Debug output");
		options.addOption("endpoint", "endpoint", true, "Service endpoint URL");
	}

	/** Print the generic options usage message to STDOUT. */
	protected static void printGenericOptsUsage()  {
		System.out.println(genericOptsStr);
	}
	
	/** Set debug level. 
	 * 
	 * @param level Debug level. 0 = off.
	 */
	public void setDebugLevel(int level) {
		printDebugMessage("setDebugLevel", "Begin " + level, 1);
		if(level > -1) {
			debugLevel = level;
		}
		printDebugMessage("setDebugLevel", "End", 1);
	}

	/** Get current debug level. 
	 * 
	 * @return Debug level.
	 */
	public int getDebugLevel() {
		printDebugMessage("getDebugLevel", new Integer(debugLevel).toString(), 1);
		return debugLevel;
	}

	/** Output debug message at specified level
	 * 
	 * @param methodName Name of the method to appear in the message
	 * @param message The message
	 * @param level Level at which to output message
	 */
	protected void printDebugMessage(String methodName, String message, int level) {
		if(level <= debugLevel) {
			System.err.println("[" + methodName + "()] " + message);
		}
	}
	
	/** <p>Get the HTTP user-agent string used for java.net calls by the 
	 * client (see RFC2616).</p>
	 * 
	 * @return User-agent string.
	 */
	public String getUserAgent() {
		printDebugMessage("getUserAgent", "Begin/End", 1);
		return System.getProperty("http.agent");
	}
	
	/** <p>Set the HTTP user-agent string used for java.net calls by the 
	 * client (see RFC2616).</p>
	 * 
	 * @param userAgent User-agent string to prepend to default client 
	 * user-agent.
	 */
	public void setUserAgent(String userAgent) {
		printDebugMessage("setUserAgent", "Begin", 1);
		// Java web calls use the http.agent property as a prefix to the default user-agent.
		StringBuffer clientUserAgent = new StringBuffer();
		if(userAgent != null && userAgent.length() > 0) {
			clientUserAgent.append(userAgent);
		}
		clientUserAgent.append(getClientUserAgentString());
		if(System.getProperty("http.agent") != null) {
			clientUserAgent.append(" ").append(System.getProperty("http.agent"));
		}
		System.setProperty("http.agent", clientUserAgent.toString());
		printDebugMessage("setUserAgent", "End", 1);
	}

	/** <p>Set the HTTP User-agent header string (see RFC2616) used by the 
	 * client for java.net requests.</p>
	 */
	protected void setUserAgent() {
		printDebugMessage("setUserAgent", "Begin", 1);
		// Java web calls use the http.agent property as a prefix to the default user-agent.
		String clientUserAgent = getClientUserAgentString();
		if(System.getProperty("http.agent") != null) {
			System.setProperty("http.agent", clientUserAgent + " " + System.getProperty("http.agent"));
		}
		else System.setProperty("http.agent", clientUserAgent);
		printDebugMessage("setUserAgent", "End", 1);
	}
	
	/** Get client specific user-agent string for addition to client 
	 * user-agent string.
	 * 
	 * @return Client specific user-agent string.
	 */
	protected abstract String getClientUserAgentString();

	/** Generate a string containing the values of the fields with "get" methods. 
	 * 
	 * @param obj Object the get values from
	 * @return String containing values and method names.
	 */
	protected String objectFieldsToString(Object obj) {
		printDebugMessage("ObjectFieldsToString", "Begin", 31);
		StringBuilder strBuilder = new StringBuilder();
		try {
			@SuppressWarnings("rawtypes")
			Class objType = obj.getClass();
			printDebugMessage("ObjectFieldsToString", "objType: " + objType, 32);
			java.lang.reflect.Method[] methods = objType.getMethods();
			for(int i = 0; i < methods.length; i++) {
				String methodName = methods[i].getName();
				if(methodName.startsWith("get") && methods[i].getParameterTypes().length == 0 &&
						!methodName.equals("getClass") && !methodName.equals("getTypeDesc")) {
					printDebugMessage("ObjectFieldsToString", "invoke(): " + methodName, 32);
					Object tmpObj = methods[i].invoke(obj, new Object[0]);
					// Handle any string lists (e.g. database)
					if(tmpObj instanceof String[]) {
						String[] tmpList = (String[])tmpObj;
						strBuilder.append(methodName + ":\n");
						for(int j = 0; j < tmpList.length; j++) {
							strBuilder.append("\t" + tmpList[j] + "\n");
						}
					}
					// Otherwise just use implicit toString();
					else {
						strBuilder.append(methodName + ": " + tmpObj + "\n");
					}
				}
			}
		}
		catch(SecurityException e) {
			System.err.println(e.getMessage());
		}
		catch (IllegalArgumentException e) {
			System.err.println(e.getMessage());
		}
		catch (IllegalAccessException e) {
			System.err.println(e.getMessage());
		}
		catch (InvocationTargetException e) {
			System.err.println(e.getMessage());
		}
		printDebugMessage("ObjectFieldsToString", "End", 31);
		return strBuilder.toString();
	}

	/** Set the output level. 
	 * 
	 * @param level Output level. 0 = quiet, 1 = normal and 2 = verbose.
	 */
	public void setOutputLevel(int level) {
		printDebugMessage("setOutputLevel", "Begin " + level, 1);
		if(level > -1) {
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
	
	/** Set the maximum interval between polling events.
	 * 
	 * @param checkInterval Maximum interval in milliseconds. Must be greater than 1000.
	 */
	public void setMaxCheckInterval(int checkInterval) {
		printDebugMessage("setMaxCheckInterval", "Begin " + checkInterval, 1);
		if(checkInterval > 1000) {
			this.maxCheckInterval = checkInterval;
		}
		printDebugMessage("setMaxCheckInterval", "End", 1);
	}
	
	/** Get the maximum interval between polling events.
	 * 
	 * @return Maximum interval in milliseconds
	 */
	public int getMaxCheckInterval() {
		printDebugMessage("getMaxCheckInterval", new Integer(this.maxCheckInterval).toString(), 1);
		return this.maxCheckInterval;
	}

	/** Set the service endpoint URL for generating the service connection.
	 * 
	 * @param urlStr Service endpoint URL as a string.
	 */
	public void setServiceEndPoint(String urlStr) {
		this.serviceEndPoint = urlStr;
	}
	
	/** Get the current service endpoint URL.
	 * 
	 * @return The service endpoint URL as a string.
	 */
	public String getServiceEndPoint() {
		return this.serviceEndPoint;
	}
	
	/** Print a progress message.
	 * 
	 * @param msg The message to print.
	 * @param level The output level at or above which this message should be displayed.
	 */
	protected void printProgressMessage(String msg, int level) {
		if(outputLevel >= level) {
			System.err.println(msg);
		}
	}

	/** Read the contents of a file into a byte array.
	 * 
	 * @param file the file to read
	 * @return the contents of the file in a byte array
	 * @throws IOException if all contents not read
	 */
	public byte[] readFile(File file) throws IOException, FileNotFoundException {
		printDebugMessage("readFile", "Begin", 1);
		printDebugMessage("readFile", "file: " + file.getPath() + File.pathSeparator + file.getName(), 2);
		if(!file.exists()) {
			throw new FileNotFoundException(file.getName() + " does not exist");
		}
		InputStream is = new FileInputStream(file);
		byte[] bytes = readStream(is);
		is.close();
		printDebugMessage("readFile", "End", 1);
		return bytes;
	}

	/** Read the contents of an input stream into a byte array.
	 * 
	 * @param inStream the input steam to read
	 * @return the contents of the stream in a byte array
	 * @throws IOException if all contents not read
	 */
	public byte[] readStream(InputStream inStream) throws IOException {
		printDebugMessage("readStream", "Begin", 1);
		byte[] ret = null;
		while(inStream.available()>0)
		{
			long length = inStream.available();
			byte[] bytes = new byte[(int)length];
			int offset = 0;
			int numRead = 0;
			while(offset < bytes.length &&
					(numRead=inStream.read(bytes,offset,bytes.length-offset)) >= 0 ) {
				offset += numRead;
			}
			if (offset < bytes.length) {
				throw new IOException("Unable to read to end of stream");
			}
			printDebugMessage("readStream", "read " + bytes.length + " bytes", 2);
			if(ret==null)		
				ret = bytes;
			else
			{
				byte[] tmp = ret.clone();
				ret = new byte[ret.length+bytes.length];
				System.arraycopy(tmp,0,ret,0         ,tmp.length);
				System.arraycopy(bytes,0,ret,tmp.length,bytes.length);
			}
		}
		printDebugMessage("readStream", "End", 1);
		return ret;
	}

	/** <p>The input data can be passed as:</p>
	 * <ul>
	 * <li>a filename</li>
	 * <li>an entry identifier (e.g. UNIPROT:WAP_RAT)</li>
	 * <li>raw data (e.g. "MRCSISLVLG")</li>
	 * <li>data from standard input (STDIN)</li>
	 * </ul>
	 * <p>This method gets the data to be passed to the service, checking for 
	 * a file and loading it if necessary.</p>
	 * 
	 * @param fileOptionStr Filename or entry identifier.
	 * @return Data to use as input as a byte array.
	 * @throws IOException
	 */
	public byte[] loadData(String fileOptionStr) throws IOException {
		printDebugMessage("loadData", "Begin", 1);
		printDebugMessage("loadData", "fileOptionStr: " + fileOptionStr, 2);
		byte[] retVal = null;
		if(fileOptionStr != null) {
			if(fileOptionStr.equals("-")) { // STDIN.
				// TODO: wait for input from STDIN.
				retVal = readStream(System.in);
			}
			else if(new File(fileOptionStr).exists()) { // File.
				retVal = readFile(new File(fileOptionStr));
			} else { // Entry Id or raw data.
				retVal = fileOptionStr.getBytes();
			}
		}
		printDebugMessage("loadData", "End", 1);
		return retVal;
	}

	/** Write a string to a file.
	 * 
	 * @param file the file to create/write to
	 * @param data the string to write
	 * @return an integer value indicating success/failure
	 * @throws IOException if there is a problem with the file operations
	 */
	public int writeFile(File file, String data) throws IOException {
		printDebugMessage("writeFile", "Begin", 1);
		printDebugMessage("writeFile", "file: " + file.getName(), 2);
		printDebugMessage("writeFile", "data: " + data.length() + " characters", 2);
		OutputStream os = new FileOutputStream(file);
		PrintStream p = new PrintStream( os );
		p.println (data);
		p.close();
		printDebugMessage("writeFile", "End", 1);
		return 0;
	}
	
	/** Write an array of bytes to a file.
	 * 
	 * @param file the file to create/write to
	 * @param data the bytes to write
	 * @return an integer value indicating success/failure
	 * @throws IOException if there is a problem with the file operations
	 */
	public int writeFile(File file, byte[] data) throws IOException {
		printDebugMessage("writeFile", "Begin", 1);
		printDebugMessage("writeFile", "file: " + file.getName(), 2);
		printDebugMessage("writeFile", "data: " + data.length + " bytes", 2);
		OutputStream os = new FileOutputStream(file);
		os.write (data);
		os.close();
		printDebugMessage("writeFile", "End", 1);
		return 0;
	}
	
	/** Get an instance of the service proxy to use with other methods.
	 * 
	 * @throws ServiceException
	 */
	abstract protected void srvProxyConnect() throws ServiceException;

	/** Get list of tool parameter names.
	 * 
	 * @return String array containing list of parameter names
	 * @throws ServiceException
	 * @throws RemoteException
	 */
	abstract public String[] getParams() throws ServiceException, RemoteException;

	/** Print list of parameter names for tool.
	 * 
	 * @throws RemoteException
	 * @throws ServiceException
	 */
	protected void printParams() throws RemoteException, ServiceException {
		printDebugMessage("printParams", "Begin", 1);
		String[] paramList = getParams();
		for(int i = 0; i < paramList.length; i++) {
			System.out.println(paramList[i]);
		}
		printDebugMessage("printParams", "End", 1);
	}

	/** Print information about a tool parameter
	 * 
	 * @param paramName Name of the tool parameter to get information for.
	 * @throws RemoteException
	 * @throws ServiceException
	 */
	abstract protected void printParamDetail(String paramName) throws RemoteException, ServiceException;

	/** Get the status of a submitted job given its job identifier.
	 * 
	 * @param jobid The job identifier
	 * @return Job status as a string.
	 * @throws IOException
	 * @throws ServiceException
	 */
	abstract public String checkStatus(String jobid) throws IOException, ServiceException;

	/** Poll the job status until the job completes.
	 * 
	 * @param jobid The job identifier.
	 * @throws ServiceException
	 */
	public void clientPoll(String jobId) throws ServiceException {
		printDebugMessage("clientPoll", "Begin", 1);
		printDebugMessage("clientPoll", "jobId: " + jobId, 2);
		int checkInterval = 1000;
		String status = "PENDING";
		// Check status and wait if not finished
		while(status.equals("RUNNING") || status.equals("PENDING")) {
			try {
				status = this.checkStatus(jobId);
				printProgressMessage(status, 1);
				if(status.equals("RUNNING") || status.equals("PENDING")) {
					// Wait before polling again.
					printDebugMessage("clientPoll", "checkInterval: " + checkInterval, 2);
					Thread.sleep(checkInterval);
					checkInterval *= 2;
					if(checkInterval > this.maxCheckInterval) checkInterval = this.maxCheckInterval;
				}
			}
			catch(InterruptedException ex) {
				// Ignore
			}
			catch(IOException ex) {
				// Report and continue
				System.err.println("Warning: " + ex.getMessage());
			}
		}
		printDebugMessage("clientPoll", "End", 1);
	}

	/** Print details of the available result types for a job.
	 * 
	 * @param jobId Job identifier to check for result types.
	 * @throws ServiceException
	 * @throws RemoteException
	 */
	abstract protected void printResultTypes(String jobId) throws ServiceException, RemoteException;

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
	abstract public String[] getResults(String jobid, String outfile, String outformat) throws IOException, ServiceException;
	
	/** Set input fasta format sequence data file.
	 * 
	 * @param fastaFileName Name of the file.
	 * @throws FileNotFoundException 
	 */
	public void setFastaInputFile(String fastaFileName) throws FileNotFoundException {
		Reader inputReader = null;
		if(fastaFileName.equals("-")) { // STDIN
			inputReader = new InputStreamReader(System.in);
		}
		else { // File
			inputReader = new FileReader(fastaFileName);
		}
		this.fastaInputReader = new BufferedReader(inputReader);
	}
	
	/** Get next fasta sequence from input sequence file.
	 * 
	 * NB: Assumes files contains correctly formated input sequences,
	 * i.e. are in fasta sequence format, and that the file contains only
	 * fasta formated sequences. For a more generic solution see BioJava.
	 * 
	 * @return Fasta input sequence from file.
	 * @throws IOException
	 */
	public String nextFastaSequence() throws IOException {
		String retVal = null;
		// Read lines until one begins with '>'.
		while(this.fastaInputReader.ready() &&
				(this.tmpFastaLine == null || !this.tmpFastaLine.startsWith(">"))) {
			this.tmpFastaLine = this.fastaInputReader.readLine();
		}
		// Read fasta header line.
		if(this.tmpFastaLine.startsWith(">")) {
			this.printProgressMessage("Sequence: " + tmpFastaLine, 1);
			StringBuffer tmpFastaSeq = new StringBuffer();
			tmpFastaSeq.append(tmpFastaLine).append("\n");
			// Read lines until EOF or a line begins with '>'.
			this.tmpFastaLine = this.fastaInputReader.readLine();
			while(this.fastaInputReader.ready() &&
					(this.tmpFastaLine == null || !this.tmpFastaLine.startsWith(">"))) {
				this.tmpFastaLine = this.fastaInputReader.readLine();
				if(!tmpFastaLine.startsWith(">")) {
					tmpFastaSeq.append(tmpFastaLine).append("\n");
				}
			}
			retVal = tmpFastaSeq.toString();
		}
		return retVal;
	}
	
	/** Close the input fasta sequence file.
	 * 
	 * @throws IOException
	 */
	public void closeFastaFile() throws IOException {
		this.fastaInputReader.close();
		this.fastaInputReader = null;
	}
	
	/**
	 * Submit a job using command-line information to construct the input.
	 * 
	 * @param cli
	 *            Command-line parameters.
	 * @param inputSeq
	 *            Data input.
	 * @throws ServiceException
	 * @throws IOException
	 */
	abstract public void submitJobFromCli(CommandLine cli, String inputData)
			throws ServiceException, IOException;

	public void multifastaSubmitCli(String dataOption, CommandLine cli) throws IOException, ServiceException {
		this.printDebugMessage("multifastaSubmitCli", "Mode: multifasta", 11);
		int numSeq = 0;
		this.setFastaInputFile(dataOption);
		// Loop over input sequences, submitting each one.
		String fastaSeq = null;
		fastaSeq = this.nextFastaSequence();
		this.printDebugMessage("multifastaSubmitCli", "fastaSeq: " + fastaSeq, 12);
		while (fastaSeq != null) {
			numSeq++;
			this.submitJobFromCli(cli, fastaSeq);
			fastaSeq = this.nextFastaSequence();
		}
		this.closeFastaFile();
		this.printProgressMessage("Processed " + numSeq
				+ " input sequences", 2);
	}
	
	/** Set the identifier list input file.
	 *  
	 * @param fileName Name of the identifier list file.
	 * @throws FileNotFoundException
	 */
	public void setIdentifierListFile(String fileName) throws FileNotFoundException {
		Reader inputReader = null;
		if(fileName.equals("-")) { // STDIN
			inputReader = new InputStreamReader(System.in);
		}
		else { // File
			inputReader = new FileReader(fileName);
		}
		this.identifierListReader = new BufferedReader(inputReader);
	}
	
	/** Get the next identifier from the identifier list file.
	 * 
	 * NB: Assumes identifiers are in DB:ID format.
	 * 
	 * @return An identifier.
	 * @throws IOException
	 */
	public String nextIdentifier() throws IOException {
		String retVal = null;
		// Read lines until EOF or a line contains a ':'.
		String tmpLine = this.identifierListReader.readLine();
		while(this.identifierListReader.ready() &&
				(tmpLine == null || !(tmpLine.indexOf(':') > 0))) {
			this.printDebugMessage("nextIdentifier", "tmpLine: " + tmpLine, 12);
			tmpLine = this.identifierListReader.readLine();
		}
		this.printDebugMessage("nextIdentifier", "tmpLine: " + tmpLine, 12);
		if(tmpLine != null && tmpLine.indexOf(':') > 0) {
			retVal = tmpLine;
		}
		return retVal;
	}
	
	/** Close the identifier list input file.
	 * 
	 * @throws IOException
	 */
	public void closeIdentifierListFile() throws IOException {
		this.identifierListReader.close();
		this.identifierListReader = null;
	}
	
	public void idlistSubmitCli(String dataOption, CommandLine cli) throws IOException, ServiceException {
		this.printDebugMessage("main", "Mode: Id list", 11);
		int numId = 0;
		this.setIdentifierListFile(dataOption.substring(1));
		// Loop over input sequences, submitting each one.
		String id = null;
		id = this.nextIdentifier();
		while (id != null) {
			numId++;
			this.printProgressMessage("ID: " + id, 1);
			this.submitJobFromCli(cli, id);
			id = this.nextIdentifier();
		}
		this.closeIdentifierListFile();
		this.printProgressMessage("Processed " + numId
				+ " input identifiers", 2);
	}
}
