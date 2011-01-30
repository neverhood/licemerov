// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
var $loader = "<img id='loader' src='images/loader.gif' />";

$(document).ready(function() {

   $('#new_root_entry').bind("ajax:beforeSend", function() {toggleLoader(this)}).
            bind("ajax:complete", function() {toggleLoader(this)});

});

function toggleLoader(form) {
    var submit = $(form).find('input[type="submit"]');
    if (submit.is(':visible')) {
        submit.hide();
        $(form).append($loader);
    } else {
        submit.show(); $('#loader').remove();
    }
}

$(document).ready(function() {

});