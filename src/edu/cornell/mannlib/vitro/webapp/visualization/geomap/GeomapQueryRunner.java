/* $This file is distributed under the terms of the license in /doc/license.txt$ */

package edu.cornell.mannlib.vitro.webapp.visualization.geomap;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.jena.iri.IRI;
import org.apache.jena.iri.IRIFactory;
import org.apache.jena.iri.Violation;

import com.hp.hpl.jena.query.Dataset;
import com.hp.hpl.jena.query.Query;
import com.hp.hpl.jena.query.QueryExecution;
import com.hp.hpl.jena.query.QueryExecutionFactory;
import com.hp.hpl.jena.query.QueryFactory;
import com.hp.hpl.jena.query.QuerySolution;
import com.hp.hpl.jena.query.ResultSet;
import com.hp.hpl.jena.query.Syntax;
import com.hp.hpl.jena.rdf.model.RDFNode;

import edu.cornell.mannlib.vitro.webapp.visualization.collaborationutils.CoAuthorshipData;
import edu.cornell.mannlib.vitro.webapp.visualization.collaborationutils.CollaborationData;
import edu.cornell.mannlib.vitro.webapp.visualization.collaborationutils.CollaboratorComparator;
import edu.cornell.mannlib.vitro.webapp.visualization.constants.QueryConstants;
import edu.cornell.mannlib.vitro.webapp.visualization.constants.QueryFieldLabels;
import edu.cornell.mannlib.vitro.webapp.visualization.exceptions.MalformedQueryParametersException;
import edu.cornell.mannlib.vitro.webapp.visualization.valueobjects.Activity;
import edu.cornell.mannlib.vitro.webapp.visualization.valueobjects.Collaboration;
import edu.cornell.mannlib.vitro.webapp.visualization.valueobjects.Collaborator;
import edu.cornell.mannlib.vitro.webapp.visualization.visutils.QueryRunner;
import edu.cornell.mannlib.vitro.webapp.visualization.visutils.UniqueIDGenerator;

/**
 * This query runner is used to execute a sparql query to get all the publications
 * for a particular individual. It will also fetch all the authors that worked
 * on that particular publication. 
 * 
 * @author cdtank
 */
public class GeomapQueryRunner { //implements QueryRunner<CollaborationData> {

	private static final int MAX_AUTHORS_PER_PAPER_ALLOWED = 100;

	protected static final Syntax SYNTAX = Syntax.syntaxARQ;

	private String egoURI;
	
	private Dataset dataset;

	private Log log;

	private UniqueIDGenerator nodeIDGenerator;

	private UniqueIDGenerator edgeIDGenerator;

	public GeomapQueryRunner(String egoURI,
			Dataset dataset, Log log) {

		this.egoURI = egoURI;
		this.dataset = dataset;
		this.log = log;
		

	}

	private String createQueryResult(ResultSet resultSet) {
		
                String response = "";
		while (resultSet.hasNext()) {
			
			QuerySolution solution = resultSet.nextSolution();
						
			RDFNode label = solution.getLiteral(QueryFieldLabels.LOCATION_NAME);
                        RDFNode location = solution.get(QueryFieldLabels.LOCATION_URI);
                        RDFNode count = solution.getLiteral(QueryFieldLabels.LOCATION_COUNT);
                        RDFNode gCount = solution.getLiteral(QueryFieldLabels.GRANT_COUNT);

			if(location != null  ) {
                                String c = "";
                                String g = "";
                                if ( count != null ) { c = count.toString( ); }
                                if ( gCount != null ) { g = gCount.toString( ); }
				response += ",['" + label.toString() + "', " +
						c + ", " +
						g + " ] \n";
			}
		}
                
		return response;
	}

	
	private ResultSet executeQuery(String queryText,
								   Dataset dataset) {

        QueryExecution queryExecution = null;
        Query query = QueryFactory.create(queryText, SYNTAX);

        queryExecution = QueryExecutionFactory.create(query, dataset);
        ResultSet r = queryExecution.execSelect();

        return r;
    }
       
        private String generateAuthorGeomapSparqlQuery(String queryURI) {
            
            String sparqlQuery = QueryConstants.getSparqlPrefixQuery() 
            + "PREFIX geo: <http://aims.fao.org/aos/geopolitical.owl#> \n"
            + "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>  \n"
            + "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> \n"
            + "PREFIX core: <http://vivoweb.org/ontology/core#>  \n"
            + "PREFIX foaf: <http://xmlns.com/foaf/0.1/>  \n"
            + "PREFIX bibo: <http://purl.org/ontology/bibo/>  \n"
            + "PREFIX vivoc: <http://vivo.library.cornell.edu/ns/0.1#>  \n"
            + "PREFIX afn:  <http://jena.hpl.hp.com/ARQ/function#> "
            + "SELECT DISTINCT (str(?label) as ?name) ?location (afn:localname(?location) AS ?localName) (str(COUNT(DISTINCT ?publication)) AS ?count) (str(COUNT(DISTINCT ?grant)) AS ?gCount) \n"
            + "WHERE { { \n"
            + "    ?authorshipNode core:relates <" + queryURI + "> . \n"
            + "    ?authorshipNode rdf:type core:Authorship . \n"
            + "    ?publication core:relatedBy ?authorshipNode . \n"
            + "    ?publication rdf:type bibo:Article . \n"
            + "    ?location core:geographicFocusOf ?publication .  \n"
            + "    ?location rdf:type core:GeographicRegion .  \n"
            + "    ?location rdfs:label ?label .   \n"
            //+ "    FILTER (NOT EXISTS {?location a core:StateOrProvince}) \n"
            + "} UNION { \n"
            + "    ?invrole core:relates <" + queryURI + "> . \n"
            + "    ?invrole rdf:type core:InvestigatorRole . \n"
            + "    ?grant core:relatedBy ?invrole . \n"
            + "    ?grant rdf:type core:Grant . \n"
            + "    ?location core:geographicFocusOf ?grant .  \n"
            + "    ?location rdf:type core:GeographicRegion .  \n"
            + "    ?location rdfs:label ?label .   \n"
            //+ "    FILTER (NOT EXISTS {?location a core:StateOrProvince}) \n"                    
            + "}} \n"        
            + "GROUP BY ?label ?location \n";
            log.debug("AUTHORGEOMAP QUERY - " + sparqlQuery);
            //System.out.println("AUTHORGEOMAP QUERY - " + sparqlQuery);
            return sparqlQuery;
        }

	
	public String getQueryResult()
		throws MalformedQueryParametersException {

		if (StringUtils.isNotBlank(this.egoURI)) {
			/*
        	 * To test for the validity of the URI submitted.
        	 * */
        	IRIFactory iRIFactory = IRIFactory.jenaImplementation();
    		IRI iri = iRIFactory.create(this.egoURI);
            if (iri.hasViolation(false)) {
                String errorMsg = ((Violation) iri.violations(false).next()).getShortMessage();
                log.error("Ego Co-Authorship Vis Query " + errorMsg);
                throw new MalformedQueryParametersException(
                		"URI provided for an individual is malformed.");
            }
        } else {
            throw new MalformedQueryParametersException("URI parameter is either null or empty.");
        }

		ResultSet resultSet	= executeQuery(generateAuthorGeomapSparqlQuery(this.egoURI),
										   this.dataset);

                
		return createQueryResult(resultSet);
	}

}
