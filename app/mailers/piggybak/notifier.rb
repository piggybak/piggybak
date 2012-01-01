module Piggybak
  class Notifier < ActionMailer::Base
    default :from => "system@example.com"
    
    def order_notification(order)
      @account = recipient
  
      #attachments['an-image.jp'] = File.read("an-image.jpg")
      #attachments['terms.pdf'] = {:content => generate_your_pdf_here() }
  
      mail(:to => order.email,
           :subject => "Complete Order")
    end
  end
end
