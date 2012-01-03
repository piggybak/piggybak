module Piggybak
  class OrdersController < ApplicationController
    def show
      response.headers['Cache-Control'] = 'no-cache'

      @cart = Piggybak::Cart.new(request.cookies["cart"])
      @order = Piggybak::Order.new

      if current_user
        @order.user = current_user
        @order.email = current_user.email 
      end

      @order.billing_address ||= Piggybak::Address.new
      @order.shipping_address ||= Piggybak::Address.new

      @order.shipments ||= [Piggybak::Shipment.new] 

      @order.payments ||= [Piggybak::Payment.new] 
    end
  
    def submit
      response.headers['Cache-Control'] = 'no-cache'

      begin
        ActiveRecord::Base.transaction do
          @order = Piggybak::Order.new(params[:piggybak_order])
          @order.user = current_user if current_user
          @order.payments.first.payment_method_id = Piggybak::PaymentMethod.find_by_active(true).id

          cart = Piggybak::Cart.new(request.cookies["cart"])
          @order.add_line_items(cart)

          if @order.save
            Piggybak::Notifier.order_notification(@order)

            cookies["cart"] = { :value => '', :path => '/' }
            session[:last_order] = @order.id
            redirect_to piggybak.receipt_url 
          else
            raise Exception, @order.errors.full_messages
          end
        end
      rescue Exception => e
        @message = e.message 
        @cart = Piggybak::Cart.new(request.cookies["cart"])

        if current_user
          @order.user = current_user
          @order.email = current_user.email 
        end

        @user = current_user

        render "piggybak/orders/show"
      end
    end
  
    def receipt
      response.headers['Cache-Control'] = 'no-cache'

      @order = Piggybak::Order.find(session[:last_order])
    end

    def list
      @user = current_user
      redirect_to root if @user.nil?
    end

    def email
      order = Order.find(params[:id])
      Piggybak::Notifier.order_notification(order)
      flash[:notice] = "Email notification sent."

      redirect_to rails_admin.edit_path('Piggybak::Order', order.id)
    end

    def shipping
      cart = Piggybak::Cart.new(request.cookies["cart"])
      cart.extra_data = params
      shipping_methods = Piggybak::ShippingMethod.lookup_methods(cart)
      render :json => shipping_methods
    end

    def tax
      cart = Piggybak::Cart.new(request.cookies["cart"])
      cart.extra_data = params
      total_tax = Piggybak::TaxMethod.calculate_tax(cart)
      render :json => { :tax => total_tax }
    end
  end
end
