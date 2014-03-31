module Piggybak
  class Payment < ActiveRecord::Base
    belongs_to :order
    belongs_to :payment_method
    belongs_to :line_item

    validates :status, presence: true
    validates :payment_method_id, presence: true
    validates :month, presence: true
    validates :year, presence: true

    attr_accessor :number
    attr_accessor :verification_value
    
    def status_enum
      ["paid"]
    end

    def month_enum
      1.upto(12).to_a
    end

    def year_enum
      Time.now.year.upto(Time.now.year + 10).to_a
    end

    def credit_card
      { "number" => self.number,
        "month" => self.month,
        "year" => self.year,
        "verification_value" => self.verification_value,
        "first_name" => self.line_item ? self.line_item.order.billing_address.firstname : nil,
        "last_name" => self.line_item ? self.line_item.order.billing_address.lastname : nil }
    end

    def process(order)
      return true if !self.new_record?

      ActiveMerchant::Billing::Base.mode = Piggybak.config.activemerchant_mode

      payment_gateway = self.payment_method.klass.constantize
      gateway = payment_gateway::KLASS.new(self.payment_method.key_values)
      p_credit_card = ActiveMerchant::Billing::CreditCard.new(self.credit_card)
      gateway_response = gateway.authorize(order.total_due*100, p_credit_card, :address => order.avs_address)
      if gateway_response.success?
        self.attributes = { :transaction_id => payment_gateway.transaction_id(gateway_response),
                            :masked_number => self.number.mask_cc_number }
        gateway.capture(order.total_due*100, gateway_response.authorization, { :credit_card => p_credit_card } )
        return true
      else
        self.errors.add :payment_method_id, gateway_response.message
        return false
      end
    end

    # Note: It is not added now, because for methods that do not store
    # user profiles, a credit card number must be passed
    # If encrypted credit cards are stored on the system,
    # this can be updated
    def refund
      # TODO: Create ActiveMerchant refund integration 
      return
    end

    def details
      if !self.new_record? 
        return "Payment ##{self.id} (#{self.created_at.strftime("%m-%d-%Y")}): " #+ 
          #"$#{"%.2f" % self.total}" reference line item total here instead
      else
        return ""
      end
    end

    validates_each :payment_method_id do |record, attr, value|
      if record.new_record?
        credit_card = ActiveMerchant::Billing::CreditCard.new(record.credit_card)
     
        if !credit_card.valid?
          credit_card.errors.each do |key, value|
            if value.any? && !["first_name", "last_name", "type"].include?(key)
              record.errors.add key, (value.is_a?(Array) ? value.join(', ') : value)
            end
          end
        end
      end
    end
  end
end
