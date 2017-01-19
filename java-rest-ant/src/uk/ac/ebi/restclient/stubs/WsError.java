package uk.ac.ebi.restclient.stubs;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

/**
 * Created by chojnasm on 23/11/2016.
 */

@XmlRootElement(name = "error")
@XmlAccessorType(XmlAccessType.FIELD)
public class WsError {

    @XmlElement(name = "description")
    private String error;

    public String getError() {
        return error;
    }

    public void setError(String error) {
        this.error = error;
    }
}
