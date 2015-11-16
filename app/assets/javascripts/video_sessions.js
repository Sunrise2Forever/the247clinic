//= require pusher
//= require simplepeer
//= require hark

// not a real GUID, but it will do
// http://stackoverflow.com/questions/105034/how-to-create-a-guid-uuid-in-javascript
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

navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia;

var mediaOptions = {
  audio: true,
  video: {
    mandatory: {
      minWidth: 1280,
      minHeight: 720
    }
  }
};

function init_video_session(id, name) {

  var $messages = $('#messages');

  var currentUser = {
    name: name,
    id: id,
    stream: undefined
  };

  navigator.getUserMedia(mediaOptions, function(stream) {
    currentUser.stream = stream;
    var video = $('#localVideo')[0];
    video.src = window.URL.createObjectURL(stream);

    start();
  }, function() {});


  function start() {
    var pusher = new Pusher($('#chat').data().apiKey, {
      authEndpoint: '/pusher/auth',
      auth: {
        params: currentUser
      }
    });

    var channel = pusher.subscribe('presence-chat');
    var peers = {};

    function lookForPeers() {
      for (var userId in channel.members.members) {
        if (userId != currentUser.id) {
          var member = channel.members.members[userId];

          peers[userId] = initiateConnection(userId, member.name)
        }
      }
    }

    channel.bind('pusher:subscription_succeeded', lookForPeers);

    function gotRemoteVideo(userId, userName, stream) {
      var video = $("<video autoplay data-user-id='" + userId + "'/>");
      video[0].src = window.URL.createObjectURL(stream);
      $('#remoteVideos').append(video);

      var preview = $("<li data-user-id='" + userId + "'>");
      preview.append("<video autoplay/>");
      preview.append("<div class='name'>" + userName + "</div></li>")
      preview.find('video')[0].src = window.URL.createObjectURL(stream);

      $('#allVideos').append(preview);
    }

    function appendMessage(name, message) {
      $messages.append('<dt>' + name + '</dt>');
      $messages.append('<dd>' + message + '</dd>');
    }

    function close(userId, name) {
      var peer = peers[userId];
      if (peer) {
        peer.destroy();
        peers[userId] = undefined;
      }
      $("[data-user-id='" + userId + "']").remove();
      appendMessage(name, '<em>Disconnected</em>');
    }

    function setupPeer(peerUserId, peerUserName, initiator) {
      var peer = new SimplePeer({ initiator: initiator, stream: currentUser.stream, trickle: false });

      peer.on('signal', function (data) {
        channel.trigger('client-signal-' + peerUserId, {
          userId: currentUser.id, userName: currentUser.name, data: data
        });
      });

      peer.on('stream', function(stream) { gotRemoteVideo(peerUserId, peerUserName, stream) });
      peer.on('close', function() { close(peerUserId, peerUserName) });
      $(window).on('beforeunload', function() { close(peerUserId, peerUserName) });

      peer.on('message', function (data) {
        if (data == '__SPEAKING__') {
          $('#remoteVideos video').hide();
          $("#remoteVideos video[data-user-id='" + peerUserId + "']").show();
        } else {
          appendMessage(peerUserName, data);
        }
      });

      return peer;
    }

    function initiateConnection(peerUserId, peerUserName) {
      return setupPeer(peerUserId, peerUserName, true);
    };

    channel.bind('client-signal-' + currentUser.id, function(signal) {
      var peer = peers[signal.userId];

      if (peer === undefined) {
        peer = setupPeer(signal.userId, signal.userName, false);
      }

      peer.on('ready', function() {
        appendMessage(signal.userName, '<em>Connected</em>');
      });
      peer.signal(signal.data)
    });

    var speech = hark(currentUser.stream);

    speech.on('speaking', function() {
      for (var userId in peers) {
        var peer = peers[userId];
        peer.send('__SPEAKING__');
      }
    });

    $('#send-message').submit(function(e) {
      e.preventDefault();
      var $input = $(this).find('input'),
          message = $input.val();

      $input.val('');

      for (var userId in peers) {
        var peer = peers[userId];
        peer.send(message);
      }
      appendMessage(currentUser.name, message);
    });
  }
}

