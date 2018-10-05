package restclient;

// Copyright 2012-2018 EMBL - European Bioinformatics Institute
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// Java Client Automatically generated with:
// https://github.com/ebi-wp/webservice-clients-generator
//
// (REST) web service Java client.

import com.google.common.io.Resources;
import com.sun.jersey.api.client.Client;
import com.sun.jersey.api.client.ClientResponse;
import com.sun.jersey.api.client.WebResource;
import com.sun.jersey.api.representation.Form;
import org.apache.commons.cli.*;
import restclient.stubs.WsParameter;
import restclient.stubs.WsParameters;
import restclient.stubs.WsResultType;
import restclient.stubs.WsResultTypes;

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


public class RestClient {

    static {
        System.setProperty("org.slf4j.simpleLogger.defaultLogLevel", "WARN");
    }

    private static final org.slf4j.Logger log = org.slf4j.LoggerFactory.getLogger(RestClient.class);

    private String revision = "";
    private Client client;
    private final String currentJar;
    private final String defaultHost = "www.ebi.ac.uk";
    private final String defaultPort = "80";
    private final String defaultProtocol = "https";
    private final String defaultUrlPath = "/Tools/services/rest/";
    private String customHost;
    private String customPort;
    private final String toolId;
    private final String toolName;
    private final String toolDescription;

    private final String resourcesDir = "tools/";
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
                    + " --port          string          override default port (80)\n"
                    + " --params                        list tool parameters\n"
                    + " --paramDetails  string          information about a parameter\n"
                    + " --async                         Run job as asynchronous task (default: asynchronous)\n"
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
                    + "  Usage: java -jar <jarFile> --email <your@email> [Options...] --sequence <your-sequence>\n"
                    + "\n"
                    + "Asynchronous (default execution) job:\n"
                    + "\n"
                    + "  The results \n"
                    + "  are stored for up to 7 days.\n"
                    + "  Usage: java -jar <jarFile> --async --email <your@email> [Options...] --sequence <your-sequence>\n"
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

        URL url = Resources.getResource(resourcesDir + "emboss_transeq.txt");
        String[] toolInfo = Resources.toString(url, Charset.defaultCharset()).split("\n");

        toolId = toolInfo[0];
        toolName = toolInfo[1];
        toolDescription = toolInfo[2];
        log.debug("Tool id: {}", toolId);
        log.debug("Tool name: {}", toolName);
        setUserAgent();
    }

    private String getServiceEndpoint() {
        return new StringBuilder(defaultProtocol)
                .append("://")
                .append(customHost == null ? defaultHost : customHost)
                .append(":")
                .append(customPort == null ? defaultPort : customPort)
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
        sb.append("Parameters:\n");
        sb.append("===========\n\n");
        sb.append("[Required for new submission]").append("\n");
        sb.append(requiredParametersMessage).append("\n\n");
        sb.append("[Optional]").append("\n");
        sb.append(optionalParametersMessage).append("\n\n");
        sb.append(generalParametersMessage);
        sb.append("\nExamples:\n");
        sb.append("=========\n");
        sb.append(usageInfo);
        sb.append("\nSyntax example:");
        sb.append("\n---------------\n");
        sb.append("java -jar " + currentJar + " --email test@ebi.ac.uk --sequence XXX\n");

        log.info("{}", sb.toString());
    }

    /**
     * Print usage message
     */
    public void printUsageShort() {
        StringBuilder sb = new StringBuilder("\n\n");

        sb.append(toolName).append('\n');
        sb.append(toolDescription).append("\n\n");
        sb.append("More info: \njava -jar " + currentJar + " --help\n");

        log.info("{}", sb.toString());
    }


    /**
     * Load tool specific options from files included in generated JAR
     *
     * @throws IOException
     */
    private void loadToolSpecificOptions() throws IOException {

        optionalParametersMessage = Resources.toString(Resources.getResource(
                        resourcesDir + "emboss_transeq_opt.txt"), Charset.defaultCharset());
        requiredParametersMessage = Resources.toString(Resources.getResource(
                        resourcesDir + "emboss_transeq_req.txt"), Charset.defaultCharset());

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
        generalOptions.addOption("async", "", false, "Run job as an asynchronous task, (default: synchronous)");
        generalOptions.addOption("status", "", false, "Status of a job");
        generalOptions.addOption("resultTypes", "", false, "Get list of output formats");
        generalOptions.addOption("polljob", "", false, "Get results for the job");
        generalOptions.addOption("outformat", "", true, "Output format");
        generalOptions.addOption("host", "", true, "Custom host");
        generalOptions.addOption("port", "", true, "Custom port");
        generalOptions.addOption("help", "", false, "Print this help text");
    }


    /**
     * Get tool's parameters from server
     *
     * @return
     */
    public WsParameters getParams() {
        ClientResponse response = getResponse("/parameters", RequestType.GET, null);

        if (ClientUtils.isResponseCorrect(response)) {
            return response.getEntity(WsParameters.class);
        }
        return null;
    }


    /**
     * Get from server detailed information about queried parameter
     *
     * @param paramDetail
     * @return
     */
    public WsParameter getParam(String paramDetail) {
        ClientResponse response = getResponse("/parameterdetails/" + paramDetail, RequestType.GET, null);

        if (ClientUtils.isResponseCorrect(response)) {
            return response.getEntity(WsParameter.class);
        }
        return null;
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

        ClientResponse response = getResponse("/status/" + jobid, RequestType.GET, null);
        if (ClientUtils.isResponseCorrect(response)) {
            return response.getEntity(String.class);
        }
        return null;
    }


    /**
     * Get result types for a job from server
     *
     * @param jobId
     * @return
     */
    public WsResultTypes getResultTypesForJobId(String jobId) {

        ClientResponse response = getResponse("/resulttypes/" + jobId, RequestType.GET, null);
        if (ClientUtils.isResponseCorrect(response)) {
            return response.getEntity(WsResultTypes.class);
        }
        return null;
    }


    /**
     * Entry point to the application
     *
     * @param args
     */
    public void run(String[] args) {

        addGeneralOptions();
        CommandLineParser cliParser = new GnuParser();

        try {
            loadToolSpecificOptions();
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

            if (cli.hasOption("host")) {
                customHost = cli.getOptionValue("host");
            }

            if (cli.hasOption("port")) {
                customPort = cli.getOptionValue("port");
            }

            if (cli.hasOption("params")) {
                WsParameters params = getParams();

                if (params != null) {
                    log.info("Tool specific parameters: " + params.getIds().toString());

                    StringBuilder sb = new StringBuilder();
                    sb.append("\n\nTo learn more about selected parameter run:\n")
                            .append("java -jar ").append(currentJar)
                            .append(" --paramDetails <parameter-name>")
                            .append(params.getIds().size() > 0 ? "\n\nFor example:\njava -jar " + currentJar + " --paramDetails " + params.getIds().get(0) : "");

                    log.info(sb.toString());
                } else {
                    log.error("Returned WsParameters object is null");
                }

            }
            // Details of selected parameter
            else if (cli.hasOption("paramDetails")) {

                WsParameter parameter = getParam(cli.getOptionValue("paramDetails"));
                if (parameter != null) {

                    log.info("Simplified view");
                    ClientUtils.marshallToXML(parameter);
                } else {
                    log.error("Returned WsParameter object is null");
                }
            }

            // Submit new job
            else if (cli.hasOption("email") && cli.hasOption("sequence")) {
                String jobid = submitJob(cli, ClientUtils
                        .loadData(cli.getOptionValue("sequence")));

                if (jobid != null) {
                    // Asynchronous (default) execution
                    if (cli.hasOption("async")) {
                        log.info("You can check status of your job with:\n" +
                                 "java -jar " + currentJar + " --status --jobid {}\n", jobid);
                    // Synchronous execution
                    } else {
                        log.info("JobId: {}", jobid);

                        if (ClientUtils.getStatusInIntervals(this, jobid, 5000L)) {
                            downloadResults(cli, jobid);
                        } else {
                            log.error("Job failed.");
                        }
                    }
                } else {
                    log.error("Job submission failed");
                }
            }

            // Check already submitted job
            else if (cli.hasOption("jobid")) {
                String jobid = cli.getOptionValue("jobid");

                // Check status
                if (cli.hasOption("status")) {
                    final String status = checkStatus(jobid);

                    if (status.equals("FINISHED")) {
                        log.info("Status: " + status + "\n\nYou can see available result types with:\n" +
                                "java -jar " + currentJar + " --resultTypes --jobid {}\n\n" +
                                "Or download all results at once with:\n" +
                                "java -jar " + currentJar + " --polljob --jobid {}", jobid, jobid);
                                // "\n\nOr next time submit job with --sync option to automatically download results when they are ready.", jobid, jobid);

                    } else {
                        log.info(status + "\n");
                    }

                    // Check available result types
                } else if (cli.hasOption("resultTypes")) {
                    ClientUtils.marshallToXML(getResultTypesForJobId(jobid));
                }

                // Download (all/filtered) result files
                else if (cli.hasOption("polljob")) {

                    downloadResults(cli, jobid);
                } else {
                    log.error("Please specify one of following parameters: --status, --resultTypes, --polljob.");
                }
            } else {
                log.error("\n\nYou either have to specify both --email and --sequence or a --jobid value. \n\nTo learn more run: java -jar " + currentJar + " --help");
            }
        } catch (ParseException e) {
            log.error(e.getMessage());
        } catch (InterruptedException e) {
            log.error(e.getMessage());
        } catch (ServiceException e) {
            log.error(e.getMessage());
        } catch (JAXBException e) {
            log.error(e.getMessage());
        } catch (IOException e) {
            log.error(e.getMessage());
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
            ClientResponse response = getResponse("/result/" + jobid + "/" + identifier, RequestType.GET, null);

            InputStream inputStream = response.getEntity(InputStream.class);
            Files.copy(inputStream, Paths.get(outputFile));
            log.info("Download: {}", outputFile);
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

        Form form = new Form();
        form.putSingle("sequence", inputSeq);

        for (Option option : cli.getOptions()) {
            String optionName = option.getOpt();
            String optionType = option.getLongOpt();
            String optionValue = option.getValue();

            if (optionName.equals("sequence") || optionName.equals("async")) {
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

        ClientResponse response = getResponse("/run", RequestType.POST, form);

        if (ClientUtils.isResponseCorrect(response)) {
            return response.getEntity(String.class);
        }
        return null;
    }

    private ClientResponse getResponse(String urlSuffix, RequestType requestType, Form form) {
        WebResource target = getClient()
                .resource(getServiceEndpoint() + urlSuffix);

        log.debug(requestType + " " + target.toString());

        try {
            if (requestType == RequestType.GET) {
                return target.get(ClientResponse.class);

            } else if (requestType == RequestType.POST) {

                log.debug("POST parameters:");
                form.keySet().stream().forEach(s -> {
                    String parameters = form.get(s).toString();

                    if (parameters.length() > 20) {
                        parameters = parameters.substring(0, 20) + " ...";
                    }

                    log.debug(s + "\t" + parameters);
                });

                System.out.println();
                return target.post(ClientResponse.class, form);
            } else {
                log.error("Unsupported RequestType");
            }
        } catch (Exception e) {
            log.error("Problem with Internet connection");
            log.error(e.getMessage());
        }
        return null;
    }

    public enum RequestType {GET, POST}
}