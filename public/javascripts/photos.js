
$('document').ready(function() {

    var photosApi = $.licemerov.photos = {
        sessionMeta : $('meta[name="_licemerov_session"]'),
        csrfToken : $('meta[name="csrf-token"]').attr('content'),
        albumId : $('div.album-container').attr('id')
    };

    if ( photosApi.sessionMeta.length ) {

        photosApi.sessionParam = photosApi.sessionMeta.attr('name');
        photosApi.sessionToken = photosApi.sessionMeta.attr('content');

        photosApi.uploadifySettings = {
            uploader : '/uploadify/uploadify.swf',
            cancelImg : '/uploadify/cancel.png',
            multi : true,
            auto : true,
            script : '/photos',
            onComplete : function(event, queueID, fileObj, response) {
                // flash thing doesn't trigger ujs events. We must follow conventions no matter what!! :)
                $('#new_photo').trigger('ajax:complete', [{responseText:response}, 'success']);
            },
            scriptData : {
                '_http_accept': 'application/javascript',
                'format' : 'json',
                '_method': 'post',
                '_licemerov_session' : encodeURIComponent( photosApi.sessionToken ),
                'authenticity_token': encodeURI( encodeURIComponent(photosApi.csrfToken) ), // double penetration. that's evil ...
                'album_id': photosApi.albumId
            }
        };

        $('#photo_photo').click(function(event) { event.preventDefault() }).
                uploadify(photosApi.uploadifySettings);


        $('#photo_submit').click(function(event){
            event.preventDefault();
            $('#photo_photo').uploadifyUpload();
        });
    }

    if ( location.hash.length ) {
      var photoId = location.hash.replace('#', ''),
          url = '/' + $.user.attributes.login + '/photos/' + photoId;

      $.getJSON(url, function(data) {
        $('#current-photo').html($('<img></img>').attr('src', data.photo)).
          show()
      });
    };



});
