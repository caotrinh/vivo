<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- List of research areas for the individual -->
<#assign researchAreas = propertyGroups.pullProperty("${core}hasResearchArea")!> 
<#assign concepts = propertyGroups.pullProperty("${core}hasAssociatedConcept")!> 
<#if researchAreas?has_content> <#-- true when the property is in the list, even if not populated (when editing) -->
    <#assign localName = researchAreas.localName>
    <div class="panel panel-primary">
	    <h4 class="panel-heading" id="${localName}" class="mainPropGroup">
	        ${researchAreas.name?capitalize} 
	        <@p.addLink researchAreas editable /> <@p.verboseDisplay researchAreas />
	        <i data-toggle="tooltip" data-placement="top" title="This is a listing the of ANZSRC field of Research codes that the researcher is active in" class="fa fa-question-circle pull-right tooltips-btn"></i>
	    </h4>
	    <ul id="individual-${localName}" role="list" >
	        <@p.objectProperty researchAreas editable />
	    </ul>
    </div>
</#if>   
