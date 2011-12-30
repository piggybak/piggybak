module Piggybak
  class ShippingMethodValue < ActiveRecord::Base
    belongs_to :shipping_method
    validates_presence_of :key
    validates_presence_of :value
    
    def admin_label
      "#{self.key} - #{self.value}"
    end
  end
end
