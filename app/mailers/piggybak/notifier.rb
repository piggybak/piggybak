module Piggybak
  class Notifier < ActionMailer::Base
    def order_notification(order)
      @order = order
  
      mail(:to => order.email,
           :subject => "Order ##{@order.id}")
    end
  end
end
