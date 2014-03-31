module Piggybak
  class TaxMethodValue < ActiveRecord::Base
    belongs_to :tax_method
    validates :key, presence: true
    validates :value, presence: true
    
    def admin_label
      "#{self.key} - #{self.value}"
    end  
  end
end
