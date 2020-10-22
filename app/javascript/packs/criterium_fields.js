function disableInputs(formElement){
    if(formElement.value === "0"){
        $(formElement).closest('div.nested-fields').find('.min-value').prop("disabled", true);
        $(formElement).closest('div.nested-fields').find('.max-value').prop("disabled", true);
    }else{
        $(formElement).closest('div.nested-fields').find('.min-value').prop("disabled", false);
        $(formElement).closest('div.nested-fields').find('.max-value').prop("disabled", false);
    }
}
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
$(document).on('turbolinks:load', function(){

    // Check all min/max boxes when page loads (for editing)
    $('.response-type').each(function() {
        disableInputs(this);
    });

    // Check all single + assessed checkboxes on page load (for editing)
    $('.single').each(function(){
        disableAssessedBox(this);
    })

    $('.assessed').each(function(){
        disableWeightBox(this);
    })

    $('form').on('click', '.add_fields', function(event){
        disableInputs(this);
    });

    // Check each box when the response type select element changes
    $('form').on('change', '.response-type', function() {
        disableInputs(this);
    });

});
