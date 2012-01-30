module Piggybak
  class Notifier < ActionMailer::Base
    default :from => Piggybak.config.email_sender

    def order_notification(order)
      @order = order
  
      mail(:to => order.email,
           :subject => "Order ##{@order.id}")
    end
  end
end
