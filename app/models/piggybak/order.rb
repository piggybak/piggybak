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
    accepts_nested_attributes_for :line_items, :allow_destroy => true
    accepts_nested_attributes_for :payments

    validates_presence_of :status  
    validates_presence_of :email
    validates_presence_of :phone
    validates_presence_of :total
    validates_presence_of :total_due
    validates_presence_of :created_at

    before_validation :update_details
    before_save :process_payments, :update_details, :update_status
    after_save :update_details

    def process_payments
      update_details

      has_errors = false
      self.payments.each do |payment|
        if(!payment.process)
          has_errors = true
        end
      end
      !has_errors
    end

    def add_line_items(cart)
      cart.update_quantities
      cart.items.each do |item|
        line_item = Piggybak::LineItem.new({ :product_id => item[:product].id,
          :total => item[:product].price*item[:quantity],
          :quantity => item[:quantity] })
        self.line_items << line_item
      end
    end

    def update_details
      self.created_at ||= Time.now
      self.status ||= "new"
      self.total = 0

      self.line_items.each do |line_item|
        line_item.total = line_item.product.price * line_item.quantity
        self.total += line_item.total
      end

      shipments.each do |shipment|
        if shipment.new_record? 
          calculator = shipment.shipping_method.klass.constantize
          shipment.total = calculator.rate(shipment.shipping_method, self)
        end
        self.total += shipment.total
      end

      self.total_due = self.total
      payments.each do |payment|
        self.total_due -= payment.total
      end
    end

    def update_status
      update_details

      if self.total_due > 0.00
        self.status = "payment owed"
      elsif self.total_due == 0.00
        if self.total == 0.00
          self.status = "new"
        else
          self.status = "paid"
        end
      else
        self.status = "credit_owed" 
      end
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
