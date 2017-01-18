
function init_tasks() {
  $('.task-title').on('click', show_create_task);

  function show_create_task() {
    var task_row = $(this).parent();
    var task_id = $(this).data('task-id');
    $.ajax({
      type: "GET",
      url: '/tasks/' + task_id,
      dataType: 'json'
    }).done(function (data) {
      $('#task_id').val(data.id);
      $('#task_title').val(data.title);
      $('#task_details').val(data.details);
      $('#task_done').prop('checked', data.done);
      $('#task_error').text('');
      $('#task_modal').modal('show');
    });
    return false;
  }

  $('.btn-save-task').on('click', function() {
    if ($('#task_id').val()) {
      $.ajax({
        type: "PUT",
        url: '/tasks/' + $('#task_id').val(),
        data: {
          task: {
            title: $('#task_title').val(),
            details: $('#task_details').val(),
            done: $('#task_done').prop('checked')
          }
        }
      }).done(function (data) {
        updated_task = $('.task-title[data-task-id=' + data.id + ']').parent();
        updated_task.find('.task-title').text(data.title);
        if (data.done) {
          updated_task.find('.progress-bar').addClass('progress-bar-u');
          updated_task.find('.progress-bar').removeClass('progress-bar-red');
          updated_task.find('.check-task-done').hide();  
        } else {
          updated_task.find('.progress-bar').addClass('progress-bar-red');
          updated_task.find('.progress-bar').removeClass('progress-bar-u');     
          updated_task.find('.check-task-done').prop('checked', false);       
          updated_task.find('.check-task-done').show();
        }
        $('#task_modal').modal('hide');        
      }).fail(function(error) {
        $('#task_error').text(error.responseJSON.error);
      });
    } else {
      $.ajax({
        type: "POST",
        url: '/tasks',
        data: {
          task: {
            title: $('#task_title').val(),
            details: $('#task_details').val(),
            done: $('#task_done').prop('checked')
          }
        }
      }).done(function (data) {
        location.reload();
      }).fail(function(error) {
        $('#task_error').text(error.responseJSON.error);
      });
    }
  });

  $('.btn-new-task').on('click', function() {
    createTask();
    return false;
  });

  function createTask() {
    if ($('.new-task-title').val()) {
      $.ajax({
        type: "POST",
        url: '/tasks',
        data: {
          task: {
            title: $('.new-task-title').val()
          }
        }
      }).done(function (data) {
        new_task = $('<div/>');
        check_task_done = $('<input type="checkbox" class="check-task-done" data-task-id=' + data.id + '>');
        check_task_done.on('click', complete_task);
        new_task.append(check_task_done);
        task_title = $('<span class="heading-xs task-title" data-task-id=' + data.id + '>' + data.title + '</span>');
        task_title.on('click', show_create_task);
        new_task.append(task_title);
        new_task.append('<div class="progress progress-u progress-xxs"><div style="width: 100%" aria-valuemax="100" aria-valuemin="0" aria-valuenow="100" role="progressbar" class="progress-bar progress-bar-red"></div></div>');
        $('.tasks').prepend(new_task);
        $('.new-task-title').val('');
      });
    }
  }

  $('.new-task-title').on('keypress', function (e) {
    if(e.keyCode == 13) {
      createTask();
    }
  });

  $('.check-task-done').on('click', complete_task);

  function complete_task() {
    $.ajax({
      type: "PUT",
      url: '/tasks/' + $(this).data('task-id'),
      data: {
        task: {
          done: true
        }
      }
    }).done(function (data) {
      updated_task = $('.task-title[data-task-id=' + data.id + ']').parent();
      updated_task.find('.task-title').text(data.title);
      updated_task.find('.progress-bar').addClass('progress-bar-u');
      updated_task.find('.progress-bar').removeClass('progress-bar-red');  
      updated_task.find('.check-task-done').hide();
    }).fail(function(error) {
      $('#task_error').text(error.responseJSON.error);
    });
  }
}
