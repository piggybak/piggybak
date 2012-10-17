module Piggybak
  class OrdersController < ApplicationController
    def submit
      response.headers['Cache-Control'] = 'no-cache'
      @cart = Piggybak::Cart.new(request.cookies["cart"])

      if request.post?
        logger = Logger.new("#{Rails.root}/#{Piggybak.config.logging_file}")

        begin
          ActiveRecord::Base.transaction do
            @order = Piggybak::Order.new(params[:piggybak_order])
            @order.create_payment_shipment

            if Piggybak.config.logging
              # TODO: Reimplement on correctly filtered params
              #clean_params = params[:piggybak_order].clone
              #clean_params["payments_attributes"]["0"]["number"] = clean_params["payments_attributes"]["0"]["number"].mask_cc_number
              #clean_params["payments_attributes"]["0"]["verification_value"] = clean_params["payments_attributes"]["0"]["verification_value"].mask_csv
              #logger.info "#{request.remote_ip}:#{Time.now.strftime("%Y-%m-%d %H:%M")} Order received with params #{clean_params.inspect}" 
            end
            @order.initialize_user(current_user, true)

            @order.ip_address = request.remote_ip 
            @order.user_agent = request.user_agent  
            @order.add_line_items(@cart)

            if Piggybak.config.logging
              logger.info "#{request.remote_ip}:#{Time.now.strftime("%Y-%m-%d %H:%M")} Order contains: #{cookies["cart"]} for user #{current_user ? current_user.email : 'guest'}"
            end

            if @order.save
              # TODO: Imporant: figure out how to have notifications not trigger rollback here. Instead log failed order notification sent.
              Piggybak::Notifier.order_notification(@order).deliver

              if Piggybak.config.logging
                logger.info "#{request.remote_ip}:#{Time.now.strftime("%Y-%m-%d %H:%M")} Order saved: #{@order.inspect}"
              end

              cookies["cart"] = { :value => '', :path => '/' }
              session[:last_order] = @order.id
              redirect_to piggybak.receipt_url 
            else
              if Piggybak.config.logging
                logger.warn "#{request.remote_ip}:#{Time.now.strftime("%Y-%m-%d %H:%M")} Order failed to save #{@order.errors.full_messages} with #{@order.inspect}."
              end
              raise Exception, @order.errors.full_messages
            end
          end
        rescue Exception => e
          if Piggybak.config.logging
            logger.warn "#{request.remote_ip}:#{Time.now.strftime("%Y-%m-%d %H:%M")} Order exception: #{e.inspect}"
          end
          if @order.errors.empty?
            @order.errors[:base] << "Your order could not go through. Please try again."
          end
        end
      else
        @order = Piggybak::Order.new
        @order.create_payment_shipment
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
        OrderNote.create(:order_id => order.id, :note => "Email confirmation manually sent.", :user_id => current_user.id)
      end

      redirect_to rails_admin.edit_path('Piggybak::Order', order.id)
    end

    def cancel
      order = Order.find(params[:id])

      if can?(:cancel, order)
        order.recorded_changer = current_user.id
        order.disable_order_notes = true

        order.line_items.each do |line_item|
          if line_item.line_item_type != "payment"
            line_item.mark_for_destruction
          end
        end
        order.update_attribute(:total, 0.00)
        order.update_attribute(:to_be_cancelled, true)

        OrderNote.create(:order_id => order.id, :note => "Order set to cancelled. Line items, shipments, tax removed.", :user_id => current_user.id)
        
        flash[:notice] = "Order #{order.id} set to cancelled. Order is now in unbalanced state."
      else
        flash[:error] = "You do not have permission to cancel this order."
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
