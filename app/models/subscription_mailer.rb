class SubscriptionMailer < ActionMailer::Base
  def charge_failure(sub, message = nil)
    user = sub.account.owner
    setup_email(user.email)
    @body[:subscription] = sub
    @body[:user] = user
    @body[:message] = message
  end
  
  def second_charge_failure(sub, message = nil)
    user = sub.account.owner
    setup_email(user.email)
    @body[:subscription] = sub
    @body[:user] = user
    @body[:message] = message
  end
  
  def charge_success(sub)
    user = sub.account.owner
    setup_email(user.email)
    @body[:subscription] = sub
    @body[:user] = user
  end
  
  def trial_expiring(sub)
    user = sub.account.owner
    setup_email(user.email)
    @body[:subscription] = sub
    @body[:user] = user
  end
  
  def account_failure(account)
    setup_email(AppConfig.admin_email)
    @body[:account] = account
  end
  
  protected
    def setup_email(email)
      @recipients  = "#{email}"
      @from        = "info@#{AppConfig.app_domain}"
      @subject     = "[#{AppConfig.app_name}] "
      @sent_on     = Time.now
    end
end
