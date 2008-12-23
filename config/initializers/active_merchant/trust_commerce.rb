# This is to make their API a bit more like PaymentExpress's one
class TrustCommerceResponse < ActiveMerchant::Billing::Response
  def token
    @params["billingid"]
  end
end

ActiveMerchant::Billing::TrustCommerceGateway::Response = TrustCommerceResponse