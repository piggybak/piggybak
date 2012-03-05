module Piggybak
  module ActsAsOrderer
    module Base
      def self.included(klass)
        klass.class_eval do
          extend ClassMethods
        end
      end
      
      module ClassMethods
        def acts_as_orderer
          has_many :piggybak_orders, :foreign_key => "user_id", :class_name => "::Piggybak::Order"
        end
      end
    end
  end
end

::ActiveRecord::Base.send :include, Piggybak::ActsAsOrderer::Base
