customForm.undoAutocompleteSelection = function(selectedObj) {
    // The test is not just for efficiency: undoAutocompleteSelection empties the acSelector value,
    // which we don't want to do if user has manually entered a value, since he may intend to
    // change the type but keep the value. If no new value has been selected, form initialization
    // below will correctly empty the value anyway.

    var $acSelectionObj = null;
    var $acSelector = null;

    // Check to see if the parameter is the typeSelector. If it is, we need to get the acSelection div
    // that is associated with it.  Also, when the type is changed, we need to determine whether the user
    // has selected an existing individual in the corresponding name field or typed the label for a new
    // individual. If the latter, we do not want to clear the value on type change. The clearAcSelectorVal
    // boolean controls whether the acSelector value gets cleared.

    //Customised: we don't want to clear the value for autocomplete text field
    var clearAcSelectorVal = false;
    
    if ( $(selectedObj).attr('id') == "typeSelector" ) {
        $acSelectionObj = customForm.acSelections[$(selectedObj).attr('acGroupName')];
        if ( $acSelectionObj.is(':hidden') ) {
            clearAcSelectorVal = false;
        }
        // if the type is being changed after a cancel, any additional a/c fields that may have been set
        // by the user should be "undone". Only loop through these if this is not the initial type selection
        if ( customForm.clearAcSelections ) {
            $.each(customForm.acSelections, function(i, acS) {
                var $checkSelection = customForm.acSelections[i];
                if ( $checkSelection.is(':hidden') && $checkSelection.attr('acGroupName') != $acSelectionObj.attr('acGroupName') ) {
                    customForm.resetAcSelection($checkSelection);
                    $acSelector = customForm.getAcSelector($checkSelection);
                    $acSelector.parent('p').show();
                }
            });
        }
    }
    else {
        $acSelectionObj = $(selectedObj);
        //remove the code that actually remove the value of the autocomplete text field
        //customForm.typeSelector.val('');
    }

    $acSelector = this.getAcSelector($acSelectionObj);
    $acSelector.parent('p').show();
    this.resetAcSelection($acSelectionObj);
    if ( clearAcSelectorVal == true ) {
        $acSelector.val('');
        $("input.display[acGroupName='" + $acSelectionObj.attr('acGroupName') + "']").val("");
    }
    customForm.addAcHelpText($acSelector);

    //Resetting so disable submit button again for object property autocomplete
    if ( this.acSelectOnly ) {
    	this.disableSubmit();
    }
    this.clearAcSelections = false;
}

if(typeof('awardReceiptUtils.hideConferredBy') === 'function'){
    awardReceiptUtils.hideConferredBy=function(){
        if ( this.awardAcSelection.attr('class').indexOf('userSelected') != -1 ) {
            this.org.parent('p').hide();
            //remove the code that empty the value of "conferred by" of award
            //this.org.val('');
            this.resetAcSelection();       
        }
    }
}
if(typeof('awardReceiptUtils.showConferredBy') === 'function'){
    awardReceiptUtils.showConferredBy=function(){
        //remove the code that empty the value of "conferred by" of award
        //this.org.val(awardReceiptUtils.selectAnOrganization);
        //this.org.addClass('acSelectorWithHelpText');
        this.org.parent('p').show();
        if ( this.editMode == "edit" ) {
            this.hiddenOrgDiv.hide();
        }
        this.resetAcSelection();
    }
}