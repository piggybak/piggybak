module Piggybak
  class PaymentCalculator::AuthorizeNet < PaymentCalculator
    KEYS = ["login", "password"]
    KLASS = ::ActiveMerchant::Billing::AuthorizeNetGateway
  end
end
