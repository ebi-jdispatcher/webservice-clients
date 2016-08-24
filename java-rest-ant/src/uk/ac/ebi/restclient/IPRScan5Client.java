package uk.ac.ebi.restclient;

import com.sun.jersey.api.representation.Form;
import org.apache.commons.cli.CommandLine;

import java.util.Arrays;


/**
 * Created by chojnasm on 12/08/2016.
 */
public class IPRScan5Client extends AbstractRestClient {

    String serviceEndPoint = "http://www.ebi.ac.uk/Tools/services/rest/iprscan5";

    String shortDescription = "\nInterProScan 5\n"
            + "==============\n"
            + "\n"
            + "Identify protein family, domain and signal signatures in a protein sequence.\n"
            + "\n"
            + "For information see:\n"
            + "- http://www.ebi.ac.uk/Tools/webservices/services/pfa/iprscan5_rest\n"
            + "- http://www.ebi.ac.uk/Tools/pfa/iprscan5/\n"
            + "\n"
            + "[Required]\n"
            + "\n"
            + "  --sequence            : file : query sequence (\"-\" for STDIN, @filename for\n"
            + "                              identifier list file)\n"
            + "  --email              : str  : email address\n"
            + "\n"
            + "[Optional]\n"
            + "\n"
            + "      --appl         : str  : comma separated list of methods, use values (not labels) from --paramDetails \n"
            + "      --goterms      :      : enable retrieval of GO terms\n"
            + "      --nogoterms    :      : disable retrieval of GO terms\n"
            + "      --pathways     :      : enable retrieval of pathway terms\n"
            + "      --nopathways   :      : disable retrieval of pathway terms\n"
            + "\n"
            + "      --help         :      : print full documentation\n"
            + "\n";

    public IPRScan5Client() {
        super.serviceEndPoint = this.serviceEndPoint;
        super.toolSpecificUsageMessage = this.shortDescription;
    }


    /**
     * Entry point to the application
     *
     * @param args
     */
    public static void main(String[] args) throws InterruptedException {

        AbstractRestClient client = new IPRScan5Client();
        client.run(args);
    }

    @Override
    void addToolSpecificOptions() {
        options.addOption("appl", "appl", true, "Signature methods");
        options.addOption("goterms", "goterms", true, "Enable or disable GO terms");
        options.addOption("pathways", "pathways", true, "Enable or disable pathway terms");
        options.addOption("sequence", true,
                "File with sequence or a sequence");
    }

    @Override
    void addToolSpecificParameters(CommandLine cli, Form form) {

        if (cli.hasOption("goterms")) {
            form.putSingle("goterms", cli.getOptionValue("goterms"));
        }

        if (cli.hasOption("pathways")) {
            form.putSingle("pathways", cli.getOptionValue("pathways"));
        }

        if (cli.hasOption("appl")) {
            String[] applications = cli.getOptionValue("appl").split(",");
            form.put("appl", Arrays.asList(applications));
        }
    }
}
