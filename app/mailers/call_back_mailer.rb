class CallBackMailer < ApplicationMailer

  def meeting_request_user(call_back)
    @call_back = call_back
    mail to: call_back.user.email, subject: "Meeting Request"
  end

  def meeting_request_doctor(call_back)
    @call_back = call_back
    mail to: call_back.doctor.email, subject: "Meeting Request"
  end
end
