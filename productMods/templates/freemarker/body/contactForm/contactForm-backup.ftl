<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Backup of contact mail email -->

<div class="panel panel-default">
	<div class="panel-heading">
		<h4>${datetime}</h4>
	</div>
	<div class="panel-body">
		<#if spamReason??>
			<div class="alert alert-danger" role="alert">
                <span class="glyphicon glyphicon-exclamation-sign" aria-hidden="true" role="error alert"></span>    
                ${i18n().rejected_spam}
                <p>${spamReason}</p>
            </div>
		</#if>
		${msgText}
	</div>
</div>