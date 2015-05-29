/**
 * Created by Apache CXF WadlToJava code generator
**/
package uk.ac.ebi.webservices.jaxrs.stubs.ebeye;

import javax.ws.rs.DefaultValue;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.Response;

@Path("/")
public interface Resource {

    @GET
    @Produces({"application/xml", "application/json", "text/csv", "text/tab-separated-values" })
    Response get(@QueryParam("format") String format);

    @GET
    @Produces({"application/xml", "application/json", "text/xml", "text/csv", "text/tab-separated-values" })
    @Path("/{domainid}")
    Response getDomainid(@PathParam("domainid") String domainid, @QueryParam("query") String query, @QueryParam("size") Integer size, @QueryParam("start") Integer start, 
                @QueryParam("sortfield") String sortfield, @QueryParam("order") String order, @QueryParam("fields") String fields, @QueryParam("fieldurl") Boolean fieldurl, 
                @QueryParam("viewurl") Boolean viewurl, @QueryParam("facetfields") String facetfields, @QueryParam("facetcount") Integer facetcount, @QueryParam("selectedfacetvalues") String selectedfacetvalues, 
                @QueryParam("feedtitle") String feedtitle, @QueryParam("feedmaxdays") Integer feedmaxdays, @QueryParam("feedmaxdaysfield") String feedmaxdaysfield, @QueryParam("format") String format);

    @GET
    @Produces({"application/xml", "application/json", "text/csv", "text/tab-separated-values" })
    @Path("/{domainid}/entry/{entryids}")
    Response getDomainidentryentryids(@PathParam("domainid") String domainid, @PathParam("entryids") String entryids, @QueryParam("fields") String fields, @QueryParam("fieldurl") @DefaultValue("false") Boolean fieldurl, 
                @QueryParam("viewurl") @DefaultValue("false") Boolean viewurl, @QueryParam("format") String format);

    @GET
    @Produces({"application/xml", "application/json", "text/csv", "text/tab-separated-values" })
    @Path("/{domainid}/entry/{entryids}/xref/{targetdomainid}")
    Response getDomainidentryentryidsxreftargetdomainid(@PathParam("domainid") String domainid, @PathParam("entryids") String entryids, @PathParam("targetdomainid") String targetdomainid, @QueryParam("size") @DefaultValue("15") Integer size, 
                @QueryParam("start") @DefaultValue("0") Integer start, @QueryParam("fields") String fields, @QueryParam("fieldurl") @DefaultValue("false") Boolean fieldurl, @QueryParam("viewurl") @DefaultValue("false") Boolean viewurl, 
                @QueryParam("format") String format);

    @GET
    @Produces({"application/xml", "application/json", "text/csv", "text/tab-separated-values" })
    @Path("/{domainid}/entry/{entryid}/xref")
    Response getDomainidentryentryidxref(@PathParam("domainid") String domainid, @PathParam("entryid") String entryid, @QueryParam("format") String format);

    @GET
    @Produces({"application/xml", "application/json", "text/csv", "text/tab-separated-values" })
    @Path("/{domainid}/xref")
    Response getDomainidxref(@PathParam("domainid") String domainid, @QueryParam("format") String format);

    @GET
    @Produces({"application/xml", "application/json", "text/csv", "text/tab-separated-values" })
    @Path("/{domainid}/autocomplete")
    Response getDomainidautocomplete(@PathParam("domainid") String domainid, @QueryParam("term") String term, @QueryParam("formatted") @DefaultValue("false") Boolean formatted, @QueryParam("format") String format);

}