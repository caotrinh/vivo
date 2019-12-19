<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Template for adding/editing core:webpages -->
<#import "lib-vivo-form.ftl" as lvf>

<#assign subjectName=editConfiguration.pageData.subjectName!"an Individual" />

<#--If edit submission exists, then retrieve validation errors if they exist-->
<#if editSubmission?has_content && editSubmission.submissionExists = true && editSubmission.validationErrors?has_content>
    <#assign submissionErrors = editSubmission.validationErrors/>
</#if>

<#--Retrieve variables needed-->
<#assign url = lvf.getFormFieldValue(editSubmission, editConfiguration, "url")/>
<#assign urlTypeValue = lvf.getFormFieldValue(editSubmission, editConfiguration, "urlType")/>
<#assign label = lvf.getFormFieldValue(editSubmission, editConfiguration, "label") />
<#assign newRank = editConfiguration.pageData.newRank!"" />

<#if url?has_content>
    <#assign editMode = "edit">
<#else>
    <#assign editMode = "add">
</#if>

<#if editMode == "edit">        
        <#assign titleVerb="${i18n().edit_wbpage_of}">        
        <#assign submitButtonText="${i18n().save_changes}">
        <#assign disabledVal="disabled">
<#else>
        <#assign titleVerb="${i18n().add_webpage_for}">
        <#assign submitButtonText="${i18n().add_webpage}">
        <#assign disabledVal=""/>
</#if>

<#assign requiredHint="<span class='requiredHint'> *</span>" />

<div class="panel panel-default">
<div class="panel-heading">
${titleVerb} ${subjectName}
</div><div class="panel-body">
<#if submissionErrors??>
<section id="error-alert" role="alert">
        <img src="${urls.images}/iconAlert.png" width="24" height="24" alert="${i18n().error_alert_icon}" />
        <p>       
        <#list submissionErrors?keys as errorFieldName>
            ${errorFieldName}: ${submissionErrors[errorFieldName]}  <br/>           
        </#list>
        </p>
</section>
</#if>    
    
<form class="customForm" action ="${submitUrl}">
	<input type="hidden" name="rangeUri" value="${editConfiguration.rangeUri!}">
	<input type="hidden" name="domainUri" value="${editConfiguration.domainUri!}">
    <div class="form-group">
        <label for="urlType">${i18n().url_type}${requiredHint}</label>
        <#assign urlTypeOpts = editConfiguration.pageData.urlType />
        <div class="input-group">
            <select name="urlType" style="margin-top:-2px" >
                <option value="" <#if editMode == "add">selected</#if>>${i18n().select_one}</option>                
                <#list urlTypeOpts?keys as key>             
                    <option value="${key}"  <#if urlTypeValue == key>selected</#if> >
                        <#if urlTypeOpts[key] == "F1000 Link">
                            ${i18n().faculty_of_1000}
                        <#elseif urlTypeOpts[key] == "Other">
                            ${i18n().standard_web_link}
                        <#else>
                            ${urlTypeOpts[key]}
                        </#if>
                    </option>         
                </#list>
            </select>
        </div>
    </div>
    <div class="form-group">
        <label for="url">URL ${requiredHint}</label>
        <div class="input-group">
            <input  size="70"  type="text" id="url" name="url" value="${url}" role="input" />
        </div>
    </div>
    <div class="form-group">
        <label for="label">${i18n().webpage_name}</label>
        <div class="input-group">
            <input  size="70"  type="text" id="label" name="label" value="${label?html}" role="input" />
        </div>
    </div>
    <#if editMode="add">
        <input type="hidden" name="rank" value="${newRank}" />
    </#if>
    
    <input type="hidden" id="editKey" name="editKey" value="${editConfiguration.editKey}"/>
    <p class="submit">
        <input type="submit" class="btn btn-primary" id="submit" value="${submitButtonText}"/><span class="or"> ${i18n().or} </span>
        <a class="cancel" href="${editConfiguration.cancelUrl}" title="${i18n().cancel_title}">${i18n().cancel_link}</a>
    </p>    
</form>
</div></div>
${stylesheets.add('<link rel="stylesheet" href="${urls.base}/templates/freemarker/edit/forms/css/customForm.css" />')}

${scripts.add('<script type="text/javascript" src="${urls.base}/js/userMenu/userMenuUtils.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/customFormUtils.js"></script>')}
