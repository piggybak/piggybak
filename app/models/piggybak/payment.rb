module Piggybak
  class Payment < ActiveRecord::Base
    belongs_to :order
    belongs_to :payment_method

    def status_enum
      ["paid"]
    end
  end
end
