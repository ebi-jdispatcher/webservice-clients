package uk.ac.ebi.webservices.jaxrs.stubs.ebeye;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;

/**
 * <p>Java class for wsTerm complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="wsTerm"&gt;
 *   &lt;complexContent&gt;
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType"&gt;
 *       &lt;sequence&gt;
 *         &lt;element name="text" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="1"/&gt;
 *         &lt;element name="docFreq" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="1"/&gt;
 *       &lt;/sequence&gt;
 *     &lt;/restriction&gt;
 *   &lt;/complexContent&gt;
 * &lt;/complexType&gt;
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "WsTerm", propOrder = { "text", "docFreq" })
public class WsTerm {
	@XmlElement(required = true)
	protected String text;
	@XmlElement(required = true)
	protected int    docFreq;

	public String getText() {
		return text;
	}

	public void setText(String text) {
		this.text = text;
	}

	public int getDocFreq() {
		return docFreq;
	}

	public void setDocFreq(int docFreq) {
		this.docFreq = docFreq;
	}

}
