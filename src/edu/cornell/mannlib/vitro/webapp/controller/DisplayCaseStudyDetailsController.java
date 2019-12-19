package edu.cornell.mannlib.vitro.webapp.controller;

import java.io.IOException;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.json.JSONArray;
import org.json.JSONObject;

import com.hp.hpl.jena.query.ResultSet;

import static javax.servlet.http.HttpServletResponse.SC_BAD_REQUEST;
import edu.cornell.mannlib.vitro.webapp.controller.ajax.VitroAjaxController;
import edu.cornell.mannlib.vitro.webapp.dao.jena.QueryUtils;

public class DisplayCaseStudyDetailsController extends VitroAjaxController {
    private static final long serialVersionUID = 1L;
    private static final Log log = LogFactory.getLog(DisplayCaseStudyDetailsController.class);
    
    private static final String PARAM_QUERY = "individualUri";
    
    @Override
    protected void doRequest(VitroRequest vreq, HttpServletResponse response)
    		throws ServletException, IOException {
    	try {
            String uri = vreq.getParameter(PARAM_QUERY);
            JSONArray details = getCaseStudyDetails(uri, vreq);
            if(details != null){
            	response.getWriter().write(details.toString());
            }
    	} catch (Throwable e) {
            log.error(e.getMessage(), e);
            response.setStatus(SC_BAD_REQUEST);
            response.getWriter().write("[{\"error\":\""+e.getMessage()+"\"}]");
        }
    }
    
    private JSONArray getCaseStudyDetails(String individualUri, VitroRequest vreq){
    	if(individualUri != null){
    		String queryStr = QueryUtils.subUriForQueryVar(CASE_STUDY_QUERY, "subject", individualUri);
            JSONArray retVal = new JSONArray();
            try {
                ResultSet results = QueryUtils.getQueryResults(queryStr, vreq);
                while (results.hasNext()) {
                	Map<String,String> map = QueryUtils.querySolutionToStringValueMap(results.nextSolution());
                	retVal.put(new JSONObject(map));
                }
            } catch (Exception e) {
                log.error(e, e);
            }
            return retVal;
    	}
    	return null;
    }
        
    private final String CASE_STUDY_QUERY = ""
    		+ "PREFIX core: <http://vivoweb.org/ontology/core#> \n"
    		+ "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> \n"
    		+ "PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#> \n"
    		+ "PREFIX afn: <http://jena.hpl.hp.com/ARQ/function#> \n"
    		+ "PREFIX uowvivo: <http://uowvivo.uow.edu.au/ontology/uowvivo#> \n"
    		+ "SELECT ?obj (SAMPLE(?t) as ?type) (SAMPLE(?label) as ?name) (SAMPLE(?i) as ?info) (SAMPLE(?desc) as ?description) (SAMPLE(?order) as ?displayOrder)"
    		+ "WHERE"
    		+ "{ "
    		+ " { ?subject <http://uowvivo.uow.edu.au/ontology/uowimpact#hasImpactCountries> ?obj ."
    		+ " ?obj <http://www.w3.org/2000/01/rdf-schema#label> ?label ."
    		+ " values ?t {'country'} } "
    		+ " UNION { ?subject <http://uowvivo.uow.edu.au/ontology/uowimpact#hasPrograms> ?obj ."
    		+ " ?obj <http://www.w3.org/2000/01/rdf-schema#label> ?label . "
    		+ " values ?t {'program'} }"
    		+ " UNION { ?subject <http://uowvivo.uow.edu.au/ontology/uowimpact#hasPartners> ?obj ."
    		+ " ?obj <http://www.w3.org/2000/01/rdf-schema#label> ?label . "
    		+ " values ?t {'partner'} }"
    		+ " UNION { ?subject <http://uowvivo.uow.edu.au/ontology/uowimpact#hasFORCodes> ?obj ."
    		+ " ?obj <http://www.w3.org/2000/01/rdf-schema#label> ?label . "
    		+ " filter regex(?label, \"^[0-9]+\") . "
    		+ " values ?t {'forcode'} }"
    		+ " UNION { ?subject <http://uowvivo.uow.edu.au/ontology/uowimpact#hasCollaborators> ?obj ."
    		+ " ?obj <http://www.w3.org/2000/01/rdf-schema#label> ?label . "
    		+ " values ?t {'collaborator'} }"
    		+ " UNION { ?subject <http://uowvivo.uow.edu.au/ontology/uowimpact#hasEvidence> ?obj ."
    		+ " ?obj <http://uowvivo.uow.edu.au/ontology/uowimpact#linkOfEvidence> ?i . "
    		+ " ?obj <http://uowvivo.uow.edu.au/ontology/uowimpact#linkName> ?label . "
    		+ " optional { ?obj <http://uowvivo.uow.edu.au/ontology/uowimpact#description> ?desc . }"
    		+ " values ?t {'evidence'} }"
    		+ " UNION { ?subject <http://uowvivo.uow.edu.au/ontology/uowimpact#hasBeneficiaries> ?obj ."
    		+ " ?obj <http://uowvivo.uow.edu.au/ontology/uowimpact#numberOfBeneficiaries> ?i . "
    		+ " ?obj <http://uowvivo.uow.edu.au/ontology/uowimpact#beneficiary> ?label . "
    		+ " optional { ?obj <http://uowvivo.uow.edu.au/ontology/uowimpact#description> ?desc . }"
    		+ " optional { ?obj <http://vivoweb.org/ontology/core#preferredDisplayOrder> ?order . }"
    		+ " values ?t {'beneficiary'} }"
    		+ " } GROUP BY ?obj order by ?name";
    
}
