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

$(document).on('turbo:load', function(){

    // For removing staff members from modules
    $('form').on('click', '.remove_fields', function(event){
        $(this).prev('input[type=hidden]').val('1');
        $(this).closest('.nested-fields').hide();
        event.preventDefault();
    });

    // Deal with criteria field removing differently, due to different styling
    $('form').on('click', '.remove_fields.remove_crit', function(event){
        // Find the closets hidden element (must first navigate out of styling divs)
        $(this).closest('.row').prev('input[type=hidden]').val('1');
        $(this).closest('.nested-fields').hide();
        event.preventDefault();
    });

    $('form').on('click', '.add_fields', function(event){
        let time = new Date().getTime();
        let regexp = new RegExp($(this).data('id'), 'g');
        // Place immediately before the button if doing staff-module creation
        if($(this).closest('.buttons').length === 0) {
            $(this).before($(this).data('fields').replace(regexp, time));
        }else{
            // Place above all the buttons if doing criteria creation
            $(this).closest('.buttons').before($(this).data('fields').replace(regexp, time));
        }

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
