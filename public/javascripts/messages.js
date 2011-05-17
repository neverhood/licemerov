// Autocomplete user logins when sending the message
// if user has less then 100 friends then div#friends-json is populated with friends data which is then used for auto completion
// if user has more then 100 friends then request is sent to server and awaits for json in response


function buildElem(item) {
    return $('<div class="token" id="' + item.value + '"><span class="v">'
            + item.value + '</span><span class="remove-token"></span></div>')
            .data({
                      'avatarUrl': item.avatar,
                      'value': item.value,
                      'name': item.name,
                      'id': item.id,
                      'index': item.index
                  });
}


function appendAvatar(avatar_url) {
    $('#avatar').html('<img src="' + avatar_url + '" />');
}



$(document).ready(function() {

    var autocompleteType = $.licemerov.user.friends.length > 0 ? 'local' : 'remote',
            inputField = $('#users-select'),
            submitButton = $('#message_submit'),
            messageBody = $('#message_body'),
            messageForm = $('form#new-message').bind('submit', function() {
              $(this).find(':submit').after($.licemerov.loader).remove();
            });



    $('.token').live({
        click: function() {
            var $this = $(this);
            if (! $this.hasClass('token-focused'))
                focusToken($this);
        },
        mouseenter: function() {
            if ( $(this).data('avatarUrl') )
                appendAvatar($(this).data('avatarUrl'));
        },
        mouseleave: function() {
            var tokens = $('.token'),
                    focusedToken = $('.token-focused')[0];
            if (focusedToken) {
                appendAvatar( $( focusedToken ).data('avatarUrl') )
            } else {
                appendAvatar( $( tokens[0] ).data('avatarUrl') );
            }
        }
    });

    $('.remove-token').live('click', function(event) {
        event.stopPropagation();
        removeToken($(this).parent());
    });

    inputField.keydown(function(event) {
        var keyCode = (event.keyCode ? event.keyCode : event.which),
                tokens = $('.token'),
                lastToken = tokens[tokens.length - 1];
        if (keyCode == 8 && this.value.length == 0 && (typeof lastToken != 'undefined')) {
            lastToken = $(lastToken);
            if (lastToken.hasClass('token-focused')) {
                removeToken(lastToken);
            } else {
                focusToken(lastToken);
            }
        }
    }).click(function() {
        $(this).autocomplete('search', '');
    }).blur(function() {
        this.value = '';
        if ( $('.token').length == 0 )
          appendAvatar('/avatars/thumb/missing.png');
    });

    messageBody.keyup(function() {
        submitButton.attr('disabled',
                !( $('.token').length > 0 && (this.value.length >= 1 && this.value.length <= 1000) ));
    });

    //  IE refuses to obey to 'submit' event ( stupid fuck )

    var handleMessageSubmit = function() {
        var input = $('#message_recipients'),
                tokens = [];
        $.each($('.token'), function() {
            tokens.push( $(this).data('id') )
        });
        input.val( tokens.join(',') );
    };

    if ( $.browser.msie ) // I hate you!
        submitButton.click(handleMessageSubmit);
    else
        messageForm.submit(handleMessageSubmit);


    var tempToken = $('<div class="token"></div>')
            .appendTo('body');
    var minWidth = parseInt($(tempToken).css('min-width'));
    tempToken.remove();

    var     container = inputField.parent(),
            containerRightPos = function() {
                return (container.offset().left + container.width());
            },
            origWidth = inputField.width(),
            margin = inputField
                    .clone(true)
                    .hide()
                    .appendTo('body').outerWidth() - origWidth,
            calcOffset = function() {
                var items = container.children('.token'),
                        lastItem = $(items[items.length - 1]),
                        lastItemRightPos = lastItem[0]?
                                (lastItem.offset().left + lastItem.width()) : (inputField.offset().left + margin);
                return ( containerRightPos() - lastItemRightPos  );
            },
            removeToken = function(token) {
                var currentSource = inputField.autocomplete('option', 'source');

                if (autocompleteType == 'local') {
                    currentSource.push( {
                        'avatar': token.data('avatarUrl'),
                        'name': token.data('name'),
                        'value': token.data('value'),
                        'id': token.data('id')} );
                }

                inputField.autocomplete('option', 'source', currentSource);

                token.remove();

                var tokens = $('.token');

                if (tokens.length == 0) {
                    appendAvatar('/avatars/thumb/missing.png');
                    submitButton.attr('disabled', true);
                }
                else
                    appendAvatar($(tokens[0]).data('avatarUrl'));

                var currentOffset = calcOffset();
                if ( currentOffset < minWidth ) {
                    inputField.width(origWidth);
                } else {
                    inputField.width(currentOffset - margin);
                }
            },
            findIndexByValue = function(value) {
                var tokens = inputField.autocomplete('option', 'source'),
                        iterator = tokens.length;

                while(iterator--) {
                    if ( tokens[iterator].value == value ) {
                        return iterator;
                    }
                }

                return -1;
            },
            focusToken = function(token) {
                $('.token-focused').removeClass('token-focused');
                appendAvatar(token.data('avatarUrl'));
                token.addClass('token-focused');
            };

    var autocompleteOnSelect = function( event, ui) {
        var tokens = $('.token');

        $('.token-focused').removeClass('token-focused');

        if ( autocompleteType == 'local'  ) {
            var currentSource = inputField.autocomplete('option', 'source'),
                    i = findIndexByValue(ui.item.value);
            currentSource.splice(i, 1);
            inputField.autocomplete('option', 'source', currentSource);
        }

        if (  tokens.length >= 15 )
            return false;


        var elem = buildElem(ui.item)
                .hide()
                .appendTo('body'),
                elemWidth = elem.outerWidth(true),
                currentOffset = calcOffset();

        tokens.push(elem[0]);

        appendAvatar( $(tokens[0]).data('avatarUrl') );

        if ((currentOffset) >= elemWidth) {
            if ( (currentOffset - elemWidth) > minWidth ) {
                inputField.before( elem.show() )
                        .width( currentOffset - elemWidth - margin  );
            } else {
                inputField.before( elem.show() )
                        .width( origWidth );
            }
        } else {
            inputField.before( elem.show() )
                    .width( calcOffset() - margin );
        }
        inputField.val('');
        if ( messageBody.val().length >= 1 && messageBody.val().length <= 1000 ) submitButton.attr('disabled', false);
        return false
    };

    if (autocompleteType == 'local') {
        inputField.autocomplete({
            minLength: 1,
            source: $.licemerov.user.friends,
            focus: function(event, ui) {
                appendAvatar(ui.item.avatar);
                return false;
            },

            select: autocompleteOnSelect
        }).
                data('autocomplete')._renderItem = function( ul, item ) {

            return $('<li></li>').data('item.autocomplete', item)
                    .append('<a class="autocompletion-item">' + item.value + '<div>' + item.name + '</div>' + '</a>')
                    .appendTo(ul);

        }
    } else {
        var cache = {},
                collectTokens = function() {
                    var tokens = [];
                    $.each($('.token'), function() {
                        tokens.push($(this).data('value'))
                    });
                    return tokens;
                },
                lastXhr;
        inputField.autocomplete({
            minLength: 2,
            source: function( request, response ) {
                var term = request.term,
                        data = [];
                if ( term in cache ) {
                    var tokens = collectTokens();
                    $.each(cache[term], function(i) {
                        if (!tokens.inArray(cache[term][i].value))
                            data.push(cache[term][i]);
                    });
                    response( data );
                    return;
                }
                lastXhr = $.getJSON( $.licemerov.user.login + "/new_message", request, function( data, status, xhr ) {
                    cache[ term ] = data;
                    if ( xhr === lastXhr ) {
                        var tokens = collectTokens();
                        var newData = [];
                        $.each(data, function(i) {
                            if (! tokens.inArray(data[i].value) )
                                newData.push(data[i]);
                        });
                        response( newData );
                    }
                });
            },
            select: autocompleteOnSelect,
            focus: function(event, ui) {
                appendAvatar(ui.item.avatar);
                return false;
            }
        });
    }
});
