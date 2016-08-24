package uk.ac.ebi.restclient.stubs;

import javax.xml.bind.annotation.*;
import java.util.List;

/**
 * Created by chojnasm on 16/08/2016.
 *
 * A list of values is used in parameter details
 */

@XmlRootElement(name = "value")
@XmlAccessorType(XmlAccessType.FIELD)
public class WsValue {

    @XmlElement(name = "label")
    private String label;

    @XmlElement(name = "value")
    private String value;

    @XmlElement(name = "defaultValue")
    private String defaultValue;

    @XmlElementWrapper(name = "properties")
    @XmlElement(name = "property")
    private List<WsProperty> properties;

    public List<WsProperty> getProperties() {
        return properties;
    }

    public void setProperties(List<WsProperty> properties) {
        this.properties = properties;
    }

    public String getLabel() {
        return label;
    }

    public void setLabel(String label) {
        this.label = label;
    }

    public String getValue() {
        return value;
    }

    public void setValue(String value) {
        this.value = value;
    }

    public String getDefaultValue() {
        return defaultValue;
    }

    public void setDefaultValue(String defaultValue) {
        this.defaultValue = defaultValue;
    }
}
