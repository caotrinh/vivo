<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Custom object property statement view for faux property "positions". See the PropertyConfig.3 file for details.

     This template must be self-contained and not rely on other variables set for the individual page, because it
     is also used to generate the property statement during a deletion.
 -->

<#import "lib-sequence.ftl" as s>
<#import "lib-datetime.ftl" as dt>
<@showPosition statement />

<#-- Use a macro to keep variable assignments local; otherwise the values carry over to the
     next statement -->
<#macro showPosition statement>
    <#local linkedIndividual>
        <#if statement.org??>
            ${statement.orgName}
        <#else>
            <#-- This shouldn't happen, but we must provide for it -->
            ${i18n().missing_organization}
        </#if>
    </#local>
    <#-- The sparql query returns both the org's parent (middleOrg) and grandparent (outerOrg).
         For now, we are only displaying the parent in the list view. -->
    <#local middleOrganization>
        <#if statement.middleOrg??>
            ${statement.middleOrgName!}
        </#if>
    </#local>

    <div class="position">
        <#if statement.positionTitle!?has_content || statement.hrJobTitle!?has_content>${statement.positionTitle!statement.hrJobTitle!} - </#if>
        <@s.join [ linkedIndividual, middleOrganization! ]/>  <@dt.yearIntervalSpan "${statement.dateTimeStart!}" "${statement.dateTimeEnd!}" /></div>

</#macro>
