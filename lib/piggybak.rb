require 'piggybak/config'
require 'acts_as_variant'
require 'acts_as_orderer'
require 'acts_as_changer'
require 'active_merchant'
require 'formatted_changes'
require 'currency'
require 'mask_submissions'

module Piggybak
  def self.config(entity = nil, &block)
    if entity
      Piggybak::Config.model(entity, &block)
    elsif block_given? && ENV['SKIP_RAILS_ADMIN_INITIALIZER'] != "true"
      block.call(Piggybak::Config)
    else
      Piggybak::Config
    end 
  end

  def self.reset
    Piggybak::Config.reset
  end

  class Engine < Rails::Engine
    initializer "piggybak.add_helper" do |app|
      ApplicationController.class_eval do
        helper :piggybak
      end
    end

    initializer "piggybak.rails_admin_config" do |app|
      # RailsAdmin config file. Generated on December 21, 2011 13:04
      # See github.com/sferik/rails_admin for more informations

      RailsAdmin.config do |config|
        config.model Piggybak::Order do
          label "Order"
          navigation_label "Orders"
          weight 1
          object_label_method :admin_label

          show do
            field :status
            field :total do
              formatted_value do
                "$%.2f" % value
              end
            end
            field :tax_charge do
              formatted_value do
                "$%.2f" % value
              end
            end
            field :total_due do
              formatted_value do
                "$%.2f" % value
              end
            end
            field :created_at
            field :email
            field :phone
            field :user

            field :line_items
            field :billing_address
            field :shipping_address
            field :shipments
            field :payments
            field :order_notes do
              pretty_value do
                value.inject([]) { |arr, o| arr << o.details }.join("<br /><br />").html_safe
              end
            end
          end
          list do
            field :id
            field :billing_address do
              label "Billing Name"
              pretty_value do
                "#{value.lastname}, #{value.firstname}"
              end
              searchable [:firstname, :lastname]
            end
            field :total do
              formatted_value do
                "$%.2f" % value
              end
            end
            field :created_at do
              strftime_format "%d-%m-%Y"
            end
            field :status
          end
          edit do
            field :recorded_changer, :hidden do
              partial "recorded_changer"
            end
            # TODO: Figure out why this doesn't work here
            #field :recorded_changer, :hidden do
            #  default_value do
            #    bindings[:view]._current_user.id
            #  end
            #end
            field :status do
              visible do
                !bindings[:object].new_record?
              end 
              read_only do 
                !bindings[:object].new_record?
              end 
            end
             
            field :details do
              partial "order_details"
              help ""
              visible do
                !bindings[:object].new_record?
              end
            end

            field :user
            field :email
            field :phone
            field :ip_address do
              read_only do 
                !bindings[:object].new_record?
              end 
            end
            field :user_agent do
              read_only do 
                !bindings[:object].new_record?
              end 
            end
            field :billing_address do 
             help "Required"
            end
            field :shipping_address do
              help "Required"
            end
            field :line_items
            field :shipments
            field :payments do
              active true
            end
            field :adjustments
            field :order_notes do
              active true
            end
          end
        end
     
        config.model Piggybak::OrderNote do
          object_label_method :admin_label
          visible false
          list do
            field :user
            field :note
            field :created_at
          end
          edit do
            field :details do
              label "Order Note"
              help ""
              visible do
                !bindings[:object].new_record?
              end 
              read_only do 
                !bindings[:object].new_record?
              end 
            end
            field :user_id, :hidden do
              default_value do
                bindings[:view]._current_user.id
              end
            end
            field :note do
              visible do
                bindings[:object].new_record?
              end 
            end
          end
        end
 
        config.model Piggybak::Address do
          label "Address"
          object_label_method :admin_label
          visible false

          edit do
            field :firstname
            field :lastname
            field :address1
            field :address2
            field :city
            field :zip
            field :location do
              partial "location_select"
              help "Required"
              label "Country & State"
            end
          end
        end
      
        config.model Piggybak::LineItem do
          label "Line Item"
          object_label_method :admin_label
          visible false

          edit do
            field :variant
            field :quantity
            field :total do
              read_only true
              formatted_value do
                value ? "$%.2f" % value : '-'
              end
              help "This will automatically be calculated at the time of processing."
            end
          end
        end
      
        config.model Piggybak::Shipment do
          object_label_method :admin_label
          visible false

          edit do
            field :shipping_method
            field :status do
              label "Shipping Status"
            end
            field :total do
              read_only true
              formatted_value do
                "$%.2f" % value
              end
              help "This will automatically be calculated at the time of processing."
            end
          end
        end
     
        config.model Piggybak::Adjustment do
          object_label_method :admin_label
          visible false
          edit do
            field :user_id, :hidden do
              default_value do
                bindings[:view]._current_user.id
              end
            end
            field :source do
              help "Source of adjustment."
              visible do
                !bindings[:object].new_record?
              end 
              read_only do 
                !bindings[:object].new_record?
              end 
            end
            field :total do
              help "A negative value will add credit to an order. A positive value will add charges to the order."
              read_only do 
                !bindings[:object].new_record?
              end
              formatted_value do
                "$%.2f" % value
              end 
            end
            field :note do
              read_only do 
                !bindings[:object].new_record?
              end 
            end
          end
        end
 
        config.model Piggybak::Payment do
          object_label_method :admin_label
          visible false

          edit do
            field :payment_method do
              read_only do 
                !bindings[:object].new_record?
              end 
            end
            field :masked_number do
              help "Required"
              label "Number"
              visible do
                !bindings[:object].new_record?
              end 
              read_only do
                !bindings[:object].new_record?
              end 
            end
            field :number do
              help "Required"
              visible do
                bindings[:object].new_record?
              end 
            end
            field :verification_value do
              help "Required"
              visible do
                bindings[:object].new_record?
              end 
            end
            field :month do
              label "Exp. Month"
              read_only do 
                !bindings[:object].new_record?
              end 
            end
            field :year do
              label "Exp. Year"
              read_only do 
                !bindings[:object].new_record?
              end 
            end
            field :total do
              read_only true
              visible do
                !bindings[:object].new_record?
              end 
              formatted_value do
                "$%.2f" % value
              end
              help "This will automatically be calculated at the time of processing."
            end
            field :actions do
              visible do
                !bindings[:object].new_record?
              end 
              partial "payment_refund"
              help "This does not mark the payment gateway payment as refunded. This only marks this local payment as refunded."
            end
          end
        end
      
        config.model Piggybak::PaymentMethod do
          navigation_label "Configuration"
          weight 2
          object_label_method :admin_label
          list do
            field :description
            field :active
          end
          edit do
            field :description do
              help "This is the label the user sees."
            end
            field :klass do
              label "Calculator"
            end
            field :active
            field :payment_method_values do
              label "Metadata"
            end
          end
        end

        config.model Piggybak::PaymentMethodValue do
          object_label_method :admin_label
          visible false
          edit do
            include_all_fields
            field :payment_method do
              visible false
            end
          end
        end
      
        config.model Piggybak::ShippingMethod do
          navigation_label "Configuration"
          object_label_method :admin_label
          edit do
            field :description do
              help "This is the label the user sees."
            end
            field :klass do
              label "Calculator"
            end
            field :active
            field :shipping_method_values do
              label "Metadata"
            end
          end
          list do
            field :description
            field :active
          end
        end
      
        config.model Piggybak::ShippingMethodValue do
          object_label_method :admin_label
          visible false
          edit do
            include_all_fields
            field :shipping_method do
              visible false
            end
          end
        end

        config.model Piggybak::TaxMethod do
          navigation_label "Configuration"
          object_label_method :admin_label
          edit do
            field :description
            field :klass do
              label "Calculator"
            end
            field :active
            field :tax_method_values do
              label "Metadata"
            end
          end
          list do
            field :description
            field :active
          end
        end
      
        config.model Piggybak::TaxMethodValue do
          object_label_method :admin_label
          visible false
          edit do
            include_all_fields
            field :tax_method do
              visible false
            end
          end
        end

        config.model Piggybak::Country do
          label "Countries"
          navigation_label "Geodata"
          weight 3
          list do
            sort_by :name
            field :name
            field :abbr
          end
          edit do
            field :name
            field :abbr
            field :active_shipping
            field :active_billing
          end
        end

        config.model Piggybak::State do
          navigation_label "Geodata"
          label "States"
          list do
            field :name
            field :abbr
            field :country
          end
          edit do
            field :name
            field :abbr
            field :country
          end
        end
      
        config.model Piggybak::Variant do
          label "Variant"
		  navigation_label "Orders"
          object_label_method :admin_label
          edit do
            field :item do
              read_only do
                !bindings[:object].new_record?
              end
            end
            include_all_fields
            field :unlimited_inventory do
              help "If true, backorders on this variant will be allowed, regardless of quantity on hand."
            end
          end
          list do
            field :description
            field :price
            field :quantity
            field :active
          end
        end
      end
    end
  end
end
