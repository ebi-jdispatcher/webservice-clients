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
 *         &lt;element name="facetValue" type="{http://www.ebi.ac.uk/ebisearch/schemas/EBISearchRestWS}wsFacetValue" maxOccurs="unbounded" minOccurs="0"/&gt;
 *       &lt;/sequence&gt;
 *     &lt;/restriction&gt;
 *   &lt;/complexContent&gt;
 * &lt;/complexType&gt;
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "facetValues", propOrder = { "facetValue" })
public class WsFacetValues {

	public List<WsFacetValue> getFacetValue() {
		if (facetValue == null) {
			facetValue = new ArrayList<WsFacetValue>(0);
		}
		return facetValue;
	}

	public void setFacetValue(List<WsFacetValue> facetValue) {
		this.facetValue = facetValue;
	}

	protected List<WsFacetValue> facetValue;
}