// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
var $loader = "<img id='loader' src='/images/loader.gif' />";

$.fn.clearForm = function() {
    return this.each(function() {
        var type = this.type, tag = this.tagName.toLowerCase();
        if (tag == 'form') {
            $(this).children('.field_with_errors').remove();
            $(this).find('.cancel-upload').hide();
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
$.fn.alignCenter = function() {
    var marginLeft =  - $(this).width()/2 + 'px',
            marginTop =  - $(this).height()/2 + 'px';
    return $(this).css({'margin-left':marginLeft, 'margin-top':marginTop});
};


$(window).load(function() {
    if((typeof $.Jcrop == 'function') && $('#cropbox').length)
           $.licemerov.jcrop_api = $.Jcrop('#cropbox', {onChange: refreshAvatarPreview, onSelect: updateCrop,
            minSize: [100, 100], aspectRation:1});
});

$('#cropbox').load(function() {
    $.jcrop_api = $.Jcrop('#cropbox', {onChange: refreshAvatarPreview, onSelect: updateCrop,
      minSize: [100, 100], aspectRation:1});
});

function togglePopup() { //TODO: REFACTORING
    var $popUp = $('#popup'),
            $opaco = $('#opaco');

    if ($popUp.hasClass('hidden'))  {

        if($.browser.msie) {
            $opaco.height($(document).height()).toggleClass('hidden');
        } else {
            $opaco.height($(document).height()).toggleClass('hidden').fadeTo('slow', 0.7);
        }
        $popUp
                .alignCenter()
                .toggleClass('hidden');
    } else {
        $opaco.toggleClass('hidden').removeAttr('style');
        $popUp.toggleClass('hidden');
        if ($popUp.find('form')) {
            $popUp.find('form').clearForm();
        }
    }
}


$(document).ready(function() {
    if ($('#wrapper').attr('data-user').length > 1) var user_attributes = $('#wrapper').attr('data-user').split(',');
    $.licemerov = {
        version: '1.0',
        loader: "<img class='loader' src='/images/loader.gif' />",
        user: {}
    };
    if(typeof user_attributes != 'undefined') {
        $.licemerov.user.attributes = {login: user_attributes[0], sex: user_attributes[1]};
        if (typeof user_attributes[2] != 'undefined')
            $.licemerov.user.attributes.avatar_url = user_attributes[2];
    }
    if ($('#friends-json').length)
        $.licemerov.user.friends = $.parseJSON( $('#friends-json').text() );
});


$(document).ready(function() {

    $('a#new-message, #close-popup').click(function(event) { //TODO: Refactoring
        event.preventDefault();
        togglePopup();
        $('#message_recipient').focus();
    });

    $('a.inactive').live('click', function() { return false });

    $('#parent_form, #response_form, #edit_avatar').clearForm();

    $('form#parent_form, form#response_form').keyup(function() {
        var submit = this.elements[this.elements.length - 1];
        (this.elements[2].value.length >= 2) ? submit.disabled = '' : submit.disabled = 'disabled'; // elements[2] is a textarea
    });
//            .bind("ajax:beforeSend", function() {toggleLoader(this)}). // TODO: Wait for JangoSteve's pull request merged into jquery-ujs
//            bind("ajax:complete", function() {toggleLoader(this)});


    $('form#edit_avatar').change(function() {
        var submit = $(this).find(':submit');
        if ( $(this).find(':file').val().length > 0 ) {
          $(submit).attr('disabled', false);
          alert('p');
        } else { 
          $(submit).attr('disabled', true)
        }
    });

    $('a#delete-friend, a#add-friend').
            live("ajax:beforeSend", function() { toggleLoader(this)}).
            live("ajax:complete", function() { toggleLoader(this)});
    $('a#add-friend').live("ajax:complete", function(evt, xhr) {
        var params = $.parseJSON(xhr.responseText);
        $(this).after('<div class="' + params.html_class + '">' + params.message + '</div>');
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

    // TODO: please refactor this ugliness
    $('img.regular, img.enlarged').live('click', function() {  // Enlarge image
        var type = this.className, opposite_type = type == 'regular' ? 'enlarged' : 'regular';
        $(this).addClass(opposite_type)
                .removeClass(type)
                .css({height:toggleSize($(this), 'height'), width:toggleSize($(this), 'width')})
                .attr('src', this.src.replace(type, opposite_type));
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
            $cancel.parents('form')
                    .find(':submit')
                    .attr('disabled', 'disabled');
    });

    $('a.confirm, a.cancel, a.blacklist').live('ajax:beforeSend', function() {
        $(this).parents('div.options').hide().after($loader);
    }).bind('ajax:complete', function() { $(this).parent().next().remove(); });

    $('a.confirm, a.blacklist').live('ajax:complete', function(evt, xhr) {
        var params = $.parseJSON(xhr.responseText);
        $(this).parents('div.options').html('<div class="' +
                params.html_class + '">' + params.message + '</div>').show();
    });

});

function toggleLoader(elem) {
    var $elem = $(elem);
    if (elem.tagName.toLowerCase() == 'a') {
        if ($elem.is(':visible'))
            $elem.before($loader).hide();
        else
            $('#loader').remove();
    }
    else if (elem.tagName.toLowerCase() == 'form') {
        var submit = $elem.find(':submit');
        if (submit.is(':visible'))
            submit.hide().parent('form').append($loader);
        else {
            submit.show().next().remove(); // Show submit button and hide next element, which is #loader
            if ($elem.children('input[name*="parent_id"]').length && !($(elem).children('.field_with_errors').length))
                $elem.hide();
        }
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
    var rx = 200/coords.w, ry = 200/coords.h,
            geometry = $('#cropbox').attr('data-geometry').split('x'),
            height = parseInt(geometry[1]), width = parseInt(geometry[0]);

    $('#preview').css({width: Math.round(rx * width) + 'px', height: Math.round(ry * height) + 'px',
        marginLeft: '-' + Math.round(rx * coords.x) + 'px',
        marginTop: '-' + Math.round(ry * coords.y) + 'px'});
}
//  ******************* CROPPING FUNCTIONS END ********************
