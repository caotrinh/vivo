<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#import "lib-vivo-form.ftl" as lvf>

<#-- Custom form for managing web pages for individuals -->
<div id="manage-records-for" class="panel panel-default">
    <div class="panel-heading">
${i18n().manage_affiliated_people} ${subjectName}
</div><div class="panel-body">
<p style="margin-left:25px;margin-bottom:12px">
${i18n().check_people_to_exclude}
<script type="text/javascript">
    var peopleData = [];
</script>
</p>

<@lvf.unsupportedBrowser urls.base /> 

       
    <#list allSubclasses as sub>
    <h4>${sub}</h4>
        <section id="pubsContainer" role="container">
        <#assign peeps = people[sub]>
        <ul >
            <#list peeps as person>
            <li>
                <input type="checkbox" class="pubCheckbox" <#if person.hideThis??>checked</#if> />${person.name}
            </li>
            <script type="text/javascript">
                peopleData.push({
                    "positionUri": "${person.position}"              
                });
            </script>      
            
            </#list>
        </ul>
        </section>
    </#list>

<br />    
<p>
    <a href="${urls.referringPage}#affiliation" title="${i18n().return_to_profile}">${i18n().return_to_profile}</a>
</p>
</div></div>
<script type="text/javascript">
var customFormData = {
    processingUrl: '${urls.base}/edit/primitiveRdfEdit'
};
var i18nStrings = {
    personSuccessfullyExcluded: '${i18n().person_successfully_excluded}',
    errorExcludingPerson: '${i18n().error_excluding_person}'
};
</script>

${stylesheets.add('<link rel="stylesheet" href="${urls.base}/templates/freemarker/edit/forms/css/customForm.css" />',
                  '<link rel="stylesheet" href="${urls.base}/js/jquery-ui/css/smoothness/jquery-ui-1.8.9.custom.css" />')}

${scripts.add('<script type="text/javascript" src="${urls.base}/js/utils.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/jquery-ui/js/jquery-ui-1.8.9.custom.min.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/customFormUtils.js"></script>',
                '<script type="text/javascript" src="${urls.base}/templates/freemarker/edit/forms/js/managePeopleForOrganization.js"></script>')}
              
