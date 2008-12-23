class Transaction < ActiveRecord::Base
  belongs_to :subscriptions
  validates_presence_of :amount
  validates_presence_of :currency
  validates_numericality_of :amount, :greater_than => 0
  
  serialize :meta
  attr_accessible # nothing
  
  def money
    amount && Money.new(amount, currency)
  end
  
  def money=(mon)
    self.amount   = mon.cents
    self.currency = mon.currency
  end
end
