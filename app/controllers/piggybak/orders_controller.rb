module Piggybak
  class OrdersController < ApplicationController
    def submit
      response.headers['Cache-Control'] = 'no-cache'
      @cart = Piggybak::Cart.new(request.cookies["cart"])

      if request.post?
        begin
          ActiveRecord::Base.transaction do
            @order = Piggybak::Order.new(params[:piggybak_order])
            @order.initialize_user(current_user, true)

            @order.ip_address = request.remote_ip 
            @order.user_agent = request.user_agent  
            @order.add_line_items(@cart)

            if @order.save
              Piggybak::Notifier.order_notification(@order).deliver

              cookies["cart"] = { :value => '', :path => '/' }
              session[:last_order] = @order.id
              redirect_to piggybak.receipt_url 
            else
              raise Exception, @order.errors.full_messages
            end
          end
        rescue Exception => e
          Rails.logger.warn "Generic Order Exception: #{e.inspect}"
          if @order.errors.empty?
            @order.errors[:base] << "Your order could not go through. Please try again."
          end
        end
	  else
        @order = Piggybak::Order.new
        @order.initialize_user(current_user, false)
      end
    end
  
    def receipt
      response.headers['Cache-Control'] = 'no-cache'

      if !session.has_key?(:last_order)
        redirect_to root_url 
        return
      end

      @order = Piggybak::Order.find(session[:last_order])
    end

    def list
      redirect_to root_url if current_user.nil?
    end

    def download
      @order = Piggybak::Order.find(params[:id])

      if can?(:download, @order)
        render :layout => false
      else
        render "no_access"
      end
    end

    def email
      order = Order.find(params[:id])

      if can?(:email, order)
        Piggybak::Notifier.order_notification(order).deliver
        flash[:notice] = "Email notification sent."
      end

      redirect_to rails_admin.edit_path('Piggybak::Order', order.id)
    end

    def restore
      order = Order.find(params[:id])

      if can?(:restore, order)
        order.update_attribute(:status, "new")
        Piggybak::OrderNote.create(:user_id => current_user.id,
          :order_id => order.id,
          :note => "Order restored from cancelled.")
      end

      redirect_to rails_admin.edit_path('Piggybak::Order', order.id)
    end

    def cancel
      order = Order.find(params[:id])

      if can?(:cancel, order)
        cancelled_items = []
        order.line_items.each do |line_item|
          cancelled_items << "#{line_item.quantity}:#{line_item.variant.sku}"
          line_item.destroy
        end
        order.payments.each do |payment|
          payment.refund
        end
        order.update_attribute(:status, "cancelled")

        Piggybak::OrderNote.create(:user_id => current_user.id,
          :order_id => order.id,
          :note => "Order marked as cancelled with #{cancelled_items.join(', ')}.")
        flash[:notice] = "Order #{order.id} cancelled"
      end

      redirect_to rails_admin.edit_path('Piggybak::Order', order.id)
    end

    # AJAX Actions from checkout
    def shipping
      cart = Piggybak::Cart.new(request.cookies["cart"])
      cart.set_extra_data(params)
      shipping_methods = Piggybak::ShippingMethod.lookup_methods(cart)
      render :json => shipping_methods
    end

    def tax
      cart = Piggybak::Cart.new(request.cookies["cart"])
      cart.set_extra_data(params)
      total_tax = Piggybak::TaxMethod.calculate_tax(cart)
      render :json => { :tax => total_tax }
    end

    def geodata
      countries = ::Piggybak::Country.find(:all, :include => :states)
      data = countries.inject({}) do |h, country|
        h["country_#{country.id}"] = country.states
        h
      end
      render :json => { :countries => data }
    end
  end
end
