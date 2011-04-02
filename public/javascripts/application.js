// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


function toggleImageSize(img) {
    var type = img.className,
            oppositeType = type == 'regular' ? 'enlarged' : 'regular',
            height = img.height + (type == 'enlarged'? -100 : 100),
            width = img.width + (type == 'enlarged'? -100 : 100),
            src = img.src.replace(type, oppositeType);

    img.width = (width);
    img.height = (height);
    img.src = src;
    img.className = oppositeType;
    return false;
}

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
        if (type == 'submit'  ) {
            $(this).attr('disabled', true);
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
        $('#message_body').focus();
    } else {
        $opaco.toggleClass('hidden').removeAttr('style');
        $popUp.toggleClass('hidden');
        if ($popUp.find('form')) {
            $popUp.find('form').clearForm();
        }
    }
}

function changeMarkedMessagesCounter( count ) {
    var counter = $('#marked-messages-counter').
            html( count ),
            container = $('#options'),
            visible = counter.is(':visible');
    if ( count == 0 )  {
        container.hide();
    } else {
        if ( !visible ) container.show();
    }
}


$(document).ready(function() {
    if ($('#wrapper').attr('data-user').length > 1) var user_attributes = $('#wrapper').attr('data-user').split(',');
    $.licemerov = {
        version: '1.0',
        loader: $("<img class='loader' src='/images/loader.gif' />"),
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
        return false;
    });

    $('a.inactive').live('click', function() { return false });

    $('#parent_form, #response_form, #edit_avatar').clearForm();

    $('form#parent_form, form#response_form').keyup(function() {
        $(this.elements[this.elements.length - 1])
                .attr('disabled', (this.elements[2].value.length < 2)); //elements[2] is a textarea
    });
//            .bind("ajax:beforeSend", function() {toggleLoader(this)}). // TODO: Wait for JangoSteve's pull request merged into jquery-ujs
//            bind("ajax:complete", function() {toggleLoader(this)});

    $('form#edit_avatar :file').change(function() {
        $('form#edit_avatar :submit')
                .attr('disabled', this.value.length == 0);
    });

    $('a#delete-friend, a#add-friend').
            live("ajax:beforeSend", function() { $(this).toggleLoader() } ).
            live("ajax:complete",  function() { $(this).toggleLoader() } );

    // Messages
    $('td.delete-message a, .message-delete').live('ajax:beforeSend', function() {
        $(this).toggleLoader();
    });

    $('td.mark-message input[type="checkbox"]').click(function() {
        var checked = this.checked,
                ids = [],
                checkedMessages = $('td.mark-message input:checked'),
                buttons = $('a.message-delete, a.message-mark_as_read');

        $.each(checkedMessages, function() {
           ids.push( this.id.replace('message-', '') );
        });

        $.each(buttons, function() {
            var href = this.href.replace(/&messages=.*/, '');
            this.href = href + '&messages=' + ids.join(',');
        });

        changeMarkedMessagesCounter( checkedMessages.length );
    });

//    $('a.message-delete, a.message-mark-as-read').click(function(event) {
//        event.preventDefault();
//        var checkedMessages = $('td.mark-message input:checked'),
//            ids = [],
//            href = this.href;
//        $.each(checkedMessages, function() {
//            ids.push( this.id.replace('message-', '') )
//        });
//        this.href = href + '&messages=' + ids.join(',');
//        return false;
//    });

    // Messages end

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

    $('img.regular, img.enlarged').live('click', function() {  // Enlarge image
        toggleImageSize(this);
    });

    $('form :file').change(function() {
        var $cancel = $(this).next();
        (this.value.length > 0) ? $cancel.show() : $cancel.hide();
    });

    $('.cancel-upload').click(function() {
        var $cancel = $(this).hide();
        var $field = $cancel.prev();
        $field.replaceWith($field.clone(true)).val('');
        $cancel.parents('form')
                .find(':submit')
                .attr('disabled', ($cancel.attr('rel') != 'disable'));
    });

    $('a.confirm, a.cancel, a.blacklist').live('ajax:beforeSend', function() {
        $(this).parents('div.options').hide().after($.licemerov.loader);
    }).bind('ajax:complete', function() { $(this).parent().next().remove(); });

    $('a.confirm, a.blacklist').live('ajax:complete', function(evt, xhr) {
        var params = $.parseJSON(xhr.responseText);
        $(this).parents('div.options').html('<div class="' +
                params.html_class + '">' + params.message + '</div>').show();
    });



});

$.fn.toggleLoader = function() {
    return this.each(function() {
        var $this = $(this),
                loader = $.licemerov.loader;

        if (this.tagName.toLowerCase() == 'a') {
            $this.is(':visible')? $this.before(loader).hide() :
                    loader.remove();
        } else if ( this.tagName.toLowerCase() == 'form' ) {
            var submit = $this.find(':submit');
            if (submit.is(':visible')) {
                submit.hide();
                $this.append(loader);
            } else {
                submit.show().next().remove();
                if (this.id == 'response_form' && $this.find('.field_with_errors').length == 0)
                    $this.hide();
            }
        }
    });
};

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
