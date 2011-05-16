
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

$(document).ready(function() {
    var wrapper = $('#wrapper');

    if (wrapper.attr('data-user').length > 1)
        var user_attributes = wrapper.attr('data-user').split(',');

    $.licemerov = {
        version: '1.0',
        domain: window.location.origin,
        location: window.location.href,
        loader: ("<img class='loader' src='/images/loader.gif' />"),
        user: {},
        actions: {},
        noticesContainer: $('#notices'),
        controller: wrapper.attr('class')
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


    $.licemerov.utils = {
        linkTo: function(options) {
            if (typeof options.href == 'undefined') {
                options.href = $.licemerov.location;
            }
            var $url = $('<a></a>')
                    .attr('href', options.href).text(options.text);

            if ( typeof options.data != 'undefined' ) {
                if ( options.data.remote )
                    $.each( options.data, function(key, value) {
                        $url.attr('data-' + key, value);
                    });
            }

            if ( typeof options.html != 'undefined' ) {
                $.each( options.html, function(key, value) {
                    eval('$url[0].' + key + ' = "' + value + '"');
                });
            }

            return $url;
        },
        noticeFor: function(params) {
            var notice = $('<div></div>');

            return notice.addClass(params.html_class)
                    .text( params.message )
        },
        appendNotice: function(notice) {
            $.licemerov.noticesContainer.find('div').
                    html(''); // Reset notices

            if (! notice instanceof Array) notice = [notice];

            $.each(notice, function() {
                var message = $(this);
                $.licemerov.noticesContainer.find('.' + message.attr('class')).
                        append( message );
            });
        },
        closePopup: function(popUp) {
            var form = popUp.find('form');
            if ( popUp.is(':visible') ) {
                popUp.toggleClass('hidden');
                $('#opaco').addClass('hidden').removeAttr('style');
                if ( form.length ) {
                    form.clearForm();
                }
            }
        }
    };

    // Let's occupy more namespaces!

    $.user = $.licemerov.user;
    $.utils = $.licemerov.utils;

});


$(document).ready(function() {


    $('a[data-notify="true"], form[data-notify="true"]')
            .live('ajax:complete', function(event, xhr, status) {

        var params = $.parseJSON( xhr.responseText );
        if ( status == 'success' ) {
            var notice = $.utils.noticeFor( params );
            $.utils.appendNotice( notice );

        } else if ( status == 'error' ) {
            var errors = [];
            $.each(params.errors, function(index) {
                var notice = $.utils.noticeFor( { message: params.errors[index],
                    html_class: params.html_class } );
                errors.push(notice);
            });

            $.utils.appendNotice( errors );
        }
    });

    $('a[data-remote="true"]').live('ajax:beforeSend ajax:complete', function() {
        $(this).toggleLoader();
    });

    $('a.inactive').live('click', function(event) {
        event.preventDefault();
        return false;
    });

    $('#parent_form, #response_form, #edit_avatar').clearForm();

    $('form#parent_form, form#response_form').keyup(function() {
        var $this = $(this),
                submit = $this.find(':submit'),
                textArea = $this.find('textarea'),
                length = textArea.val().length;

        submit.attr('disabled', !(length >= 1 && length <= 1000) );
    })
            .bind("ajax:beforeSend", function() {$(this).toggleLoader()}).
            bind("ajax:complete", function() {$(this).toggleLoader()});

    $('form#edit_avatar :file').change(function() {
        $('form#edit_avatar :submit')
                .attr('disabled', this.value.length == 0);
    });

    // Albums

    $('h1#create-album').click(function() {
        $('#new-album-form-container').toggle('fast');
    });

    $('input#album_title').bind('keyup keydown', function() {
        var submit = $('#album_submit'),
                length = this.value.length;

        submit.attr('disabled', !( length > 2 && length <= 25 ));
    });

    $('form#new_album').bind('ajax:complete', function(event, xhr, status) {
        var params = $.parseJSON( xhr.responseText ),
                $this = $(this);
        if ( status == 'success' ) {
            $('div#albums').append(
                    $(params.album)
                            .appendTo( $('body') )
                            .hide().slideDown()
                    )
        }

        // jquery ujs set's input 'disabled' attr to false when using :disable_with
        setTimeout( function() {
            $this.clearForm().
                    find(':submit').attr('disabled', true).
                    parents('#new-album-form-container').toggle('fast')
        }, 10);
    });


    $('.delete-album').live('ajax:complete', function() {
        $(this).parent().slideUp('fast', function() { $(this).delayedRemove() });
    });

    // Albums END

    // Friendships

    var friendshipsApi = $.licemerov.friendships = {
        messageFor: function(htmlClass, variations) {
            var message = variations;
            if ( /reject-friendship-invite/.test(htmlClass) ) {
                message = variations.rejected;
            } else if ( /delete-friend/.test(htmlClass) ) {
                message = variations.deleted;
            }
            return message;
        }
    };

    $('a.delete-friend, a.add-to-black-list, ' +
            'a.reject-friendship-invite, a.approve-friendship-invite').
            live('ajax:beforeSend', function() {

        var $this = $(this),
                row = $this.parents('tr'),
                classes = ['delete-friend', 'reject-friendship-invite', 'approve-friendship-invite',
                    'add-to-black-list'],
                hideBeforeComplete = function() {

                    $.each(classes, function() {
                        if ($this.hasClass(this)) return true;
                    });

                    return false;
                };

        if ( hideBeforeComplete ) {
            row.find('.friend-options a').addClass('hidden');
        }
    });

    // Delete friend using a link on his profile page
    $('a#delete-friend').bind('ajax:complete', function(event, xhr, status) {
        if ( status == 'success' ) {
            var params = $.parseJSON( xhr.responseText ),
                    $this = $(this),
                    url = $.utils.linkTo({
                        text: params.message.add,
                        href: '/friendships?friend_id=' + $.licemerov.user.attributes.id,
                        data: { remote: true, method: 'post', notify: true },
                        html: { id: 'add-friend' }});
            $this.before(url).remove();
        }
    });


    $('a.approve-friendship-invite, a.delete-friend, a.reject-friendship-invite, a.add-to-black-list')
            .bind('ajax:complete', function(event, xhr, status) {
        if ( status == 'success' ) {
            var params = $.parseJSON( xhr.responseText ),
                    $this = $(this),
                    row = $this.parents('tr'),
                    message = friendshipsApi.messageFor( $this.attr('class'), params.message  ),
                    notice = $('<div class="' + params.html_class + '">' + message + '</div>');

            $.licemerov.noticesContainer.find('.' + params.html_class)
                    .append(notice);
            row.addClass('hidden');
        }
    });

    // Friendships end

    // Messages

    // I am chainable
    var messagesApi = $.licemerov.messages = {
        filter: null,
        setFilter: function(value) {
            messagesApi.filter = value;
            return messagesApi;
        },
        setMarkedMessagesCount: function(count) {
            var counter = $('#marked-messages-counter').
                    html( count ),
                    container = $('#options');
            if ( count == 0 )  {
                container.hide();
            } else {
                if ( container.not(':visible') ) container.show();
            }
            return messagesApi;
        },
        updateMessageActionLinks: function(ids) {
            var buttons = $('a.delete-messages, a.read-messages');
            $.each(buttons, function() {
                var messages = ids.join(','),
                        href = '/messages/' + messages;
                $(this).data('messages', messages).attr('href', href);
            });
            return messagesApi;
        }
    };

    $('a.delete-message').bind('ajax:complete', function(event, xhr, status) {
        if (status == 'success') {
            var params = $.parseJSON(xhr.responseText),
                    $this = $(this),
                    row = $this.parents('tr').
                            toggleClass('to-be-deleted'),
                    column = $this.parent(),

                    url = $.utils.linkTo({
                        text: params.single,
                        href: '/messages/' + row.attr('id') + '/recover',
                        data: { remote: true, method: 'post' },
                        html: { className: 'recover-message' }
                    }).bind('ajax:complete', function(event, xhr, status) {
                        if (status == 'success') {
                            $(this).delayedRemove();
                            column.find('.delete-message').show();
                            $(row).toggleClass('to-be-deleted').
                                    find('input[type="checkbox"]').attr({checked:false, disabled:false});
                        }
                    }),


                    checkbox = row.find('input[type="checkbox"]').attr('disabled', true);


            if (checkbox.is(':checked')) { // You're nasty or not confident with your hands
                checkbox.prop('checked', false);
                var ids = [];
                $.each( $('td.mark-message input:checked'), function() {
                    ids.push(this.id.replace('message-', ''));
                });
                messagesApi.setMarkedMessagesCount( ids.length ).
                        updateMessageActionLinks( ids ).
                        setFilter(null);
            }

            column.append(url);
        }
    });

    $('a.delete-messages').bind('ajax:complete', function(event, xhr, status) {
        if (status == 'success') {
            var $this = $(this).show(),
                    recoveryLinkSupplied = $('.recover-messages').length;

            $.each( $this.data('messages').split(','), function() {
                $('tr#' + this).toggleClass('deleted-message')
                        .find('input[type="checkbox"]')
                        .prop('checked', false)
            });

            if ( ! recoveryLinkSupplied ) {
                var params = $.parseJSON(xhr.responseText),
                        url = $.licemerov.utils.linkTo({
                            text: params.multiple,
                            href: '/messages/all/recover',
                            data: { remote: true, method: 'post' },
                            html: { className: 'recover-messages' }
                        }).bind('ajax:complete', function(event, xhr, status) {
                            if ( status == 'success' ) {
                                $('.deleted-message').removeClass('deleted-message');
                                $(this).delayedRemove();
                            }
                        });
                $('#marking-message-options').append(url);
            }
            messagesApi.setMarkedMessagesCount( 0 ).
                    setFilter(null);
        }
    });

    $('a.read-messages').bind('ajax:complete', function() {
        var $this = $(this).show();
        $.each( $('td.mark-message input:checked'), function() {
            this.checked = false;
        });
        $.each( $this.data('messages').split(','), function() {
            var row = $('tr#' + this);
            if ( ! row.hasClass('read') ) {
                row.toggleClass('read unread')
            }
        });

        messagesApi.setMarkedMessagesCount( 0 ).
                setFilter(null);
    });

    $('td.mark-message input[type="checkbox"]').click(function() {
        var  ids = [],
                checkedMessages = $('td.mark-message input:checked');

        $.each(checkedMessages, function() {
            ids.push( this.id.replace('message-', '') );
        });

        messagesApi.updateMessageActionLinks(ids).
                setFilter(null).
                setMarkedMessagesCount( checkedMessages.length );
    });

    $('span#marking-message-options a').click(function(event) {
        event.preventDefault();
        var id = this.id.toLowerCase(),
                ids = [],
                markMessages = function( elements, check ) {
                    $.each( elements, function() {
                        var disabled = this.disabled;
                        if (! disabled ) {
                            this.checked = check;
                            if ( check ) ids.push(this.id.replace('message-', ''));
                        }
                    });
                },
                elements = [],
                filter = messagesApi.filter;

        markMessages( $('td.mark-message input[type="checkbox"]:checked'), false ); // Unmark all messages first

        if ( filter && filter == id ) { // User didn't check/uncheck anything and clicks filter again
            // uncheck all messages
            markMessages( $('td.mark-message input[type="checkbox"]:checked'), false );
            messagesApi.updateMessageActionLinks( [0] ).
                    setFilter(null); // hence no filter is active
        } else {
            if ( id == 'mark-unread-messages' ) {
                elements = $('tr.unread:not(.deleted-message) input[type="checkbox"]').not(':disabled');
            } else if ( id == 'mark-read-messages' ) {
                elements = $('tr.read:not(.deleted-message) input[type="checkbox"]').not(':disabled');
            } else if ( id == 'mark-all-messages' ) {
                elements = $('tr:not(.deleted-message) input[type="checkbox"]').not(':disabled');
            }

            markMessages(elements, true);
            messagesApi.updateMessageActionLinks( ids ).
                    setFilter( (elements.length > 0)? id : null );
        }

        messagesApi.setMarkedMessagesCount( elements.length );

        return false;
    });

    $('[data-popup]').click(function(event) {
        event.preventDefault();
        var $this = $(this),
                $opaco = $('#opaco');
        $( $this.attr('data-popup') ). // data-popup attr holds a selector
                alignCenter().
                toggleClass('hidden');

        $opaco.height( $(document).height() ).toggleClass('hidden');
    });

    $('.close').click(function() {
        $.utils.closePopup( $(this).parents('.popup') );
    });

    $('#opaco').click(function() {
        $.utils.closePopup( $('.popup').filter(':visible') );
    });

    $('#single-receiver-message-form').bind('ajax:complete', function() {
        var $this = $(this).clearForm();
        $.utils.closePopup( $this.parents('.popup') );

        setTimeout(function() {
            $this.find(':submit').attr('disabled', true)
        }, 1);
    });

    $('#single-receiver-message-form #message_body').bind('keyup keydown', function() {
        var submit = $('#single-receiver-message-form').find(':submit'),
                length = this.value.length;

        submit.attr('disabled', !(length >= 2 && length < 1000));
    });

    $('.write-message').click(function() {
        var recipient = $.parseJSON( $(this).attr('data-recipient') );
        $('#message-recipient').
                val( recipient.login );
        $('#message_recipients').
                val( recipient.id );
    });

    // Messages end

    // Photos


    var currentPhotoContainer = $('#current-photo'),
            photoCommentSection = $('#photo-comments'),
            photoCommentForm = $('#new-photo-comment-form');

    $('#new_photo').bind('ajax:complete', function(event, xhr, status)  {
        var params = $.parseJSON(xhr.responseText),
                container = $('#photos'),
                photo = params.photo;
        if ( status == 'success' ) {
            container.append( photo );
            $('#enable-fullscreen').show();
        }
    });

    $('.photo').live('click', function() {
        var $this = $(this),
                smallImg = $this.find('img').attr('src'),
                largeImg = $('<img/>').attr('src', smallImg.replace('medium', 'large')),
                photoId = $this.attr('id').replace('photo-', ''),
                url = '/' + $.user.attributes.login + '/photos/' + photoId;

        location.hash = '#' + photoId;
        $('#photo_comment_body').val('')
                .parents('form').find(':submit').attr('disabled', true);

        currentPhotoContainer.find('img').remove();
        currentPhotoContainer.prepend( largeImg ).show();

        photoCommentSection.html('').append($.licemerov.loader);
        $.getJSON(url, function(data) {
            photoCommentSection.html('');
            for (var comment in data.photo_comments) {
                photoCommentSection.append(data.photo_comments[comment])
            }

            photoCommentForm.show().find('#photo_comment_photo_id').val(photoId);
        });

    });

    $('#new_photo_comment').bind('ajax:complete', function(event, xhr, status) {
        var $this = $(this),
                submit = $this.find(':submit'),
                params = $.parseJSON( xhr.responseText );

        if ( status == 'success') {
            $('#photo-comments').append(params.photo_comment);
        }

        setTimeout(function() {  $this.clearForm(); }, 10);
    });

    $('#photo_comment_body').live('keyup keydown', function() {
        var submit = $(this).parents('form').find(':submit'),
                length = this.value.length;

        submit.attr('disabled', !(length >= 1 && length < 1000));
    });

    $('.delete-photo-comment, .delete-profile-comment, .delete-root-comment')
            .live('ajax:complete', function() { $(this).parents('tr').
            fadeOut('fast', function() { $(this).remove() })
    });

    // Other related code moved to photos.js ( to be merged later )

    // Photos end


    // Main page (comments and stuff)

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
        var $cancel = $(this).hide(),
                $field = $cancel.prev(),
                $form = $(this).parents('form');
        $field.replaceWith($field.clone(true)).val('');

        // Stupid workaround
        if ( $form.attr('id') == 'edit_avatar' )
            $form.find(':submit').attr('disabled', true);
    });

    $('.delete-profile-response, .delete-root-response').live('ajax:complete', function() {
        $(this).parents('.response').fadeOut('fast', function() { $(this).remove(); })
    });
});


$.fn.delayedRemove = function() {
    return this.each(function() {
        var $this = $(this);
        setTimeout(function() {
            $this.remove();
        }, 5);
    });
};

$.fn.delayedClearForm = function() {
    return this.each(function() {
        setTimeout(function() { $(this).clearForm() }, 10 );
    })
};

$.fn.toggleLoader = function() {
    return this.each(function() {
        var $this = $(this),
                loadersCount = $('.loader').length,
                tag = $this[0].tagName.toLocaleLowerCase(),
                thisLoaderId = $this.data('loader');

        if (! this ) return;

        if ( thisLoaderId ) {
            // Remove loader (action completed)
            $('#' + thisLoaderId).remove();
            $this.data('loader', null);
            if ( tag == 'form' ) $this.find(':submit').show();
        } else { // Starting action, append loader
            thisLoaderId = 'loader-' + (loadersCount + 1);
            $this.
                    after("<img class='loader' id='" + thisLoaderId + "' src='/images/loader.gif' />").
                    data('loader', thisLoaderId);
            if ( tag == 'a' ) $this.hide();
            if ( tag == 'form' ) {
                $this.find(':submit').hide();
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
    if ( typeof $.licemerov.jcrop_api != 'undefined' ) {
        $.licemerov.jcrop_api.release();
        $('#release_jcrop').hide().parent('form').find(':submit').attr('disabled', 'disabled').
                parent('form').find('input[id^="crop"]').val('');
    }
}

$(document).ready(function() {
    $('#release_jcrop, #edit_avatar :file').click(function() {
        releaseJcrop();
    });
});

function updateCrop(coords) {
    if ($('#release_jcrop').not(':visible')) {
        $('#edit_avatar').clearForm().find(':submit').attr('disabled', false);
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
