<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Custom object property statement view for faux property "editors". See the PropertyConfig.3 file for details. 
    
     This template must be self-contained and not rely on other variables set for the individual page, because it
     is also used to generate the property statement during a deletion.  
 -->

<#import "lib-sequence.ftl" as s>
<@showEditorship statement />

<#-- Use a macro to keep variable assignments local; otherwise the values carry over to the
     next statement -->
<#macro showEditorship statement>
	<#if statement.person?? && statement.personName??>
		<i class="fa fa-user"></i>&nbsp;
		<#if profileUrl(statement.uri("person"))?contains("/group")>
			<span title="${i18n().editor_name}">${statement.personName}</span>
		<#elseif statement.isHonorary?? && statement.isHonorary == "true">
            <span title="${i18n().editor_name}">${statement.personName}</span>
    	<#elseif statement.hideEditor?? && statement.hideEditor == "true">
    		<span title="${i18n().editor_name}">${statement.personName} (external editor)</span>
    	<#else>
        	<a href="${profileUrl(statement.uri("person"))}" title="${i18n().editor_name}">${statement.personName}</a>
        </#if>
    <#elseif statement.person??>
        <i class="fa fa-user"></i>&nbsp;&nbsp;<span>${statement.editorshipLabel} (external editor)</span>
    <#else>
        <#-- This shouldn't happen, but we must provide for it -->
        <a href="${profileUrl(statement.uri("editorship"))}" title="${i18n().missing_editor}">${i18n().missing_editor}</a>
    </#if>
</#macro>