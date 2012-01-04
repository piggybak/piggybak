module Piggybak
  class TaxMethod < ActiveRecord::Base
    
    # klass_enum requires the ShippingCalculator subclasses to be loaded
    shipping_calcs_path = File.expand_path("../tax_calculator", __FILE__)
    Dir.glob(shipping_calcs_path + "**/*.rb").each do |subclass|
      ActiveSupport::Dependencies.require_or_load subclass
    end 
    
    has_many :tax_method_values, :dependent => :destroy
    alias :metadata :tax_method_values

    validates_presence_of :description
    validates_presence_of :klass

    accepts_nested_attributes_for :tax_method_values, :allow_destroy => true

    validates_each :tax_method_values do |record, attr, value|
      if record.klass
        calculator = record.klass.constantize
        metadata_keys = value.collect { |v| v.key }.sort
        if calculator::KEYS.sort != metadata_keys
          record.errors.add attr, "You must define key values for #{calculator::KEYS.join(', ')} for this tax method."
        end
      end
    end

    def klass_enum 
      Piggybak::TaxCalculator.subclasses
    end

    def self.calculate_tax(object)
      total_tax = 0

      TaxMethod.all.each do |tax_method|
        calculator = tax_method.klass.constantize
        if calculator.available?(tax_method, object)
          total_tax += calculator.rate(tax_method, object)
        end 
      end
      
      total_tax
    end

    def admin_label
      self.description
    end
  end
end
