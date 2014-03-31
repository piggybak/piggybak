module Piggybak
  class TaxMethod < ActiveRecord::Base
    has_many :tax_method_values, :dependent => :destroy
    alias :metadata :tax_method_values

    validates :description, presence: true
    validates :klass, presence: true

    accepts_nested_attributes_for :tax_method_values, :allow_destroy => true

    validates_each :tax_method_values do |record, attr, value|
      if record.klass.present?
        calculator = record.klass.constantize
        metadata_keys = value.collect { |v| v.key }.sort
        if calculator::KEYS.sort != metadata_keys
          if calculator::KEYS.empty?
            record.errors.add attr, "You don't need any metadata for this method."
          else
            record.errors.add attr, "You must define key values for #{calculator::KEYS.join(', ')} for this tax method."
          end
        end
      end
    end

    def klass_enum 
      Piggybak.config.tax_calculators
    end

    def self.calculate_tax(object)
      total_tax = 0

      TaxMethod.all.each do |tax_method|
        calculator = tax_method.klass.constantize
        if calculator.available?(tax_method, object)
          total_tax += calculator.rate(tax_method, object)
        end 
      end

      ((100*total_tax.to_f).to_i).to_f/(100.to_f)
    end

    def admin_label
      self.description
    end
  end
end
