module Piggybak
  module ActsAsVariant
    ## Define ModelMethods
    module Base
      def self.included(klass)
        klass.class_eval do
          extend ClassMethods
        end
      end
      
      module ClassMethods
        def acts_as_variant
          has_one :piggybak_variant, :as => "item", :class_name => "::Piggybak::Variant"

          accepts_nested_attributes_for :piggybak_variant, :allow_destroy => true
          
          include Piggybak::ActsAsVariant::Base::InstanceMethods
        end
      end
      
      module InstanceMethods
        
        def factory_name
          "this is an example instance method"
        end
                
      end # InstanceMethods      
    end
  end
end

::ActiveRecord::Base.send :include, Piggybak::ActsAsVariant::Base
