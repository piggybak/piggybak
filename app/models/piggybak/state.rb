module Piggybak
  class State < ActiveRecord::Base
    belongs_to :country
  end
end
