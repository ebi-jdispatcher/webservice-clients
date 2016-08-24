package uk.ac.ebi.restclient;

import com.sun.jersey.api.client.Client;
import com.sun.jersey.api.client.ClientResponse;
import com.sun.jersey.api.client.WebResource;
import com.sun.jersey.api.representation.Form;
import org.apache.commons.cli.*;
import sun.reflect.generics.reflectiveObjects.NotImplementedException;
import uk.ac.ebi.restclient.stubs.WsParameter;
import uk.ac.ebi.restclient.stubs.WsParameters;
import uk.ac.ebi.restclient.stubs.WsResultType;
import uk.ac.ebi.restclient.stubs.WsResultTypes;

import javax.xml.rpc.ServiceException;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.rmi.RemoteException;
import java.util.List;

/**
 * Created by chojnasm on 22/08/2016.
 */
public abstract class AbstractRestClient {

    public String revision = "$Revision: 2640 $";
    private Client client = null;
    protected String serviceEndPoint;
    protected Options options = new Options();

    abstract void addToolSpecificOptions() throws NotImplementedException;

    abstract void addToolSpecificParameters(CommandLine cli, Form form);

    /**
     * @return
     */
    protected Client getClient() {
        if (client == null) {
            client = Client.create();
        }
        return client;
    }

    protected String toolSpecificUsageMessage;
    protected static final String genericOptsStr =
            "[General]\n"
                    + "\n"
                    + "      --params         :      : list tool parameters\n"
                    + "      --paramDetail    : str  : information about a parameter\n"
                    + "      --sync           :      : Run job as synchronous task (default: asynchronous)\n"
                    + "      --title          : str  : title for the job, surround with quotations if it contains spaces\n"
                    + "      --jobid          : str  : job identifier\n"
                    + "      --status         :      : get status of a job\n"
                    + "      --resultTypes    :      : get list of result formats for a job\n"
                    + "      --polljob        :      : get results for a job\n"
                    + "      --outformat      : str  : comma separated list of result type identifiers, see --resultTypes\n"
                    + "      --help           :      : prints this help text\n"
                    + "\n"
                    + "Synchronous job:\n"
                    + "\n"
                    + "  Program checks in interval for the results and collects them when ready.\n"
                    + "  Usage: java -jar <jarFile> --sync --email <your@email> [options...] seqFile\n"
                    + "  Returns: results as an attachment\n"
                    + "\n"
                    + "Asynchronous (default execution) job:\n"
                    + "\n"
                    + "  The results \n"
                    + "  are stored for up to 7 days.\n"
                    + "  Usage: java -jar <jarFile> --email <your@email> [options...] seqFile\n"
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

    /**
     * Print usage message.
     */
    protected void printUsage(boolean ifPrintGenericOptions) {
        System.out.println(this.toolSpecificUsageMessage);
        if (ifPrintGenericOptions) {
            System.out.println(genericOptsStr);
        }
    }


    /**
     *
     */
    protected void addGeneralOptions() {
        options.addOption("email", "email", true, "Your e-mail address");
        options.addOption("params", "params", false, "Print parameters");
        options.addOption("paramDetails", "paramDetails", true, "Details about selected parameter");
        options.addOption("title", "title", true, "Title for the job");
        options.addOption("jobid", "jobid", true, "Job identifier");
        options.addOption("sync", "sync", false, "Run job as a synchronous task, (default: asynchronous)");
        options.addOption("status", "status", false, "Status of a job");
        options.addOption("resultTypes", "resultTypes", false, "Get list of output formats");
        options.addOption("polljob", "polljob", false, "Get results for the job");
        options.addOption("outformat", "outformat", true, "Output format");
        options.addOption("help", "help", false, "Print this help text");
    }

    /**
     *
     */
    protected void printParams() {

        ClientResponse response = getClient().resource(this.serviceEndPoint + "/parameters")
                .get(ClientResponse.class);

        AbstractUtils.checkResponseStatusCode(response, 200);
        WsParameters output = response.getEntity(WsParameters.class);
        AbstractUtils.marshallToXML(output);
    }

    /**
     * @param paramDetail
     */
    protected void printParamDetail(String paramDetail) {
        ClientResponse response = getClient().resource(this.serviceEndPoint + "/parameterdetails/" + paramDetail)
                .get(ClientResponse.class);

        AbstractUtils.checkResponseStatusCode(response, 200);
        WsParameter output = response.getEntity(WsParameter.class);
        AbstractUtils.marshallToXML(output);
    }

    /**
     * Status of a given job.
     * The values for the status are:
     * <p>
     * RUNNING: the job is currently being processed.
     * FINISHED: job has finished, and the results can then be retrieved.
     * ERROR: an error occurred attempting to get the job status.
     * FAILURE: the job failed.
     * NOT_FOUND: the job cannot be found.
     *
     * @param jobid
     * @return
     * @throws IOException
     * @throws ServiceException
     */
    public String checkStatus(String jobid) throws IOException, ServiceException {

        ClientResponse response = getClient().resource(this.serviceEndPoint + "/status/" + jobid)
                .get(ClientResponse.class);
        AbstractUtils.checkResponseStatusCode(response, 200);
        return response.getEntity(String.class);
    }

    /**
     * @param jobId
     * @throws ServiceException
     * @throws RemoteException
     */
    protected void printResultTypes(String jobId) throws ServiceException, RemoteException {

        AbstractUtils.marshallToXML(getResultTypesForJobId(jobId));
    }

    /**
     * @param jobId
     * @return
     */
    public WsResultTypes getResultTypesForJobId(String jobId) {

        ClientResponse response = getClient().resource(this.serviceEndPoint + "/resulttypes/" + jobId)
                .get(ClientResponse.class);
        AbstractUtils.checkResponseStatusCode(response, 200);
        return response.getEntity(WsResultTypes.class);
    }

    /**
     * @param args
     */
    protected void run(String[] args) {

        // Configure command-line options

        // General options
        this.addGeneralOptions();

        // Tool specific options
        this.addToolSpecificOptions();



        CommandLineParser cliParser = new GnuParser();

        try {
            CommandLine cli = cliParser.parse(options, args);

            // Print just basic info
            if (args.length == 0) {
                printUsage(false);

                // Print full documentation
            } else if (cli.hasOption("help")) {
                printUsage(true);

                // List parameters
            } else if (cli.hasOption("params")) {
                this.printParams();
            }
            // Details of selected parameter
            else if (cli.hasOption("paramDetails")) {
                this.printParamDetail(cli.getOptionValue("paramDetails"));
            }

            // Submit new job
            else if (cli.hasOption("email") && cli.hasOption("seqFile")) {
                String jobid = this.submitJob(cli, new String(AbstractUtils
                        .loadData(cli.getOptionValue("sequence"))));

                // Synchronous execution
                if (cli.hasOption("sync")) {
                    System.out.println("JobId: " + jobid);
                    AbstractUtils.getStatusInIntervals(this, jobid, 5000L);

                    // Asynchronous (default) execution
                } else {
                    System.out.println("You can check status of your job with:\n" +
                            "java -jar <jarfile> --status --jobid " + jobid);
                }
            }

            // Check already submitted job
            else if (cli.hasOption("jobid")) {
                String jobid = cli.getOptionValue("jobid");

                // Check status
                if (cli.hasOption("status")) {
                    System.out.println(this.checkStatus(jobid));

                    // Check available result types
                } else if (cli.hasOption("resultTypes")) {
                    this.printResultTypes(jobid);
                }

                // Download (all/filtered) result files
                else if (cli.hasOption("polljob")) {

                    List<WsResultType> allResultTypes = this.getResultTypesForJobId(jobid).getAsList();
                    List<WsResultType> resultTypes;

                    // Augment user specified result types with file suffix
                    if (cli.hasOption("outformat")) {
                        resultTypes = AbstractUtils.processUserOutputFormats(cli.getOptionValue("outformat"), allResultTypes);
                    } else {
                        resultTypes = allResultTypes;
                    }

                    // Iterate over filtered result types and save each result in a separate file
                    for (WsResultType resultType : resultTypes) {

                        String identifier = resultType.getIdentifier();
                        String fileSuffix = resultType.getFileSuffix();
                        String outputFile = jobid + "-" + identifier + "." + fileSuffix;
                        ClientResponse response = getClient()
                                .resource(this.serviceEndPoint + "/result/" + jobid + "/" + identifier)
                                .get(ClientResponse.class);

                        AbstractUtils.checkResponseStatusCode(response, 200);

                        InputStream inputStream = response.getEntity(InputStream.class);
                        Files.copy(inputStream, Paths.get(outputFile));
                    }
                }
            }
        } catch (ParseException e) {
            System.out.println("\nAccepted values:\n");
            for(Object object : options.getOptions()){
                Option option = (Option)object;
                System.out.println("--"+option.getOpt());
            }
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        } catch (ServiceException e) {
            e.printStackTrace();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

    }

    /**
     * @param cli
     * @param inputSeq
     * @return
     * @throws ServiceException
     * @throws IOException
     */
    public String submitJob(CommandLine cli, String inputSeq)
            throws ServiceException, IOException {

        WebResource target = getClient().resource(this.serviceEndPoint + "/run");

        Form form = new Form();
        form.putSingle("email", cli.getOptionValue("email"));
        form.putSingle("sequence", inputSeq);


        if (cli.hasOption("title")) {
            form.putSingle("title", cli.getOptionValue("title"));
        }

        addToolSpecificParameters(cli, form);

        ClientResponse response = target.post(ClientResponse.class, form);
        AbstractUtils.checkResponseStatusCode(response, 200);

        return response.getEntity(String.class);

    }

}
