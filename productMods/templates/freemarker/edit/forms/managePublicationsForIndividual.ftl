<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#import "lib-vivo-form.ftl" as lvf>
<#import "lib-datetime.ftl" as dt>

<#-- Custom form for managing web pages for individuals -->
<div id="manage-records-for" class="panel panel-default">
    <div class="panel-heading">
        <#if subjectName?contains(",") >
            <#assign lastName = subjectName?substring(0,subjectName?index_of(",")) />
            <#assign firstName = subjectName?substring(subjectName?index_of(",") + 1) />

            ${i18n().manage_publications_for} ${firstName} ${lastName}
              <li> <b>Publications and grant data for UOW Scholars are automatically sourced from RIS Pubs and RIS Grants. They are not editable. 
		Please ensure that your data is correct in RIS by contacting the  <a href="https://www.uow.edu.au/library/">Library team </a>. 
              	For more information about your publications and grants in UOW Scholars, please visit the <a href="https://intranet.uow.edu.au/raid/scholars/UOW212426.html?">UOW Scholars FAQ </a>
           </b></li>
         
      <#else>
            ${i18n().manage_publications_for} ${subjectName}
            <li> <b>Publications and grant data for UOW Scholars are automatically sourced from RIS Pubs and RIS Grants. They are not editable.
                Please ensure that your data is correct in RIS by contacting the  <a href="https://www.uow.edu.au/library/">Library team </a>.
                For more information about your publications and grants in UOW Scholars, please visit the <a href="https://intranet.uow.edu.au/rai$
           </b></li>
        </#if>
    </div>
    <div class="panel-body">
        <p style="margin-left:25px;margin-bottom:12px">
            <script type="text/javascript">
                var publicationData = [];
                var topPubData = [];
                var personUri = "${subjectUri}";
            </script>
        </p>
        <#list topPublications as toppub>
            <#if toppub.dateTime?has_content>
                <#assign topPubDateTimeStr = toppub.dateTime?replace("T", " ")?replace("Z.*$", "", "r")?trim>
                <#assign topPubDateTimeObj = topPubDateTimeStr?datetime("yyyy-MM-dd HH:mm:ss")>
                <#assign topPubYear = topPubDateTimeObj?string('yyyy')>
            <#else>
                <#assign topPubYear = "">
            </#if>
            <script type="text/javascript">
                topPubData.push({"toppubUri": "${toppub.toppub}", "order": ${toppub.rank}, "title": "${toppub.title!?js_string}", "hideThis": "${toppub.hideThis!}", "year":"${topPubYear}"});
            </script>
        </#list>

        <@lvf.unsupportedBrowser urls.base />
        <div class="panel panel-default">
            <div class="panel-heading">
                ${i18n().panel_head_top_publications}
            </div>
            <div class="panel-body pubManageInstruction">
                <ul>
                    <li><i class="fa fa-star"></i> ${i18n().manage_pub_instruction_remove}</li>
                    <li><i class="fa fa-arrows"></i> ${i18n().manage_pub_instruction_reorder} </li>
                    <li><i class="fa fa-eye-slash"></i> ${i18n().manage_pub_instruction_hidden_toppub} </li>
                </ul>
            </div>
            <div id="noTopPubs" class="alert alert-info <#if topPublications?has_content>hidden</#if>" role="alert"><i class="fa fa-info-circle"></i>&nbsp;${i18n().manage_pub_no_top_pubs}</div>
            <div id="topPubs" class="<#if !topPublications?has_content>hidden</#if>">
                <span class="icon-sort-by-order-alt" id="orderLatestYearFirst"></span>
                <span class="icon-sort-by-order" id="orderOldestYearFirst"></span>
                <label for="orderTopPubsbyYear">Order Top Publications by Year</label>
                <table class="table" id="topPubSortable"></table>
            </div>
        </div>
        <div class="panel panel-default" id="publicationsManagement">
            <div class="panel-heading">
                ${i18n().panel_head_publications}
            </div>
            <div class="panel-body pubManageInstruction">
                <ul>
                    <li><i class="fa fa-star-o"></i> ${i18n().manage_pub_instruction_add_remove}</li>
                    <li><i class="fa fa-eye"></i> ${i18n().manage_pub_instruction_hide}</li>
                    <li><i class="fa fa-eye-slash"></i> ${i18n().manage_pub_instruction_show}</li>
                </ul>
            </div>
            <input type="checkbox" id="showHideAllPubs"> <label for="showHideAllPubs" class="showHideAllLabel">Show/Hide all Publications</label>
            <#list allSubclasses as sub>
                <h4>
                    <#if sub = "Software">
                        ${sub}
                    <#elseif sub = "Thesis">
                        ${i18n().theses_capitalized}
                    <#elseif sub = "Speech">
                        ${i18n().speeches_capitalized}
                    <#else>
                        ${sub}s
                    </#if>
                </h4><hr>
                <section id="pubsContainer" role="container">
                    <#assign pubs = publications[sub]>
                    <table class="table">
                        <#list pubs as pub>
                            <#if pub.dateTime?has_content>
                                <#assign pubDateTimeStr = pub.dateTime?replace("T", " ")?replace("Z.*$", "", "r")?trim>
                                <#assign pubDateTimeObj = pubDateTimeStr?datetime("yyyy-MM-dd HH:mm:ss")>
                                <#assign pubYear = pubDateTimeObj?string('yyyy')>
                            <#else>
                                <#assign pubYear = "">
                            </#if>
                            <tr class="allPubs">
                                <script type="text/javascript">
                                    publicationData.push({"authorshipUri": "${pub.authorship}", "title": "${pub.title!?js_string}", "hideThis": "${pub.hideThis!}", "year":"${pubYear}"});
                                </script>
                            </tr>
                        </#list>
                    </table>
                </section>
            </#list>
            <#if pubEditorships?has_content>
                <h4>Editor Of</h4><hr>
                <table class="table">
                    <#list pubEditorships as pubEditor>
                        <#if pubEditor.dateTime?has_content>
                            <#assign pubEditorDateTimeStr = pubEditor.dateTime?replace("T", " ")?replace("Z.*$", "", "r")?trim>
                            <#assign pubEditorDateTimeObj = pubEditorDateTimeStr?datetime("yyyy-MM-dd HH:mm:ss")>
                            <#assign pubEditorYear = pubDateTimeObj?string('yyyy')>
                        <#else>
                            <#assign pubEditorYear = "">
                        </#if>
                        <tr class="allPubs">
                            <script type="text/javascript">
                                publicationData.push({"authorshipUri": "${pubEditor.authorship}", "title": "${pubEditor.title!?js_string}", "hideThis": "${pubEditor.hideThis!}", "year":"${pubEditorYear}"});
                            </script>
                        </tr>
                    </#list>
                </table>
            </#if>

        </div>
        <p>
            <a href="${urls.referringPage}#publications" title="${i18n().return_to_profile}">${i18n().return_to_profile}</a>
        </p>
    </div>
</div>

<script type="text/javascript">
var customFormData = {
    processingUrl: '${urls.base}/edit/primitiveRdfEdit'
};
var i18nStrings = {
    publicationSuccessfullyExcluded: '${i18n().publication_successfully_excluded}',
    errorExcludingPublication: '${i18n().error_excluding_publication}'
};
</script>

${stylesheets.add('<link rel="stylesheet" href="${urls.base}/templates/freemarker/edit/forms/css/customForm.css" />',
                  '<link rel="stylesheet" href="${urls.base}/js/jquery-ui/css/smoothness/jquery-ui-1.8.9.custom.css" />')}

${scripts.add('<script type="text/javascript" src="${urls.base}/js/utils.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/jquery-ui/js/jquery-ui-1.8.9.custom.min.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/customFormUtils.js"></script>',
              '<script type="text/javascript" src="${urls.base}/templates/freemarker/edit/forms/js/managePublicationsForIndividual.js"></script>',
              '<script type="text/javascript" src="${urls.base}/templates/freemarker/edit/forms/js/manageTopPublicationsForIndividual.js"></script>')}
