module Piggybak
  class LineItem < ActiveRecord::Base
    belongs_to :order
    acts_as_changer
    belongs_to :sellable

    validates :price, presence: true
    validates :description, presence: true
    validates :quantity, presence: true
    validates_numericality_of :quantity, :only_integer => true, :greater_than_or_equal_to => 0

    default_scope { order('created_at ASC') }

    after_create :decrease_inventory, :if => Proc.new { |line_item| line_item.line_item_type == 'sellable' && !line_item.sellable.unlimited_inventory }
    after_destroy :increase_inventory, :if => Proc.new { |line_item| line_item.line_item_type == 'sellable' && !line_item.sellable.unlimited_inventory }
    after_update :update_inventory, :if => Proc.new { |line_item| line_item.line_item_type == 'sellable' && !line_item.sellable.unlimited_inventory }

    after_initialize :initialize_line_item
    before_validation :preprocess
    before_destroy :destroy_associated_item

    # TODO: Possibly replace all initializers below with database defaults
    def initialize_line_item
      self.quantity ||= 1
      self.price ||= 0

      # TODO: Fix this, should default in database
      self.created_at ||= Time.now
    end

    def preprocess
      # TODO: Investigate if this is unnecessary if you use reject_if on accepts_nested_attributes_for
      Piggybak.config.line_item_types.each do |k, v|
        if v.has_key?(:nested_attrs) && k != self.line_item_type.to_sym
          self.send("#{k}=", nil)
        end
      end

      method = "preprocess_#{self.line_item_type}"
      self.send(method) if self.respond_to?(method)
    end

    def preprocess_sellable
      if self.sellable_id.nil?
        self.errors.add(:sellable_id, "Sellable can't be blank")
        return
      end

      sellable = Piggybak::Sellable.where(id: self.sellable_id).first

      return if sellable.nil?

      # Inventory check
      quantity_change = 0
      if self.new_record?
        quantity_change = self.quantity.to_i
      elsif self.changes.keys.include?("quantity") && self.quantity > self.quantity_was
        quantity_change = self.quantity - self.quantity_was
      end
      if sellable.quantity < quantity_change && !sellable.unlimited_inventory
        self.errors.add(:sellable_id, "Insufficient inventory by #{quantity_change - sellable.quantity} unit(s).")
        return
      end

      self.description = sellable.description
      self.unit_price = sellable.price
      self.price = self.unit_price*self.quantity.to_i
    end

    def preprocess_shipment
      if !self._destroy
        if (self.new_record? || self.shipment.status != 'shipped') && self.shipment && self.shipment.shipping_method
          calculator = self.shipment.shipping_method.klass.constantize
          self.price = calculator.rate(self.shipment.shipping_method, self.order)
          self.price = ((self.price*100).to_i).to_f/100
          self.description = self.shipment.shipping_method.description
        end
        if self.shipment.nil? || self.shipment.shipping_method.nil?
          self.price = 0.00
          self.description = "Shipping"
        end
      end
    end

    def preprocess_payment
      if self.new_record?
        self.build_payment if self.payment.nil?
        self.payment.payment_method_id ||= Piggybak::PaymentMethod.where(active: true).first.id
        self.description = "Payment"
        self.price = 0
      end
    end

    def postprocess_payment
      return true if !self.new_record?

      if self.payment.process(self.order)
        self.price = -1*self.order.total_due
        self.order.total_due = 0
        return true
      else
        return false
      end
    end

    # Dependent destroy is not working as expected, so this is in place
    def destroy_associated_item
      line_item_type_sym = self.line_item_type.to_sym
      if Piggybak.config.line_item_types[line_item_type_sym].has_key?(:nested_attrs)
        if Piggybak.config.line_item_types[line_item_type_sym][:nested_attrs]
          b = self.send("#{line_item_type_sym}")
          b.destroy if b.present?
        end
      end
    end

    def self.line_item_type_select
      Piggybak.config.line_item_types.select { |k, v| v[:visible] }.collect { |k, v| [k.to_s.humanize.titleize, k] }
    end

    def sellable_id_enum
      ::Piggybak::Sellable.all.collect { |s| ["#{s.description}: $#{s.price}", s.id ] }
    end

    def admin_label
      if self.line_item_type == 'sellable'
        "#{self.quantity} x #{self.description} ($#{sprintf("%.2f", self.unit_price)}): $#{sprintf("%.2f", self.price)}".gsub('"', '&quot;')
      else
        "#{self.description}: $#{sprintf("%.2f", self.price)}".gsub('"', '&quot;')
      end
    end

    def decrease_inventory
      self.sellable.update_inventory(-1 * self.quantity)
    end

    def increase_inventory
      self.sellable.update_inventory(self.quantity)
    end

    def update_inventory
      if self.sellable_id != self.sellable_id_was
        old_sellable = Sellable.where(id: self.sellable_id_was).first
        old_sellable.update_inventory(self.quantity_was)
        self.sellable.update_inventory(-1*self.quantity)
      else
        quantity_diff = self.quantity_was - self.quantity
        self.sellable.update_inventory(quantity_diff)
      end
    end

    def self.sorted_line_item_types
      Piggybak::Config.line_item_types.sort { |a, b| (a[1][:sort] || 100) <=> (b[1][:sort] || 100) }.collect { |a| a[0] }
    end
  end
end
