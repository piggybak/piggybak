module Piggybak
  class Credit < ActiveRecord::Base
    belongs_to :order
    belongs_to :source, :polymorphic => true

    validates_presence_of :total
  end
end
