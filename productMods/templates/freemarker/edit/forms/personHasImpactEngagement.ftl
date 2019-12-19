<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- this is in request.subject.name -->

<#-- leaving this edit/add mode code in for reference in case we decide we need it -->

<#import "lib-vivo-form.ftl" as lvf>

<#--Retrieve certain edit configuration information-->
<#if editConfiguration.objectUri?has_content>
<#assign editMode = "edit">
<#else>
<#assign editMode = "add">
</#if>
<#assign flagClearLabelForExisting = "flagClearLabelForExisting" />
<#assign blankSentinel = "" />

<#assign rdfLabelPred = "http://www.w3.org/2000/01/rdf-schema#label"/>
<#assign titlePred = "http://uowvivo.uow.edu.au/ontology/uowimpact#title"/>
<#assign detailOfImpactPred = "http://uowvivo.uow.edu.au/ontology/uowimpact#detailOfImpact"/>
<#assign beneficiaryPred = "http://uowvivo.uow.edu.au/ontology/uowimpact#beneficiary"/>
<#assign descriptionPred = "http://uowvivo.uow.edu.au/ontology/uowimpact#description"/>
<#assign quantityPred = "http://uowvivo.uow.edu.au/ontology/uowimpact#numberOfBeneficiaries"/>
<#assign evidenceLinkNamePred = "http://uowvivo.uow.edu.au/ontology/uowimpact#linkName"/>
<#assign evidenceLinkPred = "http://uowvivo.uow.edu.au/ontology/uowimpact#linkOfEvidence"/>
<#assign evidenceTypePred = "http://uowvivo.uow.edu.au/ontology/uowimpact#Evidence"/>
<#assign beneficiaryTypePred = "http://uowvivo.uow.edu.au/ontology/uowimpact#Beneficiary"/>
<#assign displayOrderPred = "http://vivoweb.org/ontology/core#preferredDisplayOrder"/>

<#assign hasFORCodePred = "http://uowvivo.uow.edu.au/ontology/uowimpact#hasFORCodes"/>
<#assign hasCountryPred = "http://uowvivo.uow.edu.au/ontology/uowimpact#hasImpactCountries"/>
<#assign hasCollaboratorPred = "http://uowvivo.uow.edu.au/ontology/uowimpact#hasCollaborators"/>
<#assign hasProgramPred = "http://uowvivo.uow.edu.au/ontology/uowimpact#hasPrograms"/>
<#assign hasPartnerPred = "http://uowvivo.uow.edu.au/ontology/uowimpact#hasPartners"/>
<#assign hasBeneficiaryPred = "http://uowvivo.uow.edu.au/ontology/uowimpact#hasBeneficiaries"/>
<#assign hasEvidencePred = "http://uowvivo.uow.edu.au/ontology/uowimpact#hasEvidence"/>
<#assign existingFORCodes = editConfiguration.pageData.existingFORCodes/>
<#assign existingCountries = editConfiguration.pageData.existingCountries/>
<#assign existingCollaborators = editConfiguration.pageData.existingCollaborators/>
<#assign existingPrograms = editConfiguration.pageData.existingPrograms/>
<#assign existingBeneficiaries = editConfiguration.pageData.existingBeneficiaries/>
<#assign existingEvidences = editConfiguration.pageData.existingEvidences/>
<#assign existingPartners = editConfiguration.pageData.existingPartners/>
<#assign isHideFromPublic = editConfiguration.pageData.isHideFromPublic/>
<#assign existingImpactDetail = editConfiguration.pageData.existingImpactDetail/>
<#assign externalPartnerTypes = editConfiguration.pageData.externalPartnerTypes/>
<#assign titleValue = lvf.getFormFieldValue(editSubmission, editConfiguration, "title") />
<#assign descriptionValue = lvf.getFormFieldValue(editSubmission, editConfiguration, "description") />
<#if editConfiguration.objectUri??>
<#assign objectUri=editConfiguration.objectUri />
<#else>
<#assign objectUri="" />
</#if>
<#if isHideFromPublic>
<#assign initHideFromPublic = "true" />
<#else>
<#assign initHideFromPublic = "false" />
</#if>
<#--If edit submission exists, then retrieve validation errors if they exist-->
<#if editSubmission?has_content && editSubmission.submissionExists = true && editSubmission.validationErrors?has_content>
  <#assign submissionErrors = editSubmission.validationErrors/>
</#if>

<#if editMode == "edit">    
  <#assign titleVerb="${i18n().edit_capitalized}">        
  <#assign submitButtonText="${titleVerb}" + " ${i18n().impact_engagement}">
  <#assign disabledVal="disabled">
<#else>
  <#assign titleVerb="${i18n().create_capitalized}">        
  <#assign submitButtonText="${titleVerb}" + " ${i18n().impact_engagement}">
  <#assign disabledVal=""/>
</#if>

<#assign requiredHint = "<span class='requiredHint'> *</span>" />

<div id="manage-records-for" class="panel panel-default">
  <div class="panel-heading">
    ${titleVerb}&nbsp;${i18n().impact_engagement}
  </div>
  <div class="panel-body">

    <#--Display error messages if any-->
    <#if submissionErrors?has_content>
        <#--Checking if any required fields are empty-->
        <#if lvf.submissionErrorExists(editSubmission, "description")>
          <script>
            $(document).ready(function(){
              scholarsAutoComplete.showMessage(NOTIFY_TYPE_ERROR, '${i18n().impact_description_null}');
            });
          </script>
        </#if>
        <#if lvf.submissionErrorExists(editSubmission, "title")>
          <script>
            $(document).ready(function(){
              scholarsAutoComplete.showMessage(NOTIFY_TYPE_ERROR, '${i18n().impact_title_null}');
            });
          </script>
        </#if> 
    </#if>
    
    <@lvf.unsupportedBrowser urls.base />

    <#if editMode == "edit">
      <section role="region" class="impactDisplay">
        <div class="impact-note">
          <i class="fa fa-info-circle"></i>&nbsp;Please refer to the <a href="https://intranet.uow.edu.au/content/groups/public/@web/@raid/documents/doc/uow236690.pdf" target="_blank">Impact Story Quick-Start Guide</a> for further information.
        </div>
        <hr>
        <b>Visibility Mode</b>&nbsp;&nbsp;<input type="checkbox" name="hideFromPublic" data-size = "small" data-animate = "true" data-on-text = "Draft" data-off-text="Public" data-on-color="default" data-off-color="primary" id="hideFromPublic">
        <p >
            <b>Public</b>: Visible to everyone
            <br>
            <b>Draft</b>: Visible only to the collaborators associated with this Impact Story (recommended when developing content)
            <br>
            <i>Note</i>: enabling draft mode affects visibility on all associated collaborator profiles also
        </p>
        <hr>
        <div class="form-group">
          <label for="title" class="control-label col-ms-12 requiredField impact-label">${requiredHint} Title</label>
          <div class="col-ms-12 impact-title" data-predUri="${titlePred}" data-uri="${objectUri}">
            <div class="editableTextField">${titleValue}</div>
            <a title="Edit Title" class="editTextField btn btn-primary outline"><i class="fa fa-pencil-square-o fa-fw" ></i> Edit</a> <span class="hidden tiny-editor-controls"><a title="Save" class="btn btn-success outline save-btn"><i class="fa fa-floppy-o fa-fw"></i> Save</a> <a title="Cancel" class="btn btn-warning outline cancel-btn"><i class="fa fa-ban fa-fw"></i> Cancel</a></span>
          </div>
        </div>
        <div class="form-group stripes">
          <label for="description" class="control-label requiredField impact-label">${requiredHint} Impact Summary <small>(Max: 500 words)</small> <i data-toggle="tooltip" data-placement="top" title="" class="fa fa-question-circle tooltips-btn" data-original-title="What was the impact (outside of academia)?"></i></label>
          <div class="col-ms-12" data-predUri="${descriptionPred}" data-uri="${objectUri}">
            <div class="richTextArea">${descriptionValue}</div>
            <a title="Edit Impact Summary" class="editRichTextarea btn btn-primary outline"><i class="fa fa-pencil-square-o fa-fw" ></i> Edit</a> <span class="hidden tiny-editor-controls"><a title="Save" class="btn btn-success outline save-btn"><i class="fa fa-floppy-o fa-fw"></i> Save</a> <a title="Cancel" class="btn btn-warning outline cancel-btn"><i class="fa fa-ban fa-fw"></i> Cancel</a></span>
          </div>
        </div>
        <div class="form-group stripes">
          <label for="detailOfImpact" class="control-label impact-label">Detail of Impact <small>(Max: 1000 words)</small> <i data-toggle="tooltip" data-placement="top" title="" class="fa fa-question-circle tooltips-btn" data-original-title="What was the pathway to impact? Which activities translated the research to real-world impacts? Which knowledge translation activities were undertaken?"></i></label>
          <div class="col-ms-12" data-predUri="${detailOfImpactPred}" data-uri="${objectUri}">
            <div class="richTextArea">${existingImpactDetail}</div>
            <a title="Edit Detail of Impact" class="editRichTextarea  btn btn-primary outline"><i class="fa fa-pencil-square-o fa-fw" ></i> Edit</a> <span class="hidden tiny-editor-controls"><a title="Save" class="btn btn-success outline save-btn"><i class="fa fa-floppy-o fa-fw"></i> Save</a> <a title="Cancel" class="btn btn-warning outline cancel-btn"><i class="fa fa-ban fa-fw"></i> Cancel</a></span>
          </div>
        </div>
        <div class="form-group">
        <label for="forCode" class="impact-label">${requiredHint} Field of Research <i data-toggle="tooltip" data-placement="top" title="" class="fa fa-question-circle tooltips-btn" data-original-title="Which Fields of Research describe the research that led to the impact?"></i></label>
        <ul id="forCodeList" role="list">
          <#if (existingFORCodes?size > 0)>
            <#list existingFORCodes as forCode>
              <li role="listitem" class="targetToRemoveAfterDelete">
                <a class="glyphicon glyphicon-trash removeTriple" data-uri="${forCode.uri}" data-subjectUri="${objectUri}" data-predicateUri="${hasFORCodePred}"></a>
                <span>${forCode.label}</span>
              </li>
            </#list>
          </#if>
        </ul>
        <input class="autoCompleteInputField form-control input-md" type="text" id="forCode" acGroupName="forCode" acDisplayTarget="#forCodeList" acPredicateUri="${hasFORCodePred}" name="forCodeLabel">
        </div>
        <div class="form-group stripes">
        <label for="countries" class="control-label impact-label">Countries / Regions <i data-toggle="tooltip" data-placement="top" title="" class="fa fa-question-circle tooltips-btn" data-original-title="Where did the impact occur?"></i></label>
        <ul id="countryList" role="list">
          <#if (existingCountries?size > 0)>
            <#list existingCountries as country>
              <li role="listitem" class="targetToRemoveAfterDelete">
                <a class="glyphicon glyphicon-trash removeTriple" data-uri="${country.uri}" data-subjectUri="${objectUri}" data-predicateUri="${hasCountryPred}"></a>
                <span>${country.label}</span>
              </li>
            </#list>
          </#if>
        </ul>
        <input class="autoCompleteInputField form-control input-md" type="text" id="country" acGroupName="country" acDisplayTarget="#countryList" acPredicateUri="${hasCountryPred}" name="countryLabel">
        </div>
        <div class="panel panel-default">
        <div class="panel-heading">
            <h3>Beneficiaries</h3>
        </div>
        <div class="panel-body">
          <div class="form-group">
            <div class="col-xs-12">
              <table class="table table-hover table-striped">
                <thead>
                  <tr>
                    <th>Beneficiary <i data-toggle="tooltip" data-placement="top" title="" class="fa fa-question-circle tooltips-btn" data-original-title="Who was impacted by the research? (E.g. patients, practitioners, school teachers, industry partners, government departments, non-profit organisations, festival attendees)"></i></th>
                    <th>Quantification <i data-toggle="tooltip" data-placement="top" title="" class="fa fa-question-circle tooltips-btn" data-original-title="How would you quantify the benefit? How many of each type of beneficiary were impacted? How much money was saved? (e.g. 1000 patients, 10 school districts, 5000 event attendees, 1000000 dollars in savings) Please specify the unit used in the 'Description of Impact' field"></i></th>
                    <th>Description of Impact <small>(Max: 500 Words)</small> <i data-toggle="tooltip" data-placement="top" title="" class="fa fa-question-circle tooltips-btn" data-original-title="What is the unit for the quantification of benefit? Any qualitative description of the significance of the benefit can be added here."></i></th>
                    <th>Action</th>
                  </tr>
                </thead>
                <tbody id="beneficiary" class="controls tableColumnExtendable">
                  <#if (existingBeneficiaries?size > 0)>
                    <#list existingBeneficiaries as benefit>
                      <tr class="entry targetToRemoveAfterDelete" data-uri="${benefit.uri}">
                        <td data-predUri="${beneficiaryPred}">
                          <div class="editableTextField">${benefit.beneficiary}</div>
                          <a title="Edit Beneficiary" class="editTextField btn btn-primary outline btn-sm"><i class="fa fa-pencil-square-o fa-fw" ></i></a> <span class="hidden tiny-editor-controls"><a title="Save" class="btn btn-success outline save-btn"><i class="fa fa-floppy-o fa-fw"></i></a> <a title="Cancel" class="btn btn-warning outline cancel-btn"><i class="fa fa-ban fa-fw"></i></a></span>
                        </td>

                        <td data-predUri="${quantityPred}">
                          <div class="editableTextField" data-rdf-type="http://www.w3.org/2001/XMLSchema#int">${benefit.quantification}</div>
                          <a title="Edit Quantification" class="editTextField btn btn-primary outline btn-sm"><i class="fa fa-pencil-square-o fa-fw" ></i></a> <span class="hidden tiny-editor-controls"><a title="Save" class="btn btn-success outline save-btn"><i class="fa fa-floppy-o fa-fw"></i></a> <a title="Cancel" class="btn btn-warning outline cancel-btn"><i class="fa fa-ban fa-fw"></i></a></span>
                        <td data-predUri="${descriptionPred}">
                          <div class="richTextArea">${benefit.description}</div>
                          <a title="Edit Description" class="editRichTextarea btn btn-primary outline btn-sm"><i class="fa fa-pencil-square-o fa-fw" ></i></a> <span class="hidden tiny-editor-controls"><a title="Save" class="btn btn-success outline save-btn"><i class="fa fa-floppy-o fa-fw"></i></a> <a title="Cancel" class="btn btn-warning outline cancel-btn"><i class="fa fa-ban fa-fw"></i></a></span>
                        </td>

                        <td>
                          <button title="Delete Beneficiary Entry" class="btn btn-remove removeTripleAndIndividual btn-danger outline" type="button"  data-uri="${benefit.uri}" data-subjectUri="${objectUri}" data-predicateUri="${hasBeneficiaryPred}">
                            <i class="fa fa-trash fa-fw" aria-hidden="true"></i> Delete
                          </button>
                        </td>
                        <td class="beneficiaryDisplayOrder" data-predUri="${displayOrderPred}"><span style="display:none;" data-original="${benefit.displayOrder}"></span></td>
                      </tr>
                    </#list>
                  </#if>
                  <tr class="entry targetToRemoveAfterDelete" data-uri>
                    <td class="col-md-3" data-predUri="${beneficiaryPred}">
                      <input class="form-control" type="text" />
                    </td>
                    <td class="col-md-2" data-predUri="${quantityPred}">
                      <input class="form-control" type="text" />
                    </td>
                    <td class="col-md-7" data-predUri="${descriptionPred}">
                      <textarea class="form-control input-md" id="wysiTextArea_beneficiary" rows="6" style="width:100%;"></textarea>
                    </td>
                    <td>
                        <button title="Add Beneficiary Details" class="btn btn-success btn-add createBeneficiary outline" type="button"  data-subjectUri="${objectUri}" data-predicateUri="${hasBeneficiaryPred}" data-uri>
                            <i class="fa fa-floppy-o fa-fw" aria-hidden="true"></i> Save
                        </button>
                    </td>
                    <td class="beneficiaryDisplayOrder" data-predUri="${displayOrderPred}"></td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
        </div>
        <div class="panel panel-default">
        <div class="panel-heading">
            <h3>External Partners</h3>
        </div>
        <div class="panel-body">
          <div class="form-group">
            <div class="col-xs-12">
              <label for="externalPartners" class="control-label">External Partners <i data-toggle="tooltip" data-placement="top" title="" class="fa fa-question-circle tooltips-btn" data-original-title="Which External Organisations were involved in the research?"></i></label>
              <ul id="partnerList" role="list">
                <#if (existingPartners?size > 0)>
                  <#list existingPartners as partner>
                    <li role="listitem" class="targetToRemoveAfterDelete">
                      <a class="glyphicon glyphicon-trash removeTriple" data-uri="${partner.uri}" data-subjectUri="${objectUri}" data-predicateUri="${hasPartnerPred}" title="Delete External Partner"></a>
                      <span>${partner.label}</span>
                    </li>
                  </#list>
                </#if>
              </ul>
              <hr/>
              <div class="input-group col-xs-12" style="margin-bottom:8px;">
                <label>Organisation Type</label>
                <br/>
                <select id="typeSelector" name="partnerTypeSelection">
                  <option value="http://xmlns.com/foaf/0.1/Organization" selected> Select type </option>
                  <#list externalPartnerTypes as type>
                    <option value="${type.uri}">${type.label}</option>
                  </#list>
                </select>
              </div>
              <div class="input-group col-xs-12" style="margin-bottom:8px;">
                <input class="autoCompleteInputField form-control input-md" type="text" id="partners" acGroupName="partner" acDisplayTarget="#partnerList" acPredicateUri="${hasPartnerPred}" name="partners" valueToPredicate="${rdfLabelPred}">
                <span class="input-group-btn">
                  <button data-input-id="partners" class="btn btn-success btn-add outline-group" type="button" title="Add External Partner">
                      <i class="fa fa-plus" aria-hidden="true"></i> Add New
                  </button>
                </span>
              </div>
                <small><i class="fa fa-info-circle" aria-hidden="true"></i> Select an organisation type from the drop down and then start typing the name of the external partner: select from the auto-complete list or click <i>Add New</i> if external partner is not listed</small>
              </div>
            </div>
          </div>
        </div>
        <div class="panel panel-default">
        <div class="panel-heading">
          <h3>Evidence of Impact</h3>
        </div>
        <div class="panel-body">
          <div class="form-group">
            <div class="col-xs-12">
              <table class="table table-hover table-striped">
                <thead>
                  <tr>
                    <th class="col-xs-3">Display Name <i data-toggle="tooltip" data-placement="top" title="" class="fa fa-question-circle tooltips-btn" data-original-title="The name of the link that will be displayed to the public"></i></th>
                    <th>Link <i data-toggle="tooltip" data-placement="top" title="" class="fa fa-question-circle tooltips-btn" data-original-title="Please provide links to content demonstrating the impact (e.g. media articles, videos, policy documents, government white papers, economic valuations)"></i></th>
                    <th>Description <small>(Max: 500 Words)</small> <i data-toggle="tooltip" data-placement="top" title="" class="fa fa-question-circle tooltips-btn" data-original-title="How does the linked content demonstrate the impact? (E.g. research referenced in policy document, behaviour change demonstrated in video testimonial)"></i></th>
                    <th>Action</th>
                  </tr>
                </thead>
                <tbody id="evidence" class="controls tableColumnExtendable">
                  <#if (existingEvidences?size > 0)>
                    <#list existingEvidences as evidence>
                      <tr class="entry targetToRemoveAfterDelete" data-uri="${evidence.uri}">
                        <td data-predUri="${evidenceLinkNamePred}">
                          <div class="editableTextField">${evidence.name}</div>
                          <a title="Edit Display Name" class="editTextField btn btn-primary outline btn-sm"><i class="fa fa-pencil-square-o fa-fw" ></i></a> <span class="hidden tiny-editor-controls"><a title="Save" class="btn btn-success outline save-btn"><i class="fa fa-floppy-o fa-fw"></i></a> <a title="Cancel" class="btn btn-warning outline cancel-btn"><i class="fa fa-ban fa-fw"></i></a></span>
                        </td>

                        <td data-predUri="${evidenceLinkPred}">
                          <div class="editableTextField">${evidence.link}</div>
                          <a title="Edit Link" class="editTextField btn btn-primary outline btn-sm"><i class="fa fa-pencil-square-o fa-fw" ></i></a> <span class="hidden tiny-editor-controls"><a title="Save" class="btn btn-success outline save-btn"><i class="fa fa-floppy-o fa-fw"></i></a> <a title="Cancel" class="btn btn-warning outline cancel-btn"><i class="fa fa-ban fa-fw"></i></a></span>
                        </td>

                        <td data-predUri="${descriptionPred}">
                          <div class="richTextArea">${evidence.description}</div>
                          <a title="Edit Description" class="editRichTextarea btn btn-primary outline btn-sm"><i class="fa fa-pencil-square-o fa-fw" ></i></a> <span class="hidden tiny-editor-controls"><a title="Save" class="btn btn-success outline save-btn"><i class="fa fa-floppy-o fa-fw"></i></a> <a title="Cancel" class="btn btn-warning outline cancel-btn"><i class="fa fa-ban fa-fw"></i></a></span>
                        </td>

                        <td>
                            <button title="Delete Evidence Entry" class="btn btn-danger btn-remove removeTripleAndIndividual outline" type="button"  data-uri="${evidence.uri}" data-subjectUri="${objectUri}" data-predicateUri="${hasEvidencePred}">
                              <i class="fa fa-trash fa-fw" aria-hidden="true"></i> Delete
                            </button>
                        </td>
                      </tr>
                    </#list>
                  </#if>
                  <tr class="entry targetToRemoveAfterDelete" data-uri>
                    <td class="col-md-2" data-predUri="${evidenceLinkNamePred}">
                      <input class="form-control" type="text" />
                    </td>
                    <td class="col-md-3" data-predUri="${evidenceLinkPred}">
                      <input class="form-control" type="text" />
                    </td>
                    <td class="col-md-7" data-predUri="${descriptionPred}">
                      <textarea class="form-control input-md" id="wysiTextArea_evidence" rows="6" style="width:100%;"></textarea>
                    </td>
                    <td>
                        <button title="Add Evidence Details" class="btn btn-success btn-add createEvidence outline" type="button"  data-subjectUri="${objectUri}" data-predicateUri="${hasEvidencePred}" data-uri>
                          <i class="fa fa-floppy-o fa-fw" aria-hidden="true"></i> Save
                        </button>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
        </div>
        <div class="panel panel-default">
        <div class="panel-heading">
          <h3>UOW Support</h3>
        </div>
        <div class="panel-body">
          <div class="form-group">
            <label for="programs" class="control-label">UOW Centres / Programs <i data-toggle="tooltip" data-placement="top" title="" class="fa fa-question-circle tooltips-btn" data-original-title="Which UOW centres and programs were involved in the research?"></i></label>
            <ul id="programList" role="list">
              <#if (existingPrograms?size > 0)>
                <#list existingPrograms as program>
                  <li role="listitem" class="targetToRemoveAfterDelete">
                    <a class="glyphicon glyphicon-trash removeTriple" data-uri="${program.uri}" data-subjectUri="${objectUri}" data-predicateUri="${hasProgramPred}" title="Delete UOW Centre/Program"></a>
                    <span>${program.label}</span>
                  </li>
                </#list>
              </#if>
            </ul>
            <div class="input-group col-xs-12" style="margin-bottom:8px;">
              <input class="autoCompleteInputField form-control input-md" type="text" id="programs" acGroupName="program" acDisplayTarget="#programList" acPredicateUri="${hasProgramPred}" name="programs" valueToPredicate="${rdfLabelPred}">
              <span class="input-group-btn">
                <button data-input-id="programs" class="btn btn-success btn-add outline-group" type="button" title="Add New Centre/Program">
                    <i class="fa fa-plus" aria-hidden="true"></i> Add New
                </button>
              </span>
            </div>
              <small><i class="fa fa-info-circle" aria-hidden="true"></i> Start typing the name of the centre/program: select from the auto-complete list or click <i>Add New</i> if centre/program is not listed</small>
          </div>
          <div class="form-group">
            <label for="collaborators" class="control-label">UOW Researchers / Collaborators <i data-toggle="tooltip" data-placement="top" title="" class="fa fa-question-circle tooltips-btn" data-original-title="Who was involved in the contributing research or engagement activities?"></i></label>
            <ul id="collaboratorList" role="list">
              <#if (existingCollaborators?size > 0)>
                <#list existingCollaborators as collaborator>
                  <li role="listitem" class="targetToRemoveAfterDelete">
                    <#if collaborator.uri?? && collaborator.uri != editConfiguration.subjectUri>
                      <a class="glyphicon glyphicon-trash removeTriple" data-uri="${collaborator.uri}" data-subjectUri="${objectUri}" data-predicateUri="${hasCollaboratorPred}" title="Remove Collaborator"></a>
                    </#if>
                    <#if collaborator.uri?? && collaborator.uri != editConfiguration.subjectUri>
                      <span>
                    <#else>
                      <span style="padding-left:16px;">
                    </#if>
                    <a target="_blank" href="${collaborator.uri?replace("http://uowvivo.uow.edu.au/individual/","/display/")}">${collaborator.label}</a></span>
                  </li>
                </#list>
              </#if>
            </ul>
            <input class="autoCompleteInputField form-control input-md" type="text" id="collaborators" acGroupName="collaborator" acDisplayTarget="#collaboratorList" acPredicateUri="${hasCollaboratorPred}" name="collaborators">
              <small><i class="fa fa-info-circle" aria-hidden="true"></i> Start typing the name of the UOW Collaborator and select from the auto-complete list</small>
              <hr>
              <div class="impact-note">
                  <b>Note on adding UOW Researchers / Collaborators</b>:
                  <p>By adding a UOW Collaborator to an impact story:</p>
                  <ul>
                      <li>The Impact Story is shared across all collaborator profiles</li>
                      <li>Edits/visibility changes affect the presentation of the Impact Story for all collaborators</li>
                      <li>Collaborators are notified by email when added to an Impact Story</li>
                      <li>Each collaborator has full access to edit/delete the Impact Story</li>
                  </ul>
              </div>
          </div>
        </div>
        </div>
        <input type="hidden" id="editKey" name="editKey" value="${editKey}"/>
        <a href="${cancelUrl}&url=/individual" title="${i18n().cancel_title}" class="btn btn-primary outline"><i class="fa fa-reply" aria-hidden="true"></i> ${i18n().return_to_profile}</a>
      </section>
    <#else>
      <div class="step">
        <h2>Step 1: Create an Impact Story</h2>
        <ol>
          <li>Provide a title and brief summary of the Impact Story below.</li>
          <li>Add further details (i.e. beneficiaries, collaborators, evidence and details of impact) on the next screen.</li>
          <li>Recommended resources:
              <ul class="impact-note-list">
                  <li><a href="https://intranet.uow.edu.au/content/groups/public/@web/@raid/documents/doc/uow236690.pdf" target="_blank">Impact Story Quick-Start Guide</a></li>
                  <li><a href="https://intranet.uow.edu.au/raid/era/engagement-impact/" target="_blank">Research Engagement & Impact</a></li>
              </ul>
          </li>
        </ol>
          <hr>
          <div class="impact-note">
            <b>Note on adding UOW Researchers / Collaborators</b>:
            <p>By adding a UOW Collaborator to an Impact Story:</p>
            <ul>
                <li>The Impact Story is shared across all collaborator profiles</li>
                <li>Edits/visibility changes affect the presentation of the Impact Story for all collaborators</li>
                <li>Collaborators are notified by email when added to an Impact Story</li>
                <li>Each collaborator has full access to edit/delete the Impact Story</li>
            </ul>
          </div>
      </div>
      <form id="personHasImpactEngagement" class="customForm noIE67 col-xs-12 col-ms-12 col-lg-12 impactDisplay" action="${submitUrl}"  role="add/edit" method="POST">
        <div class="form-group">
          <label for="title stripes" class="control-label col-ms-12 requiredField">${requiredHint} Title</label>
          <div class="col-ms-12">
            <input type="text" id="title" name="title" value="${titleValue}" class="form-control input-md" />
          </div>
        </div>
        <div class="form-group stripes">
          <label for="description" class="control-label requiredField">${requiredHint} Impact Summary <small>(Max 500 words)</small> <i data-toggle="tooltip" data-placement="top" title="" class="fa fa-question-circle tooltips-btn" data-original-title="What was the impact (outside of academia)?"></i></label>
          <div class="col-ms-12">
            <textarea class="form-control input-md wysiTextArea" id="description" name="description" rows="6" style="width:100%;">${descriptionValue}</textarea>
          </div>
        </div>

        <input type="hidden" id="draftPublic" name="draftPublic" value="true" class="form-control input-md hidden" />

        <input type="hidden" id="editKey" name="editKey" value="${editKey}"/>
        <p class="submit">
          <input type="submit" class="btn btn-primary outline" value="Complete Step 1" id="submitBtn"/><span class="or"> Complete Step 1 </span>
          <a class="cancel btn btn-warning outline" href="${cancelUrl}&url=/individual" title="${i18n().cancel_title}">${i18n().cancel_link}</a>
        </p>
      </form>
      <p id="requiredLegend" class="requiredHint">* ${i18n().required_fields}</p>
    </#if>
  </div>
</div>
<script type="text/javascript">
var autoCompleteExtends  = {
  inputField: '.autoCompleteInputField',
  primitiveRdfEditUrl:'${urls.base}/edit/primitiveRdfEdit',
  acUrl: '${urls.base}/autocomplete?tokenize=true&stem=true',
  acMultipleTypes:'true',
  acTypes: {forCode: 'http://purl.org/asc/1297.0/2008/for/FOR',country:'http://vivoweb.org/ontology/core#Country',collaborator:'http://vivoweb.org/ontology/core#FacultyMember,http://uowvivo.uow.edu.au/ontology/uowvivo#staff',program:'http://uowvivo.uow.edu.au/ontology/uowimpact#Program',partner:'http://xmlns.com/foaf/0.1/Organization'},
  personUri: "${editConfiguration.subjectUri}",
  objectUri: "${objectUri}",
  removeField: '.removeTriple',
  removeRow: '.removeTripleAndIndividual',
  beneficaryPred: "${beneficiaryPred}",
  descriptionPred: "${descriptionPred}",
  quantityPred: "${quantityPred}",
  evidenceLinkPred:"${evidenceLinkPred}",
  evidenceLinkNamePred:"${evidenceLinkNamePred}",
  hasBeneficiaryPred: "${hasBeneficiaryPred}",
  displayOrderPred: "${displayOrderPred}",
  beneficiaryTypePred: "${beneficiaryTypePred}",
  evidenceTypePred: "${evidenceTypePred}",
  hasEvidencePred:"${hasEvidencePred}",
  initHideFromPublic: "${initHideFromPublic}"
}
</script>
 
${stylesheets.add('<link rel="stylesheet" href="${urls.base}/js/jquery-ui/css/smoothness/jquery-ui-1.8.9.custom.css" />')}
${stylesheets.add('<link rel="stylesheet" href="${urls.base}/templates/freemarker/edit/forms/css/customForm.css" />')}
${stylesheets.add('<link rel="stylesheet" href="${urls.base}/templates/freemarker/edit/forms/css/customFormWithAutocomplete.css" />')}

${scripts.add('<script type="text/javascript" src="${urls.base}/js/jquery-ui/js/jquery-ui-1.8.9.custom.min.js"></script>',
       '<script type="text/javascript" src="${urls.base}/js/customFormUtils.js"></script>',
       '<script type="text/javascript" src="${urls.base}/js/extensions/String.js"></script>',
       '<script type="text/javascript" src="${urls.base}/js/browserUtils.js"></script>',
       '<script type="text/javascript" src="${urls.base}/js/jquery_plugins/jquery.bgiframe.pack.js"></script>',
       '<script type="text/javascript" src="${urls.base}/templates/freemarker/edit/forms/js/scholarsAutoComplete.js"></script>')}


