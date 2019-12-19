var toggleOpenForCollaboration = {

	init: function(){
		$.extend(this, customFormData);
		this.bindEventListeners();
	},

	bindEventListeners: function(){
		if(initStatusCollab == "true"){
			$("#openForCollaboration").attr("checked", "checked");
		}
		jQuery_1_11("#openForCollaboration").bootstrapSwitch().on('switchChange.bootstrapSwitch', this.toggleCollaboration());
	},
	
	toggleCollaboration: function(){
		return function(){
			var query = "<"+toggleOpenForCollaboration.personUri+"> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://uowvivo.uow.edu.au/ontology/uowvivo#openForCollaboration> . ";
			var retractions = "";
			var additions = "";
			initStatusCollab = $('#openForCollaboration').attr('checked');
			if(initStatusCollab){
				additions = query;
			} else {
				retractions = query;
			}
			$.ajax({
				url: toggleOpenForCollaboration.processingUrl,
				type: 'POST', 
				data: {
				    retractions: retractions,
				    additions: additions
				},
				dataType: 'json',
				complete: function(request, status) {
				    if (status === 'success') {
				    	if($('.openForCollaborationLabel').length > 0){
				    		$('.openForCollaborationLabel').toggle(initStatusCollab);
				    	} else {
				    		$('.openForCollaborationDiv').prepend("<h4><span class=\"label label-default openForCollaborationLabel\">Available for collaborative projects</span></h4>");
				    	}
				    } else {
				        alert('Failed to toggle collaboration availability, please contact support for help.');
				    }
				}
			});
		}
	}
}

$(document).ready(function() {   
    toggleOpenForCollaboration.init();
}); 
