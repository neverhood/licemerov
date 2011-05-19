
$('document').ready(function() {

    var photosApi = $.licemerov.photos = {
        sessionMeta : $('meta[name="_licemerov_session"]'),
        csrfToken : $('meta[name="csrf-token"]').attr('content'),
        albumId : $('div.album-container').attr('id'),
        uploader : $('#photo_photo'),
        commentSection : $('#photo-comments'),
        commentForm : $('#new-photo-comment-form')
    };

    if ( photosApi.sessionMeta.length ) {

        photosApi.sessionParam = photosApi.sessionMeta.attr('name');
        photosApi.sessionToken = photosApi.sessionMeta.attr('content');

        photosApi.uploadifySettings = {
            uploader : '/uploadify/uploadify.swf',
            cancelImg : '/uploadify/cancel.png',
            multi : true,
            auto : true,
            queueSizeLimit : 50,
            fileExt : '*.jpg;*.jpeg;*.gif;*.png',
            fileDesc    : 'Файлы изображений',
            sizeLimit : 4194304,
            script : '/photos',
            onComplete : function(event, queueID, fileObj, response) {
                // flash thing doesn't trigger ujs events. We must follow conventions no matter what!! :)
                $('#new_photo').trigger('ajax:complete', [{responseText:response}, 'success']);
            },
            onError : function() {return false},
            onQueueFull : function() {
                alert('Можно загружать до 50 фотографий одновременно');
                photosApi.uploader.uploadifyClearQueue();
                return false;
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

        photosApi.uploader.click(function(event) { event.preventDefault() }).
                uploadify(photosApi.uploadifySettings);


    }

    if ( location.hash.length ) {
      $.photo = {};
      var photoId = $.photo.id = location.hash.replace('#', ''),
          url = '/' + $.user.attributes.login + '/photos/' + photoId;

      $.getJSON(url, function(data) {
        $('#current-photo').prepend($('<img />').attr('src', data.photo)).
          show();
          $.each(data.photo_comments, function(index) {
              photosApi.commentSection.append(data.photo_comments[index])
          });
          if (data.photo_comments.length >= 10) {
            photosApi.commentSection.after("<div class='more-entries button' id='photo-show-more' data-page='1'>Ещё</div>");
          }

        photosApi.commentForm.show().find('#photo_comment_photo_id').val(photoId);
      });
    }



});
