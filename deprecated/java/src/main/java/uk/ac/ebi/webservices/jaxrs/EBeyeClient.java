/* $Id$
 * ======================================================================
 * 
 * Copyright 2008-2018 EMBL - European Bioinformatics Institute
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
 * EB-eye web service Java client using JAX-RS Client.
 * ----------------------------------------------------------------------
 * Tested with:
 *   Sun Java 1.7.0_60 with JAX-RS Client.
 * ====================================================================== */
package uk.ac.ebi.webservices.jaxrs;

import java.io.Closeable;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URI;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;

import javax.cache.Cache;
import javax.cache.CacheManager;
import javax.cache.Caching;
import javax.cache.configuration.MutableConfiguration;
import javax.cache.expiry.AccessedExpiryPolicy;
import javax.cache.expiry.Duration;
import javax.ws.rs.client.Client;
import javax.ws.rs.client.ClientBuilder;
import javax.ws.rs.client.Invocation;
import javax.ws.rs.client.WebTarget;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.GnuParser;
import org.apache.commons.cli.Options;
import org.apache.commons.lang3.StringUtils;
import org.apache.cxf.feature.StaxTransformFeature;
import org.apache.cxf.jaxrs.client.cache.CacheControlClientReaderInterceptor;
import org.apache.cxf.jaxrs.client.cache.CacheControlClientRequestFilter;
import org.apache.cxf.jaxrs.client.cache.Entry;
import org.apache.cxf.jaxrs.client.cache.Key;
import org.apache.cxf.transport.common.gzip.GZIPInInterceptor;
import org.apache.cxf.transport.common.gzip.GZIPOutInterceptor;

import uk.ac.ebi.webservices.jaxrs.stubs.ebeye.WsDomain;
import uk.ac.ebi.webservices.jaxrs.stubs.ebeye.WsEntry;
import uk.ac.ebi.webservices.jaxrs.stubs.ebeye.WsFacet;
import uk.ac.ebi.webservices.jaxrs.stubs.ebeye.WsFacetValue;
import uk.ac.ebi.webservices.jaxrs.stubs.ebeye.WsField;
import uk.ac.ebi.webservices.jaxrs.stubs.ebeye.WsFieldInfo;
import uk.ac.ebi.webservices.jaxrs.stubs.ebeye.WsIndexInfo;
import uk.ac.ebi.webservices.jaxrs.stubs.ebeye.WsOption;
import uk.ac.ebi.webservices.jaxrs.stubs.ebeye.WsResult;
import uk.ac.ebi.webservices.jaxrs.stubs.ebeye.WsResult.Domains;
import uk.ac.ebi.webservices.jaxrs.stubs.ebeye.WsResult.Entries;
import uk.ac.ebi.webservices.jaxrs.stubs.ebeye.WsResult.Facets;
import uk.ac.ebi.webservices.jaxrs.stubs.ebeye.WsResult.Suggestions;
import uk.ac.ebi.webservices.jaxrs.stubs.ebeye.WsResult.TopTerms;
import uk.ac.ebi.webservices.jaxrs.stubs.ebeye.WsSuggestion;
import uk.ac.ebi.webservices.jaxrs.stubs.ebeye.WsTermStats;
import uk.ac.ebi.webservices.jaxrs.stubs.ebeye.Wsurl;

/** <p>EB-eye web service Java client using Apache HttpComponents.</p>
 * 
 * <p>See:</p>
 * <ul>
 * <li><a href="http://www.ebi.ac.uk/ebisearch/swagger.ebi">http://www.ebi.ac.uk/ebisearch/swagger.ebi</a></li>
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
    private String              serviceEndPoint = "https://www.ebi.ac.uk/ebisearch/ws/rest";
    /** Client version/revision */
    private String              revision        = "$Revision: 2640 $";
    private Client              client          = null;
    
    private boolean enableCache = true;
    
    private final static String DEFAULT_CACHE_CONFIG = "/cache.ccf";
    private String cacheConfig = null;
    private String classpathCacheConfig = null;
    private static final String CACHE_NAME = "ebisearch_rest_cache";
    
    private boolean correctResponseNamespace = true;
    
    /** Usage message */
    private static final String usageMsg        = "EB-eye\n"
                                                  + "======\n"
                                                  + "\n"
                                                  + "--getDomainsHierarchy\n"
                                                  + "  Returns the hierarchy of the domains available.\n"
                                                  + "\n"
                                                  + "--getDomainDetails <domain>\n"
                                                  + "  Returns the list of fields that can be retrieved for a particular domain.\n"
                                                  + "\n"
                                                  + "--getNumberOfResults <domain> <query>\n"
                                                  + "  Executes a query and returns number of results.\n"
                                                  + "\n"
                                                  + "--getResults <domain> <query> <fields> [OPTIONS: --size | --start | --fieldurl | --viewurl | --sortfield | --order | --sort ]\n"
                                                  + "  Executes a query and returns a list of results. Each result contains the \n"
                                                  + "  values for each field specified in the \"fields\" argument in the same order\n"
                                                  + "  as they appear in the \"fields\" list.\n"
                                                  + "\n"
                                                  + "--getFacetedResults <domain> <query> <fields> [OPTIONS: --size | --start | --fieldurl | --viewurl | --sortfield | --order | --sort | --facetcount | --facetfields | --facets ]\n"
                                                  + "  Executes a query and returns a list of results with facets. Each result contains the \n"
                                                  + "  values for each field specified in the \"fields\" argument in the same order\n"
                                                  + "  as they appear in the \"fields\" list.\n"
                                                  + "\n"
                                                  + "--getEntries <domain> <entryids> <fields> [OPTIONS: --fieldurl | --viewurl]\n"
                                                  + "  Search for entries in a domain and returns the values for some of the \n"
                                                  + "  fields of these entries. The result contains the values for each field \n"
                                                  + "  specified in the \"fields\" argument in the same order as they appear in the\n"
                                                  + "  \"fields\" list.\n"
                                                  + "\n"
                                                  + "--getDomainsReferencedInDomain <domain>\n"
                                                  + "  Returns the list of domains with entries referenced in a particular domain.\n"
                                                  + "  These domains are indexed in the EB-eye.\n"
                                                  + "\n"
                                                  + "--getDomainsReferencedInEntry <domain> <entry>\n"
                                                  + "  Returns the list of domains with entries referenced in a particular domain\n"
                                                  + "  entry. These domains are indexed in the EB-eye.\n"
                                                  + "\n"
                                                  + "--getReferencedEntries <domain> <entryids> <referencedDomain> <fields> [OPTIONS: --size | --start | --fieldurl | --viewurl | --facetcount | --facetfields | --facets ]\n"
                                                  + "  Returns the list of referenced entry identifiers from a domain referenced\n"
                                                  + "  in a particular domain entry.\n"
                                                  + "\n"
                                                  + "--getTopTerms <domain> <field> [OPTIONS: --size | --excludes | --excludesets]\n"
                                                  + "  Returns the list of top N terms in a field\n"
                                                  + "\n"
                                                  + "--getMoreLikeThis <domain> <entryid> <fields> "
                                                  + "                  [OPTIONS: --size | --start | --fieldurl | --viewurl | --mltfields | --mintermfreq | --mindocfreq | --maxqueryterm | --excludes | --excludesets]\n"
                                                  + "  Returns the list of similar entries to a given one\n"
                                                  + "\n"
                                                  + "--getExtendedMoreLikeThis <domain> <entryid> <targetDomain> <fields> "
                                                  + "                  [OPTIONS: --size | --start | --fieldurl | --viewurl | --mltfields | --mintermfreq | --mindocfreq | --maxqueryterm | --excludes | --excludesets]\n"
                                                  + "  Returns the list of similar entries to a given one\n"
                                                  + "\n"
                                                  + "--getAutoComplete <domain> <term>\n"
                                                  + "  Returns suggested words from a given term \n"
                                                  + "\n"
                                                  + "-h, --help\n"
                                                  + "  This help/usage message.\n"
                                                  + "\n"
                                                  + "--debugLevel <level>\n"
                                                  + "  Set debug output level. (default: 0)\n"
                                                  + "\n"
                                                  + "--endpoint <endpoint>\n"
                                                  + "  Override service endpoint used.\n"
                                                  + "\n"
                                                  + "--size <size>\tnumber of entries to retrieve\n"
                                                  + "--start <start>\tindex of the first entry in results.\n"
                                                  + "--fieldurl <fieldurl>\twhether field links are included.\n"
                                                  + "--viewurl <viewurl>\twhether view links are included.\n"
                                                  + "--sortfield <sortfield>\tfield id to sort.\n"
                                                  + "--order <order>\tsort in ascending/descending order.\n"
                                                  + "--sort <sort>\tcomma separated value of sorting criteria.\n"
                                                  + "--facets <facets>\tcomma separated value of selected facet values.\n"
                                                  + "--facetcount <facetcount>\tnumber of facet values to retrieve.\n"
                                                  + "--facetfields <facetfields>\tfield ids associated with facets to retrieve.\n"
                                                  + "--mltfields <mltfields>\tfield ids  to be used for generating a morelikethis query.\n"
                                                  + "--mintermfreq <mintermfreq>\tfrequency below which terms will be ignored in the base document.\n"
                                                  + "--mindocfreq <mindocfreq>\tfrequency at which words will be ignored which do not occur in at least this many documents.\n"
                                                  + "--maxqueryterm <maxqueryterm>\tmaximum number of query terms that will be included in any generated query.\n"
                                                  + "--excludes <excludes>\tterms to be excluded.\n"
                                                  + "--excludesets <excludesets>\tstop word sets to be excluded.\n" + "\n"
                                                  + "--nocache. Disable cache\n"
                                                  + "--cacheConfig <properties file>\t Overwrite default cache configuration as properties files. See https://commons.apache.org/proper/commons-jcs/\n"
                                                  + "--noResponseNamespaceCorrection\t Correct EBI Search responses not compliant with wadl schema\n\n"
                                                  + "Further information:\n" + "\n"
                                                  + "  https://www.ebi.ac.uk/ebisearch/swagger.ebi\n"
                                                  + "  https://www.ebi.ac.uk/Tools/webservices/tutorials/java\n" + "\n" + "Support/Feedback:\n" + "\n"
                                                  + "  https://www.ebi.ac.uk/support/\n" + "\n"
                                                 ;

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

    public boolean isEnableCache() {
      return enableCache;
   }

   public void setEnableCache(boolean enableCache) {
      this.enableCache = enableCache;
   }

   public String getCacheConfig() {
      return cacheConfig;
   }

   /**
    * Set the Cache configuration files.
    * Basic configuration can be found here: https://commons.apache.org/proper/commons-jcs/BasicJCSConfiguration.html
    * and here form more options: https://commons.apache.org/proper/commons-jcs/LocalCacheConfig.html 
    * 
    * @param cacheConfig
    */
   public void setCacheConfig(String cacheConfig) {
      this.cacheConfig = cacheConfig;
   }

   public String getClasspathCacheConfig() {
      return classpathCacheConfig;
   }

   /**
    * Set the cache configuration file to a classpath file
    * 
    * @param classpathCacheConfig
    */
   public void setClasspathCacheConfig(String classpathCacheConfig) {
      this.classpathCacheConfig = classpathCacheConfig;
   }

   public boolean isCorrectResponseNamespace() {
      return correctResponseNamespace;
   }
   
   public void setCorrectResponseNamespace(boolean correct) {
      this.correctResponseNamespace = correct;
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

    private Properties loadPropertiesFromClasspath(String classpathFile) throws IOException {
       InputStream is = getClass().getResourceAsStream(classpathFile);
       return loadProperties(is);
    }
    
    private Properties loadPropertiesFromFS(String fsFile) throws IOException {
       InputStream is = new FileInputStream(new File(fsFile));
       return loadProperties(is);
    }
    
    private Properties loadProperties(InputStream in) throws IOException {
      Properties cacheProps = new Properties();
      try {
         cacheProps.load(in);

      } catch (IOException e) {
         printDebugMessage("getClient",
            String.format("Error loading Cache config from: [%s], message: [%s]", in.toString(), e.getMessage()), 0);
      } finally {
         if (in != null) {
            in.close();
         }
      }
      return cacheProps;
    }
    
   /**
    * Get HttpClient
    * @return
    */
   protected Client getClient() {
      if (client == null) {
         client = ClientBuilder.newClient();
         client.register(new GZIPInInterceptor());
         client.register(new GZIPOutInterceptor());

         if (enableCache) {
            CacheManager cm = null;
            
            try {
               // In tomcat the default JCS URI is leading to a classloader exception.
               // Point the CacheManager to tmp dir to avoid exception in tomcat runtime
               File mockJCSDir = new File(System.getProperty("java.io.tmpdir"), "mock_jcs");
               mockJCSDir.mkdirs();
               URI tmpDirURI = mockJCSDir.toURI();
               if (!StringUtils.isBlank(cacheConfig)) {
                  cm = Caching.getCachingProvider().getCacheManager(tmpDirURI, null, loadPropertiesFromFS(cacheConfig));
               } else {
                  String classpathCfg = !StringUtils.isBlank(classpathCacheConfig)? classpathCacheConfig : DEFAULT_CACHE_CONFIG;
                  cm = Caching.getCachingProvider().getCacheManager(tmpDirURI, null, loadPropertiesFromClasspath(classpathCfg));
               }
            } catch (IOException e) {
               printDebugMessage("getClient", "Error opening cache configuration file: "+e.getMessage(), 0);
               cm = Caching.getCachingProvider().getCacheManager();
            }
            
            MutableConfiguration<Key, Entry> ccfg = new MutableConfiguration<Key, Entry>()
                  .setStoreByValue(false)
                  .setExpiryPolicyFactory(AccessedExpiryPolicy.factoryOf(Duration.ONE_DAY))
                  .setStatisticsEnabled(true);
            CacheControlClientRequestFilter cacheFilter = new CacheControlClientRequestFilter();
            Cache<Key, Entry> oneDayCache = cm.getCache(CACHE_NAME);
            if (oneDayCache == null) {
               oneDayCache = cm.createCache(CACHE_NAME, ccfg);
            }
            cacheFilter.setCache(oneDayCache);
            client.register(cacheFilter);
            
            CacheControlClientReaderInterceptor cacheInterceptor = new CacheControlClientReaderInterceptor();
            cacheInterceptor.setCache(oneDayCache);
            client.register(cacheInterceptor);
         }
         if (correctResponseNamespace) {
            client.register(getNamespaceAdditionFeature());
         }
      }
      
      return client;
   }

   /**
    * Fix backend problem where WsResult namespace is not provided, add the namespace receiving the message
    * NOTE: this HAS TO BE a temporary workaround while we correct the backend
    * 
    * @return
    */
   private StaxTransformFeature getNamespaceAdditionFeature() {
      StaxTransformFeature f = new StaxTransformFeature();
      Map<String, String> transElementsMap = new HashMap<String, String>();
      transElementsMap.put("*", "{http://www.ebi.ac.uk/ebisearch/schemas/EBISearchRestWS}*");
      f.setInTransformElements(transElementsMap);
      return f;
   }

   public void close() {
      client.getConfiguration().getInstances().forEach(obj -> {
         if (obj instanceof Closeable) {
            try {
               ((Closeable)obj).close();
            } catch (Exception e) {}
         }
      });
      client.close();
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
        WebTarget t = getTarget().path(domain);
        printDebugMessage("getDomainDetails", getURLString(t), 2);
        Invocation.Builder builder = t.request();
        WsResult result = builder.get(WsResult.class);

        printDebugMessage("getDomainDetails", "End", 1);
        return result;
    }

    /** Get number of search results.
     * 
     * @return
     */
    public WsResult getNumberOfResults(String domain, String query) {
        printDebugMessage("getNumberOfResults", "Begin", 1);

        Invocation.Builder builder = getTarget().path(domain).queryParam("query", query).queryParam("size", "0").request();
        WsResult result = builder.get(WsResult.class);

        printDebugMessage("getNumberOfResults", "End", 1);
        return result;
    }

    /** Get search results.
     * 
     * @return
     */
    public WsResult getResults(String domain, String query, String fields, int start, int size, boolean fieldurl, boolean viewurl, String sortField, String order, String sort) {
        printDebugMessage("getResults", "Begin", 1);

        Invocation.Builder builder = getTarget().path(domain)
                .queryParam("query", query)
                .queryParam("fields", fields)
                .queryParam("start", start)
                .queryParam("size", size)
                .queryParam("fieldurl", fieldurl)
                .queryParam("viewurl", viewurl)
                .queryParam("sortfield", sortField)
                .queryParam("order", order)
                .queryParam("sort", sort).request();

        WsResult result = builder.get(WsResult.class);

        printDebugMessage("getResults", "End", 1);
        return result;
    }

    /** Get faceted search results.
     * 
     * @return
     */
    public WsResult getFacetedResults(String domain, String query, String fields, int start, int size, boolean fieldurl, boolean viewurl, String sortField,
                                      String order, String sort, int facetCount, String facetfields, String facets, int facetsdepth) {
        printDebugMessage("getFacetedResults", "Begin", 1);

        Invocation.Builder builder = getTarget().path(domain)
                .queryParam("query", query)
                .queryParam("fields", fields)
                .queryParam("start", start)
                .queryParam("size", size)
                .queryParam("fieldurl", fieldurl)
                .queryParam("viewurl", viewurl)
                .queryParam("sortfield", sortField)
                .queryParam("order", order)
                .queryParam("sort", sort)
                .queryParam("facetcount", facetCount)
                .queryParam("facetfields", facetfields)
                .queryParam("facets", facets)
                .queryParam("facetsdepth", facetsdepth).request();

        WsResult result = builder.get(WsResult.class);

        printDebugMessage("getFacetedResults", "End", 1);
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
                                         boolean viewurl, int facetCount, String facetfields, String facets) {
        printDebugMessage("getReferencedEntries", "Begin", 1);
        
        String path = domain + "/entry/" + entries + "/xref/" + referencedDomain;
        
        WebTarget t =  getTarget().path(path)
                .queryParam("fields", fields)
                .queryParam("start", start)
                .queryParam("size", size)
                .queryParam("fieldurl", fieldurl)
                .queryParam("viewurl", viewurl)
                .queryParam("facetcount", facetCount)
                .queryParam("facetfields", facetfields)
                .queryParam("facets", facets);
        
        printDebugMessage("getReferencedEntries", getURLString(t), 2);
        Invocation.Builder builder = t.request();
        WsResult result = builder.get(WsResult.class);

        printDebugMessage("getReferencedEntries", "End", 1);
        return result;
    }

    /**
     * Get entries like a given document
     * @param domain
     * @param entryid
     * @param fields
     * @param start
     * @param size
     * @param fieldurl
     * @param viewurl
     * @param mltfields
     * @param mintermfreq
     * @param mindocfreq
     * @param maxqueryterm
     * @param excludes
     * @param excludesets
     * @return
     */
    private WsResult getMoreLikeThis(String domain, String entryid, String targetDomain, String fields, int start, int size, boolean fieldurl, boolean viewurl, String mltfields,
                                     int mintermfreq, int mindocfreq, int maxqueryterm, String excludes, String excludesets) {
        printDebugMessage("getMoreLikeThis", "Begin", 1);

        String path = domain + "/entry/" + entryid + "/morelikethis/" + targetDomain;

        WebTarget t = getTarget().path(path).queryParam("fields", fields).queryParam("start", start).queryParam("size", size).queryParam("fieldurl", fieldurl).queryParam("viewurl",
                                                                                                                                                                          viewurl).queryParam("mltfields",
                                                                                                                                                                                              mltfields).queryParam("mintermfreq",
                                                                                                                                                                                                                    mintermfreq).queryParam("mindocfreq",
                                                                                                                                                                                                                                            mindocfreq).queryParam("maxqueryterm",
                                                                                                                                                                                                                                                                   maxqueryterm).queryParam("excludes",
                                                                                                                                                                                                                                                                                            excludes).queryParam("excludesets",
                                                                                                                                                                                                                                                                                                                 excludesets);

        printDebugMessage("getMoreLikeThis", getURLString(t), 2);
        Invocation.Builder builder = t.request();
        WsResult result = builder.get(WsResult.class);

        printDebugMessage("getMoreLikeThis", "End", 1);
        return result;
    }
    
    /**
     * Get suggestions of a given term
     * @param domain
     * @param term
     * @return
     */
    private WsResult getAutoComplete(String domain, String term) {
        printDebugMessage("getAutoComplete", "Begin", 1);

        String path = domain + "/autocomplete";

        WebTarget t = getTarget().path(path).queryParam("term", term);

        printDebugMessage("getAutoComplete", getURLString(t), 2);

        Invocation.Builder builder = t.request();
        WsResult result = builder.get(WsResult.class);

        printDebugMessage("getAutoComplete", "End", 1);
        return result;
    }

    /**
     * Get top terms
     * 
     * @param domain
     * @param field
     * @param size
     * @param excludes
     * @param excludesets
     * @return
     */
    public WsResult getTopTerms(String domain, String field, int size, String excludes, String excludesets) {
        printDebugMessage("getTopTerms", "Begin", 1);

        String path = domain + "/topterms/" + field;
        WebTarget t = getTarget().path(path).queryParam("size", size).queryParam("excludes", excludes).queryParam("excludesets", excludesets);
        printDebugMessage("getTopTerms", getURLString(t), 2);
        Invocation.Builder builder = t.request();
        WsResult result = builder.get(WsResult.class);

        printDebugMessage("getTopTerms", "End", 1);
        return result;
    }

    private String getURLString(WebTarget t) {
        if (t.getUri().getQuery() == null || t.getUri().getQuery().isEmpty()) {
            return t.getUri().getPath();
        }
        return t.getUri().getPath() + "?" + t.getUri().getQuery();
    }

    /**
     * Print domain tree.
     */
    public void printGetDomainsHierarchy() {
        printDebugMessage("printGetDomainsHierarchy", "Begin", 1);

        WsResult result = getDomainsHierarchy();
        Domains domains = result.getDomains();
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
        Domains domains = result.getDomains();
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
     * Print number of search results.
     */
    public void printGetNumberOfResults(String domain, String query) {
        printDebugMessage("printGetNumberOfResults", "Begin", 1);

        WsResult result = getNumberOfResults(domain, query);
        System.out.println(result.getHitCount());
        printDebugMessage("printGetNumberOfResults", "End", 1);
    }

    /**
     * Print search results.
     */
    public void printGetResults(String domain, String query, String fields, int start, int size, boolean fieldurl, boolean viewurl, String sortField,
                                String order, String sort) {
        printDebugMessage("printGetResults", "Begin", 1);

        WsResult result = getResults(domain, query, fields, start, size, fieldurl, viewurl, sortField, order, sort);
        Entries entries = result.getEntries();
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
                                       String order, String sort, int facetCount, String facetfields, String selectedfacets, int facetsdepth) {
        printDebugMessage("printGetFacetedResults", "Begin", 1);

        WsResult result = getFacetedResults(domain, query, fields, start, size, fieldurl, viewurl, sortField, order, sort, facetCount, facetfields, selectedfacets, facetsdepth);
        Entries entries = result.getEntries();
        if (entries != null) {
            for (WsEntry entry : entries.getEntry()) {
                print(entry);
            }
        }

        System.out.println();

        Facets facets = result.getFacets();
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
            print(value, 0);
        }
        System.out.println();
    }

    private void print (WsFacetValue value, int depth) {
        
        for (int i=0; i< depth ; i++) {
            System.out.print("\t");
        }

        System.out.println(value.getLabel() + " (" + value.getValue() + ") " + value.getCount());
        
        if (value.getChildren() != null && !value.getChildren().getFacetValue().isEmpty()) {
            for ( int i =0; i < value.getChildren().getFacetValue().size(); i ++ ) {
                print (value.getChildren().getFacetValue().get(i), depth+1);
            }
        }
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
        Entries entries = result.getEntries();
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
        Domains domains = result.getDomains();
        if (domains != null) {
            printIds(domains);
        }

        printDebugMessage("printGetDomainsReferencedInDomain", "End", 1);
    }

    private void printIds(Domains domains) {
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
        Domains domains = result.getDomains();
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
                                          boolean viewurl, int facetCount, String facetfields, String selectedfacets) {
        printDebugMessage("printGetReferencedEntries", "Begin", 1);

        WsResult result = getReferencedEntries(domain, entryIds, referencedDomain, fields, start, size, fieldurl, viewurl, facetCount, facetfields, selectedfacets);
        Entries entries = result.getEntries();
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
        
        if (entry.getReferenceFacets() != null) {
            for (WsFacet facet : entry.getReferenceFacets().getReferenceFacet()) {
                print(facet);
            }
        }
    }

    /**
     * Print found similar documents in a same domain
     * @param domain
     * @param entryid
     * @param fields
     * @param start
     * @param size
     * @param fieldurl
     * @param viewurl
     * @param mltfields
     * @param mintermfreq
     * @param mindocfreq
     * @param maxqueryterm
     * @param excludes
     * @param excludesets
     */
    public void printGetMoreLikeThis(String domain, String entryid, String fields, int start, int size, boolean fieldurl, boolean viewurl, String mltfields,
                                     int mintermfreq, int mindocfreq, int maxqueryterm, String excludes, String excludesets) {
        printDebugMessage("printGetMoreLikeThis", "Begin", 1);

        WsResult result = getMoreLikeThis(domain,
                                          entryid,
                                          domain,
                                          fields,
                                          start,
                                          size,
                                          fieldurl,
                                          viewurl,
                                          mltfields,
                                          mintermfreq,
                                          mindocfreq,
                                          maxqueryterm,
                                          excludes,
                                          excludesets);

        Entries entries = result.getEntries();
        if (entries != null) {
            for (WsEntry entry : entries.getEntry()) {
                print(entry);
            }
        }

        printDebugMessage("printGetMoreLikeThis", "End", 1);
    }
    
    /**
     * Print found similar documents in a specific domain
     * @param domain
     * @param entryid
     * @param fields
     * @param start
     * @param size
     * @param fieldurl
     * @param viewurl
     * @param mltfields
     * @param mintermfreq
     * @param mindocfreq
     * @param maxqueryterm
     * @param excludes
     * @param excludesets
     */
    public void printGetMoreLikeThis(String domain, String entryid, String targetDomain, String fields, int start, int size, boolean fieldurl, boolean viewurl, String mltfields,
                                     int mintermfreq, int mindocfreq, int maxqueryterm, String excludes, String excludesets) {
        printDebugMessage("printGetMoreLikeThis", "Begin", 1);

        WsResult result = getMoreLikeThis(domain,
                                          entryid,
                                          targetDomain,
                                          fields,
                                          start,
                                          size,
                                          fieldurl,
                                          viewurl,
                                          mltfields,
                                          mintermfreq,
                                          mindocfreq,
                                          maxqueryterm,
                                          excludes,
                                          excludesets);

        Entries entries = result.getEntries();
        if (entries != null) {
            for (WsEntry entry : entries.getEntry()) {
                print(entry);
            }
        }

        printDebugMessage("printGetMoreLikeThis", "End", 1);
    }
    
    /**
     * Print found suggested terms
     * @param domain
     * @param term
     */
    public void printGetAutoComplete(String domain, String term) {
        printDebugMessage("printGetAutoComplete", "Begin", 1);

        WsResult result = getAutoComplete(domain, term);

        Suggestions suggestions = result.getSuggestions();
        if (suggestions != null) {
            for (WsSuggestion suggestion : suggestions.getSuggestion()) {
                System.out.println(suggestion.getSuggest());
            }
        }

        printDebugMessage("printGetAutoComplete", "End", 1);
    }

    /**
     * @param domain
     * @param field
     * @param size
     * @param excludes
     * @param excludesets
     */
    public void printGetTopTerms(String domain, String field, int size, String excludes, String excludesets) {
        printDebugMessage("printGetTopTerms", "Begin", 1);

        WsResult result = getTopTerms(domain, field, size, excludes, excludesets);
        TopTerms topTerms = result.getTopTerms();
        if (topTerms != null && topTerms.getTerm() != null) {
            for (WsTermStats term : topTerms.getTerm()) {
                System.out.println(term.getText() + ": " + term.getDocFreq());
            }
        }
        printDebugMessage("printGetTopTerms", "End", 1);
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

        // --getNumberOfResults  <domain> <query> 
        options.addOption("getNumberOfResults", true, "Get number of search results");
        options.getOption("getNumberOfResults").setArgs(2);

        // --getResults  <domain> <query> <fields> [OPTIONS: --size | --start | --fieldurl | --viewurl | --sortfield | --order] 
        options.addOption("getResults", true, "Get entries which match query");
        options.getOption("getResults").setArgs(3);

        // --getFacetedResults <domain> <query> <fields> [OPTIONS: --size | --start | --fieldurl | --viewurl | --sortfield | --order | --facetcount | --facetfields | --facets]
        options.addOption("getFacetedResults", true, "Get entries which match query with facets");
        options.getOption("getFacetedResults").setArgs(3);

        // --getEntries <domain> <entryids> <fields> [OPTIONS: --fieldurl | --viewurl]
        options.addOption("getEntries", true, "Get data from a specific set of entries");
        options.getOption("getEntries").setArgs(3);

        // --getDomainsReferencedInDomain <domain>
        options.addOption("getDomainsReferencedInDomain", true, "Domains cross-referenced by domain");

        // --getDomainsReferencedInEntry <domain> <entry>
        options.addOption("getDomainsReferencedInEntry", true, "Domains cross-referenced by entry");
        options.getOption("getDomainsReferencedInEntry").setArgs(2);

        // --getReferencedEntries <domain> <entryids> <referencedDomain> <fields> [OPTIONS: --size | --start | --fieldurl | --viewurl]
        options.addOption("getReferencedEntries", true, "Entries referenced by an entry");
        options.getOption("getReferencedEntries").setArgs(4);

        // --getTopTerms <domain> <field> [OPTIONS: --size | --excludes | --excludesets]
        options.addOption("getTopTerms", true, "Top Terms in a field");
        options.getOption("getTopTerms").setArgs(2);

        // --getMoreLikeThis <domain> <entryid> <fields> [OPTIONS: --size | --start | --fieldurl | --viewurl | --mltfields | --mintermfreq | --mindocfreq | --maxqueryterm | --excludes | --excludesets]
        options.addOption("getMoreLikeThis", true, "Similar documents similar to a given entry");
        options.getOption("getMoreLikeThis").setArgs(3);

        // --getExtendedMoreLikeThis <domain> <entryid> <targetDomain> <fields> [OPTIONS: --size | --start | --fieldurl | --viewurl | --mltfields | --mintermfreq | --mindocfreq | --maxqueryterm | --excludes | --excludesets]
        options.addOption("getExtendedMoreLikeThis", true, "Similar documents similar to a given entry");
        options.getOption("getExtendedMoreLikeThis").setArgs(4);
        
        // --getAutoComplete <domain> <term>
        options.addOption("getAutoComplete", true, "Get suggstions of a given term");
        options.getOption("getAutoComplete").setArgs(2);
        
        // Optional arguments 
        options.addOption("size", true, "number of entries to retrieve");
        options.addOption("start", true, "index of the first entry in results");
        options.addOption("fieldurl", true, "whether field links are included");
        options.addOption("viewurl", true, "whether view links are included");
        options.addOption("sortfield", true, "field id to sort");
        options.addOption("order", true, "sort in ascending/descending order");
        options.addOption("sort", true, "comma separated value of sorting criteria");
        options.addOption("facets", true, "comma separated value of selected facet values");
        options.addOption("facetsdepth", true, "depth in hierarchical facet");
        options.addOption("facetcount", true, "number of facet values to retrieve");
        options.addOption("facetfields", true, "field ids associated with facets to retrieve");
        options.addOption("mltfields", true, "field ids  to be used for generating a morelikethis query");
        options.addOption("mintermfreq", true, "frequency below which terms will be ignored in the base document");
        options.addOption("mindocfreq", true, "frequency at which words will be ignored which do not occur in at least this many documents");
        options.addOption("maxqueryterm", true, "maximum number of query terms that will be included in any generated query");
        options.addOption("excludes", true, "terms to be excluded");
        options.addOption("excludesets", true, "stop word sets to be excluded");
        
        options.addOption("nocache", false, "Disable cache");
        options.addOption("cacheConfig", true, "Override cache configuration");
        options.addOption("noResponseNamespaceCorrection", false, "Disable XML response namespace correction");
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
            
            // Cache configuration
            if (cli.hasOption("nocache")) {
               ebeye.enableCache = false;
            }
            
            if (cli.hasOption("cache-config")) {
               ebeye.cacheConfig = cli.getOptionValue("cache-config");
            }

            if (cli.hasOption("noResponseNamespaceCorrection")) {
               ebeye.correctResponseNamespace = false;
            }

            // --listDomains
            if (cli.hasOption("getDomainsHierarchy")) {
                ebeye.printGetDomainsHierarchy();
            }
            // --getDomainDetails
            else if (cli.hasOption("getDomainDetails")) {
                ebeye.printGetDomainDetails(cli.getOptionValue("getDomainDetails"));
            }
            // --getNumberOfResults <domain> <query> 
            else if (cli.hasOption("getNumberOfResults")) {
                String[] vals = cli.getOptionValues("getNumberOfResults");
                ebeye.printGetNumberOfResults(vals[0], vals[1]);
            }
            // --getResults <domain> <query> <fields> [OPTIONS: --size | --start | --fieldurl | --viewurl | --sortfield | --order | --sort ] 
            else if (cli.hasOption("getResults")) {
                String[] vals = cli.getOptionValues("getResults");
                String start = cli.hasOption("start") ? cli.getOptionValue("start") : "0";
                String size = cli.hasOption("size") ? cli.getOptionValue("size") : "15";
                String fieldurl = cli.hasOption("fieldurl") ? cli.getOptionValue("fieldurl") : "false";
                String viewurl = cli.hasOption("viewurl") ? cli.getOptionValue("viewurl") : "false";
                String sortfield = cli.hasOption("sortfield") ? cli.getOptionValue("sortfield") : "";
                String order = cli.hasOption("order") ? cli.getOptionValue("order") : "";
                String sort = cli.hasOption("sort") ? cli.getOptionValue("sort") : "";
                
                ebeye.printGetResults(vals[0],
                                      vals[1],
                                      vals[2],
                                      Integer.parseInt(start),
                                      Integer.parseInt(size),
                                      Boolean.parseBoolean(fieldurl),
                                      Boolean.parseBoolean(viewurl),
                                      sortfield,
                                      order,
                                      sort);
            }
            // --getFacetedResults <domain> <query> <fields> [OPTIONS: --size | --start | --fieldurl | --viewurl | --sortfield | --order | --facetcount | --facetfields | --facets]
            else if (cli.hasOption("getFacetedResults")) {
                String[] vals = cli.getOptionValues("getFacetedResults");
                String start = cli.hasOption("start") ? cli.getOptionValue("start") : "0";
                String size = cli.hasOption("size") ? cli.getOptionValue("size") : "15";
                String fieldurl = cli.hasOption("fieldurl") ? cli.getOptionValue("fieldurl") : "false";
                String viewurl = cli.hasOption("viewurl") ? cli.getOptionValue("viewurl") : "false";
                String sortfield = cli.hasOption("sortfield") ? cli.getOptionValue("sortfield") : "";
                String order = cli.hasOption("order") ? cli.getOptionValue("order") : "";
                String sort = cli.hasOption("sort") ? cli.getOptionValue("sort") : "";
                String facetcount = cli.hasOption("facetcount") ? cli.getOptionValue("facetcount") : "10";
                String facetfield = cli.hasOption("facetfield") ? cli.getOptionValue("facetfield") : "";
                String facets = cli.hasOption("facets") ? cli.getOptionValue("facets") : "";
                String facetsdepth = cli.hasOption("facetsdepth") ? cli.getOptionValue("facetsdepth") : "";

                ebeye.printGetFacetedResults(vals[0],
                                             vals[1],
                                             vals[2],
                                             Integer.parseInt(start),
                                             Integer.parseInt(size),
                                             Boolean.parseBoolean(fieldurl),
                                             Boolean.parseBoolean(viewurl),
                                             sortfield,
                                             order,
                                             sort,
                                             Integer.parseInt(facetcount),
                                             facetfield,
                                             facets,
                                             Integer.parseInt(facetsdepth));
            }
            // --getEntries  <domain> <entryids> <fields> [OPTIONS: --fieldurl | --viewurl]
            else if (cli.hasOption("getEntries")) {
                String[] vals = cli.getOptionValues("getEntries");
                String fieldurl = cli.hasOption("fieldurl") ? cli.getOptionValue("fieldurl") : "";
                String viewurl = cli.hasOption("viewurl") ? cli.getOptionValue("viewurl") : "";
                ebeye.printGetEntries(vals[0], vals[1], vals[2], Boolean.parseBoolean(fieldurl), Boolean.parseBoolean(viewurl));
            }
            // --getDomainsReferencedInDomain <domain>
            else if (cli.hasOption("getDomainsReferencedInDomain")) {
                ebeye.printGetDomainsReferencedInDomain(cli.getOptionValue("getDomainsReferencedInDomain"));
            }
            // --getDomainsReferencedInEntry <domain> <entry>
            else if (cli.hasOption("getDomainsReferencedInEntry")) {
                String[] vals = cli.getOptionValues("getDomainsReferencedInEntry");
                ebeye.printGetDomainsReferencedInEntry(vals[0], vals[1]);
            }
            // --getReferencedEntries <domain> <entryids> <referencedDomain> <fields> [OPTIONS: --size | --start | --fieldurl | --viewurl | --facetcount | --facetfields | --facets ]
            else if (cli.hasOption("getReferencedEntries")) {
                String[] vals = cli.getOptionValues("getReferencedEntries");
                String start = cli.hasOption("start") ? cli.getOptionValue("start") : "0";
                String size = cli.hasOption("size") ? cli.getOptionValue("size") : "15";
                String fieldurl = cli.hasOption("fieldurl") ? cli.getOptionValue("fieldurl") : "false";
                String viewurl = cli.hasOption("viewurl") ? cli.getOptionValue("viewurl") : "false";
                String facetcount = cli.hasOption("facetcount") ? cli.getOptionValue("facetcount") : "10";
                String facetfield = cli.hasOption("facetfield") ? cli.getOptionValue("facetfield") : "";
                String facets = cli.hasOption("facets") ? cli.getOptionValue("facets") : "";

                ebeye.printGetReferencedEntries(vals[0],
                                                vals[1],
                                                vals[2],
                                                vals[3],
                                                Integer.parseInt(start),
                                                Integer.parseInt(size),
                                                Boolean.parseBoolean(fieldurl),
                                                Boolean.parseBoolean(viewurl),
                                                Integer.parseInt(facetcount),
                                                 facetfield,
                                                 facets);
            }
            // --getTopTerms <domain> <field> [OPTIONS: --size | --excludes | --excludesets]
            else if (cli.hasOption("getTopTerms")) {
                String[] vals = cli.getOptionValues("getTopTerms");
                String size = cli.hasOption("size") ? cli.getOptionValue("size") : "15";
                String excludes = cli.hasOption("excludes") ? cli.getOptionValue("excludes") : "";
                String excludesets = cli.hasOption("excludesets") ? cli.getOptionValue("excludesets") : "";
                ebeye.printGetTopTerms(vals[0], vals[1], Integer.parseInt(size), excludes, excludesets);
            }
            // --getMoreLikeThis <domain> <entryid> <fields> [OPTIONS: --size | --start | --fieldurl | --viewurl | --mltfields | --mintermfreq | --mindocfreq | --maxqueryterm | --excludes | --excludesets]
            else if (cli.hasOption("getMoreLikeThis")) {
                String[] vals = cli.getOptionValues("getMoreLikeThis");
                String size = cli.hasOption("size") ? cli.getOptionValue("size") : "15";
                String start = cli.hasOption("start") ? cli.getOptionValue("start") : "0";
                String fieldurl = cli.hasOption("fieldurl") ? cli.getOptionValue("fieldurl") : "false";
                String viewurl = cli.hasOption("viewurl") ? cli.getOptionValue("viewurl") : "false";
                String mltfields = cli.hasOption("mltfields") ? cli.getOptionValue("mltfields") : "";
                String mintermfreq = cli.hasOption("mintermfreq") ? cli.getOptionValue("mintermfreq") : "1";
                String mindocfreq = cli.hasOption("mindocfreq") ? cli.getOptionValue("mindocfreq") : "5";
                String maxqueryterm = cli.hasOption("maxqueryterm") ? cli.getOptionValue("maxqueryterm") : "10";
                String excludes = cli.hasOption("excludes") ? cli.getOptionValue("excludes") : "";
                String excludesets = cli.hasOption("excludesets") ? cli.getOptionValue("excludesets") : "";
                  ebeye.printGetMoreLikeThis(vals[0],
                                           vals[1],
                                           vals[2],
                                           Integer.parseInt(start),
                                           Integer.parseInt(size),
                                           Boolean.parseBoolean(fieldurl),
                                           Boolean.parseBoolean(viewurl),
                                           mltfields,
                                           Integer.parseInt(mintermfreq),
                                           Integer.parseInt(mindocfreq),
                                           Integer.parseInt(maxqueryterm),
                                           excludes,
                                           excludesets);
            }
            // --getExtendedMoreLikeThis <domain> <entryid> <targetDomain> <fields> [OPTIONS: --size | --start | --fieldurl | --viewurl | --mltfields | --mintermfreq | --mindocfreq | --maxqueryterm | --excludes | --excludesets]
            else if (cli.hasOption("getExtendedMoreLikeThis")) {
                String[] vals = cli.getOptionValues("getExtendedMoreLikeThis");
                String size = cli.hasOption("size") ? cli.getOptionValue("size") : "15";
                String start = cli.hasOption("start") ? cli.getOptionValue("start") : "0";
                String fieldurl = cli.hasOption("fieldurl") ? cli.getOptionValue("fieldurl") : "false";
                String viewurl = cli.hasOption("viewurl") ? cli.getOptionValue("viewurl") : "false";
                String mltfields = cli.hasOption("mltfields") ? cli.getOptionValue("mltfields") : "";
                String mintermfreq = cli.hasOption("mintermfreq") ? cli.getOptionValue("mintermfreq") : "1";
                String mindocfreq = cli.hasOption("mindocfreq") ? cli.getOptionValue("mindocfreq") : "5";
                String maxqueryterm = cli.hasOption("maxqueryterm") ? cli.getOptionValue("maxqueryterm") : "10";
                String excludes = cli.hasOption("excludes") ? cli.getOptionValue("excludes") : "";
                String excludesets = cli.hasOption("excludesets") ? cli.getOptionValue("excludesets") : "";

                ebeye.printGetMoreLikeThis(vals[0],
                                           vals[1],
                                           vals[2],
                                           vals[3],
                                           Integer.parseInt(start),
                                           Integer.parseInt(size),
                                           Boolean.parseBoolean(fieldurl),
                                           Boolean.parseBoolean(viewurl),
                                           mltfields,
                                           Integer.parseInt(mintermfreq),
                                           Integer.parseInt(mindocfreq),
                                           Integer.parseInt(maxqueryterm),
                                           excludes,
                                           excludesets);
        
            }
            
            // --getAutoComplete <domain> <term>
            else if (cli.hasOption("getAutoComplete")) {
                String[] vals = cli.getOptionValues("getAutoComplete");
                ebeye.printGetAutoComplete(vals[0], vals[1]);
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
        } finally {
           ebeye.close();
        }
        System.exit(exitVal);
    }
}
