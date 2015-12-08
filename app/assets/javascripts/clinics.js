
function init_clinic_section(user_type) {
  if (user_type == 'doctor') {
    $('.select_clinic_section').show();
  } else {
    $('.select_clinic_section').hide();
  }

  $('#user_user_type').on('change', function() {
    if ($(this).val() == 'doctor') {
      $('.select_clinic_section').show();
    } else {
      $('.select_clinic_section').hide();
    }
  });

  $('#user_clinic_id').on('change', function() {
    var not_working_days = $('.chosen-select').val();
    $.ajax({
      type: "GET",
      url: '/clinics/' + $(this).val(),
      dataType: 'json'
    }).done(function(clinic) {
      $('.chosen-select').empty();
      var clinic_opening_days = $(['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday']).not($(clinic.not_opening_days)).get();
      $.each(clinic_opening_days, function(key, value) {
        $('.chosen-select').append("<option value='" + value +"'>" + value + "</option>");
      });
      $('.chosen-select').val(not_working_days);
      $('.chosen-select').trigger("chosen:updated");
    });
  });
}

