<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#--Assign variables from editConfig-->
<#assign rangeOptions = editConfiguration.pageData.objectVar />
<#assign rangeOptionsExist = false />
<#if (rangeOptions?keys?size > 0)>
	<#assign rangeOptionsExist = true/>
</#if>
<#assign rangeUri = editConfiguration.objectPredicateProperty.rangeVClassURI!"" />
<#assign formTitle = editConfiguration.formTitle />
<#if rangeUri?contains("IAO_0000030")>
    <#assign formTitle = "${i18n().select_an_existing_document}" + " ${i18n().for} " + editConfiguration.subjectName/>
</#if>

<div id="manage-records-for" class="panel panel-default">
<div class="panel-heading">
${formTitle}
</div><div class="panel-body">
<#if editConfiguration.propertySelectFromExisting = true>
    <#if rangeOptionsExist  = true >
        <#assign rangeOptionKeys = rangeOptions?keys />
        <form class="editForm" action = "${submitUrl}">
            <input type="hidden" name="editKey" id="editKey" value="${editKey}" role="input" />
            <div class="form-group">
                <#if editConfiguration.propertyPublicDescription?has_content>
                    <p>${editConfiguration.propertyPublicDescription}</p>
                </#if>
                <div class="input-group">     
                    <select id="objectVar" name="objectVar" role="select">
                        <#list rangeOptionKeys as key>
                         <option value="${key}" <#if editConfiguration.objectUri?has_content && editConfiguration.objectUri = key>selected</#if> role="option">${rangeOptions[key]}</option>
                        </#list>
                    </select>
                </div>
            </div>
            <p>
                <input type="submit" id="submit" value="${editConfiguration.submitLabel}" role="button " class="btn btn-primary"/>
                <span class="or"> ${i18n().or} </span>
                <a title="${i18n().cancel_title}" class="cancel" href="${cancelUrl}">${i18n().cancel_link}</a>
            </p>
        </form>
    <#else>
        <p> ${i18n().there_are_no_entries_for_selection}  </p>  
    </#if>
</#if>

<#if editConfiguration.propertyOfferCreateNewOption = true>
<#include "defaultOfferCreateNewOptionForm.ftl">

</#if>

<#if editConfiguration.propertySelectFromExisting = false && editConfiguration.propertyOfferCreateNewOption = false>
<p>${i18n().editing_prohibited} </p>
</#if>


<#if editConfiguration.includeDeletionForm = true>
<#include "defaultDeletePropertyForm.ftl">
</#if>

</div></div>
