<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- VIVO-specific default data property statement template. 
    
     This template must be self-contained and not rely on other variables set for the individual page, because it
     is also used to generate the property statement during a deletion.  
 -->
<#if statement.hideThis?? && statement.hideThis == "true">
  <#if user.profileUrl?? && user.profileUrl?has_content>
    <#assign userProfileUri = user.profileUrl?substring(user.profileUrl?last_index_of("/"))/>
  <#else>
    <#assign userProfileUri = "" />
  </#if>
  <#if (user.loggedIn! && user.hasSiteAdminAccess) || ( user.loggedIn! && userProfileUri?? && userProfileUri?has_content && statement.subject?? && statement.subject?has_content && statement.subject?contains(userProfileUri)) >
    <@showStatement statement />
  </#if>
<#else>
  <@showStatement statement />
</#if>

<#macro showStatement statement>
  <#assign impactId = statement.impactEngagement?replace("http://uowvivo.uow.edu.au/individual/", "")>
  <div class="panel panel-default impactStory" id="heading_${impactId!}">

    <div class="panel-heading impact-title" role="tab">
        <h4 class="impactstory"><i class="fa fa-cube fa-2x" aria-hidden="true"></i>${statement.title!}</h4>
    </div>

    <div class="panel-body" style="padding:0px;">
      <div class="row row-striped description" style="padding:10px;" data-id="${impactId!}">
        <#if statement.hideThis?? && statement.hideThis == "true">
          <i class="fa fa-eye-slash"></i> <b>Draft Mode</b>: this Impact Story is only visible to the collaborators.
          <hr/>
        </#if>
        <label class="impact-label"><i class="fa fa-bars" aria-hidden="true"></i> Summary</label>
        <div class="col-ms-12 summary">${statement.description!}</div>
        <div class="displayDetails pull-right">
          <br/>
          <a href="#heading_${impactId!}" class="showDetailsLink btn btn-primary outline" data-uri="${statement.impactEngagement!}" title="Click to view all details"><i class="fa fa-expand" aria-hidden="true"></i>&nbsp;Detail View</a>
        </div>
      </div>

      <a class="expandableLink pull-right btn btn-primary outline" data-toggle="collapse" href="#collapse_${impactId!}" aria-expanded="false" aria-controls="collapse_${impactId!}" style="display:none;">
        <span class="if-collapsed" title="Click to view all details"><i class="fa fa-expand" aria-hidden="true"></i>&nbsp;Detail View</span>
        <span class="if-not-collapsed" title="Click to view summary"><i class="fa fa-compress" aria-hidden="true"></i>&nbsp;Summary View</span>
      </a>
      
      <div id="collapse_${impactId!}" class="expandable collapse in" aria-labelledby="heading_${impactId!}">
        <#if statement.detailOfImpact?has_content>
          <div class="row" style="padding:10px;display:none;" data-id="detail_${impactId!}">
              <label class="impact-label"><i class="fa fa-adjust" aria-hidden="true"></i>&nbsp;Detail of Impact</label>
            <div class="col-ms-12">${statement.detailOfImpact!}</div>
          </div>
        </#if>
        <div class="row" style="padding:10px;display:none;" data-id="for_${impactId!}">
          <label class="impact-label"><i class="fa fa-compass" aria-hidden="true"></i>&nbsp;Field of Research</label>
          <ul role="list" style="list-style:none;"></ul>
        </div>
        <div class="row" style="padding:10px;display:none;" data-id="country_${impactId!}">
          <label class="impact-label"><i class="fa fa-globe" aria-hidden="true"></i>&nbsp;Countries / Regions</label>
          <ul role="list" style="list-style:none;"></ul>
        </div>
        <div class="row" style="padding:10px;display:none;" data-id="beneficiary_${impactId!}">
            <label class="impact-label"><i class="fa fa-handshake-o" aria-hidden="true"></i>&nbsp;Beneficiaries</label>
          <table class="table table-hover">
            <thead>
              <tr>
                <th>Beneficiary</th>
                <th>Quantification</th>
                <th>Description</th>
              </tr>
            </thead>
            <tbody></tbody>
          </table>
        </div>
        <div class="row" style="padding:10px;display:none;" data-id="partner_${impactId!}">
          <label class="impact-label"><i class="fa fa-users" aria-hidden="true"></i>&nbsp;External Partners</label>
          <ul role="list" style="list-style:none;"></ul>
        </div>
        <div class="row" style="padding:10px;display:none;" data-id="evidence_${impactId!}">
            <label class="impact-label"><i class="fa fa-link" aria-hidden="true"></i>&nbsp;Evidence of Impact</label>
          <table class="table table-hover">
            <thead>
              <tr>
                <th>Evidence</th>
                <th>Description</th>
              </tr>
            </thead>
            <tbody></tbody>
          </table>
        </div>
        <div class="row" style="padding:10px;display:none;" data-id="program_${impactId!}">
          <label class="impact-label"><i class="fa fa-university" aria-hidden="true"></i>&nbsp;UOW Centres / Programs</label>
          <ul role="list" style="list-style:none;"></ul>
        </div>
        <div class="row" style="padding:10px;display:none;" data-id="collaborator_${impactId!}">
          <label class="impact-label"><i class="fa fa-user-circle-o" aria-hidden="true"></i>&nbsp;UOW Researchers / Collaborators</label>
          <ul role="list" style="list-style:none;"></ul>
        </div>
      </div>
    </div>
    <script>
      var ajaxUrl = '${urls.base}/impactStoryDetails?individualUri=';
      var PREFIX_INDIVIDUAL = "http://uowvivo.uow.edu.au/individual/";
      function renderTemplate(self, jsonArray){
        var descriptionDiv = $(self).closest('div.description[data-id]');
        var id = $(descriptionDiv).attr('data-id');
        for(var i = 0; i < jsonArray.length; i++) {
          var jsonObj = jsonArray[i];
          switch(jsonObj.type){
            case 'country':
              appendToList(descriptionDiv, 'country_'+id, jsonObj);
              break;
            case 'forcode':
              appendToList(descriptionDiv, 'for_'+id, jsonObj);
              break;
            case 'program':
              appendToList(descriptionDiv, 'program_'+id, jsonObj);
              break;
            case 'partner':
              appendToList(descriptionDiv, 'partner_'+id, jsonObj);
              break;
            case 'beneficiary':
              appendToBeneficiary(descriptionDiv, 'beneficiary_'+id, jsonObj);
              break;
            case 'evidence':
              appendToEvidence(descriptionDiv, 'evidence_'+id, jsonObj);
              break;
            case 'collaborator':
              appendToCollaborator(descriptionDiv, 'collaborator_'+id, jsonObj);
              break;
            default:
              break;
          }
        }
        orderBeneficiary(descriptionDiv,'beneficiary_'+id);
        renderDetailOfImpact(descriptionDiv, 'detail_'+id);
        $(descriptionDiv).css('background-color', '#efefef');
        $(descriptionDiv).siblings('div.expandable').find('.row-striped:odd').css('background-color', '#efefef');
        $(descriptionDiv).siblings('div.expandable').find('.row-striped:even').css('background-color', '#ffffff');
        $(descriptionDiv).siblings('a.expandableLink').css('display','block');
      }
      function renderDetailOfImpact(target,id){
        if($(target).siblings('div.expandable').find('[data-id="'+id+'"]').length > 0){
          $(target).siblings('div.expandable').find('[data-id="'+id+'"]').css('display','block').addClass('row-striped');
          var value = $(target).siblings('div.expandable').find('[data-id="'+id+'"] div').html();
          $(target).siblings('div.expandable').find('[data-id="'+id+'"] div').html(htmlUnescape(value));
        }
      }
      function orderBeneficiary(target,id){
        var listDiv = $(target).siblings('div.expandable').find('[data-id="'+id+'"] tbody:first');
        $(listDiv).find('[data-order]').sort(function (a, b) {
           return $(a).attr('data-order') - $(b).attr('data-order');
        })
        .appendTo(listDiv);
      }
      function appendToList(target, id, jsonObject){
        var listDiv = $(target).siblings('div.expandable').find('[data-id="'+id+'"]');
        $(listDiv).css('display','block').addClass('row-striped');

        var newEntry = $('<li />').attr('role', 'list');
        var icon = $('<i />');
        if(id.match('^country')) {
            icon.attr('class', 'fa fa-map-marker fa-fw').append("&nbsp;");
        }
        else if(id.match('^program')) {
            icon.attr('class', 'fa fa-lightbulb-o fa-fw').append("&nbsp;");
        }
        else if(id.match('^for')) {
            icon.attr('class', 'fa fa-rss fa-fw').append("&nbsp;");
        }
        else if(id.match('^partner')) {
            icon.attr('class', 'fa fa-address-book-o fa-fw').append("&nbsp;");
        }

        newEntry.append(icon).append(jsonObject.name);
        $(listDiv).find('ul:first').append(newEntry);
      }
      function appendToBeneficiary(target, id, jsonObject){
        var order = jsonObject.displayOrder ?  jsonObject.displayOrder : 9999;
        var listDiv = $(target).siblings('div.expandable').find('[data-id="'+id+'"]');
        $(listDiv).css('display','block').addClass('row-striped');
        var newEntry = $('<tr/>').attr('data-order',order).append($('<td/>').html(htmlUnescape(jsonObject.name))).append($('<td/>').html(htmlUnescape(jsonObject.info))).append($('<td/>').html(htmlUnescape(jsonObject.description)));
        $(listDiv).find('tbody:first').append(newEntry);
      }
      function appendToEvidence(target, id, jsonObject){
        var listDiv = $(target).siblings('div.expandable').find('[data-id="'+id+'"]');
        $(listDiv).css('display','block').addClass('row-striped');
        var newEntry = $('<tr>/>').append($('<td class="col-xs-3"/>').append("<i class='fa fa-external-link' aria-hidden='true'></i>&nbsp;").append($('<a/>').attr('href',htmlUnescape(jsonObject.info)).attr('target','_blank').html(htmlUnescape(jsonObject.name)))).append($('<td/>').html(htmlUnescape(jsonObject.description)));
        $(listDiv).find('tbody:first').append(newEntry);
      }
      function appendToCollaborator(target, id, jsonObject){
        var listDiv = $(target).siblings('div.expandable').find('[data-id="'+id+'"]');
        $(listDiv).css('display','block').addClass('row-striped');
        var newEntry = $('<li />').attr('role', 'list').append("<i class='fa fa-user' aria-hidden='true'></i>&nbsp;").append($('<a/>').attr('href','/display/'+jsonObject.obj.replace(PREFIX_INDIVIDUAL,'')).attr('target','_blank').text(jsonObject.name));
        $(listDiv).find('ul:first').append(newEntry);
      }
      function htmlUnescape(str){
        return str
          .replace(/&quot;/g, '"')
          .replace(/&#39;/g, "'")
          .replace(/&lt;/g, '<')
          .replace(/&gt;/g, '>')
          .replace(/&#x2F;/g, '/')
          .replace(/&#92;/g, '\\');
      }
      $(document).ready(function(){
        if($('form[action*="delete"]').length > 0){
          $('.showDetailsLink').addClass('hidden');
        }
        $('a.delete-hasImpactAndEngagement').each(function(){
          var hrefVal = $(this).attr('href');
          var trimDescription = hrefVal.match(/&?statement_description=([^&]$|[^&]*)/i);
          if(trimDescription && trimDescription.length > 0 && trimDescription[0].length > 200){
            hrefVal = hrefVal.replace(/&?statement_description=([^&]$|[^&]*)/i, trimDescription[0].substring(0, 196)+ '...');
          }
          hrefVal = hrefVal.replace(/&?statement_detailOfImpact=([^&]$|[^&]*)/i, '');
          $(this).attr('href',hrefVal);
        });
        $('div.description').each(function(){
          var value = htmlUnescape($(this).find('div.summary').html());
          $(this).find('div.summary').html(value);
        });
        $('.showDetailsLink').unbind().click(function(){
          var self = this;
          $.ajax({
            url: ajaxUrl+encodeURIComponent($(self).attr('data-uri')),
            type: 'GET', 
            dataType: 'json',
            complete: function(request, status) {
              if (status === 'success') {
                var tmpJson = $.parseJSON(request.responseText);
                renderTemplate(self, tmpJson);
                $(self).closest('.displayDetails').hide();
              } else {
                console.log('failed');
              }
            }
          });
        });
      });
    </script>
  </div>
</#macro>

