<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-----------------------------------------------------------------------------
    Macros and functions for working with properties and property lists
------------------------------------------------------------------------------>

<#-- Return true iff there are statements for this property -->
<#function hasStatements propertyGroups propertyName>

    <#local property = propertyGroups.getProperty(propertyName)!>
    
    <#-- First ensure that the property is defined
    (an unpopulated property while logged out is undefined) -->
    <#if ! property?has_content>
        <#return false>
    </#if>
    
    <#if property.collatedBySubclass!false> <#-- collated object property-->
        <#return property.subclasses?has_content>
    <#else>
        <#return property.statements?has_content> <#-- data property or uncollated object property -->
    </#if>
</#function>

<#-- Return true iff there are statements for this property -->
<#function hasVisualizationStatements propertyGroups propertyName rangeUri>

    <#local property = propertyGroups.getProperty(propertyName, rangeUri)!>
    
        <#-- First ensure that the property is defined
        (an unpopulated property while logged out is undefined) -->
        <#if ! property?has_content>
            <#return false>
        </#if>
    
        <#if property.collatedBySubclass!false> <#-- collated object property-->
            <#return property.subclasses?has_content>
        <#else>
            <#return property.statements?has_content> <#-- data property or uncollated object property -->
        </#if>

</#function>

<#-----------------------------------------------------------------------------
    Macros for generating property lists
------------------------------------------------------------------------------>

<#macro dataPropertyListing property editable>
    <#if property?has_content> <#-- true when the property is in the list, even if not populated (when editing) -->
        <@addLinkWithLabel property editable />
        <@dataPropertyList property editable />
    </#if>
</#macro>

<#macro dataPropertyList property editable template=property.template>
    <#list property.statements as statement>
        <@propertyListItem property statement editable ><#include "${template}"></@propertyListItem>
    </#list> 
</#macro>

<#macro objectProperty property editable template=property.template>
    <#if property.collatedBySubclass> <#-- collated -->
        <#if property.template?contains("authorInAuthorship")>
            <@collatedObjectPropertyListGrid property editable template />
	<#elseif property.template?contains("advisorIn")>
            <@collatedObjectSupervisorListGrid property editable template />
        <#else>
            <@collatedObjectPropertyList property editable template />
        </#if>
    <#else> <#-- uncollated -->
        <#-- We pass property.statements and property.template even though we are also
             passing property, because objectPropertyList can get other values, and
             doesn't necessarily use property.statements and property.template -->
        <#if property.template?contains("editorship") || property.template?contains("toppub")>
            <@objectPropertyListGrid property editable property.statements template />
        <#elseif property.template?contains("hasInvestigatorRole")>
            <@objectPropertyListGrid property false property.statements template />
        <#else>
            <@objectPropertyList property editable property.statements template />
        </#if>
    </#if>
</#macro>

<#macro collatedObjectSupervisorListGrid property editable template=property.template >
    <#local subclasses = property.subclasses>
    <#if property.template?contains("advisorIn")>
        <#assign th = ["Degree","Research Title","Advisee"]>
    </#if>
    <#list subclasses as subclass>
        <#local subclassName = subclass.name!>
        <#if subclassName?has_content>
            <#assign subclassId = subclassName?replace("\\s+", "", "rm") />
            <li class="subclass ${subclassId}_subclasslist" role="listitem">
                <h3>${subclassName?capitalize}</h3>
                <#if subclass.statements?has_content>
                    <table class="table subclass-property-list">
                        <thead>
                            <tr>
                                <#list th as i>
                                    <th>${i}</th>
                                </#list>
                            </tr>
                        </thead>
                        <tbody>
                            <#list subclass.statements as statement>
                                <@propertyListItemGrid property statement editable><#include "${template}"></@propertyListItemGrid>
                            </#list>
                        </tbody>
                    </table>
                </#if>
            </li>
        <#else>
            <#-- If not in a real subclass, the statements are in a dummy subclass with an
                 empty name. List them in the top level ul, not nested. -->
            <@objectPropertyList property editable subclass.statements template/>
        </#if>
    </#list>
</#macro>

<#macro collatedObjectPropertyListGrid property editable template=property.template >
    <#local subclasses = property.subclasses>
    <#if property.template?contains("authorInAuthorship")>
        <#assign th = ["Year","Title"]>
    </#if>
    <#list subclasses as subclass>
        <#local subclassName = subclass.name!>
        <#if subclassName?has_content>
            <#assign subclassId = subclassName?replace("\\s+", "", "rm")?replace(",", "", "rm") />
            <li class="subclass ${subclassId}_subclasslist" role="listitem">
                <h3>${subclassName?capitalize}</h3>
                <#if subclass.statements?has_content>
                    <table id="pubdetails_${subclassId}" class="table subclass-property-list">
                        <thead>
                            <tr>
                                <#list th as i>
                                    <th>${i}</th>
                                </#list>
                            </tr>
                        </thead>
                        <tbody>
                            <#list subclass.statements as statement>
                                <@propertyListItemGrid property statement editable><#include "${template}"></@propertyListItemGrid>
                            </#list>
                        </tbody>
                    </table>
                </#if>
            </li>
        <#else>
            <#-- If not in a real subclass, the statements are in a dummy subclass with an
                 empty name. List them in the top level ul, not nested. -->
            <@objectPropertyList property editable subclass.statements template/>
        </#if>
        <script>
            if($('.${subclassId!}_subclasslist').length > 1 && $('.${subclassId!}_subclasslist table tbody tr').length > 6 && $('#${subclassId!}_showBtn').length < 1 || ($('.${subclassId!}_subclasslist').length < 2 && $('.${subclassId!}_subclasslist table tbody tr').length > 3 && $('#${subclassId!}_showBtn').length < 1)){
                $('.${subclassId!}_subclasslist').eq(0).append($('<a/>').attr('id','${subclassId!}_showBtn').text('Show all ${subclassName!}').addClass('show-pubs'));
                $('.${subclassId!}_subclasslist').eq(0).find('table tbody tr:gt(2)').hide();
                $('#${subclassId!}_showBtn').click(function() {
                    if($(this).hasClass('show-pubs')){
                        $('.${subclassId!}_subclasslist').eq(0).find('table tbody tr:gt(2)').show();
                        $(this).removeClass('show-pubs').addClass('hide-pubs').text('Hide');
                    } else if($(this).hasClass('hide-pubs')){
                        $('.${subclassId!}_subclasslist').eq(0).find('table tbody tr:gt(2)').hide();
                        $(this).removeClass('hide-pubs').addClass('show-pubs').text('Show all ${subclassName!}');
                    }
                });
            }
        </script>
    </#list>
</#macro>

<#macro collatedObjectPropertyList property editable template=property.template >
    <#local subclasses = property.subclasses>
    <#list subclasses as subclass>
        <#local subclassName = subclass.name!>
        <#if subclassName?has_content>
            <li class="subclass" role="listitem">
                <h3>${subclassName?capitalize}</h3>
                <ul class="subclass-property-list">
                    <@objectPropertyList property editable subclass.statements template />
                </ul>
            </li>
        <#else>
            <#-- If not in a real subclass, the statements are in a dummy subclass with an
                 empty name. List them in the top level ul, not nested. -->
            <@objectPropertyList property editable subclass.statements template/>
        </#if>
    </#list>
</#macro>

<#-- Full object property listing, including heading and ul wrapper element. 
Assumes property is non-null. -->
<#macro objectPropertyListing property editable template=property.template>
    <#local localName = property.localName>
    <h2 id="${localName}" class="mainPropGroup">${property.name?capitalize} <@addLink property editable /> <@verboseDisplay property /></h2>    
    <ul id="individual-${localName}" role="list">
        <@objectProperty property editable />
    </ul>
</#macro>

<#macro objectPropertyList property editable statements=property.statements template=property.template>
    <#list statements as statement>
        <@propertyListItem property statement editable><#include "${template}"></@propertyListItem>
    </#list>
</#macro>
<#macro objectPropertyListGrid property editable statements=property.statements template=property.template>
    <#assign tableId = property.name?replace("\\s+", "", "rm")?replace(",", "", "rm") />
    <#if statements?has_content>
        <table class="table ${tableId}_table_list">
            <thead>
                <tr>
                    <th>Year</th>
                    <th>Title</th>
                </tr>
            </thead>
            <tbody>
                <#list statements as statement>
                    <#if template?contains("hasInvestigatorRole")>
                      <#include "${template}">
                    <#else>
                      <@propertyListItemGrid property statement editable><#include "${template}"></@propertyListItemGrid>
                    </#if>
                </#list>
            </tbody>
        </table>
        <#if template?contains("hasInvestigatorRole")>
        <#else>
          <script>
            if($('.${tableId!}_table_list').length > 1 && $('.${tableId!}_table_list tbody tr').length > 6 && $('#${tableId!}_showBtn').length < 1 || ($('.${tableId!}_table_list').length < 2 && $('.${tableId!}_table_list tbody tr').length > 3 && $('#${tableId!}_showBtn').length < 1)){
                $('.${tableId!}_table_list').eq(0).after($('<a/>').attr('id','${tableId!}_showBtn').text('Show all ${property.name!?capitalize}').addClass('show-pubs'));
                $('.${tableId!}_table_list').eq(0).find('tbody tr:gt(2)').hide();
                $('#${tableId!}_showBtn').click(function() {
                    if($(this).hasClass('show-pubs')){
                        $('.${tableId!}_table_list').eq(0).find('tbody tr:gt(2)').show();
                        $(this).removeClass('show-pubs').addClass('hide-pubs').text('Hide');
                    } else if($(this).hasClass('hide-pubs')){
                        $('.${tableId!}_table_list').eq(0).find('tbody tr:gt(2)').hide();
                        $(this).removeClass('hide-pubs').addClass('show-pubs').text('Show all ${subclassName!}');
                    }
                });
            }
          </script>
        </#if>
    </#if>
</#macro>

<#-- Some properties usually display without a label. But if there's an add link, 
we need to also show the property label. If no label is specified, the property
name will be used as the label. -->
<#macro addLinkWithLabel property editable label="${property.name?capitalize}">
    <#local addLink><@addLink property editable label /></#local>
    <#local verboseDisplay><@verboseDisplay property /></#local>
    <#-- Changed to display the label when user is in edit mode, even if there's no add link (due to 
    displayLimitAnnot, for example). Otherwise the display looks odd, since neighboring 
    properties have labels. 
    <#if addLink?has_content || verboseDisplay?has_content>
        <h2 id="${property.localName}">${label} ${addLink!} ${verboseDisplay!}</h2>         
    </#if>
    -->
    <#if editable> 
        <h3 id="${property.localName!}">${label} ${addLink!} ${verboseDisplay!}</h3>
    </#if>
</#macro>

<#macro addLink property editable label="${property.name}">    
    <#if property.rangeUri?? >
        <#local rangeUri = property.rangeUri /> 
    <#else>
        <#local rangeUri = "" /> 
    </#if>
    <#if property.domainUri?? >
        <#local domainUri = property.domainUri /> 
    <#else>
        <#local domainUri = "" /> 
    </#if>
    <#if editable>
        <#if property.addUrl?has_content>
        	<#local url = property.addUrl>
            <@showAddLink property.localName label url rangeUri domainUri/>
        </#if>
    </#if>
</#macro>

<#macro showAddLink propertyLocalName label url rangeUri domainUri="">
    <#if (rangeUri?contains("Authorship") && domainUri?contains("IAO_0000030")) || (rangeUri?contains("Editorship") && domainUri?contains("IAO_0000030"))|| rangeUri?contains("URL") || propertyLocalName == "hasResearchArea">
        <a class="add-${propertyLocalName}" href="${url}" title="${i18n().manage_list_of} ${label?lower_case}">
        <span class="glyphicon glyphicon-plus-sign add-btn"></span></a>
        <#--<img class="add-individual" src="${urls.images}/individual/manage-icon.png" alt="${i18n().manage}" /></a>-->
    <#else>
        <a class="add-${propertyLocalName}" href="${url}" title="${i18n().add_new} ${label?lower_case} ${i18n().entry}">
        <span class="glyphicon glyphicon-plus-sign add-btn"></span></a>
        <#--<img class="add-individual" src="${urls.images}/individual/addIcon.gif" alt="${i18n().add}" /></a> -->
    </#if>
</#macro>

<#macro propertyLabel property label="${property.name?capitalize}">
    <h2 id="${property.localName}">${label} <@verboseDisplay property /></h2>     
</#macro>

<#macro propertyListItemGrid property statement editable >
    <#if property.rangeUri?? >
        <#local rangeUri = property.rangeUri />
    <#else>
        <#local rangeUri = "" />
    </#if>
    <tr role="listitem">
        <#nested>
        <td><@editingLinks "${property.localName}" "${property.name}" statement editable rangeUri/></td>
      </tr>
</#macro>

<#macro propertyListItem property statement editable >
    <#if property.rangeUri?? >
        <#local rangeUri = property.rangeUri /> 
    <#else>
        <#local rangeUri = "" /> 
    </#if>
    <li role="listitem">    
        <#nested>       
        <@editingLinks "${property.localName}" "${property.name}" statement editable rangeUri/>
    </li>
</#macro>

<#macro editingLinks propertyLocalName propertyName statement editable rangeUri="">
    <#if editable >
        <#if (!rangeUri?contains("Authorship") && !rangeUri?contains("URL") && !rangeUri?contains("Editorship") && propertyLocalName != "hasResearchArea")>
            &nbsp;| <@editLink propertyLocalName propertyName statement rangeUri/>
            <@deleteLink propertyLocalName propertyName statement rangeUri/>
        </#if>    
    </#if>
</#macro>
<#macro editLink propertyLocalName propertyName statement rangeUri="">
<#if propertyLocalName?contains("ARG_2000028")>
    <#if rangeUri?contains("Address")>
        <#local url = statement.editUrl + "&addressUri=" + "${statement.address!}">
    <#elseif rangeUri?contains("Telephone") || rangeUri?contains("Fax")>
        <#local url = statement.editUrl + "&phoneUri=" + "${statement.phone!}">
    <#elseif rangeUri?contains("Work") || rangeUri?contains("Email")>
        <#local url = statement.editUrl + "&emailUri=" + "${statement.email!}">
    <#elseif rangeUri?contains("Name")>
        <#local url = statement.editUrl + "&fullNameUri=" + "${statement.fullName!}">
    <#elseif rangeUri?contains("Title")>
        <#local url = statement.editUrl + "&titleUri=" + "${statement.title!}">
    <#elseif rangeUri?contains("Role")>
        <#local url = statement.editUrl + "&roleUri=" + "${statement.role!}">
    </#if>
<#else>
    <#local url = statement.editUrl>
</#if>
    <#if url?has_content>
        <@showEditLink propertyLocalName url />
    </#if>

</#macro>

<#macro showEditLink propertyLocalName url>
    <a class="edit-${propertyLocalName}" href="${url}" title="${i18n().edit_entry}"><i class="fa fa-pencil fa-fw actionIcon" title="${i18n().edit_entry}"></i></a>
</#macro>

<#macro deleteLink propertyLocalName propertyName statement rangeUri=""> 
    <#local url = statement.deleteUrl>
    <#if url?has_content>
    	<#--We need to specify the actual object to be deleted as it is different from the object uri-->
	    <#if propertyLocalName?contains("ARG_2000028")>
		    <#if rangeUri?contains("Address")>
		        <#local url = url + "&deleteObjectUri=" + "${statement.address!}">
		    <#elseif rangeUri?contains("Telephone") || rangeUri?contains("Fax")>
		        <#local url = url + "&deleteObjectUri=" + "${statement.phone!}">
		    <#elseif rangeUri?contains("Work") || rangeUri?contains("Email")>
		        <#local url = url + "&deleteObjectUri=" + "${statement.email!}">
		    <#elseif rangeUri?contains("Name")>
		        <#local url = url + "&deleteObjectUri=" + "${statement.fullName!}">
		    <#elseif rangeUri?contains("Title")>
		        <#local url = url + "&deleteObjectUri=" + "${statement.title!}">
            <#elseif rangeUri?contains("Role")>
                <#local url = url + "&deleteObjectUri=" + "${statement.role!}">
		    </#if>
		</#if>
        <@showDeleteLink propertyLocalName url />
    </#if>
</#macro>

<#macro showDeleteLink propertyLocalName url>
    <a class="delete-${propertyLocalName}" href="${url}" title="${i18n().delete_entry}"><i class="fa fa-trash-o fa-fw actionIcon" title="${i18n().delete_entry}"></i></a>
</#macro>

<#macro verboseDisplay property>
    <#local verboseDisplay = property.verboseDisplay!>
    <#if verboseDisplay?has_content>       
        <section class="verbosePropertyListing">
            <#if verboseDisplay.fauxProperty??>
                 a faux property of
            </#if>
            <a class="propertyLink" href="${verboseDisplay.propertyEditUrl}" title="${i18n().name}">${verboseDisplay.localName}</a> 
            (<span>${property.type?lower_case}</span> property);
            order in group: <span>${verboseDisplay.displayRank};</span> 
            display level: <span>${verboseDisplay.displayLevel};</span>
            update level: <span>${verboseDisplay.updateLevel};</span>
            publish level: <span>${verboseDisplay.publishLevel}</span>
        </section>
    </#if>
</#macro>

<#-----------------------------------------------------------------------------
    Macros for specific properties
------------------------------------------------------------------------------>

<#-- Image 

     Values for showPlaceholder: "always", "never", "with_add_link" 
     
     Note that this macro has a side-effect in the call to propertyGroups.pullProperty().
-->
<#macro image individual propertyGroups namespaces editable showPlaceholder="never" imageWidth=160 >
    <#local mainImage = propertyGroups.pullProperty("${namespaces.vitroPublic}mainImage")!>
    <#local thumbUrl = individual.thumbUrl!>
    <#-- Don't assume that if the mainImage property is populated, there is a thumbnail image (though that is the general case).
         If there's a mainImage statement but no thumbnail image, treat it as if there is no image. -->
    <#if (mainImage.statements)?has_content && thumbUrl?has_content>
        <a href="${individual.imageUrl}" title="${i18n().alt_thumbnail_photo}">
        	<img class="individual-photo" src="${thumbUrl}" title="${i18n().click_to_view_larger}" alt="${individual.name}" width="${imageWidth!}" />
        </a>
        <@editingLinks "${mainImage.localName}" "" mainImage.first() editable />
    <#else>
        <#local imageLabel><@addLinkWithLabel mainImage editable "${i18n().photo}" /></#local>
        ${imageLabel}
        <#if showPlaceholder == "always" || (showPlaceholder="with_add_link" && imageLabel?has_content)>
            <img class="individual-photo img-responsive" src="${placeholderImageUrl(individual.uri)}" title = "${i18n().no_image}" alt="${i18n().placeholder_image}" width="${imageWidth!}" />
        </#if>
    </#if>
</#macro>

<#-- Label -->
<#macro label individual editable labelCount localesCount=1 languageCount=1>
	<#assign labelPropertyUri = ("http://www.w3.org/2000/01/rdf-schema#label"?url) />
	<#assign useEditLink = false />
	<#--edit link used if in edit mode and only one label and one language-->
	<#--locales count may be 0 in case where no languages/selectable locales are specified-->
	<#if labelCount = 1 &&  editable && (localesCount >= 0) >
		<#assign useEditLink = true/>
	</#if>
    <#local label = individual.nameStatement>
    ${label.value}
    <#if useEditLink>
    	<@editingLinks "label" "" label editable ""/>
    <#elseif (editable && (labelCount > 0)) || (languageCount > 1)>
    	<#--We display the link even when the user is not logged in case of multiple labels with different languages-->
    	<#assign labelLink = ""/>
    	<#-- Manage labels now goes to generator -->
    	<#assign individualUri = individual.uri!""/>
    	<#assign individualUri = (individualUri?url)/>
    	<#assign individualProfileUrl = individual.profileUrl />
    	<#assign profileParameters = individualProfileUrl?substring(individualProfileUrl?index_of("?") + 1)/>
    	<#assign extraParameters = ""/>
    	<#if profileParameters?contains("uri=")>
    		<#assign extraParameters = profileParameters?replace("uri=" + individualUri, "") />
    	</#if>
    	<#--IF there are special parameters, then get those-->
    	<#if editable>
    		<#assign imageAlt = "${i18n().manage}" />
    		<#assign linkTitle = "${i18n().manage_list_of_labels}">
    		<#assign labelLink= "${urls.base}/editRequestDispatch?subjectUri=${individualUri}&editForm=edu.cornell.mannlib.vitro.webapp.edit.n3editing.configuration.generators.ManageLabelsGenerator&predicateUri=${labelPropertyUri}${extraParameters}">
    	<#else>
			<#assign linkTitle = "${i18n().view_list_of_labels}">
			<#assign imageAlt = "${i18n().view}" /> 
			<#assign labelLink= "${urls.base}/viewLabels?subjectUri=${individualUri}${extraParameters}">
    	</#if>
    	
        <span class="inline">
            <a class="add-label" href="${labelLink}"
             title="${linkTitle}"><i class="fa fa-tags actionIcon" title="${imageAlt}"></i></a>
        </span>
    </#if>
</#macro>

<#-- Most specific types -->
<#macro mostSpecificTypes individual >
    <#list individual.mostSpecificTypes as type>
        <span class="display-title">${type}</span>
    </#list>
</#macro>

<#macro mostSpecificTypesPerson individual editable>
    <#list individual.mostSpecificTypes as type>
        <div id="titleContainer"><span class="<#if editable>display-title-editable<#else>display-title-not-editable</#if>">${type}</span></div>
    </#list>
</#macro>

<#--Property group names may have spaces in them, replace spaces with underscores for html id/hash-->
<#function createPropertyGroupHtmlId propertyGroupName>
	<#return propertyGroupName?replace(" ", "_")>
</#function>

<#macro mostSpecificTypesTitleDisplay individual>
    <#list individual.mostSpecificTypes as type>
        <#if ! type?contains("Supervis") && ! type?contains("Collaborative") && ! type?contains("Honorary") && type != ("Staff")>
            <span class="display-title">${type}</span>
        </#if>
    </#list>
</#macro>

