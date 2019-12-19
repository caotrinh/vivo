/* $This file is distributed under the terms of the license in /doc/license.txt$ */

package edu.cornell.mannlib.vitro.webapp.controller.edit;

import static javax.servlet.http.HttpServletResponse.SC_BAD_REQUEST;
import static javax.servlet.http.HttpServletResponse.SC_INTERNAL_SERVER_ERROR;

import java.io.IOException;
import java.io.StringReader;
import java.io.StringWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.json.JSONException;
import org.json.JSONObject;

import com.hp.hpl.jena.ontology.OntModel;
import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.shared.Lock;

import edu.cornell.mannlib.vitro.webapp.auth.permissions.SimplePermission;
import edu.cornell.mannlib.vitro.webapp.auth.requestedAction.AuthorizationRequest;
import edu.cornell.mannlib.vitro.webapp.beans.DataProperty;
import edu.cornell.mannlib.vitro.webapp.beans.DataPropertyStatement;
import edu.cornell.mannlib.vitro.webapp.beans.DataPropertyStatementImpl;
import edu.cornell.mannlib.vitro.webapp.beans.Individual;
import edu.cornell.mannlib.vitro.webapp.controller.VitroRequest;
import edu.cornell.mannlib.vitro.webapp.controller.ajax.VitroAjaxController;
import edu.cornell.mannlib.vitro.webapp.dao.IndividualDao;
import edu.cornell.mannlib.vitro.webapp.dao.InsertException;
import edu.cornell.mannlib.vitro.webapp.dao.NewURIMakerVitro;
import edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory;
import edu.cornell.mannlib.vitro.webapp.dao.jena.DependentResourceDeleteJena;
import edu.cornell.mannlib.vitro.webapp.dao.jena.event.EditEvent;
import edu.cornell.mannlib.vitro.webapp.edit.n3editing.VTwo.N3EditUtils;
import edu.cornell.mannlib.vitro.webapp.edit.n3editing.VTwo.NewURIMaker;
import edu.cornell.mannlib.vitro.webapp.edit.n3editing.configuration.StandardModelSelector;

public class PrimitiveRdfEdit extends VitroAjaxController {

    private static final long serialVersionUID = 1L;
    private static final String PREFIX_NEW_RESOURCE = "primitiveEditNew";
    private static final String PARAM_DELETION = "deletion";
    private static final String PARAM_UPDATE = "updatePredValue";
    private static final String PARAM_JSON_SUBJECT = "subject";
    private static final String PARAM_JSON_OBJECT = "object";
    private static final String PARAM_JSON_PREDICATE = "predicate";

    //Using the same setup as primitive delete
    @Override
    protected AuthorizationRequest requiredActions(VitroRequest vreq) {
    	return SimplePermission.USE_BASIC_AJAX_CONTROLLERS.ACTION;
    }
    
    @Override
    protected void doRequest(VitroRequest vreq,
            HttpServletResponse response) throws ServletException, IOException {
        
        //Test error case
        /*
        if (1==1) {
            doError(response, "Test error", 500);
            return;
        } */
        
        /* Predefined values for RdfFormat are "RDF/XML", 
         * "N-TRIPLE", "TURTLE" (or "TTL") and "N3". null represents 
         * the default language, "RDF/XML". "RDF/XML-ABBREV" is a synonym for "RDF/XML" */
        String format = vreq.getParameter("RdfFormat");      
        if( format == null )            
            format = "N3";      
        if ( ! ("N-TRIPLE".equals(format) || "TURTLE".equals(format) || "TTL".equals(format)
                || "N3".equals(format)|| "RDF/XML-ABBREV".equals(format) || "RDF/XML".equals(format) )){
            doError(response,"RdfFormat was not recognized.",500);
            return;
        }
        
        Map<String, Object> responseObj = new HashMap<String, Object>();
        
        if(vreq.getParameterMap() != null){
        	try{
	    		for(String key: vreq.getParameterMap().keySet()){
	    			if(key.equals(PARAM_DELETION)){
	    				//delete individual with uri
	    				doDeleteUri(vreq, response);
	    			} else if(key.equals(PARAM_UPDATE)){
	    				//update individual value for predicate
	    				doUpdateValue(vreq, response);
	    			}
	    		}
        	} catch(Exception e){
        		log.error(e.getMessage());
        		doError(response,e.getMessage(),SC_BAD_REQUEST);
        		return;
        	}
    	}
        
        //parse RDF 
        Set<Model> additions= null;
        try {
        	String[] newResourceStrings = preProcessNewResources(vreq, response, vreq.getParameterValues("additions"), responseObj);
            additions = parseRdfParam(newResourceStrings,format);
        } catch (Exception e) {
        	log.error(e.getMessage());
            doError(response,"Error reading RDF, set log level to debug for this class to get error messages in the server logs.",SC_BAD_REQUEST);
            return;
        }
                        
        Set<Model> retractions = null;
        try {
            retractions = parseRdfParam(vreq.getParameterValues("retractions"),format);
        } catch (Exception e) {
        	log.error(e.getMessage());
            doError(response,"Error reading RDF, set log level to debug for this class to get error messages in the server logs.",SC_BAD_REQUEST);
            return;
        }

        String editorUri = N3EditUtils.getEditorUri(vreq);           
        try {
			Model a = mergeModels(additions);
			Model r = mergeModels(retractions);

			Model toBeAdded = a.difference(r);
			Model toBeRetracted = r.difference(a);

			Model depResRetractions = DependentResourceDeleteJena
					.getDependentResourceDeleteForChange(toBeAdded,
							toBeRetracted, getWriteModel(vreq));
			toBeRetracted.add(depResRetractions);
        	processChanges(editorUri, getWriteModel(vreq), toBeAdded, toBeRetracted);
        	if(!responseObj.isEmpty()){
        		response.getWriter().write(new JSONObject(responseObj).toString());
        	}
        } catch (Exception e) {
            doError(response,e.getMessage(),SC_INTERNAL_SERVER_ERROR);
        }
        
        //send email to collaborator
		try{
			if(vreq.getParameterMap().containsKey("emailCollaborator")){				
				String emailInfo = vreq.getParameter("emailCollaborator");
				if(emailInfo != null && !emailInfo.isEmpty()){
					new NotifyCollaborators(vreq, getServletContext()).notifyCollaborators();
				}
			}
        } catch(Exception e){
        	log.error("email sent failed:"+String.join(",", vreq.getParameterValues("emailCollaborator")));
        }
    }
    
	/** Package access to allow for unit testing. */
	void processChanges(String editorUri, Model writeModel,
			Model toBeAdded, Model toBeRetracted) throws Exception {
		Lock lock = null;
		log.debug("Model to be retracted is");
		StringWriter sw = new StringWriter();
		toBeRetracted.write(sw, "N3");
		log.debug(sw.toString());
		try {
			lock = writeModel.getLock();
			lock.enterCriticalSection(Lock.WRITE);
			if( writeModel instanceof OntModel){
			    ((OntModel)writeModel).getBaseModel().notifyEvent(new EditEvent(editorUri, true));
			}
			writeModel.add(toBeAdded);
			writeModel.remove(toBeRetracted);
		} catch (Throwable t) {
			throw new Exception("Error while modifying model \n" + t.getMessage());
		} finally {
		    if( writeModel instanceof OntModel){
		        ((OntModel)writeModel).getBaseModel().notifyEvent(new EditEvent(editorUri, false));
		    }
			lock.leaveCriticalSection();
		}
	}

    /**
     * Convert the values from a parameters into RDF models.
     * 
     * Package access to allow for unit testing.
     * 
     * @param parameters - the result of request.getParameters(String)
     * @param format - a valid format string for Jena's Model.read()
     */
    Set<Model> parseRdfParam(String[] parameters, String format) throws Exception{
        Set<Model> models = new HashSet<Model>();               
        for( String param : parameters){
            try{
                StringReader reader = new StringReader(param);
                Model model = com.hp.hpl.jena.rdf.model.ModelFactory.createDefaultModel();          
                model.read(reader, null, format);
                models.add(model);
            }catch(Error ex){
                log.error("Error reading RDF as " + format + " in " + param);
                throw new Exception("Error reading RDF, set log level to debug for this class to get error messages in the sever logs.");
            }
        }
        return models;
    }

    private Model getWriteModel(VitroRequest vreq){
    	return StandardModelSelector.selector.getModel(vreq,getServletContext());  
    }

	/** Package access to allow for unit testing. */
	Model mergeModels(Set<Model> additions) {
		Model a = com.hp.hpl.jena.rdf.model.ModelFactory.createDefaultModel();
		for (Model m : additions) {
			a.add(m);
		}
		return a;
	}
	
	private String[] preProcessNewResources(VitroRequest vreq, HttpServletResponse response, String[] newResource, Map<String, Object> responseObj) throws InsertException, IOException{
		List<String> retVal = new ArrayList<String>();
		if(newResource != null){
			NewURIMaker uriMaker = new NewURIMakerVitro(vreq.getWebappDaoFactory());
			Pattern p = Pattern.compile("\\b"+PREFIX_NEW_RESOURCE+"\\w+\\b");
			Map<String,String> newResourceKeyValue = new HashMap<String, String>();
			for(String item: newResource){
				if(StringUtils.isNotEmpty(item) && item.contains(PREFIX_NEW_RESOURCE)){
					Matcher m = p.matcher(item);
					while(m.find()) {
						if(!newResourceKeyValue.containsKey(m.group(0))){
							newResourceKeyValue.put(m.group(0), uriMaker.getUnusedNewURI(""));
						}
						retVal.add(item.replace(m.group(0), "<"+newResourceKeyValue.get(m.group(0))+">"));
					}
				} else {
					retVal.add(item);
				}
			}
			responseObj.putAll(newResourceKeyValue);
		}
		return retVal.toArray(new String[0]);
	}
	
	@Override
	protected void doError(HttpServletResponse response, String errorMsg,
			int httpstatus) {
		response.setStatus(httpstatus);
		try {
			JSONObject jsonObject = new JSONObject();
			jsonObject.put("status", String.valueOf(httpstatus));
			jsonObject.put("error", String.valueOf(errorMsg));
			response.getWriter().write(jsonObject.toString());
		} catch (IOException e) {
			log.debug("IO exception during output", e);
		} catch (JSONException e) {
			log.debug("JSON exception during output", e);
		}
	}
	
	private void doDeleteUri(VitroRequest vreq, HttpServletResponse response) throws Exception{
		String urisToDelete = vreq.getParameter(PARAM_DELETION);
		if(urisToDelete != null && !urisToDelete.isEmpty()){
			log.debug("prarameter value for "+PARAM_DELETION+" is "+urisToDelete);
			try{
		    	List<String> errorMessage = new ArrayList<String>();
		        if (!StringUtils.isEmpty(urisToDelete)) {
		        	String[] items = urisToDelete.split("\\s*,\\s*");
		        	for(String item: items){
			        	if(!StringUtils.isEmpty(item)){
				        	WebappDaoFactory wdf = vreq.getWebappDaoFactory();
					        IndividualDao idao = wdf.getIndividualDao();
					        int result = idao.deleteIndividual(item);
					        if (result == 1) {
					        	errorMessage.add("Error when delete the individual:"+item);
					        }
			        	}
		        	}
			    }
		    	if(errorMessage.size() > 0){
		    		throw new Exception("Error when delete individual: "+String.join(",", errorMessage));
		    	}
			} catch(Exception e){
				throw new Exception("Error when delete individual");
			}
		}
    }
	
	private void doUpdateValue(VitroRequest vreq, HttpServletResponse response) throws Exception{
		String params = vreq.getParameter(PARAM_UPDATE);
		if(params != null && !params.isEmpty()){
			try{
				JSONObject jsonObject = new JSONObject(params);
				String subjectUri = jsonObject.getString(PARAM_JSON_SUBJECT);
				String predUri = jsonObject.getString(PARAM_JSON_PREDICATE);
				String dataValue = jsonObject.getString(PARAM_JSON_OBJECT);
				
				log.debug("subjectUri: "+subjectUri);
				log.debug("predUri: "+predUri);
				log.debug("dataValue: "+dataValue);
				
				WebappDaoFactory wdf = vreq.getWebappDaoFactory();
		        IndividualDao idao = wdf.getIndividualDao();
				Individual subject = idao.getIndividualByURI(subjectUri);
				
				DataProperty pred = wdf.getDataPropertyDao().getDataPropertyByURI(predUri);
				if(pred!=null){
					wdf.getDataPropertyStatementDao().deleteDataPropertyStatementsForIndividualByDataProperty(subjectUri, predUri);            
					DataPropertyStatement dps = new DataPropertyStatementImpl();
		            dps.setIndividualURI(subjectUri);
		            dps.setDatapropURI(predUri);
		            dps.setData(dataValue);
		            wdf.getDataPropertyStatementDao().insertNewDataPropertyStatement(dps);
				}
				int result = idao.updateIndividual(subject);
				if(result != 0){
					doError(response, "Error when update value", SC_INTERNAL_SERVER_ERROR);
				}
			} catch(JSONException e){
				throw new Exception("Error parse JSON object when update value.");
			} catch(Exception e){
				throw new Exception("Error when updating value.");
			}
		}
	}

    Log log = LogFactory.getLog(PrimitiveRdfEdit.class.getName());
    
}
