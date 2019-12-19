<script type="text/javascript">
    var solrServerUrl="${urls.solr}/";
</script>

<#include "search-include-scripts.ftl">
<#import "lib-string.ftl" as str>
<noscript>
<p style="padding: 20px 20px 20px 20px;background-color:#f8ffb7">${i18n().browse_page_javascript_one} <a href="${urls.base}/browse" title="${i18n().index_page}">${i18n().index_page}</a> ${i18n().browse_page_javascript_two}</p>
</noscript>

<section id="noJavascriptContainer" class="hidden">
  <section id="browse-by" role="region">
    <div class="row">
      <div class="col-xs-12 col-md-3">
          <div class="col-xs-12">
              <div class="panel panel-default">
                <h4 class="panel-heading">Current Filters</h4>
                <div class="panel-body">
                  <ul id="currentSearchSelection"></ul>
                </div>
              </div>
              <div class="panel panel-default">
                <h4 class="panel-heading">Categories</h4>
                <div class="panel-body">
                  <ul id="browse-classes" class="list-group">
                    <li id="allCategories">
                      <a class="list-group-item vClassGroupSearchLink" href="#" title="${i18n().browse_all_individuals}" data-uri="allCategory">
                        <div class="row">
                          <div class="col-xs-6 col-md-9 vcenter">All</div><!--
                          --><div class="col-xs-6 col-md-3 vcenter"><div class="count-classes badge"></div></div>
                        </div>
                      </a>
                    </li>
                    <script>
                      if(document.URL.indexOf('/grants') > 0){
                        $('#allCategories').remove();
                      }
                    </script>
                    <#list vClassGroup?sort_by("displayRank") as vClass>
                          <#------------------------------------------------------------
                          Need to replace vClassCamel with full URL that allows function
                          to degrade gracefully in absence of JavaScript. Something
                          similar to what Brian had setup with widget-browse.ftl
                          ------------------------------------------------------------->
                          <#assign vClassCamel = str.camelCase(vClass.name) />
                          <#-- Only display vClasses with individuals -->
                          <#if (vClass.entityCount > 0)>
                              <li id="${vClassCamel}">
                                  <a class="list-group-item vClassGroupSearchLink" href="#" title="${i18n().browse_all_in_class}" data-uri="${vClass.URI}">
                                      <div class="row">
                                          <div class="col-xs-6 col-md-9 vcenter">${vClass.name}</div><!--
                                          --><div class="col-xs-6 col-md-3 vcenter"><div class="count-classes badge">${vClass.entityCount}</div></div>
                                      </div>
                                  </a>
                              </li>
                          </#if>
                      </#list>
                  </ul>
                </div>
              </div>
              <div class="panel panel-default" id="keywordsSearch"></div>
              <div id="openAccessSearch"></div>
              <div id="researchArea"></div>
              <div class="facet-popup" id="researchAreaPopup" style="display: none;"></div>
          </div>
        </div>
        <div class="menupage-r col-xs-12 col-md-9" id="result">
            <div class="col-xs-12">
              <div>
              <nav id="alpha-browse-container" role="navigation">
                <h3 class="selected-class"></h3>
                <#assign alphabet = ["A", "B", "C", "D", "E", "F", "G" "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"] />
                <ul id="alpha-browse-individuals" class="pagination">
                  <li><a href="#" class="selected alphabeticSearchLetter" data-alpha="all" title="${i18n().select_all}">${i18n().all}</a></li>
                  <#list alphabet as letter>
                      <li><a class='alphabeticSearchLetter' href="#" data-alpha="${letter?lower_case}" title="${i18n().browse_all_starts_with(letter)}">${letter}</a></li>
                  </#list>
                </ul>
              </nav>
              </div>
              <br/>
              <div id="navigationTop">
                <ul id="pager-top" class="pager"></ul>
              </div>
              <section id="individuals-in-class" role="region">
                <ul id="docs" role="list"></ul>
              </section>
              <div id="navigationBtm">
                <ul id="pager-bottom" class="pager"></ul>
              </div>
            </div>
        </div>
    </div>    
  </section>
</section>
<script type="text/javascript">
    $('section#noJavascriptContainer').removeClass('hidden');
</script>