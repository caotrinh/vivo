<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- VIVO-specific default object property statement template. 
    
     This template must be self-contained and not rely on other variables set for the individual page, because it
     is also used to generate the property statement during a deletion.  
 -->

<@showStatement statement />

<#macro showStatement statement>
    <#-- The query retrieves a type only for Persons. Post-processing will remove all but one. -->  
    <#if profileUrl(statement.uri("object"))!?contains("/group")>
    	${statement.label!statement.localName!} &nbsp; ${statement.title!statement.type!}
    <#elseif statement.hideThis?? && statement.hideThis == "true">
    	${statement.label!statement.localName!} &nbsp; ${statement.title!statement.type!}
    <#else>
    	<a href="${profileUrl(statement.uri("object"))}" title="${i18n().name}">${statement.label!statement.localName!}</a>&nbsp; ${statement.title!statement.type!}
    </#if>
</#macro>





