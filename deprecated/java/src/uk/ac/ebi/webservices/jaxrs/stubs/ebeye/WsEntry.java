package uk.ac.ebi.webservices.jaxrs.stubs.ebeye;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlType;

/**
 * <p>Java class for wsEntry complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="wsEntry"&gt;
 *   &lt;complexContent&gt;
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType"&gt;
 *       &lt;sequence&gt;
 *         &lt;element name="fields" minOccurs="0"&gt;
 *           &lt;complexType&gt;
 *             &lt;complexContent&gt;
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType"&gt;
 *                 &lt;sequence&gt;
 *                   &lt;element name="field" type="{http://www.ebi.ac.uk/ebisearch/schemas/EBISearchRestWS}wsField" maxOccurs="unbounded" minOccurs="0"/&gt;
 *                 &lt;/sequence&gt;
 *               &lt;/restriction&gt;
 *             &lt;/complexContent&gt;
 *           &lt;/complexType&gt;
 *         &lt;/element&gt;
 *         &lt;element name="fieldURLs" minOccurs="0"&gt;
 *           &lt;complexType&gt;
 *             &lt;complexContent&gt;
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType"&gt;
 *                 &lt;sequence&gt;
 *                   &lt;element name="fieldURL" type="{http://www.ebi.ac.uk/ebisearch/schemas/EBISearchRestWS}wsurl" maxOccurs="unbounded" minOccurs="0"/&gt;
 *                 &lt;/sequence&gt;
 *               &lt;/restriction&gt;
 *             &lt;/complexContent&gt;
 *           &lt;/complexType&gt;
 *         &lt;/element&gt;
 *         &lt;element name="viewURLs" minOccurs="0"&gt;
 *           &lt;complexType&gt;
 *             &lt;complexContent&gt;
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType"&gt;
 *                 &lt;sequence&gt;
 *                   &lt;element name="viewURL" type="{http://www.ebi.ac.uk/ebisearch/schemas/EBISearchRestWS}wsurl" maxOccurs="unbounded" minOccurs="0"/&gt;
 *                 &lt;/sequence&gt;
 *               &lt;/restriction&gt;
 *             &lt;/complexContent&gt;
 *           &lt;/complexType&gt;
 *         &lt;/element&gt;
 *         &lt;element name="referenceCount" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/&gt;
 *         &lt;element name="references" minOccurs="0"&gt;
 *           &lt;complexType&gt;
 *             &lt;complexContent&gt;
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType"&gt;
 *                 &lt;sequence&gt;
 *                   &lt;element name="reference" type="{http://www.ebi.ac.uk/ebisearch/schemas/EBISearchRestWS}wsEntry" maxOccurs="unbounded" minOccurs="0"/&gt;
 *                 &lt;/sequence&gt;
 *               &lt;/restriction&gt;
 *             &lt;/complexContent&gt;
 *           &lt;/complexType&gt;
 *         &lt;/element&gt;
 *       &lt;/sequence&gt;
 *       &lt;attribute name="id" use="required" type="{http://www.w3.org/2001/XMLSchema}string" /&gt;
 *       &lt;attribute name="source" use="required" type="{http://www.w3.org/2001/XMLSchema}string" /&gt;
 *       &lt;attribute name="acc" type="{http://www.w3.org/2001/XMLSchema}string" /&gt;
 *     &lt;/restriction&gt;
 *   &lt;/complexContent&gt;
 * &lt;/complexType&gt;
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "wsEntry", propOrder = { "fields", "fieldURLs", "viewURLs", "referenceCount", "references", "referenceFacets" })
public class WsEntry {

	protected WsFields     fields;
	protected WsFieldURLs  fieldURLs;
	protected WsViewURLs   viewURLs;
	protected Integer      referenceCount;
	protected WsReferences references;
	protected WsReferenceFacets referenceFacets;
	@XmlAttribute(name = "id", required = true)
	protected String       id;
	@XmlAttribute(name = "source", required = true)
	protected String       source;
	@XmlAttribute(name = "acc")
	protected String       acc;

	/**
	* Gets the value of the fields property.
	* 
	* @return
	*     possible object is
	*     {@link WsFields }
	*     
	*/
	public WsFields getFields() {
		return fields;
	}

	/**
	* Sets the value of the fields property.
	* 
	* @param value
	*     allowed object is
	*     {@link WsFields }
	*     
	*/
	public void setFields(WsFields value) {
		this.fields = value;
	}

	/**
	 * Gets the value of the fieldURLs property.
	 * 
	 * @return
	 *     possible object is
	 *     {@link WsFieldURLs }
	 *     
	 */
	public WsFieldURLs getFieldURLs() {
		return fieldURLs;
	}

	/**
	 * Sets the value of the fieldURLs property.
	 * 
	 * @param value
	 *     allowed object is
	 *     {@link WsEntry.FieldURLs }
	 *     
	 */
	public void setFieldURLs(WsFieldURLs value) {
		this.fieldURLs = value;
	}

	/**
	 * Gets the value of the viewURLs property.
	 * 
	 * @return
	 *     possible object is
	 *     {@link WsViewURLs }
	 *     
	 */
	public WsViewURLs getViewURLs() {
		return viewURLs;
	}

	/**
	 * Sets the value of the viewURLs property.
	 * 
	 * @param value
	 *     allowed object is
	 *     {@link WsViewURLs }
	 *     
	 */
	public void setViewURLs(WsViewURLs value) {
		this.viewURLs = value;
	}

	/**
	 * Gets the value of the referenceCount property.
	 * 
	 * @return
	 *     possible object is
	 *     {@link Integer }
	 *     
	 */
	public Integer getReferenceCount() {
		return referenceCount;
	}

	/**
	 * Sets the value of the referenceCount property.
	 * 
	 * @param value
	 *     allowed object is
	 *     {@link Integer }
	 *     
	 */
	public void setReferenceCount(Integer value) {
		this.referenceCount = value;
	}

	/**
	 * Gets the value of the references property.
	 * 
	 * @return
	 *     possible object is
	 *     {@link WsReferences }
	 *     
	 */
	public WsReferences getReferences() {
		return references;
	}

	/**
	 * Sets the value of the references property.
	 * 
	 * @param value
	 *     allowed object is
	 *     {@link WsReferences }
	 *     
	 */
	public void setReferences(WsReferences value) {
		this.references = value;
	}

	/**
	 * Gets the value of the referenceFacets property.
	 * 
	 * @return
	 *     possible object is
	 *     {@link WsReferenceFacets }
	 *     
	 */
	public WsReferenceFacets getReferenceFacets() {
		return referenceFacets;
	}

	/**
	 * Sets the value of the referenceFacets property.
	 * 
	 * @param value
	 *     allowed object is
	 *     {@link WsReferenceFacets }
	 *     
	 */
	public void setReferenceFacet(WsReferenceFacets value) {
		this.referenceFacets = value;
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
	 * Gets the value of the source property.
	 * 
	 * @return
	 *     possible object is
	 *     {@link String }
	 *     
	 */
	public String getSource() {
		return source;
	}

	/**
	 * Sets the value of the source property.
	 * 
	 * @param value
	 *     allowed object is
	 *     {@link String }
	 *     
	 */
	public void setSource(String value) {
		this.source = value;
	}

	/**
	 * Gets the value of the acc property.
	 * 
	 * @return
	 *     possible object is
	 *     {@link String }
	 *     
	 */
	public String getAcc() {
		return acc;
	}

	/**
	 * Sets the value of the acc property.
	 * 
	 * @param value
	 *     allowed object is
	 *     {@link String }
	 *     
	 */
	public void setAcc(String value) {
		this.acc = value;
	}

}
