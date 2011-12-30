module Piggybak
  class Order < ActiveRecord::Base
    has_many :line_items
    has_many :payments
    has_many :shipments
    belongs_to :billing_address, :class_name => "Piggybak::Address"
    belongs_to :shipping_address, :class_name => "Piggybak::Address"
  
    accepts_nested_attributes_for :billing_address
    accepts_nested_attributes_for :shipping_address
    accepts_nested_attributes_for :shipments
    accepts_nested_attributes_for :payments
  
    validates_presence_of :email
    validates_presence_of :phone
    validates_presence_of :total

    before_save :update_total
  
    def update_total
      total = self.line_items.inject(0) { |total, line_item| total + line_item.total }
      shipments.each do |shipment|
        total += shipment.total
      end
      self.total = total
    end
      
    def avs_address
      {
      :address1 => self.billing_address.address1,
      :city     => self.billing_address.city,
      :state    => self.billing_address.state,
      :zip      => self.billing_address.zip,
      :country  => "US" 
      }
    end

    def admin_label
      "Order ##{self.id}"    
    end
  end
end
