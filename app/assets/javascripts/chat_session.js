//= require pusher.min

var pusher;
var chat_csr_channel, chat_message_channel;
var chat_message_channels = [];
var chat_messages = [];

var present_users = [];

var presence_session;
var current_user;
var current_user_status = 'present';
var current_video_session_id;

function init_chat_session(current_user_name, current_user_id, current_user_type, opentok_api_key, presence_session_id, current_user_presence_token) {
  if (!current_user_id)
    return;

  current_user = {
    name: current_user_name,
    id: current_user_id
  };

  presence_session = OT.initSession(opentok_api_key, presence_session_id);
  
  presence_session.on("connectionCreated", function(event) {
    user = JSON.parse(event.connection.data);
    console.log('connected ' + event.connection.data);

    if (!present_users[user.id]) {
      present_users[user.id] = user;
      presence_session.signal({ type: 'request-client-status-' + user.id },
        function(error) {
          if (error) {
            alert(error.message);
          }
        }
      );
    }
    if ($('#chat_' + user.id).length == 0) {
      chat_prepare(user.id, current_user_id);      
      presence_session.on('signal:client-chat-message-from-' + user.id + '-to-' + current_user_id, function (event) {
        data = JSON.parse(event.data);
        d = $('#chat_' + data.user_id);
        d.find('.chat-messages').append('<div class="col-sm-12"><div class="chat-time">' + moment().format('MMMM D, YYYY, hh:mm a') + '</div></div>');
        d.find('.chat-messages').append('<div class="col-sm-12"><div class="chat-message-received">' + data.message + '</div></div>');
        d.show();
        d.find('.chat-messages-container').scrollTop(d.find('.chat-messages-container').prop('scrollHeight'));
        chat_messages[data.user_id] = { messages: d.find('.chat-messages').html(), display: true };
      });
    }
    notify_current_user_status(current_user_status, current_video_session_id);
  });
  
  presence_session.on("connectionDestroyed", function(event) {
    user = JSON.parse(event.connection.data);
    present_users[user.id] = null;
    console.log('disconnected ' + event.connection.data);
  });

  presence_session.connect(current_user_presence_token, function(error) {
  // If the connection is successful, initialize a publisher and publish to the session
    if (error) {
      alert(error.message);
    }
  });

  presence_session.on('signal:client-status', function (event) {
    data = JSON.parse(event.data);
    if (present_users[data.user_id]) {
      present_users[data.user_id].status = data.status; 
      present_users[data.user_id].video_session_id = data.video_session_id;  
    }
    console.log(present_users[data.user_id]);
  });

  presence_session.on('signal:request-client-status-' + current_user_id, function (event) {
    notify_current_user_status(current_user_status, current_video_session_id);
  });

  presence_session.on('signal:transfer-video-session-' + current_user_id, function (event) {
    data = JSON.parse(event.data);
    window.location.href = '/video_sessions/' + data.video_session_id;
  });

  presence_session.on('signal:wait-video-session-' + current_user_id, function (event) {
    $('#waiting-message h2').text("You've been placed on hold");    
  });
}

function notify_current_user_status(status, video_session_id) {
  current_user_status = status;
  current_video_session_id = video_session_id;  
  if (presence_session && presence_session.connection) {
    presence_session.signal({ type: 'client-status', data: JSON.stringify({user_id: current_user.id, status: current_user_status, video_session_id: current_video_session_id}) },
      function(error) {
        if (error) {
          alert(error.message);
        }
      }
    );    
  }
}

function transfer_video_session(doctor_id) {
  $.ajax({url: '/video_sessions/' + current_video_session_id + '/transfer?doctor_id=' + doctor_id, method: 'post', success: function(){
    presence_session.signal({ type: 'transfer-video-session-' + doctor_id, data: JSON.stringify({video_session_id: current_video_session_id}) },
      function(error) {
        if (error) {
          alert(error.message);
        } else {
          window.location.href = '/video_sessions';
        }
      }
    );    
  }});
}

function put_waiting_queue(user_id, video_session_id) {
  $.ajax({url: '/video_sessions/' + video_session_id + '/wait', method: 'post', success: function(){
    presence_session.signal({ type: 'wait-video-session-' + user_id, data: JSON.stringify({video_session_id: video_session_id}) },
      function(error) {
        if (error) {
          alert(error.message);
        } else {
          window.location.href = '/video_sessions';
        }
      }
    );    
  }});
}

function chat_prepare(user_id, current_user_id) {
  if ($('#chat_' + user_id).length == 0 && present_users[user_id]) {
    d = $('#chat_template').clone(true);
    d.attr('id', 'chat_' + user_id);
    d.appendTo($('#chat_template').parent());
    d.find('.chat-title').text(present_users[user_id].name);

    if (chat_messages[user_id]) {
      d.find('.chat-messages').append(chat_messages[user_id].messages);
      if (chat_messages[user_id].display) {
        d.show();
        d.find('.chat-messages-container').scrollTop(d.find('.chat-messages-container').prop('scrollHeight'));
      }
    }

    d.find('.chat-message').on('keypress', function (e) {
      d = $('#chat_' + user_id);
      if(e.keyCode == 13 && !e.shiftKey) {
        if ($(this).val()) {
          presence_session.signal({ type: 'client-chat-message-from-' + current_user_id + '-to-' + user_id, data: JSON.stringify({user_id: current_user_id, message: $(this).val()})},
            function(error) {
              if (error) {
                alert(error.message);
                d.hide();
              }
            }
          );
          d.find('.chat-messages').append('<div class="col-sm-12"><div class="chat-message-sent">' + $(this).val() + '</div></div>');
          d.find('.chat-messages-container').scrollTop(d.find('.chat-messages-container').prop('scrollHeight'));
          chat_messages[user_id] = { messages: d.find('.chat-messages').html(), display: true };
          $(this).val('');
        }
        return false;
      }
    });

    d.find('.chat-message').on( 'keyup', function (){
      $(this).css({ overflow: 'hidden' });
      $(this).height( 0 );
      $(this).height( $(this).prop('scrollHeight') );
      if (parseInt($(this).css('max-height')) <= $(this).prop('scrollHeight')) {
        $(this).css({ overflow: 'auto' });
      }
    });

    d.find('.chat-title-bar .close').on('click', function () {
      d = $('#chat_' + user_id);
      if (!confirm('Are you sure?')) return;
      chat_messages[user_id] = { messages: d.find('.chat-messages').html(), display: false };
      $(this).parent().parent().hide();
    });
  }
}

function set_chat_session_start_handler(){
  $('.start-chat-session').on('click', function() {
    if (!$('#video_session_symptom').val()) {
      alert("Symptom can't be blank");
      return;
    }
    present_csrs = $.grep(present_users, function(user) { return user && user.user_type == 'csr'; });
    if (present_csrs.length == 0) {
      alert("CSR will be available soon");
    } else {
      csr_user = present_csrs[Math.floor(Math.random() * present_csrs.length)];
      d = $('#chat_' + csr_user.id);
      d.find('.chat-message').val($('#video_session_symptom').val());
      $('#video_session_symptom').val('');
      var e = jQuery.Event('keypress');
      e.keyCode = 13;
      d.find('.chat-message').trigger(e);
      d.show();      
    }
  });

  $.each(present_users, function(user_id, present_user) {
    if (present_user) {
      chat_prepare(user_id, current_user.id);  
    }    
  });

  $('.start-online-visit').on('click', function() {
    online_csrs = $.grep(present_users, function(user) { return user && user.user_type == 'csr' && user.status == 'online'; });
    if (online_csrs.length == 0) {
      return true;
    } else {
      csr_user = online_csrs[Math.floor(Math.random() * online_csrs.length)];
      window.location.href = "/video_sessions/" + csr_user.video_session_id;
      return false;
    }
  });
}

$(window).on('page:load', set_chat_session_start_handler);
$(document).ready(set_chat_session_start_handler);

