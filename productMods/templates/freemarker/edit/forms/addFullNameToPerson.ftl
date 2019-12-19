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

<#assign htmlForElements = editConfiguration.pageData.htmlForElements />

<#--Retrieve variables needed-->
<#assign firstNameValue = lvf.getFormFieldValue(editSubmission, editConfiguration, "firstName") />
<#assign middleNameValue = lvf.getFormFieldValue(editSubmission, editConfiguration, "middleName") />
<#assign lastNameValue = lvf.getFormFieldValue(editSubmission, editConfiguration, "lastName") />
<#assign suffixValue = lvf.getFormFieldValue(editSubmission, editConfiguration, "suffix") />
<#assign prefixValue = lvf.getFormFieldValue(editSubmission, editConfiguration, "prefix") />


<#--If edit submission exists, then retrieve validation errors if they exist-->
<#if editSubmission?has_content && editSubmission.submissionExists = true && editSubmission.validationErrors?has_content>
	<#assign submissionErrors = editSubmission.validationErrors/>
</#if>

<#if editMode == "edit">    
        <#assign titleVerb="${i18n().edit_capitalized}">        
        <#assign submitButtonText="${titleVerb}" + " ${i18n().full_name}">
        <#assign disabledVal="disabled">
<#else>
        <#assign titleVerb="${i18n().create_capitalized}">        
        <#assign submitButtonText="${titleVerb}" + " ${i18n().full_name}">
        <#assign disabledVal=""/>
</#if>

<#assign requiredHint = "<span class='requiredHint'> *</span>" />

<div id="manage-records-for" class="panel panel-default">
<div class="panel-heading">
${titleVerb}&nbsp;${i18n().full_name_for} ${editConfiguration.subjectName}
</div><div class="panel-body">
<#--Display error messages if any-->
<#if submissionErrors?has_content>
    <section id="error-alert" role="alert">
        <img src="${urls.images}/iconAlert.png" width="24" height="24" alert="${i18n().error_alert_icon}" />
        <p>
            <#--Checking if any required fields are empty-->
            <#if lvf.submissionErrorExists(editSubmission, "firstName")>
 	            ${i18n().enter_first_name}<br />
            </#if>        
            <#if lvf.submissionErrorExists(editSubmission, "lastName")>
 	            ${i18n().enter_last_name}<br />
            </#if>        
        </p>
    </section>
</#if>

<@lvf.unsupportedBrowser urls.base /> 

<section id="addFullNameToPerson" role="region">        
    
    <form id="addFullNameToPerson" class="customForm noIE67" action="${submitUrl}"  role="add/edit name">

        <div class="form-group">
            <label for="firstName">${i18n().first_name} ${requiredHint}</label>
            <div class="input-group">
                <input  size="25"  type="text" id="firstName" name="firstName" value="${firstNameValue}" />
            </div>
            <label>${i18n().name_prefix}</label>
            <div class="input-group">
                <input size="12"  type="text" id="prefix" name="prefix" value="${prefixValue}" />
            </div>
        </div>
        <hr/>
        <div class="form-group">
            <label for="middleName">${i18n().middle_name}</label>
            <div class="input-group">
                <input  size="25"  type="text" id="middleName" name="middleName" value="${middleNameValue}" />
            </div>
            <label>${i18n().name_suffix}</label>
            <div class="input-group">
                <input size="12"  type="text" id="suffix" name="suffix" value="${suffixValue}" />
            </div>
        </div>
        <hr/>
        <div class="form-group">
            <label for="lastName">${i18n().last_name} ${requiredHint}</label>
            <div class="input-group">
                <input  size="25"  type="text" id="lastName" name="lastName" value="${lastNameValue}" />
            </div>
        </div>
        <input type="hidden" id="editKey" name="editKey" value="${editKey}"/>

        <div class="submit form-group">
            <input type="submit" id="submit" class="btn btn-primary" value="${submitButtonText}"/><span class="or"> ${i18n().or} </span>
            <a class="cancel" href="${cancelUrl}" title="${i18n().cancel_title}">${i18n().cancel_link}</a>
        </p>
        <div class="form-group">
            <p id="requiredLegend" class="requiredHint">* ${i18n().required_fields}</p>
        </div>

    </form>

</section>
 
${stylesheets.add('<link rel="stylesheet" href="${urls.base}/js/jquery-ui/css/smoothness/jquery-ui-1.8.9.custom.css" />')}
${stylesheets.add('<link rel="stylesheet" href="${urls.base}/templates/freemarker/edit/forms/css/customForm.css" />')}

${scripts.add('<script type="text/javascript" src="${urls.base}/js/jquery-ui/js/jquery-ui-1.8.9.custom.min.js"></script>',
             '<script type="text/javascript" src="${urls.base}/js/extensions/String.js"></script>',
             '<script type="text/javascript" src="${urls.base}/js/browserUtils.js"></script>',
             '<script type="text/javascript" src="${urls.base}/js/jquery_plugins/jquery.bgiframe.pack.js"></script>')}

</div></div>