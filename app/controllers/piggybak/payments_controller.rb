module Piggybak
  class PaymentsController < ApplicationController
    def refund
      payment = Payment.find(params[:id])

      if can?(:refund, payment)
        flash[:notice] = payment.refund
      end

      redirect_to rails_admin.edit_path('Piggybak::Order', payment.order.id)
    end
  end
end
