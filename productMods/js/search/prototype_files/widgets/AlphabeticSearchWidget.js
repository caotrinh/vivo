(function ($) {

AjaxSolr.AlphabeticSearchWidget = AjaxSolr.AbstractFacetWidget.extend({

 	constructor: function (attributes) {
	    AjaxSolr.AlphabeticSearchWidget.__super__.constructor.apply(this, arguments);
	    AjaxSolr.extend(this, {
	      clickTarget: null,
	      taggedField: null
	    }, attributes);
    },

    /**
	* On startup, create the classgroup menu even if there are no search terms yet
	*/
	init: function () {
		var self = this;
		//asign click handler to hyperlinks
		$(self.clickTarget).each(function(){
			$(this).click(self.clickHandler($(this).attr('data-alpha')));

			if($(this).attr('data-alpha') == 'all'){
				$(this).parent().addClass('selected').siblings().removeClass('selected');
			}
		});
	},

	clickHandler: function (value) {
		var self = this;
		return function () {
			var param = new AjaxSolr.Parameter({
		        name: 'fq',
		        key: self.field,
		        value: '/['+value.toUpperCase()+'|'+value.toLowerCase()+'].*/',
		        filterType: 'normal'
		    });
			if (self.tagAndExclude) {
	        	param.local('tag', self.taggedField);
	      	}
	      	if (self.setParam(param)) {
		        self.manager.doRequest(0);
		    }
		    $(this).parent().addClass('selected').siblings().removeClass('selected');
		    return false;
		}
	},
	setParam: function (param) {
	    var b1 = this.clear();
	    this.manager.store.addByValue('start','0');
	    var b2 = true;
	    if(param.value.indexOf('all') < 0){
			b2 = this.manager.store.add('fq', param);
	    }
	    return b1 || b2;
	}
});
})(jQuery);
