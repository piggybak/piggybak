module Piggybak
  class PaymentMethodValue < ActiveRecord::Base
    belongs_to :payment_method
        
    def admin_label
      "#{self.key} - #{self.value}"
    end
  end
end
