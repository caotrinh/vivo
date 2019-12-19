<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Template for property listing on individual profile page -->

<#import "lib-properties.ftl" as p>
<#assign subjectUri = individual.controlPanelUrl()?split("=") >
<#assign tabCount = 1 >
<#assign sectionCount = 1 >
<!-- ${propertyGroups.all?size} -->

<!-- Tab Panel -->
<div role="tabpanel">
  <#assign overview = "false">

  <#list propertyGroups.all as groupTabs>
    <#assign groupName = groupTabs.getName(nameForOtherGroup)>
    <#if groupName = "overview" >
      <#assign overview = "true">
    </#if>
  </#list>
  <!-- Tab panes -->
  <div class="tab-content">

    <#if overview = "false">
      <div role="tabpanel" class="tab-pane active" id="overview">
        <#include "individual-overview.ftl">
      </div>
    </#if>

    <#list propertyGroups.all as group>
      <#if (group.properties?size > 0)>
        <#assign groupName = group.getName(nameForOtherGroup)>
        <#assign groupNameHtmlId = p.createPropertyGroupHtmlId(groupName) >
        <#assign verbose = (verbosePropertySwitch.currentValue)!false>

        <div role="tabpanel" class="tab-pane <#if tabCount = 1>active<#assign tabCount = 2></#if>" id="${groupNameHtmlId?replace("/","-")}">

          <nav id="scroller" class="scroll-up hidden" role="navigation">
            <a href="#branding" title="${i18n().scroll_to_menus}" >
              <img src="${urls.images}/individual/scroll-up.gif" alt="${i18n().scroll_to_menus}" />
            </a>
          </nav>
          
          <#-- Display the group heading --> 
          <#if groupName?has_content>
            <#--the function replaces spaces in the name with underscores, also called for the property group menu-->
            <#assign groupNameHtmlId = p.createPropertyGroupHtmlId(groupName) >
            <h2 id="${groupNameHtmlId?replace("/","-")}" pgroup="tabs" class="hidden">${groupName?capitalize}</h2>
          <#else>
            <h2 id="properties" pgroup="tabs" class="hidden">${i18n().properties_capitalized}</h2>
          </#if>
          <div id="${groupNameHtmlId?replace("/","-")}Group" >

            <#if groupName = "overview" >
              <#include "individual-overview.ftl">
            </#if>

            <#if groupName="supervision">
                <#include "individual-openForSupervision.ftl">
            </#if>

            <#if groupName="affiliation">
              <#assign displayOpenForCollab = !individual.mostSpecificTypes?seq_contains("Grant") >
              <#if displayOpenForCollab>
                <#include "individual-openForCollaboration.ftl">
              </#if>
            </#if>

            <#-- List the properties in the group   -->
            <#include "individual-properties.ftl">

            <#if groupName="overview">
                <#include "individual-openForSupervision.ftl">
            </#if>
          </div>

        </div>
        <#assign sectionCount = 2 >
      </#if>
    </#list>

    <!-- View All -->
    <#if (propertyGroups.all?size > 1) >
      <div roll="tabpanel" class="tab-pane" id="viewAll">
        <#list propertyGroups.all as group>
          <#if (group.properties?size > 0)>
            <#assign groupName = group.getName(nameForOtherGroup)>
            <#assign groupNameHtmlId = p.createPropertyGroupHtmlId(groupName) >
            <#assign verbose = (verbosePropertySwitch.currentValue)!false>

              <nav id="scroller" class="scroll-up hidden" role="navigation">
                <a href="#branding" title="${i18n().scroll_to_menus}" >
                  <img src="${urls.images}/individual/scroll-up.gif" alt="${i18n().scroll_to_menus}" />
                </a>
              </nav>

              <#-- Display the group heading --> 
              <#if groupName?has_content>
                <#--the function replaces spaces in the name with underscores, also called for the property group menu-->
                <#assign groupNameHtmlId = p.createPropertyGroupHtmlId(groupName) >
                <h2 id="${groupNameHtmlId?replace("/","-")}" pgroup="tabs" class="hidden">${groupName?capitalize}</h2>
              <#else>
                <h2 id="properties" pgroup="tabs" class="hidden">${i18n().properties_capitalized}</h2>
              </#if>
              <div id="${groupNameHtmlId?replace("/","-")}Group" >

                <#-- List the properties in the group   -->
                <#include "individual-properties.ftl">
              </div>

            <#assign sectionCount = 2 >
          </#if>
        </#list>
      </div>
    </#if>

  </div> <!-- / Tab panes -->
</div> <!-- / Tab Panel -->

<script>
  var individualLocalName = "${individual.localName}";
</script>

${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/individual/individual-property-groups.css" />')}
${headScripts.add('<script type="text/javascript" src="${urls.base}/js/amplify/amplify.store.min.js"></script>')}
${scripts.add('<script type="text/javascript" src="${urls.base}/js/individual/propertyGroupControls.js"></script>')}

