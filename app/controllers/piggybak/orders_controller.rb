module Piggybak
  class OrdersController < ApplicationController
    def show
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
          @order = Piggybak::Order.new(params[:piggybak_order].merge({:total => 0.0 }))
          if @order.save
            cart = Piggybak::Cart.new(request.cookies["cart"])
            cart.items.each do |item|
              Piggybak::LineItem.create({ :order_id => @order.id,
                :product_id => item[:product].id,
                :total => item[:product].price*item[:quantity],
                :quantity => item[:quantity] })
            end

            shipment = @order.shipments.first
            calculator = shipment.shipping_method.klass.constantize
            shipment.update_attribute(:total, calculator.rate(shipment.shipping_method, cart))

            @order.update_total

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
        @payment_methods = Piggybak::PaymentMethod.find_all_by_active(true).inject([]) { |arr, b| arr << [b.klass, b.id]; arr }

        render "piggybak/orders/show"
      end
    end
  
    def receipt
      @order = Piggybak::Order.find(session[:last_order])
    end
  end
end
