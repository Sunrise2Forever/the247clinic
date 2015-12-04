
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
}

