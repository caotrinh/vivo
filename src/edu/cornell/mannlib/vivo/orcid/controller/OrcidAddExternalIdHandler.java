/* $This file is distributed under the terms of the license in LICENSE$ */

package edu.cornell.mannlib.vivo.orcid.controller;

import static edu.cornell.mannlib.orcidclient.actions.ApiAction.ADD_EXTERNAL_ID;
import static edu.cornell.mannlib.orcidclient.beans.Visibility.PUBLIC;
import static edu.cornell.mannlib.vivo.orcid.controller.OrcidConfirmationState.Progress.ADDED_ID;
import static edu.cornell.mannlib.vivo.orcid.controller.OrcidConfirmationState.Progress.DENIED_ID;
import static edu.cornell.mannlib.vivo.orcid.controller.OrcidConfirmationState.Progress.FAILED_ID;

import java.net.MalformedURLException;
import java.net.URL;

import edu.cornell.mannlib.orcidclient.model.OrcidProfile;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import edu.cornell.mannlib.orcidclient.OrcidClientException;
import edu.cornell.mannlib.orcidclient.auth.AuthorizationStatus;
import edu.cornell.mannlib.orcidclient.beans.ExternalId;
import edu.cornell.mannlib.vitro.webapp.beans.Individual;
import edu.cornell.mannlib.vitro.webapp.controller.VitroRequest;
import edu.cornell.mannlib.vitro.webapp.controller.freemarker.responsevalues.ResponseValues;

/**
 * We should now be logged in to ORCID and authorized to add an external ID.
 */
public class OrcidAddExternalIdHandler extends OrcidAbstractHandler {
	private static final Log log = LogFactory
			.getLog(OrcidAddExternalIdHandler.class);
	private static final String RDF_LABEL_PRED = "http://www.w3.org/2000/01/rdf-schema#label";

	private AuthorizationStatus status;
	private OrcidProfile profile;

	protected OrcidAddExternalIdHandler(VitroRequest vreq) {
		super(vreq);
	}

	public ResponseValues exec() throws OrcidClientException {
		status = auth.getAuthorizationStatus(ADD_EXTERNAL_ID);
		if (status.isSuccess()) {
			addVivoId();
			return showConfirmationPage(ADDED_ID, profile);
		} else if (status.isDenied()) {
			return showConfirmationPage(DENIED_ID);
		} else {
			return showConfirmationPage(FAILED_ID);
		}
	}

	private void addVivoId() throws OrcidClientException {
		Individual individual = findIndividual();
		if(individual != null){
			String urlToOrcid = null;
			String externalLabel = individual.getDataPropertyStatement(RDF_LABEL_PRED) != null ? individual.getDataPropertyStatement(RDF_LABEL_PRED).getData() : individual.getLocalName();
			try{
				URL context = new URL(this.vreq.getRequestURL().toString());
				URL url = new URL(context, individual.getLabel());
				urlToOrcid = url.toExternalForm().replace("/orcid/", "/individual/");
			} catch (MalformedURLException e) {
				log.error(e.getMessage(), e);
			}
			
			if(urlToOrcid == null || urlToOrcid.isEmpty()){
				urlToOrcid = individual.getURI();
			}
			
			ExternalId externalId = new ExternalId().setCommonName("UOW Scholars")
					.setReference(externalLabel)
					.setUrl(urlToOrcid).setVisibility(PUBLIC);
	
			log.debug("Adding external VIVO ID");
			profile = manager.createAddExternalIdAction().execute(externalId, status.getAccessToken());
		}
	}

}
