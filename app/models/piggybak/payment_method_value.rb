module Piggybak
  class PaymentMethodValue < ActiveRecord::Base
    belongs_to :payment_method
    validates :key, presence: true
    validates :value, presence: true
    
    def admin_label
      "#{self.key} - #{self.value}"
    end
  end
end
