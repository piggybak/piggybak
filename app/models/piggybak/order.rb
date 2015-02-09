module Piggybak
  class Order < ActiveRecord::Base
    has_many :line_items, :inverse_of => :order
    has_many :order_notes, :inverse_of => :order

    belongs_to :billing_address, :class_name => "Piggybak::Address"
    belongs_to :shipping_address, :class_name => "Piggybak::Address"
    belongs_to :user
  
    accepts_nested_attributes_for :billing_address, :allow_destroy => true
    accepts_nested_attributes_for :shipping_address, :allow_destroy => true
    accepts_nested_attributes_for :line_items, :allow_destroy => true
    accepts_nested_attributes_for :order_notes

    attr_accessor :recorded_changes, :recorded_changer,
                  :was_new_record, :disable_order_notes 

    validates :status, presence: true
    validates :email, presence: true
    validates :phone, presence: true
    validates :total, presence: true
    validates :total_due, presence: true
    validates :created_at, presence: true
    validates :ip_address, presence: true
    validates :user_agent, presence: true

    after_initialize :initialize_defaults
    validate :number_payments
    before_save :postprocess_order, :update_status, :set_new_record
    after_save :record_order_note
    after_save :deliver_order_confirmation, :if => Proc.new { |order| !order.confirmation_sent }

    default_scope { order('created_at ASC') }

    def deliver_order_confirmation
      Piggybak::Notifier.order_notification(self).deliver
      self.update_column(:confirmation_sent,true)
    end
 
    def initialize_defaults
      self.recorded_changes ||= []

      self.billing_address ||= Piggybak::Address.new
      self.shipping_address ||= Piggybak::Address.new
      self.shipping_address.is_shipping = true

      self.ip_address ||= 'admin'
      self.user_agent ||= 'admin'

      self.created_at ||= Time.now
      self.status ||= "new"
      self.total ||= 0
      self.total_due ||= 0
      self.disable_order_notes = false
    end

    def number_payments

      new_payments = self.line_items.payments.select { |li| li.new_record? }
      if new_payments.size > 1
        self.errors.add(:base, "Only one payment may be created at a time.")
        new_payments.each do |li|
          li.errors.add(:line_item_type, "Only one payment may be created at a time.")
        end
      end
    end

    def initialize_user(user)
      if user
        self.user = user
        self.email = user.email 
      end
    end

    def postprocess_order

      # Mark line items for destruction if quantity == 0
      self.line_items.each do |line_item|
        if line_item.quantity == 0
          line_item.mark_for_destruction
        end
      end

      # Postprocess everything but payments first
      self.line_items.each do |line_item|
        next if line_item.line_item_type == "payment"
        method = "postprocess_#{line_item.line_item_type}"
        if line_item.respond_to?(method)
          if !line_item.send(method)
            return false
          end
        end
      end
      
      # Recalculate and create line item for tax
      # If a tax line item already exists, reset price
      # If a tax line item doesn't, create
      # If tax is 0, destroy tax line item
      tax = TaxMethod.calculate_tax(self)
      tax_line_item = self.line_items.taxes
      if tax > 0
        if tax_line_item.any?
          tax_line_item.first.price = tax
        else
          self.line_items << LineItem.new({ :line_item_type => "tax", :description => "Tax Charge", :price => tax })
        end
      elsif tax_line_item.any?
        tax_line_item.first.mark_for_destruction
      end
     
      # Recalculating total and total due, in case post process changed totals
      self.total_due = 0
      self.total = 0
      self.line_items.each do |line_item|
        if !line_item._destroy
          self.total_due += line_item.price
          if line_item.line_item_type != "payment" 
            self.total += line_item.price
          end 
        end
      end

      # Postprocess payment last
      self.line_items.payments.each do |line_item|
        method = "postprocess_payment"
        if line_item.respond_to?("postprocess_payment")
          if !line_item.postprocess_payment
            return false
          end
        end
      end

      true
    end

    def record_order_note
      if self.changed? && !self.was_new_record
        self.recorded_changes << self.formatted_changes
      end

      if self.recorded_changes.any? && !self.disable_order_notes
        OrderNote.create(:order_id => self.id, :note => self.recorded_changes.join("<br />"), :user_id => self.recorded_changer.to_i)
      end
    end

    def create_payment_shipment
      shipment_line_item = self.line_items.detect { |li| li.line_item_type == "shipment" }

      if shipment_line_item.nil?
        new_shipment_line_item = Piggybak::LineItem.new({ :line_item_type => "shipment" })
        new_shipment_line_item.build_shipment
        self.line_items << new_shipment_line_item
      elsif shipment_line_item.shipment.nil?
        shipment_line_item.build_shipment
      else
        previous_method = shipment_line_item.shipment.shipping_method_id
        shipment_line_item.build_shipment
        shipment_line_item.shipment.shipping_method_id = previous_method
      end

      if !self.line_items.detect { |li| li.line_item_type == "payment" }
        payment_line_item = Piggybak::LineItem.new({ :line_item_type => "payment" })
        payment_line_item.build_payment 
        self.line_items << payment_line_item
      end
    end

    def add_line_items(cart)
      cart.update_quantities

      cart.sellables.each do |item|
        self.line_items << Piggybak::LineItem.new({ :sellable_id => item[:sellable].id,
          :unit_price => item[:sellable].price,
          :price => item[:sellable].price*item[:quantity],
          :description => item[:sellable].description,
          :quantity => item[:quantity] })
      end
    end

    def update_status
      return if self.status == "cancelled"  # do nothing

      if self.total_due != 0.00
        self.status = "unbalanced" 
      else
        if self.to_be_cancelled
          self.status = "cancelled"
        elsif line_items.shipments.any? && line_items.shipments.all? { |li| li.shipment.status == "shipped" }
          self.status = "shipped"
        elsif line_items.shipments.any? && line_items.shipments.all? { |li| li.shipment.status == "processing" }
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
  end
end
