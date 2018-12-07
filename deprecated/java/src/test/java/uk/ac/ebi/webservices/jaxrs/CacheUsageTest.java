package uk.ac.ebi.webservices.jaxrs;

import uk.ac.ebi.webservices.jaxrs.EBeyeClient;
import uk.ac.ebi.webservices.jaxrs.stubs.ebeye.WsResult;

public class CacheUsageTest {

   public static void main(String[] args) throws Exception {
      EBeyeClient cli = new EBeyeClient();
      cli.setServiceEndPoint("http://wwwdev.ebi.ac.uk/ebisearch/ws/rest/");
//      cli.setServiceEndPoint("http://wp-p3s-f8:9050/ebisearch/ws/rest/");
//      cli.setEnableCache(false);
//      cli.setCacheConfig("path to configuration");

      try {
         for (int i = 0; i < 15; i++) {
            WsResult r = cli.getResults("emblnew_standard", "brca1", "", 0, 100, false, false, "", "", "");
            System.out.println(String.format("[%d], tot: %d", i, r.getHitCount()));
            Thread.sleep(5000);
         }
      } finally {
         cli.close();
      }
   }
}
