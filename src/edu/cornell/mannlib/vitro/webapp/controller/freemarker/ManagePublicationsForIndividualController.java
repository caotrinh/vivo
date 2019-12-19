/* $This file is distributed under the terms of the license in /doc/license.txt$ */
package edu.cornell.mannlib.vitro.webapp.controller.freemarker;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.hp.hpl.jena.query.QuerySolution;
import com.hp.hpl.jena.query.ResultSet;
import com.hp.hpl.jena.rdf.model.RDFNode;

import edu.cornell.mannlib.vitro.webapp.auth.permissions.SimplePermission;
import edu.cornell.mannlib.vitro.webapp.auth.requestedAction.AuthorizationRequest;
import edu.cornell.mannlib.vitro.webapp.beans.Individual;
import edu.cornell.mannlib.vitro.webapp.beans.VClass;
import edu.cornell.mannlib.vitro.webapp.controller.VitroRequest;
import edu.cornell.mannlib.vitro.webapp.controller.freemarker.responsevalues.ResponseValues;
import edu.cornell.mannlib.vitro.webapp.controller.freemarker.responsevalues.TemplateResponseValues;
import edu.cornell.mannlib.vitro.webapp.dao.VClassDao;
import edu.cornell.mannlib.vitro.webapp.dao.jena.QueryUtils;


public class ManagePublicationsForIndividualController extends FreemarkerHttpServlet {

    private static final Log log = LogFactory.getLog(ManagePublicationsForIndividualController.class.getName());
    private static final String TEMPLATE_NAME = "managePublicationsForIndividual.ftl";
    
    @Override
	protected AuthorizationRequest requiredActions(VitroRequest vreq) {
		return SimplePermission.DO_FRONT_END_EDITING.ACTION;
	}

    @Override
    protected ResponseValues processRequest(VitroRequest vreq) {

        Map<String, Object> body = new HashMap<String, Object>();

        String subjectUri = vreq.getParameter("subjectUri");
        body.put("subjectUri", subjectUri);

        HashMap<String, List<Map<String,String>>>  publications = getPublications(subjectUri, vreq);
        List<Map<String, String>> topPublications = getTopPublications(subjectUri, vreq);
        List<Map<String, String>> editorships = getPublicationEditorship(subjectUri, vreq);
        if ( log.isDebugEnabled() ) {
			log.debug("publications = " + publications);
		}
        body.put("publications", publications);
        body.put("topPublications", topPublications);
        body.put("pubEditorships", editorships);

        List<String> allSubclasses = getAllSubclasses(publications);
        body.put("allSubclasses", allSubclasses);
        
        Individual subject = vreq.getWebappDaoFactory().getIndividualDao().getIndividualByURI(subjectUri);
        if( subject != null && subject.getName() != null ){
             body.put("subjectName", subject.getName());
        }else{
             body.put("subjectName", null);
        }
        
        return new TemplateResponseValues(TEMPLATE_NAME, body);
    }

    private static String PUBLICATION_QUERY = ""
        + "PREFIX core: <http://vivoweb.org/ontology/core#> \n"
        + "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> \n"
        + "PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#> \n"
        + "PREFIX afn: <http://jena.hpl.hp.com/ARQ/function#> \n"
        + "SELECT DISTINCT ?subclass ?authorship (str(?label) as ?title) ?pub ?hideThis ?dateTime WHERE { \n"
        + "    ?subject core:relatedBy ?authorship . \n"
        + "    ?authorship a core:Authorship  . \n"
        + "    OPTIONAL { \n "
        + "        ?subject core:relatedBy ?authorship . \n"
        + "        ?authorship a core:Authorship  . \n"
        + "        ?authorship core:relates ?pub . "
        + "        ?pub a <http://purl.org/ontology/bibo/Document> . \n"
        + "        ?pub rdfs:label ?label . \n"
        + "        OPTIONAL { \n"
        + "            ?subject core:relatedBy ?authorship . \n"
        + "            ?authorship a core:Authorship  . \n"
        + "            ?authorship core:relates ?pub . "
        + "            ?pub a <http://purl.org/ontology/bibo/Document> . \n"
        + "            ?pub vitro:mostSpecificType ?subclass . \n"
        + "        } \n"
        + "		   OPTIONAL { \n"
        + "			   ?pub core:dateTimeValue ?dateTimeValue . \n"
        + "            ?dateTimeValue core:dateTime ?dateTime \n"
        + "        } \n"
        + "    } \n" 
        + "    OPTIONAL { ?authorship core:hideFromDisplay ?hideThis } \n"
        + "} ORDER BY ?subclass ?title";
    
    private static String PUBLICATION_EDITORSHIP_QUERY = ""
            + "PREFIX core: <http://vivoweb.org/ontology/core#> \n"
            + "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> \n"
            + "PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#> \n"
            + "PREFIX afn: <http://jena.hpl.hp.com/ARQ/function#> \n"
            + "SELECT DISTINCT ?authorship (str(?label) as ?title) ?pub ?hideThis ?dateTime WHERE { \n"
            + "    ?subject core:relatedBy ?authorship . \n"
            + "    ?authorship a core:Editorship . \n"
            + "    OPTIONAL { \n "
            + "        ?subject core:relatedBy ?authorship . \n"
            + "        ?authorship a core:Editorship  . \n"
            + "        ?authorship core:relates ?pub . "
            + "        ?pub a <http://purl.org/ontology/bibo/Document> . \n"
            + "        ?pub rdfs:label ?label . \n"
            + "		   OPTIONAL { \n"
            + "			   ?pub core:dateTimeValue ?dateTimeValue . \n"
            + "            ?dateTimeValue core:dateTime ?dateTime \n"
            + "        } \n"
            + "    } \n"
            + "    OPTIONAL { ?authorship core:hideFromDisplay ?hideThis } \n"
            + "} ORDER BY ?title";
    
    private static String TOP_PUBLICATION_QUERY = ""
            + "PREFIX core: <http://vivoweb.org/ontology/core#> \n"
            + "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> \n"
            + "PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#> \n"
            + "PREFIX afn: <http://jena.hpl.hp.com/ARQ/function#> \n"
            + "PREFIX uowvivo: <http://uowvivo.uow.edu.au/ontology/uowvivo#> \n"
            + "SELECT DISTINCT ?toppub (str(?label) as ?title) (str(?pubrank) as ?rank) ?hideThis ?dateTime (str(?journalLabel) as ?journalTitle) WHERE {  \n"
            + "    ?subject uowvivo:toppub ?toppub . \n"
            + "    OPTIONAL { ?toppub core:relates ?pub . "
            + "               ?pub a <http://purl.org/ontology/bibo/Document> . \n"
            + "               ?pub rdfs:label ?label  \n"
            + "    } \n"
            + "	   OPTIONAL { ?toppub core:relates ?pub . \n"
            + "				  ?pub a <http://purl.org/ontology/bibo/Document> . \n"
            + "				  ?pub core:dateTimeValue ?dateTimeValue . \n"
            + "				  ?dateTimeValue core:dateTime ?dateTime \n"
            + "	   } \n"
            + "    OPTIONAL { ?toppub core:relates ?pub . \n "
            + "               ?pub a <http://purl.org/ontology/bibo/Document> . \n"
            + "               ?pub core:hasPublicationVenue ?journal . \n"
            + "               ?journal a <http://purl.org/ontology/bibo/Journal> . \n"
            + "               ?journal rdfs:label ?journalLabel \n"
            + "    } \n"
            + "	   OPTIONAL { ?toppub uowvivo:publicationRank ?pubrank }"
            + "	   OPTIONAL { ?toppub core:hideFromDisplay ?hideThis } \n"
        	+ "} ORDER BY ?pubrank ?title";
    
    //known issue with pubs of type informationresource, vclass is null for core:informationresource
    HashMap<String, List<Map<String,String>>>  getPublications(String subjectUri, VitroRequest vreq) {

        VClassDao vcDao = vreq.getUnfilteredAssertionsWebappDaoFactory().getVClassDao();

        String queryStr = QueryUtils.subUriForQueryVar(PUBLICATION_QUERY, "subject", subjectUri);
        String subclass = "";
        log.debug("queryStr = " + queryStr);
        HashMap<String, List<Map<String,String>>>  subclassToPublications = new HashMap<String, List<Map<String,String>>>();
        try {
            ResultSet results = QueryUtils.getQueryResults(queryStr, vreq);
            while (results.hasNext()) {
                QuerySolution soln = results.nextSolution();
                RDFNode subclassUri= soln.get("subclass");
                if(subclassUri != null){
                	String subclassUriStr = soln.get("subclass").toString();
                	//manually remove informationresource type from pub displaying section 
                	//since it causes duplicate mostspecific type and this type is not real
                	if(subclassUriStr.contains("core#InformationResource")){
                		continue;
                	}
            		VClass vClass = vcDao.getVClassByURI(subclassUriStr);
                    subclass = ((vClass != null && vClass.getName() != null) ? vClass.getName() : subclassUriStr);
                }
                else {
                    subclass = "Unclassified Publication";
                }
                if(!subclassToPublications.containsKey(subclass)) {
                    subclassToPublications.put(subclass, new ArrayList<Map<String,String>>()); //list of publication information
                }
                List<Map<String,String>> publicationsList = subclassToPublications.get(subclass);
                publicationsList.add(QueryUtils.querySolutionToStringValueMap(soln));
            }
        } catch (Exception e) {
            log.error(e, e);
        }
        return subclassToPublications;
    }
    
    List<Map<String, String>> getPublicationEditorship(String subjectUri, VitroRequest vreq){
    	String queryStr = QueryUtils.subUriForQueryVar(PUBLICATION_EDITORSHIP_QUERY, "subject", subjectUri);
        List<Map<String,String>>  editorships = new ArrayList<Map<String,String>>();
        try {
            ResultSet results = QueryUtils.getQueryResults(queryStr, vreq);
            while (results.hasNext()) {
            	editorships.add(QueryUtils.querySolutionToStringValueMap(results.nextSolution()));
            }
        } catch (Exception e) {
            log.error(e, e);
        }
        return editorships;
    }

    
    List<Map<String, String>> getTopPublications(String subjectUri, VitroRequest vreq){
    	String queryStr = QueryUtils.subUriForQueryVar(TOP_PUBLICATION_QUERY, "subject", subjectUri);
        List<Map<String,String>>  topPublications = new ArrayList<Map<String,String>>();
        try {
            ResultSet results = QueryUtils.getQueryResults(queryStr, vreq);
            while (results.hasNext()) {
                topPublications.add(QueryUtils.querySolutionToStringValueMap(results.nextSolution()));
            }
        } catch (Exception e) {
            log.error(e, e);
        }
        return topPublications;
    }

    private List<String> getAllSubclasses(HashMap<String, List<Map<String, String>>> publications) {
        List<String> allSubclasses = new ArrayList<String>(publications.keySet());
        Collections.sort(allSubclasses);
        return allSubclasses;
    }
}