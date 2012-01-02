module Piggybak
  class TaxMethodValue < ActiveRecord::Base
    belongs_to :tax_method
    validates_presence_of :key
    validates_presence_of :value

    def admin_label
      "#{self.key} - #{self.value}"
    end  
  end
end
