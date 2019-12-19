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
    <#assign geomapVisUrl = '${urls.base}${shortVisualizationURLRoot}/author-geomap/${egoLocalName}'>
    
<#else>

    <#assign coprincipalinvestigatorURL = '${urls.base}${shortVisualizationURLRoot}/investigator-network/?uri=${egoURI}'>
    <#assign mapOfScienceVisUrl = '${urls.base}${shortVisualizationURLRoot}/map-of-science/?uri=${egoURI}'>
    <#assign coAuthorVisUrl = '${urls.base}${shortVisualizationURLRoot}/author-network/?uri=${egoURI}'>
    <#assign geomapVisUrl = '${urls.base}${shortVisualizationURLRoot}/author-geomap/?uri=${egoURI}'>

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

    <#if (numOfCoAuthorShips?? && numOfCoAuthorShips > 0) >
        $("#coauth_table_container").empty().html('<img id="loadingData" width="auto" src="${loadingImageLink}" alt="${i18n().loading_data}"/>');
    </#if>
                
    processProfileInformation("ego_label", 
                              "ego_moniker",
                              "ego_profile_image",
                              jQuery.parseJSON(getWellFormedURLs("${egoURIParam}", "profile_info")));
    
    <#if (numOfCoAuthorShips?? && numOfCoAuthorShips <= 0) || (numOfAuthors?? && numOfAuthors <= 0) >  
            if ($('#ego_label').text().length > 0) {
                setProfileName('no_coauthorships_person', $('#ego_label').text());
            }
    </#if>
    
    
        $.ajax({
                url: "${urls.base}/visualizationAjax",
                data: ({vis: "utilities", vis_mode: "SHOW_GRANTS_LINK", uri: '${egoURIParam}'}),
                dataType: "json",
                success:function(data){
                
                    /*
                    Collaboratorship links do not show up by default. They should show up only if there any data to
                    show on that page. 
                    */
                    if (data.numOfGrants !== undefined && data.numOfGrants > 0) {
                           $(".toggle_visualization").show();                    
                    }
                
                }
            });
                    
});
</script>



	
    
    
    
    <#if (numOfAuthors?? && numOfAuthors > 0) >
    
        
        
    
    <#else>
    
        <span id="no_coauthorships">${i18n().no_papers_for} 
            <a href="${egoVivoProfileURL}" title="${i18n().co_authorship}"><span id="no_coauthorships_person" class="author_name">${i18n().this_author}</span></a> ${i18n().in_the_vivo_db}
        </span>
    
    </#if>
            
    <#if (numOfCoAuthorShips?? && numOfCoAuthorShips > 0) || (numOfAuthors?? && numOfAuthors > 0) >
    
            <div id="individual-sidebar">
                
                <div id="data-panel-content">
                <div id="profileImage"></div>
            
                <div id="sidebarStats" class="panel panel-primary">
                <h4 id="sidebarStatsHeading" class="panel-heading">Author Stats</h4>

                <div class="author_stats" id="num_works"><span class="numbers" style="width: 40px;" id="works"></span>&nbsp;&nbsp;
                <span class="author_stats_text">${i18n().publication_s_capitalized}</span></div>
                <div class="author_stats" id="num_authors"><span class="numbers" style="width: 40px;" id="coAuthors"></span>
                &nbsp;&nbsp;<span class="author_stats_text">${i18n().co_author_s_capitalized}</span></div>
                
                <div class="author_stats" id="fPub" style="visibility:hidden">
                    <span class="numbers" style="width:40px;" id="firstPublication"></span>&nbsp;&nbsp;<span>${i18n().first_publication}</span></div>
                <div class="author_stats" id="lPub" style="visibility:hidden"><span class="numbers" style="width:40px;" id="lastPublication"></span>
                &nbsp;&nbsp;<span>${i18n().last_publication}</span></div>
                <div id="profile-links"><a href="#" id="profileUrl" title="${i18n().vivo_profile}">${i18n().vivo_profile}</a></div>
                <div id="incomplete-data" class="alert alert-warning">${i18n().incomplete_data_note1}<p></p><p></p>
                </div>
                
                <div class="vis_stats">
        
        
                    <div class="vis-tables">
                
                        <#assign tableID = "publication_data_table" />
                        <#assign tableCaption = "${i18n().publications_per_year} " />
                        <#assign tableActivityColumnName = "${i18n().publications_capitalized}" />
                        <#assign tableContent = egoPubSparklineVO.yearToActivityCount />
                        <#assign fileDownloadLink = egoPubSparklineVO.downloadDataLink />
                
                        <#include "yearToActivityCountTable.ftl">

                
                    </div>
            
                    <#if (numOfCoAuthorShips?? && numOfCoAuthorShips > 0) >
                    <div class="vis-tables">
                        <p id="coauth_table_container" class="datatable"></p>
                    </div>
                    </#if>
            
                    <div style="clear:both"></div>
        
                </div>
                </div>
                </div>
            </div>


        <#-- Sparkline -->
        <div id="sparkline-container" class="viz-spacer">
    <#if (numOfAuthors?? && numOfAuthors > 0) >
            
            <#assign displayTable = false />
            
            <#assign sparklineVO = egoPubSparklineVO />
            <div id="publication-count-sparkline-include" class="panel panel-primary">
                <h4 class="panel-heading">Visualisations</h4>
                    <div id="publication-count-sparkline-include">
                        <span class="glyphicon glyphicon-stats"></span>&nbsp;<span id="sparklineHeading">Publication History</span> 
                        <#include "personPublicationSparklineContent.ftl">
                    </div>
            
                    <#assign sparklineVO = uniqueCoauthorsSparklineVO />
                    <div id="coauthor-count-sparkline-include">
                        <span class="glyphicon glyphicon-stats"></span>&nbsp;<span id="sparklineHeading">Co-Author History</span> 
                        <#include "coAuthorshipSparklineContent.ftl">
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
            
            
            
            </div> <!-- end panel-body -->

        </#if>
        </div>  
    
        
    


<div id="vis-container">

	<div id="vis-headings" class="individual-details">
        <h1 class="vcard foaf-person"><span class="fn"><span id="ego_label"></span></span></h1>
    <#if (numOfCoAuthorShips?? && numOfCoAuthorShips > 0) || (numOfAuthors?? && numOfAuthors > 0) > 
    <#else>
            <#if numOfAuthors?? && numOfAuthors <= 0 >
                <#assign authorsText = "multi-author" />
            </#if>
            <div id="no_coauthorships">${i18n().currently_no_papers_for(authorsText!)} 
                <a href="${egoVivoProfileURL}" title="${i18n().co_authorship}"><span id="no_coauthorships_person" class="author_name">${i18n().this_author}</span></a> ${i18n().in_the_vivo_db}
            </div>                      
    </#if>
    </div>

            <div id="visPanel">
                <script language="JavaScript" type="text/javascript">
                    <!--
                    renderCollaborationshipVisualization();
                    //-->
                </script>
            </div>
    </#if>


</div>
