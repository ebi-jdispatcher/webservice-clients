/* $Id$
 * ======================================================================
 * jDispatcher NCBI BLAST SOAP web service Java client.
 * ====================================================================== */
package uk.ac.ebi.webservices.jdispatcher;

import java.io.*;
import org.apache.commons.cli.*;
import uk.ac.ebi.webservices.jdispatcher.ncbiblast.*;

/** jDispatcher NCBI BLAST SOAP web service Java client.
 * 
 * See:
 * <a href="http://www.ebi.ac.uk/Tools/Webservices/services/ncbiblast">http://www.ebi.ac.uk/Tools/Webservices/services/ncbiblast</a>
 * <a href="http://www.ebi.ac.uk/Tools/Webservices/clients/ncbiblast">http://www.ebi.ac.uk/Tools/Webservices/clients/ncbiblast</a>
 * <a href="http://www.ebi.ac.uk/Tools/Webservices/tutorials/java">http://www.ebi.ac.uk/Tools/Webservices/tutorials/java</a>
 */
public class NCBIBlastClient {
	/** Service proxy */
	private JDispatcherService_PortType srvProxy = null;
	/** Verbosity level */
	private int outputLevel = 1;
	/** Usage message */
	private static final String usageMsg = "NCBI BLAST\n"
		+ "==========\n"
		+ "   \n"
		+ "Rapid sequence database search programs utilizing the BLAST algorithm\n"
		+ "    \n"
		+ "For more detailed help information refer to \n"
		+ "http://www.ebi.ac.uk/blastall/blastall_help_frame.html\n"
		+ "\n"
		+ "[Required]\n"
		+ "\n"
		+ "  -p, --program    : str  : BLAST program to use: blastn, blastp, blastx, \n"
		+ "                            tblastn or tblastx\n"
		+ "  -D, --database   : str  : database to search\n"
		+ "  seqFile          : file : query sequence (\"-\" for STDIN)\n"
		+ "\n"
		+ "  -m, --matrix     : str  : scoring matrix\n"
		+ "  -e, --exp        : real : 0<E<= 1000. Statistical significance threshold \n"
		+ "                            for reporting database sequence matches.\n"
		+ "  -f, --filter     :      : display the filtered query sequence in the output\n"
		+ "  -A, --align      : int  : number of alignments to be reported\n"
		+ "  -s, --scores     : int  : number of scores to be reported\n"
		+ "  -n, --numal      : int  : Number of alignments\n"
                + "  -u, --match      : int  : Match score\n"
                + "  -v, --mismatch   : int  : Mismatch score\n"
		+ "  -o, --opengap    : int  : Gap open penalty\n"
		+ "  -x, --extendgap  : int  : Gap extension penalty\n"
		+ "  -d, --dropoff    : int  : Drop-off\n"
		+ "  -g, --gapalign   :      : Optimise gapped alignments\n"
		+ "\n"
		+ "[General]\n"
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
		+ "  Usage: java -jar WSNCBIBlast.jar --email <your@email> [options...] seqFile\n"
		+ "  Returns: results as an attachment\n"
		+ "\n"
		+ "Asynchronous job:\n"
		+ "\n"
		+ "  Use this if you want to retrieve the results at a later time. The results \n"
		+ "  are stored for up to 24 hours. \n"
		+ "  Usage: java -jar WSNCBIBlast.jar --async --email <your@email> [options...] seqFile\n"
		+ "  Returns: jobid\n"
		+ "\n"
		+ "  Use the jobid to query for the status of the job. If the job is finished, \n"
		+ "  it also returns the results/errors.\n"
		+ "  Usage: java -jar WSNCBIBlast.jar --polljob --jobid <jobId> [--outfile string]\n"
		+ "  Returns: string indicating the status of the job and if applicable, results \n"
		+ "  as an attachment.\n";

	/** Print the usage message to STDOUT.
	 */
	private static void printUsage()  {
		System.out.println(usageMsg);
	}
	
	/** Get an instance of the service proxy to use with other methods.
	 * 
	 * @throws javax.xml.rpc.ServiceException
	 */
	private void srvProxyConnect() throws javax.xml.rpc.ServiceException {
		if(this.srvProxy == null) {
			JDispatcherService_Service service =  new JDispatcherService_ServiceLocator();
			this.srvProxy = service.getJDispatcherServiceHttpPort();
		}
	}

	/** Get the web service proxy.
	 * 
	 * @return The web service proxy.
	 * @throws javax.xml.rpc.ServiceException
	 */
	public JDispatcherService_PortType getSrvProxy() throws javax.xml.rpc.ServiceException {
		this.srvProxyConnect(); // Ensure the service proxy exists
		return this.srvProxy;
	}

	/** Get the status of a submitted job given its job identifier.
	 * 
	 * @param jobid The job identifier
	 * @return Job status as a string.
	 * @throws IOException
	 * @throws javax.xml.rpc.ServiceException
	 */
	public String checkStatus(String jobid) throws IOException, javax.xml.rpc.ServiceException {
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
		this.srvProxyConnect(); // Ensure the service proxy exists
		return this.srvProxy.;	
	} /*

	/** Get the results for a job and save them to files.
	 * 
	 * @param jobid The job identifer.
	 * @param outfile The base name of the file to save the results to. If
	 * null the jobid will be used.
	 * @param outformat The name of the data format to save, e.g. toolraw 
	 * or toolxml. If null all available data formats will be saved.
	 * @return Array of filenames
	 * @throws IOException
	 * @throws javax.xml.rpc.ServiceException
	 */
	public String[] getResults(String jobid, String outfile, String outformat) throws IOException, javax.xml.rpc.ServiceException {
		String[] retVal = null;
		this.srvProxyConnect(); // Ensure the service proxy exists
		clientPoll(jobid); // Wait for job to finish
		// Set the base name for the output file.
		String basename = (outfile != null) ? outfile : jobid;
		// Get result types
		String[] results = this.srvProxy.getResultTypes(jobid);
		if(outformat == null) {
			retVal = new String[results.length];
		} else {
			retVal = new String[2];
		}
		for(int i = 0; i < results.length; i++) {
			WSFile file = results[i];
			if(outputLevel > 2) { // Verbose output
				System.err.println("File type: " + file.getType());
			}
			// Get the results
			if(outformat == null || outformat.equals(file.getType())) {
				byte[] resultbytes = this.srvProxy.poll(jobid, file.getType());
				if(resultbytes == null) {
					System.err.println("Null result for " + file.getType() + "!");
				} else {
					if(outputLevel > 2) { // Verbose output
						System.err.println("Result bytes length: " + resultbytes.length);
					}
					// Write the results to a file
					String result = new String(resultbytes);
					if(basename.equals("-")) { // STDOUT
						System.out.print(results);
					}
					else { // File
						String filename = basename + "." + file.getExt();
						FileUtil.writeFile(new File(filename), result);
						retVal[i] = filename;
					}
				}
			}
		}
		return retVal;
	}

	/** Submit a job to the service.
	 * 
	 * @param params Input parameters for the job.
	 * @param content Data to run the job on.
	 * @return The job identifer.
	 * @throws java.rmi.RemoteException
	 * @throws javax.xml.rpc.ServiceException
	 */
	public String runApp(InputParameters params, Data[] content) throws java.rmi.RemoteException, javax.xml.rpc.ServiceException {
		String retVal = null;
		this.srvProxyConnect(); // Ensure the service proxy exists
		retVal = srvProxy.runNCBIBlast(params, content);
		return retVal;
	}

	/** Poll the job status until the job completes.
	 * 
	 * @param jobid The job identifer.
	 * @throws javax.xml.rpc.ServiceException
	 */
	public void clientPoll(String jobId) throws javax.xml.rpc.ServiceException {
		String status = "PENDING";
		// Check status and wait if not finished
		while(status.equals("RUNNING") || status.equals("PENDING")) {
			try {
				status = this.checkStatus(jobId);
				if(this.outputLevel > 0) {
					System.err.println(status);
				}
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
	public static Data[] loadData(String fileOptionStr) throws IOException {
		Data[] inputs = new Data[1];
		if(fileOptionStr != null) {
			Data input= new Data();
			input.setType("sequence");
			if(fileOptionStr.equals("-")) { // STDIN
				String fileContent = FileUtil.readStream(System.in);
				input.setContent(fileContent);
			}
			else if(new File(fileOptionStr).exists()) { // File
				String fileContent = FileUtil.readFile(new File(fileOptionStr));
				input.setContent(fileContent);
			} else { // Entry Id
				input.setContent(fileOptionStr);
			}
			inputs[0]=input;
		}
		return inputs;
	}

	/** Build input parameters structure from command-line options
	 * 
	 * @param line Command line options
	 * @return input Input parameters structure for use with runApp().
	 * @throws IOException
	 */
	public static InputParameters loadParams(CommandLine line) throws IOException {
		InputParameters params = new InputParameters();
		// Standard options
		if (line.hasOption("email")) params.setEmail(line.getOptionValue("email")); 
		params.setAsync(true); // Always perform an async submission
		// Tool specific options
		if (line.hasOption("p")) params.setProgram(line.getOptionValue("p")); 	
		if (line.hasOption("D")) params.setDatabase(line.getOptionValue("D"));
		if (line.hasOption("m")) params.setMatrix(line.getOptionValue("m"));
		if (line.hasOption("e")) params.setExp(Float.parseFloat(line.getOptionValue("e")));
		else params.setExp(1.0F);
                if (line.hasOption("u")) params.setMatch(Integer.parseInt(line.getOptionValue("u")));
                if (line.hasOption("v")) params.setMismatch(Integer.parseInt(line.getOptionValue("v")));
		if (line.hasOption("o")) params.setOpengap(Integer.parseInt(line.getOptionValue("o"))); 
		if (line.hasOption("x")) params.setExtendgap(Integer.parseInt(line.getOptionValue("x"))); 
		if (line.hasOption("d")) params.setDropoff(Integer.parseInt(line.getOptionValue("d"))); 
		if (line.hasOption("A")) params.setAlign(Integer.parseInt(line.getOptionValue("A"))); 
		if (line.hasOption("s")) params.setScores(Integer.parseInt(line.getOptionValue("s"))); 
		if (line.hasOption("n")) params.setNumal(Integer.parseInt(line.getOptionValue("n"))); 
		if (line.hasOption("g")) params.setGapalign(true); 
		if (line.hasOption("f")) params.setFilter(line.getOptionValue("f"));

		return params;
	}

	/** Entry point for running as an application
	 * 
	 * @param args list of command-line options
	 */
	public static void main(String[] args) {
		// TODO Auto-generated method stub

	}

}
