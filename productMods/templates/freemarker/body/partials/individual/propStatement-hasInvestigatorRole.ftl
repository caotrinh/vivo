<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Custom object property statement view for faux property "investigator on," "principal investigator on" and 
     "co-principal investigator on." See the PropertyConfig.3 file for details.
    
     This template must be self-contained and not rely on other variables set for the individual page, because it
     is also used to generate the property statement during a deletion.  
 -->

<#import "lib-datetime.ftl" as dt>
<@showRole statement />

<#-- Use a macro to keep variable assignments local; otherwise the values carry over to the
     next statement -->
<#macro showRole statement>
<#if statement.hideThis?has_content>
    <span class="hideThis">&nbsp;</span>
    <script type="text/javascript" >
        $('span.hideThis').parent().parent().addClass("hideThis");
        if ( $('h3#RO_0000053-InvestigatorRole').length > 0 && $('h3#RO_0000053-InvestigatorRole').attr('class').length == 0 ) {
            $('h3#RO_0000053-InvestigatorRole').addClass('hiddenGrants');
        }
        $('span.hideThis').parent().remove();
    </script>
<#else>
    <#local linkedIndividual>
        <#if statement.activity??>
            <a href="${profileUrl(statement.uri("activity"))}" title="${i18n().activity_name}">${statement.activityLabel!statement.activityName!}</a>
        <#else>
            <#-- This shouldn't happen, but we must provide for it -->
            <a href="${profileUrl(statement.uri("role"))}" title="${i18n().missing_activity}">${i18n().missing_activity}</a>
        </#if>
    </#local>
    
    <#local awardBy>
        <#if statement.awardedByLabel??>
            <div class="row cites"><div class="col-md-3"><strong>Awarded by:</strong></div><div class="col-md-9"><a href="${profileUrl(statement.uri("awardedBy"))}" title="${i18n().awarded_by}">${statement.awardedByLabel!}</a></div></div>
        <#elseif statement.adminedByLabel??>
        </#if>
    </#local>

    <#local adminBy>
      <#if statement.adminByLabel??>
            <div class="row cites"><div class="col-md-3"><strong>Administered by::</strong></div><div class="col-md-9"><a href="${profileUrl(statement.uri("adminedBy"))}" title="${i18n().administered_by}">${statement.adminedByLabel!}</a></div></div>
      <#else>
      </#if>
    </#local>
        
    <#local scheme>
      <#if statement.scheme??>
            <div class="row cites"><div class="col-md-3"><strong>Funding Scheme:</strong></div><div class="col-md-9">${statement.scheme!}</div></div>
      <#else>
      </#if>
    </#local>
        
    <#local dateTime>
        <#if statement.dateTimeStartRole?has_content || statement.dateTimeEndRole?has_content>
            <@dt.yearIntervalSpan "${statement.dateTimeStartRole!}" "${statement.dateTimeEndRole!}" />
        <#else>
            <@dt.yearIntervalSpan "${statement.dateTimeStartGrant!}" "${statement.dateTimeEndGrant!}" />
        </#if>
    </#local>
    
    <tr><td>${dateTime!}</td><td><div>${linkedIndividual}</div><hr /><div class="citationDetails">${awardBy} ${scheme} ${adminBy}</div></td></tr>
</#if>
</#macro>
