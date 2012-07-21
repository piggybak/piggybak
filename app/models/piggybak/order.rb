module Piggybak
  class Order < ActiveRecord::Base
    has_many :line_items, :inverse_of => :order
    has_many :payments, :inverse_of => :order
    has_many :shipments, :inverse_of => :order
    has_many :adjustments, :inverse_of => :order
    has_many :order_notes, :inverse_of => :order

    belongs_to :billing_address, :class_name => "Piggybak::Address"
    belongs_to :shipping_address, :class_name => "Piggybak::Address"
    belongs_to :user
  
    accepts_nested_attributes_for :billing_address, :allow_destroy => true
    accepts_nested_attributes_for :shipping_address, :allow_destroy => true
    accepts_nested_attributes_for :shipments, :allow_destroy => true
    accepts_nested_attributes_for :line_items, :allow_destroy => true
    accepts_nested_attributes_for :payments
    accepts_nested_attributes_for :adjustments, :allow_destroy => true
    accepts_nested_attributes_for :order_notes

    attr_accessor :recorded_changes
    attr_accessor :recorded_changer
    attr_accessor :was_new_record

    validates_presence_of :status, :email, :phone, :total, :total_due, :tax_charge, :created_at, :ip_address, :user_agent

    after_initialize :initialize_nested, :initialize_request
    before_validation :set_defaults
    after_validation :update_totals
    before_save :process_payments, :update_status, :set_new_record
    after_save :record_order_note

    default_scope :order => 'created_at DESC'

    def initialize_nested
      self.recorded_changes ||= []

      self.billing_address ||= Piggybak::Address.new
      self.shipping_address ||= Piggybak::Address.new
      self.shipments ||= [Piggybak::Shipment.new] 
      self.payments ||= [Piggybak::Payment.new]
      if self.payments.any?
        self.payments.first.payment_method_id = Piggybak::PaymentMethod.find_by_active(true).id
      end
    end

    def initialize_request
      self.ip_address ||= 'admin'
      self.user_agent ||= 'admin'
    end

    def initialize_user(user, on_post)
      if user
        self.user = user
        self.email = user.email 
      end
    end

    def process_payments
      has_errors = false
      self.payments.each do |payment|
        if(!payment.process)
          has_errors = true
        end
      end

      self.total_due = self.total
      payments_total = payments.inject(0) do |payments_total, payment|
        payments_total += payment.total if payment.status == "paid"
        payments_total
      end 
      self.total_due -= payments_total

      !has_errors
    end

    def record_order_note
      if self.changed?
        if self.was_new_record
          self.recorded_changes << self.new_destroy_changes("created")
        else
          self.recorded_changes << self.formatted_changes
        end
      end

      if self.recorded_changes.any?
        OrderNote.create(:order_id => self.id, :note => self.recorded_changes.join("<br />"), :user_id => self.recorded_changer.to_i)
      end
    end

    def add_line_items(cart)
      cart.update_quantities
      cart.items.each do |item|
        line_item = Piggybak::LineItem.new({ :variant_id => item[:variant].id,
          :price => item[:variant].price,
          :total => item[:variant].price*item[:quantity],
          :description => item[:variant].description,
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
        if self.status != "shipped"
          line_item.description = line_item.variant.description
          line_item.price = line_item.variant.price
        end
        if line_item.variant
          line_item.total = line_item.price * line_item.quantity.to_i
        else
          line_item.total = 0
        end
      end
    end

    def update_totals
      self.total = 0

      self.line_items.each do |line_item|
        if !line_item._destroy
          self.total += line_item.total 
        end
      end

      self.tax_charge = TaxMethod.calculate_tax(self)
      self.total += self.tax_charge

      shipments.each do |shipment|
        if (shipment.new_record? || shipment.status != "shipped") && shipment.shipping_method
          calculator = shipment.shipping_method.klass.constantize
          shipment.total = calculator.rate(shipment.shipping_method, self)
        end
        if !shipment._destroy
          self.total += shipment.total
        end
      end

      adjustments.each do |adjustment|
        if !adjustment._destroy
          self.total += adjustment.total
        end
      end

      self.total_due = self.total
      payments.each do |payment|
        if payment.status == "paid"
          self.total_due -= payment.total
        end
      end
    end

    def update_status
      return if self.status == "cancelled"  # do nothing

      if self.total_due != 0.00
        self.status = "unbalanced" 
      else
        if self.shipments.any? && self.shipments.all? { |s| s.status == "shipped" }
          self.status = "shipped"
        elsif self.shipments.any? && self.shipments.all? { |s| s.status == "processing" }
          self.status = "processing"
        else
          self.status = "new"
        end
      end
    end
    def set_new_record
      self.was_new_record = self.new_record?

      true
    end

    def status_enum
      ["new", "processing", "shipped"]
    end
      
    def avs_address
      {
      :address1 => self.billing_address.address1,
      :city     => self.billing_address.city,
      :state    => self.billing_address.state_display,
      :zip      => self.billing_address.zip,
      :country  => "US" 
      }
    end

    def admin_label
      "Order ##{self.id}"    
    end

    def subtotal
      self.line_items.inject(0) { |subtotal, li| subtotal + li.total }
    end
  end
end
