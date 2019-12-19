<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<table id='${tableID}'>
    <caption class="sidebarTableCaption">
        ${tableCaption} <a href="${fileDownloadLink}" alt="Download CSV data"><span class="glyphicon glyphicon-download-alt"></span></a>
    </caption>
    <thead>
        <tr>
            <th>
                ${i18n().year_capitalized}
            </th>
            <th>
                ${tableActivityColumnName}
            </th>
        </tr>
    </thead>
    <tbody>

    <#list tableContent?keys as year>
        <tr>
            <td>
                ${year}
            </td>
            <td>
                ${tableContent[year]}
            </td>
        </tr>
    </#list>

    </tbody>
</table>
