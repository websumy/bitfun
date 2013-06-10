class UserMailer < ActionMailer::Base
  default :from => "from@example.com"

  def welcome_email(user)
    @user = user
    mail(:to => user.email, subject: t('user.welcome_email.subject'))
  end

end
