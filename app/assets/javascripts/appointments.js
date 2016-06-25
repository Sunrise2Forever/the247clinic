
function renderAppointmentCalendar() {
  var date_format = 'MMMM D, YYYY hh:mm A';
  $.ajax({
    type: "GET",
    url: '/appointments',
    dataType: 'json'
  }).done(function(appointments) {
    var appointment_objects = [];
    $.each(appointments, function (index, data) {
      var colors = ['purple', 'blue', 'green', 'orange', 'deepskyblue', 'yellowgreen', 'orangered'];
      appointment_objects.push({
        id: data.id,
        title: data.user_name || data.email,
        start: data.start_time,
        end: data.end_time,
        allDay: false,
        editable: false,
        backgroundColor: colors[index % colors.length],
        borderColor: '#888888'
      })
    });

    $('.appointment-calendar').fullCalendar({
      header: {
        left: 'prev,next today',
        center: 'title',
        right: 'month,agendaWeek,agendaDay'
      },
      buttonIcons: { // note the space at the beginning
        prev: ' glyphicon glyphicon-chevron-left',
        next: ' glyphicon glyphicon-chevron-right'
      },
      buttonText: {
        today: 'today',
        month: 'month',
        week: 'week',
        day: 'day'
      },
      defaultView: 'agendaWeek',
      editable: true,
      droppable: true, // this allows things to be dropped onto the calendar
      slotDuration: { minutes: 10 },
      // This array is the events sources
      events: appointment_objects,
      eventClick: function (calEvent, jsEvent, view) {
        $.ajax({
          type: "GET",
          url: '/appointments/' + calEvent.id,
          dataType: 'json'
        }).done(function (data) {
          $('#appointment_user').text(data.user_name || '');
          $('#appointment_doctor').text(data.doctor_name || '');
          $('#appointment_clinic').text(data.clinic_name || '');
          $('#appointment_email').text(data.email || '');
          $('#appointment_phone').text(data.phone || '');
          if (data.user_id) {
            $('.user-appointment-section').show();
            $('.non-user-appointment-section').hide();
          } else {
            $('.user-appointment-section').hide();
            $('.non-user-appointment-section').show();
          }
          $('#appointment_start_time').text(moment(data.start_time).utcOffset(data.start_time).format(date_format));
          $('#appointment_end_time').text(moment(data.end_time).utcOffset(data.start_time).format(date_format));
          $('#appointment_modal').modal('show');
        });
      }
    })
  });

}