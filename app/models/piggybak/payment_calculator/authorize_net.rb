module Piggybak
  class PaymentCalculator::AuthorizeNet
    KEYS = ["login", "password"]
    KLASS = ::ActiveMerchant::Billing::AuthorizeNetGateway

    def self.transaction_id(gateway_response)
      gateway_response.params["transaction_id"]
    end
  end
end
