class LineItemRearchitecture < ActiveRecord::Migration
  def up
    Piggybak::Shipment.class_eval do
      self.table_name = 'shipments'
    end
    Piggybak::Payment.class_eval do
      self.table_name = 'payments'
    end
    Piggybak::Adjustment.class_eval do
      self.table_name = 'adjustments'
    end
    Piggybak::Order.class_eval do
      self.table_name = 'orders'
    end

    add_column :line_items, :line_item_type, :string, :null => false, :default => "sellable"
    rename_column :line_items, :price, :unit_price
    rename_column :line_items, :total, :price
    change_column :line_items, :sellable_id, :integer, :null => true
    add_column :line_items, :sort, :integer, :null => false, :default => 0

    add_column :shipments, :line_item_id, :integer
    add_column :payments, :line_item_id, :integer

    [Piggybak::Shipment, Piggybak::Payment, Piggybak::Adjustment].each do |klass|
      klass.all.each do |item|
        description = ''
        if klass == Piggybak::Shipment
          description = item.shipping_method.description
        elsif klass == Piggybak::Payment
          description = "Payment"
        elsif klass == Piggybak::Adjustment
          description = item.note || "Adjustment"
        end
        li = Piggybak::LineItem.new({ :line_item_type => klass.to_s.demodulize.downcase,
          :price => 0.00,
          :description => description,
          :quantity => 1 })
        b = item.attributes["order_id"]
        li.order_id = b
        li.save

        if [Piggybak::Shipment, Piggybak::Payment].include?(klass)
          item.update_attribute(:line_item_id, li.id)
        end

        li.update_attribute(:price, item.total)
      end
    end

    remove_column :shipments, :total
    remove_column :payments, :total
    remove_column :adjustments, :total
    remove_column :shipments, :order_id
    remove_column :payments, :order_id
    remove_column :adjustments, :order_id

    Piggybak::Order.all.each do |o|
      next if o.attributes["tax_charge"] == 0.00
      o.line_items << Piggybak::LineItem.new({ :line_item_type => "tax",
        :price => o.attributes["tax_charge"],
        :description => "Tax Charge",
        :quantity => 1 })
    end

    remove_column :orders, :tax_charge
  end

  def down
    add_column :shipments, :total, :decimal, :null => false, :default => 0.0
    add_column :payments, :total, :decimal, :null => false, :default => 0.0
    add_column :adjustments, :total, :decimal
    add_column :shipments, :order_id, :integer, :null => false, :default => 0
    add_column :payments, :order_id, :integer, :null => false, :default => 0
    add_column :adjustments, :order_id, :integer, :null => false, :default => 0

    add_column :orders, :tax_charge, :decimal, :null => false, :default => 0.0

    to_delete = []
    Piggybak::LineItem.class_eval do
      self.table_name = 'line_items'
    end
    Piggybak::LineItem.all.each do |line_item|
      if line_item.line_item_type == "payment"
        line_item.payment.update_attributes({ :order_id => line_item.order_id, :total => line_item.price }) 
        to_delete << line_item
      elsif line_item.line_item_type == "shipment"
        line_item.shipment.update_attributes({ :order_id => line_item.order_id, :total => line_item.price }) 
        to_delete << line_item
      elsif line_item.line_item_type == "adjustment"
        to_delete << line_item
        line_item.adjustment.update_attributes({ :order_id => line_item.order_id, :total => line_item.price }) 
      elsif line_item.line_item_type == "tax"
        line_item.order.update_attribute(:tax_charge, line_item.price)
        to_delete << line_item
      end
    end
    Piggybak::LineItem.destroy(to_delete)

    remove_column :shipments, :line_item_id
    remove_column :payments, :line_item_id

    remove_column :line_items, :line_item_type
    remove_column :line_items, :updated_at
    remove_column :line_items, :created_at
    remove_column :line_items, :sort
    rename_column :line_items, :price, :total
    rename_column :line_items, :unit_price, :price
  end
end
