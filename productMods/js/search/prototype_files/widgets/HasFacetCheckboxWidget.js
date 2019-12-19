(function ($) {

AjaxSolr.HasFacetCheckboxWidget = AjaxSolr.AbstractFacetWidget.extend({
    constructor: function (attributes) {
	    AjaxSolr.HasFacetCheckboxWidget.__super__.constructor.apply(this, arguments);
	    AjaxSolr.extend(this, {
	      checkboxId: null
	    }, attributes);
	},

	afterRequest: function(){
		var self = this;
		var facets = self.responseFacetsMap();
	    var activeFacets = self.getActive();
	    var totalNumberOfResults = parseInt(this.manager.response.response.numFound);
	    var totalNumOfActiveResults = -1;
	    $(this.target).empty();

	    var percent = 0;

	    if(facets.length > 0 && facets[0].count > 0 & totalNumberOfResults >= 0){
		    if(activeFacets && activeFacets.length > 0){
		    	if(totalNumberOfResults != 0){
		    		percent = parseInt(100);
		    	}
		    	if(self.checkboxId == 'openAccess'){
			    	self.templateOpenAccess(totalNumberOfResults, activeFacets && activeFacets.length > 0, percent);
				}
		    } else {
		    	self.manager.executeRequest(self.manager.servlet, self.manager.store.string()+"&fq="+self.field+"%3Atrue", function(data){
		    		totalNumOfActiveResults = data.response.numFound;
		    		if( totalNumberOfResults != 0 ){
		    			percent = Math.round(totalNumOfActiveResults / totalNumberOfResults * 100);
		    		}
		    		if(self.checkboxId == 'openAccess'){
				    	self.templateOpenAccess(totalNumberOfResults, activeFacets && activeFacets.length > 0, percent);
					}
		    	});
		    }
		    
		}
	},

	changeHandler: function (value) {
		var self = this;
		return function () {
			if($(self.target).find('#'+self.checkboxId).attr('checked')){
				var param = new AjaxSolr.Parameter({
			        name: 'fq',
			        key: self.field,
			        value: 'true',
			        filterType: 'normal'
			    });
				if (self.tagAndExclude) {
		        	param.local('tag', self.taggedField);
		      	}
		      	self.manager.store.add('fq', param);
			} else {
				self.clear();
			}
			
		    self.manager.doRequest(0);
		    return false;
		}
	},

	responseFacetsMap: function () {
	    var facets = [];
	    for (var value in this.manager.response.facet_counts.facet_fields[this.field]) {
			var count = parseInt(this.manager.response.facet_counts.facet_fields[this.field][value]);
			facets.push({ value: value, count: count });
	    }
	    return facets;
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

	templateOpenAccess: function(totalResults, checked, percentage){
		var self = this;
		var target = $(this.target);
		var message = '';
    	if(totalNumberForPage > 0){
	    	message = '<span class="small"><img src="/images/openAccess.png"> <strong>'+ percentage + '%</strong> of '+totalResults+' Resources</span>';
	    }

		target.addClass('panel panel-default');
    	var checkbox = $('<input/>').attr('type','checkbox').attr('id',self.checkboxId).attr('name', 'hasOpenAccess')
    					.attr('data-size','mini').attr('data-animate','true').addClass('checkbox');
    	var label = $('<label/>').addClass('facet-item-label small').attr('for','openAccess').text('Show only Open Access Resources');
    	
    	if(checked){
    		checkbox.attr('checked','checked');
    	}
	    target.append($('<h4/>').addClass('panel-heading').text(self.title));
	    target.append($('<div/>').addClass('panel-body').append($('<div/>').attr('id','openAccessMessage').addClass('alert alert-grey').html(message))
	    	  .append(checkbox).append(label));
	    jQuery_1_11("#"+self.checkboxId).bootstrapSwitch().on('switchChange.bootstrapSwitch',self.changeHandler());
	}
});
})(jQuery);
