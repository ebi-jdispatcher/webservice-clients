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

import com.sun.jersey.api.client.ClientResponse;
import org.apache.commons.cli.Options;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import restclient.stubs.WsError;
import restclient.stubs.WsResultType;

import org.w3c.dom.*;
import javax.xml.parsers.*;
import org.xml.sax.InputSource;
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


public class ClientUtilsemboss_dottup {


//    private static final Logger log = LoggerFactory.getLogger(ClientUtilsemboss_dottup.class);

    /**
     * Check if Http response code is as expected
     *
     * @param response
     */
    public static boolean isResponseCorrect(ClientResponse response, int debugLevel) {
        if (response == null) {
            return false;
        } else if (response.getStatus() != 200) {

            printDebugMessage("isResponseCorrect", response.toString(),
                    41, debugLevel);
            WsError wsError = response.getEntity(WsError.class);
            printDebugMessage("isResponseCorrect", wsError.getError() + "\n",
                    41, debugLevel);
            System.out.println(wsError.getError());
            return false;
        }
        return true;
    }

    /**
     * Print object as XML
     *
     * @param result
     * @param <T>
     */
    public static <T> void marshallToXML(T result, int debugLevel, String target) throws JAXBException {
        String xmlString = "";
        StringWriter sw = new StringWriter();
        JAXBContext jc = JAXBContext.newInstance(result.getClass());
        Marshaller marshaller = jc.createMarshaller();
        marshaller.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, true);
        marshaller.marshal(result, sw);
        xmlString = sw.toString();
        //System.out.println(xmlString);
        if (target.equals("parameters")){
            printParsedXML(xmlString, debugLevel);
        } else if (target.equals("types")) {
            printParsedXMLTypes(xmlString, debugLevel);
        }
    }

    public static void printParsedXML(String xmlString, int debugLevel){
        try {
            DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
            DocumentBuilder db = dbf.newDocumentBuilder();
            InputSource is = new InputSource();
            is.setCharacterStream(new StringReader(xmlString));
            Document doc = db.parse(is);

            NodeList nodes = doc.getElementsByTagName("parameter");
            try {
                for (int i = 0; i < nodes.getLength(); i++) {
                    Element element = (Element) nodes.item(i);

                    String n = "";
                    try {
                        NodeList name = element.getElementsByTagName("name");
                        Element line = (Element) name.item(0);
                        n = line.getTextContent();
                    } catch (Exception e){
                        //skip
                    }

                    String d = "";
                    try {
                        NodeList description = element.getElementsByTagName("description");
                        Element line = (Element) description.item(0);
                        d = line.getTextContent();
                    } catch (Exception e){
                        //skip
                    }

                    String t = "";
                    try {
                        NodeList type = element.getElementsByTagName("type");
                        Element line = (Element) type.item(0);
                        t = line.getTextContent();
                    } catch (Exception e){
                        //skip
                    }

                    if (!n.equals("") && !t.equals("")) System.out.println(n + "\t" + t);
                    if (!d.equals("")) System.out.println(d);
                }
            } catch (Exception e){
                printDebugMessage("printParsedXML", "Values not available", 11, debugLevel);
                e.printStackTrace();
            }

            nodes = doc.getElementsByTagName("value");


            try {
                for (int i = 0; i < nodes.getLength(); i++) {
                    Element element = (Element) nodes.item(i);

                    String v = "";
                    try {
                        NodeList value = element.getElementsByTagName("value");
                        Element line = (Element) value.item(0);
                        v = line.getTextContent();
                    } catch (Exception e){
                        //skip
                    }

                    String l = "";
                    try {
                        NodeList label = element.getElementsByTagName("label");
                        Element line = (Element) label.item(0);
                        l = line.getTextContent();
                    } catch (Exception e){
                        //skip
                    }


                    String ke = "";
                    try {
                        NodeList key = element.getElementsByTagName("key");
                        Element line = (Element) key.item(0);
                        ke = line.getTextContent();
                    } catch (Exception e){
                        //skip
                    }

                    String va = "";
                    try {
                        NodeList val = element.getElementsByTagName("value");
                        Element line = (Element) val.item(0);
                        va = line.getTextContent();
                    } catch (Exception e){
                        //skip
                    }

                    if (!v.equals("")) System.out.println(v);
                    if (!l.equals("")) System.out.println("\t" + l);
                    if (!ke.equals("") && !va.equals("")) System.out.println("\t" + ke + "\t" + va);
                }
            } catch (Exception e){
                printDebugMessage("printParsedXML", "Values not available", 11, debugLevel);
                e.printStackTrace();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void printParsedXMLTypes(String xmlString, int debugLevel){
        try {
            DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
            DocumentBuilder db = dbf.newDocumentBuilder();
            InputSource is = new InputSource();
            is.setCharacterStream(new StringReader(xmlString));
            Document doc = db.parse(is);
            NodeList nodes = doc.getElementsByTagName("type");

            try {
                for (int i = 0; i < nodes.getLength(); i++) {
                    Element element = (Element) nodes.item(i);

                    String d = "";
                    try {
                        NodeList description = element.getElementsByTagName("description");
                        Element line = (Element) description.item(0);
                        d = line.getTextContent();
                    } catch (Exception e){
                        //skip
                    }

                    String f = "";
                    try{
                        NodeList fileSuffix = element.getElementsByTagName("fileSuffix");
                        Element line = (Element) fileSuffix.item(0);
                        f = line.getTextContent();
                    } catch (Exception e){
                        //skip
                    }

                    String id = "";
                    try {
                        NodeList identifier = element.getElementsByTagName("identifier");
                        Element line = (Element) identifier.item(0);
                        id = line.getTextContent();
                    } catch (Exception e){
                        //skip
                    }

                    String l = "";
                    try {
                        NodeList label = element.getElementsByTagName("label");
                        Element line = (Element) label.item(0);
                        l = line.getTextContent();
                    } catch (Exception e){
                        //skip
                    }

                    String t = "";
                    try {
                        NodeList mediaType = element.getElementsByTagName("mediaType");
                        Element line = (Element) mediaType.item(0);
                        t = line.getTextContent();
                    } catch (Exception e){
                        //skip
                    }

                    if (!id.equals("")) System.out.println(id);
                    if (!l.equals("")) System.out.println("\t" + l);
                    if (!d.equals("")) System.out.println("\t" + d);
                    if (!t.equals("")) System.out.println("\t" + t);
                    if (!f.equals("")) System.out.println("\t" + f);
                }

            } catch (Exception e){
                printDebugMessage("printParsedXML", "Types not available", 11, debugLevel);
                e.printStackTrace();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static List<WsResultType> processUserOutputFormats(String cli, List<WsResultType> allResultTypes,
                                                              int debugLevel) {
        List<WsResultType> resultTypes;
        resultTypes = new ArrayList<>();

        for (String identifier : cli.split(",")) {
            WsResultType resultType = new WsResultType();
            resultType.setIdentifier(identifier);

            String suffix = ClientUtilsemboss_dottup.getSuffixFor(identifier, allResultTypes);

            if (suffix != null) {
                resultType.setFileSuffix(ClientUtilsemboss_dottup.getSuffixFor(identifier, allResultTypes));
            } else {
                printDebugMessage("processUserOutputFormats",
                        "Incorrect output format identifier: " + identifier,
                        41, debugLevel);
                printDebugMessage("processUserOutputFormats",
                        "Correct identifiers: ", 11, debugLevel);
//                allResultTypes.stream().forEach(ws -> log.info(ws.getIdentifier()));
//                allResultTypes.stream()
//                        .forEach(ws -> printDebugMessage("processUserOutputFormats", ws.getIdentifier(), 11,
// debugLevel));
                System.exit(1);
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
    public static boolean getStatusInIntervals(RestClientemboss_dottup client, String jobid, int interval,
                                               int outputLevel, int debugLevel)
            throws InterruptedException, IOException, ServiceException {

        String status = null;
        printDebugMessage("getStatusInIntervals",
                String.format("Update status: every %s seconds.", interval), 11, debugLevel);

        while (status == null || !status.equals("FINISHED")) {
            Thread.sleep(interval);
            status = client.checkStatus(jobid);
            printDebugMessage("getStatusInIntervals", "Status: " + status,
                    11, debugLevel);
            if (status.equals("FAILURE")) {
                return false;
            }
            if (outputLevel > 0)
                System.out.println(status);
        }
        printDebugMessage("getStatusInIntervals", "Synchronous job execution has finished.",
                11, debugLevel);
        return true;
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
        if (Files.exists(path)) {
            return new String(Files.readAllBytes(Paths.get(sequence)));
        } else {
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

        for (String line : optionalParametersMessage.split("\n")) {
            String[] fields = line.split("\t");
            options.addOption(fields[0].replace("--", "").trim(), fields[1].trim(), true, fields[2].trim());
        }
    }


    /**
     * Print debug message
     */
    public static void printDebugMessage(String functionName, String message,
                                         int level, int debugLevel) {
        if (level <= debugLevel)
            System.out.println("[" + functionName + "] " + message);
    }
}
