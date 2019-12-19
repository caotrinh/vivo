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

<#--The blank sentinel indicates what value should be put in a URI when no autocomplete result has been selected.
If the blank value is non-null or non-empty, n3 editing for an existing object will remove the original relationship
if nothing is selected for that object-->
<#assign blankSentinel = "" />
<#if editConfigurationConstants?has_content && editConfigurationConstants?keys?seq_contains("BLANK_SENTINEL")>
	<#assign blankSentinel = editConfigurationConstants["BLANK_SENTINEL"] />
</#if>

<#--This flag is for clearing the label field on submission for an existing object being selected from autocomplete.
Set this flag on the input acUriReceiver where you would like this behavior to occur. -->
<#assign flagClearLabelForExisting = "flagClearLabelForExisting" />

<#assign htmlForElements = editConfiguration.pageData.htmlForElements />

<#--Retrieve variables needed-->
<#assign credentialTypeValue = lvf.getFormFieldValue(editSubmission, editConfiguration, "credentialType")/>
<#assign credentialValue = lvf.getFormFieldValue(editSubmission, editConfiguration, "existingCredential") />
<#assign credentialLabelValue = lvf.getFormFieldValue(editSubmission, editConfiguration, "credentialLabel") />
<#assign yearCredentialedDisplayValue = lvf.getFormFieldValue(editSubmission, editConfiguration, "yearCredentialedDisplay") />
<#assign credentialLabelDisplayValue = lvf.getFormFieldValue(editSubmission, editConfiguration, "credentialLabelDisplay") />
<#assign issuedCredentialTypeValue = lvf.getFormFieldValue(editSubmission, editConfiguration, "issuedCredentialType")/>

<#--If edit submission exists, then retrieve validation errors if they exist-->
<#if editSubmission?has_content && editSubmission.submissionExists = true && editSubmission.validationErrors?has_content>
	<#assign submissionErrors = editSubmission.validationErrors/>
</#if>

<#if editMode == "edit">    
        <#assign titleVerb="${i18n().edit_capitalized}">        
        <#assign submitButtonText="${i18n().save_changes}">
        <#assign disabledVal="disabled">
<#else>
<#assign titleVerb="${i18n().create_capitalized}">        
<#assign submitButtonText="${i18n().create_entry}">
        <#assign disabledVal=""/>
</#if>

<#assign requiredHint = "<span class='requiredHint'> *</span>" />
<#assign yearHint     = "<span class='hint'>(${i18n().year_hint_format})</span>" />

<div id="manage-records-for" class="panel panel-default">
<div class="panel-heading">
<h2>${titleVerb}&nbsp;${i18n().credentials} ${i18n().for} ${editConfiguration.subjectName}</h2>
</div><div class="panel-body">
<#--Display error messages if any-->
<#if submissionErrors?has_content>
    <#if credentialLabelDisplayValue?has_content >
        <#assign credentialLabelValue = credentialLabelDisplayValue />
    </#if>
        
    <section id="error-alert" role="alert">
        <img src="${urls.images}/iconAlert.png" width="24" height="24" alt="${i18n().error_alert_icon}" />
        <p>
        <#--Checking if any required fields are empty-->
        <#if lvf.submissionErrorExists(editSubmission, "credentialLabel")>
 	        ${i18n().select_credential_or_enter_name}
        </#if> 
        <#list submissionErrors?keys as errorFieldName>
        	<#if errorFieldName == "startField">
        	    <#if submissionErrors[errorFieldName]?contains("before")>
        	        ${i18n().start_year_must_precede_end}
        	    <#else>
        	        ${submissionErrors[errorFieldName]}
        	    </#if>
        	    
        	<#elseif errorFieldName == "endField">
    	        <#if submissionErrors[errorFieldName]?contains("after")>
    	            ${i18n().end_year_must_be_later}
    	        <#else>
    	            ${submissionErrors[errorFieldName]}
    	        </#if>
	        </#if><br />
        </#list>
        </p>
    </section>
</#if>

<@lvf.unsupportedBrowser urls.base /> 

<section id="personHasIssuedCredential" role="region">        
    
    <form id="personHasIssuedCredential" class="customForm noIE67" action="${submitUrl}"  role="add/edit IssuedCredential">
    <div class="form-group">    
        <label for="credentialType">${i18n().type_of_credential} ${requiredHint}</label>
        <#assign credentialTypeOpts = editConfiguration.pageData.credentialType />


        <#if editMode == "add" >
            <div class="input-group">
                <select id="typeSelector" name="credentialType" acGroupName="credential">
                    <option value="" selected="selected">${i18n().select_one}</option>                
                    <#list credentialTypeOpts?keys as key>             
                        <#if credentialTypeValue = key>
                            <option value="${key}"  selected >${credentialTypeOpts[key]}</option>     
                        <#else>
                            <option value="${key}">${credentialTypeOpts[key]}</option>
                        </#if>
                    </#list>
                </select>
            </div>
        <#else>
            <div class="input-group">
                <#list credentialTypeOpts?keys as key>             
                    <#if credentialTypeValue = key >
                      <span class="readOnly" id="typeSelectorSpan">${credentialTypeOpts[key]}</span> 
                      <input type="hidden" id="typeSelectorInput" name="credentialType" acGroupName="credential" value="${credentialTypeValue}" >
                    </#if>           
                </#list>
            </div>
        </#if>
        
        
    </div>
    <hr/>     
    <p>
        <label for="relatedIndLabel">${i18n().credential_name} ${requiredHint}</label>
            <input class="acSelector" size="50" style="display:block;" type="text" id="credential" acGroupName="credential" name="credentialLabel" value="${credentialLabelValue}">
            <input class="display" type="hidden" id="credentialDisplay" acGroupName="credential" name="credentialLabelDisplay" value="${credentialLabelDisplayValue}">
    </p>

    <div class="acSelection" acGroupName="credential" id="credentialAcSelection">
        <p class="inline">
            <label style="display:block;">${i18n().selected_credential}:</label>
            <span style="display:block;" class="acSelectionInfo"></span>
            <a href="" class="verifyMatch"  title="${i18n().verify_match_capitalized}">(${i18n().verify_match_capitalized}</a> ${i18n().or} 
            <a href="#" class="changeSelection" id="changeSelection">${i18n().change_selection})</a>
        </p>
        <input class="acUriReceiver" type="hidden" id="credentialUri" name="existingCredential" value="${credentialValue}" ${flagClearLabelForExisting}="true" />
    </div>
    <hr/>
    <#assign htmlForElements = editConfiguration.pageData.htmlForElements />


    <p>    
        <input type="hidden" id="issuedCredentialType" name="issuedCredentialType" acGroupName="credential" value="${issuedCredentialTypeValue}">
    </p>     

    <div class="form-group">
        <label for="yearCredentialedDisplay" id="yearCredentialed">${i18n().year_issued}</label>
        <div class="input-group">
            <input  size="4"  type="text" id="yearCredentialedDisplay" name="yearCredentialedDisplay" value="${yearCredentialedDisplayValue}" /> ${yearHint}
        </div>
    </div>
    <hr/>
    <p>
        <h4>${i18n().years_inclusive}</h4>
    </p>
    <#--Need to draw edit elements for dates here-->
    <#if htmlForElements?keys?seq_contains("startField")>
        <div class="form-group">
            <label class="dateTime" for="startField">${i18n().start_capitalized}</label>
    		${htmlForElements["startField"]} ${yearHint}
        </div>
    </#if>
    
    <#if htmlForElements?keys?seq_contains("endField")>
		<div class="form-group">
            <label class="dateTime" for="endField">${i18n().end_capitalized}</label>
    	 	${htmlForElements["endField"]} ${yearHint}
        </div>
    </#if>
	<#--End draw elements-->

    <input type="hidden" id="editKey" name="editKey" value="${editKey}"/>

    <p class="submit">
         <input type="submit" class="btn btn-primary" value="${submitButtonText}"/><span class="or"> ${i18n().or} </span>
         <a class="cancel" href="${cancelUrl}" title="${i18n().cancel_title}">${i18n().cancel_link}</a>
     </p>

    <p id="requiredLegend" class="requiredHint">* ${i18n().required_fields}</p>

    <#-- hide the html that gets written, and use java script to pass the value between the two -->
    <div class="hidden">
        <#if htmlForElements?keys?seq_contains("yearCredentialed")>
		    ${htmlForElements["yearCredentialed"]} 
        </#if>
    </div>

</form>
<#assign credentials = editConfiguration.pageData.credentialTypeMap />
<script>
    var credentials = {<#list credentials?keys as key>${key}: '${credentials[key]!}'<#if key_has_next>, </#if></#list>}
</script>
</section>


<script type="text/javascript">
var customFormData  = {
    acUrl: '${urls.base}/autocomplete?tokenize=true&stem=true',
    acTypes: {credential: 'http://vivoweb.org/ontology/core#Credential'},
    editMode: '${editMode}',
    defaultTypeName: 'credential',
    baseHref: '${urls.base}/individual?uri=',
    blankSentinel: '${blankSentinel}',
    flagClearLabelForExisting: '${flagClearLabelForExisting}'
};
var i18nStrings = {
    selectAnExisting: '${i18n().select_an_existing}',
    orCreateNewOne: '${i18n().or_create_new_one}',
    selectedString: '${i18n().selected}',
};

</script>

 
<script type="text/javascript">
 $(document).ready(function(){
    issuedCredentialUtils.onLoad();
}); 
</script>

${stylesheets.add('<link rel="stylesheet" href="${urls.base}/js/jquery-ui/css/smoothness/jquery-ui-1.8.9.custom.css" />')}
${stylesheets.add('<link rel="stylesheet" href="${urls.base}/templates/freemarker/edit/forms/css/customForm.css" />')}
${stylesheets.add('<link rel="stylesheet" href="${urls.base}/templates/freemarker/edit/forms/css/customFormWithAutocomplete.css" />')}

${scripts.add('<script type="text/javascript" src="${urls.base}/js/jquery-ui/js/jquery-ui-1.8.9.custom.min.js"></script>',
             '<script type="text/javascript" src="${urls.base}/js/customFormUtils.js"></script>',
             '<script type="text/javascript" src="${urls.base}/templates/freemarker/edit/forms/js/issuedCredentialUtils.js"></script>',
             '<script type="text/javascript" src="${urls.base}/js/extensions/String.js"></script>',
             '<script type="text/javascript" src="${urls.base}/js/browserUtils.js"></script>',
             '<script type="text/javascript" src="${urls.base}/js/jquery_plugins/jquery.bgiframe.pack.js"></script>',
             '<script type="text/javascript" src="${urls.base}/templates/freemarker/edit/forms/js/customFormWithAutocomplete.js"></script>',
             '<script type="text/javascript" src="${urls.base}/js/customFormWithAutoComplete_patch.js"></script>')}


</div></div>