module Piggybak 
  class Address < ActiveRecord::Base
    validates_presence_of :firstname
    validates_presence_of :lastname
    validates_presence_of :address1
    validates_presence_of :city
    validates_presence_of :state
    validates_presence_of :zip
        
    def admin_label
      "Address: #{self.id}"
    end
  end
end
