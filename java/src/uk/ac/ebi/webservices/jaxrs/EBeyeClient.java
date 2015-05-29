/* $Id$
 * ======================================================================
 * 
 * Copyright 2008-2013 EMBL - European Bioinformatics Institute
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * 
 * ======================================================================
 * EB-eye web service Java client using Jersey.
 * ----------------------------------------------------------------------
 * Tested with:
 *   Sun Java 1.7.0_60 with Jersey 2.7.
 * ====================================================================== */
package uk.ac.ebi.webservices.jaxrs;

import java.util.List;

import javax.ws.rs.client.Client;
import javax.ws.rs.client.ClientBuilder;
import javax.ws.rs.client.Invocation;
import javax.ws.rs.client.WebTarget;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.GnuParser;
import org.apache.commons.cli.Options;

import uk.ac.ebi.webservices.jaxrs.stubs.ebeye.WsDomain;
import uk.ac.ebi.webservices.jaxrs.stubs.ebeye.WsDomains;
import uk.ac.ebi.webservices.jaxrs.stubs.ebeye.WsEntries;
import uk.ac.ebi.webservices.jaxrs.stubs.ebeye.WsEntry;
import uk.ac.ebi.webservices.jaxrs.stubs.ebeye.WsFacet;
import uk.ac.ebi.webservices.jaxrs.stubs.ebeye.WsFacetValue;
import uk.ac.ebi.webservices.jaxrs.stubs.ebeye.WsFacets;
import uk.ac.ebi.webservices.jaxrs.stubs.ebeye.WsField;
import uk.ac.ebi.webservices.jaxrs.stubs.ebeye.WsFieldInfo;
import uk.ac.ebi.webservices.jaxrs.stubs.ebeye.WsIndexInfo;
import uk.ac.ebi.webservices.jaxrs.stubs.ebeye.WsOption;
import uk.ac.ebi.webservices.jaxrs.stubs.ebeye.WsResult;
import uk.ac.ebi.webservices.jaxrs.stubs.ebeye.Wsurl;

/** <p>EB-eye web service Java client using Apache HttpComponents.</p>
 * 
 * <p>See:</p>
 * <ul>
 * <li><a href="http://www.ebi.ac.uk/Tools/webservices/services/eb-eye_rest">http://www.ebi.ac.uk/Tools/webservices/services/eb-eye_rest</a></li>
 * <li><a href="http://www.ebi.ac.uk/Tools/webservices/tutorials/06_programming/java">http://www.ebi.ac.uk/Tools/webservices/tutorials/06_programming/java</a></li>
 * <li><a href="https://jersey.java.net/">https://jersey.java.net/</a></li>
 * </ul>
 */
public class EBeyeClient {
	/** Output level. Controlled by the --verbose and --quiet options. */
	protected int               outputLevel     = 1;
	/** Debug level. Controlled by the --debugLevel option. */
	private int                 debugLevel      = 0;
	/** URL for service endpoint. */
	private String              serviceEndPoint = "http://www.ebi.ac.uk/ebisearch/ws/rest";
	/** Client version/revision */
	private String              revision        = "$Revision: 2640 $";
	private Client              client          = null;
	/** Usage message */
	private static final String usageMsg        = "EB-eye\n"
	                                              + "======\n"
	                                              + "\n"
	                                              + "-h, --help\n"
	                                              + "  This help/usage message.\n"
	                                              + "\n"
	                                              //+ "-q, --quiet\n"
	                                              //+ "  Decrease output messages.\n"
	                                              //+ "\n"
	                                              //+ "-v, --verbose\n"
	                                              //+ "  Increase output messages.\n"
	                                              //+ "\n"
	                                              + "--debugLevel <level>\n"
	                                              + "  Set debug output level. (default: 0)\n"
	                                              + "\n"
	                                              + "--endpoint <endpoint>\n"
	                                              + "  Override service endpoint used.\n"
	                                              + "\n"
	                                              + "--getDomainsHierarchy\n"
	                                              + "  Returns the hierarchy of the domains available.\n"
	                                              + "\n"
	                                              + "--getDomainDetails <domain>\n"
	                                              + "  Returns the list of fields that can be retrieved for a particular domain.\n"
	                                              + "\n"
	                                              + "--getResults <domain> <query> <fields> <start> <size> <fieldurl> <viewurl> <sortfield> <order>\n"
	                                              + "  Executes a query and returns a list of results. Each result contains the \n"
	                                              + "  values for each field specified in the \"fields\" argument in the same order\n"
	                                              + "  as they appear in the \"fields\" list.\n"
	                                              + "\n"
	                                              + "--getFacetedResults <domain> <query> <fields> <start> <size> <fieldurl> <viewurl> <sortfield> <order> <facetcount> <facetfield> <facets>\n"
	                                              + "  Executes a query and returns a list of results with facets. Each result contains the \n"
	                                              + "  values for each field specified in the \"fields\" argument in the same order\n"
	                                              + "  as they appear in the \"fields\" list.\n" + "\n"
	                                              + "--getEntries <domain> <entries> <fields> <fieldurl> <viewurl>\n"
	                                              + "  Search for entries in a domain and returns the values for some of the \n"
	                                              + "  fields of these entries. The result contains the values for each field \n"
	                                              + "  specified in the \"fields\" argument in the same order as they appear in the\n" + "  \"fields\" list.\n"
	                                              + "\n" + "--getDomainsReferencedInDomain <domain>\n"
	                                              + "  Returns the list of domains with entries referenced in a particular domain.\n"
	                                              + "  These domains are indexed in the EB-eye.\n" + "\n" + "--getDomainsReferencedInEntry <domain> <entry>\n"
	                                              + "  Returns the list of domains with entries referenced in a particular domain\n"
	                                              + "  entry. These domains are indexed in the EB-eye.\n" + "\n"
	                                              + "--getReferencedEntries <domain> <entries> <referencedDomain> <fields> <start> <size> <fieldurl> <viewurl>\n"
	                                              + "  Returns the list of referenced entry identifiers from a domain referenced\n"
	                                              + "  in a particular domain entry.\n" + "\n" + "Further information:\n" + "\n"
	                                              + "  http://www.ebi.ac.uk/Tools/webservices/services/eb-eye\n"
	                                              + "  http://www.ebi.ac.uk/Tools/webservices/tutorials/java\n" + "\n" + "Support/Feedback:\n" + "\n"
	                                              + "  http://www.ebi.ac.uk/support/\n" + "\n";

	/** Default constructor.
	 */
	public EBeyeClient() {
		// Set the HTTP user agent string for (java.net) requests.
		this.setUserAgent();
	}

	/** <p>Set the HTTP User-agent header string for the client.</p>
	 */
	private void setUserAgent() {
		printDebugMessage("setUserAgent", "Begin", 1);
		String currentUserAgent = System.getProperty("http.agent");
		if (currentUserAgent == null || !currentUserAgent.startsWith("EBI-Sample-Client/")) {
			// Java web calls use the http.agent property as a prefix to the default user-agent.
			String clientVersion = this.revision.substring(11, this.revision.length() - 2);
			String clientUserAgent = "EBI-Sample-Client/" + clientVersion + " (" + this.getClass().getName() + "; " + System.getProperty("os.name") + ")";
			if (currentUserAgent != null) {
				System.setProperty("http.agent", clientUserAgent + " " + currentUserAgent);
			}
			else {
				System.setProperty("http.agent", clientUserAgent);
			}
		}
		printDebugMessage("setUserAgent", "End", 1);
	}

	/**
	 * Print the usage message to STDOUT.
	 */
	private static void printUsage() {
		System.out.print(usageMsg);
	}

	/**
	 * Set debug level.
	 * 
	 * @param level Debug level. 0 = off.
	 */
	public void setDebugLevel(int level) {
		printDebugMessage("setDebugLevel", "Begin " + level, 1);
		if (level > -1) {
			debugLevel = level;
		}
		printDebugMessage("setDebugLevel", "End", 1);
	}

	/**
	 * Get current debug level.
	 * 
	 * @return Debug level.
	 */
	public int getDebugLevel() {
		printDebugMessage("getDebugLevel", new Integer(debugLevel).toString(), 1);
		return debugLevel;
	}

	/**
	 * Output debug message at specified level
	 * 
	 * @param methodName Name of the method to appear in the message
	 * @param message The message
	 * @param level Level at which to output message
	 */
	protected void printDebugMessage(String methodName, String message, int level) {
		if (level <= debugLevel) {
			System.err.println("[" + methodName + "()] " + message);
		}
	}

	/**
	 * Set the output level.
	 * 
	 * @param level Output level. 0 = quiet, 1 = normal and 2 = verbose.
	 */
	public void setOutputLevel(int level) {
		printDebugMessage("setOutputLevel", "Begin " + level, 1);
		if (level > -1) {
			this.outputLevel = level;
		}
		printDebugMessage("setOutputLevel", "End", 1);
	}

	/**
	 * Get the current output level.
	 * 
	 * @return Output level.
	 */
	public int getOutputLevel() {
		printDebugMessage("getOutputLevel", new Integer(this.outputLevel).toString(), 1);
		return this.outputLevel;
	}

	/**
	 * Set the service endpoint URL for generating the service connection.
	 * 
	 * @param urlStr Service endpoint URL as a string.
	 */
	public void setServiceEndPoint(String urlStr) {
		printDebugMessage("setServiceEndpoint", "urlStr: " + urlStr, 1);
		this.serviceEndPoint = urlStr;
	}

	/**
	 * Get the current service endpoint URL.
	 * 
	 * @return The service endpoint URL as a string.
	 */
	public String getServiceEndPoint() {
		printDebugMessage("getServiceEndpoint", "serviceEndPoint: " + this.serviceEndPoint, 1);
		return this.serviceEndPoint;
	}

	/**
	 * Print a progress message.
	 * 
	 * @param msg The message to print.
	 * @param level The output level at or above which this message should be displayed.
	 */
	protected void printProgressMessage(String msg, int level) {
		if (outputLevel >= level) {
			System.err.println(msg);
		}
	}

	/**
	 * Get HttpClient
	 * @return
	 */
	protected Client getClient() {
		if (client == null) {
			client = ClientBuilder.newClient();
		}
		return client;
	}

	protected WebTarget getTarget() {
		return getClient().target(this.serviceEndPoint);
	}

	/** Get domain tree.
	 * @return domain tree
	 */
	public WsResult getDomainsHierarchy() {
		printDebugMessage("getDomainsHierarchy", "Begin", 1);
		Invocation.Builder builder = getTarget().request();
		WsResult result = builder.get(WsResult.class);

		printDebugMessage("getDomainsHierarchy", "End", 1);
		return result;
	}

	/**
	 * Get domain
	 * @param domain
	 * @return
	 */
	public WsResult getDomainDetails(String domain) {
		printDebugMessage("getDomainDetails", "Begin", 1);

		Invocation.Builder builder = getTarget().path(domain).request();
		WsResult result = builder.get(WsResult.class);

		printDebugMessage("getDomainDetails", "End", 1);
		return result;
	}

	/** Get search results.
	 * 
	 * @return Domain description object tree.
	 */
	public WsResult getResults(String domain, String query, String fields, int start, int size, boolean fieldurl, boolean viewurl, String sortField, String order) {
		printDebugMessage("getResults", "Begin", 1);

		Invocation.Builder builder = getTarget().path(domain).queryParam("query", query).queryParam("fields", fields).queryParam("start", start).queryParam("size",
		                                                                                                                                                    size).queryParam("fieldurl",
		                                                                                                                                                                     fieldurl).queryParam("viewurl",
		                                                                                                                                                                                          viewurl).queryParam("sortfield",
		                                                                                                                                                                                                              sortField).queryParam("order",
		                                                                                                                                                                                                                                    order).request();
		WsResult result = builder.get(WsResult.class);

		printDebugMessage("getResults", "End", 1);
		return result;
	}

	/** Get faceted search results.
	 * 
	 * @return Domain description object tree.
	 */
	public WsResult getFacetedResults(String domain, String query, String fields, int start, int size, boolean fieldurl, boolean viewurl, String sortField,
	                                  String order, int facetCount, String facetfields, String facets) {
		printDebugMessage("getResults", "Begin", 1);

		Invocation.Builder builder = getTarget().path(domain).queryParam("query", query).queryParam("fields", fields).queryParam("start", start).queryParam("size",
		                                                                                                                                                    size).queryParam("fieldurl",
		                                                                                                                                                                     fieldurl).queryParam("viewurl",
		                                                                                                                                                                                          viewurl).queryParam("sortfield",
		                                                                                                                                                                                                              sortField).queryParam("order",
		                                                                                                                                                                                                                                    order).queryParam("facetcount",
		                                                                                                                                                                                                                                                      facetCount).queryParam("facetfields",
		                                                                                                                                                                                                                                                                             facetfields).queryParam("facets",
		                                                                                                                                                                                                                                                                                                     facets).request();

		WsResult result = builder.get(WsResult.class);

		printDebugMessage("getResults", "End", 1);
		return result;
	}

	/**
	 * Get entries
	 * @param domain
	 * @param entries
	 * @param fields
	 * @param fieldurl
	 * @param viewurl
	 * @return
	 */
	public WsResult getEntries(String domain, String entries, String fields, boolean fieldurl, boolean viewurl) {
		printDebugMessage("getEntries", "Begin", 1);

		String path = domain + "/entry/" + entries;
		Invocation.Builder builder = getTarget().path(path).queryParam("fields", fields).queryParam("fieldurl", fieldurl).queryParam("viewurl", viewurl).request();

		WsResult result = builder.get(WsResult.class);
		printDebugMessage("getEntries", "End", 1);
		return result;
	}

	/**
	 * Get domains referenced by a domain
	 * @param domain
	 * @return
	 */
	public WsResult getDomainsReferencedInDomain(String domain) {
		printDebugMessage("getDomainsReferencedInDomain", "Begin", 1);

		String path = domain + "/xref";
		Invocation.Builder builder = getTarget().path(path).request();
		WsResult result = builder.get(WsResult.class);

		printDebugMessage("getDomainsReferencedInDomain", "End", 1);
		return result;
	}

	/**
	 * Get domains referenced by an entry
	 * @param domain
	 * @param entry
	 * @return
	 */
	public WsResult getDomainsReferencedInEntry(String domain, String entry) {
		printDebugMessage("getDomainsReferencedInEntry", "Begin", 1);

		String path = domain + "/entry/" + entry + "/xref";
		Invocation.Builder builder = getTarget().path(path).request();
		WsResult result = builder.get(WsResult.class);

		printDebugMessage("getDomainsReferencedInEntry", "End", 1);
		return result;
	}

	/**
	 * Get referenced entries
	 * @param domain
	 * @param entries
	 * @param referencedDomain
	 * @param fields
	 * @param start
	 * @param size
	 * @param fieldurl
	 * @param viewurl
	 * @return
	 */
	public WsResult getReferencedEntries(String domain, String entries, String referencedDomain, String fields, int start, int size, boolean fieldurl,
	                                     boolean viewurl) {
		printDebugMessage("getReferencedEntries", "Begin", 1);

		String path = domain + "/entry/" + entries + "/xref/" + referencedDomain;
		Invocation.Builder builder = getTarget().path(path).queryParam("fields", fields).queryParam("start", start).queryParam("size", size).queryParam("fieldurl",
		                                                                                                                                                fieldurl).queryParam("viewurl",
		                                                                                                                                                                     viewurl).request();

		WsResult result = builder.get(WsResult.class);

		printDebugMessage("getReferencedEntries", "End", 1);
		return result;
	}

	/**
	 * Print domain tree.
	 */
	public void printGetDomainsHierarchy() {
		printDebugMessage("printGetDomainsHierarchy", "Begin", 1);

		WsResult result = getDomainsHierarchy();
		WsDomains domains = result.getDomains();
		if (domains != null) {
			for (WsDomain domain : domains.getDomain()) {
				printDomainsInHierarchy(domain, "");
			}
		}

		printDebugMessage("printGetDomainsHierarchy", "End", 1);
	}

	private void printDomainsInHierarchy(WsDomain domain, String indent) {
		System.out.println(indent + domain.getId() + ": " + domain.getName());
		if (domain.getSubdomains() != null) {
			for (WsDomain subDomain : domain.getSubdomains().getDomain()) {
				printDomainsInHierarchy(subDomain, indent + '\t');
			}
		}
	}

	/**
	 * Print domain tree.
	 * @param domainId
	 */
	public void printGetDomainDetails(String domainId) {
		printDebugMessage("printGetDomainDetails", "Begin", 1);

		WsResult result = getDomainDetails(domainId);
		WsDomains domains = result.getDomains();
		if (domains != null) {
			for (WsDomain domain : domains.getDomain()) {
				printDetailsInHierarchy(domain);
			}
		}

		printDebugMessage("printGetDomainDetails", "End", 1);
	}

	String[] labels = { "searchable", "retrievable", "sortable", "facet", "alias", "referenced domain", "referenced field", "type" };

	private void printDetailsInHierarchy(WsDomain domain) {
		System.out.println(domain.getName() + " (" + domain.getId() + ")");
		if (domain.getSubdomains() == null) {
			if (domain.getIndexInfos() != null) {
				for (WsIndexInfo indexInfo : domain.getIndexInfos().getIndexInfo()) {
					System.out.println(indexInfo.getName() + ": " + indexInfo.getValue());
				}
				System.out.println();
			}

			if (domain.getFieldInfos() != null) {

				System.out.println(getDomainDetailHeaders());
				StringBuffer sb = null;
				String option = null;
				for (WsFieldInfo fieldInfo : domain.getFieldInfos().getFieldInfo()) {
					sb = new StringBuffer(domain.getId());
					sb.append('\t');
					sb.append(fieldInfo.getId());
					for (int i = 0; i < labels.length; i++) {
						option = findOptionValue(fieldInfo.getOptions().getOption(), labels[i]);
						sb.append('\t');
						sb.append(option);
					}
					System.out.println(sb.toString());
				}
				System.out.println();
			}

		}
		else {
			System.out.println();
			for (WsDomain subDomain : domain.getSubdomains().getDomain()) {
				printDetailsInHierarchy(subDomain);
			}
		}
	}

	private String getDomainDetailHeaders() {
		StringBuffer sb = new StringBuffer("domain\tfield\t");
		if (labels != null && labels.length > 0) {
			sb.append(labels[0]);
			for (int i = 1; i < labels.length; i++) {
				sb.append('\t');
				sb.append(labels[i]);
			}
		}
		return sb.toString();
	}

	private String findOptionValue(List<WsOption> options, String name) {
		for (WsOption option : options) {
			if (option.getName().equals(name)) {
				return option.getValue();
			}
		}
		return "";
	}

	/**
	 * Print search results.
	 */
	public void printGetResults(String domain, String query, String fields, int start, int size, boolean fieldurl, boolean viewurl, String sortField,
	                            String order) {
		printDebugMessage("printGetResults", "Begin", 1);

		WsResult result = getResults(domain, query, fields, start, size, fieldurl, viewurl, sortField, order);
		WsEntries entries = result.getEntries();
		if (entries != null) {
			for (WsEntry entry : entries.getEntry()) {
				print(entry);
			}
		}

		printDebugMessage("printGetResults", "End", 1);
	}

	private void print(WsEntry entry) {
		if (entry.getFields() != null) {
			List<String> values = null;
			if (entry.getFields() != null) {
				for (WsField field : entry.getFields().getField()) {
					values = field.getValues().getValue();
					if (values.size() > 0) {
						for (String value : values) {
							System.out.println(value);
						}
					}
				}
			}

			if (entry.getFieldURLs() != null) {
				for (Wsurl url : entry.getFieldURLs().getFieldURL()) {
					System.out.println(url.getValue());
				}
			}

			if (entry.getViewURLs() != null) {
				for (Wsurl url : entry.getViewURLs().getViewURL()) {
					System.out.println(url.getValue());
				}
			}
		}
		System.out.println();
	}

	/**
	 * Print search results.
	 * @param domain
	 * @param query
	 * @param fields
	 * @param start
	 * @param size
	 * @param fieldurl
	 * @param viewurl
	 * @param sortField
	 * @param order
	 * @param facetCount
	 * @param facetfields
	 * @param selectedfacets
	 */
	public void printGetFacetedResults(String domain, String query, String fields, int start, int size, boolean fieldurl, boolean viewurl, String sortField,
	                                   String order, int facetCount, String facetfields, String selectedfacets) {
		printDebugMessage("printGetFacetedResults", "Begin", 1);

		WsResult result = getFacetedResults(domain, query, fields, start, size, fieldurl, viewurl, sortField, order, facetCount, facetfields, selectedfacets);
		WsEntries entries = result.getEntries();
		if (entries != null) {
			for (WsEntry entry : entries.getEntry()) {
				print(entry);
			}
		}

		System.out.println();

		WsFacets facets = result.getFacets();
		if (facets != null) {
			for (WsFacet facet : facets.getFacet()) {
				print(facet);
			}
		}

		printDebugMessage("printGetFacetedResults", "End", 1);
	}

	private void print(WsFacet facet) {
		System.out.println(facet.getLabel() + " (" + facet.getId() + ")");
		for (WsFacetValue value : facet.getFacetValues().getFacetValue()) {
			System.out.println(value.getLabel() + " (" + value.getValue() + ") " + value.getCount());
		}
		System.out.println();
	}

	/**
	 * Print entries
	 * @param domain
	 * @param entryIds
	 * @param fields
	 * @param fieldurl
	 * @param viewurl
	 */
	public void printGetEntries(String domain, String entryIds, String fields, boolean fieldurl, boolean viewurl) {
		printDebugMessage("printGetEntries", "Begin", 1);

		WsResult result = getEntries(domain, entryIds, fields, fieldurl, viewurl);
		WsEntries entries = result.getEntries();
		if (entries != null) {
			for (WsEntry entry : entries.getEntry()) {
				print(entry);
			}
		}

		printDebugMessage("printGetEntries", "End", 1);
	}

	/**
	 * Print domains referenced by a domain
	 * @param domain
	 */
	public void printGetDomainsReferencedInDomain(String domain) {
		printDebugMessage("printGetDomainsReferencedInDomain", "Begin", 1);

		WsResult result = getDomainsReferencedInDomain(domain);
		WsDomains domains = result.getDomains();
		if (domains != null) {
			printIds(domains);
		}

		printDebugMessage("printGetDomainsReferencedInDomain", "End", 1);
	}

	private void printIds(WsDomains domains) {
		for (WsDomain domain : domains.getDomain()) {
			System.out.println(domain.getId());
		}
	}

	/**
	 * Print domains referenced by an entry
	 * @param domain
	 * @param entry
	 */
	public void printGetDomainsReferencedInEntry(String domain, String entry) {
		printDebugMessage("printGetDomainsReferencedInEntry", "Begin", 1);

		WsResult result = getDomainsReferencedInEntry(domain, entry);
		WsDomains domains = result.getDomains();
		if (domains != null) {
			printIds(domains);
		}

		printDebugMessage("printGetDomainsReferencedInEntry", "End", 1);
	}

	/**
	 * Print referenced entries
	 * @param domain
	 * @param entries
	 * @param referencedDomain
	 * @param fields
	 * @param start
	 * @param size
	 * @param fieldurl
	 * @param viewurl
	 */
	public void printGetReferencedEntries(String domain, String entryIds, String referencedDomain, String fields, int start, int size, boolean fieldurl,
	                                      boolean viewurl) {
		printDebugMessage("printGetReferencedEntries", "Begin", 1);

		WsResult result = getReferencedEntries(domain, entryIds, referencedDomain, fields, start, size, fieldurl, viewurl);
		WsEntries entries = result.getEntries();
		if (entries != null) {
			for (WsEntry entry : entries.getEntry()) {
				printReference(entry);
			}
		}

		printDebugMessage("printGetReferencedEntries", "End", 1);
	}

	private void printReference(WsEntry entry) {
		System.out.println(entry.getId() + " " + entry.getReferenceCount());
		if (entry.getReferences() != null) {
			for (WsEntry ref : entry.getReferences().getReference()) {

				for (WsField field : ref.getFields().getField()) {
					for (String value : field.getValues().getValue()) {
						System.out.println(value);
					}
				}

				if (ref.getFieldURLs() != null) {
					for (Wsurl url : ref.getFieldURLs().getFieldURL()) {
						System.out.println(url.getValue());
					}
				}

				if (ref.getViewURLs() != null) {
					for (Wsurl url : ref.getViewURLs().getViewURL()) {
						System.out.println(url.getValue());
					}
				}
			}
		}
		System.out.println();
	}

	/**
	 * Built the option descriptions for processing the command-line arguments.
	 * 
	 * @param options
	 *            Command-line options description.
	 */
	public static void addCliOptions(Options options) {
		// --help
		options.addOption("h", "help", false, "Help/usage message");
		// --quiet
		options.addOption("q", "quiet", false, "Decrease output");
		// --verbose
		options.addOption("v", "verbose", false, "Increase output");
		// --debugLevel
		options.addOption("debugLevel", true, "Level of debug output");
		// --endpoint
		options.addOption("endpoint", true, "Alternative server endpoint");

		// --getDomainsHierarchy
		options.addOption("getDomainsHierarchy", false, "Get the hierarchy of search domains");

		// --getDomainDetails <domain>
		options.addOption("getDomainDetails", true, "Get domain details");

		// --getResults <domain> <query> <fields> <start> <size> <fieldurl> <viewurl> <sortfield> <order>
		options.addOption("getResults", true, "Get entries which match query");
		options.getOption("getResults").setArgs(9);

		// --getFacetedResults <domain> <query> <fields> <start> <size> <fieldurl> <viewurl> <sortfield> <order> <facetcount> <facetfield> <facets>
		options.addOption("getFacetedResults", true, "Get entries which match query with facets");
		options.getOption("getFacetedResults").setArgs(12);

		// --getEntries <domain> <entries> <fields> <fieldurl> <viewurl>
		options.addOption("getEntries", true, "Get data from a specific set of entries");
		options.getOption("getEntries").setArgs(5);

		// --getDomainsReferencedInDomain <domain>
		options.addOption("getDomainsReferencedInDomain", true, "Domains cross-referenced by domain");

		// --getDomainsReferencedInEntry <domain> <entry>
		options.addOption("getDomainsReferencedInEntry", true, "Domains cross-referenced by entry");
		options.getOption("getDomainsReferencedInEntry").setArgs(2);

		// --getReferencedEntries <domain> <entry> <referencedDomain> <fields> <start> <size> <fieldurl> <viewurl>
		options.addOption("getReferencedEntries", true, "Entries referenced by an entry");
		options.getOption("getReferencedEntries").setArgs(8);

	}

	/**
	 * Entry point for running as an application
	 * 
	 * @param args
	 *            list of command-line options
	 */
	public static void main(String[] args) {

		int exitVal = 0; // Exit value
		int argsLength = args.length; // Number of command-line arguments

		// Configure the command-line options
		Options options = new Options();
		addCliOptions(options);
		CommandLineParser cliParser = new GnuParser(); // Create the command
		// line parser

		// Create the client object.
		EBeyeClient ebeye = new EBeyeClient();
		try {
			// Parse the command-line
			CommandLine cli = cliParser.parse(options, args);
			// Usage info
			if (argsLength == 0 || cli.hasOption("help")) {
				printUsage();
				System.exit(0);
			}
			// Modify output level according to the quiet and verbose options
			if (cli.hasOption("q")) {
				ebeye.outputLevel--;
			}
			if (cli.hasOption("v")) {
				ebeye.outputLevel++;
			}
			// Set debug level
			if (cli.hasOption("debugLevel")) {
				ebeye.setDebugLevel(Integer.parseInt(cli.getOptionValue("debugLevel")));
			}
			// Alternative service endpoint
			if (cli.hasOption("endpoint")) {
				ebeye.setServiceEndPoint(cli.getOptionValue("endpoint"));
			}

			// --listDomains
			if (cli.hasOption("getDomainsHierarchy")) {
				ebeye.printGetDomainsHierarchy();
			}
			// --getDomainDetails
			else if (cli.hasOption("getDomainDetails")) {
				ebeye.printGetDomainDetails(cli.getOptionValue("getDomainDetails"));
			}
			// --getResults
			else if (cli.hasOption("getResults")) {
				String[] vals = cli.getOptionValues("getResults");
				ebeye.printGetResults(vals[0],
				                      vals[1],
				                      vals[2],
				                      Integer.parseInt(vals[3]),
				                      Integer.parseInt(vals[4]),
				                      Boolean.parseBoolean(vals[5]),
				                      Boolean.parseBoolean(vals[6]),
				                      vals[7],
				                      vals[8]);
			}
			// --getFacetedResults
			else if (cli.hasOption("getFacetedResults")) {
				String[] vals = cli.getOptionValues("getFacetedResults");
				ebeye.printGetFacetedResults(vals[0],
				                             vals[1],
				                             vals[2],
				                             Integer.parseInt(vals[3]),
				                             Integer.parseInt(vals[4]),
				                             Boolean.parseBoolean(vals[5]),
				                             Boolean.parseBoolean(vals[6]),
				                             vals[7],
				                             vals[8],
				                             Integer.parseInt(vals[9]),
				                             vals[10],
				                             vals[11]);
			}
			// --getEntries
			else if (cli.hasOption("getEntries")) {
				String[] vals = cli.getOptionValues("getEntries");
				ebeye.printGetEntries(vals[0], vals[1], vals[2], Boolean.parseBoolean(vals[3]), Boolean.parseBoolean(vals[4]));
			}
			// --getDomainsReferencedInDomain
			else if (cli.hasOption("getDomainsReferencedInDomain")) {
				ebeye.printGetDomainsReferencedInDomain(cli.getOptionValue("getDomainsReferencedInDomain"));
			}
			// --getDomainsReferencedInEntry
			else if (cli.hasOption("getDomainsReferencedInEntry")) {
				String[] vals = cli.getOptionValues("getDomainsReferencedInEntry");
				ebeye.printGetDomainsReferencedInEntry(vals[0], vals[1]);
			}
			// --getReferencedEntries <domain> <entry> <referencedDomain>
			else if (cli.hasOption("getReferencedEntries")) {
				String[] vals = cli.getOptionValues("getReferencedEntries");
				ebeye.printGetReferencedEntries(vals[0],
				                                vals[1],
				                                vals[2],
				                                vals[3],
				                                Integer.parseInt(vals[4]),
				                                Integer.parseInt(vals[5]),
				                                Boolean.parseBoolean(vals[6]),
				                                Boolean.parseBoolean(vals[7]));
			}
			else {
				System.err.println("Error: unknown action, see --help");
				exitVal = 1;
			}
		} catch (Exception ex) {
			System.err.println("ERROR: " + ex.getMessage());
			if (ebeye.getOutputLevel() > 0) {
				ex.printStackTrace();
			}
			exitVal = 1;
		}
		System.exit(exitVal);
	}

}
