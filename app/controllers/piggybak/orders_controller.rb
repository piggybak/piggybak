module Piggybak
  class OrdersController < ApplicationController
    def show
      @user = current_user

      @cart = Piggybak::Cart.new(request.cookies["cart"])
      @order = Piggybak::Order.new
      @order.billing_address ||= Piggybak::Address.new
      @order.shipping_address ||= Piggybak::Address.new

      @shipping_methods = Piggybak::ShippingMethod.lookup_methods(@cart) 
      @order.shipments ||= [Piggybak::Shipment.new] 

      @payment_methods = Piggybak::PaymentMethod.find_all_by_active(true).inject([]) { |arr, b| arr << [b.label, b.id]; arr }
      @order.payments ||= [Piggybak::Payment.new] 
    end
  
    def submit
      begin
        ActiveRecord::Base.transaction do
          @order = Piggybak::Order.new(params[:piggybak_order].merge({:total => 0.0, :total_due => 0.0, :created_at => Time.now}))

          if current_user.present?
            @order.email = current_user.email
            @order.user_id = current_user.id
          end

          if @order.save
            cart = Piggybak::Cart.new(request.cookies["cart"])
            cart.update_quantities
            cart.items.each do |item|
              line_item = Piggybak::LineItem.new({ :product_id => item[:product].id,
                :total => item[:product].price*item[:quantity],
                :quantity => item[:quantity] })
              @order.line_items << line_item
              item[:product].decrease_quantity(item[:quantity])
            end

            shipment = @order.shipments.first
            calculator = shipment.shipping_method.klass.constantize
            shipment.update_attribute(:total, calculator.rate(shipment.shipping_method, cart))

            @order.update_details
            @order.save

            payment = @order.payments.first
            payment_gateway = payment.payment_method.klass.constantize
  	        params[:credit_card][:first_name] = @order.billing_address.firstname
  	        params[:credit_card][:last_name] = @order.billing_address.lastname
  	        credit_card = ActiveMerchant::Billing::CreditCard.new(params[:credit_card])

  	        if credit_card.valid?
  		      gateway = payment_gateway.new(payment.payment_method.key_values)
  		      gateway_response = gateway.authorize(@order.total*100, credit_card, :address => @order.avs_address)
  		      if gateway_response.success?
  		        gateway.capture(1000, gateway_response.authorization)
                cookies["cart"] = { :value => '', :path => '/' }
                session[:last_order] = @order.id
                redirect_to piggybak.receipt_url 
  		      else
  		        raise Exception, gateway_response.message
  		      end
  	        else
  		      raise Exception, "Your credit card was not valid. #{credit_card.errors}"
            end
          else
            raise Exception, @order.errors.full_messages
          end
        end
      rescue Exception => e
        @message = e.message 
        @cart = Piggybak::Cart.new(request.cookies["cart"])

        @shipping_methods = Piggybak::ShippingMethod.lookup_methods(@cart) 
        @payment_methods = Piggybak::PaymentMethod.find_all_by_active(true).inject([]) { |arr, b| arr << [b.label, b.id]; arr }
        @user = current_user

        render "piggybak/orders/show"
      end
    end
  
    def receipt
      @order = Piggybak::Order.find(session[:last_order])
    end

    def list
      @user = current_user
      redirect_to root if @user.nil?
    end
  end
end
