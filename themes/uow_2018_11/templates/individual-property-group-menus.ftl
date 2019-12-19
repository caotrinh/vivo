<#import "lib-properties.ftl" as p>
<#assign subjectUri = individual.controlPanelUrl()?split("=") >
<#assign tabCount = 1 >
<#assign sectionCount = 1 >
<#assign nameForOtherGroup = "${i18n().other}">
<!-- Nav tabs -->
  <ul class="nav nav-tabs" role="tablist">

    <#assign overview = "false">
    
    <#list propertyGroups.all as groupTabs>
      <#assign groupName = groupTabs.getName(nameForOtherGroup)>
      <#if groupName = "overview" >
        <#assign overview = "true">
      </#if>
    </#list>

    <#if overview = "false">
      <li role="presentation" class="active">
        <a href="#overview" aria-controls="overview" role="tab" data-toggle="tab">Overview</a>
      </li>
    </#if>


    <#list propertyGroups.all as groupTabs>
      <#if ( groupTabs.properties?size > 0 ) >
        <#assign groupName = groupTabs.getName(nameForOtherGroup)>
        <#if groupName?has_content>
          <#--the function replaces spaces in the name with underscores, also called for the property group menu-->
          <#assign groupNameHtmlId = p.createPropertyGroupHtmlId(groupName) >
        <#else>
          <#assign groupName = "${i18n().properties_capitalized}">
          <#assign groupNameHtmlId = "${i18n().properties}" >
        </#if>        

        <#if tabCount = 1 >
          <li role="presentation" <#if overview = "true">class="active"</#if>>
            <a href="#${groupNameHtmlId?replace("/","-")}" aria-controls="${groupNameHtmlId?replace("/","-")}" role="tab" data-toggle="tab">${groupName?capitalize}</a>
          </li>
          <#assign tabCount = 2>
        <#else>
          <li role="presentation">
            <a href="#${groupNameHtmlId?replace("/","-")}" aria-controls="${groupNameHtmlId?replace("/","-")}" role="tab" data-toggle="tab">${groupName?capitalize}</a>
          </li>
        </#if>
      </#if>
    </#list>
    <#assign tabCount = 1>

    <#if (propertyGroups.all?size > 1) >
      <li role="presentation">
        <a href="#viewAll" aria-controls="viewAll" role="tab" data-toggle="tab">${i18n().view_all_capitalized}</a>
      </li>
    </#if>

  </ul> <!-- / Nav tabs -->