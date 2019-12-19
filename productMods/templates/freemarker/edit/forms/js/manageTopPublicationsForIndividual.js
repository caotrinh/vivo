/* $This file is distributed under the terms of the license in /doc/license.txt$ */

var manageTopPublications = {

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
        this.renderOrderedTopPubs();
        this.initSortable();
        this.bindEventListeners();
    },

    // On page load, associate data with each list item. Then we don't
    // have to keep retrieving data from or modifying the DOM as we manipulate the
    // items.
    renderOrderedTopPubs: function(){
        var target = $('#topPubSortable');
        target.empty();
        topPubData = _.sortBy(topPubData, "order");
        topPubData.forEach(function(item){
            var link = $('<td/>').addClass('col-md-1').append($('<a/>').addClass('fa fa-star removeFromTopPubs').css('font-size','16px').data(item));
            var list = $('<td/>').addClass('col-md-1').text(item.year).after($('<td/>').addClass('col-md-10').text(item.title));
            var span = "";
            if(item.hideThis){
                span = $('<span/>').addClass('fa fa-eye-slash hiddenTopPub');
            }
            target.append($('<tr/>').append(link.append(span)).append(list));
            
        });
    },
    
    initSortable: function() {
        $( "#topPubSortable tbody" ).sortable({
            placeholder: "ui-state-highlight",
            start: function(event, ui) {
            	ui.placeholder.height(ui.item.height() + (ui.item.css("padding-top").replace("px", ""))*2);
            	ui.item.height(ui.item.height() + (ui.item.css("padding-top").replace("px", ""))*2);
                ui.item.data('start_order', ui.item.index());
            },
            update: function(event, ui){
                ui.item.data('stop_order', ui.item.index());
                if(ui.item.data('start_order') != ui.item.data('stop_order')){
                    var tmp = topPubData[ui.item.data('start_order')];
                    topPubData.splice(ui.item.data('start_order'), 1);
                    topPubData.splice(ui.item.data('stop_order'), 0, tmp);
                    manageTopPublications.reorderTopPublications(topPubData);
                }
            }
        });
        $( "#topPubSortable" ).disableSelection();         
    },

    bindEventListeners: function(){
        $('.removeFromTopPubs').click(function(){
            manageTopPublications.removeFromTopPubs(this);
        });
        $('#orderLatestYearFirst').click(function(){
            topPubData = _.chain(topPubData).sortBy("title").reverse().sortBy("year").reverse().value();
            manageTopPublications.reorderTopPublications(topPubData);
        });
        $('#orderOldestYearFirst').click(function(){
            topPubData = _.chain(topPubData).sortBy("title").sortBy("year").value();
            manageTopPublications.reorderTopPublications(topPubData);
        });
    },

    generateAddForReorder: function(){
        var retVal = "";
        topPubData.forEach(function(item, index){
            retVal += "<"+item.toppubUri+"> <http://uowvivo.uow.edu.au/ontology/uowvivo#publicationRank> \"" + (++index) + "\"^^<http://www.w3.org/2001/XMLSchema#int> . ";
        });
        return retVal;
    },

    generateRetractForReorder: function(){
        var retVal = "";
        topPubData.forEach(function(item){
            retVal += "<"+item.toppubUri+"> <http://uowvivo.uow.edu.au/ontology/uowvivo#publicationRank> \""+ item.order +"\"^^<http://www.w3.org/2001/XMLSchema#int> . ";
        });
        return retVal;
    },

    generateRetractForRemove: function(publication){
        var retVal = "<"+personUri+"> <http://uowvivo.uow.edu.au/ontology/uowvivo#toppub> <"+$(publication).data('toppubUri')+"> . " 
                    + manageTopPublications.generateRetractAllOrders($(publication).data('toppubUri'));
        return retVal;
    },

    generateRetractAllOrders: function(uri){
        var retVal = "";
        var maxOrder = manageTopPublications.getMaxOrder();
        for(var i=0; i<= maxOrder; i++){
            retVal += "<"+uri+"> <http://uowvivo.uow.edu.au/ontology/uowvivo#publicationRank> \""+i+"\"^^<http://www.w3.org/2001/XMLSchema#int> . ";
        }
        return retVal;
    },

    resetOrderAfterSaveSuccess: function(){
        topPubData.forEach(function(item, index){
            item.order = ++index;
        });
    },
                      
    reorderTopPublications: function() {
        $.ajax({
            url: manageTopPublications.processingUrl,
            type: 'POST', 
            data: {
                retractions: manageTopPublications.generateRetractForReorder(),
                additions: manageTopPublications.generateAddForReorder()
            },
            dataType: 'json',
            complete: function(request, status) {
                if (status === 'success') {
                    window.status = manageTopPublications.publicationSuccessfullyExcluded;
                    manageTopPublications.resetOrderAfterSaveSuccess();
                } else {
                    alert(manageTopPublications.errorExcludingPublication);
                }
                manageTopPublications.initPage();
            }
        });        
    },

    getMaxOrder: function(){
        var retVal = 0;
        if(topPubData){
            var item = _.max(topPubData, function(data){ return data.order; });
            if(/^\d+$/.test(item.order)){
                retVal = parseInt(item.order);
            }
        }
        return retVal;
    },

    removeFromTopPubs: function(topPub){
        $.ajax({
            url: manageTopPublications.processingUrl,
            type: 'POST', 
            data: {
                retractions: manageTopPublications.generateRetractForRemove(topPub),
                additions: ""
            },
            dataType: 'json',
            complete: function(request, status) {
                if (status === 'success') {
                    window.status = manageTopPublications.publicationSuccessfullyExcluded;
                    topPubData = _.without(topPubData, _.findWhere(topPubData, {toppubUri: $(topPub).data('toppubUri')}));
                    if(topPubData.length < 1){
                        $("#noTopPubs").removeClass('hidden');
                        $("#topPubs").addClass('hidden');
                    }
                } else {
                    alert(manageTopPublications.errorExcludingPublication);
                }
                manageTopPublications.initPage();
                managePublications.initPage();
            }
        });
    }

};
