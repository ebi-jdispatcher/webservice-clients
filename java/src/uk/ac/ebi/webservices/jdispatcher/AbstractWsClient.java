/* $Id$
 * ======================================================================
 * Abstract jDispatcher web services Java client.
 * ====================================================================== */
package uk.ac.ebi.webservices.jdispatcher;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.PrintStream;

/** Abstract class defining common methods to all jDispatcher SOAP web 
 * service clients.
 * 
 * See:
 * <a href="http://www.ebi.ac.uk/Tools/webservices/tutorials/java">http://www.ebi.ac.uk/Tools/webservices/tutorials/java</a>
 */
public abstract class AbstractWsClient {
	/** Output level. Controlled by the --verbose and --quiet options. */
	protected int outputLevel = 1;
	/** Debug level */
	private static int debugLevel = 0;
	/** Maximum interval between polling events (ms) */
	private int maxCheckInterval = 60000; 
	/** Generic options message */
	private static final String genericOptsStr = "[General]\n"
	+ "\n"
	+ "      --help       :      : prints this help text\n"
	+ "      --outfile    : str  : name of the file results should be written to \n"
	+ "                            (default is based on the jobid; \"-\" for STDOUT)\n"
	+ "      --async      :      : forces to make an asynchronous query\n"
	+ "      --email      : str  : e-mail address \n"
	+ "      --polljob    :      : Poll for the status of a job\n"
	+ "      --jobid      : str  : jobid that was returned when an asynchronous job \n"
	+ "                            was submitted.\n"
	+ "   \n"
	+ "Synchronous job:\n"
	+ "\n"
	+ "  The results/errors are returned as soon as the job is finished.\n"
	+ "  Usage: java -jar <jarFile> --email <your@email> [options...] seqFile\n"
	+ "  Returns: results as an attachment\n"
	+ "\n"
	+ "Asynchronous job:\n"
	+ "\n"
	+ "  Use this if you want to retrieve the results at a later time. The results \n"
	+ "  are stored for up to 24 hours. \n"
	+ "  Usage: java -jar <jarFile> --async --email <your@email> [options...] seqFile\n"
	+ "  Returns: jobid\n"
	+ "\n"
	+ "  Use the jobid to query for the status of the job. If the job is finished, \n"
	+ "  it also returns the results/errors.\n"
	+ "  Usage: java -jar <jarFile> --polljob --jobid <jobId> [--outfile string]\n"
	+ "  Returns: string indicating the status of the job and if applicable, results \n"
	+ "  as an attachment.\n";
 
	/** Print the generic options usage message to STDOUT.
	 */
	protected static void printGenericOptsUsage()  {
		System.out.println(genericOptsStr);
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
	
	/** Set debug level. 
	 * 
	 * @param level Debug level.
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

	/** Set the output level. 
	 * 
	 * @param level Output level
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
	 * @param checkInterval Maximum interval in milliseconds
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

	/** Read the contents of a file into a string.
	 * 
	 * @param file the file to read
	 * @return the contents of the file in a string
	 * @throws IOException if all contents not read
	 */
	public String readFile(File file) throws IOException, FileNotFoundException {
		printDebugMessage("readFile", "Begin", 1);
		printDebugMessage("readFile", "file: " + file.getPath() + File.pathSeparator + file.getName(), 2);
		if(!file.exists()) {
			throw new FileNotFoundException(file.getName());
		}
		InputStream is = new FileInputStream(file);
		long length = file.length();
		byte[] bytes = new byte[(int)length];
		int offset = 0;
		int numRead = 0;
		while(offset < bytes.length && (numRead=is.read(bytes,offset,bytes.length-offset)) >= 0 ) {
			offset += numRead;
		}
		if (offset < bytes.length) {
			throw new IOException("...");
		}
		is.close();
		printDebugMessage("readFile", "read " + bytes.length + " bytes", 2);
		printDebugMessage("readFile", "End", 1);
		return new String(bytes);
	}

	/** Read the contents of an input stream into a string.
	 * 
	 * @param inStream the input steam to read
	 * @return the contents of the stream in a string
	 * @throws IOException if all contents not read
	 */
	public String readStream(InputStream inStream) throws IOException {
		printDebugMessage("readStream", "Begin", 1);
		String retVal = null;
		StringBuffer strBuf = new StringBuffer();
		InputStreamReader inReader = new InputStreamReader(inStream);
		BufferedReader inBufReader = new BufferedReader(inReader);
		while(inBufReader.ready()) {
			strBuf.append(inBufReader.readLine() + System.getProperty("line.separator"));
		}
		if(strBuf.length() > 0) {
			retVal = strBuf.toString();
		}
		printDebugMessage("readStream", "read " + retVal.length() + " characters", 2);
		printDebugMessage("readStream", "End", 1);
		return retVal;
	}

	/** Write a string to a file
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
	
	/** Write bytes to a file
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
}
