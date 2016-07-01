
function init_tasks() {
  $('.task-title').on('click', function() {
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
  });

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
        location.reload();
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
    $('#task_id').val('');
    $('#task_title').val('');
    $('#task_details').val('');
    $('#task_done').prop('checked', false);
    $('#task_error').text('');
    $('#task_modal').modal('show');
    return false;
  });
}
