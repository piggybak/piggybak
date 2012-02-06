module Piggybak
  class OrdersController < ApplicationController
    def submit
      response.headers['Cache-Control'] = 'no-cache'
      @cart = Piggybak::Cart.new(request.cookies["cart"])

      if request.post?
        begin
          ActiveRecord::Base.transaction do
            @order = Piggybak::Order.new(params[:piggybak_order])
            @order.initialize_user(current_user)

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
          if @order.errors.empty?
            @order.errors.add "", "Your order could not go through. Please try again."
          end
        end
	  else
        @order = Piggybak::Order.new
        @order.initialize_user(current_user)
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
      redirect_to root if current_user.nil?
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

    def cancel
      order = Order.find(params[:id])

      if can?(:cancel, order)
        order.payments.each do |payment|
          payment.refund
        end
        order.update_attribute(:status, "cancelled")
        flash[:notice] = "Cancelled"
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
