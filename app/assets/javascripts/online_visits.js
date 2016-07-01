
function renderOnlineVisitCalendar(current_user_id, current_user_type, online_visits, call_backs) {
  var date_format = 'MMMM D, YYYY hh:mm A';
  var objects = [];
  var object_count = 0;
  $.each(online_visits, function (index, data) {
    var colors = ['purple', 'blue', 'green', 'orange', 'deepskyblue', 'yellowgreen', 'orangered'];
    if (data.scheduled_time) {
      objects.push({
        id: data.id,
        title: data.user_name,
        start: data.scheduled_time,
        end: moment(data.scheduled_time).utcOffset(data.scheduled_time).add(15, 'minutes'),
        allDay: false,
        editable: false,
        backgroundColor: colors[object_count % colors.length],
        borderColor: '#888888',
        type: 'online_visit'
      });      
      object_count ++;
    }
  });

  $.each(call_backs, function (index, data) {
    var colors = ['purple', 'blue', 'green', 'orange', 'deepskyblue', 'yellowgreen', 'orangered'];
    if (data.scheduled_time) {
      objects.push({
        id: data.id,
        title: data.user_name,
        start: data.scheduled_time,
        end: moment(data.scheduled_time).utcOffset(data.scheduled_time).add(15, 'minutes'),
        allDay: false,
        editable: false,
        backgroundColor: colors[object_count % colors.length],
        borderColor: '#888888',
        type: 'call_back'
      });      
      object_count ++;
    }
  });

  $('.online-visit-calendar').fullCalendar({
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
    slotDuration: { minutes: 15 },
    
    // This array is the events sources
    events: objects,
    eventClick: function (calEvent, jsEvent, view) {
      if (calEvent.type == 'online_visit') {
        $.ajax({
          type: "GET",
          url: '/online_visits/' + calEvent.id,
          dataType: 'json'
        }).done(function (data) {
          $('#online_visit_user').text(data.user_name || '');
          $('#online_visit_type').text('CSR');
          $('#online_visit_doctor').text(data.csr_name || '');
          $('#online_visit_scheduled_time').text(moment(data.scheduled_time).utcOffset(data.scheduled_time).format(date_format));
          if ((current_user_id == data.user_id || current_user_id == data.csr_id) && data.startable) {
            $('#online_visit_start').attr('href', '/online_visits/' + data.id);
            $('#online_visit_start').show();
          } else {
            $('#online_visit_start').attr('href', '');
            $('#online_visit_start').hide();            
          }
          if (current_user_id == data.csr_id || (current_user_type == 'csr' && !data.csr_id)) {
            $('#online_visit_edit').attr('href', '/online_visits/' + data.id + '/edit');
            $('#online_visit_edit').show();
            $('#online_visit_delete').attr('href', '/online_visits/' + data.id);
            $('#online_visit_delete').show();
          } else {
            $('#online_visit_edit').attr('href', '');
            $('#online_visit_edit').hide();
            $('#online_visit_delete').attr('href', '');
            $('#online_visit_delete').hide();            
          }
          $('#online_visit_modal').modal('show');
        });        
      } else {
        $.ajax({
          type: "GET",
          url: '/call_backs/' + calEvent.id,
          dataType: 'json'
        }).done(function (data) {
          $('#online_visit_user').text(data.user_name || '');
          $('#online_visit_type').text('Doctor');
          $('#online_visit_doctor').text(data.doctor_name || '');
          $('#online_visit_scheduled_time').text(moment(data.scheduled_time).utcOffset(data.scheduled_time).format(date_format));
          if ((current_user_id == data.user_id || current_user_id == data.doctor_id) && data.startable) {
            $('#online_visit_start').attr('href', '/call_backs/' + data.id);
            $('#online_visit_start').show();
          } else {
            $('#online_visit_start').attr('href', '');
            $('#online_visit_start').hide();            
          }
          if (current_user_id == data.doctor_id || (current_user_type == 'doctor' && !data.doctor_id)) {
            $('#online_visit_edit').attr('href', '/call_backs/' + data.id + '/edit');
            $('#online_visit_edit').show();
            $('#online_visit_delete').attr('href', '/call_backs/' + data.id);
            $('#online_visit_delete').show();
          } else {
            $('#online_visit_edit').attr('href', '');
            $('#online_visit_edit').hide();
            $('#online_visit_delete').attr('href', '');
            $('#online_visit_delete').hide();            
          }
          $('#online_visit_modal').modal('show');
        });        
      }
    }
  })

}
