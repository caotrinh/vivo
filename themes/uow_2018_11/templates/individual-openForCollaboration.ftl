<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- List of positions for the individual -->
<#if editable && groupName="affiliation">
	<h3>Available for Collaboration</h3>
	<hr>
	<input type="checkbox" name="openForCollaboration" class="openForCollabCheckbox checkbox" data-size = "mini" data-animate = "true" id="openForCollaboration">
	<label>Toggle to set collaboration availability</label>
	<p class="small">Please consider any relevant faculty/school policies before enabling this option.</p>
</#if>
<div class="row openForCollaborationDiv" id="openForCollaborationDiv">
	<#assign isOpenForCollaboration = "false" >
	<#list individual.mostSpecificTypes as type>
		<#if type?contains("Collaborative")>
			<h4><span class="label label-default openForCollaborationLabel">${type}</span></h4>
			<#assign isOpenForCollaboration = "true" >
		</#if>
	</#list>
	<#if editable && groupName="affiliation">
		<script>
			var customFormData = {
				processingUrl: '${urls.base}/edit/primitiveRdfEdit',
				personUri: "${individual.uri}"
				
			};
			var initStatusCollab = "${isOpenForCollaboration}";
		</script>
		${scripts.add('<script type="text/javascript" src="${urls.base}/templates/freemarker/edit/forms/js/toggleOpenForCollaboration.js"></script>')}
	</#if>
</div>
