class UserMailer < ActionMailer::Base
  default from: 'websumy@mail.ru'
  default to: 'support@bitfun.ru'

  def welcome_email(user)
    @user = user
    mail(to: user.email, subject: t('user.welcome_email.subject'))
  end

  def contact_us(contact)
    @contact = contact
    mail(subject: t('user.contact_us.subject'))
  end

end
