//= require pusher.min
//= require simplewebrtc.bundle
/*
// not a real GUID, but it will do
var guid = (function() {
  function s4() {
    return Math.floor((1 + Math.random()) * 0x10000)
        .toString(16)
        .substring(1);
  }
  return function() {
    return s4() + s4() + '-' + s4() + '-' + s4() + '-' +
        s4() + '-' + s4() + s4() + s4();
  };
})();

var channel;
var webrtc;

function init_video_session(current_user_id, current_user_name, video_session_id, video_session_user_id) {
  var $messages = $('#messages');
  var $mute_video_stream = false;

  var currentUser = {
    name: current_user_name,
    id: current_user_id,
    stream: undefined
  };

  $('#waiting-message h2').text('Initializing ...');
  $('#waiting-message').show();

  var peer_user_name = '';
  var peer_user_id = '';

  var pusher = new Pusher($('#chat').data().apiKey, {
    authEndpoint: '/pusher/auth',
    auth: {
      params: currentUser
    }
  });

  channel = pusher.subscribe('presence-chat-' + video_session_id);

  function lookForPeers() {
    for (var userId in channel.members.members) {
      if (userId != currentUser.id) {
        peer_user_name = channel.members.members[userId].name;
        peer_user_id = userId;
      }
    }
    start();
  }

  channel.bind('pusher:subscription_succeeded', lookForPeers);

  function start() {
    // create our webrtc connection
    webrtc = new SimpleWebRTC({
      // the id/element dom element that will hold "our" video
      localVideoEl: 'localVideo',
      // the id/element dom element that will hold remote videos
      remoteVideosEl: '',
      // immediately ask for camera access
      autoRequestMedia: true,
      debug: false,
      detectSpeakingEvents: true,
      autoAdjustMic: false
    });

    // when it's ready, join if we got a room from the URL
    webrtc.on('readyToCall', function () {
      // you can name it anything
      webrtc.joinRoom('the247clinic-video' + video_session_id);

      if (currentUser.id == video_session_user_id) {
        $('#waiting-message h2').text('Waiting for Doctor');
      } else {
        $('#waiting-message h2').text('Waiting for Patient');
      }
      $('#waiting-message').show();
    });

    webrtc.on('videoAdded', function (video, peer) {
      console.log('video added', peer);
      var remotes = document.getElementById('remoteVideos');
      if (remotes) {
        var d = document.createElement('div');
        d.className = 'videoContainer';
        d.id = 'container_' + webrtc.getDomId(peer);
        d.appendChild(video);
        remotes.appendChild(d);
      }

      $('#waiting-message').hide();
      appendMessage(peer_user_name, '<em>Connected</em>');
    });

    webrtc.on('mute', function(data){
      if ($('#remoteVideos video').length > 0)
        $('#remoteVideos video')[0].pause();
    })
    webrtc.on('unmute', function(data){
      if ($('#remoteVideos video').length > 0)
        $('#remoteVideos video')[0].play();
    })

    webrtc.on('videoRemoved', function (video, peer) {
      console.log('video removed ', peer);
      var remotes = document.getElementById('remoteVideos');
      var el = document.getElementById('container_' + webrtc.getDomId(peer));
      if (remotes && el) {
        remotes.removeChild(el);
      }

      appendMessage(peer_user_name, '<em>Disconnected</em>');
      if (currentUser.id == video_session_user_id) {
        $('#waiting-message h2').text('Waiting for Doctor');
      } else {
        $('#waiting-message h2').text('Waiting for Patient');
      }
      $('#waiting-message').show();
    });

    function appendMessage(name, message) {
      $messages.show();
      $messages.append('<dt>' + name + '</dt>');
      $messages.append('<dd>' + message + '</dd>');
    }

    function close() {
      $("#remoteVideos video").remove();
    }

    channel.bind('pusher:member_added', function (member) {
      peer_user_name = member.info.name;
      peer_user_id = member.id;
    });

    channel.bind('client-signal-' + video_session_id, function (signal) {
    });

    channel.bind('client-finish-video-session-' + currentUser.id, function (data) {
      if (currentUser.id == video_session_user_id) {
        window.location.href = "/video_sessions/" + video_session_id + "/edit/feedback";
      } else {
        window.location.href = "/video_sessions/" + video_session_id + "/edit/notes";
      }
    });

    $('#mute_video_stream').click(function (e) {
      if ($('#remoteVideos video').length > 0) {
        $mute_video_stream = !$mute_video_stream;
        if ($mute_video_stream) {
          $('#remoteVideos video')[0].pause();
          $('#localVideo')[0].pause();
          webrtc.mute();
        } else {
          $('#remoteVideos video')[0].play();
          $('#localVideo')[0].play();
          webrtc.unmute();
        }
      }
    });

    var fileInput    = $("input:file");
    var form         = $('.directUpload');
    var submitButton = $('input[type="submit"]');
    var progressBar  = $("<div class='bar'></div>");
    var barContainer = $("<div class='progress'></div>").append(progressBar);
    fileInput.after(barContainer);
    var photo_count = 0;


    $('#take_photo').click(function (e) {
      if ($('#remoteVideos video').length > 0) {
        var d = $('canvas')[0];
        //document.getElementById('taken_photos').appendChild(d);

        d.width = $('#remoteVideos video').innerWidth();
        d.height = $('#remoteVideos video').innerHeight();
        d.getContext('2d').drawImage($('#remoteVideos video')[0],
            0, 0, $('#remoteVideos video')[0].videoWidth, $('#remoteVideos video')[0].videoHeight,
            0, 0, d.width, d.height
        );
        d.style.display='none';

        var e = document.createElement('img');
        document.getElementById('taken_photos').appendChild(e);
        e.src = d.toDataURL('image/png');

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
      channel.trigger('client-finish-video-session-' + peer_user_id, {
        userId: currentUser.id
      });
    });

    if (currentUser.id == video_session_user_id) {
      window.addEventListener('beforeunload', function(e) {
        if (e.target.location.pathname == '/video_sessions/' + video_session_id) {
          $.ajax({ type: "POST", url: '/video_sessions/' + video_session_id + '/call_backs', success: function() {}, dataType: 'json' });
        }
      }, false);

      $('a').on('click', function() {
        if (webrtc) {
          webrtc.leaveRoom();
        }
        $.ajax({ type: "POST", url: '/video_sessions/' + video_session_id + '/call_backs', success: function() {}, dataType: 'json' });
      });
    } else {
      $('a').on('click', function() {
        if (webrtc) {
          webrtc.leaveRoom();
        }
      });
    }

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

*/