module Piggybak
  class State < ActiveRecord::Base
    attr_accessible :name, :abbr, :country
    belongs_to :country
  end
end
