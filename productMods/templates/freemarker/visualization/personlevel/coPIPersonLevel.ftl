<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#assign standardVisualizationURLRoot ="/visualization">
<#assign shortVisualizationURLRoot ="/vis">
<#assign ajaxVisualizationURLRoot ="/visualizationAjax">
<#assign dataVisualizationURLRoot ="/visualizationData">

<#assign egoURI ="${egoURIParam?url}">
<#assign egoCoInvestigationDataFeederURL = '${urls.base}${dataVisualizationURLRoot}?vis=coprincipalinvestigator&uri=${egoURI}&vis_mode=copi_network_stream&labelField=label'>

<#assign coauthorshipURL = '${urls.base}${shortVisualizationURLRoot}/author-network/?uri=${egoURI}'>

<#if egoLocalName?has_content >
    
    <#assign coauthorshipURL = '${urls.base}${shortVisualizationURLRoot}/author-network/${egoLocalName}'>
    <#assign coAuthorVisUrl = '${urls.base}${shortVisualizationURLRoot}/author-network/${egoLocalName}'>
    <#assign coprincipalinvestigatorURL = '${urls.base}${shortVisualizationURLRoot}/investigator-network/${egoLocalName}'>
    <#assign mapOfScienceVisUrl = '${urls.base}${shortVisualizationURLRoot}/map-of-science/${egoLocalName}'>
    <#assign geomapVisUrl = '${urls.base}${shortVisualizationURLRoot}/author-geomap/${egoLocalName}'>
    
<#else>

    <#assign coauthorshipURL = '${urls.base}${shortVisualizationURLRoot}/author-network/?uri=${egoURI}'>
    <#assign coauthorVisUrl = '${urls.base}${shortVisualizationURLRoot}/author-network/?uri=${egoURI}'>
    <#assign coprincipalinvestigatorURL = '${urls.base}${shortVisualizationURLRoot}/investigator-network/?uri=${egoURI}'>
    <#assign mapOfScienceVisUrl = '${urls.base}${shortVisualizationURLRoot}/map-of-science/?uri=${egoURI}'>
    <#assign geomapVisUrl = '${urls.base}${shortVisualizationURLRoot}/author-geomap/?uri=${egoURI}'>

</#if>

<#assign egoCoInvestigatorsListDataFileURL = '${urls.base}${dataVisualizationURLRoot}?vis=coprincipalinvestigator&uri=${egoURI}&vis_mode=copis'>
<#assign egoCoInvestigationNetworkDataFileURL = '${urls.base}${dataVisualizationURLRoot}?vis=coprincipalinvestigator&uri=${egoURI}&vis_mode=copi_network_download'>

<#assign coAuthorIcon = '${urls.images}/visualization/coauthorship/co_author_icon.png'>

<#assign swfLink = '${urls.images}/visualization/coauthorship/EgoCentric.swf'>
<#assign adobeFlashDetector = '${urls.base}/js/visualization/coauthorship/AC_OETags.js'>
<#assign googleVisualizationAPI = 'https://www.google.com/jsapi?autoload=%7B%22modules%22%3A%5B%7B%22name%22%3A%22visualization%22%2C%22version%22%3A%221%22%2C%22packages%22%3A%5B%22areachart%22%2C%22imagesparkline%22%5D%7D%5D%7D'>
<#assign coInvestigatorPersonLevelJavaScript = '${urls.base}/js/visualization/coPIship/coPIship-person-level.js'>
<#assign commonPersonLevelJavaScript = '${urls.base}/js/visualization/personlevel/person-level.js'>

<script type="text/javascript" src="${adobeFlashDetector}"></script>
<script type="text/javascript" src="${googleVisualizationAPI}"></script>

<script language="JavaScript" type="text/javascript">
<!--
// -----------------------------------------------------------------------------
// Globals
// Major version of Flash required
var requiredMajorVersion = 10;
// Minor version of Flash required
var requiredMinorVersion = 0;
// Minor version of Flash required
var requiredRevision = 0;
// -----------------------------------------------------------------------------

var swfLink = "${swfLink}";
var egoURI = "${egoURI}";
var unEncodedEgoURI = "${egoURIParam}";
var egoCoInvestigationDataFeederURL = "${egoCoInvestigationDataFeederURL}";
var egoCoInvestigatorsListDataFileURL = "${egoCoInvestigatorsListDataFileURL}";

var contextPath = "${urls.base}";

var visualizationDataRoot = "${dataVisualizationURLRoot}";

// -->
var i18nStringsCoPi = {
    coInvestigatorString: '${i18n().co_inestigators_capitalized}',
    investigatorString: '${i18n().investigator_capitalized}',
    grantsWithString: '${i18n().grants_with}',
    grantsCapitalized: '${i18n().grant_s_capitalized}',
    coInvestigatorCapitalized: '${i18n().co_investigator_s_capitalized}'
};
var i18nStringsPersonLvl = {
    fileCapitalized: '${i18n().file_capitalized}',
    contentRequiresFlash: '${i18n().content_requires_flash}',
    getFlashString: '${i18n().get_flash}'
};
</script>

<script type="text/javascript" src="${coInvestigatorPersonLevelJavaScript}"></script>
<script type="text/javascript" src="${commonPersonLevelJavaScript}"></script>

${scripts.add('<script type="text/javascript" src="${urls.base}/js/visualization/visualization-helper-functions.js"></script>')}

${stylesheets.add('<link rel="stylesheet" type="text/css" href="${urls.base}/css/visualization/personlevel/page.css" />',
                  '<link rel="stylesheet" type="text/css" href="${urls.base}/css/visualization/visualization.css" />')}

<#assign loadingImageLink = "${urls.images}/visualization/ajax-loader.gif">

<#assign egoVivoProfileURL = "${urls.base}/individual?uri=${egoURI}" />

<script language="JavaScript" type="text/javascript">

$(document).ready(function(){
        
    <#if (numOfCoInvestigations?? && numOfCoInvestigations > 0) >
        $("#coinve_table_container").empty().html('<img id="loadingData" width="auto" src="${loadingImageLink}" alt="${i18n().loading_data}"/>');
    </#if>
                
        
    processProfileInformation("ego_label", 
                              "ego_moniker",
                              "ego_profile_image",
                              jQuery.parseJSON(getWellFormedURLs("${egoURIParam}", "profile_info")));
    
    <#if (numOfCoInvestigations?? && numOfCoInvestigations <= 0) || (numOfInvestigators?? && numOfInvestigators <= 0) >  
            if ($('#ego_label').text().length > 0) {
                setProfileName('no_coinvestigations_person', $('#ego_label').text());
            }
    </#if>
    
        
            $.ajax({
                url: "${urls.base}/visualizationAjax",
                data: ({vis: "utilities", vis_mode: "SHOW_AUTHORSHIP_LINK", uri: '${egoURIParam}'}),
                dataType: "json",
                success:function(data){
                
                    /*
                    Collaboratorship links do not show up by default. They should show up only if there any data to
                    show on that page. 
                    */
                    if (data.numOfPublications !== undefined && data.numOfPublications > 0) {
                           $(".toggle_visualization").show();                    
                    }
                
                }
            });        
                    
});
</script>


    <div id="individual-sidebar">
        <div id="data-panel-content">
            <div id="profileImage"></div>
            <div id="sidebarStats" class="panel panel-primary">
                <h4 id="sidebarStatsHeading" class="panel-heading">Investigator Stats</h4>

                <div class="investigator_stats" id="num_works"><span class="numbers" style="width: 40px;" id="works"></span>&nbsp;&nbsp;
                <span class="investigator_stats_text">${i18n().grant_s_capitalized}</span></div>
                <div class="investigator_stats" id="num_investigators"><span class="numbers" style="width: 40px;" id="coInvestigators"></span>
                &nbsp;&nbsp;<span class="investigator_stats_text">${i18n().co_investigator_s_capitalized}</span></div>
                
                <div class="investigator_stats" id="fGrant" style="visibility:hidden">
                    <span class="numbers" style="width:40px;" id="firstGrant"></span>&nbsp;&nbsp;<span>${i18n().first_grant}</span></div>
                <div class="investigator_stats" id="lGrant" style="visibility:hidden"><span class="numbers" style="width:40px;" id="lastGrant"></span>
                &nbsp;&nbsp;<span>${i18n().last_grant}</span></div>
                <div id="profile-links"><a href="#" id="profileUrl" title="${i18n().vivo_profile}">${i18n().vivo_profile}</a></div> 
                <div id="incomplete-data" class="alert alert-warning">${i18n().incomplete_grant_data_note1}<p></p><p></p></div>
        <div class="vis_stats">
            <div class="vis-tables">
                <p id="grants_table_container" class="datatable">
                <#assign tableID = "grant_data_table" />
                <#assign tableCaption = "${i18n().grants_per_year}" />
                <#assign tableActivityColumnName = "${i18n().grants_capitalized}" />
                <#assign tableContent = egoGrantSparklineVO.yearToActivityCount />
                <#assign fileDownloadLink = egoGrantSparklineVO.downloadDataLink />
                <#include "yearToActivityCountTable.ftl">
                </p>
            </div>
            <#if (numOfCoInvestigations?? && numOfCoInvestigations > 0) >
                <div class="vis-tables">
                <p id="coinve_table_container" class="datatable"></p>
                </div>
            </#if>
            <div style="clear:both"></div>
        </div>
        </div>
        </div>

    </div>
    <div id="sparkline-container" class="viz-spacer">
        <#-- Sparkline -->
        <#if (numOfInvestigators?? && numOfInvestigators > 0) >
            <#assign displayTable = false />
            <#assign sparklineVO = egoGrantSparklineVO />
            <div id="grant-count-sparkline-include" class="panel panel-primary">
                <h4 class="panel-heading">Visualisations</h4>
                <span class="glyphicon glyphicon-stats"></span>&nbsp;<span id="sparklineHeading">Grant History</span>
                <#include "personGrantSparklineContent.ftl">
            
                <#assign sparklineVO = uniqueCoInvestigatorsSparklineVO />
                <div id="coinvestigator-count-sparkline-include">
                    <span class="glyphicon glyphicon-stats"></span>&nbsp;<span id="sparklineHeading">Co-Investigators</span> 
                    <#include "coInvestigationSparklineContent.ftl">
                </div>
            

            <div id="coauthorship_link_container" class="collaboratorship-link-container">
                <a href="${coAuthorVisUrl}" title="${i18n().co_author_network}">
                    <div class="collaboratorship-link">
                        <span class="glyphicon glyphicon-book"></span>&nbsp;${i18n().co_author_network}
                    </div>
                </a>
            </div> 

            <div id="coinvestigator_link_container" class="collaboratorship-link-container">
                <a href="${coprincipalinvestigatorURL}" title="${i18n().co_investigator_network}">
                    <div class="collaboratorship-link">
                        <span class="glyphicon glyphicon-usd"></span>&nbsp;${i18n().co_investigator_network}
                    </div>
                </a>
            </div>

            <div id="coauthorship_link_container" class="collaboratorship-link-container">
                <a href="${geomapVisUrl}" title="Collaborator Map">
                    <div class="collaboratorship-link">
                        <span class="glyphicon glyphicon-globe"></span>&nbsp;Collaborator Map
                    </div>
                </a>
            </div>


            <div id="mapofscience_link_container" class="collaboratorship-link-container">
                <a href="${mapOfScienceVisUrl}" title="${i18n().map_of_science}">
                    <div class="collaboratorship-link">
                        <span class="glyphicon glyphicon-search"></span>&nbsp;${i18n().map_of_science_capitalized}
                    </div>
                </a>
            </div>


            </div> <!-- end panel-primary -->
        </#if>
    </div>  
    <div id="vis-container">
        <div id="vis-headings" class="individual-details">
            <h1 class="vcard foaf-person">
                <span class="fn">
                    <span id="ego_label"></span>
                </span>
            </h1>
            <div class="graphml-file-link">
            <#if (numOfCoInvestigations?? && numOfCoInvestigations > 0) || (numOfInvestigators?? && numOfInvestigators > 0) > 
            <#else>
                <#if numOfInvestigators?? && numOfInvestigators <= 0 >
                    <#assign investigatorsText = "multi-investigator" />
                </#if>
                <span id="no_coinvestigations">${i18n().currently_no_grants_for(investigatorsText!)} 
                    <a href="${egoVivoProfileURL}" title="${i18n().investigator_name}"><span id="no_coinvestigations_person" class="investigator_name">${i18n().this_investigator}</span></a> ${i18n().in_the_vivo_db}
                </span>                     
            </#if>
                
            </div>
        </div>
        <#if (numOfInvestigators?? && numOfInvestigators > 0) >
        <#else>
        <span id="no_coinvestigations">${i18n().no_grants_for}
            <a href="${egoVivoProfileURL}" title="${i18n().co_investigator}"><span id="no_coinvestigations_person" class="investigator_name">${i18n().this_investigator}</span></a> ${i18n().in_the_vivo_db}
        </span>
    
        </#if>
        <div id="visPanel">
            <script language="JavaScript" type="text/javascript">
            <!--
            renderCollaborationshipVisualization();
            //-->
            </script>
        </div>
    </div>
