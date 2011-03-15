// Autocomplete user logins when sending the message
// if user has less then 100 friends then div#friends-json is populated with friends data which is then used for auto completion
// if user has more then 100 friends then request is sent to server and awaits for json in response

var eql = function(elem1, elem2) {
  if (elem1.length === elem2.length && elem1.length === $(elem1).filter(elem2).length) {
    return true
  } else { return false };
};

function buildElem(value) {
  return $('<span class="token">' + value +
      '<strong class="remove-token">X </strong></span>' )
}


$(document).ready(function() {

    $('.remove-token').live('click', function() {
      var f = $('#message_recipient');
      var newWidth = f.width() + $(this).parent().outerWidth(true) + 10;
      if (newWidth > 340) newWidth = 340;
      f.width(newWidth);
      $(this).parent().remove();
    });

    if ( $('#friends-json').length ) {
        $('#message_recipient').autocomplete({
            minLength: 1,
            source: $.licemerov.user.friends,
            focus: function(event, ui) {
           //     $('#message_recipient').val(ui.item.value);
                return false;
            },
            select: function( event, ui) {
                //$('#message_recipient').val(ui.item.value);
                // $('#please-avatar').val(ui.item.avatar);
                var elem = buildElem(ui.item.value).hide();
                var textbox = $('#message_recipient');
                $('body').append(elem);
                var newWidth = ( textbox.width() - elem.outerWidth(true) - 5 );
                if (newWidth > 35) {
                  textbox.css({width:newWidth + 'px'});
                  textbox.before(elem.show());
                } else {
                  if ( elem.width() < 35 ) {
                    textbox.before(elem.show());
                    textbox.css({width:'335px'});
                  } else {
                    textbox.css({width:'335px'});
                    newWidth = ( textbox.width() - elem.outerWidth(true) - 5);
                    textbox.css({width:newWidth + 'px'});
                    textbox.before(elem.show());
                  }
                }

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
