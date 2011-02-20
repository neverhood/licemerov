// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
var $loader = "<img id='loader' src='/images/loader.gif' />";

$.fn.clearForm = function() {
    return this.each(function() {
        var type = this.type, tag = this.tagName.toLowerCase();
        if (tag == 'form') {
            $(this).children('.field_with_errors').remove();
            return $(':input',this).clearForm();
        }
        if (type == 'file') {
            this.value = '';
            $(this).replaceWith($(this).clone(true));
        }
        if (type == 'submit') {
            if ((typeof $(this).attr('disabled')) != 'undefined') this.disabled = 'disabled';
        }
        if (type == 'text' || type == 'password' || tag == 'textarea') {
            this.value = '';  $('#' + this.id).val(''); }
        if (type == 'checkbox' || type == 'radio')
            this.checked = false;
        if (tag == 'select')
            this.selectedIndex = -1;
    });
};

$(window).load(function() {
    $.licemerov = {
        version: '1.0',
        jcrop_params: {onChange: refreshAvatarPreview, onSelect: updateCrop, minSize: [100, 100], aspectRation:1},
        jcrop_api: null
    };
    if(typeof $.Jcrop == 'function') $.licemerov['jcrop_api'] = $.Jcrop('#cropbox', $.licemerov.jcrop_params);
});

$(document).ready(function() {


    $('div.parent .body, div.parent ul.responses').corner();
    $('#parent_form, #response_form, #edit_avatar').clearForm();

    $('form#parent_form, form#response_form').keyup(function() {
        var submit = this.elements[this.elements.length - 1];
        (this.elements[2].value.length >= 2) ? submit.disabled = '' : submit.disabled = 'disabled'; // elemets[2] is a textarea
    }).
            bind("ajax:loading", function() {toggleLoader(this)}). // TODO: Wait for 'remotipart' release for new rails.js and change 'loading' to 'beforeSend'
            bind("ajax:complete", function() {toggleLoader(this)});


    $('form#edit_avatar').submit(function() {
        toggleLoader(this);
    }).change(function() {
        var submit = $(this).find(':submit');
        ($(this).find(':file').val().length > 0) ? submit.enable() : submit.disable();
    });

    $('.reply').live('click', function() {
        var form = $('#response_form');
        var div = $(this).next();
        var id = $(this).parents('.parent').attr('id').replace(/entry-/, '');
        if (! (div.children('#response_form').length && form.is(':visible')) )
            form.clearForm().appendTo(div).fadeIn().find('textarea').focus().next().val(id);
        else
            form.hide();
        $('#parent_form').clearForm();
    });

    $('img.regular, img.enlarged').live('click', function() {  // Enlarge image on click. It`s WEB 2.0, motherfucker
        var type = this.className, opposite_type = type == 'regular' ? 'enlarged' : 'regular';
        $(this).addClass(opposite_type).removeClass(type).
                css({height:toggleSize($(this), 'height'), width:toggleSize($(this), 'width')}).
                attr('src', this.src.replace(type, opposite_type));
    });

    $('form :file').change(function() {
        var $cancel = $(this).next();
        (this.value.length > 0) ? $cancel.show() : $cancel.hide();
    });

    $('.cancel-upload').click(function() {
        var $cancel = $(this).hide();
        var $field = $cancel.prev();
        $field.replaceWith($field.clone(true)).val('');
        if ($cancel.attr('rel') == 'disable')
            $cancel.parents('form').find(':submit').attr('disabled', 'disabled');
    });

});

function toggleLoader(form) {
    var submit = $(form).find(':submit');
    if (submit.is(':visible'))
        submit.hide().parent('form').append($loader);
    else {
        submit.show().next().remove(); // Show submit button and hide next element, which is #loader
        if ($(form).children('input[name*="parent_id"]').length && !($(form).children('.field_with_errors').length))
            $(form).hide();
    }
}

function toggleSize(img, attr) {
    return(parseInt(img.css(attr)) + (img.attr('class') == 'enlarged' ? 100 : -100) + 'px');
}

function appendErrors(errors, form) { // Render object errors
    $.each(errors, function(index) {
        form.prepend("<div class='field_with_errors'>" + errors[index] + "</div>");
    });
}
//  ******************* CROPPING FUNCTIONS ******************** TODO: please refactor me


function releaseJcrop() {
    $.licemerov.jcrop_api.release();
    $('#release_jcrop').hide().parent('form').find(':submit').attr('disabled', 'disabled').
            parent('form').find('input[id^="crop"]').val('');
}

$(document).ready(function() {
    $('#release_jcrop, #edit_avatar :file').click(function() {
        releaseJcrop();
    });
});

function updateCrop(coords) {
    if ($('#release_jcrop').not(':visible')) {
        $('#edit_avatar').clearForm().find(':submit').attr('disabled', '');
        $('#release_jcrop').show();
    }
    var ratio = (parseFloat($('#cropbox').attr('data-ratio'))); // The rate of original image / re-sized image
    $('#crop_x').val(Math.floor(coords.x * ratio)).next().val(Math.floor(coords.y * ratio)).
            next().val(Math.floor(coords.w * ratio)).next().val(Math.floor(coords.h * ratio));
}

function refreshAvatarPreview(coords) {
    var rx = 200/coords.w, ry = 200/coords.h;
    var geometry = $('#cropbox').attr('data-geometry').split('x');
    var height = parseInt(geometry[1]), width = parseInt(geometry[0]);
    $('#preview').css({width: Math.round(rx * width) + 'px', height: Math.round(ry * height) + 'px',
        marginLeft: '-' + Math.round(rx * coords.x) + 'px',
        marginTop: '-' + Math.round(ry * coords.y) + 'px'});
}
//  ******************* CROPPING FUNCTIONS END ********************
