<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Default individual browse view -->

<#import "lib-properties.ftl" as p>

<li class="individual" role="listitem" role="navigation">
<div class="row">
<#if (individual.thumbUrl)??>
    <img src="${individual.thumbUrl}" width="90" alt="${individual.name}" />
</#if>
    <div class="sideText">
    <a href="${individual.profileUrl}" title="${i18n().view_profile_page_for} ${individual.name}}">${individual.name}</a>

<#if (extra[0].pt)?? >
    <span class="title">${extra[0].pt}</span>
<#else>
    <#assign cleanTypes = 'edu.cornell.mannlib.vitro.webapp.web.TemplateUtils$DropFromSequence'?new()(individual.mostSpecificTypes, vclass) />
    <#if cleanTypes?size == 1>
        <span class="title">${cleanTypes[0]}</span>
    <#elseif (cleanTypes?size > 1) >
        <span class="title">
            <#list cleanTypes as type>
            <span class="titleList">${type}</span>
            <#if type_has_next> | </#if>
            </#list>
        </span>
    </#if>
</#if>
</div>
</div>
</li>

