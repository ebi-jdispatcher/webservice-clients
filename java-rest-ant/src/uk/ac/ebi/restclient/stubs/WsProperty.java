package uk.ac.ebi.restclient.stubs;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

/**
 * Created by chojnasm on 16/08/2016.
 */

@XmlRootElement(name = "property")
@XmlAccessorType(XmlAccessType.FIELD)
public class WsProperty {

    @XmlElement(name = "key")
    private String key;

    @XmlElement(name = "value")
    private String value;

    public String getKey() {
        return key;
    }

    public void setKey(String key) {
        this.key = key;
    }

    public String getValue() {
        return value;
    }

    public void setValue(String value) {
        this.value = value;
    }
}
