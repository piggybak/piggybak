module Piggybak
  class Payment < ActiveRecord::Base
    belongs_to :order
    acts_as_changer
    belongs_to :payment_method

    validates_presence_of :status
    validates_presence_of :total
    validates_presence_of :payment_method_id
    validates_presence_of :month
    validates_presence_of :year

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
        "first_name" => self.order.billing_address.firstname,
        "last_name" => self.order.billing_address.lastname }
    end

    def process
      ActiveMerchant::Billing::Base.mode = Piggybak.config.activemerchant_mode

      if self.new_record?
        payment_gateway = self.payment_method.klass.constantize
        gateway = payment_gateway::KLASS.new(self.payment_method.key_values)
        p_credit_card = ActiveMerchant::Billing::CreditCard.new(self.credit_card)
        gateway_response = gateway.authorize(self.order.total_due*100, p_credit_card, :address => self.order.avs_address)
        if gateway_response.success?
          self.attributes = { :total => self.order.total_due, 
                              :transaction_id => payment_gateway.transaction_id(gateway_response),
                              :masked_number => self.number.mask_cc_number }
          gateway.capture(self.order.total_due*100, gateway_response.authorization, { :credit_card => p_credit_card } )
          return true
  	    else
  	      self.errors.add :payment_method_id, gateway_response.message
          return false
  	    end
      else
        return true
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

    def admin_label
      if !self.new_record? 
        return "Payment ##{self.id} (#{self.created_at.strftime("%m-%d-%Y")}): " + 
          "$#{"%.2f" % self.total}"
      else
        return ""
      end
    end
    alias :details :admin_label

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
