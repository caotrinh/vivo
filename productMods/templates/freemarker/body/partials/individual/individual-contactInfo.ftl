<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Contact info on individual profile page -->

<#assign phone = propertyGroups.pullProperty("http://purl.obolibrary.org/obo/ARG_2000028","http://www.w3.org/2006/vcard/ns#Telephone")!>
<#assign primaryEmail = propertyGroups.pullProperty("http://purl.obolibrary.org/obo/ARG_2000028","http://www.w3.org/2006/vcard/ns#Work")!>
<#assign addlEmail = propertyGroups.pullProperty("http://purl.obolibrary.org/obo/ARG_2000028","http://www.w3.org/2006/vcard/ns#Email")!>

<#if phone?has_content || primaryEmail?has_content || addlEmail?has_content >
    <h2 id="hasContactInfo">${i18n().contact_info}</h2>
</#if>

<#-- Primary Email -->    
<@emailLinks "primaryEmail" primaryEmail />

<#-- Additional Emails --> 
<@emailLinks "email" addlEmail />   
  
<#-- Phone --> 

<#if phone?has_content> <#-- true when the property is in the list, even if not populated (when editing) -->
    <@p.addLinkWithLabel phone editable />
    <#if phone.statements?has_content> <#-- if there are any statements -->
        <ul id="individual-phone" role="list" <#if editable>style="list-style:none;margin-left:0;"</#if>>
            <#list phone.statements as statement>
                <li role="listitem">
                    <span class="glyphicon glyphicon-phone contact-item"></span>
                    ${statement.number!}
                    <@p.editingLinks "${phone.localName}" "${phone.name}" statement editable phone.rangeUri />
                </li>
            </#list>
        </ul>
    </#if>
</#if>

<#macro emailLinks property email>
    <#if property == "primaryEmail">
        <#local listId = "primary-email">
        <#local label = "${i18n().primary_email_capitalized}">
    <#else>
        <#local listId = "additional-emails">
        <#local label = "${i18n().additional_emails_capitalized}">
    </#if>     
    <#if email?has_content> <#-- true when the property is in the list, even if not populated (when editing) -->
        <@p.addLinkWithLabel email editable label/>
        <#if email.statements?has_content> <#-- if there are any statements -->
            <ul id="${listId}" class="individual-emails" role="list" <#if editable>style="list-style:none;margin-left:0;"</#if>>
                <#list email.statements as statement>
                    <li role="listitem">
                        <a class="email" href="mailto:${statement.emailAddress!}" title="${i18n().email}"><span class="glyphicon glyphicon-envelope contact-item"></span></a>
                        <a class="email" href="mailto:${statement.emailAddress!}" title="${i18n().email}">${statement.emailAddress!}</a>
                        <@p.editingLinks "${email.localName}" "${email.name}" statement editable email.rangeUri />
                    </li>
                </#list>
            </ul>
        </#if>
    </#if>
</#macro>
