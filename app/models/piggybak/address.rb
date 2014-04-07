module Piggybak 
  class Address < ActiveRecord::Base
    belongs_to :state
    belongs_to :country
    has_one :order_shipping, :foreign_key => "shipping_address_id", :class_name => "Piggybak::Order"
    has_one :order_billing, :foreign_key => "billing_address_id", :class_name => "Piggybak::Order"

    validates :firstname, presence: true
    validates :lastname, presence: true
    validates :address1, presence: true
    validates :city, presence: true
    validates :state_id, presence: true
    validates :country_id, presence: true
    validates :zip, presence: true

    after_initialize :set_default_country
    after_save :document_address_changes
    
    attr_accessor :is_shipping
    
    def set_default_country
      self.country ||= Country.where(abbr: Piggybak.config.default_country).first
    end

    def admin_label
      address = "#{self.firstname} #{self.lastname}<br />"
      address += "#{self.address1}<br />"
      if self.address2 && self.address2 != ''
        address += "#{self.address2}<br />"
      end
      address += "#{self.city}, #{self.state_display} #{self.zip}<br />"
      address += "#{self.country.name}"
      address
    end
    alias :display :admin_label  

    def state_display
      self.state ? self.state.name : self.state_id
    end

    # TODO: Fix this. It isn't working.
    def document_address_changes
      if self.order_billing.present? && self.changed?
        self.order_billing.recorded_changes << self.formatted_changes
      end
      if self.order_shipping.present? && self.changed?
        self.order_shipping.recorded_changes << self.formatted_changes
      end
    end
  end
end
