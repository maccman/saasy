require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  include Authorization::StatefulRoles
  belongs_to :account
    
  validates_length_of       :first_name, :last_name, 
                            :maximum      => 100,
                            :allow_blank  => true
                            
  validates_format_of       :first_name, :last_name, 
                            :with         => Authentication.name_regex, 
                            :message      => Authentication.bad_name_message,
                            :allow_blank  => true
                            
  validates_presence_of     :first_name, :last_name                          
                                      
  validates_presence_of     :email    
  validates_length_of       :email,   :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_email_veracity_of :email, :message => Authentication.bad_email_message
  
  validates_acceptance_of :eula, :on => :create, :message => "must be accepted"
  
  validates_presence_of   :identity_url, :if => :identity_url_required?
  validates_uniqueness_of :identity_url, :allow_blank => true
  
  before_validation :normalize_identity_url
  before_create     :make_activation_code
  
  attr_accessible :email, 
                  :first_name,
                  :last_name, 
                  :password, 
                  :password_confirmation, 
                  :identity_url,
                  :eula
                  
  attr_accessor :eula

  class << self
    def authenticate(email, password)
      return nil if email.blank? || password.blank?
      u = in_state(:active).first(:conditions => {:email => email}) # need to get the salt
      (u && u.authenticated?(password) && u.account.active?) ? u : nil
    end
  
    def authenticate_by_identity_url(identity_url)
      return nil if identity_url.blank?
      u = in_state(:active).first
      u && u.account.active? ? u : nil
    end
  end
  
  named_scope :other_account_users, lambda {|user|
                {
                  :conditions => [
                    'account_id = ? and id != ?', 
                    user.account_id, 
                    user.id
                  ]
                }
              }
  
  def name
    [first_name, last_name].join(' ')
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end
  
  def password_required?
    !identity_url? && (crypted_password.blank? || !password.blank?)
  end
  
  def to_xml(options = {})
    options[:only] ||= []
    options[:only] = [
      :id,
      :account_id,
      :email, 
      :first_name,
      :last_name,  
      :identity_url,
      :created_at,
      :updated_at
    ]
    super(options)
  end
  
  protected
  
    def identity_url_required?
      crypted_password.blank? && password.blank?
    end
    
    def make_activation_code
      self.deleted_at = nil
      self.activation_code = self.class.make_token
    end
    
    def normalize_identity_url
      self.identity_url = OpenIdAuthentication.normalize_url(identity_url) if identity_url?
    end
end
