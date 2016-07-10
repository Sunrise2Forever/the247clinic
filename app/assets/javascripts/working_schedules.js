
function init_working_schedule_fields() {
  $('.working-schedules').on('cocoon:after-insert', function(e, insertedItem) {
    init_fields(insertedItem);
  });

  function init_fields(insertedItem) {
    insertedItem.find('.timepicker').parent().datetimepicker();
    insertedItem.find('.datepicker').parent().datetimepicker();    

    insertedItem.find('.working-schedule-weekly').on('change', function() {
      if ($(this).prop('checked')) {
        insertedItem.find('.working-schedule-day-of-week').show();
        insertedItem.find('.working-schedule-date').hide();
      } else {
        insertedItem.find('.working-schedule-day-of-week').hide();
        insertedItem.find('.working-schedule-date').show();
      }
    })
  }

  $.each($('.working-schedules .nested-fields'), function() {
    init_fields($(this));
  });
}
