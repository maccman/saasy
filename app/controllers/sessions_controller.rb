class SessionsController < ApplicationController
  ssl_required :new, :create, :unless => SubConfig.test
  
  def new
    sso_record_params!
    if logged_in?
      successful_login(current_user)
    end
  end

  def create
    using_open_id? ? open_id_auth : normal_auth
  end

  def destroy
    logout_killing_session!
    sso_record_params!
    sso_forget!
    flash[:notice] = "You have been logged out."
    redirect_to :action => :new
  end

  private
  
    def normal_auth
      logout_keeping_session!
      user = User.authenticate(params[:email], params[:password])
      user ? successful_login(user) : failed_login
    end
    
    def open_id_auth
      # Catch user before they go too far
      if openid_url = params[:openid_url]
        openid_url  = OpenIdAuthentication.normalize_url(openid_url)
        user        = User.find_by_identity_url(openid_url)
        failed_login('Unknown user - please sign up') and return unless user
      end
      
      authenticate_with_open_id(params[:openid_url]) do |result, identity_url, registration|
        if result.successful?
          user = User.authenticate_by_identity_url(identity_url)
          user ? successful_login(user) : failed_login
        else
          failed_login result.message
        end
      end
    end
  
    def failed_login(message = "Authentication failed")
      flash.now[:error] = message
      logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
      render :action => 'new'
    end
    
    def successful_login(user)
      # Get this before we call
      # sso_authorize! or reset
      # the session
      is_sso  = sso?
      sso_url = sso_client_url
      
      # Save user_id in the sso session
      # and then save to cache
      self.sso_session[:user_id] = user.id
      sso_authorize!
      
      reset_session
      self.current_user = user
      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
      if is_sso
        redirect_to sso_url
      elsif AppConfig.other_site
        redirect_back_or_default(AppConfig.other_site + '/login')
      else
        redirect_back_or_default('/')
      end
    end
end
