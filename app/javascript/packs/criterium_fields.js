function disableInputs(formElement){
    if(formElement.value === "0" || formElement.value === "3"){
        $(formElement).closest('div.nested-fields').find('.min-value').prop("disabled", true);
        $(formElement).closest('div.nested-fields').find('.max-value').prop("disabled", true);
    }else{
        $(formElement).closest('div.nested-fields').find('.min-value').prop("disabled", false);
        $(formElement).closest('div.nested-fields').find('.max-value').prop("disabled", false);
    }
}

// Dynamically enabled and disables the min/max values for the criteria fields
$(document).on('turbolinks:load', function(){

    // Check all min/max boxes when page loads (for editing)
    $('.response-type').each(function() {
        disableInputs(this);
    });

    $('form').on('click', '.add_fields', function(event){
        disableInputs(this);
    });

    // Check each box when the response type select element changes
    $('form').on('change', '.response-type', function() {
        disableInputs(this);
    });

});
