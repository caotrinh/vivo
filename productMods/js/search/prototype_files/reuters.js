var Manager;
var popups = {};
var totalNumberForPage = -1;
var alphbeticSearchDefaultFq = 'label';
var sort = 'dp_label asc';

function getUrlVars() {
  var vars = [], hash;
  var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
  for(var i = 0; i < hashes.length; i++)
  {
      hash = hashes[i].split('=');
      vars.push(hash[0]);
      vars[hash[0]] = hash[1];
  }
  return vars;
}

function isPeoplePage(){
  if(window.location.href.indexOf('/people') >= 0){
    alphbeticSearchDefaultFq = 'dp_lastName';
    sort = 'dp_lastName asc'
  }
}

(function ($) {
  isPeoplePage();
  $(function () {
    Manager = new AjaxSolr.Manager({
      solrUrl: solrServerUrl
    });
    Manager.addWidget(new AjaxSolr.ResultWidget({
      id: 'result',
      target: '#docs',
      availableClassSearchOptionsTarget: '.vClassGroupSearchLink'
    }));
    Manager.addWidget(new AjaxSolr.AlphabeticSearchWidget({
      id: 'alphbeticSearch',
      clickTarget: '.alphabeticSearchLetter',
      field: alphbeticSearchDefaultFq,
      taggedField:'research_areas',
      tagAndExclude: true,
      allowMultipleValues: false
    }));
    Manager.addWidget(new AjaxSolr.PagerWidget({
      id: 'pagerTop',
      target: '#pager-top',
      prevLabel: '&lt; prev',
      nextLabel: 'next &gt;',
      innerWindow: 1,
      renderHeader: function (perPage, offset, total) {
        $('#pager-header').html($('<span></span>').text('displaying ' + Math.min(total, offset + 1) + ' to ' + Math.min(total, offset + perPage) + ' of ' + total));
      }
    }));
    Manager.addWidget(new AjaxSolr.PagerWidget({
      id: 'pagerBottom',
      target: '#pager-bottom',
      prevLabel: '&lt; prev',
      nextLabel: 'next &gt;',
      innerWindow: 1,
      renderHeader: function (perPage, offset, total) {
        $('#pager-header').html($('<span></span>').text('displaying ' + Math.min(total, offset + 1) + ' to ' + Math.min(total, offset + perPage) + ' of ' + total));
      }
    }));
    Manager.addWidget(new AjaxSolr.TextWidget({
      id: 'key_words',
      target: '#keywordsSearch',
      title: 'Search',
      taggedField:'research_areas',
      tagAndExclude: true,
      field: 'op_freetextSearch'
    }));
    Manager.addWidget(new AjaxSolr.CurrentSearchWidget({
      id: 'currentsearch',
      target: '#currentSearchSelection'
    }));
    Manager.addWidget(new AjaxSolr.ClassGroupWidget({
      id:'classGroupSearch',
      clickTarget:'.vClassGroupSearchLink',
      field: 'mostSpecificTypeURIs',
      taggedField:'research_areas',
      tagAndExclude: true,
      allowMultipleValues: false
    }));
    Manager.addWidget(new AjaxSolr.MultiCheckboxFacet({
      id: 'research_areas',
      target: '#researchArea',
      field: ['op_label_hasAssociatedConcept'],
      title: 'Research Areas',
      tagAndExclude: true,
      alignedTarget: '#currentSearchSelection',
      allowMultipleValues: true,
      limit: 5
    }));
    popups.research_areas = new AjaxSolr.MultiCheckboxPopup({
      id: 'research_areas_popup',
      target: '#researchAreaPopup',
      field: ['op_label_hasAssociatedConcept'],
      title: 'Research Areas',
      tagAndExclude: true,
      allowMultipleValues: true,
      limit: 9999
    });
    Manager.addWidget(new AjaxSolr.HasFacetCheckboxWidget({
      id: 'hasOpenAccess',
      target: '#openAccessSearch',
      field: 'dp_hasOpenAccess',
      title: 'Open Access',
      tagAndExclude: true,
      checkboxId: 'openAccess'
    }));
    Manager.init();
    Manager.store.addByValue('q', '*:*');
    var params = {
      'facet': true,
      'facet.field': ['{!ex=research_areas}op_label_hasAssociatedConcept','{!ex=research_areas}dp_hasOpenAccess'],
      'facet.mincount': 1,
      'f.op_label_hasAssociatedConcept.facet.limit': 9999,
      'facet.limit': 5,
      'f.classgroup.facet.limit': 20,
      'facet.sort': 'index',
      'hl': true,
      'hl.snippets': 2,
      'hl.fl': 'ALLTEXT',
      'hl.fragsize': 120,
      'rows': 30,
      'sort': sort,
      'json.nl': 'map'
    };
    var preDefineFq;
    if(getUrlVars()['type']){
      if(getUrlVars()['type'] == 'supervisor'){
        preDefineFq = {'fq': 'mostSpecificTypeURIs:"http://uowvivo.uow.edu.au/ontology/uowvivo#openForSupervision"'};
      } else if ( getUrlVars()['type'] == 'collaborator') {
        preDefineFq = {'fq': 'mostSpecificTypeURIs:"http://uowvivo.uow.edu.au/ontology/uowvivo#openForCollaboration"'};
      } 
    }
    $.extend(true, params, preDefineFq);
    for (var name in params) {
      Manager.store.addByValue(name, params[name]);
    }

    Manager.doRequest();
  });

})(jQuery);
