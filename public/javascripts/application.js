// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
var $loader = "<img id='loader' src='images/loader.gif' />";

$.fn.clearForm = function() {
    this.each(function() {
        var type = this.type, tag = this.tagName.toLowerCase();
        if (tag == 'form')
            return $(':input',this).clearForm();
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

    $('#parent_form, #response_form').bind("ajax:beforeSend", function() {toggleLoader(this)}).
            bind("ajax:complete", function() {toggleLoader(this)});

    $('.reply').live('click', function() {
        var div = $(this).parent('div');
        var id = div.attr('id').replace(/entry-/, '');
        $('#response_form').appendTo(div).show().
                find('input[name*="parent_id"]').val(id);
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
        if ($(form).children('input[name*="parent_id"]').length)
            $(form).hide();
    }
}

$(document).ready(function() {

});