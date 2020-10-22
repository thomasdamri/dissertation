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
    if(formElement.value !== "0"){
        targetElement.prop('disabled', true);
    }else{
        targetElement.prop('disabled', false);
    }
}

// Given an assessed checkbox, disables the nearest weighting input box if not assessed
function disableWeightBox(formElement){
    let targetElement = $(formElement).closest('div.nested-fields').find('.relative-weight');
    if(formElement.value === "0"){
        targetElement.val('')
        targetElement.prop('disabled', true);
    }else{
        targetElement.prop('disabled', false);
    }
}

$(document).on('turbolinks:load', function(){

    $('form').on('click', '.remove_fields', function(event){
        $(this).prev('input[type=hidden]').val('1');
        $(this).closest('.nested-fields').hide();
        event.preventDefault();
    });

    $('form').on('click', '.add_fields', function(event){
        let time = new Date().getTime();
        let regexp = new RegExp($(this).data('id'), 'g');
        $(this).before($(this).data('fields').replace(regexp, time));

        // Run check for disabling mix/max inputs on assessment creation form
        $('.minmax').each(function (){
            let response_type_el = $(this).closest('div.nested-fields').find('.response-type');
            disableInputs(response_type_el[0]);
        });

        $('.single:last').each(function (){
            // Manually disable the assessed and weighting boxes when fields are first added
            // This does not affect pre-made fields from the edit form, only new ones
            $(this).closest('div.nested-fields').find('.assessed').prop('disabled', true);
            $(this).closest('div.nested-fields').find('.relative-weight').prop('disabled', true);
        });

        event.preventDefault();
    });

    $('form').on('change', '.single', function() {
        disableAssessedBox(this);
    });

    $('form').on('change', '.assessed', function() {
        disableWeightBox(this);
    });

});
