module Piggybak
  class Country < ActiveRecord::Base
    attr_accessible :name, :abbr, :active_shipping, :active_billing
    has_many :states

    scope :shipping, where(:active_shipping => true)
    scope :billing, where(:active_billing => true)
    default_scope :order => 'name ASC'
  end
end
