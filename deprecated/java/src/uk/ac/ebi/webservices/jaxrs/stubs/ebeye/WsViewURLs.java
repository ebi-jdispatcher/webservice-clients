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
 *         &lt;element name="viewURL" type="{http://www.ebi.ac.uk/ebisearch/schemas/EBISearchRestWS}wsurl" maxOccurs="unbounded" minOccurs="0"/&gt;
 *       &lt;/sequence&gt;
 *     &lt;/restriction&gt;
 *   &lt;/complexContent&gt;
 * &lt;/complexType&gt;
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "viewURLs", propOrder = { "viewURL" })
public class WsViewURLs {

	protected List<Wsurl> viewURL;

	public List<Wsurl> getViewURL() {
		if (viewURL == null) {
			viewURL = new ArrayList<Wsurl>(0);
		}
		return viewURL;
	}

	public void setViewURL(List<Wsurl> viewURL) {
		this.viewURL = viewURL;
	}
}
