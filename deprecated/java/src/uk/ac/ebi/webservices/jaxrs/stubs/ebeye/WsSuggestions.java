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
 *         &lt;element name="suggestion" type="{http://www.ebi.ac.uk/ebisearch/schemas/EBISearchRestWS}wsSuggestion" maxOccurs="unbounded" minOccurs="0"/&gt;
 *       &lt;/sequence&gt;
 *     &lt;/restriction&gt;
 *   &lt;/complexContent&gt;
 * &lt;/complexType&gt;
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "suggestions", propOrder = { "suggestion" })
public class WsSuggestions {

	protected List<WsSuggestion> suggestion;

	public List<WsSuggestion> getSuggestion() {
		if (suggestion == null) {
			suggestion = new ArrayList<WsSuggestion>(0);
		}
		return suggestion;
	}

	public void setSuggestion(List<WsSuggestion> suggestion) {
		this.suggestion = suggestion;
	}
}
