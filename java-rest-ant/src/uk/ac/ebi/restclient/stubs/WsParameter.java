package uk.ac.ebi.restclient.stubs;

import javax.xml.bind.annotation.*;
import java.util.List;

/**
 * Created by chojnasm on 16/08/2016.
 *
 * Represents a java class parsed from endpoint: /parameterdetails/
 */

@XmlRootElement(name="parameter")
@XmlAccessorType(XmlAccessType.FIELD)
public class WsParameter {

    @XmlElement(name = "name")
    private String name;

    @XmlElement(name = "description")
    private String description;

    @XmlElement(name = "type")
    private String type;

    @XmlElementWrapper(name="values")
    @XmlElement(name = "value")
    private List<WsValue> values;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public List<WsValue> getValues() {
        return values;
    }

    public void setValues(List<WsValue> values) {
        this.values = values;
    }
}
