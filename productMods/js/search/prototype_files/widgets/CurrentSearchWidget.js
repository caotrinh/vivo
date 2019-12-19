(function ($) {
AjaxSolr.CurrentSearchWidget = AjaxSolr.AbstractWidget.extend({
  start: 0,
  afterRequest: function () {
    var self = this;
    var links = [];
    var removeAllSearchList = [];

    var fq = this.manager.store.values2('fq');
    var q = this.manager.store.values2('q');
    
    if (q != '*:*') {
      links.push($('<a href="#"/>').html('<span class="facet-wrapper"><span class="facet-type">' + item + '</span><span class="remove-facet glyphicon glyphicon-remove-sign"></span></span>').click(function () {
        self.manager.store.get('q').val('*:*');
        self.doRequest();
        return false;
      }));
    }
console.log(fq );
    for (var i = 0, l = fq.length; i < l; i++) {
      if (fq[i].match(/[\[\{]\S+ TO \S+[\]\}]/)) {
        var field = fq[i].match(/^\w+:/)[0];
        var value = fq[i].substr(field.length + 1, 10);
        field = '';
        links.push($('<a href="#"/>').html(field + value).click(self.removeFacet(fq[i])));
        removeAllSearchList.push(fq[i]);
      }
      else {
      	var field = fq[i].match(/^\w+:/)[0];
        var pos = fq[i].indexOf("mostSpecificTypeURIs:");
        if (pos!=0) {
        	var pos = fq[i].lastIndexOf(":")+1;
          var value = fq[i].substring(pos,fq[i].length);
          if(fq[i].substring(pos,fq[i].length).match(/^\/.*\/$/)){
            value = fq[i].substring(pos,fq[i].length).match(/[\w+\s?]+/)[0];
          }
          if(value){
            if(field.indexOf("dp_hasOpenAccess") >= 0){
              value="Open Access";
            }
            links.push($('<a href="#"/>').html('<span class="facet-wrapper"><span class="facet-type">' 
              + value + '</span><span class="remove-facet glyphicon glyphicon-remove-sign"></span></span>').click(self.removeFacet(fq[i])));
            removeAllSearchList.push(fq[i]);
          }
        }
      }
    }

    if (links.length > 1) {
      links.push($('<a href="#"></a>').text('remove all').click(function () {
        self.manager.store.get('q').val('*:*');
        for (var i = 0, l = removeAllSearchList.length; i < l; i++) {
          self.manager.store.removeByValue('fq', removeAllSearchList[i]);
        }
        self.doRequest();
        return false;
      }));
    }

    if (links.length) {
      var $target = $(this.target);
      $target.empty();
      for (var i = 0, l = links.length; i < l; i++) {
        $target.append($('<li></li>').append(links[i]));
      }
      $('.facet-type').truncate({max_length: 50, display_number:1});
    }
    else {
      $(this.target).empty();
    }
  },

  removeFacet: function (facet) {
    var self = this;
    return function () {
      if (self.manager.store.removeByValue('fq', facet)) {
        self.manager.doRequest(0);
      }
      return false;
    };
  }
});

})(jQuery);
