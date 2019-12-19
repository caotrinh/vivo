<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#assign standardVisualizationURLRoot ="/visualization">
<#assign shortVisualizationURLRoot ="/vis">
<#assign ajaxVisualizationURLRoot ="/visualizationAjax">
<#assign dataVisualizationURLRoot ="/visualizationData">

<#assign egoURI ="${egoURIParam?url}">
<#assign egoCoAuthorshipDataFeederURL = '${urls.base}${dataVisualizationURLRoot}?vis=coauthorship&uri=${egoURI}&vis_mode=coauthor_network_stream&labelField=label'>

<#if egoLocalName?has_content >
    
    <#assign coprincipalinvestigatorURL = '${urls.base}${shortVisualizationURLRoot}/investigator-network/${egoLocalName}'>
    <#assign mapOfScienceVisUrl = '${urls.base}${shortVisualizationURLRoot}/map-of-science/${egoLocalName}'>
    <#assign coAuthorVisUrl = '${urls.base}${shortVisualizationURLRoot}/author-network/${egoLocalName}'>
    <#assign profileURL = "${urls.base}/individual/${egoLocalName}" />
    
<#else>

    <#assign coprincipalinvestigatorURL = '${urls.base}${shortVisualizationURLRoot}/investigator-network/?uri=${egoURI}'>
    <#assign mapOfScienceVisUrl = '${urls.base}${shortVisualizationURLRoot}/map-of-science/?uri=${egoURI}'>
    <#assign coAuthorVisUrl = '${urls.base}${shortVisualizationURLRoot}/author-network/?uri=${egoURI}'>
    <#assign profileURL = "${urls.base}/individual?uri=${egoURI}" />

</#if>



<#assign egoCoAuthorsListDataFileURL = '${urls.base}${dataVisualizationURLRoot}?vis=coauthorship&uri=${egoURI}&vis_mode=coauthors'>
<#assign egoCoAuthorshipNetworkDataFileURL = '${urls.base}${dataVisualizationURLRoot}?vis=coauthorship&uri=${egoURI}&vis_mode=coauthor_network_download'>

<#assign swfLink = '${urls.images}/visualization/coauthorship/EgoCentric.swf'>
<#assign adobeFlashDetector = '${urls.base}/js/visualization/coauthorship/AC_OETags.js'>
<#assign googleVisualizationAPI = 'https://www.google.com/jsapi?autoload=%7B%22modules%22%3A%5B%7B%22name%22%3A%22visualization%22%2C%22version%22%3A%221%22%2C%22packages%22%3A%5B%22areachart%22%2C%22imagesparkline%22%5D%7D%5D%7D'>
<#assign coAuthorPersonLevelJavaScript = '${urls.base}/js/visualization/coauthorship/coauthorship-personlevel.js'>
<#assign commonPersonLevelJavaScript = '${urls.base}/js/visualization/personlevel/person-level.js'>

<#assign coInvestigatorIcon = '${urls.images}/visualization/coauthorship/co_investigator_icon.png'>


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
var egoCoAuthorshipDataFeederURL = "${egoCoAuthorshipDataFeederURL}";
var egoCoAuthorsListDataFileURL = "${egoCoAuthorsListDataFileURL}";
var contextPath = "${urls.base}";

var visualizationDataRoot = "${dataVisualizationURLRoot}";

// -->
var i18nStringsCoauthorship = {
    coAuthorsString: '${i18n().co_authors_capitalized}',
    authorString: '${i18n().author_capitalized}',
    publicationsWith: '${i18n().publications_with}',
    publicationsString: '${i18n().publication_s_capitalized}',
    coauthorsString: '${i18n().co_author_s_capitalized}'
};
var i18nStringsPersonLvl = {
    fileCapitalized: '${i18n().file_capitalized}',
    contentRequiresFlash: '${i18n().content_requires_flash}',
    getFlashString: '${i18n().get_flash}'
};
</script>

<script type="text/javascript" src="${coAuthorPersonLevelJavaScript}"></script>
<script type="text/javascript" src="${commonPersonLevelJavaScript}"></script>

${scripts.add('<script type="text/javascript" src="${urls.base}/js/visualization/visualization-helper-functions.js"></script>')}

${stylesheets.add('<link rel="stylesheet" type="text/css" href="${urls.base}/css/visualization/personlevel/page.css" />',
                  '<link rel="stylesheet" type="text/css" href="${urls.base}/css/visualization/visualization.css" />')}

<#assign loadingImageLink = "${urls.images}/visualization/ajax-loader.gif">

<#assign egoVivoProfileURL = "${urls.base}/individual?uri=${egoURI}" />

<script language="JavaScript" type="text/javascript">

$(document).ready(function(){
    processProfileInformation("ego_label", 
                              "ego_moniker",
                              "profileImage",
                              jQuery.parseJSON(getWellFormedURLs("${egoURIParam}", "profile_info")));
    setProfileName( 'authorName', $('#ego_label').text(), false );
                    
});
</script>

    
            <div id="individual-sidebar">
                <div id="data-panel-content">
                <div id="profileImage"></div>
                
                <div id="sidebarStats" class="panel panel-primary">
                <h4 class="panel-heading">Collaboration Stats</h4>

                <div class="author_stats" id="num_works">
                    <span class="numbers" style="width: 40px;" id="works"></span>&nbsp;&nbsp;<span class="author_stats_text">${i18n().publication_s_capitalized}</span>
                </div>
                <div class="author_stats" id="num_authors">
                    <span class="numbers" style="width: 40px;" id="coAuthors"></span>&nbsp;&nbsp;<span class="author_stats_text">${i18n().co_author_s_capitalized}</span>
                </div>
                
                <div class="author_stats" id="fPub" style="visibility:hidden">
                    <span class="numbers" style="width:40px;" id="firstPublication"></span>&nbsp;&nbsp;<span>${i18n().first_publication}</span>
                </div>
                <div class="author_stats" id="lPub" style="visibility:hidden">
                    <span class="numbers" style="width:40px;" id="lastPublication"></span>&nbsp;&nbsp;<span>${i18n().last_publication}</span>
                </div>
                <div id="profile-links"><a href="${profileURL}" id="profileUrl" title="${i18n().vivo_profile}">${i18n().vivo_profile}</a></div>
                <div id="incomplete-data" class="alert alert-warning">${i18n().incomplete_data_note1}<p></p><p></p></div>
                </div>
                </div>
                
            </div>


        <#-- Sparkline -->


        <div id="sparkline-container" class="viz-spacer">
            
            <#assign sparklineVO = egoPubSparklineVO />
            <div id="publication-count-sparkline-include" class="panel panel-primary">
                <h4 class="panel-heading">Visualisations</h4>

                <span class="glyphicon glyphicon-stats"></span>&nbsp;<span id="sparklineHeading">Publication History</span> 
                <#include "personPublicationSparklineContent.ftl">
            
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
                <a href="" title="Collaborator Map">
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
            </div> <!-- panel-primary -->

        </div>  
    
        
    


<div id="vis-container">

	<div id="vis-headings" class="individual-details">
        <h1 class="vcard foaf-person"><span class="fn"><span id="ego_label">${egoLocalName}</span></span></h1>
    </div>

               <div id="visPanel">
                    <div id="geomap_div"></div>
                
                    
                <script type="text/javascript" src="https://www.google.com/jsapi"></script>
                <script language="JavaScript" type="text/javascript">
                google.load("visualization", "1", {packages:["geochart"]});
                google.setOnLoadCallback(drawRegionsMap);

                function drawRegionsMap() {    
                
                    var data = google.visualization.arrayToDataTable([
                    ['Country','Publications','Grants']
                    ${geoData}
                    ]);
                    
                    var options = {
                        'backgroundColor':'#ffffff',
                        'colorAxis' : { colors: ['#FFE6E6', '#EF4135']},
                        'backgroundColor.stroke' : '#999',
                        'backgroundColor.strokeWidth' : 6,
                        width: 598,
                        height: 398
                                    };

                    var chart = new google.visualization.GeoChart(document.getElementById('geomap_div'));

                    chart.draw(data, options);
                }

                </script>
            </div>



</div>
