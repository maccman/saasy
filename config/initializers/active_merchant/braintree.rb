# This is to make their API a bit more like PaymentExpress's one
class BraintreeResponse < ActiveMerchant::Billing::Response
  def token
    @params["customer_vault_id"]
  end
end

ActiveMerchant::Billing::BraintreeGateway::Response = BraintreeResponse

class BraintreeGateway < ActiveMerchant::Billing::Gateway
  # ActiveMerchant's got a weird API. Let's implement it properly.
  # http://groups.google.com/group/activemerchant/browse_thread/thread/9271d87b833ba7a3
  def store(creditcard, options = {})
    post = {}
    post[:customer_vault] = "add_customer"
    add_invoice(post, options)
    add_payment_source(post, creditcard,options)        
    add_address(post, creditcard, options)        
    add_customer_data(post, options)
    
    commit(nil, nil, post)
  end
end