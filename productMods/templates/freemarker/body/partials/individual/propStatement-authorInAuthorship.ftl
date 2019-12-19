<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Custom object property statement view for faux property "selected publications". See the PropertyConfig.3 file for details. 
    
     This template must be self-contained and not rely on other variables set for the individual page, because it
     is also used to generate the property statement during a deletion.  
 -->
 
<#import "lib-sequence.ftl" as s>
<#import "lib-datetime.ftl" as dt>

<@showAuthorship statement />

<#-- Use a macro to keep variable assignments local; otherwise the values carry over to the
     next statement -->
<#macro showAuthorship statement>
<#if statement.hideThis?has_content>
    <td class="hideThis">&nbsp;</td>
    <script type="text/javascript" >
        $('td.hideThis').parent().parent().parent().addClass("hideThis");
        if ( $('h3#relatedBy-Authorship').length > 0 && $('h3#relatedBy-Authorship').attr('class').length == 0 ) {
            $('h3#relatedBy-Authorship').addClass('hiddenPubs');
        }
        $('td.hideThis').parent().remove();
    </script>
<#else>
    <#local citationDetails>
        <#if statement.subclass??>
            <#if statement.subclass?contains("IAO_0000013")>
                <#if statement.journal?? || statement.volume?? || statement.startPage?? || statement.doi??>
                    <hr>
                </#if>
                <#if statement.journal??>
                    <div class="row cites">
                        <div class="col-md-3">
                            <strong>Published In </strong>
                        </div>
                        <div class="col-md-9">
                            ${statement.journal!}
                        </div>
                    </div>
                </#if>
                <#if statement.volume??>
                    <div class="row cites">
                        <div class="col-md-3">
                            <strong>Volume </strong>
                        </div>
                        <div class="col-md-9">
                            ${statement.volume!}
                        </div>
                    </div>
                </#if>
                <#if statement.startPage?? && statement.endPage??>
                    <div class="row cites">
                        <div class="col-md-3">
                            <strong>Pages </strong>
                        </div>
                        <div class="col-md-9">
                            ${statement.startPage!} - ${statement.endPage!}
                        </div>
                    </div>
                <#elseif statement.startPage??>
                    <div class="row cites">
                        <div class="col-md-3">
                            <strong>Page </strong>
                        </div>
                        <div class="col-md-9">
                            p. ${statement.startPage!}
                        </div>
                    </div>
                </#if>
                <#if statement.issn??>
                    <div class="row cites">
                        <div class="col-md-3">
                            <strong>ISSN </strong>
                        </div>
                        <div class="col-md-9">
                            ${statement.issn!}
                        </div>
                    </div>
                </#if>
                <#if statement.doi??>
                    <div class="row cites">
                        <div class="col-md-3 hidden altmetricLabel">
                            <strong>Altmetric </strong>
                        </div>
                        <div class="col-md-9">
                            <div class='altmetric-embed' data-doi="${statement.doi!}" data-badge-popover="right" data-hide-no-mentions="true"></div>
                        </div>
                    </div>
                </#if>
            <#elseif statement.subclass?contains("Chapter")>
                <#if statement.journal?? || statement.appearsIn?? || statement.partOf?? || statement.startPage?? || statement.bookTitle?? || statement.locale?? || statement.publisher?? || statement.edition?? || statement.isbn10?? || statement.isbn13?? || statement.doi??>
                    <hr>
                </#if>
                <#if statement.journal?? || statement.appearsIn?? || statement.partOf?? || statement.bookTitle??>
                    <div class="row cites">
                        <div class="col-md-3">
                            <strong>Published In </strong>
                        </div>
                        <div class="col-md-9">
                            <#if statement.journal??>
                                ${statement.journal!}
                            <#elseif statement.appearsIn??>
                                ${statement.appearsIn!}
                            <#elseif statement.partOf??>
                                ${statement.partOf!}
                            <#elseif statement.bookTitle??>
                                ${statement.bookTitle!}
                            </#if>
                        </div>
                    </div>
                </#if>
                <#if statement.locale?? || statement.publisher??>
                    <div class="row cites">
                        <div class="col-md-3">
                            <strong>Publisher </strong>
                        </div>
                        <div class="col-md-9">
                            <#if statement.locale?? && statement.publisher??>
                                ${statement.locale!}:&nbsp;${statement.publisher!}
                            <#elseif statement.publisher??>
                                ${statement.publisher!}
                            <#else>
                                ${statement.locale!}
                            </#if>
                        </div>
                    </div>
                </#if>
                <#if statement.startPage?? && statement.endPage??>
                    <div class="row cites">
                        <div class="col-md-3">
                            <strong>Pages </strong>
                        </div>
                        <div class="col-md-9">
                            ${statement.startPage!} - ${statement.endPage!}
                        </div>
                    </div>
                <#elseif statement.startPage??>
                    <div class="row cites">
                        <div class="col-md-3">
                            <strong>Page </strong>
                        </div>
                        <div class="col-md-9">
                            p. ${statement.startPage!}
                        </div>
                    </div>
                </#if>
                <#if statement.isbn10??>
                    <div class="row cites">
                        <div class="col-md-3">
                            <strong>ISBN </strong>
                        </div>
                        <div class="col-md-9">
                            ${statement.isbn10!}
                        </div>
                    </div>
                <#elseif statement.isbn13??>
                    <div class="row cites">
                        <div class="col-md-3">
                            <strong>ISBN </strong>
                        </div>
                        <div class="col-md-9">
                            ${statement.isbn13!}
                        </div>
                    </div>
                </#if>
                <#if statement.edition??>
                    <div class="row cites">
                        <div class="col-md-3">
                            <strong>Edition </strong>
                        </div>
                        <div class="col-md-9">
                            ${statement.edition!}
                        </div>
                    </div>
                </#if>
                <#if statement.doi??>
                    <div class="row cites">
                        <div class="col-md-3 hidden altmetricLabel">
                            <strong>Altmetric </strong>
                        </div>
                        <div class="col-md-9">
                            <div class='altmetric-embed' data-doi="${statement.doi!}" data-badge-popover="right" data-hide-no-mentions="true"></div>
                        </div>
                    </div>
                </#if>
            <#elseif statement.subclass?contains("Book")>
                <#if statement.volume?? || statement.locale?? || statement.publisher?? || statement.edition?? || statement.numPages?? || statement.isbn10?? || statement.isbn13?? || statement.doi??>
                    <hr>
                </#if>
                <#if statement.volume??>
                    <div class="row cites">
                        <div class="col-md-3">
                            <strong>Volume </strong>
                        </div>
                        <div class="col-md-9">
                            ${statement.volume!}
                        </div>
                    </div>
                </#if>
                <#if statement.locale?? || statement.publisher??>
                    <div class="row cites">
                        <div class="col-md-3">
                            <strong>Publisher </strong>
                        </div>
                        <div class="col-md-9">
                            <#if statement.locale?? && statement.publisher??>
                                ${statement.locale!}:&nbsp;${statement.publisher!}
                            <#elseif statement.publisher??>
                                ${statement.publisher!}
                            <#else>
                                ${statement.locale!}
                            </#if>
                        </div>
                    </div>
                </#if>
                <#if statement.isbn10??>
                    <div class="row cites">
                        <div class="col-md-3">
                            <strong>ISBN </strong>
                        </div>
                        <div class="col-md-9">
                            ${statement.isbn10!}
                        </div>
                    </div>
                <#elseif statement.isbn13??>
                    <div class="row cites">
                        <div class="col-md-3">
                            <strong>ISBN </strong>
                        </div>
                        <div class="col-md-9">
                            ${statement.isbn13!}
                        </div>
                    </div>
                </#if>
                <#if statement.numPages??>
                    <div class="row cites">
                        <div class="col-md-3">
                            <strong>Pages </strong>
                        </div>
                        <div class="col-md-9">
                            ${statement.numPages!}
                        </div>
                    </div>
                </#if>
                <#if statement.edition??>
                    <div class="row cites">
                        <div class="col-md-3">
                            <strong>Edition </strong>
                        </div>
                        <div class="col-md-9">
                            ${statement.edition!}
                        </div>
                    </div>
                </#if>
                <#if statement.doi??>
                    <div class="row cites">
                        <div class="col-md-3 hidden altmetricLabel">
                            <strong>Altmetric </strong>
                        </div>
                        <div class="col-md-9">
                            <div class='altmetric-embed' data-doi="${statement.doi!}" data-badge-popover="right" data-hide-no-mentions="true"></div>
                        </div>
                    </div>
                </#if>
            <#elseif statement.subclass?contains("ConferencePaper")>
                <#if statement.journal?? || statement.appearsIn?? || statement.partOf?? || statement.startPage?? ||
                     statement.conferenceTitle?? || statement.volume??|| statement.doi??>
                    <hr>
                </#if>
                <#if statement.journal?? || statement.appearsIn?? || statement.partOf?? || statement.conferenceTitle?? >
                    <div class="row cites">
                        <div class="col-md-3">
                            <strong>Published In </strong>
                        </div>
                        <div class="col-md-9">
                            <#if statement.journal??>
                                ${statement.journal!}
                            <#elseif statement.appearsIn??>
                                ${statement.appearsIn!}
                            <#elseif statement.partOf??>
                                ${statement.partOf!}
                            <#elseif statement.conferenceTitle??>
                                ${statement.conferenceTitle!}
                            </#if>
                        </div>
                    </div>
                </#if>
                <#if statement.startPage?? && statement.endPage??>
                    <div class="row cites">
                        <div class="col-md-3">
                            <strong>Pages </strong>
                        </div>
                        <div class="col-md-9">
                            ${statement.startPage!} - ${statement.endPage!}
                        </div>
                    </div>
                <#elseif statement.startPage??>
                    <div class="row cites">
                        <div class="col-md-3">
                            <strong>Page </strong>
                        </div>
                        <div class="col-md-9">
                            p. ${statement.startPage!}
                        </div>
                    </div>
                </#if>
                <#if statement.volume??>
                    <div class="row cites">
                        <div class="col-md-3">
                            <strong>Volume </strong>
                        </div>
                        <div class="col-md-9">
                            ${statement.volume!}
                        </div>
                    </div>
                </#if>
                <#if statement.issn??>
                    <div class="row cites">
                        <div class="col-md-3">
                            <strong>ISSN </strong>
                        </div>
                        <div class="col-md-9">
                            ${statement.issn!}
                        </div>
                    </div>
                </#if>
                <#if statement.doi??>
                    <div class="row cites">
                        <div class="col-md-3 hidden altmetricLabel">
                            <strong>Altmetric </strong>
                        </div>
                        <div class="col-md-9">
                            <div class='altmetric-embed' data-doi="${statement.doi!}" data-badge-popover="right" data-hide-no-mentions="true"></div>
                        </div>
                    </div>
                </#if>
            <#else>
                <#if statement.startPage?? || statement.bookTitle?? || statement.url?? || statement.venue?? || statement.issn?? || statement.ismn?? || statement.dateOfExhibition?? || statement.edition?? || 
                statement.isbn10?? || statement.isbn13?? || statement.dateFirstPerformed?? || statement.dateOfRecording?? || statement.publisher?? || statement.placeOfAd?? || 
                statement.patentNumber?? || statement.doi??>
                    <hr>
                </#if>
                <#if statement.bookTitle?? || statement.journal?? || statement.conferenceTitle?? >
                    <div class="row cites">
                        <div class="col-md-3">
                            <strong>Published In </strong>
                        </div>
                        <div class="col-md-9">
                            <#if statement.bookTitle??>
                                ${statement.bookTitle!}
                            <#elseif statement.journal??>
                                ${statement.journal!}
                            <#elseif statement.conferenceTitle??>
                                ${statement.conferenceTitle!}
                            </#if>
                        </div>
                    </div>
                </#if>
                <#if statement.patentNumber??>
                    <div class="row cites">
                        <div class="col-md-3">
                            <strong>Patent Number </strong>
                        </div>
                        <div class="col-md-9">
                            ${statement.patentNumber!}
                        </div>
                    </div>
                </#if>
                <#if statement.startPage?? && statement.endPage??>
                    <div class="row cites">
                        <div class="col-md-3">
                            <#if statement.startPage == statement.endPage>
                                <strong>Page </strong>
                            <#else>
                                <strong>Pages </strong>
                            </#if>
                        </div>
                        <div class="col-md-9">
                            <#if statement.startPage == statement.endPage>
                                ${statement.startPage!}
                            <#else>
                                ${statement.startPage!} - ${statement.endPage!}
                            </#if>
                        </div>
                    </div>
                <#elseif statement.startPage??>
                    <div class="row cites">
                        <div class="col-md-3">
                            <strong>Page </strong>
                        </div>
                        <div class="col-md-9">
                            p. ${statement.startPage!}
                        </div>
                    </div>
                </#if>
                <#if statement.issn??>
                    <div class="row cites">
                        <div class="col-md-3">
                            <strong>ISSN </strong>
                        </div>
                        <div class="col-md-9">
                            ${statement.issn!}
                        </div>
                    </div>
                </#if>
                <#if statement.ismn??>
                    <div class="row cites">
                        <div class="col-md-3">
                            <strong>ISMN </strong>
                        </div>
                        <div class="col-md-9">
                            ${statement.ismn!}
                        </div>
                    </div>
                </#if>
                <#if statement.isbn10?? || statement.isbn13??>
                    <div class="row cites">
                        <div class="col-md-3">
                            <strong>ISBN </strong>
                        </div>
                        <div class="col-md-9">
                            <#if statement.isbn10??>
                                ${statement.isbn10}
                            <#else>
                                ${statement.isbn13}
                            </#if>
                        </div>
                    </div>
                </#if>
                <#if statement.edition??>
                    <div class="row cites">
                        <div class="col-md-3">
                            <strong>Edition </strong>
                        </div>
                        <div class="col-md-9">
                            ${statement.edition!}
                        </div>
                    </div>
                </#if>
                <#if statement.venue??>
                    <div class="row cites">
                        <div class="col-md-3">
                            <strong>Venue </strong>
                        </div>
                        <div class="col-md-9">
                            ${statement.venue!}
                        </div>
                    </div>
                </#if>
                <#if statement.dateOfPresentation??>
                    <div class="row cites">
                        <div class="col-md-3">
                            <strong>Date of Presentation </strong>
                        </div>
                        <div class="col-md-9">
                            ${statement.dateOfPresentation!}
                        </div>
                    </div>
                </#if>
                <#if statement.dateOfExhibition??>
                    <div class="row cites">
                        <div class="col-md-3">
                            <strong>Date of Exhibition </strong>
                        </div>
                        <div class="col-md-9">
                            ${statement.dateOfExhibition!}
                        </div>
                    </div>
                </#if>
                <#if statement.dateFirstPerformed??>
                    <div class="row cites">
                        <div class="col-md-3">
                            <strong>Date of First Performed </strong>
                        </div>
                        <div class="col-md-9">
                            ${statement.dateFirstPerformed!}
                        </div>
                    </div>
                </#if>
                <#if statement.dateOfRecording??>
                    <div class="row cites">
                        <div class="col-md-3">
                            <strong>Date of Recording </strong>
                        </div>
                        <div class="col-md-9">
                            ${statement.dateOfRecording!}
                        </div>
                    </div>
                </#if>
                <#if statement.placeOfAd??>
                    <div class="row cites">
                        <div class="col-md-3">
                            <strong>Place of Advertisement </strong>
                        </div>
                        <div class="col-md-9">
                            ${statement.placeOfAd!}
                        </div>
                    </div>
                </#if>
                <#if statement.publisher??>
                    <div class="row cites">
                        <div class="col-md-3">
                            <strong>Publisher</strong>
                        </div>
                        <div class="col-md-9">
                            ${statement.publisher!}
                        </div>
                    </div>
                </#if>
                <#if statement.url??>
                    <div class="row cites">
                        <div class="col-md-3">
                            <strong>External URL </strong>
                        </div>
                        <div class="col-md-9">
                            <a href="${statement.url!}" target="_blank" title="${statement.url!}">
                                <#if statement.infoResourceName??>
                                    ${statement.infoResourceName!}
                                <#else>
                                    ${statement.url!}
                                </#if>
                            </a>
                        </div>
                    </div>
                </#if>
                <#if statement.doi??>
                    <div class="row cites">
                        <div class="col-md-3 hidden altmetricLabel">
                            <strong>Altmetric </strong>
                        </div>
                        <div class="col-md-9">
                            <div class='altmetric-embed' data-doi="${statement.doi!}" data-badge-popover="right" data-hide-no-mentions="true"></div>
                        </div>
                    </div>
                </#if>
            </#if>
        </#if>
    </#local>

    <#local resourceTitle>
        <#if statement.infoResource??>
            <#if citationDetails?has_content>
                <div class="row"><a href="${profileUrl(statement.uri("infoResource"))}"  title="${i18n().resource_name}">${statement.infoResourceName}</a></div>
                <div class="citationDetails">${citationDetails}</div>
            <#else>
                <a href="${profileUrl(statement.uri("infoResource"))}"  title="${i18n().resource_name}">${statement.infoResourceName}</a>
            </#if>
        <#else>
            <#-- This shouldn't happen, but we must provide for it -->
            <a href="${profileUrl(statement.uri("authorship"))}" title="${i18n().missing_info_resource}">${i18n().missing_info_resource}</a>
        </#if>
    </#local>
        
    <td class="col-md-1"><@dt.yearSpan "${statement.dateTime!}" /></td><td>${resourceTitle}</td>
</#if>
</#macro>
