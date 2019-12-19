<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Custom object property statement view for faux property "selected publications". See the PropertyConfig.3 file for details. 
    
     This template must be self-contained and not rely on other variables set for the individual page, because it
     is also used to generate the property statement during a deletion.  
 -->
<#import "lib-datetime.ftl" as dt>
<@showTopPubs statement />

<#macro showTopPubs statement>
	<#if statement.hideThis?has_content>
	    <td class="hideThis">&nbsp;</td>
	    <script type="text/javascript" >
	        $('td.hideThis').parent().parent().parent().addClass("hideThis");
	        $('td.hideThis').parent().remove();
	    </script>
	<#else>
		<td><@dt.yearSpan "${statement.dateTime!}" /></td>
		<td>
            <a href="${profileUrl(statement.uri("infoResource"))}" title="${i18n().resource_name}">${statement.infoResourceName}</a>
            <#if statement.journalTitle?has_content>
            <br>
            <small><i>Published in</i>&nbsp;&nbsp;&nbsp;${statement.journalTitle}</small>
            </#if>
        </td>
    </#if>
</#macro>
