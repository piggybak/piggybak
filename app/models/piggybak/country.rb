module Piggybak
  class Country < ActiveRecord::Base
    has_many :states
  end
end
