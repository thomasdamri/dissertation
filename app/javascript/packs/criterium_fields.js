// Given a single checkbox, disables the nearest assessed checkbox if not single
function disableAssessedBox(formElement){
    let targetElement = $(formElement).closest('div.nested-fields').find('.assessed');
    if(formElement.value === "0"){
        targetElement.prop('disabled', true);
    }else{
        targetElement.prop('disabled', false);
    }
}

// Given an assessed checkbox, disables the nearest weighting input box if not assessed
function disableWeightBox(formElement){
    let targetElement = $(formElement).closest('div.nested-fields').find('.relative-weight')
    console.log(formElement.value);
    if(formElement.value === "0"){
        targetElement.val('')
        targetElement.prop('disabled', true);
    }else{
        targetElement.prop('disabled', false);
    }
}

// Dynamically enabled and disables the min/max values for the criteria fields
$(document).on('turbo:load', function(){

    // Check all single + assessed checkboxes on page load (for editing)
    $('.single').each(function(){
        disableAssessedBox(this);
    });

    $('.assessed').each(function(){
        disableWeightBox(this);
    });

});
