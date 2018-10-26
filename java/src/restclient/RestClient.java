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
        System.setProperty("org.slf4j.simpleLogger.defaultLogLevel", "ERROR");
    }

    private static final org.slf4j.Logger log = org.slf4j.LoggerFactory.getLogger(RestClient.class);

    private String revision = "2018";
    private Client client;
    private final String toolId;
    private final String toolName;
    private final String toolDescription;
    private String baseUrl = "";
    private final String defaultHost = "www.ebi.ac.uk";
    private final String defaultProtocol = "https";
    private final String defaultUrlPath = "/Tools/services/rest/";
    public int outputLevel = 1;
    public int debugLevel = 0;
    public int pollFreq = 3;
    private String currentJar = new java.io.File(RestClient.class.getProtectionDomain()
          .getCodeSource().getLocation().getPath()).getName();
    private String toolid = currentJar.replace(".jar", "");

    private final String resourcesDir = "tools/";
    private final Options allOptions = new Options();
    private final Options generalOptions = new Options();
    private final Options requiredOptions = new Options();
    private final Options optionalOptions = new Options();

    private String requiredParametersMessage;
    private String optionalParametersMessage;

    private final String generalInfo = "EMBL-EBI Clustal Omega Java Client:\n"
                                   + "\n"
                                   + "Multiple sequence alignment with Clustal Omega.\n"
                                   + "\n"
                                   + "[General]\n"
                                   + "  -h, --help            Show this help message and exit.\n"
                                   + "  --async               Forces to make an asynchronous query.\n"
                                   + "  --title               Title for job.\n"
                                   + "  --status              Get job status.\n"
                                   + "  --resultTypes         Get available result types for job.\n"
                                   + "  --polljob             Poll for the status of a job.\n"
                                   + "  --pollFreq            Poll frequency in seconds (default 3s).\n"
                                   + "  --jobid               JobId that was returned when an asynchronous job was submitted.\n"
                                   + "  --outfile             File name for results (default is JobId; for STDOUT).\n"
                                   + "  --outformat           Result format(s) to retrieve. It accepts comma-separated values.\n"
                                   + "  --params              List input parameters.\n"
                                   + "  --paramDetail         Display details for input parameter.\n"
                                   + "  --quiet               Decrease output.\n"
                                   + "  --verbose             Increase output.\n"
                                   + "  --debugLevel          Debugging level.\n"
                                   + "  --baseUrl             Base URL. Defaults to:\n"
                                   + "                        " + getServiceEndpoint() + toolid + "\n"
                                   + "\n"
                                   + "[Optional]\n";

private final String additionalInfo = "\n"
                                   + "Synchronous job:\n"
                                   + "  The results/errors are returned as soon as the job is finished.\n"
                                   + "  Usage: java -jar " + currentJar + " --email <your@email.com> [options...] <SequenceFile>\n"
                                   + "  Returns: results as an attachment\n"
                                   + "\n"
                                   + "Asynchronous job:\n"
                                   + "  Use this if you want to retrieve the results at a later time. The results\n"
                                   + "  are stored for up to 24 hours.\n"
                                   + "  Usage: java -jar " + currentJar + " --async --email <your@email.com> [options...] <SequenceFile>\n"
                                   + "  Returns: jobid\n"
                                   + "\n"
                                   + "  Use the jobid to query for the status of the job. If the job is finished,\n"
                                   + "  it also returns the results/errors.\n"
                                   + "  Usage: java -jar " + currentJar + " --polljob --jobid <jobId> [--outfile string]\n"
                                   + "  Returns: string indicating the status of the job and if applicable, results\n"
                                   + "  as an attachment.\n"
                                   + "\n"
                                   + "Further information:\n"
                                   + "  https://www.ebi.ac.uk/Tools/webservices and\n"
                                   + "    https://github.com/ebi-wp/webservice-clients\n"
                                   + "\n"
                                   + "Support/Feedback:\n"
                                   + "  https://www.ebi.ac.uk/support/";

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

        URL url = Resources.getResource(resourcesDir + "tool.txt");
        String[] toolInfo = Resources.toString(url, Charset.defaultCharset()).split("\n");

        toolId = toolInfo[0];
        toolName = toolInfo[1];
        toolDescription = toolInfo[2];
        printDebugMessage("RestClient", String.format("Tool id: %s", toolId), 1);
        printDebugMessage("RestClient", String.format("Tool name: %s", toolName), 1);
        setUserAgent();
    }

    private String getServiceEndpoint() {
        return new StringBuilder(defaultProtocol)
                .append("://")
                .append(defaultHost)
                .append(defaultUrlPath).toString();
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

        printDebugMessage("setUserAgent", String.format("http.agent: %s", System.getProperty("http.agent").toString()), 1);
    }

    private int getOutputLevel() {
        return outputLevel;
    }

    private void setOutputLevel(int level) {
        this.outputLevel = level;
    }

    private int getDebugLevel() {
        return debugLevel;
    }

    private void setDebugLevel(int level) {
        this.debugLevel = level;
    }

    private int getPollFreq() {
        return pollFreq;
    }

    private void setPollFreq(int freq) {
        this.pollFreq = freq;
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
        StringBuilder sb = new StringBuilder("");

        sb.append(generalInfo);
        sb.append(requiredParametersMessage);
        sb.append(additionalInfo);

        System.out.println(sb.toString());
        printDebugMessage("printUsage", String.format("%s", sb.toString()), 11);
    }

    /**
     * Print debug message
     */
    public void printDebugMessage(String functionName, String message, int level) {
        if (level <= debugLevel)
            System.out.println("[" + functionName + "] " + message);
    }

    /**
     * Load tool specific options from files included in generated JAR
     *
     * @throws IOException
     */
    private void loadToolSpecificOptions() throws IOException {

        optionalParametersMessage = Resources.toString(Resources.getResource(
                        resourcesDir + "optional.txt"), Charset.defaultCharset());
        requiredParametersMessage = Resources.toString(Resources.getResource(
                        resourcesDir + "required.txt"), Charset.defaultCharset());

        ClientUtils.parseOptionsFromFormattedString(optionalOptions, optionalParametersMessage);

        for (Object option : generalOptions.getOptions()) {
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

        generalOptions.addOption("h", "", false, "Print this help text.");
        generalOptions.addOption("help", "", false, "Print this help text.");
        generalOptions.addOption("params", "", false, "Print parameters.");
        generalOptions.addOption("paramDetail", "", true, "Details about selected parameter.");
        generalOptions.addOption("title", "", true, "Title for the job.");
        generalOptions.addOption("jobid", "", true, "Job identifier.");
        generalOptions.addOption("async", "", false, "Run job as an asynchronous task, (default: synchronous).");
        generalOptions.addOption("status", "", false, "Status of a job.");
        generalOptions.addOption("resultTypes", "", false, "Get list of output formats.");
        generalOptions.addOption("polljob", "", false, "Get results for the job.");
        generalOptions.addOption("outformat", "", true, "Output format.");
        generalOptions.addOption("quiet", "", false, "Decrease output level.");
        generalOptions.addOption("verbose", "", false, "Increase output level.");
        generalOptions.addOption("debugLevel", "", true, "Debugging level.");
        generalOptions.addOption("baseUrl", "", true, "Custom host.");
    }


    /**
     * Get tool's parameters from server
     *
     * @return
     */
    public WsParameters getParams() {
        ClientResponse response = getResponse(baseUrl, "/parameters", RequestType.GET, null);

        if (ClientUtils.isResponseCorrect(response, debugLevel)) {
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
        ClientResponse response = getResponse(baseUrl, "/parameterdetails/" + paramDetail, RequestType.GET, null);

        if (ClientUtils.isResponseCorrect(response, debugLevel)) {
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
        outputLevel = getOutputLevel();
        ClientResponse response = getResponse(baseUrl, "/status/" + jobid, RequestType.GET, null);
        if (ClientUtils.isResponseCorrect(response, debugLevel)) {
            final String status = response.getEntity(String.class);
            if (outputLevel > 0)
                System.out.println(status);
            if (status == "FINISHED")
                System.out.println("To get results: java -jar " + currentJar + " --polljob --jobid " + jobid);
            return status;
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
        ClientResponse response = getResponse(baseUrl, "/resulttypes/" + jobId, RequestType.GET, null);
        if (ClientUtils.isResponseCorrect(response, debugLevel)) {
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

            List<String> unusedargs = cli.getArgList();

            // Print just basic info
            if (args.length == 0) {
                printUsage();
                return;
            }

            if (cli.hasOption("help") || cli.hasOption("h")) {
                printUsage();
                return;
            }

            if (cli.hasOption("verbose")) {
                setOutputLevel(getOutputLevel() + 1);
            }
            if (cli.hasOption("quiet")) {
                setOutputLevel(getOutputLevel() - 1);
            }
            int outputLevel = getOutputLevel();

            if (cli.hasOption("debugLevel")) {
                setDebugLevel(Integer.valueOf(cli.getOptionValue("debugLevel")));
            }
            int debugLevel = getDebugLevel();

            if (cli.hasOption("pollFreq")) {
                setPollFreq(Integer.valueOf(cli.getOptionValue("pollFreq")));
            }
            int pollFreq = getPollFreq();

            String sequence = null;
            if (cli.hasOption("sequence")) {
                sequence = cli.getOptionValue("sequence");
            } else if (unusedargs.size() > 0) {
                sequence = unusedargs.get(0);
            }

            if (cli.hasOption("baseUrl")) {
                baseUrl = cli.getOptionValue("baseUrl");
            } else {
                baseUrl = getServiceEndpoint() + toolid;
            }

            if (cli.hasOption("params")) {
                WsParameters params = getParams();

                if (params != null) {
                    for (String param : params.getIds()) {
                        System.out.println(param);
                    }
                    printDebugMessage("run", ("Tool specific parameters: " + params.getIds().toString()), 11);

                    StringBuilder sb = new StringBuilder();
                    sb.append("\n\nTo learn more about selected parameter run:\n")
                            .append("java -jar ").append(currentJar)
                            .append(" --paramDetails <parameter-name>")
                            .append(params.getIds().size() > 0 ? "\n\nFor example:\njava -jar " + currentJar + " --paramDetails " + params.getIds().get(0) : "");

                    printDebugMessage("run", sb.toString(), 11);
                } else {
                    printDebugMessage("run", "Returned WsParameters object is null", 41);
                }

            }
            // Details of selected parameter
            else if (cli.hasOption("paramDetail")) {

                WsParameter parameter = getParam(cli.getOptionValue("paramDetail"));
                if (parameter != null) {

                    printDebugMessage("run", "Simplified view", 11);
                    ClientUtils.marshallToXML(parameter);
                } else {
                    printDebugMessage("run", "Returned WsParameter object is null", 41);
                }
            }

            // Submit new job
            else if (cli.hasOption("email") && sequence != null) {

                String jobid = submitJob(cli, ClientUtils.loadData(sequence));

                if (jobid != null) {
                    // Asynchronous (default) execution
                    if (cli.hasOption("async")) {
                        System.out.println(jobid);
                        printDebugMessage("run", String.format("You can check status of your job with:\n" +
                                                 "java -jar " + currentJar + " --status --jobid %s\n", jobid), 11);

                        if (outputLevel > 0)
                            System.out.println("To check status: java -jar  " + currentJar
                                             + " --status --jobid " + jobid);
                        
                    // Synchronous execution
                    } else {
                        if (outputLevel > 0){
                            System.out.println("JobId: " + jobid);
                        } else {
                            System.out.println(jobid);
                        }
                        printDebugMessage("run", String.format("JobId: %s", jobid), 11);
                        if (ClientUtils.getStatusInIntervals(this, jobid, pollFreq, outputLevel, debugLevel)) {
                            downloadResults(cli, jobid);
                        } else {
                            printDebugMessage("run", "Job failed.", 41);
                        }
                    }
                } else {
                    printDebugMessage("run", "Job submission failed.", 41);
                }
            }

            // Check already submitted job
            else if (cli.hasOption("jobid") && cli.hasOption("status")) {
                String jobid = cli.getOptionValue("jobid");
                if (outputLevel > 0)
                     System.out.println("Getting status for job " + jobid);
                final String status = checkStatus(jobid);
                if (status.equals("FINISHED")) {
                     printDebugMessage("run", String.format("Status: " + status + "\n\nYou can see available result types with:\n" +
                                               "java -jar " + currentJar + " --resultTypes --jobid %s\n\n" +
                                               "Or download all results at once with:\n" +
                                               "java -jar " + currentJar + " --polljob --jobid %s", jobid, jobid), 11);
                                               // "\n\nOr next time submit job with --sync option to automatically download results when they are ready.", jobid, jobid);

                } else {
                    printDebugMessage("run", status + "\n", 11);

                }
            }

            else if (cli.hasOption("jobid") && (cli.hasOption("resultTypes") || cli.hasOption("polljob"))) {
                String jobid = cli.getOptionValue("jobid");
                if (outputLevel > 0)
                    System.out.println("Getting status for job " + jobid);
                final String status = checkStatus(jobid);
                if (status == "PENDING" || status == "RUNNING"){
                    System.out.println("Error: Job status is " + status
                                       + ". To get result types the job must be finished.");
                    System.exit(0);
                }

                // Check available result types
                if (cli.hasOption("resultTypes")) {
                    if (outputLevel > 0)
                        System.out.println("Getting result types for job " + jobid);
                    if (outputLevel > 0)
                        System.out.println("Available result types:");
                    ClientUtils.marshallToXML(getResultTypesForJobId(jobid));
                    if (outputLevel > 0)
                        System.out.println("To get results:\n  java -jar " + currentJar
                                           + " --polljob --jobid " + jobid
                                           + "\n  java -jar " + currentJar
                                           + " --polljob --outformat <type> --jobid " + jobid);
                }

                // Download (all/filtered) result files
                else if (cli.hasOption("polljob")) {

                    downloadResults(cli, jobid);
                } else {
                    printDebugMessage("run", "Please specify one of following parameters: --status, --resultTypes, --polljob.", 41);
                }
            } else {
                printDebugMessage("run", "\n\nYou either have to specify both --email and --sequence or a --jobid value. \n\nTo learn more run: java -jar " + currentJar + " --help", 41);
            }
        } catch (ParseException e) {
            printDebugMessage("run", e.getMessage(), 41);
        } catch (InterruptedException e) {
            printDebugMessage("run", e.getMessage(), 41);
        } catch (ServiceException e) {
            printDebugMessage("run", e.getMessage(), 41);
        } catch (JAXBException e) {
            printDebugMessage("run", e.getMessage(), 41);
        } catch (IOException e) {
            printDebugMessage("run", e.getMessage(), 41);
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

        outputLevel = getOutputLevel();
        if (outputLevel > 1)
            System.out.println("Getting results for job " + jobid);
        // Augment user specified result types with file suffix
        if (cli.hasOption("outformat")) {
            resultTypes = ClientUtils.processUserOutputFormats(cli.getOptionValue("outformat"),
                allResultTypes, debugLevel);
        } else {
            resultTypes = allResultTypes;
        }

        // Iterate over filtered result types and save each result in a separate file
        for (WsResultType resultType : resultTypes) {

            String identifier = resultType.getIdentifier();
            if (outputLevel > 1)
                System.out.println("Getting " + identifier);
            String fileSuffix = resultType.getFileSuffix();
            String outputFile = jobid + "-" + identifier + "." + fileSuffix;
            ClientResponse response = getResponse(baseUrl, "/result/" + jobid + "/" + identifier, RequestType.GET, null);

            InputStream inputStream = response.getEntity(InputStream.class);
            Files.copy(inputStream, Paths.get(outputFile));
            if (outputLevel > 0)
                System.out.println("Creating result file: " + outputFile);
            printDebugMessage("downloadResults", String.format("Download: %s", outputFile), 11);

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
                        printDebugMessage("submitJob", "Boolean parameter can be only 'true' or 'false'", 31);
                        System.exit(0);
                }
                form.putSingle(optionName, optionValue);

            } else {
                form.putSingle(optionName, optionValue);
            }
        }

        ClientResponse response = getResponse(baseUrl, "/run", RequestType.POST, form);

        if (ClientUtils.isResponseCorrect(response, debugLevel)) {
            return response.getEntity(String.class);
        }
        return null;
    }

    private ClientResponse getResponse(String baseUrl, String urlSuffix, RequestType requestType, Form form) {

        WebResource target = getClient()
                .resource(baseUrl + urlSuffix);

        printDebugMessage("getResponse", requestType + " " + target.toString(), 11);

        try {
            if (requestType == RequestType.GET) {
                return target.get(ClientResponse.class);

            } else if (requestType == RequestType.POST) {

                printDebugMessage("getResponse", "POST parameters:", 11);
                form.keySet().stream().forEach(s -> {
                    String parameters = form.get(s).toString();

                    if (parameters.length() > 20) {
                        parameters = parameters.substring(0, 20) + " ...";
                    }

                    printDebugMessage("getResponse", s + "\t" + parameters, 11);
                });

                //System.out.println();
                return target.post(ClientResponse.class, form);
            } else {
                printDebugMessage("getResponse", "Unsupported RequestType", 41);
            }
        } catch (Exception e) {
            printDebugMessage("getResponse", "Problem with Internet connection", 41);
            printDebugMessage("getResponse", e.getMessage(), 41);
        }
        return null;
    }

    public enum RequestType {GET, POST}
}
