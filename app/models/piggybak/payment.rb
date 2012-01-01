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
      ["paid"]
    end

    def credit_card
      { :number => self.number,
        :month => self.month,
        :year => self.year,
        :verification_value => self.verification_value,
        :first_name => self.order.billing_address.firstname,
        :last_name => self.order.billing_address.lastname }
    end

    validates_each :payment_method_id do |record, attr, value|
      if record.new_record?
  	    credit_card = ActiveMerchant::Billing::CreditCard.new(record.credit_card)
  	 
        if credit_card.valid?
          payment_gateway = record.payment_method.klass.constantize
  		  gateway = payment_gateway::KLASS.new(record.payment_method.key_values)
  		  gateway_response = gateway.authorize(record.order.total_due*100, credit_card, :address => record.order.avs_address)
  		  if gateway_response.success?
            record.total = record.order.total_due
  		    gateway.capture(1000, gateway_response.authorization)
  		  else
  		    record.errors.add attr, gateway_response.message
  		  end
        else
          record.errors.add attr, "Your credit card is not valid: #{credit_card.errors.full_messages.join('<br />')}"
        end
      end
    end
  end
end
