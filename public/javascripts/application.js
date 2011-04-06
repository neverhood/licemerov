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

function updateMessageActionLinks( ids ) {
    var buttons = $('a.delete-messages, a.read-messages');
    $.each(buttons, function() {
        var messages = ids.join(','),
                href = '/messages/' + messages;
        $(this).data('messages', messages).attr('href', href);
    });
}


$(document).ready(function() {
    if ($('#wrapper').attr('data-user').length > 1)
        var user_attributes = $('#wrapper').attr('data-user').split(',');
    $.licemerov = {
        version: '1.0',
        domain: window.location.origin,
        location: window.location.href,
        loader: ("<img class='loader' src='/images/loader.gif' />"),
        user: {},
        actions: {},
        utils: {}
    };
    if(typeof user_attributes != 'undefined') {
        $.licemerov.user.attributes = {
            login: user_attributes[0],
            sex: user_attributes[1],
            avatar_url: user_attributes[2],
            id: user_attributes[3]
        };
    }
    if ($('#friends-json').length)
        $.licemerov.user.friends = $.parseJSON( $('#friends-json').text() );


    $.licemerov.utils.linkTo = function(options) {
        if (typeof options.href == 'undefined') {
            options.href = $.licemerov.location;
        }
        var $url = $('<a></a>').
                attr( {href: options.href} ).text(options.text);
        if ( typeof options.data != 'undefined' ) {
            if ( options.data.remote ) $url.attr('rel', 'nofollow');
            $.each( options.data, function(key, value) {
                $url.attr('data-' + key, value);
            });
        }

        if ( typeof options.html != 'undefined' ) {
            $.each( options.html, function(key, value) {
                eval('$url[0].' + key + ' = "' + value + '"'); // duh, ugly
            });
        }

        return $url;

    };

});


$(document).ready(function() {

    $('a#new-message, #close-popup').click(function(event) { //TODO: Refactoring
        event.preventDefault();
        togglePopup();
        return false;
    });

    $('a.inactive').live('click', function(event) {
        event.preventDefault();
        return false;
    });

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


    // Friendships
    $('a#delete-friend, a#add-friend, a.delete-friend, a.cancel-friendship-invite').
            live('ajax:beforeSend', function() {

        var $this = $(this).toggleLoader(),
            row = $this.parents('tr');

        if ($this.hasClass('delete-friend') || $this.hasClass('cancel-friendship-invite')) {
            row.find('.friend-options a').addClass('hidden');
        }
    });

    // Delete friend using a link on his profile page
    $('a#delete-friend').bind('ajax:complete', function(event, xhr, status) {
        if ( status == 'success' ) {
            var params = $.parseJSON( xhr.responseText ),
                    $this = $(this).toggleLoader(),
                    url = $.licemerov.utils.linkTo({
                        text: params.add_friend,
                        href: '/friendships?friend_id=' + $.licemerov.user.attributes.id,
                        data: { remote: true, method: 'post' },
                        html: { id: 'add-friend' }
                    }).bind('ajax:complete', function(event, xhr, status) {
                        if ( status == 'success' ) {
                            var params = $.parseJSON( xhr.responseText ),
                                    noticesContainer = $('#notices'),
                                    notice = $('<div class="' + params.html_class + '">' +
                                            params.message + '</div>');
                            noticesContainer.find('.' + params.html_class)
                                    .append(notice);
                        }
                        $(this).toggleLoader();
                    });

            // Update friends counter
            $this.before(url).remove();
        }
    });

    // Delete from /friends page or cancel friendship invite
    $('a.delete-friend, a.cancel-friendship-invite').bind('ajax:complete', function() {
        $(this).parents('tr').hide();
        // Update friends counter
    });



    // TODO: To be refactored
//    $('a.confirm, a.cancel, a.blacklist').live('ajax:beforeSend', function() {
//        $(this).parents('div.options').hide().after($.licemerov.loader);
//    }).bind('ajax:complete', function() { $(this).parent().next().remove(); });
//
//    $('a.confirm, a.blacklist').live('ajax:complete', function(evt, xhr) {
//        var params = $.parseJSON(xhr.responseText);
//        $(this).parents('div.options').html('<div class="' +
//                params.html_class + '">' + params.message + '</div>').show();
//    });

    // TODO: till here

    // Friendships end

    // Messages
    $('a.delete-message, a.delete-messages, a.recover-message, a.recover-messages, a.read-messages')
            .live('ajax:beforeSend', function() {
        $(this).toggleLoader();
    });

    $('a.delete-message').bind('ajax:complete', function(event, xhr, status) {
        if (status == 'success') {
            var params = $.parseJSON(xhr.responseText),
                    $this = $(this).toggleLoader(),
                    row = $this.parents('tr')[0],
                    column = $this.parent(),

                    url = $.licemerov.utils.linkTo({
                        text: params.single,
                        href: '/messages/' + row.id + '/recover',
                        data: { remote: true, method: 'post' },
                        html: { className: 'recover-message' }
                    }).bind('ajax:complete', function(event, xhr, status) {
                        if (status == 'success') {
                            $(this).toggleLoader().remove();
                            column.find('.delete-message').show();
                        }
                    });

            column.append(url);
        }
    });

    $('a.delete-messages').bind('ajax:complete', function(event, xhr, status) {
        if (status == 'success') {
            var elements = [],
                    $this = $(this).toggleLoader().show();

            $.each( $this.data('messages').split(','), function() {
                var elem = $('tr#' + this).toggleClass('deleted-message');
                elem.find('input[type="checkbox"]').attr('checked', false);
                elements.push(elem);
            });

            var params = $.parseJSON(xhr.responseText),
                    url = $.licemerov.utils.linkTo({
                        text: params.multiple,
                        href: '/messages/all/recover',
                        data: { remote: true, method: 'post' },
                        html: { className: 'recover-messages' }
                    }).bind('ajax:complete', function(event, xhr, status) {
                        if ( status == 'success' ) {
                            $.each(elements, function() {
                                this.toggleClass('deleted-message');
                            });
                            $(this).toggleLoader().remove();
                        }
                    });

            changeMarkedMessagesCounter( 0 );
            $.licemerov.user.messages_marked_filter = null;
            $('#marking-message-options').append(url);

        }
    });

    $('a.read-messages').bind('ajax:complete', function() {
        var $this = $(this).toggleLoader().show();
        $.each( $('td.mark-message input:checked'), function() {
            this.checked = false;
        });
        $.each( $this.data('messages').split(','), function() {
            var row = $('tr#' + this);
            if ( ! row.hasClass('read') ) {
                row.toggleClass('read unread')
            }
        });

        changeMarkedMessagesCounter( 0 );
        $.licemerov.user.messages_marked_filter = null;
    });

    $('td.mark-message input[type="checkbox"]').click(function() {
        var  ids = [],
                checkedMessages = $('td.mark-message input:checked'),
                buttons = $('a.delete-messages, a.read-messages');

        $.each(checkedMessages, function() {
            ids.push( this.id.replace('message-', '') );
        });

        updateMessageActionLinks(ids);

        $.licemerov.user.messages_marked_filter = null;

        changeMarkedMessagesCounter( checkedMessages.length );
    });

    $('span#marking-message-options a').click(function(event) {
        event.preventDefault();
        var id = this.id.toLowerCase(),
                ids = [],
                markMessages = function( elements, check ) {
                    $.each( elements, function() {
                        this.checked = check;
                        if ( check ) ids.push(this.id.replace('message-', ''))
                    });
                },
                elements = [],
                filter = $.licemerov.user.messages_marked_filter;

        markMessages( $('td.mark-message input[type="checkbox"]:checked'), false ); // Unmark all messages first

        if ( filter && filter == id ) { // User didn't check/uncheck anything and clicks filter again
            // uncheck all messages
            markMessages( $('td.mark-message input[type="checkbox"]:checked'), false );
            updateMessageActionLinks( [0] );
            $.licemerov.user.messages_marked_filter = null; // hence no filter is active
        } else {
            if ( id == 'mark-unread-messages' ) {
                elements = $('tr.unread:not(.deleted-message) input[type="checkbox"]');
            } else if ( id == 'mark-read-messages' ) {
                elements = $('tr.read:not(.deleted-message) input[type="checkbox"]')
            } else if ( id == 'mark-all-messages' ) {
                elements = $('tr:not(.deleted-message) input[type="checkbox"]')
            }

            markMessages(elements, true);
            updateMessageActionLinks( ids );
            $.licemerov.user.messages_marked_filter = (elements.length > 0)? id : null;

        }

        changeMarkedMessagesCounter( elements.length );

        return false;
    });


    // Messages end


    $('.reply').live('click', function() {
        var form = $('#response_form'),
                $this = $(this),
                div = $this.next(),
                id = $this.parents('.parent')
                        .attr('id')
                        .replace(/entry-/, '');

        if (! (div.children('#response_form').length && form.is(':visible')) )
            form.clearForm()
                    .appendTo(div)
                    .fadeIn()
                    .find('textarea').focus()
                    .next()
                    .val(id);
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

});

$.fn.toggleLoader = function() {
    return this.each(function() {
        var $this = $(this),
                loader = ("<img class='loader' src='/images/loader.gif' />");

        if (this.tagName.toLowerCase() == 'a') {
            $this.is(':visible')? $this.before(loader).hide() :
                    $this.prev().remove();
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
