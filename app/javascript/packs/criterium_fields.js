// Dynamically enabled and disables the min/max values for the criteria fields
$(document).on('turbolinks:load', function(){

    $('form').on('change', '.response-type', function() {
        if(this.value === "0"){
            $(this).closest('div.nested-fields').find('.min-value').prop("disabled", true);
            $(this).closest('div.nested-fields').find('.max-value').prop("disabled", true);
        }else{
            $(this).closest('div.nested-fields').find('.min-value').prop("disabled", false);
            $(this).closest('div.nested-fields').find('.max-value').prop("disabled", false);
        }
    });

});
