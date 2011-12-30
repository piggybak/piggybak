module Piggybak
  class Order < ActiveRecord::Base
    has_many :line_items, :inverse_of => :order
    has_many :payments, :inverse_of => :order
    has_many :shipments, :inverse_of => :order
    belongs_to :billing_address, :class_name => "Piggybak::Address"
    belongs_to :shipping_address, :class_name => "Piggybak::Address"
    belongs_to :user
  
    accepts_nested_attributes_for :billing_address, :allow_destroy => true
    accepts_nested_attributes_for :shipping_address, :allow_destroy => true
    accepts_nested_attributes_for :shipments, :allow_destroy => true
    accepts_nested_attributes_for :payments, :allow_destroy => true
    accepts_nested_attributes_for :line_items, :allow_destroy => true
  
    validates_presence_of :email
    validates_presence_of :phone
    validates_presence_of :total
    validates_presence_of :total_due
    validates_presence_of :created_at

    before_save :update_details
  
    def update_details
      total = 0

      self.line_items.each do |line_item|
        total += line_item.total
      end

      shipments.each do |shipment|
        total += shipment.total
      end
      self.total = total

      payments.each do |payment|
        total -= payment.total
      end
      self.total_due = total 

      if total < 0.00
        self.status = "credit_owed" 
      elsif total == 0.00
        if shipments.collect { |s| s.status }.uniq == ["shipped"]
          self.status = "shipped" 
        else
          self.status = "paid" 
        end
      else
        self.status = "incomplete"
      end
      self
    end

    def status_enum
      ["incomplete", "paid", "shipped"]
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
