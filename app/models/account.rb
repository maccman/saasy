class Account < ActiveRecord::Base
  has_many :users, :dependent => :destroy
  belongs_to :owner, :class_name => "User"
  
  validates_presence_of :owner_id
  
  has_one :subscription
  
  attr_accessible # nothing
  
  acts_as_state_machine :initial => :pending
  state :pending
  state :active
  state :suspended
  
  event :activate do
    transitions :from => :pending, :to => :active 
  end

  event :suspend do
    transitions :from => :active, :to => :suspended
  end

  event :unsuspend do
    transitions :from => :suspended, :to => :active
  end
end
