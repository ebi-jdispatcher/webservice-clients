package uk.ac.ebi.webservices.jaxrs.stubs.ebeye;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlType;

/**
 * <p>Java class for wsFacet complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="wsFacet"&gt;
 *   &lt;complexContent&gt;
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType"&gt;
 *       &lt;sequence&gt;
 *         &lt;element name="facetValues" minOccurs="0"&gt;
 *           &lt;complexType&gt;
 *             &lt;complexContent&gt;
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType"&gt;
 *                 &lt;sequence&gt;
 *                   &lt;element name="facetValue" type="{http://www.ebi.ac.uk/ebisearch/schemas/EBISearchRestWS}wsFacetValue" maxOccurs="unbounded" minOccurs="0"/&gt;
 *                 &lt;/sequence&gt;
 *               &lt;/restriction&gt;
 *             &lt;/complexContent&gt;
 *           &lt;/complexType&gt;
 *         &lt;/element&gt;
 *       &lt;/sequence&gt;
 *       &lt;attribute name="id" use="required" type="{http://www.w3.org/2001/XMLSchema}string" /&gt;
 *       &lt;attribute name="label" use="required" type="{http://www.w3.org/2001/XMLSchema}string" /&gt;
 *     &lt;/restriction&gt;
 *   &lt;/complexContent&gt;
 * &lt;/complexType&gt;
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "wsFacet", propOrder = { "facetValues" })
public class WsFacet {

	protected WsFacetValues facetValues;
	@XmlAttribute(name = "id", required = true)
	protected String        id;
	@XmlAttribute(name = "label", required = true)
	protected String        label;

	/**
	* Gets the value of the facetValues property.
	* 
	* @return
	*     possible object is
	*     {@link WsFacetValues }
	*     
	*/
	public WsFacetValues getFacetValues() {
		return facetValues;
	}

	/**
	* Sets the value of the facetValues property.
	* 
	* @param value
	*     allowed object is
	*     {@link WsFacetValues }
	*     
	*/
	public void setFacetValues(WsFacetValues value) {
		this.facetValues = value;
	}

	/**
	 * Gets the value of the id property.
	 * 
	 * @return
	 *     possible object is
	 *     {@link String }
	 *     
	 */
	public String getId() {
		return id;
	}

	/**
	 * Sets the value of the id property.
	 * 
	 * @param value
	 *     allowed object is
	 *     {@link String }
	 *     
	 */
	public void setId(String value) {
		this.id = value;
	}

	/**
	 * Gets the value of the label property.
	 * 
	 * @return
	 *     possible object is
	 *     {@link String }
	 *     
	 */
	public String getLabel() {
		return label;
	}

	/**
	 * Sets the value of the label property.
	 * 
	 * @param value
	 *     allowed object is
	 *     {@link String }
	 *     
	 */
	public void setLabel(String value) {
		this.label = value;
	}

}
