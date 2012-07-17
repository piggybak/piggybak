module Piggybak
  class OrderNote < ActiveRecord::Base
    attr_accessible :user_id, :order_id, :note, :created_at
    validates_presence_of :user_id, :order_id

    belongs_to :order
    belongs_to :user

    def admin_label
      "Order Note: #{created_at.strftime("%m-%d-%Y")}"
    end
  end
end
