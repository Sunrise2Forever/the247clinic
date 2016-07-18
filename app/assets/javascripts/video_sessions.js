
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
      if (current_user_status == 'online') {
        notify_current_user_status('busy', video_session_id);  
      }      
    }
  });

  session.on('sessionDisconnected', function(event) {
    setMessage('You', '<em>Disconnected</em>');
    notify_current_user_status('present', null);
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

      notify_current_user_status('online', video_session_id);
    } else {
      $('#waiting-message h2').text(error.message);
    }
    $('#waiting-message').show();
  });

  session.on('signal:client-finish-video-session', function (event) {
    if (event.data != currentUser.id) {
      if (is_csr) {
        window.location.href = '/video_sessions';
      } else {
        if (currentUser.id == video_session_user_id) {
          window.location.href = "/video_sessions/" + video_session_id + "/edit/feedback";
        } else {
          //window.location.href = "/video_sessions/" + video_session_id + "/edit/notes";
        }        
      }
    }
  });

  session.on('signal:peerDisconnected', function (event) {
    if (event.data == peer_user_id) {
      setMessage(peer_user_name, '<em>Disconnected</em>');
      if (is_csr || currentUser.id != video_session_user_id) {
        $('#waiting-message h2').text('Waiting for Patient');
      } else {
        $('#waiting-message h2').text('Waiting for Doctor');
      }

      $('#waiting-message').show();
      subscriber = null;
      peer_user_id = null;
      peer_user_name = null;

      if (current_user_status == 'busy') {
        notify_current_user_status('online', video_session_id);
      }
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
    if (confirm('Are you sure?')) {
      session.signal({ type: 'client-finish-video-session', data: currentUser.id });  
    } else {
      return false;
    }    
  });

  $('#end_session').click(function (e) {
    $('#finish_video_session').trigger('click');
  });

  $('#sign_off').click(function (e) {
    $.ajax({
      type: "PATCH",
      url: '/video_sessions/' + video_session_id + '/update/sign_off'
    }).done(function (data) {
      $('#sign_off').attr('disabled', true);
    }).fail(function(error) {
    });
  });

  $('#save_exit').click(function (e) {
    if (confirm('Are you sure?')) {
      $.ajax({
        type: "PATCH",
        url: '/video_sessions/' + video_session_id + '/update/save',
        data: {
          video_session: { 
            notes: $('#video_session_notes').val(), 
            diagnosis: $('#video_session_diagnosis').val()
          }
        }
      }).done(function (data) {
        close_video_session();
        notify_current_user_status('present', null);
        window.location.href = '/video_sessions';
      }).fail(function(error) {
      });
    }
  });

  $('#video_session_notes').wysihtml5({toolbar: false});

  $('#export_print').click(function (e) {
    $.ajax({
      type: "PATCH",
      url: '/video_sessions/' + video_session_id + '/update/save',
      data: {
        video_session: { 
          notes: $('#video_session_notes').val(), 
          diagnosis: $('#video_session_diagnosis').val()
        }
      }
    }).done(function (data) {
      window.location.href = '/video_sessions/' + video_session_id + '/export.pdf';
    }).fail(function(error) {
    });
  });

  $('#export_file').click(function (e) {
    $.ajax({
      type: "PATCH",
      url: '/video_sessions/' + video_session_id + '/update/save',
      data: {
        video_session: { 
          notes: $('#video_session_notes').val(), 
          diagnosis: $('#video_session_diagnosis').val()
        }
      }
    }).done(function (data) {
      window.location.href = '/video_sessions/' + video_session_id + '/export.rtf';
    }).fail(function(error) {
    });
  });

  $('#video_session_diagnosis').on('keypress', function (e) {
    if(e.keyCode == 13 && $(this).val()) {
      $.ajax({
        type: "PATCH",
        url: '/video_sessions/' + video_session_id + '/update/add_diagnosis',
        data: {
          video_session: { 
            diagnosis: $(this).val()
          }
        }
      }).done(function (data) {
        $('#video_session_diagnosis').val('');
        $('.video-session-diagnosis').html(data.video_session.diagnosis);
      }).fail(function(error) {
      });
    }
  });

  if (!is_csr && currentUser.id == video_session_user_id) {
    window.addEventListener('beforeunload', function(e) {
      if (e.target.location.pathname == '/video_sessions/' + video_session_id) {
        $.ajax({ type: "POST", url: '/video_sessions/' + video_session_id + '/call_backs', success: function() {}, dataType: 'json' });
      }
      notify_current_user_status('present', null);
    }, false);

    $('a').on('click', function() {
      close_video_session();
      $.ajax({ type: "POST", url: '/video_sessions/' + video_session_id + '/call_backs', success: function() {}, dataType: 'json' });
      notify_current_user_status('present', null);
    });
  } else {
    $('a').on('click', function() {
      close_video_session();
      notify_current_user_status('present', null);
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

  $('.btn-transfer-video-session-to-doctor').click(function (e) {
    $('.present-doctors').html('');
    $.each(present_users, function(index, user) {
      if (user && user.user_type == 'doctor' && user.status == 'present') {
        $('.present-doctors').append('<option value="' + user.id + '">' + user.name + '</option');
      }
    })
  });

  $('.btn-chat').click(function (e) {
    if (!$('.present-doctors').val()) {
      alert('Please select a doctor');
    } else {
      d = $('#chat_' + $('.present-doctors').val());
      d.show();
    }    
  });

  $('.btn-transfer').click(function (e) {
    if (!$('.present-doctors').val()) {
      alert('Please select a doctor');
    } else {
      if (confirm('Are you sure?')) {
        transfer_video_session($('.present-doctors').val());  
      }      
    }    
  });

  $('.btn-put-wating').click(function (e) {
    if (peer_user_id) {
      close_video_session();
      notify_current_user_status('present', null);
      put_waiting_queue(peer_user_id, video_session_id);
    }
  });
}

