/* $This file is distributed under the terms of the license in /doc/license.txt$ */
(function ($) {

AjaxSolr.ClassGroupWidget = AjaxSolr.AbstractFacetWidget.extend({

  constructor: function (attributes) {
    AjaxSolr.ClassGroupWidget.__super__.constructor.apply(this, arguments);
    AjaxSolr.extend(this, {
      clickTarget: null,
      taggedField: null
    }, attributes);
  },

  getAllVClassGroups: function(){
    var vClasses = [];
    console.log(this.clickTarget);
    $(this.clickTarget).each(function(){
      vClasses.push($(this).attr('data-uri'));
    });
    return vClasses;
  },

  defaultParamString: function(){
    var vClasses = this.getAllVClassGroups();
    var defaultPageSearch = '';
    for(var name in vClasses){
      if(name == 0){
        defaultPageSearch += '(';
      }
      if(name != 0){
        defaultPageSearch += ' OR ';
      }
      defaultPageSearch += '"' + vClasses[name] + '"';
      if(name == vClasses.length - 1){
        defaultPageSearch += ')';
      }
    }
    return defaultPageSearch;
  },

  defaultParam: function(){
    return new AjaxSolr.Parameter({name:'fq', value:this.field + ':'+this.defaultParamString()});
  },

 /* add default search when load each page,
  * so that only certain type of vclass will be limited in the result
  * the query will be like this:
  * fq=type:("uri1" OR "uri2" OR "uri3"...)
  */
  setDefaultParam: function(){
    this.manager.store.addByValue('fq', this.field + ':'+this.defaultParamString());
  },
  /**
   * On startup, create the classgroup menu even if there are no search terms yet
   */
  init: function () {
    var self = this;
    
    //asign click handler to hyperlinks
    $(self.clickTarget).each(function(){
      $(this).click(self.clickHandler($(this).attr('data-uri')));
    });
    self.setDefaultParam();
  },

  /**
   * @param {value} a vclass group URI.
   * @returns {Function} The click handler for searching vclass group.
   * e.g. Faculty Member, Staff, Student etc
   */
  clickHandler: function (value) {
    var self = this;
    return function () {
      
      // self.doRequest();
      var param = new AjaxSolr.Parameter({
        name: 'fq',
        key: self.field,
        value: value,
        filterType: 'subquery'
      });
      if (self.tagAndExclude) {
        param.local('tag', self.taggedField);
      }
      if (self.setParam(param)) {
        self.manager.doRequest(0);
      }
      return false;
    }
  },

  setParam: function (param) {
    var b1 = this.clear();
    this.setDefaultParam();
    this.manager.store.addByValue('start','0');
    var b2 = true;
    if(param.value.indexOf('allCategory') < 0){
      b2 = this.manager.store.add('fq', param);
    }
    return b1 || b2;
  },

  getActive: function() {
    var facets = [];
    if (keys = this.manager.store.find('fq', new RegExp('^-?' + this.field + ':'))) {
      for (var i=0; i<keys.length; i++) {
        var param = this.manager.store.params['fq'][keys[i]];
        if (AjaxSolr.isArray(param.value)) {
          for (var j=0; j<param.value.length; j++) {
            facets.push(param.value[j]);
          }
        }
        else {
          facets.push(param.value);
        }
      }
    }
    return facets;
  },

  afterRequest: function(){
    if(totalNumberForPage < 0){
      var self = this;
      var activeFacets = self.getActive();
      var activeGroup;
      for(var i=0; i<activeFacets.length; i++){
        if(activeFacets[i].indexOf("OR") < 0){
          activeGroup = activeFacets[i].match("\".*\"");
        }
      }
      if(activeGroup){
        $(self.clickTarget).each(function(){$(this).removeClass('active')});
        $(self.clickTarget).filter('[data-uri=' + activeGroup + ']').addClass('active');

      }
      totalNumberForPage = this.manager.response.response.numFound;
      self.manager.executeRequest(self.manager.servlet, self.defaultParam().string(), function(data){
            totalNumberForPage = data.response.numFound;
            $(self.clickTarget).filter('[data-uri="allCategory"]').find('.count-classes.badge').empty().text(totalNumberForPage);
      });
    }
  }
});

})(jQuery);
