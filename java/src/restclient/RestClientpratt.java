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
// PRATT (REST) web service Java client.

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


public class RestClientpratt {

    static {
        System.setProperty("org.slf4j.simpleLogger.defaultLogLevel", "ERROR");
    }

    private static final org.slf4j.Logger log = org.slf4j.LoggerFactory.getLogger(RestClientpratt.class);

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

    private final Options allOptions = new Options();

    private String requiredParameters;
    private String requiredParametersMessage;
    private String optionalParameters;
    private String optionalParametersMessage;

    private final String generalInfo = "EMBL-EBI PRATT Java Client:\n"
                                   + "\n"
                                   + "Protein function analysis with Pratt.\n"
                                   + "\n"
                                   + "[Required (for job submission)]\n"
                                   + "  --email               E-mail address.\n"
                                   + "  --stype               Defines the type of the sequences to be aligned.\n"

                                   + "  --sequence            The input set of up to 100 sequences can be entered directly\n"
                                   + "                        into this form. The sequences can be in FASTA or\n"
                                   + "                        UniProtKB/Swiss-Prot format. A partially formatted sequences\n"
                                   + "                        are not accepted. Note that directly using data from word\n"
                                   + "                        processors may yield unpredictable results as hidden/control\n"
                                   + "                        characters may be present.\n"


                                   + "\n[Optional]\n"
                                   + "  --minPerc             Set the minimum percentage of the input sequences that\n"
                                   + "                        should match a pattern (C%). If you set this to, say 80,\n"
                                   + "                        Pratt will only report patterns matching at least 80 % of\n"
                                   + "                        the sequences input.\n"

                                   + "  --patternPosition     Pattern position in sequence (PP parameter).\n"

                                   + "  --maxPatternLength    Maximum pattern length (PL parameter) allows you to set the\n"
                                   + "                        maximum length of a pattern. The length of the pattern\n"
                                   + "                        C-x(2,4)-[DE] is 1+4+1=6. The memory requirement of Pratt\n"
                                   + "                        depends on L; a higher L value gives higher memory\n"
                                   + "                        requirement.\n"

                                   + "  --maxNumPatternSymbols Maximum number of pattern symbols (PN parameter). Using this\n"
                                   + "                        you can set the maximum number of symbols in a pattern. The\n"
                                   + "                        pattern C-x(2,4)-[DE] has 2 symbols (C and [DE]). When PN is\n"
                                   + "                        increased, Pratt will require more memory.\n"

                                   + "  --maxNumWildcard      Maximum length of a widecard (x). Using this option you can\n"
                                   + "                        set the maximum length of a wildcard (PX parameter).\n"
                                   + "                        Increasing this will increase the time used by Pratt, and\n"
                                   + "                        also slightly the memory required.\n"

                                   + "  --maxNumFlexSpaces    Maximum length of flexible spaces. Using this option you can\n"
                                   + "                        set the maximum number of flexible wildcards (matching a\n"
                                   + "                        variable number of arbitrary sequence symbols) (FN\n"
                                   + "                        parameter). Increasing this will increase the time used by\n"
                                   + "                        Pratt.\n"

                                   + "  --maxFlexibility      Maximum flexibility. You can set the maximum flexibility of\n"
                                   + "                        a flexible wildcard (matching a variable number of arbitrary\n"
                                   + "                        sequence symbols) (FL parameter). For instance x(2,4) and\n"
                                   + "                        x(10,12) has flexibility 2, and x(10) has flexibility 0.\n"
                                   + "                        Increasing this will increase the time used by Pratt.\n"

                                   + "  --maxFlexProduct      Maximum flex. product. Using this option you can set an\n"
                                   + "                        upper limit on the product of a flexibilities for a pattern\n"
                                   + "                        (FP parameter). This is related to the memory requirements\n"
                                   + "                        of the search, and increasing the limit, increases the\n"
                                   + "                        memory usage.\n"

                                   + "  --patternSymbolFile   Pattern Symbol File (BI parameter).\n"

                                   + "  --numPatternSymbols   Number of pattern symbols used in the initial search (BN\n"
                                   + "                        parameter).\n"

                                   + "  --patternScoring      Pattern scoring (S parameter).\n"

                                   + "  --patternGraph        Pattern Graph (G parameter) allows the use of an alignment\n"
                                   + "                        or a query sequence to restrict the pattern search.\n"

                                   + "  --searchGreediness    Using the greediness parameter (E) you can adjust the\n"
                                   + "                        greediness of the search. Setting E to 0 (zero), the search\n"
                                   + "                        will be exhaustive. Increasing E increases the greediness,\n"
                                   + "                        and decreases the time used in the search.\n"

                                   + "  --patternRefinement   Pattern Refinement (R parameter). When the R option is\n"
                                   + "                        switched on, patterns found during the initial pattern\n"
                                   + "                        search are input to a refinement algorithm where more\n"
                                   + "                        ambiguous pattern symbols can be added.\n"

                                   + "  --genAmbigSymbols     Generalise ambiguous symbols (RG parameter). If the RG\n"
                                   + "                        option is switched on, then ambiguous symbols listed in the\n"
                                   + "                        symbols file are used. If RG is off, only the letters needed\n"
                                   + "                        to match the input sequences are included in the ambiguous\n"
                                   + "                        pattern positions.\n"

                                   + "  --patternFormat       PROSITE Pattern Format (OP parameter). When switched on,\n"
                                   + "                        patterns will be output in PROSITE style (for instance\n"
                                   + "                        C-x(2,4)-[DE]). When switched off, patterns are output in a\n"
                                   + "                        simpler consensus pattern style (for instance Cxx--[DE]\n"
                                   + "                        where x matches exactly one arbitrary sequence symbol and -\n"
                                   + "                        matches zero or one arbitrary sequence symbol).\n"

                                   + "  --maxNumPatterns      Maximum number of patterns (ON parameter) between 1 and 100.\n"

                                   + "  --maxNumAlignments    Maximum number of alignments (OA parameter) between 1 and\n"
                                   + "                        100.\n"

                                   + "  --printPatterns       Print Patterns in sequences (M parameter) If the M option is\n"
                                   + "                        set, then Pratt will print out the location of the sequence\n"
                                   + "                        segments matching each of the (maximum 52) best patterns.\n"
                                   + "                        The patterns are given labels A, B,...Z,a,b,...z in order of\n"
                                   + "                        decreasing pattern score. Each sequence is printed on a\n"
                                   + "                        line, one character per K-tuple in the sequence. If pattern\n"
                                   + "                        with label C matches the third K-tuple in a sequence C is\n"
                                   + "                        printed out. If several patterns match in the same K-tuple,\n"
                                   + "                        only the best will be printed.\n"

                                   + "  --printingRatio       Printing ratio (MR parameter). sets the K value (ratio) used\n"
                                   + "                        for printing the summary information about where in each\n"
                                   + "                        sequence the pattern matches are found.\n"

                                   + "  --printVertically     Print vertically (MV parameter). if set, the output is\n"
                                   + "                        printed vertically instead of horizontally, vertical output\n"
                                   + "                        can be better for large sequence sets.\n"

                                   + "  --ppfile              Pattern restriction file. The restriction file limits the\n"
                                   + "                        sequence range via the start/end parameter and is in the\n"
                                   + "                        format '>Sequence (start, end)'. If parameter PP is off, the\n"
                                   + "                        restiction file will be ignored.\n"


                                   + "\n[General]\n"
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
                                   + "  --verbose             Increase output.\n"
                                   + "  --quiet               Decrease output.\n"
                                   + "  --baseUrl             Base URL. Defaults to:\n"
                                   + "                        https://www.ebi.ac.uk/Tools/services/rest/pratt\n"
                                   + "\n"
                                   + "Synchronous job:\n"
                                   + "  The results/errors are returned as soon as the job is finished.\n"
                                   + "  Usage: java -jar pratt.jar --email <your@email.com> [options...] <SeqFile|SeqID(s)>\n"
                                   + "  Returns: results as an attachment\n"
                                   + "\n"
                                   + "Asynchronous job:\n"
                                   + "  Use this if you want to retrieve the results at a later time. The results\n"
                                   + "  are stored for up to 24 hours.\n"
                                   + "  Usage: java -jar pratt.jar --async --email <your@email.com> [options...] <SeqFile|SeqID(s)>\n"
                                   + "  Returns: jobid\n"
                                   + "\n"
                                   + "Check status of Asynchronous job:\n"
                                   + "   Usage: java -jar pratt.jar --status --jobid <jobId>\n"
                                   + "\n"
                                   + "Retrieve job data:\n"
                                   + "  Use the jobid to query for the status of the job. If the job is finished,\n"
                                   + "  it also returns the results/errors.\n"
                                   + "  Usage: java -jar pratt.jar --polljob --jobid <jobId> [--outfile string]\n"
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

        RestClientpratt client = new RestClientpratt();
        client.run(args);
    }

    /**
     * Load tool specific information in the constructor
     */
    private RestClientpratt() throws IOException {

        toolId = "pratt";
        toolName = "PRATT";
        toolDescription = "Protein function analysis with Pratt.";
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
        System.out.println(sb.toString());
        printDebugMessage("printUsage", String.format("%s", sb.toString()), 11);
    }

    /**
     * Print debug message
     */
    public void printDebugMessage(String functionName, String message, int level) {
        debugLevel = getDebugLevel();
        if (level <= debugLevel)
            System.out.println("[" + functionName + "] " + message);
    }


    /**
     * Print job status
     */
    public void printGetStatus(String jobid) throws IOException, ServiceException {

        printDebugMessage("printGetStatus", "Getting status for job " + jobid, 11);
        outputLevel = getOutputLevel();
        if (outputLevel > 0)
            System.out.println("Getting status for job " + jobid);
        String status = checkStatus(jobid);
        if (outputLevel > 0)
            System.out.println(status);
        if (outputLevel > 0 && status.equals("FINISHED")) {
             System.out.println("To get results: java -jar pratt.jar --polljob --jobid " + jobid);
        }
    }

    /**
     * Set options common to all tools
     */
    private void addGeneralOptions() {
        allOptions.addOption("minPerc", "", true, "Set the minimum percentage of the input sequences that should match a"
                   + "pattern (C%). If you set this to, say 80, Pratt will only report"
                   + "patterns matching at least 80 % of the sequences input.");
        allOptions.addOption("patternPosition", "", true, "Pattern position in sequence (PP parameter)");
        allOptions.addOption("maxPatternLength", "", true, "Maximum pattern length (PL parameter) allows you to set the maximum"
                   + "length of a pattern. The length of the pattern C-x(2,4)-[DE] is"
                   + "1+4+1=6. The memory requirement of Pratt depends on L; a higher L"
                   + "value gives higher memory requirement.");
        allOptions.addOption("maxNumPatternSymbols", "", true, "Maximum number of pattern symbols (PN parameter). Using this you can"
                   + "set the maximum number of symbols in a pattern. The pattern"
                   + "C-x(2,4)-[DE] has 2 symbols (C and [DE]). When PN is increased, Pratt"
                   + "will require more memory.");
        allOptions.addOption("maxNumWildcard", "", true, "Maximum length of a widecard (x). Using this option you can set the"
                   + "maximum length of a wildcard (PX parameter). Increasing this will"
                   + "increase the time used by Pratt, and also slightly the memory"
                   + "required.");
        allOptions.addOption("maxNumFlexSpaces", "", true, "Maximum length of flexible spaces. Using this option you can set the"
                   + "maximum number of flexible wildcards (matching a variable number of"
                   + "arbitrary sequence symbols) (FN parameter). Increasing this will"
                   + "increase the time used by Pratt.");
        allOptions.addOption("maxFlexibility", "", true, "Maximum flexibility. You can set the maximum flexibility of a flexible"
                   + "wildcard (matching a variable number of arbitrary sequence symbols)"
                   + "(FL parameter). For instance x(2,4) and x(10,12) has flexibility 2,"
                   + "and x(10) has flexibility 0. Increasing this will increase the time"
                   + "used by Pratt.");
        allOptions.addOption("maxFlexProduct", "", true, "Maximum flex. product. Using this option you can set an upper limit on"
                   + "the product of a flexibilities for a pattern (FP parameter). This is"
                   + "related to the memory requirements of the search, and increasing the"
                   + "limit, increases the memory usage.");
        allOptions.addOption("patternSymbolFile", "", false, "Pattern Symbol File (BI parameter)");
        allOptions.addOption("numPatternSymbols", "", true, "Number of pattern symbols used in the initial search (BN parameter).");
        allOptions.addOption("patternScoring", "", true, "Pattern scoring (S parameter)");
        allOptions.addOption("patternGraph", "", true, "Pattern Graph (G parameter) allows the use of an alignment or a query"
                   + "sequence to restrict the pattern search.");
        allOptions.addOption("searchGreediness", "", true, "Using the greediness parameter (E) you can adjust the greediness of"
                   + "the search. Setting E to 0 (zero), the search will be exhaustive."
                   + "Increasing E increases the greediness, and decreases the time used in"
                   + "the search.");
        allOptions.addOption("patternRefinement", "", false, "Pattern Refinement (R parameter). When the R option is switched on,"
                   + "patterns found during the initial pattern search are input to a"
                   + "refinement algorithm where more ambiguous pattern symbols can be"
                   + "added.");
        allOptions.addOption("genAmbigSymbols", "", false, "Generalise ambiguous symbols (RG parameter). If the RG option is"
                   + "switched on, then ambiguous symbols listed in the symbols file are"
                   + "used. If RG is off, only the letters needed to match the input"
                   + "sequences are included in the ambiguous pattern positions.");
        allOptions.addOption("patternFormat", "", false, "PROSITE Pattern Format (OP parameter). When switched on, patterns will"
                   + "be output in PROSITE style (for instance C-x(2,4)-[DE]). When switched"
                   + "off, patterns are output in a simpler consensus pattern style (for"
                   + "instance Cxx--[DE] where x matches exactly one arbitrary sequence"
                   + "symbol and - matches zero or one arbitrary sequence symbol).");
        allOptions.addOption("maxNumPatterns", "", true, "Maximum number of patterns (ON parameter) between 1 and 100.");
        allOptions.addOption("maxNumAlignments", "", true, "Maximum number of alignments (OA parameter) between 1 and 100.");
        allOptions.addOption("printPatterns", "", false, "Print Patterns in sequences (M parameter) If the M option is set, then"
                   + "Pratt will print out the location of the sequence segments matching"
                   + "each of the (maximum 52) best patterns. The patterns are given labels"
                   + "A, B,...Z,a,b,...z in order of decreasing pattern score. Each sequence"
                   + "is printed on a line, one character per K-tuple in the sequence. If"
                   + "pattern with label C matches the third K-tuple in a sequence C is"
                   + "printed out. If several patterns match in the same K-tuple, only the"
                   + "best will be printed.");
        allOptions.addOption("printingRatio", "", true, "Printing ratio (MR parameter). sets the K value (ratio) used for"
                   + "printing the summary information about where in each sequence the"
                   + "pattern matches are found.");
        allOptions.addOption("printVertically", "", false, "Print vertically (MV parameter). if set, the output is printed"
                   + "vertically instead of horizontally, vertical output can be better for"
                   + "large sequence sets.");
        allOptions.addOption("stype", "", true, "Defines the type of the sequences to be aligned.");
        allOptions.addOption("sequence", "", true, "The input set of up to 100 sequences can be entered directly into this"
                   + "form. The sequences can be in FASTA or UniProtKB/Swiss-Prot format. A"
                   + "partially formatted sequences are not accepted. Note that directly"
                   + "using data from word processors may yield unpredictable results as"
                   + "hidden/control characters may be present.");
        allOptions.addOption("ppfile", "", true, "Pattern restriction file. The restriction file limits the sequence"
                   + "range via the start/end parameter and is in the format >Sequence"
                   + "(start, end). If parameter PP is off, the restiction file will be"
                   + "ignored.");


        allOptions.addOption("email", "", true, "E-mail address.");
        allOptions.addOption("h", "help", false, "Show this help message and exit.");
        allOptions.addOption("params", "", false, "Print parameters.");
        allOptions.addOption("paramDetail", "", true, "Details about selected parameter.");
        allOptions.addOption("title", "", true, "Title for the job.");
        allOptions.addOption("jobid", "", true, "Job identifier.");
        allOptions.addOption("async", "", false, "Run job as an asynchronous task, (default: synchronous).");
        allOptions.addOption("status", "", false, "Status of a job.");
        allOptions.addOption("resultTypes", "", false, "Get list of output formats.");
        allOptions.addOption("polljob", "", false, "Get results for the job.");
        allOptions.addOption("outformat", "", true, "Output format.");
        allOptions.addOption("quiet", "", false, "Decrease output level.");
        allOptions.addOption("verbose", "", false, "Increase output level.");
        allOptions.addOption("debugLevel", "", true, "Debugging level.");
        allOptions.addOption("baseUrl", "", true, "Custom host.");
    }


    /**
     * Get tool's parameters from server
     *
     * @return
     */
    public WsParameters getParams() {
        ClientResponse response = getResponse(baseUrl, "/parameters", RequestType.GET, null);

        if (ClientUtilspratt.isResponseCorrect(response, debugLevel)) {
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

        if (ClientUtilspratt.isResponseCorrect(response, debugLevel)) {
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
        if (ClientUtilspratt.isResponseCorrect(response, debugLevel)) {
            final String status = response.getEntity(String.class);
            return status;
        } else {
            System.out.println(response.getEntity(String.class));
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
        if (ClientUtilspratt.isResponseCorrect(response, debugLevel)) {
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
                baseUrl = getServiceEndpoint() + toolId;
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
                            .append("java -jar ").append("pratt.jar")
                            .append(" --paramDetails <parameter-name>")
                            .append(params.getIds().size() > 0 ? "\n\nFor example:\njava -jar pratt.jar --paramDetails " + params.getIds().get(0) : "");

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
                    ClientUtilspratt.marshallToXML(parameter);
                } else {
                    printDebugMessage("run", "Returned WsParameter object is null", 41);
                }
            }

            // Submit new job
            else if (cli.hasOption("email") && sequence != null) {

                String jobid = submitJob(cli, ClientUtilspratt.loadData(sequence));

                if (jobid != null) {
                    // Asynchronous (default) execution
                    if (cli.hasOption("async")) {
                        System.out.println(jobid);
                        printDebugMessage("run", String.format("You can check status of your job with:\n" +
                                                 "java -jar pratt.jar --status --jobid %s\n", jobid), 11);

                        if (outputLevel > 0)
                            System.out.println("To check status: java -jar pratt.jar --status --jobid " + jobid);
                        
                    // Synchronous execution
                    } else {
                        if (outputLevel > 0){
                            System.out.println("JobId: " + jobid);
                        } else {
                            System.out.println(jobid);
                        }
                        printDebugMessage("run", String.format("JobId: %s", jobid), 11);
                        if (ClientUtilspratt.getStatusInIntervals(this, jobid, pollFreq, outputLevel, debugLevel)) {
                            downloadResults(cli, jobid);
                        } else {
                            System.out.println("Job failed.");
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
                printGetStatus(jobid);
            }

            else if (cli.hasOption("jobid") && (cli.hasOption("resultTypes") || cli.hasOption("polljob"))) {
                String jobid = cli.getOptionValue("jobid");
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
                    ClientUtilspratt.marshallToXML(getResultTypesForJobId(jobid));
                    if (outputLevel > 0)
                        System.out.println("To get results:\n  java -jar pratt.jar --polljob --jobid " + jobid
                                           + "\n  java -jar pratt.jar --polljob --outformat <type> --jobid " + jobid);
                }

                // Download (all/filtered) result files
                else if (cli.hasOption("polljob")) {

                    downloadResults(cli, jobid);
                } else {
                    printDebugMessage("run", "Please specify one of following parameters: --status, --resultTypes, --polljob.", 41);
                }
            } else {
                printUsage();
                printDebugMessage("run", "\n\nYou either have to specify both --email and --sequence or a --jobid value. \n\nTo learn more run: java -jar pratt.jar --help", 41);
                return;
            }
        } catch (ParseException e) {
            System.out.println("Error: unrecognised argument combination: " + e.getMessage());
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
            resultTypes = ClientUtilspratt.processUserOutputFormats(cli.getOptionValue("outformat"),
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

        if (ClientUtilspratt.isResponseCorrect(response, debugLevel)) {
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
