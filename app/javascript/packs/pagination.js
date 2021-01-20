$(document).on('turbolinks:load', function(){
    $('.pagination > span').addClass('page-item');
    $('.pagination > a').addClass('page-item');
    $('.pagination > a').addClass('page-link');

    $('.pagination > em, .pagination > span').replaceWith(function(i){
        // Replace the em from the will-paginate gem with bootstrap styled links
        return `<li class='page-item disabled'><a class='page-link' href='#' tabindex='-1'>${this.innerText}</a></li>`
    })
});