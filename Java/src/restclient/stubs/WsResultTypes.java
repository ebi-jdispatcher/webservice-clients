package restclient.stubs;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import java.util.List;

/**
 * Java class created from parsing result of endpoint: /resulttypes/ + jobId
 * Created by chojnasm on 17/08/2016.
 */

@XmlRootElement(name="types")
@XmlAccessorType(XmlAccessType.FIELD)
public class WsResultTypes {

    @XmlElement(name = "type")
    private List<WsResultType> resultTypes;

    public List<WsResultType> getAsList() {
        return resultTypes;
    }

    public void setResultTypes(List<WsResultType> resultTypes) {
        this.resultTypes = resultTypes;
    }
}
