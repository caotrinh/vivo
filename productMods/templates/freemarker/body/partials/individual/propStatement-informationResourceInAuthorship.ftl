<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Custom object property statement view for faux property "authors". See the PropertyConfig.3 file for details. 
    
     This template must be self-contained and not rely on other variables set for the individual page, because it
     is also used to generate the property statement during a deletion.  
 -->

<#import "lib-sequence.ftl" as s>
<@showAuthorship statement />

<#-- Use a macro to keep variable assignments local; otherwise the values carry over to the
     next statement -->
<#macro showAuthorship statement>
    <#if statement.author?? && statement.authorName??>
        <i class="fa fa-user"></i>&nbsp;
        <#if profileUrl(statement.uri("author"))?contains("/group")>
            <span title="${i18n().author_name}">${statement.authorName}</span>
        <#elseif statement.isHonorary?? && statement.isHonorary == "true">
            <span title="${i18n().author_name}">${statement.authorName}</span>
        <#elseif statement.hideAuthor?? && statement.hideAuthor == "true">
            <span title="${i18n().author_name}">${statement.authorName} (external author)</span>
        <#else>
            <a href="${profileUrl(statement.uri("author"))}" title="${i18n().author_name}">${statement.authorName}</a>
        </#if>
    <#elseif statement.author??>
        <i class="fa fa-user"></i>&nbsp;&nbsp;<span>${statement.authorshipLabel} (external author)</span>
    <#else>
        <a href="${profileUrl(statement.uri("authorship"))}" title="${i18n().missing_author}">${i18n().missing_author}</a>
        <#-- This shouldn't happen, but we must provide for it 
        ${statement.label}
        <a href="${profileUrl(statement.uri("authorship"))}" title="${i18n().missing_author}">${i18n().missing_author}</a>
        -->
    </#if>
</#macro>
