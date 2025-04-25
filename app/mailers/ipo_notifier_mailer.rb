class IpoNotifierMailer < ApplicationMailer

  def notify_subscriber
    @subscriber = params[:subscriber]
    @ipos = params[:ipos]
    mail(to: @subscriber.email, subject: "IPO Notifier - Expected To Trade Tomorrow")
  end

end
