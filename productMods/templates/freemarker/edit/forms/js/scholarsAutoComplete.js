var NEW_RESOURCE_PREFIX_CONST = "primitiveEditNew";
var RDF_TYPE_PRED = "http://www.w3.org/1999/02/22-rdf-syntax-ns#type";
var RSD_TYPE_STRING = "http://www.w3.org/2001/XMLSchema#string";
var PREFIX_INDIVIDUAL = "http://uowvivo.uow.edu.au/individual";
var HIDE_FROM_PUBLIC_PRED = "http://uowvivo.uow.edu.au/ontology/uowimpact#hideFromPublic";
var NOTIFY_TYPE_SUCCESS = "success";
var NOTIFY_TYPE_INFO = "info";
var NOTIFY_TYPE_ERROR = "danger";
var NOTIFY_TYPE_WARN = "warn";

var scholarsAutoComplete = {
  primitiveEditSuccess: {},
  onLoad: function() {
    this.mixIn();
    this.init();
    this.bindRemoveEvent();
    this.bindCreateEntryEvent();
    this.bindEditable();
    this.bindEditorControlButtons();
    this.bindTinymceRichEditor(['wysiTextArea_beneficiary', 'description', 'wysiTextArea_evidence']);
  },
  mixIn: function() {
    $.extend(this, autoCompleteExtends);
  },
  init: function(){
    // Polyfill startswith for IE compatibility
    if (!String.prototype.startsWith) {
      String.prototype.startsWith = function(searchString, position) {
        position = position || 0;
        return this.indexOf(searchString, position) === position;
      };
    }

    //bind selection change
    $('#typeSelector').change(function(){
      scholarsAutoComplete.acTypes['partner'] = $("#typeSelector option:selected").attr('value');
      //TODO: be aware of this field index can change if adding more auto-complete on the page
      $('ul.ui-autocomplete').eq(2).empty();
    });

    scholarsAutoComplete.initAutoComplete();
    scholarsAutoComplete.bindCheckboxSwitch();

    $('div.richTextArea').each(function(){
      $(this).html(scholarsAutoComplete.htmlUnescape($(this).text()));
    });
    $('div.editableTextField').each(function(){
      $(this).html(scholarsAutoComplete.htmlUnescape($(this).text()));
    });
  },
  initAutoComplete: function(){
    $(scholarsAutoComplete.inputField).each(function(){
      var self = $(this);
      $(this).autocomplete({
        source: function( request, response ) {
          $.ajax( {
            url: scholarsAutoComplete.acUrl,
            dataType: 'json',
            data: {
                term: request.term,
                type: scholarsAutoComplete.acTypes[$(self).attr('acGroupName')],
                multipleTypes: (scholarsAutoComplete.acMultipleTypes == undefined || scholarsAutoComplete.acMultipleTypes == null)? null: scholarsAutoComplete.acMultipleTypes
            },
            success: function( data ) {
              response( data );
            }
          });
        },
        minLength: 2,
        select: function( event, ui ) {
          //check if the display target has aleady includes the selected uri
          var displayTarget = $(self).attr('acDisplayTarget');
          for(var i = 0; i < $(displayTarget).find('li a[data-uri]').length; i++){
            if($(displayTarget).find('li a[data-uri]').eq(i).attr('data-uri') == ui.item.uri){
              $(self).val('');
              return false;
            }
          }
          scholarsAutoComplete.primitiveEditSuccess = {action:"postSelectAuto", self: $(self), uri: ui.item.uri, label: ui.item.label, type:NOTIFY_TYPE_SUCCESS, message: 'Saved'};
          var addN3 = scholarsAutoComplete.generateTripleN3(scholarsAutoComplete.objectUri,$(self).attr('acPredicateUri'),ui.item.uri);
          
          //add email parameters
          var notifyCollaborator = new Object();
          if($(self).attr('id') == 'collaborators'){
            notifyCollaborator.who = scholarsAutoComplete.personUri;
            notifyCollaborator.impactUri = scholarsAutoComplete.objectUri;
            notifyCollaborator.collaborator = ui.item.uri;
          }
          scholarsAutoComplete.addOrRetract(addN3,'', '', '', notifyCollaborator);
        }
      });
      scholarsAutoComplete.bindCreateFromTextEvent($(self));
    });
  },
  bindCheckboxSwitch: function(){
    if(scholarsAutoComplete.initHideFromPublic == "true"){
      $("#hideFromPublic").attr("checked", "checked");
    }
    jQuery_1_11("#hideFromPublic").bootstrapSwitch().on('switchChange.bootstrapSwitch', function(){
      var newValue = $('#hideFromPublic').attr('checked');
      var query = scholarsAutoComplete.generateTripleN3(scholarsAutoComplete.objectUri,HIDE_FROM_PUBLIC_PRED,"\"true\"^^<http://www.w3.org/2001/XMLSchema#boolean>");
      if(newValue){
        scholarsAutoComplete.primitiveEditSuccess = function(){
          scholarsAutoComplete.showMessage(NOTIFY_TYPE_SUCCESS, 'Switched to <b>Draft mode</b>');
        };
        scholarsAutoComplete.addOrRetract(query, '','','','');
      } else {
        scholarsAutoComplete.primitiveEditSuccess = function(){
          scholarsAutoComplete.showMessage(NOTIFY_TYPE_SUCCESS, 'Switched to <b>Public view mode</b>');
        };
        scholarsAutoComplete.addOrRetract('',query,'','','');
      }
      
    });
  },
  addOrRetract: function(addN3, removeN3, deletion, updatePredValue, notifyCollaborator){
    //Using primitive rdf edit which expects an n3 string for deletion
    if(_.isEmpty(notifyCollaborator)){
      notifyCollaborator = '';
    } else {
      notifyCollaborator = JSON.stringify(notifyCollaborator);
    }
    if(_.isEmpty(updatePredValue)){
      updatePredValue = '';
    } else {
      updatePredValue = JSON.stringify(updatePredValue);
    }
    if(!deletion){
      deletion = '';
    }
    $.ajax({
        url: scholarsAutoComplete.primitiveRdfEditUrl,
        type: 'POST', 
        data: {
          additions: addN3,
          retractions: removeN3,
          deletion: deletion,
          updatePredValue: updatePredValue,
          emailCollaborator: notifyCollaborator
        },
        dataType: 'json',
        complete: function(request, status) {
          if (status === 'success') {
            scholarsAutoComplete.postAddSuccessFunc(request);
          } else {
            //TODO: display error
            scholarsAutoComplete.showMessage(NOTIFY_TYPE_ERROR, 'Please copy the edited content, refresh the page and try again.<p>If the problem persists, please contact <a href="/contact" target="_blank">UOW Scholars Support</p>');
          }
          scholarsAutoComplete.primitiveEditSuccess = {};
        }
    });
  },
  appendSelectToList: function(request){
    var self = scholarsAutoComplete.primitiveEditSuccess.self;
    var uri = scholarsAutoComplete.primitiveEditSuccess.uri;
    var label = scholarsAutoComplete.primitiveEditSuccess.label;
    if(!uri){
      var tmpJson = $.parseJSON(request.responseText);
      uri = tmpJson[scholarsAutoComplete.generateNewResourceName($(self).attr('id'))];
    }
    if(uri){
      var displayTarget = $(self).attr('acDisplayTarget');
      var removeLink = $('<a />').addClass('glyphicon glyphicon-trash removeTriple')
        .attr('data-uri',uri)
        .attr('data-subjectUri',scholarsAutoComplete.objectUri)
        .attr('data-predicateUri', $(self).attr('acPredicateUri'))
        .attr('title', 'Delete');

      var spanText = '';
      if($(self).attr('id')== "collaborators"){
        spanText = $('<span />').append("&nbsp;").append($('<a/>').attr('href','/display'+uri.replace(PREFIX_INDIVIDUAL,'')).attr('target','_blank').text(label));
      } else {
        spanText = $('<span />').append("&nbsp;").append(label);
      }
      $( "<li />" ).addClass('targetToRemoveAfterDelete').prepend(removeLink.after(spanText)).prependTo( $(displayTarget) );
      $(self).val('');
      scholarsAutoComplete.bindRemoveEvent();
      scholarsAutoComplete.showMsgFromJson();
    }
  },
  bindRemoveEvent: function(){
    $(scholarsAutoComplete.removeField).unbind().click(function(){
      scholarsAutoComplete.removeEventClickFunction(this);
    });
    $(scholarsAutoComplete.removeRow).unbind().click(function(){
      scholarsAutoComplete.removeEventClickFunction(this,$(this).attr('data-uri'));
    });
  },
  removeEventClickFunction: function(self,deletion){
    scholarsAutoComplete.primitiveEditSuccess = function(request){
      $(self).closest('.targetToRemoveAfterDelete').remove();
      scholarsAutoComplete.showMessage(NOTIFY_TYPE_SUCCESS, 'Removed');};
    var removeN3 = scholarsAutoComplete.generateTripleN3($(self).attr('data-subjectUri'), $(self).attr('data-predicateUri'),$(self).attr('data-uri'));
    scholarsAutoComplete.addOrRetract('', removeN3, deletion);
  },
  bindEditable: function(){
    scholarsAutoComplete.bindTinymceInlineRich();
    scholarsAutoComplete.bindTinymceInline();
  },
  bindTinymceInlineRich: function(){
    $('a.editRichTextarea').unbind().click(function(){
      if($(this).siblings('div.richTextArea').length > 0){
        var self = $(this).siblings('div.richTextArea')[0];
        scholarsAutoComplete.initMCERichInline(self);
      }

      $(this).siblings("span.tiny-editor-controls").removeClass("hidden").show();
    });
  },
  bindTinymceInline: function(){
    $('a.editTextField').unbind().click(function(){
      if($(this).siblings('div.editableTextField').length > 0){
        var self = $(this).siblings('div.editableTextField')[0];
        scholarsAutoComplete.initMCETextInline(self);
      }

      $(this).siblings("span.tiny-editor-controls").removeClass("hidden").show();
    });

  },

  bindEditorControlButtons: function() {
      jQuery_1_11(document).on('click', "a.save-btn", function(){
          var parentDiv = $(this).parent().parent();
          var saveIcon = parentDiv.find(".mce-ico.mce-i-fa.fa-floppy-o");
          var saveButton = saveIcon.parent();
          saveButton.trigger("click");
      });

      jQuery_1_11(document).on('click', "a.cancel-btn", function(){
          var parentDiv = $(this).parent().parent();
          var cancelIcon = parentDiv.find(".mce-ico.mce-i-fa.fa-ban");
          var cancelButton = cancelIcon.parent();
          cancelButton.trigger("click");
      });
  },

  initMCETextInline: function(self){
    tinyMCE.init({
      target: self,
      mode: "exact",
      menubar: false,
      toolbar: 'save cancel',
      branding: false,
      resize: false,
      content_style: "body{padding-bottom:0px;}",
      statusbar: false,
      valid_elements :'c', //a artificial element that will enable paste as text
      fix_list_elements : true,
      fix_nesting : true,
      cleanup_on_startup : true,
      gecko_spellcheck : true,
      forced_root_block: false,
      plugins : "paste",
      paste_use_dialog : false,
      paste_auto_cleanup_on_paste : true,
      paste_strip_class_attributes : "all",
      paste_remove_spans : true,
      paste_remove_styles : true,
      paste_retain_style_properties : "",
      entity_encoding: 'raw',
      setup: function(editor) {
        editor.on('init', function () {
            editor.init_content = editor.getContent();
        });
        editor.on('PostProcess', function(e) {
          e.content = scholarsAutoComplete.htmlEscape(e.content.replace(/(?:\r\n|\r|\n)/g, '').replace(/&nbsp;/g, ' '));
        });
        editor.on('keydown', function(e) {
          var keyCode = e.keyCode || e.which;
          if (keyCode === 13) {
            e.preventDefault();
            e.stopPropagation();
          }
        });
        editor.addButton('save', {
          text: '',
          icon: 'fa fa-floppy-o',
          title: 'Save',
          onclick: function () {
            scholarsAutoComplete.inlineSaveButtonClick(self, editor);
          }
        });
        editor.addButton('cancel', {
          text: '',
          icon: 'fa fa-ban',
          title: 'Cancel',
          onclick: function(){
            tinymce.remove('#'+editor.id);
            $(self).html(scholarsAutoComplete.htmlUnescape(editor.init_content));
            scholarsAutoComplete.bindEditable();

            $(self).siblings("span.tiny-editor-controls").hide();
          }
        });
      }
    });
  },
  initMCERichInline: function(self){
    tinyMCE.init({
      target: self,
      mode: "exact",
      plugins: "link wordcount lists paste",
      menubar: false,
      toolbar: 'undo redo | bold italic underline | bullist numlist | link unlink | save cancel',
      branding: false,
      elementpath: false,
      valid_elements : "a[href|title|target=_blank],br,p,i,em,cite,strong/b,u,sub,sup,ul,ol,li,b",
      fix_list_elements : true,
      fix_nesting : true,
      cleanup_on_startup : true,
      gecko_spellcheck : true,
      forced_root_block: false,
      paste_use_dialog : false,
      paste_auto_cleanup_on_paste : true,
      paste_convert_headers_to_strong : true,
      paste_strip_class_attributes : "all",
      paste_remove_spans : true,
      paste_remove_styles : true,
      paste_retain_style_properties : "",
      entity_encoding: 'raw',
      setup: function(editor) {
        editor.on('init', function () {
            editor.init_content = editor.getContent();
        });
        editor.on('PostProcess', function(e) {
          e.content = scholarsAutoComplete.htmlEscape(e.content.replace(/(?:\r\n|\r|\n)/g, '').replace(/&nbsp;/g, ' '));
        });
        editor.addButton('save', {
          text: '',
          icon: 'fa fa-floppy-o',
          title: 'Save',
          onclick: function () {
            scholarsAutoComplete.inlineSaveButtonClick(self, editor);
          }
        });
        editor.addButton('cancel', {
          text: '',
          icon: 'fa fa-ban',
            title: 'Cancel',
          onclick: function(){
            tinymce.remove('#'+editor.id);
            $(self).html(scholarsAutoComplete.htmlUnescape(editor.init_content));
            scholarsAutoComplete.bindEditable();
            $(self).siblings("span.tiny-editor-controls").hide();
          }
        });
      }
    });
  },
  bindTinymceRichEditor: function(ids){
    function initMCERich(e) {
      tinyMCE.init({
        mode: "exact",
        elements: e,
        plugins: "link wordcount lists paste",
        menubar: false,
        toolbar: 'undo redo | bold italic underline | bullist numlist | link unlink',
        branding: false,
        elementpath: false,
        valid_elements : "a[href|title|target=_blank],br,p,i,em,cite,strong/b,u,sub,sup,ul,ol,li,b",
        fix_list_elements : true,
        fix_nesting : true,
        cleanup_on_startup : true,
        gecko_spellcheck : true,
        forced_root_block: false,
        paste_use_dialog : false,
        paste_auto_cleanup_on_paste : true,
        paste_convert_headers_to_strong : true,
        paste_strip_class_attributes : "all",
        paste_remove_spans : true,
        paste_remove_styles : true,
        paste_retain_style_properties : "",
        entity_encoding: 'raw',
        setup: function(editor) {
          editor.on('PostProcess', function(e) {
            e.content = scholarsAutoComplete.htmlEscape(e.content.replace(/(?:\r\n|\r|\n)/g, '').replace(/&nbsp;/g, ' '));
          });
        }
      });
    }

    for(var i = 0; i< ids.length; i++) {
        if ($('#' + ids[i]).length > 0) {
          initMCERich(ids[i]);
        }
    }
  },
  //create new resource from the input of a text field
  bindCreateFromTextEvent: function(self){
    $( "button[data-input-id='"+$(self).attr('id')+"']" ).click(function(){
      var fieldNameForAlert;
      if($(self).attr('id') == 'partners'){
        if($("#typeSelector option:selected").attr('value') === 'http://xmlns.com/foaf/0.1/Organization'){
          scholarsAutoComplete.showMessage(NOTIFY_TYPE_INFO, 'Please select an organisation type to create the new external partner');
          return false;
        }
        fieldNameForAlert = 'External Partners';
      } else if($(self).attr('id') == 'programs'){
        fieldNameForAlert = 'UOW Centres / Programs';
      }

      if($('li.ui-menu-item').length > 0){
        for(var i = 0; i < $('li.ui-menu-item a').length; i++){
          if($.trim($('li.ui-menu-item a').eq(i).text().toLowerCase()) == $.trim($(self).val().toLowerCase())){
            scholarsAutoComplete.showMessage(NOTIFY_TYPE_INFO, 'Please select the '+fieldNameForAlert+' from the drop down');
            return false;
          }
        }
      }

      if(scholarsAutoComplete.isStringEmpty($(self).val())){
        $(self).val('');
        return false;
      }
      var addN3 = scholarsAutoComplete.generateNewResourceTripleN3(self);
      scholarsAutoComplete.primitiveEditSuccess = {action:"postSelectAuto", self: $(self), uri: '', label: $(self).val(), type:NOTIFY_TYPE_SUCCESS, message:'Created <b>'+fieldNameForAlert+'</b>'};
      scholarsAutoComplete.addOrRetract(addN3, '');
    });
  },
  bindCreateEntryEvent: function(){
    jQuery_1_11(document).on('click','.tableColumnExtendable .btn-add', function(e){
      e.preventDefault();
      var self = $(this);
      if($(this).hasClass('createEvidence')){
        scholarsAutoComplete.createEvidence(self);
      } else if($(this).hasClass('createBeneficiary')){
        scholarsAutoComplete.createBeneficiary(self);
      }
    });
  },
  inlineSaveButtonClick: function(self, editor){
    var uri = $(self).closest('[data-uri]').attr('data-uri');
    var pred = $(self).closest('[data-predUri]').attr('data-predUri');
    var dataType = $(self).attr('data-rdf-type');

    if(!editor.getContent()){
      scholarsAutoComplete.showMessage(NOTIFY_TYPE_INFO, 'Please add content');
      return false;
    }

    if(dataType && dataType.indexOf('int') > 0 && !jQuery_1_11.isNumeric(editor.getContent())){
      scholarsAutoComplete.showMessage(NOTIFY_TYPE_INFO, 'Quantification of Impact should be numeric');
      return false;
    }

    if(tinymce.get(editor.id).plugins.wordcount){
      var wordcount = tinymce.get(editor.id).plugins.wordcount.getCount();
      var maxWordCount = 500;
      if(pred.indexOf('detailOfImpact') !== -1) {
        maxWordCount = 1000;
      }
    }

    if(wordcount > maxWordCount){
      scholarsAutoComplete.showMessage(NOTIFY_TYPE_INFO, 'Maximum of ' + maxWordCount + ' words allowed.');
      return false;
    }

    scholarsAutoComplete.primitiveEditSuccess = function(request){
      var value = editor.getContent();
      tinymce.remove('#'+editor.id);
      $(self).html(scholarsAutoComplete.htmlUnescape(value));
      scholarsAutoComplete.bindEditable();
      $(self).siblings("span.tiny-editor-controls").hide();
      scholarsAutoComplete.showMessage(NOTIFY_TYPE_SUCCESS, 'Saved');
    };
    var obj = new Object();
    obj.subject = uri;
    obj.predicate = pred;
    obj.object = editor.getContent();
    scholarsAutoComplete.addOrRetract('','','',obj);
  },
  createBeneficiary: function(self){
    var currentEntry = $(self).parents('.entry:first'),
        controlForm = $(self).parents('.tableColumnExtendable.controls:first');
    var beneficiary = $(currentEntry).find("td[data-predUri='"+scholarsAutoComplete.beneficaryPred+"'] input").val();
    var quantity = $(currentEntry).find("td[data-predUri='"+scholarsAutoComplete.quantityPred+"'] input").val();
    var description = tinyMCE.get('wysiTextArea_beneficiary').getContent();

    var wordcount = tinymce.get('wysiTextArea_beneficiary').plugins.wordcount.getCount();
    if(wordcount > 500){
      scholarsAutoComplete.showMessage(NOTIFY_TYPE_INFO, 'Maximum of 500 words permitted.');
      return false;
    }
    if(scholarsAutoComplete.isStringEmpty(beneficiary) || !quantity || !description){
      scholarsAutoComplete.showMessage(NOTIFY_TYPE_INFO, 'Please provide details of the beneficiary');
      return false;
    }
    if(!jQuery_1_11.isNumeric(quantity)){
      scholarsAutoComplete.showMessage(NOTIFY_TYPE_INFO, 'Quantification of Impact Field should be numeric');
      return false;
    }
    scholarsAutoComplete.primitiveEditSuccess = {action:"postCreateBeneficiary",self:self, type:NOTIFY_TYPE_SUCCESS, message:'Saved'};
    var addN3 = scholarsAutoComplete.generateBeneficiaryCreationN3($(controlForm).attr('id'), $.trim(beneficiary),$.trim(quantity),description);
    scholarsAutoComplete.addOrRetract(addN3, '');
  },
  createEvidence: function(self){
    var currentEntry = $(self).parents('.entry:first'),
        controlForm = $(self).parents('.tableColumnExtendable.controls:first');
    var name = $(currentEntry).find("td[data-predUri='"+scholarsAutoComplete.evidenceLinkNamePred+"'] input").val();
    var link = $(currentEntry).find("td[data-predUri='"+scholarsAutoComplete.evidenceLinkPred+"'] input").val();
    var description = tinyMCE.get('wysiTextArea_evidence').getContent();

    var wordcount = tinymce.get('wysiTextArea_evidence').plugins.wordcount.getCount();
    if(wordcount > 500){
        scholarsAutoComplete.showMessage(NOTIFY_TYPE_INFO, 'Maximum of 500 words permitted.');
      return false;
    }
    if(scholarsAutoComplete.isStringEmpty(name) || scholarsAutoComplete.isStringEmpty(link) || !description){
      scholarsAutoComplete.showMessage(NOTIFY_TYPE_INFO, 'Please provide details of the evidence');
      return false;
    }
    scholarsAutoComplete.primitiveEditSuccess = {action:"postCreateEvidence",self:self, type:NOTIFY_TYPE_SUCCESS, message:'Saved'};
    var addN3 = scholarsAutoComplete.generateEvidenceCreationN3($(controlForm).attr('id'),$.trim(name),$.trim(link),description);
    scholarsAutoComplete.addOrRetract(addN3, '');
  },
  generateBeneficiaryCreationN3: function(id,beneficiary,quantity,description){
    var beneficiaryResourceName = scholarsAutoComplete.generateNewResourceName(id);
    var addN3 = scholarsAutoComplete.generateTripleN3(scholarsAutoComplete.objectUri,scholarsAutoComplete.hasBeneficiaryPred,beneficiaryResourceName);
    addN3 += scholarsAutoComplete.generateTripleN3(beneficiaryResourceName,RDF_TYPE_PRED,scholarsAutoComplete.beneficiaryTypePred);
    addN3 += scholarsAutoComplete.generateTripleN3(beneficiaryResourceName,scholarsAutoComplete.beneficaryPred,"\""+scholarsAutoComplete.htmlEscape(beneficiary)+"\"^^<"+RSD_TYPE_STRING+">");
    addN3 += scholarsAutoComplete.generateTripleN3(beneficiaryResourceName,scholarsAutoComplete.quantityPred,"\""+quantity+"\"^^<http://www.w3.org/2001/XMLSchema#int>");
    addN3 += scholarsAutoComplete.generateTripleN3(beneficiaryResourceName,scholarsAutoComplete.descriptionPred,"\""+description+"\"^^<"+RSD_TYPE_STRING+">");
    addN3 += scholarsAutoComplete.generateTripleN3(beneficiaryResourceName,scholarsAutoComplete.displayOrderPred,"\""+scholarsAutoComplete.getMaximumDisplayOrder('.beneficiaryDisplayOrder')+"\"^^<http://www.w3.org/2001/XMLSchema#int>");
    return addN3;
  },
  getMaximumDisplayOrder: function(element){
    var maximum = 0;
    $(element).find('[data-original]').each(function(){
      var value = parseInt($(this).attr('data-original'));
      maximum = (value > maximum) ? value : maximum;
    });
    maximum = maximum + 1;
    return maximum;
  },
  generateEvidenceCreationN3: function(id, name, link, description){
    var evidenceResourceName = scholarsAutoComplete.generateNewResourceName(id);
    var addN3 = scholarsAutoComplete.generateTripleN3(scholarsAutoComplete.objectUri,scholarsAutoComplete.hasEvidencePred,evidenceResourceName);
    addN3 += scholarsAutoComplete.generateTripleN3(evidenceResourceName,RDF_TYPE_PRED,scholarsAutoComplete.evidenceTypePred);
    addN3 += scholarsAutoComplete.generateTripleN3(evidenceResourceName,scholarsAutoComplete.evidenceLinkNamePred,"\""+scholarsAutoComplete.htmlEscape(name)+"\"^^<"+RSD_TYPE_STRING+">")
    addN3 += scholarsAutoComplete.generateTripleN3(evidenceResourceName,scholarsAutoComplete.evidenceLinkPred,"\""+scholarsAutoComplete.htmlEscape(link)+"\"^^<"+RSD_TYPE_STRING+">")
    addN3 += scholarsAutoComplete.generateTripleN3(evidenceResourceName,scholarsAutoComplete.descriptionPred,"\""+description+"\"^^<"+RSD_TYPE_STRING+">");
    return addN3;
  },
  generateTripleN3: function(subjectUri, predicateUri, objectNode) {
    var n3String = '';
    if(subjectUri.startsWith(PREFIX_INDIVIDUAL)){
      n3String = "<" + subjectUri + ">";
    } else {
      n3String = subjectUri;
    }
    n3String += " <" + predicateUri + "> ";
    if(objectNode.startsWith("http://")){
      n3String += "<" + objectNode + "> . ";
    } else {
      n3String += objectNode + " . ";
    }
    return n3String;
  },
  generateNewResourceTripleN3: function(self){
    var newResourceName = scholarsAutoComplete.generateNewResourceName($(self).attr('id'));
    var predicateUri = $(self).attr('acPredicateUri');
    var objectUri = scholarsAutoComplete.objectUri;
    var newResourceType = scholarsAutoComplete.acTypes[$(self).attr('acGroupName')];
    var newResourceValueToPred = $(self).attr('valueToPredicate');
    var n3 = scholarsAutoComplete.generateTripleN3(objectUri, predicateUri, newResourceName);
    n3 += scholarsAutoComplete.generateTripleN3(newResourceName, RDF_TYPE_PRED, newResourceType);
    n3 += scholarsAutoComplete.generateTripleN3(newResourceName, newResourceValueToPred, "\""+$(self).val().replace(/"/g, '\\\"')+"\"^^<"+RSD_TYPE_STRING+">");
    return n3;
  },
  generateNewResourceName: function(id){
    return NEW_RESOURCE_PREFIX_CONST + id;
  },
  postAddSuccessFunc: function(request){
    if(typeof(scholarsAutoComplete.primitiveEditSuccess) === 'function'){
      scholarsAutoComplete.primitiveEditSuccess(request);
    } else {
      switch(scholarsAutoComplete.primitiveEditSuccess.action){
        case 'postSelectAuto':
          scholarsAutoComplete.appendSelectToList(request);
          break;
        case 'postCreateBeneficiary':
          scholarsAutoComplete.postCreateBeneficiary(request,scholarsAutoComplete.primitiveEditSuccess.self);
          break;
        case 'postCreateEvidence':
          scholarsAutoComplete.postCreateEvidence(request,scholarsAutoComplete.primitiveEditSuccess.self);
          break;
        default:
          return false;
      }
    }
  },
  postCreateBeneficiary: function(request, self){
    var newResourceUri,newResourceLabel,newQuantification,newDescription,
        controlForm = $(self).parents('.tableColumnExtendable.controls:first');//first tbody parent
        currentEntry = $(self).parents('.entry:first'),//first tr parent
        newEntry = currentEntry.clone();
    newEntry.find('input').val('');
    newEntry.find("td[data-predUri='"+scholarsAutoComplete.descriptionPred+"']").empty()
    .append($('<div/>').addClass("form-control input-md").attr("id","wysiTextArea_beneficiary").attr("rows","6").css('width','100%'));

    //get new beneficiary label for message displaying
    newResourceLabel = $(currentEntry).find("td[data-predUri='"+scholarsAutoComplete.beneficaryPred+"'] input").val();
    newQuantification = $(currentEntry).find("td[data-predUri='"+scholarsAutoComplete.quantityPred+"'] input").val();
    newDescription = tinyMCE.get('wysiTextArea_beneficiary').getContent();

    var editTextFieldButton = $('<a/>').attr('title', 'Edit')
        .addClass('editTextField btn btn-primary outline btn-sm')
        .append($('<i/>')
            .addClass('fa fa-pencil-square-o fa-fw'));

    var editTextAreaButton = $('<a/>').attr('title', 'Edit')
        .addClass('editRichTextarea btn btn-primary outline btn-sm')
        .append($('<i/>')
            .addClass('fa fa-pencil-square-o fa-fw'));

    var tinySaveButton = $('<a/>').attr('title', 'Save')
        .addClass('btn btn-success outline save-btn btn-sm')
        .append($('<i/>')
            .addClass('fa fa-floppy-o fa-fw'));

    var tinyCancelButton = $('<a/>').attr('title', 'Cancel')
        .addClass('btn btn-warning outline cancel-btn btn-sm')
        .append($('<i/>')
            .addClass('fa fa-ban fa-fw'));

    var tinyEditControls = $('<span/>').attr('class', 'hidden tiny-editor-controls')
        .append(tinySaveButton)
        .append(tinyCancelButton);

    var beneficiaryField = $('<div/>').addClass('editableTextField')
        .html(scholarsAutoComplete.htmlUnescape(newResourceLabel));

    var quantificationField = $('<div/>').addClass('editableTextField')
        .attr('data-rdf-type','http://www.w3.org/2001/XMLSchema#int')
        .html(scholarsAutoComplete.htmlUnescape(newQuantification));

    var descriptionField = $('<div/>').addClass('richTextArea')
        .html(scholarsAutoComplete.htmlUnescape(newDescription));

    //generate links to add function with in place editable
    var beneficiaryContainer = $('<div/>');
    $(currentEntry)
        .find("td[data-predUri='"+scholarsAutoComplete.beneficaryPred+"']")
        .append(beneficiaryContainer);
    beneficiaryContainer.append(beneficiaryField)
        .append(editTextFieldButton)
        .append(tinyEditControls);
    beneficiaryContainer.siblings('input').remove();

    var quantificationContainer = $('<div/>');
    $(currentEntry)
        .find("td[data-predUri='"+scholarsAutoComplete.quantityPred+"']")
        .append(quantificationContainer);
    quantificationContainer.append(quantificationField)
        .append(editTextFieldButton.clone())
        .append(tinyEditControls.clone());
    quantificationContainer.siblings('input').remove();

    var descriptionContainer = $('<div/>');
    $(currentEntry)
        .find("td[data-predUri='"+scholarsAutoComplete.descriptionPred+"']")
        .empty()
        .append(descriptionContainer);
      descriptionContainer.append(descriptionField)
          .append(editTextAreaButton)
          .append(tinyEditControls.clone());

      $(currentEntry).find("td[data-predUri='"+scholarsAutoComplete.displayOrderPred+"']")
        .append($('<span/>').css('display','none').attr('data-original',scholarsAutoComplete.getMaximumDisplayOrder('.beneficiaryDisplayOrder')).attr('data-rdf-type','http://www.w3.org/2001/XMLSchema#int'));

    if(request){
      var tmpJson = $.parseJSON(request.responseText);
      newResourceUri = tmpJson[scholarsAutoComplete.generateNewResourceName($(controlForm).attr('id'))];
    }
    newEntry.appendTo(controlForm);
    controlForm.find('.entry:not(:last) .btn-add')
      .removeClass('btn-add').addClass('btn-remove')
      .removeClass('btn-success').addClass('btn-danger').addClass('removeTripleAndIndividual')
      .attr('data-uri', newResourceUri)
      .attr('title', 'Delete Beneficiary Entry')
      .html('<i class="fa fa-trash fa-fw" aria-hidden="true"></i> Delete');
    $(currentEntry).closest('[data-uri]').attr('data-uri',newResourceUri);
    
    scholarsAutoComplete.bindTinymceRichEditor(['wysiTextArea_beneficiary']);

    scholarsAutoComplete.bindRemoveEvent();
    scholarsAutoComplete.bindEditable();
    scholarsAutoComplete.showMsgFromJson();
  },

  postCreateEvidence: function(request, self){
    var newResourceUri,newResourceLabel,newDescription,newLinkName,
        controlForm = $(self).parents('.tableColumnExtendable.controls:first');//first tbody parent
        currentEntry = $(self).parents('.entry:first'),//first tr parent
        newEntry = currentEntry.clone();
    newEntry.find('input').val('');
    newEntry.find("td[data-predUri='"+scholarsAutoComplete.descriptionPred+"']").empty()
    .append($('<div/>').addClass("form-control input-md").attr("id","wysiTextArea_evidence").attr("rows","6").css('width','100%'));

    //get original value and put to editable link
    newLinkName = $(currentEntry).find("td[data-predUri='"+scholarsAutoComplete.evidenceLinkNamePred+"'] input").val();
    newResourceLabel = $(currentEntry).find("td[data-predUri='"+scholarsAutoComplete.evidenceLinkPred+"'] input").val();
    newDescription = tinyMCE.get('wysiTextArea_evidence').getContent();

      var editTextFieldButton = $('<a/>').attr('title', 'Edit')
          .addClass('editTextField btn btn-primary outline btn-sm')
          .append($('<i/>')
              .addClass('fa fa-pencil-square-o fa-fw'));

      var editTextAreaButton = $('<a/>').attr('title', 'Edit')
          .addClass('editRichTextarea btn btn-primary outline btn-sm')
          .append($('<i/>')
              .addClass('fa fa-pencil-square-o fa-fw'));

      var tinySaveButton = $('<a/>').attr('title', 'Save')
          .addClass('btn btn-success outline save-btn btn-sm')
          .append($('<i/>')
              .addClass('fa fa-floppy-o fa-fw'));

      var tinyCancelButton = $('<a/>').attr('title', 'Cancel')
          .addClass('btn btn-warning outline cancel-btn btn-sm')
          .append($('<i/>')
              .addClass('fa fa-ban fa-fw'));

      var tinyEditControls = $('<span/>').attr('class', 'hidden tiny-editor-controls')
          .append(tinySaveButton)
          .append(tinyCancelButton);

      var displayNameField = $('<div/>').addClass('editableTextField')
          .html(scholarsAutoComplete.htmlUnescape(newLinkName));

      var linkField = $('<div/>').addClass('editableTextField')
          .html(scholarsAutoComplete.htmlUnescape(newResourceLabel));

      var descriptionField = $('<div/>').addClass('richTextArea')
          .html(scholarsAutoComplete.htmlUnescape(newDescription));
    
    //generate links to add function with in place editable
    var displayNameContainer = $('<div/>');
    $(currentEntry)
        .find("td[data-predUri='"+scholarsAutoComplete.evidenceLinkNamePred+"']")
        .append(displayNameContainer);
    displayNameContainer.append(displayNameField)
        .append(editTextFieldButton)
        .append(tinyEditControls);
    displayNameContainer.siblings('input').remove();

    var linkContainer = $('<div/>');
    $(currentEntry)
        .find("td[data-predUri='"+scholarsAutoComplete.evidenceLinkPred+"']")
        .append(linkContainer);
    linkContainer.append(linkField)
        .append(editTextFieldButton.clone())
        .append(tinyEditControls.clone());
    linkContainer.siblings('input').remove();

    var descriptionContainer = $('<div/>');
    $(currentEntry)
        .find("td[data-predUri='"+scholarsAutoComplete.descriptionPred+"']")
        .empty()
        .append(descriptionContainer);
    descriptionContainer.append(descriptionField)
        .append(editTextAreaButton)
        .append(tinyEditControls.clone());

    if(request){
      var tmpJson = $.parseJSON(request.responseText);
      newResourceUri = tmpJson[scholarsAutoComplete.generateNewResourceName($(controlForm).attr('id'))];
    }
    newEntry.appendTo(controlForm);
    controlForm.find('.entry:not(:last) .btn-add')
      .removeClass('btn-add').addClass('btn-remove')
      .removeClass('btn-success').addClass('btn-danger').addClass('removeTripleAndIndividual')
      .attr('data-uri', newResourceUri)
      .attr('title', 'delete this evidence entry')
      .html('<i class="fa fa-trash fa-fw" aria-hidden="true"></i> Delete');
    $(currentEntry).closest('[data-uri]').attr('data-uri',newResourceUri);
    
    scholarsAutoComplete.bindTinymceRichEditor(['wysiTextArea_evidence']);

    scholarsAutoComplete.bindRemoveEvent();
    scholarsAutoComplete.bindEditable();
    scholarsAutoComplete.showMsgFromJson();
  },
  htmlEscape: function(str) {
    return str
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#39;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/\//g, '&#x2F;')
      .replace(/\\/g, '&#92;');
  },
  htmlUnescape: function(str){
    return str
      .replace(/&quot;/g, '"')
      .replace(/&#39;/g, "'")
      .replace(/&lt;/g, '<')
      .replace(/&gt;/g, '>')
      .replace(/&#x2F;/g, '/')
      .replace(/&#92;/g, '\\');
  },
  isStringEmpty: function(string){
    return /^\s*$/.test(string);
  },
  showMsgFromJson: function(){
    if(typeof scholarsAutoComplete.primitiveEditSuccess !== 'function' && !_.isEmpty(scholarsAutoComplete.primitiveEditSuccess)){
      var type = scholarsAutoComplete.primitiveEditSuccess.type;
      var msg = scholarsAutoComplete.primitiveEditSuccess.message;
      scholarsAutoComplete.showMessage(type, msg);
    }
  },
  showMessage: function(type, msg){
    var icon,title;
      if(!type){
        type = NOTIFY_TYPE_INFO;
      } 
      if(!msg){
        msg = 'Saved';
      }
      switch(type){
        case NOTIFY_TYPE_INFO:
          icon = 'fa fa-info';
          delay = 5000;
          break;
        case NOTIFY_TYPE_WARN:
          icon = 'fa fa-exclamation-triangle';
          delay = 5000;
          break;
        case NOTIFY_TYPE_SUCCESS:
          icon = 'fa fa-check';
          delay = 3000;
          break;
        case NOTIFY_TYPE_ERROR:
          icon = 'fa fa-times';
          delay = 10000;
          break;
        default:
          break;
      }
      scholarsAutoComplete.initNotify(type, icon, msg, delay);
  },
  initNotify:function(type, icon, msg, delay){

    jQuery_1_11.notify({
        icon: icon,
        title: '',
        message: msg
      },{
        type: type,
        allow_dismiss: true,
        newest_on_top: true,
        showProgressbar: false,
        delay: delay,
        offset: {
          x: 20,
          y: 150
        },
        placement: {
          from: "top",
          align: "center"
        }
      });
  },

};

$(document).ready(function() {
    scholarsAutoComplete.onLoad();
    $('#personHasImpactEngagement').submit(function(event){
        var wordcount = tinymce.get('description').plugins.wordcount.getCount();
        if(wordcount > 500){
          scholarsAutoComplete.showMessage(NOTIFY_TYPE_INFO, 'Impact summary should not exceed 500 words.');
          event.preventDefault();
        } else {
          return true;
        }
      });
}); 