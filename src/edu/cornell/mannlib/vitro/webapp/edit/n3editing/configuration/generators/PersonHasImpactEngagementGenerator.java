/* $This file is distributed under the terms of the license in /doc/license.txt$ */

package edu.cornell.mannlib.vitro.webapp.edit.n3editing.configuration.generators;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpSession;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.hp.hpl.jena.query.ResultSet;
import com.hp.hpl.jena.vocabulary.XSD;

import edu.cornell.mannlib.vitro.webapp.beans.Individual;
import edu.cornell.mannlib.vitro.webapp.controller.VitroRequest;
import edu.cornell.mannlib.vitro.webapp.dao.jena.QueryUtils;
import edu.cornell.mannlib.vitro.webapp.edit.n3editing.VTwo.EditConfigurationUtils;
import edu.cornell.mannlib.vitro.webapp.edit.n3editing.VTwo.EditConfigurationVTwo;
import edu.cornell.mannlib.vitro.webapp.edit.n3editing.VTwo.fields.FieldVTwo;
import edu.cornell.mannlib.vitro.webapp.edit.n3editing.configuration.validators.AntiXssValidation;

public class PersonHasImpactEngagementGenerator extends VivoBaseGenerator implements
EditConfigurationGenerator {
    private Log log = LogFactory.getLog(PersonHasImpactEngagementGenerator.class);
    final static String impactEngagementClass = uowImpactEngagement + "ImpactEngagement";
    
    final static String hasImpactEngagementPred = uowvivo + "hasImpactAndEngagement";
    final static String titlePred = uowImpactEngagement + "title";
    final static String descriptionPred = uowImpactEngagement + "description";
    final static String detailOfImpactPred = uowImpactEngagement + "detailOfImpact";
    final static String hasFORCodePred = uowImpactEngagement + "hasFORCodes";
    final static String hasImpactCountryPred = uowImpactEngagement + "hasImpactCountries";
    final static String hasCollaboratorPred = uowImpactEngagement + "hasCollaborators";
    final static String hasProgramPred = uowImpactEngagement + "hasPrograms";
    final static String hasPartnersPred = uowImpactEngagement + "hasPartners";
    final static String hasBeneficiariesPred = uowImpactEngagement + "hasBeneficiaries";
    final static String hasEvidencePred = uowImpactEngagement + "hasEvidence";
    final static String beneficiaryPred = uowImpactEngagement + "beneficiary";
    final static String quantityPred = uowImpactEngagement + "numberOfBeneficiaries";
    final static String evidenceLinkPred = uowImpactEngagement + "linkOfEvidence";
    final static String evidenceLinkNamePred = uowImpactEngagement + "linkName";
    final static String hideFromPublicPred = uowImpactEngagement + "hideFromPublic";
    final static String displayOrderPred = vivoCore + "preferredDisplayOrder";
       
    @Override
    public EditConfigurationVTwo getEditConfiguration(VitroRequest vreq,
            HttpSession session) throws Exception {
        
        EditConfigurationVTwo conf = new EditConfigurationVTwo();
        
        initBasics(conf, vreq);
        initPropertyParameters(vreq, session, conf);
        initObjectPropForm(conf, vreq);  
        
        conf.setTemplate("personHasImpactEngagement.ftl");
        
        conf.setVarNameForSubject("person");
        conf.setVarNameForPredicate("predicate");
        conf.setVarNameForObject("impactEngagement");
        
        conf.setN3Required( Arrays.asList( n3ForNewImpactEngagement ) );

        conf.setN3Optional( Arrays.asList(  n3TitleAssertion, 
        									n3DescriptionAssertion,
        									n3DraftPublicAssertion) );
        
        conf.setLiteralsOnForm(Arrays.asList("title", "description", "draftPublic"));
        
        conf.addNewResource("impactEngagement", DEFAULT_NS_FOR_NEW_RESOURCE);
        
        conf.addSparqlForExistingLiteral("title", titleQuery);
        conf.addSparqlForExistingLiteral("description", descriptionQuery);

        conf.addField( new FieldVTwo().                        
                setName("title")
                .setRangeDatatypeUri( XSD.xstring.toString() ).
                setValidators( list("nonempty") ));
        conf.addField( new FieldVTwo().                        
                setName("description")
                .setRangeDatatypeUri( XSD.xstring.toString() ).
                setValidators( list("nonempty") ));
        conf.addField( new FieldVTwo().                        
                setName("draftPublic")
                .setRangeDatatypeUri( XSD.xboolean.toString() ) );
        addFormSpecificData(conf, vreq);
        conf.addValidator(new AntiXssValidation());
        
        if(!conf.isUpdate()){
        	conf.setCreateAndStayOnEditPage(true);
        	conf.setUrlPatternToReturnTo(EditConfigurationUtils.getFormUrlWithoutContext(vreq));
        }
        prepare(vreq, conf);
        return conf;
    }
    
    /* N3 assertions  */
    final static String n3ForNewImpactEngagement = 
            "@prefix vivo: <" + vivoCore + "> . \n\n" +   
            "?person <" + hasImpactEngagementPred + ">  ?impactEngagement . \n" +
            "?impactEngagement a  <" + impactEngagementClass + "> ";

    final static String n3TitleAssertion  =      
            "?impactEngagement <"+ titlePred +"> ?title .";
    final static String n3DescriptionAssertion  =      
            "?impactEngagement <"+ descriptionPred +"> ?description .";
    final static String n3DraftPublicAssertion  =      
            "?impactEngagement <"+ hideFromPublicPred +"> ?draftPublic .";
    final static String titleQuery  =  
            "SELECT ?existingTitle WHERE {\n"+
            " ?impactEngagement <"+ titlePred +"> ?existingTitle . }";
    final static String descriptionQuery  =  
            "SELECT ?existingDescription WHERE {\n"+
            " ?impactEngagement <"+ descriptionPred +"> ?existingDescription . }";
    
    private String EXTERNAL_ORGANISATION_TYPES =
		" SELECT ?uri (str(?l) as ?label) "
		+" WHERE { "
		+"     ?uri <http://www.w3.org/2000/01/rdf-schema#subClassOf> <http://xmlns.com/foaf/0.1/Organization> . "
		+"     ?uri <http://www.w3.org/2000/01/rdf-schema#label> ?l "
		+" } order by ?l";

    private List<IndividualGeneralInfo> getExternalPartnerTypes(VitroRequest vreq){
        List<IndividualGeneralInfo> retVal = new ArrayList<IndividualGeneralInfo>();
        try {
        	Map<String, String> map = null;
            ResultSet results = QueryUtils.getQueryResults(EXTERNAL_ORGANISATION_TYPES, vreq);
            while (results.hasNext()) {
            	map = QueryUtils.querySolutionToStringValueMap(results.nextSolution());
            	retVal.add(new IndividualGeneralInfo(map.get("uri"), map.get("label")));
            }
        } catch (Exception e) {
            log.error(e, e);
        }
        return retVal;
    }
  	public void addFormSpecificData(EditConfigurationVTwo editConfiguration, VitroRequest vreq) {
  		HashMap<String, Object> formSpecificData = new HashMap<String, Object>();
  		formSpecificData.put("existingFORCodes", getExistingObjects(vreq, hasFORCodePred));
  		formSpecificData.put("existingCountries", getExistingObjects(vreq, hasImpactCountryPred));
  		formSpecificData.put("existingCollaborators", getExistingObjects(vreq, hasCollaboratorPred));
  		formSpecificData.put("existingPrograms", getExistingObjects(vreq, hasProgramPred));
  		formSpecificData.put("existingBeneficiaries", getExistingBeneficiaryInfo(vreq));
  		formSpecificData.put("existingEvidences", getExistingEvidenceInfo(vreq));
  		formSpecificData.put("existingImpactDetail", getExistingImpactDetail(vreq));
  		formSpecificData.put("isHideFromPublic", isHidingFromPublic(vreq));
  		formSpecificData.put("externalPartnerTypes", getExternalPartnerTypes(vreq));
  		formSpecificData.put("existingPartners", getExistingObjects(vreq, hasPartnersPred));
  		
  		editConfiguration.setFormSpecificData(formSpecificData);
  	}
  	private String getExistingImpactDetail(VitroRequest vreq){
  		Individual individual = EditConfigurationUtils.getObjectIndividual(vreq);
  		return individual != null && individual.getDataPropertyStatement(detailOfImpactPred) != null ? individual.getDataPropertyStatement(detailOfImpactPred).getData() : "";
  	}
  	private boolean isHidingFromPublic(VitroRequest vreq){
  		Individual individual = EditConfigurationUtils.getObjectIndividual(vreq);
  		boolean retVal = false;
		if(individual != null && individual.getDataPropertyStatement(hideFromPublicPred) != null && individual.getDataPropertyStatement(hideFromPublicPred).getData().contains("true")){
			retVal = true;
		}
		return retVal;
  	}
    private List<IndividualGeneralInfo> getExistingObjects(VitroRequest vreq, String predicate) {
		Individual individual = EditConfigurationUtils.getObjectIndividual(vreq);
		if(individual != null){
			List<Individual> objs = individual.getRelatedIndividuals(predicate); 
			List<IndividualGeneralInfo> infos = getIndividualGeneralInfo(objs, vreq);
			
			return infos;
		}
		return new ArrayList<PersonHasImpactEngagementGenerator.IndividualGeneralInfo>();
	}
    private List<IndividualGeneralInfo> getIndividualGeneralInfo(List<Individual> individuals, VitroRequest vreq) {
		List<IndividualGeneralInfo> info = new ArrayList<IndividualGeneralInfo>();
		 for ( Individual individual : individuals ) {
			 	String uri =  individual.getURI();
			 	String label = individual.getName();
			 	info.add(new IndividualGeneralInfo(uri, label));
		 }
		 sortGeneralInfo(info);
		 return info;
	}
    
    private List<BeneficiaryInfo> getExistingBeneficiaryInfo(VitroRequest vreq){
    	Individual individual = EditConfigurationUtils.getObjectIndividual(vreq);
		if(individual != null){
			List<Individual> objs = individual.getRelatedIndividuals(hasBeneficiariesPred); 
			List<BeneficiaryInfo> infos = getBeneficiaryInfo(objs, vreq);
			return infos;
		}
		return new ArrayList<PersonHasImpactEngagementGenerator.BeneficiaryInfo>();
    }
    private List<BeneficiaryInfo> getBeneficiaryInfo(List<Individual> individuals, VitroRequest vreq){
    	List<BeneficiaryInfo> info = new ArrayList<BeneficiaryInfo>();
    	if(individuals != null){
	    	for(Individual individual: individuals){
	    		String beneficiay = individual.getDataPropertyStatement(beneficiaryPred) != null ? individual.getDataPropertyStatement(beneficiaryPred).getData() : "";
	    		String quantity = individual.getDataPropertyStatement(quantityPred) != null ? individual.getDataPropertyStatement(quantityPred).getData() : "";
	    		String description = individual.getDataPropertyStatement(descriptionPred) != null ? individual.getDataPropertyStatement(descriptionPred).getData() : "";
	    		Integer order = individual.getDataPropertyStatement(displayOrderPred) != null ? Integer.valueOf(individual.getDataPropertyStatement(displayOrderPred).getData()) : -1;
	    		info.add(new BeneficiaryInfo(individual.getURI(), beneficiay, quantity, description, order));
	    	}
	    	sortBeneficiaryInfo(info);
    	}
    	return info;
    }
    private List<EvidenceInfo> getExistingEvidenceInfo(VitroRequest vreq){
    	Individual individual = EditConfigurationUtils.getObjectIndividual(vreq);
		if(individual != null){
			List<Individual> objs = individual.getRelatedIndividuals(hasEvidencePred); 
			List<EvidenceInfo> infos = getEvidenceInfo(objs, vreq);
			return infos;
		}
		return new ArrayList<PersonHasImpactEngagementGenerator.EvidenceInfo>();
    }
    private List<EvidenceInfo> getEvidenceInfo(List<Individual> individuals, VitroRequest vreq){
    	List<EvidenceInfo> info = new ArrayList<EvidenceInfo>();
    	if(individuals != null){
    		for(Individual individual: individuals){
    			String name = individual.getDataPropertyStatement(evidenceLinkNamePred) != null ? individual.getDataPropertyStatement(evidenceLinkNamePred).getData() : "";
    			String link = individual.getDataPropertyStatement(evidenceLinkPred) != null ? individual.getDataPropertyStatement(evidenceLinkPred).getData() : "";
    			String description = individual.getDataPropertyStatement(descriptionPred) != null ? individual.getDataPropertyStatement(descriptionPred).getData() : "";
    			info.add(new EvidenceInfo(individual.getURI(), name, link, description));
    		}
    		sortEvidenceInfo(info);
    	}
    	return info;
    }
    private void sortGeneralInfo(List<IndividualGeneralInfo> infos) {
	    Collections.sort(infos, new IndividualGeneralInfoComparator());
	}
    private class IndividualGeneralInfoComparator implements Comparator<IndividualGeneralInfo>{
		public int compare(IndividualGeneralInfo info1, IndividualGeneralInfo info2) {
	    	String info1Label = info1.getLabel().toLowerCase();
	    	String info2Label = info2.getLabel().toLowerCase();
	    	return info1Label.compareTo(info2Label);
	    }
	}
    private void sortBeneficiaryInfo(List<BeneficiaryInfo> infos) {
	    Collections.sort(infos, new BeneficiaryInfoComparator());
	}
    private class BeneficiaryInfoComparator implements Comparator<BeneficiaryInfo>{
		public int compare(BeneficiaryInfo info1, BeneficiaryInfo info2) {
	    	Integer info1Label = info1.getDisplayOrder();
	    	Integer info2Label = info2.getDisplayOrder();
    		return info1Label.compareTo(info2Label);
	    }
	}
    private void sortEvidenceInfo(List<EvidenceInfo> infos) {
	    Collections.sort(infos, new EvidenceInfoComparator());
	}
    private class EvidenceInfoComparator implements Comparator<EvidenceInfo>{
		public int compare(EvidenceInfo info1, EvidenceInfo info2) {
	    	String info1Label = info1.getLink().toLowerCase();
	    	String info2Label = info2.getLink().toLowerCase();
	    	return info1Label.compareTo(info2Label);
	    }
	}
    public class IndividualGeneralInfo{
    	private String uri;
    	private String label;
    	public IndividualGeneralInfo(String uri, String label){
    		this.uri = uri;
    		this.label = label;
    	}
    	public String getUri(){
    		return this.uri;
    	}
    	public String getLabel(){
    		return this.label;
    	}
    }
    public class BeneficiaryInfo{
    	private String uri;
    	private String beneficiary;
    	private String quantification;
    	private String description;
    	private int displayOrder;
    	public BeneficiaryInfo(String uri, String beneficiary, String quantification, String description, Integer displayOrder){
    		this.description = description;
    		this.beneficiary = beneficiary;
    		this.quantification = quantification;
    		this.uri = uri;
    		this.displayOrder = displayOrder;
    	}
    	public String getUri(){
    		return this.uri;
    	}
    	public String getDescription(){
    		return this.description;
    	}
    	public String getQuantification(){
    		return this.quantification;
    	}
    	public String getBeneficiary(){
    		return this.beneficiary;
    	}
    	public Integer getDisplayOrder(){
    		return this.displayOrder;
    	}
    }
    public class EvidenceInfo{
    	private String uri;
    	private String name;
    	private String link;
    	private String description;
    	public EvidenceInfo(String uri, String name, String link, String description){
    		this.description = description;
    		this.link = link;
    		this.name = name;
    		this.uri = uri;
    	}
    	public String getUri(){
    		return this.uri;
    	}
    	public String getName(){
    		return this.name;
    	}
    	public String getDescription(){
    		return this.description;
    	}
    	public String getLink(){
    		return this.link;
    	}
    }

}
