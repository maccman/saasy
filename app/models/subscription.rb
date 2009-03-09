class Subscription < ActiveRecord::Base
  extend ActiveSupport::Memoizable
  class SubscriptionError < RuntimeError; end
  class ResponseFailed < SubscriptionError
    attr_reader :response
    def initialize(response = nil)
      @response = response
    end
  end
  class AuthorizationFailed < ResponseFailed; end
  class CaptureFailed < ResponseFailed; end
  class StoreFailed < ResponseFailed; end

  belongs_to  :account
  has_many    :transactions
  has_one     :subscription_address
  
  after_save                  :store_card!
  before_destroy              :unstore_card!
  before_validation_on_create :set_default_renewal
  
  validate                :valid_card
  validates_presence_of   :plan_name
  validates_inclusion_of  :plan_name, :in => SubConfig.plans.collect {|p| p["name"] }
  validate_on_create      :valid_plan
  validates_presence_of   :next_renewal_at
  
  attr_accessible :card, :plan_name
    
  named_scope :for_account, lambda {|account| 
    { :conditions => { :account_id => account.id } } 
  }
  
  # Find subscriptions due on a particular day
  named_scope :due, lambda {|time|
    { 
      :include    => :account, 
      :conditions => [
        "accounts.state = ? AND next_renewal_at = ?", 
        "active",
        time.midnight
      ]
    }
  }
  
  acts_as_state_machine :initial => :pending
  state :pending
  state :trial
  state :active
  state :error
  
  event :trial do
    transitions :from => [:error, :pending], :to => :active 
  end
  
  event :active do
    transitions :from => [:active, :pending, :trial, :error], :to => :active 
  end

  event :error do
    transitions :from => [:error, :pending, :active, :trial], :to => :error
  end
  
  def renew!
    begin
      charge!(plan_money)
    rescue SubscriptionError => e
      logger.error "****Subscription Error****"
      logger.error e.response.message
      self.last_charge_error = e.class.name + ' - ' + e.response.message
      self.error! # Saves last_charge_error too
      false
    else
      record_transaction!(next_renewal_at, plan_money)
      self.last_charge_error = nil
      self.next_renewal_at = expires_at(next_renewal_at)
      self.active! # Saves next_renewal_at too
      true
    end
  end
  
  def charge!(money)
    if auth_code?
      purchase_using_auth_code!(money)
    else
      raise "Nothing to charge with"
    end
    true
  end
  
  def plan
    plan_name && 
      SubConfig.plans.find {|plan| 
        plan["name"] == plan_name 
      }.with_indifferent_access
  end
  
  def plan=(d)
    self.plan_name = d.to_s
  end
  
  def plan_money
    plan && Money.new(plan[:price], plan[:currency])
  end
  
  def card
    @card ||= ActiveMerchant::Billing::CreditCard.new
  end
  
  def card=(value)
    @card = case value
      when ActiveMerchant::Billing::CreditCard, nil
        value
      else
        ActiveMerchant::Billing::CreditCard.new(value)
      end
  end
  
  def card?
    !!@card
  end
  
  def expires_at(time = next_renewal_at)
    time ||= Time.now.midnight
    (time + 1.month).midnight
  end
  
  def to_xml(options = {})
    options[:only] ||= []
    options[:only] = [
      :id,
      :account_id,
      :plan_name,
      :state,
      :created_at,
      :updated_at
    ]
    options[:procs] ||= []
    options[:procs] << Proc.new { |options| 
      plan.to_xml(options.update(:root => 'plan'))
    }
    super(options)
  end
  
  private
  
    def store_card!
      return unless card? && card.valid?
      # We might be updating to a new card
      unstore_card! if auth_code?
      
      store_response  = gateway.store(card)
      raise StoreFailed.new(store_response) unless store_response.success?
      new_auth_code   = store_response.token
      
      # We have to set the card to nil so:
      # a) it's taken out of memory
      # b) store_card! doesn't get called again 
      #    when we resave.
      self.card = nil
      # Save the auth code so we don't need to use
      # a credit card the next time we bill
      update_attribute(:auth_code, new_auth_code)
    end
    
    def unstore_card!
      return unless auth_code?
      # Some gateways don't implement unstore
      if gateway.respond_to?(:unstore)
        gateway.unstore(auth_code)
      end
      self.auth_code = nil
    end
  
    def purchase_using_auth_code!(money)
      auth_response = gateway.authorize(money, auth_code)
      raise AuthorizationFailed.new(auth_response) unless auth_response.success?
      
      cap_response = gateway.capture(money, auth_response.authorization)
      raise CaptureFailed.new(cap_response) unless cap_response.success?
    end
    
    def record_transaction!(time, money)
      tran = transactions.build
      tran.money = money
      tran.meta = {}
      tran.meta[:from] = (time - 1.month).midnight
      tran.meta[:to]   = time
      tran.save
    end
    
    # Check out http://letsfreckle.com/blog/2008/12/ecommerce-stuff/
    # Test charges need to be at least $1
    def test_card!
      auth_response = gateway.authorize(100, card)
      gateway.void(auth_response.authorization) if auth_response.success?
      raise AuthorizationFailed.new(auth_response) unless auth_response.success?
    end
  
    def set_default_renewal
      self.next_renewal_at = expires_at(Time.now.midnight)
    end
  
    def valid_plan
      if plan && plan[:disabled]
        errors.add(:plan, "is disabled")
      end
    end
    
    def valid_card
      return unless card?
      unless card.valid?
        errors.add(:card, "must be valid") and return
      end
      begin
        test_card!
      rescue AuthorizationFailed => e
        errors.add(:card, "failed test charge with: #{e.response.message}")
      end
    end
    
    def gateway
      $gateway
    end
end
