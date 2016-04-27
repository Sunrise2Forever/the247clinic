//= require pusher.min
/*
var pusher;
var chat_csr_channel, chat_message_channel;
var chat_message_channels = [];
var chat_messages = [];

function init_chat_session(current_user_name, current_user_id) {
  if (!current_user_id)
    return;

  if (chat_csr_channel || chat_message_channel) {
    chat_start();
  } else {
    var currentUser = {
      name: current_user_name,
      id: current_user_id
    };

    pusher = new Pusher($('#chat').data().apiKey, {
      authEndpoint: '/pusher/auth',
      auth: {
        params: currentUser
      }
    });

    chat_csr_channel = pusher.subscribe('presence-chat-csr');
    chat_message_channel = pusher.subscribe('presence-chat-message-' + current_user_id);
    chat_message_channel.bind('pusher:subscription_succeeded', chat_start);
  }

  function chat_start() {
    set_chat_event_handlers($('#chat_template'), chat_message_channel)
  }
}

function init_chat_session_csr(current_user_name, current_user_id) {
  if (!current_user_id)
    return;

  if (chat_csr_channel || chat_message_channels.length) {
    $.each (chat_csr_channel.members.members, function(user_id, member) {
      if (user_id != current_user_id) {
        chat_prepare(user_id, chat_csr_channel.members.members[user_id].name, true);
      }
    });
  } else {
    var currentUser = {
      name: current_user_name,
      id: current_user_id
    };

    pusher = new Pusher($('#chat').data().apiKey, {
      authEndpoint: '/pusher/auth',
      auth: {
        params: currentUser
      }
    });

    chat_csr_channel = pusher.subscribe('presence-chat-csr');
    chat_csr_channel.bind('pusher:subscription_succeeded', chat_login);
  }

  function chat_login() {
    $.each (chat_csr_channel.members.members, function(user_id, member) {
      if (user_id != current_user_id) {
        chat_prepare(user_id, chat_csr_channel.members.members[user_id].name);
      }
    });

    chat_csr_channel.bind('pusher:member_added', function (member) {
      chat_prepare(member.id, member.info.name);
    });
    chat_csr_channel.bind('pusher:member_removed', function(member) {
      pusher.unsubscribe('presence-chat-message-' + member.id);
    });
  }

  function chat_prepare(user_id, user_name, channel_flag) {
    if (channel_flag) {
      create_chat_templates();
    } else {
      chat_message_channels[user_id] = pusher.subscribe('presence-chat-message-' + user_id);
      chat_message_channels[user_id].bind('pusher:subscription_succeeded', create_chat_templates);
    }

    function create_chat_templates() {
      d = $('#chat_template').clone(true);
      d.attr('id', 'chat_' + user_id);
      d.appendTo($('#chat_template').parent());
      d.find('.chat-title').text(user_name);

      set_chat_event_handlers(d, chat_message_channels[user_id]);
    }
  }
}

function set_chat_event_handlers(d, channel) {
  if (chat_messages[d.id]) {
    d.find('.chat-messages').append(chat_messages[d.id].messages);
    if (chat_messages[d.id].display) {
      d.show();
      d.find('.chat-messages-container').scrollTop(d.find('.chat-messages-container').prop('scrollHeight'));
    }
  }

  channel.bind('client-chat-message', function (data) {
    d.find('.chat-messages').append('<div class="col-sm-12"><div class="chat-time">' + moment().format('MMMM d, YYYY, hh:mm a') + '</div></div>');
    d.find('.chat-messages').append('<div class="col-sm-12"><div class="chat-message-received">' + data.message + '</div></div>');
    d.show();
    d.find('.chat-messages-container').scrollTop(d.find('.chat-messages-container').prop('scrollHeight'));
    chat_messages[d.id] = { messages: d.find('.chat-messages').html(), display: true };
  });

  d.find('.chat-message').on('keypress', function (e) {
    if(e.keyCode == 13 && !e.shiftKey) {
      if ($(this).val()) {
        channel.trigger('client-chat-message', {
          message: $(this).val()
        });
        d.find('.chat-messages').append('<div class="col-sm-12"><div class="chat-message-sent">' + $(this).val() + '</div></div>');
        d.find('.chat-messages-container').scrollTop(d.find('.chat-messages-container').prop('scrollHeight'));
        chat_messages[d.id] = { messages: d.find('.chat-messages').html(), display: true };
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
    if (!confirm('Are you sure?')) return;
    chat_messages[d.id] = { messages: d.find('.chat-messages').html(), display: false };
    $(this).parent().parent().hide();
  });
}

function set_chat_session_start_handler(){
  $('.start-chat-session').on('click', function() {
    if (!$('#video_session_symptom').val()) {
      alert("Symptom can't be blank");
      return;
    }
    $('#chat_template').find('.chat-message').val($('#video_session_symptom').val());
    $('#video_session_symptom').val('');
    var e = jQuery.Event('keypress');
    e.keyCode = 13;
    $('#chat_template').find('.chat-message').trigger(e);
    $('#chat_template').show();
  });
}

$(window).on('page:load', set_chat_session_start_handler);
$(document).ready(set_chat_session_start_handler);
*/