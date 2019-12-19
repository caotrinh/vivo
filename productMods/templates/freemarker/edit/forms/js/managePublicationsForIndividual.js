/* $This file is distributed under the terms of the license in /doc/license.txt$ */

var managePublications = {

    /* *** Initial page setup *** */
   
    onLoad: function() {
    
            this.mixIn();               
            this.initPage();       
        },

    mixIn: function() {

        // Get the custom form data from the page
        $.extend(this, customFormData);
        $.extend(this, i18nStrings);
    },

    // Initial page setup. Called only at page load.
    initPage: function() {
        this.initPublicationData();
        this.bindEventListeners();
    },

    initPublicationData: function(){
        $('.allPubs').each(function(index){
            $(this).empty();
            //add checkbox and label for hide and show pubs
            var checkboxId = 'checkbox_'+index;
            var checkbox = $('<input/>', { type: 'checkbox', class: 'pubCheckbox', id:checkboxId}).data(publicationData[index]);
            var label = $('<label/>').attr('for', checkboxId);
            if(publicationData[index].hideThis){
                checkbox.attr('checked', true);
            }
            $(this).prepend(checkbox).append(label);

            //add adding top publication button
            var aLink = $('<a/>').addClass('addToTopPubs enabled').data(publicationData[index]);
            if(checkbox.attr('checked') || _.contains(_.pluck(topPubData, "toppubUri"), publicationData[index].authorshipUri)){
                if(_.contains(_.pluck(topPubData, "toppubUri"), publicationData[index].authorshipUri)) aLink.removeClass('enabled').addClass('disabled');
                if(checkbox.attr('checked')) aLink.addClass('inactive');
            } else {
                aLink.addClass('handler');
            }

            $(this).append($('<td/>').addClass('col-md-1').prepend(checkbox).append(label).append(aLink));
            $(this).append($('<td/>').addClass('col-md-1').append(publicationData[index].year));
            $(this).append($('<td/>').addClass('col-md-10').append(publicationData[index].title));
        });
        var bool = true;
        publicationData.forEach(function(item){
            bool = bool && item.hideThis;
        });
        $("#showHideAllPubs").attr("checked", bool);
    },
    
    bindEventListeners: function() {

        $('.pubCheckbox').click(function() {
            managePublications.processPublication(this);
        });

        $('.addToTopPubs.handler').click(function(){
            managePublications.addPublicationToTopPubs(this);
        });
        $("#showHideAllPubs").unbind('change').change(function(){
            managePublications.toggleAllPublications(this);
        });
    },

    generateToggleAllPublications: function(){
        var retVal = "";
        $('.pubCheckbox').each(function(item){
            retVal += "<"+$(this).data('authorshipUri')+"> <http://vivoweb.org/ontology/core#hideFromDisplay> \"true\" . ";
        });
        return retVal;
    },

    addPublicationToTopPubs: function(publication){
        var maxOrder = manageTopPublications.getMaxOrder() + 1;
        var n3String = "<"+personUri+"> <http://uowvivo.uow.edu.au/ontology/uowvivo#toppub> <"+$(publication).data('authorshipUri')+"> ."
                      +"<"+$(publication).data('authorshipUri')+"> <http://uowvivo.uow.edu.au/ontology/uowvivo#publicationRank> \""+ maxOrder +"\"^^<http://www.w3.org/2001/XMLSchema#int> .";
        $.ajax({
            url: managePublications.processingUrl,
            type: 'POST',
            data:{
                additions: n3String,
                retractions: ""
            },
            dataType: 'json',
            complete: function(request, status){
                if(status === 'success'){
                    window.status = managePublications.publicationSuccessfullyExcluded,
                    topPubData.push({"toppubUri": $(publication).data('authorshipUri'), "order": maxOrder, "title": $(publication).data('title'), "year": $(publication).data('year')});
                    if(topPubData.length == 1){
                        $("#noTopPubs").addClass('hidden');
                        $("#topPubs").removeClass('hidden');
                    }
                    manageTopPublications.initPage();
                    managePublications.initPage();
                } else {
                    alert(managePublications.errorExcludingPublication);
                }
            }
        });
    },

    toggleAllPublications: function(){
        var add = "";
        var retract = "";
        var n3String = managePublications.generateToggleAllPublications();
        if ( $('#showHideAllPubs').is(':checked') ) {
            add = n3String;
        }
        else {
            retract = n3String;
        }

        $.ajax({
            url: managePublications.processingUrl,
            type: 'POST', 
            data: {
                additions: add,
                retractions: retract
            },
            dataType: 'json',
            complete: function(request, status) {
            
                if (status === 'success') {
                    window.status = managePublications.publicationSuccessfullyExcluded; 
                    publicationData.forEach(function(item){
                        item.hideThis = $('#showHideAllPubs').attr('checked');
                    });
                    topPubData.forEach(function(item){
                        item.hideThis = $('#showHideAllPubs').attr('checked');
                    });
                } else {
                    alert(managePublications.errorExcludingPublication);
                }
                managePublications.initPage();
                manageTopPublications.initPage();
            }
        }); 
    },
                      
    processPublication: function(publication) {
        
        var add = "";
        var retract = "";
        var n3String = "<" + $(publication).data('authorshipUri') + "> <http://vivoweb.org/ontology/core#hideFromDisplay> \"true\" ." ;

        if ( $(publication).is(':checked') ) {
            add = n3String;
        }
        else {
            retract = n3String;
        } 
        
        $.ajax({
            url: managePublications.processingUrl,
            type: 'POST', 
            data: {
                additions: add,
                retractions: retract
            },
            dataType: 'json',
            context: publication, // context for callback
            complete: function(request, status) {
            
                if (status === 'success') {
                    window.status = managePublications.publicationSuccessfullyExcluded;
                    _.findWhere(publicationData, {authorshipUri: $(publication).data('authorshipUri')}).hideThis = $(publication).is(':checked');
                    var item = _.findWhere(topPubData, {toppubUri: $(publication).data('authorshipUri')});
                    if(item){
                        item.hideThis = $(publication).is(':checked');
                    }
                    managePublications.initPage();
                    manageTopPublications.initPage();
                } else {
                    alert(managePublications.errorExcludingPublication);
                    $(publication).removeAttr('checked');
                }
            }
        });        
    }

};

$(document).ready(function() {   
    managePublications.onLoad();
    manageTopPublications.onLoad();
}); 
