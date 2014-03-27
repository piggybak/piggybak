module Piggybak
  class ShippingMethodValue < ActiveRecord::Base
    belongs_to :shipping_method
    validates :key, presence: true
    validates :value, presence: true
    
    def admin_label
      "#{self.key} - #{self.value}"
    end
  end
end
