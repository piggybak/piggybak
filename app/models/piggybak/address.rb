module Piggybak 
  class Address < ActiveRecord::Base
    belongs_to :state
    belongs_to :country

    validates_presence_of :firstname
    validates_presence_of :lastname
    validates_presence_of :address1
    validates_presence_of :city
    validates_presence_of :state_id
    validates_presence_of :country_id
    validates_presence_of :zip

    after_initialize :set_default_country

    def set_default_country
      self.country ||= Address.DEFAULT_COUNTRY
    end

    def self.DEFAULT_COUNTRY
      Country.find_by_abbr("US")
    end
      
    def admin_label
      address = "#{self.firstname} #{self.lastname}<br />"
      address += "#{self.address1}<br />"
      if self.address2 && self.address2 != ''
        address += "#{self.address2}<br />"
      end
      address += "#{self.city}, #{self.state ? self.state.name : self.state_id} #{self.zip}<br />"
      address += "#{self.country.name}"
      address
    end
    alias :display :admin_label  
  end
end
