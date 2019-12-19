package edu.cornell.mannlib.vitro.webapp.controller.edit;

import static javax.mail.Message.RecipientType.TO;

import java.net.MalformedURLException;
import java.net.URL;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.ServletContext;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.json.JSONObject;

import edu.cornell.mannlib.vitro.webapp.beans.Individual;
import edu.cornell.mannlib.vitro.webapp.config.ConfigurationProperties;
import edu.cornell.mannlib.vitro.webapp.controller.VitroRequest;
import edu.cornell.mannlib.vitro.webapp.controller.authenticate.Authenticator;
import edu.cornell.mannlib.vitro.webapp.email.FreemarkerEmailFactory;
import edu.cornell.mannlib.vitro.webapp.email.FreemarkerEmailMessage;

public class NotifyCollaborators {

	private static final String EMAIL_TEST_ENABLE = "email.test.replyTo";
	private static final String RDF_LABEL_PRED = "http://www.w3.org/2000/01/rdf-schema#label";
	private static final String IMPACT_TITLE_PRED = "http://uowvivo.uow.edu.au/ontology/uowimpact#title";
	private static final String PRIMARY_EMAIL_PRED = "http://vivoweb.org/ontology/core#primaryEmail";
	private static final String NETWORK_ID_PRED = "http://uowvivo.uow.edu.au/ontology/uowvivo#networkId";
	private static final String PARAM_NAME_EMAIL = "emailCollaborator";
	private static final String PARAM_VALUE_FROM = "who";
	private static final String PARAM_VALUE_IMPACT = "impactUri";
	private static final String PARAM_VALUE_COLLABORATOR = "collaborator";
	private static final String EMAIL_SUBJECT = "UOW Scholars: Collaborator on Impact Story";
	private static final String EMAIL_TEMPLATE = "notify_collaborator_impact_creation.ftl";
	private static final String EMAIL_BODY_UNKNOWN = "unknown";
	private static final String SUFFIX_UOW_EMAIL = "@uow.edu.au";
	
	private ServletContext servletContext;
	private VitroRequest vitroRequest;
	
	public NotifyCollaborators(VitroRequest vreq, ServletContext context) {
		this.servletContext = context;
		this.vitroRequest = vreq;
	}
	
	protected boolean isEmailEnabled(VitroRequest vreq) {
		return FreemarkerEmailFactory.isConfigured(vreq);
	}
	
	protected String testEmailEnabled(VitroRequest vreq) {
		ConfigurationProperties config = ConfigurationProperties.getBean(servletContext);
		return config.getProperty(EMAIL_TEST_ENABLE, "");
	}
	
	public void notifyCollaborators() throws Exception{
		if(isEmailEnabled(vitroRequest)){
			try{
				JSONObject emailInfo = new JSONObject(vitroRequest.getParameter(PARAM_NAME_EMAIL));
				if(emailInfo != null){
					Individual creator = getIndividualOfUri(emailInfo.getString(PARAM_VALUE_FROM));
					Individual impactUri = getIndividualOfUri(emailInfo.getString(PARAM_VALUE_IMPACT));
					Individual emailTo = getIndividualOfUri(emailInfo.getString(PARAM_VALUE_COLLABORATOR));
	
					if(testEmailEnabled(vitroRequest).isEmpty()){
						log.info("Impact Story Notification: Sending to collaborators");
						sendEmailToCollaborators(creator, impactUri, emailTo);
					} else {
						log.info("Impact Story Notification: Test Mode");
						String[] testEmailAddress = testEmailEnabled(vitroRequest).split("\\s*,\\s*");
						sendEmailToAdministrators(creator, impactUri, emailTo, testEmailAddress);
					}
				}
			} catch(Exception e){
				throw e;
			}
		} else {
			log.warn("Impact Story Notification: SMTP is not enabled for sending emails");
		}
	}
	
	private void sendEmailToCollaborators(Individual creator, Individual impact, Individual collaborator){
		String emailAddress = getEmailAddressForIndividual(collaborator);
		if(emailAddress != null && !emailAddress.isEmpty() && Authenticator.isValidEmailAddress(emailAddress)){
			log.info("Impact Story Notification: Sending email to: "+emailAddress);
			log.debug("Impact Story Notification: Email Subject: "+EMAIL_SUBJECT);
			log.debug("Impact Story Notification: Body: "+generateEmailBody(creator, impact, collaborator));
			sendEmail(
					new String[]{emailAddress},
					EMAIL_SUBJECT,
					generateEmailBody(creator, impact, collaborator));
	
		}
	}
	
	private void sendEmailToAdministrators(Individual creator, Individual impact, Individual collaborator, String[] adminEmails){
		sendEmail(
				adminEmails,
				EMAIL_SUBJECT,
				generateEmailBody(creator, impact, collaborator));
	}
	
	private Map<String, Object> generateEmailBody(Individual creator, Individual impact, Individual collaborator){
		Map<String, Object> body = new HashMap<String, Object>();
		body.put("subject", EMAIL_SUBJECT);
		body.put("impactTitle", impact != null && impact.getDataPropertyStatement(IMPACT_TITLE_PRED) != null ? impact.getDataPropertyStatement(IMPACT_TITLE_PRED).getData() : EMAIL_BODY_UNKNOWN);
		
		body.put("creatorLabel", creator != null && creator.getDataPropertyStatement(RDF_LABEL_PRED) != null ? creator.getDataPropertyStatement(RDF_LABEL_PRED).getData() : EMAIL_BODY_UNKNOWN);
		body.put("creatorUri", getRequestUrlForIndividual(creator));
		
		body.put("collaboratorLabel", collaborator != null && collaborator.getDataPropertyStatement(RDF_LABEL_PRED) != null ? collaborator.getDataPropertyStatement(RDF_LABEL_PRED).getData() : EMAIL_BODY_UNKNOWN);
		body.put("collaboratorUri", getRequestUrlForIndividual(collaborator));
		return body;
	}
	
	private String getRequestUrlForIndividual(Individual ind){
		String retVal = "";
		if(ind != null){
			try{
				URL context = new URL(vitroRequest.getRequestURL().toString());
				URL url = new URL(context, ind.getLabel());
				retVal = url.toExternalForm().replace("/edit/", "/display/");
			} catch (MalformedURLException e) {
				log.error(e.getMessage(), e);
				retVal = ind.getURI();
			}
		}
		return retVal;
	}
	
	private String getEmailAddressForIndividual(Individual ind){
		String retVal = null;
		if(ind != null){
			retVal = ind.getDataPropertyStatement(PRIMARY_EMAIL_PRED) != null ? ind.getDataPropertyStatement(PRIMARY_EMAIL_PRED).getData() : "";
			if(retVal == null || retVal.isEmpty()){
				retVal = ind.getDataPropertyStatement(NETWORK_ID_PRED) != null ? ind.getDataPropertyStatement(NETWORK_ID_PRED).getData() : "";
				if(retVal != null && !retVal.isEmpty()){
					retVal += SUFFIX_UOW_EMAIL;
					log.debug("use networkId as email");
				}
			}
		}
		log.debug("Impact Story Notification: email address is " + retVal);
		return retVal;
	}
	
	private void sendEmail(String[] receiver, String subject, Map<String, Object> body){
		FreemarkerEmailMessage email = FreemarkerEmailFactory.createNewMessage(vitroRequest);
		for(String address: receiver){
			email.addRecipient(TO, address);
			log.info("Impact Story Notification: sending email to: " + address);
		}
		email.setSubject(subject);
		email.setTemplate(EMAIL_TEMPLATE);
		email.setBodyMap(body);
		email.processTemplate();
		email.send();
	}
	
	private Individual getIndividualOfUri(String param){
		Individual retVal = null;
		if(param != null && !param.isEmpty()){
			retVal = vitroRequest.getUnfilteredWebappDaoFactory().getIndividualDao().getIndividualByURI(param);
		}
		return retVal;
	}

    Log log = LogFactory.getLog(NotifyCollaborators.class.getName());
}
