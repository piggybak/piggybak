module Piggybak
  module ActsAsOrderer
    extend ActiveSupport::Concern

    module ClassMethods
      def acts_as_orderer
        has_many :piggybak_orders, :foreign_key => "user_id", :class_name => "::Piggybak::Order"

        has_many :order_notes, :foreign_key => "user_id", :class_name => "::Piggybak::OrderNote"
      end
    end
  end
end

::ActiveRecord::Base.send :include, Piggybak::ActsAsOrderer
