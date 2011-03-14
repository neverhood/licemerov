// Autocomplete user logins when sending the message
// if user has less then 100 friends then div#friends-json is populated with friends data which is then used for auto completion
// if user has more then 100 friends then request is sent to server and awaits for json in response



$(document).ready(function() {
    if ( $('#friends-json').length ) {
        $('#message_recipient').autocomplete({
            minLength: 1,
            source: $.licemerov.user.friends,
            focus: function(event, ui) {
                $('#message_recipient').val(ui.item.value);
                return false;
            },
            select: function( event, ui) {
                $('#message_recipient').val(ui.item.value);
                // $('#please-avatar').val(ui.item.avatar);
                return false
            }
        }).
                data('autocomplete')._renderItem = function( ul, item ) {
            return $('<li></li>').data('item.autocomplete', item).
                    append('<a>' + item.value + '</a>').
                    appendTo(ul);
        };
    } else {
        var cache = {},
                lastXhr;
        $( "#message_recipient" ).autocomplete({
            minLength: 2,
            source: function( request, response ) {
                var term = request.term;
                if ( term in cache ) {
                    response( cache[term] );
                    return;
                }
                lastXhr = $.getJSON( "/messages/new", request, function( data, status, xhr ) {
                    cache[ term ] = data;
                    if ( xhr === lastXhr ) {
                        response( data );
                    }
                });
            }
        });
    }
});