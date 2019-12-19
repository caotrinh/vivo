var toggleOpenForSupervision = {

	init: function(){
		$.extend(this, customFormData);
		this.bindEventListeners();
	},

	bindEventListeners: function(){
		if(initStatus == "true"){
			$("#openForSupervision").attr("checked", "checked");
		}
		jQuery_1_11("#openForSupervision").bootstrapSwitch().on('switchChange.bootstrapSwitch', this.toggleSupervision());
	},
	
	toggleSupervision: function(){
		return function(){
			var query = "<"+toggleOpenForSupervision.personUri+"> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://uowvivo.uow.edu.au/ontology/uowvivo#openForSupervision> . ";
			var retractions = "";
			var additions = "";
			initStatus = $('#openForSupervision').attr('checked');
			if(initStatus){
				additions = query;
			} else {
				retractions = query;
			}
			$.ajax({
				url: toggleOpenForSupervision.processingUrl,
				type: 'POST', 
				data: {
				    retractions: retractions,
				    additions: additions
				},
				dataType: 'json',
				complete: function(request, status) {
				    if (status === 'success') {
				    	if($('.openForSupervisionLabel').length > 0){
				    		$('.openForSupervisionLabel').toggle(initStatus);
				    	} else {
				    		$('.openForSupervisionDiv').prepend("<h4><span class=\"label label-default openForSupervisionLabel\">Available as Research Supervisor</span></h4>");
				    	}
				    } else {
				        alert('Failed to toggle supervision availability, please contact support for help.');
				    }
				}
			});
		}
	}
}

$(document).ready(function() {   
    toggleOpenForSupervision.init();
}); 
