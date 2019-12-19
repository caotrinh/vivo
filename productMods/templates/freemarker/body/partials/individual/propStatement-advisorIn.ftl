<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Custom object property statement view for faux property "advisees". See the PropertyConfig.3 file for details. 
    
     This template must be self-contained and not rely on other variables set for the individual page, because it
     is also used to generate the property statement during a deletion.  
 -->
<#import "lib-datetime.ftl" as dt>
<@showAdvisorIn statement />

<#-- Use a macro to keep variable assignments local; otherwise the values carry over to the
     next statement -->
<#macro showAdvisorIn statement>
    <#-- It's possible that advisorIn relationships were created before the custom form and only have
         an rdfs:label. So check to see if there's an advisee first. If not, just display the label.  -->
    <#local linkedIndividual>
        <#if statement.advisee??>
            ${statement.adviseeLabel!}
        </#if>
    </#local>

    <#local degreeInformation>
        <#if statement.degreeLabel??>
            ${statement.degreeAbbr!statement.degreeLabel!}
        </#if>
    </#local>

    <#local projectTitle>
        <#if statement.advisingRelLabel??>
            ${statement.advisingRelLabel!statement.localName}
        </#if>
    </#local>
    <td>${degreeInformation}</td><td>${projectTitle}</td><td>${linkedIndividual}</td>
 </#macro>