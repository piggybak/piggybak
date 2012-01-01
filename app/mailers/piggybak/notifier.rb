module Piggybak
  class Notifier < ActionMailer::Base
    default :from => "system@example.com"
    
    def order_notification(order)
      @order = order
  
      mail(:to => order.email,
           :subject => "Order ##{@order.id}")
    end
  end
end
