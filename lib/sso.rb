# Simple SSO - Alex MacCaw - info@eribium.org
# 
# This is something I wrote so all my Rails
# apps could log in through this one (Single Sign On)
# All your apps have a shared secret, and shared salt.
# Requires a Rails cache to be enabled (on this site).
# I'm also assuming you're using restful authentication
# in the examples below. I've also assumed that both apps 
# access the same database.
# 
# For the Client, copy this file to the lib directory, and
# then do something like this:
# 
# # controllers/application.rb
# 
# include SSO::Client
# sso({
#   :secret       => AppConfig.sso_secret,
#   :salt         => AppConfig.sso_salt,
#   :login_url    => AppConfig.saas_site + '/login', 
#   :logout_url   => AppConfig.saas_site + '/logout', 
#   :callback_url => AppConfig.app_site + '/sessions/sso'
# })
# 
# def set_sso_header
#   Remote.headers = {'Authorization' => sso_header_token}
#   # todo - They're not inheriting in production :(
#   Remote::User.headers = Remote.headers
# end
# before_filter :set_sso_header
# 
# # controllers/sessions_controller.rb
# 
# class SessionsController < ApplicationController
#   def new
#     if logged_in?
#       remote_user = Remote::User.current_user
#       self.current_user = User.find(remote_user.id)
#       flash[:notice] = "Logged in successfully"
#       redirect_back_or_default('/')
#       return
#     end
#     
#     if Rails.env.development?
#       # So I don't have to bother loading
#       # up the SSO app every time I want to log in
#       self.current_user = User.first
#       redirect_back_or_default('/')
#     else
#       redirect_to sso_login_url
#     end
#   end
#   
#   def destroy
#     logout_killing_session!
#     redirect_to sso_logout_url
#   end
#   
#   def sso
#     head(401) and return unless sso_valid_token?
#     remote_user = Remote::User.current_user
#     self.current_user = User.find(remote_user.id)
#     flash[:notice] = "Logged in successfully"
#     redirect_back_or_default('/')
#   end
# end
# 
# # models/remote.rb
# 
# class Remote < ActiveResource::Base
#   self.site = AppConfig.saas_site
#   class_inheritable_accessor :headers
# end
# 
# # models/remote/user.rb
# 
# class Remote::User < Remote
#   class << self
#     def current_user
#       find(:one, :from => :current)
#     end
#   end
# end


module SSO  
  module Generic
    def self.included(base)
      base.class_eval do
        class_inheritable_accessor :sso_options
        self.sso_options = {}
        helper_method :sso?
      end
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      def sso(options)
        self.sso_options = options
      end
    end
    
    protected
    
    def sso_salt
      sso_options[:salt] || raise('You must provide a SSO :salt')
    end
    
    def sso_token(*args)
      key = if sso_options[:secret].respond_to?(:call)
        sso_options[:secret].call(@session)
      else
        sso_options[:secret]
      end
      raise 'You must provide an SSO :secret' unless key
      digest = sso_options[:digest] ||= 'SHA1'
      OpenSSL::HMAC.hexdigest(OpenSSL::Digest::Digest.new(digest), key.to_s, args.join)
    end
  end
  
  module Client    
    def self.included(base)
      base.class_eval do
        include(Generic)
      end
    end
    
    protected
    
    def sso?
      !!session[:sso_nounce]
    end
  
    def sso_valid_token?
      sso? && (sso_token(sso_salt, session[:sso_nounce]) == params[:sso_token])
    end
        
    def sso_nounce
      @sso_nounce ||= ActiveSupport::SecureRandom.hex(16)
    end
    
    def sso_login_url
      raise 'You must provide a SSO :login_url'     unless sso_options[:login_url]
      raise 'You must provide a SSO :callback_url'  unless sso_options[:callback_url]
      uri = URI.parse(sso_options[:login_url].to_s.strip)
      uri.query ||= ''
      uri.query += '&' unless uri.query.blank?
      uri.query = {
        :sso_callback => sso_options[:callback_url],
        :sso_nounce   => sso_nounce
      }.to_query
      session[:sso_nounce] = sso_nounce
      uri.to_s
    end
    
    def sso_logout_url
      raise 'You must provide a SSO :logout_url'     unless sso_options[:logout_url]
      raise 'You must provide a SSO :callback_url'  unless sso_options[:callback_url]
      uri = URI.parse(sso_options[:logout_url].to_s.strip)
      uri.query ||= ''
      uri.query += '&' unless uri.query.blank?
      uri.query = {
        :sso_callback => sso_options[:callback_url],
        :sso_nounce   => sso_nounce
      }.to_query
      session[:sso_nounce] = sso_nounce
      uri.to_s 
    end

    def sso_header_token
      # Don't store token in session - otherwise
      # Could be stolen (if using Cookie session).
      # So, we need to generate it every time.
      @sso_header_token ||= sso_token(session[:sso_nounce])
    end
  end
  
  module Server
    def self.included(base)
      base.class_eval do
        include(Generic)
      end
    end
    
    protected
    
    def sso?
      !!session[:sso_nounce] || !!params[:sso_token]
    end
    
    def sso_session=(obj)
      @sso_session = obj
    end

    def sso_session
      @sso_session ||= begin
        token = params[:sso_token] || request.headers['Authorization']
        token.blank? ? {} : Rails.cache.read(token.to_s)
      end
    end
    
    def sso_record_params!
      session[:sso_nounce]   = params[:sso_nounce]   if params[:sso_nounce]
      session[:sso_callback] = params[:sso_callback] if params[:sso_callback]
    end
  
    def sso_authorize!
      return unless session[:sso_nounce]
      Rails.cache.write(
        sso_token(session[:sso_nounce]), 
        sso_session || true, 
        :expires_in => sso_options[:expires_in] || 5.days
      )
      session[:sso_nounce] = nil
    end
    
    def sso_forget!
      return unless sso?
      Rails.cache.delete(sso_token(session[:sso_nounce]))
    end
    
    def sso_client_url
      return unless sso?
      uri = URI.parse(session[:sso_callback].to_s.strip)
      uri.query ||= ''
      uri.query += '&' unless uri.query.blank?
      uri.query += {
        :sso_token => sso_token(sso_salt, session[:sso_nounce])
      }.to_query
      uri.to_s
    end
  end
end