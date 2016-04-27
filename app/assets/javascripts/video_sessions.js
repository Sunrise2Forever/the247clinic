
var channel;
var webrtc;

function init_video_session(current_user_id, current_user_name, video_session_id, video_session_user_id, opentok_api_key, opentok_session_id, opentok_token, is_csr) {
  var $messages = $('#messages');
  var $play_video_stream = true;

  var currentUser = {
    name: current_user_name,
    id: current_user_id,
    stream: undefined
  };

  $('#waiting-message h2').text('Initializing ...');
  $('#waiting-message').show();

  var peer_user_name = '';
  var peer_user_id = '';
  var publisher, subscriber;

  var session = OT.initSession(opentok_api_key, opentok_session_id);

  // Subscribe to a newly created stream
  session.on('streamCreated', function(event) {
    subscriber = session.subscribe(event.stream, 'remoteVideoContainer', {
      insertMode: 'append',
      width: '100%',
      height: '100%',
      showControls: false,
      style: {
        buttonDisplayMode: 'off'
      }
    });
  });

  session.on('signal:peerConnected', function(event) {
    var user = JSON.parse(event.data);
    if (user.id != currentUser.id) {
      $('#waiting-message').hide();
      if (peer_user_id != user.id) {
        session.signal({ type: 'peerConnected', data: JSON.stringify(currentUser)});
      }
      peer_user_id = user.id;
      peer_user_name = user.name;
      setMessage(peer_user_name, '<em>Connected</em>');
    }
  });

  session.on('sessionDisconnected', function(event) {
    setMessage('You', '<em>Disconnected</em>');
    console.log('You were disconnected from the session.', event.reason);
  });

  // Connect to the session
  session.connect(opentok_token, function(error) {
    // If the connection is successful, initialize a publisher and publish to the session
    if (!error) {
      publisher = OT.initPublisher('localVideoContainer', {
        insertMode: 'append',
        width: '100%',
        height: '100%',
        showControls: false
      });
      session.publish(publisher, null, function(err) {
        if (err) {
          publisher = null;
        }
      });
      session.signal({ type: 'peerConnected', data: JSON.stringify(currentUser)});

      if (is_csr || currentUser.id != video_session_user_id) {
        $('#waiting-message h2').text('Waiting for Patient');
      } else {
        $('#waiting-message h2').text('Waiting for Doctor');
      }
    } else {
      $('#waiting-message h2').text(error.message);
    }
    $('#waiting-message').show();
  });

  session.on('signal:client-finish-video-session', function (event) {
    if (event.data != currentUser.id) {
      if (currentUser.id == video_session_user_id) {
        window.location.href = "/video_sessions/" + video_session_id + "/edit/feedback";
      } else {
        window.location.href = "/video_sessions/" + video_session_id + "/edit/notes";
      }
    }
  });

  session.on('signal:peerDisconnected', function (event) {
    if (event.data == peer_user_id) {
      setMessage(peer_user_name, '<em>Disconnected</em>');
      if (currentUser.id == video_session_user_id) {
        $('#waiting-message h2').text('Waiting for Doctor');
      } else {
        $('#waiting-message h2').text('Waiting for Patient');
      }
      $('#waiting-message').show();
      subscriber = null;
      peer_user_id = null;
      peer_user_name = null;
    }
  });

  function close_video_session() {
    publisher = null;
    session.signal({ type: 'peerDisconnected', data: currentUser.id }, function() {
      session.disconnect();
    });
  }

  $('#play_video_stream').click(function (e) {
    $play_video_stream = !$play_video_stream;
    if (publisher) {
      publisher.publishVideo($play_video_stream);
      publisher.publishAudio($play_video_stream);
    }
    if (subscriber) {
      subscriber.subscribeToVideo($play_video_stream);
      subscriber.subscribeToAudio($play_video_stream);
    }
  });

  function setMessage(name, message) {
    $messages.show();
    $messages.html('');
    $messages.append('<dt>' + name + '</dt>');
    $messages.append('<dd>' + message + '</dd>');
  }

  var fileInput    = $("input:file");
  var form         = $('.directUpload');
  var submitButton = $('input[type="submit"]');
  var progressBar  = $("<div class='bar'></div>");
  var barContainer = $("<div class='progress'></div>").append(progressBar);
  fileInput.after(barContainer);
  var photo_count = 0;


  $('#take_photo').click(function (e) {
    if (subscriber) {
      var imgData = subscriber.getImgData();

      var e = document.createElement('img');
      document.getElementById('taken_photos').appendChild(e);
      e.setAttribute("src", "data:image/png;base64," + imgData);

      var blob = dataURItoBlob(e.src);
      blob.name = 'photo_' + video_session_id + '_' + photo_count + '.png';
      photo_count ++;

      fileInput.fileupload({
        url:             form.data('url'),
        type:            'POST',
        autoUpload:       true,
        formData:         form.data('form-data'),
        paramName:        'file',
        dataType:         'XML',  // S3 returns XML if success_action_status is set to 201
        replaceFileInput: false,
        progressall: function (e, data) {
          var progress = parseInt(data.loaded / data.total * 100, 10);
          progressBar.css('width', progress + '%')
        },
        start: function (e) {
          submitButton.prop('disabled', true);

          progressBar.
              css('background', 'green').
              css('display', 'block').
              css('width', '0%').
              text("Loading...");
        },
        done: function(e, data) {
          submitButton.prop('disabled', false);
          progressBar.text("Uploading done");

          // extract key and generate URL from response
          var key   = $(data.jqXHR.responseXML).find("Key").text();
          var url   = '//' + form.data('host') + '/' + key;

          // create hidden field
          $.ajax({
            type: "POST",
            url: '/photos',
            data: { video_session_id: video_session_id, photo_url: url },
            success: function() {},
            dataType: 'json'
          });
        },
        fail: function(e, data) {
          submitButton.prop('disabled', false);

          progressBar.
              css("background", "red").
              text("Failed");
        }
      });
      fileInput.fileupload('add', { files: [blob] });
    }
  });

  $('#finish_video_session').click(function (e) {
    session.signal({ type: 'client-finish-video-session', data: currentUser.id });
  });

  if (currentUser.id == video_session_user_id) {
    window.addEventListener('beforeunload', function(e) {
      if (e.target.location.pathname == '/video_sessions/' + video_session_id) {
        $.ajax({ type: "POST", url: '/video_sessions/' + video_session_id + '/call_backs', success: function() {}, dataType: 'json' });
      }
    }, false);

    $('a').on('click', function() {
      close_video_session();
      $.ajax({ type: "POST", url: '/video_sessions/' + video_session_id + '/call_backs', success: function() {}, dataType: 'json' });
    });
  } else {
    $('a').on('click', function() {
      close_video_session();
    });
  }

  function dataURItoBlob(dataURI) {
    // convert base64/URLEncoded data component to raw binary data held in a string
    var byteString;
    if (dataURI.split(',')[0].indexOf('base64') >= 0)
      byteString = atob(dataURI.split(',')[1]);
    else
      byteString = unescape(dataURI.split(',')[1]);

    // separate out the mime component
    var mimeString = dataURI.split(',')[0].split(':')[1].split(';')[0];

    // write the bytes of the string to a typed array
    var ia = new Uint8Array(byteString.length);
    for (var i = 0; i < byteString.length; i++) {
      ia[i] = byteString.charCodeAt(i);
    }

    return new Blob([ia], {type:mimeString});
  }
}

