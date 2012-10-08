module Piggybak
  module ActsAsSellable
    extend ActiveSupport::Concern

    module ClassMethods
      
      def acts_as_sellable
        
        has_one :piggybak_sellable, :as => "item", :class_name => "::Piggybak::Sellable"

        has_one :piggybak_variant, :as => :piggybak_sellable
        
        accepts_nested_attributes_for :piggybak_sellable, :allow_destroy => true

      end
      
      alias :acts_as_variant :acts_as_sellable

    end
  end
end

::ActiveRecord::Base.send :include, Piggybak::ActsAsSellable


