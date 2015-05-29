
package uk.ac.ebi.webservices.jaxrs.stubs.ebeye;

import javax.xml.bind.JAXBElement;
import javax.xml.bind.annotation.XmlElementDecl;
import javax.xml.bind.annotation.XmlRegistry;
import javax.xml.namespace.QName;


/**
 * This object contains factory methods for each 
 * Java content interface and Java element interface 
 * generated in the uk.ac.ebi.webservices.jaxrs.stubs.ebeye package. 
 * <p>An ObjectFactory allows you to programatically 
 * construct new instances of the Java representation 
 * for XML content. The Java representation of XML 
 * content can consist of schema derived interfaces 
 * and classes representing the binding of schema 
 * type definitions, element declarations and model 
 * groups.  Factory methods for each of these are 
 * provided in this class.
 * 
 */
@XmlRegistry
public class ObjectFactory {

    private final static QName _Result_QNAME = new QName("http://www.ebi.ac.uk/ebisearch/schemas/EBISearchRestWS", "result");

    /**
     * Create a new ObjectFactory that can be used to create new instances of schema derived classes for package: uk.ac.ebi.webservices.jaxrs.stubs.ebeye
     * 
     */
    public ObjectFactory() {
    }

    /**
     * Create an instance of {@link WsFieldInfo }
     * 
     */
    public WsFieldInfo createWsFieldInfo() {
        return new WsFieldInfo();
    }

    /**
     * Create an instance of {@link WsDomain }
     * 
     */
    public WsDomain createWsDomain() {
        return new WsDomain();
    }

    /**
     * Create an instance of {@link WsFacet }
     * 
     */
    public WsFacet createWsFacet() {
        return new WsFacet();
    }

    /**
     * Create an instance of {@link WsField }
     * 
     */
    public WsField createWsField() {
        return new WsField();
    }

    /**
     * Create an instance of {@link WsEntry }
     * 
     */
    public WsEntry createWsEntry() {
        return new WsEntry();
    }

    /**
     * Create an instance of {@link WsResult }
     * 
     */
    public WsResult createWsResult() {
        return new WsResult();
    }

    /**
     * Create an instance of {@link Wsurl }
     * 
     */
    public Wsurl createWsurl() {
        return new Wsurl();
    }

    /**
     * Create an instance of {@link WsFacetValue }
     * 
     */
    public WsFacetValue createWsFacetValue() {
        return new WsFacetValue();
    }

    /**
     * Create an instance of {@link WsIndexInfo }
     * 
     */
    public WsIndexInfo createWsIndexInfo() {
        return new WsIndexInfo();
    }

    /**
     * Create an instance of {@link WsOption }
     * 
     */
    public WsOption createWsOption() {
        return new WsOption();
    }

    /**
     * Create an instance of {@link WsDiagnostics }
     * 
     */
    public WsDiagnostics createWsDiagnostics() {
        return new WsDiagnostics();
    }

    /**
     * Create an instance of {@link WsSuggestion }
     * 
     */
    public WsSuggestion createWsSuggestion() {
        return new WsSuggestion();
    }

    /**
	 * Create an instance of {@link WsOptions }
	 * 
	 */
	public WsOptions createWsFieldInfoOptions() {
		return new WsOptions();
    }

    /**
	 * Create an instance of {@link WsIndexInfos }
	 * 
	 */
	public WsIndexInfos createWsDomainIndexInfos() {
		return new WsIndexInfos();
    }

    /**
	 * Create an instance of {@link WsFieldInfos }
	 * 
	 */
	public WsFieldInfos createWsDomainFieldInfos() {
		return new WsFieldInfos();
    }

    /**
	 * Create an instance of {@link WsSubdomains }
	 * 
	 */
	public WsSubdomains createWsDomainSubdomains() {
		return new WsSubdomains();
    }

    /**
	 * Create an instance of {@link WsFacetValues }
	 * 
	 */
	public WsFacetValues createWsFacetFacetValues() {
		return new WsFacetValues();
    }

    /**
	 * Create an instance of {@link WsValues }
	 * 
	 */
	public WsValues createWsFieldValues() {
		return new WsValues();
    }

    /**
	 * Create an instance of {@link WsFields }
	 * 
	 */
	public WsFields createWsEntryFields() {
		return new WsFields();
    }

    /**
	 * Create an instance of {@link WsFieldURLs }
	 * 
	 */
	public WsFieldURLs createWsEntryFieldURLs() {
		return new WsFieldURLs();
    }

    /**
	 * Create an instance of {@link WsViewURLs }
	 * 
	 */
	public WsViewURLs createWsEntryViewURLs() {
		return new WsViewURLs();
    }

    /**
	 * Create an instance of {@link WsReferences }
	 * 
	 */
	public WsReferences createWsEntryReferences() {
		return new WsReferences();
    }

    /**
	 * Create an instance of {@link WsEntries }
	 * 
	 */
	public WsEntries createWsResultEntries() {
		return new WsEntries();
    }

    /**
	 * Create an instance of {@link WsFacets }
	 * 
	 */
	public WsFacets createWsResultFacets() {
		return new WsFacets();
    }

    /**
	 * Create an instance of {@link WsDomains }
	 * 
	 */
	public WsDomains createWsResultDomains() {
		return new WsDomains();
    }

    /**
	 * Create an instance of {@link WsSuggestions }
	 * 
	 */
	public WsSuggestions createWsResultSuggestions() {
		return new WsSuggestions();
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link WsResult }{@code >}}
     * 
     */
	@XmlElementDecl(namespace = "", name = "result")
    public JAXBElement<WsResult> createResult(WsResult value) {
        return new JAXBElement<WsResult>(_Result_QNAME, WsResult.class, null, value);
    }

}
