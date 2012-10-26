module Piggybak 
  class Address < ActiveRecord::Base
    belongs_to :state
    belongs_to :country
    has_one :order_shipping, :foreign_key => "shipping_address_id", :class_name => "Piggybak::Order"
    has_one :order_billing, :foreign_key => "billing_address_id", :class_name => "Piggybak::Order"

    validates_presence_of :firstname
    validates_presence_of :lastname
    validates_presence_of :address1
    validates_presence_of :city
    validates_presence_of :state_id
    validates_presence_of :country_id
    validates_presence_of :zip

    after_initialize :set_default_country
    after_save :document_address_changes
    
    attr_accessible :firstname, :lastname, :address1, :location,
                    :address2, :city, :state_id, :zip, :country_id,
                    :copy_from_billing
    attr_accessor :is_shipping
    
    def set_default_country
      self.country ||= Country.find_by_abbr(Piggybak.config.default_country)
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

    def document_address_changes
      # TODO: Fix this. It isn't working.
      if self.order_billing.present? && self.changed?
        self.order_billing.recorded_changes << self.formatted_changes
      end
      if self.order_shipping.present? && self.changed?
        self.order_shipping.recorded_changes << self.formatted_changes
      end
    end
  end
end
