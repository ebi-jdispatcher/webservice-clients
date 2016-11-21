package uk.ac.ebi.restclient;

import com.google.common.io.Resources;
import com.sun.jersey.api.client.Client;
import com.sun.jersey.api.client.ClientResponse;
import com.sun.jersey.api.client.WebResource;
import com.sun.jersey.api.representation.Form;
import org.apache.commons.cli.*;
import uk.ac.ebi.restclient.stubs.WsParameter;
import uk.ac.ebi.restclient.stubs.WsParameters;
import uk.ac.ebi.restclient.stubs.WsResultType;
import uk.ac.ebi.restclient.stubs.WsResultTypes;

import javax.xml.bind.JAXBException;
import javax.xml.rpc.ServiceException;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Arrays;
import java.util.List;

/**
 * Created by Szymon Chojnacki on 22/08/2016.
 */
public class RestClient {

    static {
        System.setProperty("org.slf4j.simpleLogger.defaultLogLevel", "INFO");
    }

    private static final org.slf4j.Logger log = org.slf4j.LoggerFactory.getLogger(RestClient.class);

    private String revision = "$Revision$";
    private Client client;
    private final String currentJar;
    private final String defaultHost = "www.ebi.ac.uk";
    private final String defaultProtocol = "http";
    private final String defaultUrlPath = "/Tools/services/rest/";
    private String customHost;
//    private String serviceEndPoint = "http://www.ebi.ac.uk/Tools/services/rest/";
    private final String toolId;
    private final String toolName;
    private final String toolDescription;

    private final String resourcesDir = "files/";
    private final Options allOptions = new Options();
    private final Options generalOptions = new Options();
    private final Options requiredOptions = new Options();
    private final Options optionalOptions = new Options();

    private String requiredParametersMessage;
    private String optionalParametersMessage;
    private final String generalParametersMessage =
            "[General]\n"
                    + " --help                          prints help\n"
                    + " --host          string          override default host (www.ebi.ac.uk)\n"
                    + " --params                        list tool parameters\n"
                    + " --paramDetails  string          information about a parameter\n"
                    + " --sync                          Run job as synchronous task (default: asynchronous)\n"
                    + " --title         string          title for the job, surround with quotations if it contains spaces\n"
                    + " --jobid         string          job identifier\n"
                    + "\n Following options require --jobid\n"
                    + " --status                        get status of a job \n"
                    + " --resultTypes                   get list of result formats \n"
                    + " --polljob                       get results for a job\n"
                    + " --outformat     ArrayOfString   comma separated list of result type identifiers, see --resultTypes\n";

    private final String usageInfo =
            "\n"
                    + "Synchronous job:\n"
                    + "\n"
                    + "  Program checks in interval for the results and collects them when ready.\n"
                    + "  Usage: java -jar <jarFile> --sync --email <your@email> [allOptions...] sequence\n"
                    + "\n"
                    + "Asynchronous (default execution) job:\n"
                    + "\n"
                    + "  The results \n"
                    + "  are stored for up to 7 days.\n"
                    + "  Usage: java -jar <jarFile> --email <your@email> [allOptions...] sequence\n"
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
     * Entry point to the application
     *
     * @param args
     * @throws IOException
     * @throws InterruptedException
     * @throws ServiceException
     */
    public static void main(String[] args) throws IOException, InterruptedException, ServiceException, JAXBException {

        RestClient client = new RestClient();
        client.run(args);
    }


    /**
     * Load tool specific information in the constructor
     */
    private RestClient() throws IOException {

        currentJar = new java.io.File(RestClient.class.getProtectionDomain()
                .getCodeSource()
                .getLocation()
                .getPath())
                .getName();

        URL url = Resources.getResource(resourcesDir + "tool.info");
        String[] toolInfo = Resources.toString(url, Charset.defaultCharset()).split("\n");

        toolId = toolInfo[0];
        toolName = toolInfo[1];
        toolDescription = toolInfo[2];


//        serviceEndPoint = serviceEndPoint + toolId;

        log.info("Tool id: {}", toolId);
        log.info("Tool name: {}", toolName);
//        Here we do not know service endpoint yet, it depends on program arguments
//        log.info("Service endpoint: {}", getServiceEndpoint());

        setUserAgent();
    }

    private String getServiceEndpoint(){
        return new StringBuilder(defaultProtocol)
                .append("://")
                .append(customHost == null ? defaultHost : customHost)
                .append(defaultUrlPath)
                .append(toolId).toString();
    }



    /**
     * Set user agent for http request with SVN revision, EBI phrase, class name and OS name
     */
    private void setUserAgent() {
        String currentUserAgent = System.getProperty("http.agent");

        String clientVersion = revision;
        String clientUserAgent = "EBI-Sample-Client/" + clientVersion + " (" + this.getClass().getName() + "; " + System.getProperty("os.name") + ")";
        if (currentUserAgent != null) {
            System.setProperty("http.agent", clientUserAgent + " " + currentUserAgent);
        } else {
            System.setProperty("http.agent", clientUserAgent);
        }

        log.debug("http.agent: {}", System.getProperty("http.agent"));
    }


    /**
     * Return Client form Jersey library
     *
     * @return
     */
    private Client getClient() {
        if (client == null) {
            client = Client.create();
        }
        return client;
    }


    /**
     * Print usage message
     */
    public void printUsage() {
        StringBuilder sb = new StringBuilder("\n\n");

        sb.append(toolName).append('\n');
        sb.append(toolDescription).append("\n\n");
        sb.append("[Required]").append("\n");
        sb.append(requiredParametersMessage).append("\n\n");
        sb.append("[Optional]").append("\n");
        sb.append(optionalParametersMessage).append("\n\n");
        sb.append(generalParametersMessage);
        sb.append(usageInfo);

        log.info("{}", sb.toString());
    }

    /**
     * Print usage message
     */
    public void printUsageShort() {
        StringBuilder sb = new StringBuilder("\n\n");

        sb.append(toolName).append('\n');
        sb.append(toolDescription).append("\n\n");
        sb.append("java -jar " + currentJar + " --help\n");

        log.info("{}", sb.toString());
    }


    /**
     * Load tool specific options from files included in generated JAR
     *
     * @throws IOException
     */
    private void loadToolSpecificOptions() throws IOException {

        optionalParametersMessage = Resources.toString(Resources.getResource(resourcesDir + "optional.txt"), Charset.defaultCharset());
        requiredParametersMessage = Resources.toString(Resources.getResource(resourcesDir + "required.txt"), Charset.defaultCharset());

        ClientUtils.parseOptionsFromFormattedString(requiredOptions, requiredParametersMessage);
        ClientUtils.parseOptionsFromFormattedString(optionalOptions, optionalParametersMessage);

        for (Object option : generalOptions.getOptions()) {
            allOptions.addOption((Option) option);
        }

        for (Object option : requiredOptions.getOptions()) {
            allOptions.addOption((Option) option);
        }

        for (Object object : optionalOptions.getOptions()) {
            Option option = (Option) object;
            allOptions.addOption(option);
        }
    }


    /**
     * Set options common to all tools
     */
    private void addGeneralOptions() {

        generalOptions.addOption("params", "", false, "Print parameters");
        generalOptions.addOption("paramDetails", "", true, "Details about selected parameter");
        generalOptions.addOption("title", "", true, "Title for the job");
        generalOptions.addOption("jobid", "", true, "Job identifier");
        generalOptions.addOption("sync", "", false, "Run job as a synchronous task, (default: asynchronous)");
        generalOptions.addOption("status", "", false, "Status of a job");
        generalOptions.addOption("resultTypes", "", false, "Get list of output formats");
        generalOptions.addOption("polljob", "", false, "Get results for the job");
        generalOptions.addOption("outformat", "", true, "Output format");
        generalOptions.addOption("host", "", true, "Custom host");
        generalOptions.addOption("help", "", false, "Print this help text");
    }


    /**
     * Get tool's parameters from server
     *
     * @return
     */
    public WsParameters getParams() {
        ClientResponse response = getClient().resource(getServiceEndpoint() + "/parameters")
                .get(ClientResponse.class);

        ClientUtils.checkResponseStatusCode(response, 200);
        return response.getEntity(WsParameters.class);
    }


    /**
     * Get from server detailed information about queried parameter
     *
     * @param paramDetail
     * @return
     */
    public WsParameter getParam(String paramDetail) {
        ClientResponse response = getClient().resource(getServiceEndpoint() + "/parameterdetails/" + paramDetail)
                .get(ClientResponse.class);

        ClientUtils.checkResponseStatusCode(response, 200);
        return response.getEntity(WsParameter.class);
    }


    /**
     * Status of a given job.
     * The values for the status are:
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

        final String url = getServiceEndpoint() + "/status/" + jobid;
        ClientResponse response = getClient().resource(url)
                .get(ClientResponse.class);
        ClientUtils.checkResponseStatusCode(response, 200);
        return response.getEntity(String.class);
    }


    /**
     * Get result types for a job from server
     *
     * @param jobId
     * @return
     */
    public WsResultTypes getResultTypesForJobId(String jobId) {

        ClientResponse response = getClient().resource(getServiceEndpoint() + "/resulttypes/" + jobId)
                .get(ClientResponse.class);
        ClientUtils.checkResponseStatusCode(response, 200);
        return response.getEntity(WsResultTypes.class);
    }


    /**
     * Entry point to the application
     *
     * @param args
     */
    public void run(String[] args) throws IOException, ServiceException, InterruptedException, JAXBException {

        addGeneralOptions();
        loadToolSpecificOptions();


        CommandLineParser cliParser = new GnuParser();

        try {
            CommandLine cli = cliParser.parse(allOptions, args);

            // Print just basic info
            if (args.length == 0) {
                printUsageShort();
                return;
            }
            if (cli.hasOption("help")) {
                printUsage();
                return;
            }

            if (cli.hasOption("host")){
                customHost = cli.getOptionValue("host");
            }

            if (cli.hasOption("params")) {
                ClientUtils.marshallToXML(getParams());
            }
            // Details of selected parameter
            else if (cli.hasOption("paramDetails")) {
                ClientUtils.marshallToXML(getParam(cli.getOptionValue("paramDetails")));
            }

            // Submit new job
            else if (cli.hasOption("email") && cli.hasOption("sequence")) {
                String jobid = submitJob(cli, ClientUtils
                        .loadData(cli.getOptionValue("sequence")));

                // Synchronous execution
                if (cli.hasOption("sync")) {
                    log.info("JobId: {}", jobid);
                    ClientUtils.getStatusInIntervals(this, jobid, 5000L);
                    downloadResults(cli, jobid);

                    // Asynchronous (default) execution
                } else {
                    log.info("You can check status of your job with:\n" +
                            "java -jar " + currentJar + " --status --jobid {}", jobid);
                    log.info("When job status is FINISHED you can download results with:\n" +
                            "java -jar " + currentJar + " --polljob --jobid {}", jobid);
                }
            }

            // Check already submitted job
            else if (cli.hasOption("jobid")) {
                String jobid = cli.getOptionValue("jobid");

                // Check status
                if (cli.hasOption("status")) {
                    log.info(checkStatus(jobid));

                    // Check available result types
                } else if (cli.hasOption("resultTypes")) {
                    ClientUtils.marshallToXML(getResultTypesForJobId(jobid));
                }

                // Download (all/filtered) result files
                else if (cli.hasOption("polljob")) {

                    downloadResults(cli, jobid);
                } else {
                    log.warn("Please specify one of following parameters: status, resultTypes, polljob.");
                }
            } else {
                log.warn("Your parameters are not correct. Please run jar without any parameters to learn more.");
            }
        } catch (ParseException e) {
            log.warn(e.getMessage());
        }

    }


    /**
     * Download result files to specified directory
     *
     * @param cli
     * @param jobid
     * @throws IOException
     */
    public void downloadResults(CommandLine cli, String jobid) throws IOException {
        List<WsResultType> allResultTypes = getResultTypesForJobId(jobid).getAsList();
        List<WsResultType> resultTypes;

        // Augment user specified result types with file suffix
        if (cli.hasOption("outformat")) {
            resultTypes = ClientUtils.processUserOutputFormats(cli.getOptionValue("outformat"), allResultTypes);
        } else {
            resultTypes = allResultTypes;
        }

        // Iterate over filtered result types and save each result in a separate file
        for (WsResultType resultType : resultTypes) {

            String identifier = resultType.getIdentifier();
            String fileSuffix = resultType.getFileSuffix();
            String outputFile = jobid + "-" + identifier + "." + fileSuffix;
            ClientResponse response = getClient()
                    .resource(getServiceEndpoint() + "/result/" + jobid + "/" + identifier)
                    .get(ClientResponse.class);

            ClientUtils.checkResponseStatusCode(response, 200);

            InputStream inputStream = response.getEntity(InputStream.class);
            Files.copy(inputStream, Paths.get(outputFile));
            log.info("Downloaded: {}", outputFile);
        }
    }


    /**
     * Submit job for a given sequence
     *
     * @param cli
     * @param inputSeq
     * @return
     * @throws ServiceException
     * @throws IOException
     */
    private String submitJob(CommandLine cli, String inputSeq)
            throws ServiceException, IOException {

        WebResource target = getClient().resource(getServiceEndpoint() + "/run");

        Form form = new Form();
        form.putSingle("sequence", inputSeq);

        for (Option option : cli.getOptions()) {
            String optionName = option.getOpt();
            String optionType = option.getLongOpt();
            String optionValue = option.getValue();

            if (optionName.equals("sequence") || optionName.equals("sync")) {
                continue;
            }

            if (optionType.equals("ArrayOfString")) {
                form.put(optionName, Arrays.asList(optionValue.split(",")));
            } else if (optionType.equals("boolean")) {
                optionValue = optionValue.toLowerCase();
                switch (optionValue) {
                    case "true":
                    case "yes":
                    case "y":
                        optionValue = "true";
                        break;
                    case "false":
                    case "no":
                    case "n":
                        optionValue = "false";
                        break;
                    default:
                        log.warn("boolean parameter can be only 'true' or 'false'");
                        System.exit(0);
                }
                form.putSingle(optionName, optionValue);

            } else {
                form.putSingle(optionName, optionValue);
            }
        }

        ClientResponse response = target.post(ClientResponse.class, form);
        ClientUtils.checkResponseStatusCode(response, 200);

        return response.getEntity(String.class);
    }
}
