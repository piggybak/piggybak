module Piggybak
  class TaxMethod < ActiveRecord::Base
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
      #TODO: Troubleshoot use of subclasses here instead
      [Piggybak::TaxCalculator::FlatRate]
    end

    def self.calculate_tax(order)
      total_tax = 0

      TaxMethod.all.each do |tax_method|
        calculator = tax_method.klass.constantize
        logger.warn "steph: calc: #{calculator.inspect}"
        if calculator.available?(tax_method, order)
          total_tax += calculator.rate(tax_method, order)
        end 
      end
      
      total_tax
    end

    def admin_label
      self.description
    end
  end
end
