class AppointmentMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.account_activation.subject
  #
  def appointment_email_to_doctor(appointment) do
    @appointment = appointment
    mail to: appointment.doctor.email, subject: "You have received the appointment"
  end

  def appointment_email_to_user(appointment) do
    @appointment = appointment
    mail to: appointment.user.email, subject: "You have created a appointment"
  end
end 
