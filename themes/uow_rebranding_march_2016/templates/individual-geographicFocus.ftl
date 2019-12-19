<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- List of research areas for the individual -->
<#assign geographicFoci = propertyGroups.pullProperty("${core}geographicFocus")!> 
<#if geographicFoci?has_content> <#-- true when the property is in the list, even if not populated (when editing) -->
    <#assign localName = geographicFoci.localName>
    <div class="panel panel-primary">
	    <h4 id="${localName}" class="panel-heading mainPropGroup" style="clear:left">
	        ${geographicFoci.name?capitalize} 
	        <@p.addLink geographicFoci editable /> <@p.verboseDisplay geographicFoci />
	    </h4>
	    <ul id="individual-hasGeographicFocus" role="list" >
	        <@p.objectProperty geographicFoci editable />
	    </ul>
    </div>
</#if>   
