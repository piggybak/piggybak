module Piggybak
  class Order < ActiveRecord::Base
    has_many :line_items, :inverse_of => :order
    has_many :payments, :inverse_of => :order
    has_many :shipments, :inverse_of => :order
    has_many :credits, :inverse_of => :order

    belongs_to :billing_address, :class_name => "Piggybak::Address"
    belongs_to :shipping_address, :class_name => "Piggybak::Address"
    belongs_to :user
  
    accepts_nested_attributes_for :billing_address, :allow_destroy => true
    accepts_nested_attributes_for :shipping_address, :allow_destroy => true
    accepts_nested_attributes_for :shipments, :allow_destroy => true
    accepts_nested_attributes_for :line_items, :allow_destroy => true
    accepts_nested_attributes_for :payments # test :allow_destroy

    validates_presence_of :status  
    validates_presence_of :email
    validates_presence_of :phone
    validates_presence_of :total
    validates_presence_of :total_due
    validates_presence_of :tax_charge
    validates_presence_of :created_at

    before_validation :set_defaults
    after_validation :update_totals
    before_save :process_payments, :update_status

    def process_payments
      has_errors = false
      self.payments.each do |payment|
        if(!payment.process)
          has_errors = true
        end
      end

      self.total_due = self.total
      payments.each do |payment|
        self.total_due -= payment.total
      end
      !has_errors
    end

    def details
      if !self.new_record? 
        subtotal = self.line_items.inject(0) { |subtotal, li| subtotal + li.total }
        shipping = self.shipments.inject(0) { |shipping, shipment| shipping + shipment.total }
        return "Status: #{self.status}<br />" +
          "Subtotal: $#{"%.2f" % subtotal}<br />" + 
          "Shipping: $#{"%.2f" % shipping}<br />" + 
          "Tax: $#{"%.2f" % self.tax_charge}<br />" + 
          "Due: $#{"%.2f" % self.total_due}<br />" + 
          "Created at: #{self.created_at.strftime("%m-%d-%Y")}<br />" #details here"
      else
        return "New Order"
      end
    end

    def add_line_items(cart)
      cart.update_quantities
      cart.items.each do |item|
        line_item = Piggybak::LineItem.new({ :variant_id => item[:variant].id,
          :total => item[:variant].price*item[:quantity],
          :quantity => item[:quantity] })
        self.line_items << line_item
      end
    end

    def set_defaults
      self.created_at ||= Time.now
      self.status ||= "new"
      self.total = 0
      self.total_due = 0
      self.tax_charge = 0

      self.line_items.each do |line_item|
        line_item.total = line_item.variant.price * line_item.quantity
      end
    end

    def update_totals
      self.total = 0

      self.line_items.each do |line_item|
        self.total += line_item.total
      end

      self.tax_charge = TaxMethod.calculate_tax(self)
      self.total += self.tax_charge

      shipments.each do |shipment|
        if shipment.new_record? 
          calculator = shipment.shipping_method.klass.constantize
          shipment.total = calculator.rate(shipment.shipping_method, self)
        end
        self.total += shipment.total
      end

      # Hook in credits, TBD
      credits.each do |credit|
        self.total -= credit.total
      end

      self.total = self.total.to_c

      self.total_due = self.total
      payments.each do |payment|
        self.total_due -= payment.total
      end
    end

    def update_status
      if self.total_due > 0.00
        self.status = "payment owed"
      elsif self.total_due < 0.00
        self.status = "credit_owed" 
      else
        if self.total == 0.00
          self.status = "new"
        elsif self.shipments.all? { |s| s.status == "shipped" }
          self.status = "shipped"
        else
          self.status = "paid"
        end
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
