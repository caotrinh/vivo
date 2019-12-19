<#-- Template for core:webpage.
    
     This template must be self-contained and not rely on other variables set for the individual page, because it
     is also used to generate the property statement during a deletion.  
 -->

<#assign linkText>
    <#if statement.anchor?has_content>${statement.anchor}<#t>
    <#elseif statement.label?has_content>${statement.label}<#t>
    <#elseif statement.url?has_content>${statement.url}<#t>
    </#if>    
</#assign>

<#assign linkIcon>
    <#if statement.url?has_content>
        <#if statement.url?contains("ro.uow.edu.au") && statement.url?contains("article")>[download]<#t>
        <#elseif statement.url?contains("ro.uow.edu.au")>[metadata]<#t>
        <#else><span class="hoverlight glyphicon glyphicon-link contact-item"></span><#t>
        </#if>    
    </#if>    
</#assign>


<#if statement.url?has_content>
        <a href="${statement.url}" title="${linkText}"></a>&nbsp; <a href="${statement.url}" title="${linkText}">${linkText} ${linkIcon}</a> 
<#else>
    <a href="${profileUrl(statement.uri("link"))}" title="link name">${statement.linkName}</a> (no url provided for link)
</#if>
