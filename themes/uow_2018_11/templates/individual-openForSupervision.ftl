<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- List of positions for the individual -->
<#if editable && groupName="supervision">
	<h3>Available for Supervision</h3>
	<hr>
	<input type="checkbox" name="openForSupervision" class="openForSuperCheckbox checkbox" data-size = "mini" data-animate = "true" id="openForSupervision">
	<label>Toggle to set supervision availability</label>
	<p class="small">Please consider any relevant faculty/school policies before enabling this option.</p>
</#if>
<div class="row openForSupervisionDiv" id="openForSupervisionDiv">
	<#assign isOpenForSupervision = "false" >
	<#list individual.mostSpecificTypes as type>
		<#if type?contains("Supervis")>
			<h4><span class="label label-default openForSupervisionLabel">${type}</span></h4>
			<#assign isOpenForSupervision = "true" >
		</#if>
	</#list>
	<#if editable && groupName="supervision">
		<script>
			var customFormData = {
				processingUrl: '${urls.base}/edit/primitiveRdfEdit',
				personUri: "${individual.uri}"
				
			};
			var initStatus = "${isOpenForSupervision}";
		</script>
		${scripts.add('<script type="text/javascript" src="${urls.base}/templates/freemarker/edit/forms/js/toggleOpenForSupervision.js"></script>')}
	</#if>
</div>
