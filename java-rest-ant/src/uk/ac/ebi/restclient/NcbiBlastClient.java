package uk.ac.ebi.restclient;

import com.sun.jersey.api.representation.Form;
import org.apache.commons.cli.CommandLine;
import sun.reflect.generics.reflectiveObjects.NotImplementedException;

/**
 * Created by chojnasm on 23/08/2016.
 */
public class NcbiBlastClient extends AbstractRestClient {
    @Override
    void addToolSpecificOptions() {
        System.out.println("Not implemented");
    }

    @Override
    void addToolSpecificParameters(CommandLine cli, Form form) {
        System.out.println("Not implemented");
    }

    /**
     * Entry point to the application
     *
     * @param args
     */
    public static void main(String[] args) throws InterruptedException {

        AbstractRestClient client = new NcbiBlastClient();
        client.run(args);
    }
}
