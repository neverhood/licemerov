// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
    var $loader = "<img src='images/loader.gif' />";
$(document).ready(function() {

    $('#parent_form').bind("ajax:beforeSend", function() {toggleLoader(this)}).
            bind("ajax:complete", function() {toggleLoader(this)});

});

function toggleLoader(form) {
    var submit = $(this).children('input[type="submit"]');
    if (submit.is(':visible')) {
        submit.hide();
        form.append($loader);
    } else {
        submit.show(); $loader.remove();
    }
}