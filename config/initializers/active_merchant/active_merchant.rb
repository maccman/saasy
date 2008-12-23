ActiveMerchant::Billing::Base.mode = :test if SubConfig.test
$gateway = ActiveMerchant::Billing::Base.gateway(SubConfig.gateway).new(
              :login    => SubConfig.login, 
              :password => SubConfig.password
            )

allowed_gateways = [
    ActiveMerchant::Billing::BraintreeGateway,
    ActiveMerchant::Billing::TrustCommerceGateway,
    ActiveMerchant::Billing::PaymentExpressGateway
  ]

unless allowed_gateways.include?($gateway.class)
  raise "#{$gateway.class.name} is not an allowed gateway. " \
        "Please choose on of the following: #{allowed_gateways.join(', ')}."
end