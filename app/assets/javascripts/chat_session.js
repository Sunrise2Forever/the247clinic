//= require pusher.min

var pusher;
var chat_csr_channel, chat_message_channel;
var chat_message_channels = [];
var chat_messages = [];

var present_users = [];

var presence_session;
var current_user;

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
    present_users[user.id] = user;
    console.log('connected ' + event.connection.data);

    presence_session.on('signal:client-chat-message-from-' + user.id + '-to-' + current_user_id, function (event) {
      message = JSON.parse(event.data);
      d = $('#chat_' + message.user_id);
      d.find('.chat-messages').append('<div class="col-sm-12"><div class="chat-time">' + moment().format('MMMM d, YYYY, hh:mm a') + '</div></div>');
      d.find('.chat-messages').append('<div class="col-sm-12"><div class="chat-message-received">' + message.data + '</div></div>');
      d.show();
      d.find('.chat-messages-container').scrollTop(d.find('.chat-messages-container').prop('scrollHeight'));
      chat_messages[message.user_id] = { messages: d.find('.chat-messages').html(), display: true };
    });

    chat_prepare(user.id, current_user_id);
  });
  
  presence_session.on("connectionDestroyed", function(event) {
    user = JSON.parse(event.connection.data);
    present_users[user.id] = null;
    console.log('disconnected ' + event.connection.data);
  });

  presence_session.connect(current_user_presence_token, function(error) {
  // If the connection is successful, initialize a publisher and publish to the session
    if (!error) {
    } else {
      alert(error.message);
    }
  });
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
          presence_session.signal({ type: 'client-chat-message-from-' + current_user_id + '-to-' + user_id, data: JSON.stringify({user_id: current_user_id, data: $(this).val()})},
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
      alert("CSR is not present");
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
}

$(window).on('page:load', set_chat_session_start_handler);
$(document).ready(set_chat_session_start_handler);

