class UserMailer < ActionMailer::Base
  def signup_notification(user)
    setup_email(user.email)
    @subject    += 'Please activate your new account'
    @body[:url]  = "#{AppConfig.app_site}/activate/#{user.activation_code}"
    @body[:user] = user
  end
  
  def account_information(user)
    setup_email(user.email)
    @subject    += 'Your new account'
    @body[:url]  = "#{AppConfig.app_site}/activate/#{user.activation_code}"
    @body[:user] = user
  end
  
  def activation(user)
    setup_email(user.email)
    @subject    += 'Your account has been activated!'
    @body[:url]  = AppConfig.other_site
    @body[:user] = user
  end
  
  protected
    def setup_email(email)
      @recipients  = "#{email}"
      @from        = "info@#{AppConfig.app_domain}"
      @subject     = "[#{AppConfig.app_name}] "
      @sent_on     = Time.now
    end
end
