package uk.ac.ebi.restclient;


import com.sun.jersey.api.client.ClientResponse;
import uk.ac.ebi.restclient.stubs.WsResultType;

import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Marshaller;
import javax.xml.rpc.ServiceException;
import java.io.*;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;


/**
 * Created by chojnasm on 17/08/2016.
 */
public class AbstractUtils {


    public static void checkResponseStatusCode(ClientResponse response, int expectedStatusCode) {
        if (response.getStatus() != expectedStatusCode) {
            throw new RuntimeException("Failed : HTTP error code : "
                    + response.getStatus());
        }
    }

    public static <T> void marshallToXML(T result) {
        try {
            JAXBContext jc = JAXBContext.newInstance(result.getClass());
            Marshaller marshaller = jc.createMarshaller();
            marshaller.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, true);
            marshaller.marshal(result, System.out);
        } catch (JAXBException e) {
            e.printStackTrace();
        }
    }

    public static List<WsResultType> processUserOutputFormats(String cli, List<WsResultType> allResultTypes) {
        List<WsResultType> resultTypes;
        resultTypes = new ArrayList<>();

        for (String identifier : cli.split(",")) {
            WsResultType resultType = new WsResultType();
            resultType.setIdentifier(identifier);

            String suffix = AbstractUtils.getSuffixFor(identifier, allResultTypes);

            if (suffix != null) {
                resultType.setFileSuffix(AbstractUtils.getSuffixFor(identifier, allResultTypes));
            } else {
                throw new RuntimeException("Incorrect output format identifier: " + identifier);
            }

            resultTypes.add(resultType);
        }
        return resultTypes;
    }


    public static void getStatusInIntervals(AbstractRestClient client, String jobid, Long interval) throws InterruptedException, IOException, ServiceException {

        String status = null;
        System.out.println("Refresh rate: 5 seconds.");

        while (status == null || !status.equals("FINISHED")) {
            Thread.sleep(interval);
            status = client.checkStatus(jobid);
            DateFormat dateFormat = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
            Date date = new Date();
            System.out.println(dateFormat.format(date) + " " + status); //2014/08/06 15:59:48
        }

        System.out.println("Synchronous job execution has finished");
    }


    /**
     * <p>The input data can be passed as:</p>
     * <ul>
     * <li>a filename</li>
     * <li>an entry identifier (e.g. UNIPROT:WAP_RAT)</li>
     * <li>raw data (e.g. "MRCSISLVLG")</li>
     * <li>data from standard input (STDIN)</li>
     * </ul>
     * <p>This method gets the data to be passed to the service, checking for
     * a file and loading it if necessary.</p>
     *
     * @param fileOptionStr Filename or entry identifier.
     * @return Data to use as input as a byte array.
     * @throws IOException
     */
    public static byte[] loadData(String fileOptionStr) throws IOException {
        byte[] retVal = null;
        if (fileOptionStr != null) {
            if (new File(fileOptionStr).exists()) { // File.
                retVal = readFile(new File(fileOptionStr));
            } else { // Entry Id or raw data.
                retVal = fileOptionStr.getBytes();
            }
        }
        return retVal;
    }

    public static byte[] readFile(File file) throws IOException, FileNotFoundException {
        if (!file.exists()) {
            throw new FileNotFoundException(file.getName() + " does not exist");
        }
        InputStream is = new FileInputStream(file);
        byte[] bytes = readStream(is);
        is.close();
        return bytes;
    }

    public static byte[] readStream(InputStream inStream) throws IOException {

        byte[] ret = null;
        while (inStream.available() > 0) {
            long length = inStream.available();
            byte[] bytes = new byte[(int) length];
            int offset = 0;
            int numRead = 0;
            while (offset < bytes.length &&
                    (numRead = inStream.read(bytes, offset, bytes.length - offset)) >= 0) {
                offset += numRead;
            }
            if (offset < bytes.length) {
                throw new IOException("Unable to read to end of stream");
            }

            if (ret == null)
                ret = bytes;
            else {
                byte[] tmp = ret.clone();
                ret = new byte[ret.length + bytes.length];
                System.arraycopy(tmp, 0, ret, 0, tmp.length);
                System.arraycopy(bytes, 0, ret, tmp.length, bytes.length);
            }
        }
        return ret;
    }

    public static String getSuffixFor(String identifier, List<WsResultType> allResultTypes) {
        for (WsResultType resultType : allResultTypes) {
            if (resultType.getIdentifier().equals(identifier)) {
                return resultType.getFileSuffix();
            }
        }
        return null;
    }
}
