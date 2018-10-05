package uk.ac.ebi.webservices.jaxrs.stubs.ebeye;

import java.util.ArrayList;
import java.util.List;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlType;

/**
 * <p>Java class for anonymous complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType&gt;
 *   &lt;complexContent&gt;
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType"&gt;
 *       &lt;sequence&gt;
 *         &lt;element name="reference" type="{http://www.ebi.ac.uk/ebisearch/schemas/EBISearchRestWS}wsEntry" maxOccurs="unbounded" minOccurs="0"/&gt;
 *       &lt;/sequence&gt;
 *     &lt;/restriction&gt;
 *   &lt;/complexContent&gt;
 * &lt;/complexType&gt;
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "references", propOrder = { "reference" })
public class WsReferences {

	protected List<WsEntry> reference;

	public List<WsEntry> getReference() {
		if (reference == null) {
			reference = new ArrayList<WsEntry>(0);
		}
		return reference;
	}

	public void setReference(List<WsEntry> reference) {
		this.reference = reference;
	}

}
