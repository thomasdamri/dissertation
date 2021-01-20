$(document).on('turbolinks:load', function(){
    $('.copy-btn').on('click', function() {
        let copyText = $("#groupEmailText");
        navigator.clipboard.writeText(copyText[0].innerText);
    });
});
