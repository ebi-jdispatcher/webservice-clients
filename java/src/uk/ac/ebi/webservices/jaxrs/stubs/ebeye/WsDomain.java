package uk.ac.ebi.webservices.jaxrs.stubs.ebeye;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlType;

/**
 * <p>Java class for wsDomain complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="wsDomain"&gt;
 *   &lt;complexContent&gt;
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType"&gt;
 *       &lt;sequence&gt;
 *         &lt;element name="hitCount" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/&gt;
 *         &lt;element name="indexInfos" minOccurs="0"&gt;
 *           &lt;complexType&gt;
 *             &lt;complexContent&gt;
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType"&gt;
 *                 &lt;sequence&gt;
 *                   &lt;element name="indexInfo" type="{http://www.ebi.ac.uk/ebisearch/schemas/EBISearchRestWS}wsIndexInfo" maxOccurs="unbounded" minOccurs="0"/&gt;
 *                 &lt;/sequence&gt;
 *               &lt;/restriction&gt;
 *             &lt;/complexContent&gt;
 *           &lt;/complexType&gt;
 *         &lt;/element&gt;
 *         &lt;element name="fieldInfos" minOccurs="0"&gt;
 *           &lt;complexType&gt;
 *             &lt;complexContent&gt;
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType"&gt;
 *                 &lt;sequence&gt;
 *                   &lt;element name="fieldInfo" type="{http://www.ebi.ac.uk/ebisearch/schemas/EBISearchRestWS}wsFieldInfo" maxOccurs="unbounded" minOccurs="0"/&gt;
 *                 &lt;/sequence&gt;
 *               &lt;/restriction&gt;
 *             &lt;/complexContent&gt;
 *           &lt;/complexType&gt;
 *         &lt;/element&gt;
 *         &lt;element name="subdomains" minOccurs="0"&gt;
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
 *       &lt;/sequence&gt;
 *       &lt;attribute name="id" use="required" type="{http://www.w3.org/2001/XMLSchema}string" /&gt;
 *       &lt;attribute name="name" use="required" type="{http://www.w3.org/2001/XMLSchema}string" /&gt;
 *       &lt;attribute name="description" type="{http://www.w3.org/2001/XMLSchema}string" /&gt;
 *     &lt;/restriction&gt;
 *   &lt;/complexContent&gt;
 * &lt;/complexType&gt;
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "wsDomain", propOrder = { "hitCount", "indexInfos", "fieldInfos", "subdomains" })
public class WsDomain {

	protected Integer      hitCount;
	protected WsIndexInfos indexInfos;
	protected WsFieldInfos fieldInfos;
	protected WsDomains    subdomains;
	@XmlAttribute(name = "id", required = true)
	protected String       id;
	@XmlAttribute(name = "name")
	protected String       name;
	@XmlAttribute(name = "description")
	protected String       description;

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
	 * Gets the value of the indexInfos property.
	 * 
	 * @return
	 *     possible object is
	 *     {@link WsIndexInfos }
	 *     
	 */
	public WsIndexInfos getIndexInfos() {
		return indexInfos;
	}

	/**
	 * Sets the value of the indexInfos property.
	 * 
	 * @param value
	 *     allowed object is
	 *     {@link WsIndexInfos }
	 *     
	 */
	public void setIndexInfos(WsIndexInfos value) {
		this.indexInfos = value;
	}

	/**
	 * Gets the value of the fieldInfos property.
	 * 
	 * @return
	 *     possible object is
	 *     {@link WsFieldInfos }
	 *     
	 */
	public WsFieldInfos getFieldInfos() {
		return fieldInfos;
	}

	/**
	 * Sets the value of the fieldInfos property.
	 * 
	 * @param value
	 *     allowed object is
	 *     {@link WsFieldInfos }
	 *     
	 */
	public void setFieldInfos(WsFieldInfos value) {
		this.fieldInfos = value;
	}

	/**
	 * Gets the value of the subdomains property.
	 * 
	 * @return
	 *     possible object is
	 *     {@link WsDomains }
	 *     
	 */
	public WsDomains getSubdomains() {
		return subdomains;
	}

	/**
	 * Sets the value of the subdomains property.
	 * 
	 * @param value
	 *     allowed object is
	 *     {@link WsDomains }
	 *     
	 */
	public void setSubdomains(WsDomains value) {
		this.subdomains = value;
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
	 * Gets the value of the name property.
	 * 
	 * @return
	 *     possible object is
	 *     {@link String }
	 *     
	 */
	public String getName() {
		return name;
	}

	/**
	 * Sets the value of the name property.
	 * 
	 * @param value
	 *     allowed object is
	 *     {@link String }
	 *     
	 */
	public void setName(String value) {
		this.name = value;
	}

	/**
	 * Gets the value of the description property.
	 * 
	 * @return
	 *     possible object is
	 *     {@link String }
	 *     
	 */
	public String getDescription() {
		return description;
	}

	/**
	 * Sets the value of the description property.
	 * 
	 * @param value
	 *     allowed object is
	 *     {@link String }
	 *     
	 */
	public void setDescription(String value) {
		this.description = value;
	}

}
