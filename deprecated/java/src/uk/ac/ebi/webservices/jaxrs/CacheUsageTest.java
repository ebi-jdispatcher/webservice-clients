package uk.ac.ebi.webservices.jaxrs;

import uk.ac.ebi.webservices.jaxrs.stubs.ebeye.WsResult;

public class CacheUsageTest {

   public static void main(String[] args) throws Exception {
      EBeyeClient cli = new EBeyeClient();
      cli.setServiceEndPoint("http://wp-np2-28:8080/ebisearch/ws/rest/");

      for (int i = 0; i < 10; i++) {
         WsResult r = cli.getResults("emblnew_standard", "brca1", "", 0, 100, false, false, "", "", "");
         System.out.println(String.format("[%d], tot: %d", i, r.getHitCount()));
      }
   }
}
