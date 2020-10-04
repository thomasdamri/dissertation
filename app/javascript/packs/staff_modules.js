$(document).on('turbolinks:load', function(){

    $('form').on('click', '.remove_fields', function(event){
        console.log("yes");
        $(this).prev('input[type=hidden]').val('1');
        $(this).closest('.nested-fields').hide();
        event.preventDefault();
    });

    $('form').on('click', '.add_fields', function(event){
        console.log("Yes");
        let time = new Date().getTime();
        let regexp = new RegExp($(this).data('id'), 'g');
        $(this).before($(this).data('fields').replace(regexp, time));
        event.preventDefault();
    });
});