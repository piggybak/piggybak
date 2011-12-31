require 'acts_as_product/base'
require 'acts_as_orderer/base'
require 'application_helper'
require 'active_merchant'
      
ActiveMerchant::Billing::Base.mode = :test

module Piggybak
  class Engine < Rails::Engine
    initializer "define rails_admin config" do |app|
      # RailsAdmin config file. Generated on December 21, 2011 13:04
      # See github.com/sferik/rails_admin for more informations
      
      RailsAdmin.config do |config|
        config.model Piggybak::Order do
          label "Order"
          navigation_label "Piggybak Orders"
          weight 1
          object_label_method :admin_label
      
          list do
            field :status
            field :total
            field :created_at
            field :user
          end
          edit do
            field :created_at do
              visible do
                !bindings[:object].new_record?
              end
              read_only true
            end
            field :status do
              visible do
                !bindings[:object].new_record?
              end
              read_only true
            end
            field :total do
              visible do
                !bindings[:object].new_record?
              end
              read_only true
            end
            field :total_due do
              visible do
                !bindings[:object].new_record?
              end
              read_only true
            end
            field :user do
              read_only do
                !bindings[:object].new_record?
              end
            end
            field :billing_address
            field :shipping_address
            field :line_items
            field :shipments
            field :payments
          end
        end
      
        config.model Piggybak::Address do
          label "Address"
          parent Piggybak::Order
          object_label_method :admin_label
          visible false
        end
      
        config.model Piggybak::LineItem do
          label "Line Item"
          #parent Piggybak::Order
          object_label_method :admin_label
          visible false

          edit do
            include_all_fields
            field :order do
              visible false 
            end
          end
        end
      
        config.model Piggybak::Shipment do
          parent Piggybak::Order
          object_label_method :admin_label
          visible false

          edit do
            include_all_fields
            field :order do
              visible false 
            end
          end
        end
      
        config.model Piggybak::Payment do
          parent Piggybak::Order
          visible false

          edit do
            include_all_fields
            field :order do
              visible false 
            end
          end
        end
      
        config.model Piggybak::PaymentMethod do
          navigation_label "Piggybak Configuration"
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
            field :klass
            include_all_fields
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
          parent Piggybak::PaymentMethod
          object_label_method :admin_label
          edit do
            field :description do
              help "This is the label the user sees."
            end
            field :klass
            include_all_fields
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
      
        config.model Piggybak::Product do
          label "Product"
          parent Piggybak::Order
          object_label_method :admin_label
          edit do
            field :item do
              read_only do
                !bindings[:object].new_record?
              end
            end
            include_all_fields
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
