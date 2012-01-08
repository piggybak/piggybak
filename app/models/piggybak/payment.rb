module Piggybak
  class Payment < ActiveRecord::Base
    belongs_to :order
    belongs_to :payment_method

    validates_presence_of :status
    validates_presence_of :total
    validates_presence_of :payment_method_id
    validates_presence_of :month
    validates_presence_of :year

    def status_enum
      ["paid", "refunded"]
    end

    def month_enum
      1.upto(12)
    end

    def year_enum
      Time.now.year.upto(Time.now.year + 10)
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
      if self.new_record?
        payment_gateway = self.payment_method.klass.constantize
        gateway = payment_gateway::KLASS.new(self.payment_method.key_values)
  	    credit_card = ActiveMerchant::Billing::CreditCard.new(self.credit_card)
        gateway_response = gateway.authorize(self.order.total_due*100, credit_card, :address => self.order.avs_address)
        if gateway_response.success?
          self.attributes = { :total => self.order.total_due, 
                              :number => 'hidden',
                              :verification_value => 'hidden',
                              :transaction_id => payment_gateway.transaction_id(gateway_response) } 
          gateway.capture(1000, gateway_response.authorization)
          return true
  	    else
  	      self.errors.add :payment_method_id, gateway_response.message
          return false
  	    end
      else
        return true
      end
    end

    def refund
      # Call refund on payment gateway calculator
      # Update status to refunded if success
      # Else return error messages
      # Update total due on order
      "Not Implemented Yet"
    end

    def admin_label
      if !self.new_record? 
        return "Payment ##{self.id} (#{self.created_at.strftime("%m-%d-%Y")})<br />" + 
          "Payment Method: #{self.payment_method.description}<br />" +
          "Status: #{self.status}<br />" +
          "Transaction ID: #{self.transaction_id}<br />" + 
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
