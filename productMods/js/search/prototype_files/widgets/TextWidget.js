(function ($) {

AjaxSolr.TextWidget = AjaxSolr.AbstractFacetWidget.extend({
  init: function () {
    var self = this;
    var target = $(self.target);
    target.empty();
    target.append('<h4 class="panel-heading">'+self.title+'</h4>')
          .append($('<div/>').addClass('input-group')
          .append('<input type="text" class="form-control" placeholder="Search for...">')
          .append($('<span/>').addClass('input-group-btn')
          .append('<button class="btn btn-default" type="button">Add</button>')));
    target.find('input').bind('keydown', function(e) {
      var code = e.keyCode || e.which;
      if(code == 13){
        self.clickHandler();
      }
    });
    target.find('button').click(function(){
      self.clickHandler();
    });
  },

  clickHandler: function(){
    var self = this;
    var target = $(self.target);
    var param = new AjaxSolr.Parameter({
        name: 'fq',
        key: self.field,
        value: '/.*'+target.find('input').val().toLowerCase()+'.*/',
        filterType: 'normal'
    });
    if (self.tagAndExclude) {
      param.local('tag', self.taggedField);
    }
    if (self.setParam(param)) {
      self.manager.doRequest(0);
    }

    return false;
  },

  afterRequest: function () {
    $(this.target).find('input').val('');
  },
  setParam: function (param) {
      var b2 = this.manager.store.add('fq', param);
      return b2;
  }
});

})(jQuery);
