<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- this is in request.subject.name -->

<#-- leaving this edit/add mode code in for reference in case we decide we need it -->

<#import "lib-vivo-form.ftl" as lvf>
<div class="panel panel-default">
<#--Retrieve certain edit configuration information-->
<#if editConfiguration.objectUri?has_content>
    <#assign editMode = "edit">
<#else>
    <#assign editMode = "add">
</#if>

<#assign htmlForElements = editConfiguration.pageData.htmlForElements />

<#--Retrieve variables needed-->
<#assign orcidIdFromConf = lvf.getFormFieldValue(editSubmission, editConfiguration, "orcidId") />
<#assign orcidIdValue = orcidIdFromConf?replace("http://orcid.org/","") />
<#--If edit submission exists, then retrieve validation errors if they exist-->
<#if editSubmission?has_content && editSubmission.submissionExists = true && editSubmission.validationErrors?has_content>
	<#assign submissionErrors = editSubmission.validationErrors/>
</#if>

<#if editMode == "edit">    
        <#assign titleVerb="${i18n().edit_capitalized}">        
        <#assign submitButtonText="${titleVerb}" + " ORCID iD">
        <#assign disabledVal="disabled">
<#else>
        <#assign titleVerb="${i18n().create_capitalized}">        
        <#assign submitButtonText="${titleVerb}" + " ORCID iD">
        <#assign disabledVal=""/>
</#if>

<#assign requiredHint = "<span class='requiredHint'> *</span>" />

<div class="panel-heading">${titleVerb}&nbsp;ORCID iD&nbsp;${i18n().for} ${editConfiguration.subjectName}</div>
<div class="panel-body">
<#--Display error messages if any-->
<#if submissionErrors?has_content>
    <section id="error-alert" role="alert">
        <img src="${urls.images}/iconAlert.png" width="24" height="24" alert="${i18n().error_alert_icon}" />
        <p>
            <#--Checking if any required fields are empty-->
            <#if lvf.submissionErrorExists(editSubmission, "orcidId")>
 	            ${i18n().required_fields}: ORCID iD<br />
            </#if>        
        </p>
    </section>
</#if>

<@lvf.unsupportedBrowser urls.base /> 

<section id="personHasOrcidId" role="region">        
    
    <form id="personHasOrcidId" class="customForm noIE67" action="${submitUrl}"  role="add/edit orcidId">

        <p>
            <label for="orcidId">ORCID iD ${requiredHint}</label>
            <input  size="35"  type="text" id="orcidIdDisplay" name="orcidIdDisplay" value="${orcidIdValue}" />
            <input  type="hidden" id="orcidId" name="orcidId" value="" />
            <br>
            <span class="small">Please enter the ORCID iD only - e.g. <i>0000-0002-1825-0097</i></span>
        </p>

        <input type="hidden" id="editKey" name="editKey" value="${editKey}"/>

        <p class="submit">
            <input type="submit" id="submit" value="${submitButtonText}" class="displaySubmit btn btn-primary"/><span class="or"> ${i18n().or} </span>
            <a class="cancel" href="${cancelUrl}" title="${i18n().cancel_title}">${i18n().cancel_link}</a>
        </p>

        <p id="requiredLegend" class="requiredHint">* ${i18n().required_fields}</p>

    </form>

</section>
</div>
</div> 
${stylesheets.add('<link rel="stylesheet" href="${urls.base}/js/jquery-ui/css/smoothness/jquery-ui-1.8.9.custom.css" />')}
${stylesheets.add('<link rel="stylesheet" href="${urls.base}/templates/freemarker/edit/forms/css/customForm.css" />')}
${stylesheets.add('<link rel="stylesheet" href="${urls.base}/templates/freemarker/edit/forms/css/customFormWithAutocomplete.css" />')}

${scripts.add('<script type="text/javascript" src="${urls.base}/js/jquery-ui/js/jquery-ui-1.8.9.custom.min.js"></script>',
             '<script type="text/javascript" src="${urls.base}/js/extensions/String.js"></script>',
             '<script type="text/javascript" src="${urls.base}/js/browserUtils.js"></script>',
             '<script type="text/javascript" src="${urls.base}/templates/freemarker/edit/forms/js/addOrcidIdToPersonUtils.js"></script>',
             '<script type="text/javascript" src="${urls.base}/js/jquery_plugins/jquery.bgiframe.pack.js"></script>')}


