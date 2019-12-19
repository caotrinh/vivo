(function ($) {

AjaxSolr.ResultWidget = AjaxSolr.AbstractWidget.extend({
  start: 0,

  constructor: function (attributes) {
    AjaxSolr.ResultWidget.__super__.constructor.apply(this, arguments);
    AjaxSolr.extend(this, {
      availableClassSearchOptionsTarget: null
    }, attributes);
  },

  beforeRequest: function () {
    $(this.target).html($('<img>').attr('src', 'images/ajax-loader.gif'));
  },

  afterRequest: function () {
    var self = this;
    var target = $(this.target);
    target.empty();

    var list = $('<ul/>').attr('role', 'list');
    for (var i = 0, l = this.manager.response.response.docs.length; i < l; i++) {
      var doc = this.manager.response.response.docs[i];
      list.append($('<li/>').addClass('individual').attr('role','listitem').append($('<div/>').addClass('row').append($(self.template(doc)))));
      jQuery()

    }
    if(this.manager.response.response.docs.length < 1){
      list.append($('<li/>').text('No result found. Please try other search criteria.'));
    }
    target.append(list);
    //make investigators list only showing 280 characters
    $('span.investigatorsList').truncate({max_length: 280, display_number:1});
    $('span.citation').truncate({max_length: 80, display_number:1});
  },

  /**
   * Theme a single search result
   *
   * @param {Object} doc Solr document
   * @param {String} snippet Highlighted text snippet
   * @param {Boolean} national Where this is a national search result
   */
  template: function (doc) {
    var output = '';
    var displayURI = '';
    if(doc.URI !== undefined){
      displayURI = doc.URI.substring(doc.URI.indexOf('/individual')).replace("individual","display");
    }

    //1st line: title/fullName + preferred title, with thumbnail image
    var title = '';
    if(doc.dp_lastName && doc.dp_firstName){
      title = doc.dp_lastName+', '+doc.dp_firstName;
    } else if(doc.label !== undefined){
      title = doc.label;
    }

    output = '<div class="col-xs-4 col-sm-3 col-lg-2"><span class="individualImg">';
    if(doc.THUMBNAIL_DOWNLOAD_URL){
      output += '<img class="img-responsive center-block" src="'+doc.THUMBNAIL_DOWNLOAD_URL+'" alt="'+title+'"/>';
      //TODO: for publications, provide default thumbnail img
    } else if( (doc.URI.indexOf('/individual') > 0 && doc.URI.indexOf( '_' ) > 0 ) || doc.URI.indexOf('/student') > 0  || doc.URI.indexOf( '/person' ) > 0 ){
      
      output += '<a href="' + displayURI + '" title="View profile: ' + this.htmlEscape(title) + '">';
      output += '<img class="img-responsive center-block" src="/images/placeholders/person.thumbnail.jpg" alt="'+title+'"/>';
      output += '</a>';
    } else if(doc.URI.indexOf('/publication') > 0 || doc.URI.indexOf('/journal') > 0){
      output += '<a href="' + displayURI + '" title="View publication: ' + this.htmlEscape(title) + '">';
      output += '<img class="img-responsive center-block" src="/images/placeholders/publication.thumbnail.png" alt="'+title+'"/>';
      output += '</a>';
    } else if(doc.URI.indexOf('/grant') > 0){
      output += '<a href="' + displayURI + '" title="View grant: ' + this.htmlEscape(title) + '">';
      output += '<img class="img-responsive center-block" src="/images/placeholders/thumbnail.jpg" alt="'+title+'"/>';
      output += '</a>';
    } else {
      output += '<img class="img-responsive center-block" src="/images/placeholders/thumbnail.jpg" alt="'+title+'"/>';
    }

    output += '</span></div>';
    output += '<div class="col-xs-8 col-sm-9 col-lg-10">';

    if(doc.URI.indexOf('/publication') > 0 || doc.URI.indexOf('/journal') > 0){
      output += '<strong><a href="' + displayURI + '" title="View publication: ' + this.htmlEscape(title) + '">' + title + '</a></strong>';
    } else if(doc.URI.indexOf('/grant') > 0){
      output += '<strong><a href="' + displayURI + '" title="View grant: ' + this.htmlEscape(title) + '">' + title + '</a></strong>';
    }
    else {
      output += '<strong><a href="' + displayURI + '" title="View profile page: ' + this.htmlEscape(title) + '">' + title + '</a></strong>';
    }

    if(doc.PREFERRED_TITLE){
      output += '<em>  '+doc.PREFERRED_TITLE+'</em>';
    }
    else if(doc.dp_preferredTitle){
      output += '<em>  '+doc.dp_preferredTitle+'</em>';
    }
    output+= '<br/>';

    //2nd line: show publication title for pubs
    if(doc.POSITION_TITLE){
      output += '<b>Position: </b>'+doc.POSITION_TITLE+'<br/>';
    }
    if(doc.dp_presentedAt){
      output += '<b>Conference: </b>'+doc.dp_presentedAt+'<br/>';
    }
    if(doc.op_label_hasPublicationVenue){
      output += '<b>Journal Title: </b>'+doc.op_label_hasPublicationVenue+'<br/>';
    }
    //4th line:
    if(doc.dp_roFulltextUrl){
      output += '<span><a class="openAccessImg" href="'
             +doc.dp_roFulltextUrl+'" target="_blank" title="download full-text article from open access"></a></span>';
    }
    if(doc.op_contributingRole){
      output += '<span class="investigatorsList"><b>Investigators: </b>';
      c = 0;
      for(var role in doc.op_contributingRole){
        if(c > 0) {
          output += ' | ';
        }
        output += doc.op_contributingRole[role];
        c = c+1;
        /*
        var identifier = doc.op_contributingRole[role].substr(doc.op_contributingRole[role].lastIndexOf('/')+1);
        if(role > 0){
          output += ' | ';
        }
        if(doc['op_context_person'+identifier]){
          output += '<a href="/display/person'+identifier+'">'+doc['op_context_person'+identifier]+'</a>';
        } else if(doc['op_context_invrole'+identifier]){
          output += doc['op_context_invrole'+identifier];
        }
        */
      }
      output += '</span>';
    }
    //TODO: need to be agency
    if(doc.op_label_assignedBy){
      output += '<span class="fundingAgency"><b>Funding Agency: </b>'+doc.op_label_assignedBy+'</span>';
    }
    if(doc.op_context_groupType){
      output += '<!--group type--><b>Type: </b>'+doc.op_context_groupType;
    }

    //3rd line: show doi/scheme
    if(doc.dp_doi){
      output += '<span class="doi"><b>DOI: </b>'+doc.dp_doi+"</span>";
    }
    if(doc.dp_scopusEid){
      //give a static link to EID
      output += '<span class="externalIds"><b>Scopus EID: </b><a target="_blank" href="http://www.scopus.com/record/display.url?eid='+doc.dp_scopusEid+'&origin=inward">'+doc.dp_scopusEid+'</a></span>';
    }
    // if(doc.dp_accession){
    //   output += '<span class="externalIds"><b>Web Of Science: </b>'+doc.dp_accession+'</span>';
    // }
    if(doc.dp_scheme){
      output += '<span class="grantScheme"><b>Grant Scheme: </b>'+doc.dp_scheme+'</span>';
    }

    //5nd line:
    if(doc.dp_quotedcitation){
      output+= '<span class="citation"><b>Citation: </b>'+doc.dp_quotedcitation+'</span>';
    }

    //6th line: research area for people, publication title for pub, group type for group, funding agency for grant
    if(doc.op_label_hasResearchArea){
      output += '<span class="associatedConcept"><b>Research Area: </b>'+doc.op_label_hasResearchArea+'</span>';
    }
    if(doc.op_label_hasSubjectArea){
      output += '<span class="associatedConcept"><b>Subject Area: </b>'+doc.op_label_hasSubjectArea+'</span>';
    }

    //8th line: number of things
    output += '<br/>';
    if(doc.op_context_memberCnt){
      output += '<span class="numberPlaceHolder"><b>' + doc.op_context_memberCnt + '</b> Members </span>';
    }
    if(doc.op_context_authorOfPubsCount){
      output += '<span class="numberPlaceHolder"><b>' + doc.op_context_authorOfPubsCount + '</b> Publications </span>'
    }
    if(doc.op_context_investigatorOf && parseInt(doc.op_context_investigatorOf) > 0){
      output += '<span class="numberPlaceHolder"><b>' + doc.op_context_investigatorOf + '</b> Grants </span>';
    }

    //7th line: keywords for all
    if(doc.dp_freetextKeyword){
      output+='<span class="keywords"><b>Keywords: </b>'+doc.dp_freetextKeyword+'</span>';
    }
    output+='</div></a>';
    return output;
  },
  getActiveSearchOption: function(){
    $(availableClassSearchOptionsTarget).each(function(){
      if($(this).hasClass('active')){
        return $(this).attr('data-uri');
      }
    });
  },
  htmlEscape: function(str) {
    return String(str)
        .replace(/&/g, '&amp;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#39;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;');
  }
});
})(jQuery);
