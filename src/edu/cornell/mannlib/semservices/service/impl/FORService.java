/* $This file is distributed under the terms of the license in /doc/license.txt$ */

package edu.cornell.mannlib.semservices.service.impl;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.StringWriter;
import java.net.MalformedURLException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.net.URLEncoder;
import java.rmi.RemoteException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Comparator;
import java.util.Collections;
import java.util.Set;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.rpc.ServiceException;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;
import net.sf.json.JSONSerializer;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.commons.lang3.text.WordUtils;
import org.semanticweb.skos.SKOSAnnotation;
import org.semanticweb.skos.SKOSConcept;
import org.semanticweb.skos.SKOSDataFactory;
import org.semanticweb.skos.SKOSDataProperty;
import org.semanticweb.skos.SKOSDataRelationAssertion;
import org.semanticweb.skos.SKOSDataset;
import org.semanticweb.skos.SKOSEntity;
import org.semanticweb.skos.SKOSLiteral;
import org.semanticweb.skos.SKOSObjectRelationAssertion;
import org.semanticweb.skos.SKOSUntypedLiteral;
import org.semanticweb.skos.properties.*;
import org.semanticweb.skosapibinding.SKOSManager;
import org.w3c.dom.Attr;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

import com.hp.hpl.jena.query.Query;
import com.hp.hpl.jena.query.QueryExecution;
import com.hp.hpl.jena.query.QueryExecutionFactory;
import com.hp.hpl.jena.query.QueryFactory;
import com.hp.hpl.jena.query.QuerySolution;
import com.hp.hpl.jena.query.ResultSet;
import com.hp.hpl.jena.rdf.model.Literal;
import com.hp.hpl.jena.rdf.model.RDFNode;
import com.hp.hpl.jena.rdf.model.Resource;

import edu.cornell.mannlib.semservices.bo.Concept;
import edu.cornell.mannlib.semservices.exceptions.ConceptsNotFoundException;
import edu.cornell.mannlib.semservices.service.ExternalConceptService;
import edu.cornell.mannlib.semservices.util.XMLUtils;

public class FORService implements ExternalConceptService {

	protected final Log log = LogFactory.getLog(getClass());
	private final String skosSuffix = ".skos.rdf";
    private final String conceptVocabEndPoint = "http://localhost/vocab/anzsrc_for_2008.rdf";
	private final String hostUri = "http://services.ands.org.au";
	private java.lang.String LCSHWS_address = hostUri + "/vocab";
	private final String schemeUri = hostUri + "/vocab";
	private final String baseUri = hostUri + "/getConceptByIdentifier";
	private final String ontologyName = "ANZSRC For Code";
	private final String format = "SKOS";
	private final String lang = "en";
	private final String codeName = "hasCodeAgrovoc";
	private final String searchMode = "Exact Match";
	protected final String dbpedia_endpoint = " http://dbpedia.org/sparql";
	//Property uris used for SKOS
	protected final String SKOSNotePropertyURI = "http://www.w3.org/2004/02/skos/core#note";
	protected final String SKOSPrefLabelURI = "http://www.w3.org/2004/02/skos/core#prefLabel";
	protected final String SKOSAltLabelURI = "http://www.w3.org/2008/05/skos-xl#altLabel";
	protected final String SKOSBroaderURI = "http://www.w3.org/2004/02/skos/core#broader";
	protected final String SKOSNarrowerURI = "http://www.w3.org/2004/02/skos/core#narrower";
	protected final String SKOSExactMatchURI = "http://www.w3.org/2004/02/skos/core#exactMatch";
	protected final String SKOSCloseMatchURI = "http://www.w3.org/2004/02/skos/core#closeMatch";

	@Override
	public List<Concept> getConcepts(String term) throws Exception {
		List<Concept> conceptList = new ArrayList<Concept>();
		String results = null;
                log.debug( "About to search for '"+term+"'");
 
                try {
                    conceptList = processOutput(term);
                
                } catch (Exception e ) {
                    log.error( "Failed to gneerate results: " + e.getMessage() );
                }
                /**
                 * Sorting the results based on the FOR numeric code.
                 * These are normally organised in a nested structure & we want to preserve that
                 * since this is how researchers are used to seeing them presented.
                 */
                Comparator<Concept> comparator = new Comparator<Concept>() {
                public int compare(Concept c1, Concept c2) {
                    Integer code1 = ( c1.getNotation().length( ) == 2 ? Integer.parseInt( c1.getNotation() ) * 100 : Integer.parseInt( c1.getNotation() ) );
                    Integer code2 = ( c2.getNotation().length( ) == 2 ? Integer.parseInt( c2.getNotation() ) * 100 : Integer.parseInt( c2.getNotation() ) );
                    return (code1 - code2);
                }
                };
                try{
                	Collections.sort(conceptList, comparator);
                } catch( NullPointerException e )
                {
                	log.error("Failed to complete sorting: " + e.getMessage( ));
                }

		return conceptList;
	}

	// Results are in json format (atom) - atom entries need to be extracted
	// retrieve the URIs and get the SKOS version of the entry, getting broader
	// and narrower terms as applicable as well as any description (skos:note)
	// that might exist
	private List<Concept> processOutput(String term) throws Exception {
		log.debug("processOuput called. setting up...");
		List<Concept> conceptList = new ArrayList<Concept>();
                log.debug("processOuput called. gets the SKOSManager ");
		//SKOSManager manager = new SKOSManager();
                log.debug("processOuput called. Preparing to fetch concepts");
		// Get uris from the results
		// Properties we will be querying for
		//SKOSDataFactory sdf = manager.getSKOSDataFactory();
                log.debug("END Point for URI: " + this.conceptVocabEndPoint);
                
                URI conceptURI = URI.create(this.conceptVocabEndPoint );
                
                
                String rdf;
                try {
                    StringWriter sw = new StringWriter();
			URL feed = new URL(this.conceptVocabEndPoint);

			BufferedReader in = new BufferedReader(new InputStreamReader(
					feed.openStream()));
			String inputLine;
			while ((inputLine = in.readLine()) != null) {
				sw.write(inputLine);
			}
			in.close();

			rdf = sw.toString();
                } catch (Exception ex) {
			log.error("error occurred in servlet", ex);
			return null;
		}
                log.debug( "rdfxml read:"  + rdf );
                List<Concept> allConcepts = getConceptURIFromXML( rdf );
                log.debug( "read " + allConcepts.size() + " concepts from the FORService rdfxml" );
                
                
                log.debug("concept end point: " + conceptURI.toString());
                //SKOSDataset dataset = manager.loadDataset(conceptURI);
                //log.debug("SKOSDataset URI: " + conceptURI );
		//Set<SKOSConcept> skosConcepts = dataset.getSKOSConcepts();
                //Concept c;
                for (Concept c : allConcepts) {
                    String bestMatch = "true";
                    //Concept c = this.createConcept(sdf, bestMatch, skosConcept, dataset);
                    //log.debug( "CREATED Concept URI code: " + skosConcept.getURI().toString() +" Notation: '" + c.getNotation() +"' ");
                    
                    if( term.length() > 0  ) {
                        String pattern = "(.*)"+ term.toUpperCase( ) + "(.*)";
                        if( c.getLabel( ).toUpperCase( ).matches( pattern ) ) {
                            conceptList.add(c);
                        }
                    } else {
                        //No search terms provided, so display all FOR Concepts for possible inclusion
                        conceptList.add(c);                      
                    }

                }
                log.debug("Number of SKOSConcepts copied in the list: " + conceptList.size() );
                return conceptList;
		
	}

        protected List<Concept> getConceptURIFromXML(String rdf) {
		List<Concept> conceptList = new ArrayList<Concept>();
		String conceptUri = new String();
		try {
			Document doc = XMLUtils.parse(rdf);
			NodeList nodes = doc.getElementsByTagName("rdf:Description");
			int len = nodes.getLength();
			int i;
			for (i = 0; i < len; i++) {
				Concept c = new Concept( );
				Element firstElement = (Element)nodes.item(i);                              
				conceptUri = firstElement.getAttribute("rdf:about");
                String bm = "true";
                NodeList notationList = firstElement.getElementsByTagName("skos:notation");
                
                if(notationList != null && notationList.getLength() > 0){
                	c.setUri(conceptUri);
                    c.setConceptId(conceptUri);
                    c.setBestMatch( bm );
                    c.setDefinedBy(schemeUri);
                    c.setSchemeURI(schemeUri);
                    c.setType("");
                    
                    NodeList noteList = firstElement.getElementsByTagName("skos:note");
                    if(noteList != null && noteList.getLength() > 0){
	                    Element note = (Element)noteList.item(0);
	                    NodeList noteStringList = note.getChildNodes();
	                    c.setDefinition(((Node)noteStringList.item(0)).getNodeValue().trim());
                    }
                    
                    NodeList labelList = firstElement.getElementsByTagName("skos:prefLabel");
                    Element label = (Element)labelList.item(0);
                    NodeList labelStringList = label.getChildNodes();
                    
                    Element notation = (Element)notationList.item(0);
                    NodeList notationStringList = notation.getChildNodes();
                    c.setLabel( ((Node)notationStringList.item(0)).getNodeValue().trim()+" - "+((Node)labelStringList.item(0)).getNodeValue().trim());
                    conceptList.add(c);
                }
                                
			}

		} catch (IOException e) {
			log.error("error occurred in parsing " +rdf, e);
		} catch (SAXException e) {
			log.error("error occurred in parsing " +rdf, e);
		} catch (ParserConfigurationException e) {
			log.error("error occurred in parsing " +rdf, e);

		}
		return conceptList;

	}
	
	
	//Will use skos if does not encounter error from skos api, otherwise will use regular XML parsing techniques
	public Concept createConcept(SKOSDataFactory skosDataFactory, String bestMatch, SKOSConcept skosConcept, SKOSDataset dataset) {

		Concept concept = new Concept();
		String skosConceptURI = skosConcept.getURI().toString();
		log.debug("SKOSConceptURI is " + skosConceptURI);
		// get skos version of uri

		concept.setUri(skosConceptURI);
		concept.setConceptId(stripConceptId(skosConceptURI));
		concept.setBestMatch(bestMatch);
		concept.setDefinedBy(schemeUri);
		concept.setSchemeURI(schemeUri);
		concept.setType("");
		
		try {
			Set<SKOSAnnotation> skosAnnots = skosConcept
					.getSKOSAnnotations(dataset);
		} catch(Exception ex) {
			log.debug("Error occurred for annotation retrieval for skos concept " + skosConceptURI, ex);
			return null;
		}
		
		concept = this.createConceptUsingSKOS(skosDataFactory, concept, skosConcept, dataset);
		return concept;

	}
	
	private Concept createConceptUsingSKOS(SKOSDataFactory skosDataFactory, Concept concept, SKOSConcept skosConcept, SKOSDataset dataset) {
		
		SKOSPrefLabelProperty prefLabelProperty = skosDataFactory.getSKOSPrefLabelProperty();
		SKOSAltLabelProperty altLabelProperty = skosDataFactory.getSKOSAltLabelProperty();

		try {
			List<String> labelLiterals = this.getSKOSLiteralValues(skosConcept
					.getSKOSRelatedConstantByProperty(dataset,
							prefLabelProperty)); 
			List<String> notations = this.getSKOSAnnotationValues( 
					skosConcept.getSKOSAnnotationsByURI( dataset, 
									     skosDataFactory.getSKOSNotationProperty().getURI() ) );
			if( notations.size( ) > 0 ) { 
				log.debug("PreLabelProperty: " + prefLabelProperty.getURI( ).toString( )+ " Notation: " + notations.get(0).toString() );
				concept.setNotation( notations.get(0) );
			} else {
				//This is an error because there should be at least one notation returned
				log.debug("The number of preferred notations is not greater than zero");
			}

			if(labelLiterals.size() > 0) {
				concept.setLabel(labelLiterals.get(0));
				concept.setLabel( concept.getNotation() + " - " + concept.getLabel() );
			} else {
				//This is an error because there should be at least one label returned
				log.debug("The number of preferred labels is not greater than zero");
			}
							
			// get altLabels
			List<String> altLabelList = this.getSKOSLiteralValues(skosConcept
					.getSKOSRelatedConstantByProperty(dataset, altLabelProperty));
			concept.setAltLabelList(altLabelList);

			// See if we can get a description as well
			List<String> notes = this.getSKOSAnnotationValues(skosConcept
				.getSKOSAnnotationsByURI(dataset, new URI(this.SKOSNotePropertyURI)));
			
			concept.setDefinition(StringUtils.join(notes, ","));
			
			// get the broader property URI
			List<String> broaderURIList = this.getSKOSAnnotationValues(skosConcept
					.getSKOSAnnotationsByURI(dataset, new URI(this.SKOSBroaderURI)));
			concept.setBroaderURIList(broaderURIList);

			// get the narrower property URI
			List<String> narrowerURIList = this.getSKOSAnnotationValues(skosConcept
					.getSKOSAnnotationsByURI(dataset, new URI(this.SKOSNarrowerURI)));
			concept.setNarrowerURIList(narrowerURIList);

			// exact match
			List<String> exactMatchURIList = this.getSKOSAnnotationValues(skosConcept
					.getSKOSAnnotationsByURI(dataset,
							new URI(this.SKOSExactMatchURI)));
			concept.setExactMatchURIList(exactMatchURIList);

			// close match
			List<String> closeMatchURIList = this.getSKOSAnnotationValues(skosConcept
					.getSKOSAnnotationsByURI(dataset,
							new URI(this.SKOSCloseMatchURI)));
			concept.setCloseMatchURIList(closeMatchURIList);
			log.debug("add concept to list");
		} catch (Exception ex) {
			log.debug("Exception occurred for -" + skosConcept.getURI()
					+ "- " + ex.getMessage(), ex);
			return null;
		}

		return concept;
	}
	
	private List<String> getSKOSLiteralValues(Set<SKOSLiteral> skosLiterals) {
		String lang = "";
		List<String> literalValues = new ArrayList<String>();
		for (SKOSLiteral literal : skosLiterals) {
			if(literal != null) {
				if (!literal.isTyped()) {
					// if it has language
					SKOSUntypedLiteral untypedLiteral = literal
							.getAsSKOSUntypedLiteral();
					if (untypedLiteral.hasLang()) {
						lang = untypedLiteral.getLang();
					} else {
						lang = "";
					}
				}
				// log.debug("literal: "+ literal.getLiteral());
				log.debug("literal value: " + literal.getLiteral());
				literalValues.add(literal.getLiteral());
			} else {
				log.debug("Literal returned was null so was ignored");
			}
		}
		return literalValues;
	}
	
	//For a given set of annotations (for example, for a specific property)
	private List<String> getSKOSAnnotationValues(Set<SKOSAnnotation> skosAnnotations) {
		List<String> valuesList = new ArrayList<String>();
		for (SKOSAnnotation annotation : skosAnnotations) {
			String value = this.getSKOSAnnotationStringValue(annotation);
			valuesList.add(value);
		}
		return valuesList;
	}
	
	//Get string value for annotation
	private String getSKOSAnnotationStringValue(SKOSAnnotation annotation) {
		String value = new String();
		if (annotation.isAnnotationByConstant()) {
			SKOSLiteral literal = annotation
					.getAnnotationValueAsConstant();
			value = literal.getLiteral();
			log.debug("broder uri: " + value);
		} else {
			// annotation is some resource
			SKOSEntity entity = annotation.getAnnotationValue();
			value = entity.getURI().toString();
		}
		return value;
	}

	private String getSKOSURI(String uri) {
		// Strip .xml at the end and replace with .skos.rdf
		String skosURI = uri;
		if (uri.endsWith(".xml")) {
			skosURI = uri.substring(0, uri.length() - 4);
			skosURI += skosSuffix;
		}
		return skosURI;
	}

	public List<String> getConceptURISFromJSON(String results) {
		List<String> uris = new ArrayList<String>();
		try {
			JSONObject json = (JSONObject) JSONSerializer.toJSON(results);
			log.debug(json.toString());
			// Get atom entry elements

		} catch (Exception ex) {
			log.error("Could not get concepts", ex);
			throw ex;
		}
		return uris;

	}
/*
	protected List<String> getConceptURIFromXML(String rdf) {
		List<String> uris = new ArrayList<String>();
		String conceptUri = new String();
		try {
			Document doc = XMLUtils.parse(rdf);
			NodeList nodes = doc.getElementsByTagName("search:result");
			int len = nodes.getLength();
			int i;
			for (i = 0; i < len; i++) {
				Node node = nodes.item(i);
				NamedNodeMap attrs = node.getAttributes();
				Attr idAttr = (Attr) attrs.getNamedItem("uri");
				conceptUri = idAttr.getTextContent();
				log.debug("concept uri is " + conceptUri);
				uris.add(conceptUri);
			}

		} catch (IOException e) {
			log.error("error occurred in parsing " +rdf, e);
		} catch (SAXException e) {
			log.error("error occurred in parsing " +rdf, e);
		} catch (ParserConfigurationException e) {
			log.error("error occurred in parsing " +rdf, e);

		}
		return uris;

	}
*/
	public List<Concept> processResults(String term) throws Exception {
		return getConcepts(term);
	}

	/**
	 * @param uri
	 * @return
	 */
	protected String stripConceptId(String uri) {
		String conceptId = new String();
		int lastslash = uri.lastIndexOf('/');
		conceptId = uri.substring(lastslash + 1, uri.length());
		return conceptId;
	}

	/**
	 * @param str
	 * @return
	 */
	protected String extractConceptId(String str) {
		try {
			return str.substring(1, str.length() - 1);
		} catch (Exception ex) {
			log.error("Exception occurred in extracting concept id for " + str, ex);
			return "";
		}
	}

	@Override
	public List<Concept> getConceptsByURIWithSparql(String uri)
			throws Exception {
		// TODO Auto-generated method stub
		return null;
	}
	
	
	
	
	public List<String> getValuesFromXMLNodes(Document doc, String tagName, String attributeName) {
		NodeList nodes = doc.getElementsByTagName(tagName);
		
		return getValuesFromXML(nodes, attributeName);
	}
	
	//Returns list of values based on nodes and whether or not a specific attribute name should be used or just the text content
	public List<String> getValuesFromXML(NodeList nodes, String attributeName) {
		int len = nodes.getLength();
		int i;
		List<String> values = new ArrayList<String>();
		for (i = 0; i < len; i++) {
			Node node = nodes.item(i);
			if(attributeName != null && !attributeName.isEmpty()) {
				NamedNodeMap attrs = node.getAttributes();
				Attr a = (Attr)attrs.getNamedItem(attributeName);
				if(a != null) {
					values.add(a.getTextContent());
				}
			} else {
				values.add(node.getTextContent());
			}
		}
		return values;
	}

	

}
