module Piggybak
  module ActsAsSellable
    extend ActiveSupport::Concern

    module ClassMethods
      def acts_as_sellable
        has_one :piggybak_sellable, :as => "item", :class_name => "::Piggybak::Sellable", :inverse_of => :item
        accepts_nested_attributes_for :piggybak_sellable, :allow_destroy => true
      end      
    end
  end
end

::ActiveRecord::Base.send :include, Piggybak::ActsAsSellable
