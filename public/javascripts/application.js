// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
var $loader = "<img id='loader' src='images/loader.gif' />";

$.fn.clearForm = function() {
    this.each(function() {
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

    $('#parent_form, #response_form').keyup(function() {
        var submit = $(this).children('input[type="submit"]');
        if ($(this).children('textarea').val().length >= 2)
            submit.removeAttr('disabled');
        else
            submit.attr('disabled', 'disabled');
    }).
            bind("ajax:beforeSend", function() {toggleLoader(this)}).
            bind("ajax:complete", function() {toggleLoader(this)});

    $('.reply').live('click', function() {
        var form = $('#response_form');
        var div = $(this).parent('div');
        var id = div.attr('id').replace(/entry-/, '');
        if (! (div.children('#response_form').length && form.is(':visible')) ) {
            form.clearForm();
            form.appendTo(div).show().
                    find('input[name*="parent_id"]').val(id);
            form.children('textarea').focus();
        }
    });

});

function toggleLoader(form) {
    var submit = $(form).find('input[type="submit"]');
    if (submit.is(':visible')) {
        submit.hide();
        $(form).append($loader);
    } else {
        submit.show();
        $('#loader').remove();
        if ($(form).children('input[name*="parent_id"]').length && !($(form).children('.field_with_errors').length))
            $(form).hide();
    }
}

function appendErrors(errors, form) { // Render object errors
    $.each(errors, function(index) {
        form.prepend("<div class='field_with_errors'>" + errors[index] + "</div>");
    });
}