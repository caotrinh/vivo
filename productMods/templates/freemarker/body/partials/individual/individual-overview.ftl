 <#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

 <#-- Overview on individual profile page -->

<#if group?has_content>
	<#list group.properties as property>
	    <#if property.name = "overview" && property?has_content>
			<h3 id="overview">
			${property.name?capitalize}
					<@p.addLink property editable /> <@p.verboseDisplay property />
			</h3>
			<hr style="margin: 0">
	        <#list property.statements as statement>
	            <div class="individual-overview">
	                <div class="overview-value">
	                    ${statement.value}
	                </div>
	                <@p.editingLinks "${property.name}" "" statement editable />
	            </div>
	        </#list>
	    </#if>
	</#list>
</#if>
