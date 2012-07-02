module Piggybak
  module ActsAsVariant
    extend ActiveSupport::Concern

    module ClassMethods
      def acts_as_variant
        has_one :piggybak_variant, :as => "item", :class_name => "::Piggybak::Variant"

        accepts_nested_attributes_for :piggybak_variant, :allow_destroy => true
      end
    end
  end
end

::ActiveRecord::Base.send :include, Piggybak::ActsAsVariant
