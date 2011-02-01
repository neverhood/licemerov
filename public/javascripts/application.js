// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
var $loader = "<img id='loader' src='images/loader.gif' />";

$.fn.clearForm = function() {
    return this.each(function() {
        var type = this.type, tag = this.tagName.toLowerCase();
        if (tag == 'form') {
            $(this).children('.field_with_errors').remove();
            $(this).children('input[type="submit"]').attr('disabled', 'disabled');
            return $(':input',this).clearForm();
        }
        if (type == 'text' || type == 'password' || tag == 'textarea') {
            this.value = '';
            $('#' + this.id).val('');
        }
        else if (type == 'checkbox' || type == 'radio')
            this.checked = false;
        else if (tag == 'select')
            this.selectedIndex = -1;
    });
};

$(document).ready(function() {

    $('div.parent .body, div.parent ul.responses').corner();

    $('#parent_form, #response_form').keyup(function() {
        var submit = $(this).children('input[type="submit"]');
        if ($(this).children('textarea').val().length >= 2)
            submit.removeAttr('disabled');
        else
            submit.attr('disabled', 'disabled');
    }).
            bind("ajax:loading", function() {toggleLoader(this)}). // TODO: Wait for 'remotipart' release for new rails.js and change 'loading' to 'beforeSend'
            bind("ajax:complete", function() {toggleLoader(this)});

    $('.reply').live('click', function() {
        var form = $('#response_form');
        var div = $(this).next();
        var id = $(this).parents('.parent').attr('id').replace(/entry-/, '');
        if (! (div.children('#response_form').length && form.is(':visible')) )
            form.clearForm().appendTo(div).fadeIn().find('textarea').focus().next().val(id);
        else
            form.hide();
    });

    $('img.regular, img.enlarged').live('click', function() {  // Enlarge image on click. It`s WEB 2.0, motherfucker
        var type = this.className.toLowerCase();
        var opposite_type = type == 'regular' ? 'enlarged' : 'regular';
        $(this).addClass(opposite_type).removeClass(type).
                attr('src', this.src.replace(type, opposite_type));
    });

});

function toggleLoader(form) {
    var submit = $(form).find('input[type="submit"]');
    if (submit.is(':visible'))
        submit.hide().parent('form').append($loader);
    else {
        submit.show().next().remove(); // Show submit button and hide next element, which is #loader
        if ($(form).children('input[name*="parent_id"]').length && !($(form).children('.field_with_errors').length))
            $(form).hide();
    }
}

function appendErrors(errors, form) { // Render object errors
    $.each(errors, function(index) {
        form.prepend("<div class='field_with_errors'>" + errors[index] + "</div>");
    });
}