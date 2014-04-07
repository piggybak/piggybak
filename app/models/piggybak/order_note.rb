module Piggybak
  class OrderNote < ActiveRecord::Base
    validates :user_id, presence: true
    validates :order_id, presence: true

    belongs_to :order
    belongs_to :user
    default_scope { order('created_at ASC') }

    def details
      "<b>#{created_at.strftime("%m-%d-%Y %H:%M")}</b> by #{user ? user.email : 'N/A'}:<br />#{note}"
    end

    def admin_label
      "Order Note: #{created_at.strftime("%m-%d-%Y %H:%M")}"
    end
  end
end
