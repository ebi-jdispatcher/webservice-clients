package uk.ac.ebi.restclient;


import com.sun.jersey.api.client.ClientResponse;
import org.apache.commons.cli.Options;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.restclient.stubs.WsResultType;

import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Marshaller;
import javax.xml.rpc.ServiceException;
import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;




/**
 * Created by chojnasm on 17/08/2016.
 */
public class ClientUtils {


    private static final Logger log = LoggerFactory.getLogger(ClientUtils.class);

    /**
     * Check if Http response code is as expected
     *
     * @param response
     * @param expectedStatusCode
     */
    public static void checkResponseStatusCode(ClientResponse response, int expectedStatusCode) {
        if (response.getStatus() != expectedStatusCode) {
            throw new RuntimeException("Failed : HTTP error code is: "
                    + response.getStatus()+", expected code is: " + expectedStatusCode);
        }
    }

    /**
     * Print object as XML
     *
     * @param result
     * @param <T>
     */
    public static <T> void marshallToXML(T result) throws JAXBException {

            JAXBContext jc = JAXBContext.newInstance(result.getClass());
            Marshaller marshaller = jc.createMarshaller();
            marshaller.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, true);
            marshaller.marshal(result, System.out);
    }

    public static List<WsResultType> processUserOutputFormats(String cli, List<WsResultType> allResultTypes) {
        List<WsResultType> resultTypes;
        resultTypes = new ArrayList<>();

        for (String identifier : cli.split(",")) {
            WsResultType resultType = new WsResultType();
            resultType.setIdentifier(identifier);

            String suffix = ClientUtils.getSuffixFor(identifier, allResultTypes);

            if (suffix != null) {
                resultType.setFileSuffix(ClientUtils.getSuffixFor(identifier, allResultTypes));
            } else {
                throw new RuntimeException("Incorrect output format identifier: " + identifier);
            }

            resultTypes.add(resultType);
        }
        return resultTypes;
    }


    /**
     * Check status of rest request in specified time intervals
     *
     * @param client
     * @param jobid
     * @param interval
     * @throws InterruptedException
     * @throws IOException
     * @throws ServiceException
     */
    public static void getStatusInIntervals(RestClient client, String jobid, Long interval) throws InterruptedException, IOException, ServiceException {

        String status = null;
        log.info("Refresh rate: {} seconds.", interval/1000);

        while (status == null || !status.equals("FINISHED")) {
            Thread.sleep(interval);
            status = client.checkStatus(jobid);
            log.info(status);
        }

        log.info("Synchronous job execution has finished");
    }


    /**
     * Read file content to a String or if file does not exist return input parameter
     *
     * @param sequence path to a file or sequence as a string
     * @return
     * @throws IOException
     */
    public static String loadData(String sequence) throws IOException {
        Path path = Paths.get(sequence);
        if(Files.exists(path)){
            return new String(Files.readAllBytes(Paths.get(sequence)));
        }else{
            return sequence;
        }
    }


    /**
     * Find file extension for a given identifier from list of WsResultType
     *
     * @param identifier
     * @param allResultTypes
     * @return
     */
    public static String getSuffixFor(String identifier, List<WsResultType> allResultTypes) {
        for (WsResultType resultType : allResultTypes) {
            if (resultType.getIdentifier().equals(identifier)) {
                return resultType.getFileSuffix();
            }
        }
        return null;
    }


    /**
     * Convert python generated string with options to Options object
     *
     * @param options
     * @param optionalParametersMessage
     */
    public static void parseOptionsFromFormattedString(Options options, String optionalParametersMessage) {

        for(String line : optionalParametersMessage.split("\n")){
            String[] fields = line.split("\t");
            options.addOption(fields[0].replace("--","").trim(),fields[1].trim(),true, fields[2].trim());
        }
    }
}
