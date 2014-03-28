module Piggybak
  class Engine < Rails::Engine
    isolate_namespace Piggybak

    initializer "piggybak.ssl_enforcer" do |app|
      # Note: If your main application also uses rack-ssl-enforcer,
      # append to Piggyak.config.extra_secure_paths
      # inside a before_initialize block
      if Piggybak.config.secure_checkout
        paths = [/^#{Piggybak.config.secure_prefix}\/checkout\/$/,
                 "#{Piggybak.config.secure_prefix}/checkout/orders/tax",
                 "#{Piggybak.config.secure_prefix}/checkout/orders/shipping",
                 "#{Piggybak.config.secure_prefix}/checkout/orders/geodata",
                 /^\/users$/,
                 "/users/sign_in",
                 "/users/sign_out",
                 "/users/sign_up"]
        Piggybak.config.extra_secure_paths.each do |extra_path|
          paths << [/^#{Piggybak.config.secure_prefix}#{extra_path}/]
        end
        app.config.middleware.use Rack::SslEnforcer,
          :only => paths,
          :strict => true
      end
    end
    
    initializer "piggybak.add_helper" do |app|
      ActiveSupport.on_load :action_controller do
        helper :piggybak
      end
    end

    initializer "piggybak.assets.precompile" do |app|
      app.config.assets.precompile += ['piggybak/piggybak-application.js']
    end

    # Needed for development
    config.to_prepare do
      Piggybak.config.line_item_types.each do |k, v|
        plural_k = k.to_s.pluralize.to_sym
        if v[:nested_attrs]
          Piggybak::LineItem.class_eval do
            # TODO: dependent destroy destroys all line items. Fix and remove after_destroy on line items
            has_one k, :class_name => v[:class_name] #, :dependent => :destroy
            accepts_nested_attributes_for k
          end
        end
        Piggybak::Order.class_eval do
          define_method "#{k}_charge" do
            self.line_items.send(plural_k).map(&:price).reduce(:+) || 0
          end
        end
      end
      Piggybak::Order.class_eval do
        has_many :line_items, :inverse_of => :order do
          Piggybak.config.line_item_types.each do |k, v|
            # Define proxy association method for line items
            # e.g. self.line_items.sellables
            # e.g. self.line_items.taxes
            define_method "#{k.to_s.pluralize}" do
              proxy_association.select { |li| li.line_item_type == "#{k}" && !li.marked_for_destruction? }
            end
          end
        end
        # Define method subtotal on order, alias to sellable_charge
        alias :subtotal :sellable_charge 
      end
    end

    initializer "piggybak.rails_admin_config" do |app|
      Piggybak.config.line_item_types.each do |k, v|
        plural_k = k.to_s.pluralize.to_sym
        if v[:nested_attrs]
          Piggybak::LineItem.class_eval do
            # TODO: See above
            has_one k, :class_name => v[:class_name]
            accepts_nested_attributes_for k
          end
        end
      end
      RailsAdmin::Config.reset_model(Piggybak::LineItem)

      RailsAdmin.config do |config|
        config.label_methods << :admin_label

        config.model Piggybak::LineItem do
          label "Line Item"
          visible false

          edit do
            field :line_item_type do
              label "Line Item Type"
              partial "polymorphic_nested"
              help ""
            end
            Piggybak.config.line_item_types.each do |k, v|
              if v[:nested_attrs]
                field k do
                  active true
                end
              end
            end
            field :sellable_id, :enum do
              label "Sellable"
              help "Required"
            end
            field :price 
            field :quantity
            field :description  
          end
        end

        config.model Piggybak::Sellable do
          label "Sellable"
          visible false
          edit do
            field :sku
            field :description 
            field :price
            field :active
            field :quantity
            field :unlimited_inventory do
              help "If true, backorders on this variant will be allowed, regardless of quantity on hand."
            end
          end
        end

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
            field :total_due do
              formatted_value do
                "$%.2f" % value
              end
            end
            field :created_at
            field :email
            field :phone

            field :user if defined?(User)

            field :line_items
            field :billing_address
            field :shipping_address
            field :order_notes do
              pretty_value do
                value.inject([]) { |arr, o| arr << o.details }.join("<br /><br />").html_safe
              end
            end
            field :ip_address
            field :user_agent
          end
          list do
            field :id
            field :billing_address do
              label "Billing Name"
              pretty_value do
                "#{value.lastname}, #{value.firstname}"
              end
              searchable [:firstname, :lastname]
              sortable false
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

            field :user if defined?(User)
            field :email
            field :phone
            field :ip_address do
              partial "ip_address"
            end
            field :user_agent do
              read_only true
            end
            field :billing_address do
              active true
              help "Required"
            end
            field :shipping_address do
              active true
              help "Required"
            end
            field :line_items do
              active true
              help ""
            end
            field :order_notes do
              active true
            end
          end
        end
     
        config.model Piggybak::OrderNote do
          visible false
          list do
            field :user if defined?(User)
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
          visible false

          edit do
            field :copy_from_billing do
              visible do
                bindings[:object].respond_to?(:is_shipping) && bindings[:object].is_shipping
              end 
              partial "copy_from_billing"
              label "Help"
              help "Copies address from billing to shipping."
            end
            field :firstname
            field :lastname
            field :address1
            field :address2
            field :city
            field :zip
            field :country
            field :state_id, :hidden do
				help ""
            end
            field :location do
              partial "location_select"
              help "Required"
              label "State"
            end
          end
        end
      
        config.model Piggybak::Shipment do
          visible false

          edit do
            field :shipping_method do
              read_only do
                bindings[:object].status == "shipped"
              end
            end
            field :status do
              label "Shipping Status"
            end
          end
        end
    
        config.model Piggybak::Adjustment do
          visible false
        end

        config.model Piggybak::Payment do
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
          end
        end
      
        config.model Piggybak::PaymentMethod do
          navigation_label "Configuration"
          weight 2
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
      end
    end
  end
end
