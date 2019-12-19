<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#--If edit submission exists, then retrieve validation errors if they exist-->
<#if editSubmission?has_content && editSubmission.submissionExists = true && editSubmission.validationErrors?has_content>
    <#assign submissionErrors = editSubmission.validationErrors/>
</#if>

<div id="manage-records-for" class="panel panel-default">
<div class="panel-heading">
${editConfiguration.formTitle}
</div><div class="panel-body">
<#--Display error messages if any-->
<#if submissionErrors?has_content>
    <section id="error-alert" role="alert">
        <img src="${urls.images}/iconAlert.png" width="24" height="24" alt="${i18n().error_alert_icon}" />
        <p>
        
        <#list submissionErrors?keys as errorFieldName>
            ${submissionErrors[errorFieldName]}
        </#list>
                        
        </p>
    </section>
</#if>

<#assign literalValues = "${editConfiguration.dataLiteralValuesAsString}" />

<#if editConfiguration.dataPredicateProperty.rangeDatatypeURI?? >
    <#assign datatype = editConfiguration.dataPredicateProperty.rangeDatatypeURI />
<#else>
    <#assign datatype = "none" />
</#if>

<form class="editForm" action = "${submitUrl}" method="post">
    <input type="hidden" name="editKey" id="editKey" value="${editKey}" role="input" />
    <div class="form-group">
    <#if editConfiguration.dataPredicatePublicDescription?has_content>
       <label for="${editConfiguration.dataLiteral}"><p class="propEntryHelpText">${editConfiguration.dataPredicatePublicDescription}</p></label>
    </#if>   

    <div class="input-group">
        <textarea rows="2"  id="literal" name="literal" value="" class="useTinyMce" role="textarea">${literalValues}</textarea>
    </div>
    </div>
    <br />
    <#--The submit label should be set within the template itself, right now
    the default label for default data/object property editing is returned from Edit Configuration Template Model,
    but that method may not return the correct result for other custom forms-->
    <input type="submit" id="submit" value="${editConfiguration.submitLabel}" role="button" class="btn btn-primary"/>
    <span class="or"> or </span>
    <a title="${i18n().cancel_title}" href="${cancelUrl}">${i18n().cancel_link}</a>

</form>

<#if editConfiguration.includeDeletionForm = true>
<#include "defaultDeletePropertyForm.ftl">
</#if>
</div></div>

<#include "defaultFormScripts.ftl">     

<script type="text/javascript">
    var datatype = "${datatype!}";

    var i18nStrings = {
        four_digit_year: '${i18n().four_digit_year}',
        year_numeric: '${i18n().year_numeric}',
        year_month_day: '${i18n().year_month_day}',
        minimum_ymd: '${i18n().minimum_ymd}',
        minimum_hour: '${i18n().minimum_hour}',
        year_month: '${i18n().year_month}',
        decimal_only: '${i18n().decimal_only}',
        whole_number: '${i18n().whole_number}'
    };
</script> 
