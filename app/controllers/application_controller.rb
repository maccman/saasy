# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  # Scrub sensitive parameters from your log
  filter_parameter_logging :password, :password_confirmation, :card
  
  include HoptoadNotifier::Catcher if defined?(HoptoadNotifier)
  
  include AuthenticatedSystem
  
  include SslRequirement
  
  rescue_from RestResponses::BaseError do |exception|
    responds_error(exception.http_status)
  end
  
  include SSO::Server
  sso :secret => AppConfig.sso_secret, :salt => AppConfig.sso_salt
  
  protected
  
    def login_from_sso
      sso_session && 
        sso_session[:user_id] && 
          User.find(sso_session[:user_id])
    end
    
    # Override AuthenticatedSystem
    def current_user
      @current_user ||= (login_from_session || login_from_sso || login_from_cookie) unless @current_user == false
    end
end
