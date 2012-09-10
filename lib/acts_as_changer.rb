module Piggybak
  module ActsAsChanger
    extend ActiveSupport::Concern

    module ClassMethods
      def acts_as_changer
        after_create :document_new_item
        after_update :document_nested_change
        after_destroy :document_destroy_item
      end
    end

    def document_new_item
      self.order.recorded_changes << self.new_destroy_changes("added")
    end

    def document_nested_change
      if self.changed?
        self.order.recorded_changes << self.formatted_changes
      end
    end

    def document_destroy_item
      self.order.recorded_changes << self.new_destroy_changes("destroyed")
    end
  end
end

::ActiveRecord::Base.send :include, Piggybak::ActsAsChanger
