<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Template for property listing on individual profile page -->

        <#list group.properties as property>
            <#if property.name != "overview">
            <#assign rangeClass = "noRangeClass">
            <#if property.rangeUri?has_content && property.rangeUri?contains("#")>
                <#assign rangeClass = property.rangeUri?substring(property.rangeUri?last_index_of("#")+1)>
            <#elseif property.rangeUri?has_content >
                <#assign rangeClass = property.rangeUri?substring(property.rangeUri?last_index_of("/")+1)>
            </#if>
        
            <article class="property-profile" role="article">
                <#-- Property display name -->
                <#if rangeClass == "Authorship" && individual.editable && (property.domainUri)?? && property.domainUri?contains("Person")>
                    <h3 id="${property.localName}-${rangeClass}">${property.name?capitalize} <@p.addLink property editable /> <@p.verboseDisplay property /> 
                        <a id="managePubLink" class="manageLinks" href="${urls.base}/managePublications?subjectUri=${subjectUri[1]!}" title="${i18n().manage_publications_link}" <#if verbose>style="padding-top:10px"</#if> >
                            ${i18n().manage_publications_link?capitalize}
                        </a>
                    </h3>
                <#elseif rangeClass == "InvestigatorRole" && individual.editable  >
                    <h3 id="${property.localName}-${rangeClass}">${property.name?capitalize} <@p.addLink property editable /> <@p.verboseDisplay property /> 
                        <a id="manageGrantLink" class="manageLinks" href="${urls.base}/manageGrants?subjectUri=${subjectUri[1]!}" title="${i18n().manage_grants_and_projects_link}" <#if verbose>style="padding-top:10px"</#if> >
                            ${i18n().manage_grants_and_projects_link?capitalize}
                        </a>
                    </h3>
                <#elseif rangeClass == "Position" && individual.editable  >
                    <h3 id="${property.localName}-${rangeClass}">${property.name?capitalize} <@p.addLink property editable /> <@p.verboseDisplay property /> 
                        <a id="managePeopleLink" class="manageLinks" href="${urls.base}/managePeople?subjectUri=${subjectUri[1]!}" title="${i18n().manage_affiliated_people}" <#if verbose>style="padding-top:10px"</#if> >
                            ${i18n().manage_affiliated_people_link?capitalize}
                        </a>
                    </h3>
                <#elseif property.localName == "toppub" && individual.editable && (property.domainUri)?? && property.domainUri?contains("Person")>
                    <h3 id="${property.localName}-${rangeClass}">${property.name?capitalize} <@p.verboseDisplay property /> 
                        <a id="managePubLink" class="manageLinks" href="${urls.base}/managePublications?subjectUri=${subjectUri[1]!}" title="${i18n().manage_top_publications_link}" <#if verbose>style="padding-top:10px"</#if> >
                            ${i18n().manage_top_publications_link?capitalize}
                        </a>
                    </h3>
                <#elseif rangeClass == "Name" && property.statements?has_content && editable >
                    <h3 id="${property.localName}">${property.name?capitalize}  <@p.verboseDisplay property /> </h3>
                <#elseif rangeClass == "Title" && property.statements?has_content && editable >
                    <h3 id="${property.localName}">${property.name?capitalize}  <@p.verboseDisplay property /> </h3>
                <#else>
                    <h3 id="${property.localName}">${property.name?capitalize} <@p.addLink property editable /> <@p.verboseDisplay property /> </h3>
                </#if>
                <hr />
                <#-- List the statements for each property -->
                <ul class="property-list" role="list" id="${property.localName}-${rangeClass}-List">
                    <#-- data property -->
                    <#if property.type == "data">
                        <@p.dataPropertyList property editable />
                    <#-- object property -->
                    <#else>
                        <#if property.localName == "toppub">
                            <@p.objectProperty property false />
                        <#else>
                            <@p.objectProperty property editable />
                        </#if>
                    </#if>
                </ul>
            </article> <!-- end property -->
            </#if>
        </#list>
