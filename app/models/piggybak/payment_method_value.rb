module Piggybak
  class PaymentMethodValue < ActiveRecord::Base
    belongs_to :payment_method
    validates_presence_of :key
    validates_presence_of :value
    
    attr_accessible :key, :value, :payment_method_id
      
    def admin_label
      "#{self.key} - #{self.value}"
    end
  end
end
