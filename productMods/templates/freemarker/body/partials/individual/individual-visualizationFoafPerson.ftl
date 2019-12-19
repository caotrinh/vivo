<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Template for sparkline visualization on individual profile page -->

<#-- Determine whether this person is an author -->
<#assign isAuthor = p.hasVisualizationStatements(propertyGroups, "${core}relatedBy", "${core}Authorship") />

<#-- Determine whether this person is involved in any grants -->
<#assign obo_RO53 = "http://purl.obolibrary.org/obo/RO_0000053">

<#assign isInvestigator = ( p.hasVisualizationStatements(propertyGroups, "${obo_RO53}", "${core}InvestigatorRole") ||
                            p.hasVisualizationStatements(propertyGroups, "${obo_RO53}", "${core}PrincipalInvestigatorRole") || 
                            p.hasVisualizationStatements(propertyGroups, "${obo_RO53}", "${core}CoPrincipalInvestigatorRole") ) >

<#if (isAuthor || isInvestigator)>
 
    ${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/visualization/visualization.css" />')}
    <#assign standardVisualizationURLRoot ="/visualization">
        
        <#if isAuthor>
            <#assign coAuthorIcon = "${urls.images}/visualization/coauthorship/co_author_icon.png">
            <#assign mapOfScienceIcon = "${urls.images}/visualization/mapofscience/scimap_icon.png">
            <#assign mapOfScienceVisUrl = individual.mapOfScienceUrl()>
            <#assign coAuthorVisUrl = individual.coAuthorVisUrl()>
            <#assign geomapVisUrl = "${urls.base}/vis/author-geomap/"+individual.getLocalName()>
            
            <#assign googleJSAPI = "https://www.google.com/jsapi?autoload=%7B%22modules%22%3A%5B%7B%22name%22%3A%22visualization%22%2C%22version%22%3A%221%22%2C%22packages%22%3A%5B%22imagesparkline%22%5D%7D%5D%7D"> 
            
            
            <div id="vis_container_coauthor">
                <span class="glyphicon glyphicon-stats"></span>&nbsp;
                <span id="sparklineHeading">${i18n().publications_in_vivo}</span>
                <div id="vis_container_coauthor_inner">&nbsp;</div>
            </div>
            
            <div class="collaboratorship-link-separator"></div>
            <div id="coauthorship_link_container" class="collaboratorship-link-container">
                <a href="${coAuthorVisUrl}" title="${i18n().co_author_network}">
                    <div class="collaboratorship-link">
                        <span class="glyphicon glyphicon-book"></span>&nbsp;${i18n().co_author_network}
                    </div>
                </a>
            </div>
            
            
                <div class="collaboratorship-link-separator"></div>
                <#assign coInvestigatorVisUrl = individual.coInvestigatorVisUrl()>
                <#assign coInvestigatorIcon = "${urls.images}/visualization/coauthorship/co_investigator_icon.png">
            
            <div id="coinvestigator_link_container" class="collaboratorship-link-container">
                <a href="${coInvestigatorVisUrl}" title="${i18n().co_investigator_network}">
                    <div class="collaboratorship-link">
                        <span class="glyphicon glyphicon-usd"></span>&nbsp;${i18n().co_investigator_network}
                    </div>
                </a>
            </div>
            
            <div class="collaboratorship-link-separator"></div>
            <div id="coauthorship_link_container" class="collaboratorship-link-container">
                <a href="${geomapVisUrl}" title="Collaborator Map">
                    <div class="collaboratorship-link">
                        <span class="glyphicon glyphicon-globe"></span>&nbsp;Collaborator Map
                    </div>
                </a>
            </div>
            
            <div class="collaboratorship-link-separator"></div>
            
  	      	<div id="mapofscience_link_container" class="collaboratorship-link-container">
                <a href="${mapOfScienceVisUrl}" title="${i18n().map_of_science}">
                    <div class="collaboratorship-link">
                        <span class="glyphicon glyphicon-search"></span>&nbsp;${i18n().map_of_science_capitalized}
                    </div>
                </a>
            </div>
            
            ${scripts.add('<script type="text/javascript" src="${googleJSAPI}"></script>',
                          '<script type="text/javascript" src="${urls.base}/js/visualization/visualization-helper-functions.js"></script>',
                          '<script type="text/javascript" src="${urls.base}/js/visualization/sparkline.js"></script>')}           
            
            <script type="text/javascript">
                var visualizationUrl = '${urls.base}/visualizationAjax?uri=${individual.uri?url}&template=${visRequestingTemplate!}';
                var infoIconSrc = '${urls.images}/iconInfo.png';
            </script>
            
        </#if>
        
        <#if isInvestigator>
        </#if>
</#if>
