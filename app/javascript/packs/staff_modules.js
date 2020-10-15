function disableInputs(formElement){
    if(formElement.value === "0" || formElement.value === "3"){
        $(formElement).closest('div.nested-fields').find('.min-value').prop("disabled", true);
        $(formElement).closest('div.nested-fields').find('.max-value').prop("disabled", true);
    }else{
        $(formElement).closest('div.nested-fields').find('.min-value').prop("disabled", false);
        $(formElement).closest('div.nested-fields').find('.max-value').prop("disabled", false);
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

        event.preventDefault();
    });
});
