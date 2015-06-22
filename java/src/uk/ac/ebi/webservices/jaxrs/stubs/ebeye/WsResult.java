package uk.ac.ebi.webservices.jaxrs.stubs.ebeye;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlType;

/**
 * <p>Java class for wsResult complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="wsResult"&gt;
 *   &lt;complexContent&gt;
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType"&gt;
 *       &lt;sequence&gt;
 *         &lt;element name="hitCount" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/&gt;
 *         &lt;element name="entries" minOccurs="0"&gt;
 *           &lt;complexType&gt;
 *             &lt;complexContent&gt;
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType"&gt;
 *                 &lt;sequence&gt;
 *                   &lt;element name="entry" type="{http://www.ebi.ac.uk/ebisearch/schemas/EBISearchRestWS}wsEntry" maxOccurs="unbounded" minOccurs="0"/&gt;
 *                 &lt;/sequence&gt;
 *               &lt;/restriction&gt;
 *             &lt;/complexContent&gt;
 *           &lt;/complexType&gt;
 *         &lt;/element&gt;
 *         &lt;element name="facets" minOccurs="0"&gt;
 *           &lt;complexType&gt;
 *             &lt;complexContent&gt;
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType"&gt;
 *                 &lt;sequence&gt;
 *                   &lt;element name="facet" type="{http://www.ebi.ac.uk/ebisearch/schemas/EBISearchRestWS}wsFacet" maxOccurs="unbounded" minOccurs="0"/&gt;
 *                 &lt;/sequence&gt;
 *               &lt;/restriction&gt;
 *             &lt;/complexContent&gt;
 *           &lt;/complexType&gt;
 *         &lt;/element&gt;
 *         &lt;element name="domains" minOccurs="0"&gt;
 *           &lt;complexType&gt;
 *             &lt;complexContent&gt;
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType"&gt;
 *                 &lt;sequence&gt;
 *                   &lt;element name="domain" type="{http://www.ebi.ac.uk/ebisearch/schemas/EBISearchRestWS}wsDomain" maxOccurs="unbounded" minOccurs="0"/&gt;
 *                 &lt;/sequence&gt;
 *               &lt;/restriction&gt;
 *             &lt;/complexContent&gt;
 *           &lt;/complexType&gt;
 *         &lt;/element&gt;
 *         &lt;element name="suggestions" minOccurs="0"&gt;
 *           &lt;complexType&gt;
 *             &lt;complexContent&gt;
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType"&gt;
 *                 &lt;sequence&gt;
 *                   &lt;element name="suggestion" type="{http://www.ebi.ac.uk/ebisearch/schemas/EBISearchRestWS}wsSuggestion" maxOccurs="unbounded" minOccurs="0"/&gt;
 *                 &lt;/sequence&gt;
 *               &lt;/restriction&gt;
 *             &lt;/complexContent&gt;
 *           &lt;/complexType&gt;
 *         &lt;/element&gt;
 *         &lt;element name="diagonostics" type="{http://www.ebi.ac.uk/ebisearch/schemas/EBISearchRestWS}wsDiagnostics" minOccurs="0"/&gt;
 *       &lt;/sequence&gt;
 *     &lt;/restriction&gt;
 *   &lt;/complexContent&gt;
 * &lt;/complexType&gt;
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "result", propOrder = { "hitCount", "entries", "facets", "domains", "suggestions", "diagonostics", "topTerms" })
public class WsResult {

	protected Integer       hitCount;
	protected WsEntries     entries;
	protected WsFacets      facets;
	protected WsDomains     domains;
	protected WsSuggestions suggestions;
	protected WsTopTerms    topTerms;
	protected WsDiagnostics diagonostics;

	/**
	 * Gets the value of the hitCount property.
	 * 
	 * @return
	 *     possible object is
	 *     {@link Integer }
	 *     
	 */
	public Integer getHitCount() {
		return hitCount;
	}

	/**
	 * Sets the value of the hitCount property.
	 * 
	 * @param value
	 *     allowed object is
	 *     {@link Integer }
	 *     
	 */
	public void setHitCount(Integer value) {
		this.hitCount = value;
	}

	/**
	 * Gets the value of the entries property.
	 * 
	 * @return
	 *     possible object is
	 *     {@link WsEntries }
	 *     
	 */
	public WsEntries getEntries() {
		return entries;
	}

	/**
	 * Sets the value of the entries property.
	 * 
	 * @param value
	 *     allowed object is
	 *     {@link WsEntries }
	 *     
	 */
	public void setEntries(WsEntries value) {
		this.entries = value;
	}

	/**
	 * Gets the value of the facets property.
	 * 
	 * @return
	 *     possible object is
	 *     {@link WsFacets }
	 *     
	 */
	public WsFacets getFacets() {
		return facets;
	}

	/**
	 * Sets the value of the facets property.
	 * 
	 * @param value
	 *     allowed object is
	 *     {@link WsFacets }
	 *     
	 */
	public void setFacets(WsFacets value) {
		this.facets = value;
	}

	/**
	 * Gets the value of the domains property.
	 * 
	 * @return
	 *     possible object is
	 *     {@link WsDomains }
	 *     
	 */
	public WsDomains getDomains() {
		return domains;
	}

	/**
	 * Sets the value of the domains property.
	 * 
	 * @param value
	 *     allowed object is
	 *     {@link WsDomains }
	 *     
	 */
	public void setDomains(WsDomains value) {
		this.domains = value;
	}

	/**
	 * Gets the value of the suggestions property.
	 * 
	 * @return
	 *     possible object is
	 *     {@link WsSuggestions }
	 *     
	 */
	public WsSuggestions getSuggestions() {
		return suggestions;
	}

	/**
	 * Sets the value of the suggestions property.
	 * 
	 * @param value
	 *     allowed object is
	 *     {@link WsSuggestions }
	 *     
	 */
	public void setSuggestions(WsSuggestions value) {
		this.suggestions = value;
	}

	/**
	 * Gets the value of the topTerms property.
	 * 
	 * @return
	 *     possible object is
	 *     {@link WsTopTerms }
	 *     
	 */
	public WsTopTerms getTopTerms() {
		return topTerms;
	}

	/**
	 * Sets the value of the topTerms property.
	 * 
	 * @param value
	 *     allowed object is
	 *     {@link WsTopTerms }
	 *     
	 */
	public void setTopTerms(WsTopTerms topTerms) {
		this.topTerms = topTerms;
	}

	/**
	 * Gets the value of the diagonostics property.
	 * 
	 * @return
	 *     possible object is
	 *     {@link WsDiagnostics }
	 *     
	 */
	public WsDiagnostics getDiagonostics() {
		return diagonostics;
	}

	/**
	 * Sets the value of the diagonostics property.
	 * 
	 * @param value
	 *     allowed object is
	 *     {@link WsDiagnostics }
	 *     
	 */
	public void setDiagonostics(WsDiagnostics value) {
		this.diagonostics = value;
	}

}
