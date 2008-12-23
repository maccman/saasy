# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'bc11bd14c7337ac474db42c2b08fc7e3'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
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
