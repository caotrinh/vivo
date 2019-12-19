<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Contact form processing errors -->

<div class="panel panel-default">
	<div class="panel-heading">
		<h4>UOW Scholars Feedback Form</h4>
	</div>
	<div class="panel-body">
		<#if errorMessage?has_content>
			<div class="alert alert-danger" role="alert">
                <span class="glyphicon glyphicon-exclamation-sign" aria-hidden="true" role="error alert"></span>    
                ${errorMessage}
            </div>
		</#if>
		<p class="contactUsReturnHome">${i18n().return_to_the} 
		    <a href="${urls.home}" title="${i18n().home_page}">${i18n().home_page}</a>.
		</p> 
	</div>
</div>
