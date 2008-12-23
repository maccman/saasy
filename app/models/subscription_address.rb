class SubscriptionAddress < ActiveRecord::Base
  belongs_to :subscription
  
  validates_presence_of :street,
                        :city,
                        :region,
                        :postcode,
                        :country,
                        :invoice_to
  
  attr_accessible       :street,
                        :city,
                        :region,
                        :postcode,
                        :country,
                        :invoice_to
end