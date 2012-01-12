class Pickup
  KEYS = ["state_id", "rate"]

  def self.available?(method, object)
    id = method.metadata.detect { |t| t.key == "state_id" }.value.to_i

    if object.is_a?(Piggybak::Cart)
      state = Piggybak::State.find(object.extra_data["state_id"])
      return true if state && state.id == id
    else
      if object.billing_address && object.billing_address.state 
        return object.billing_address.state.id == id
      end
    end
    return false
  end

  def self.rate(method, object)
    method.metadata.detect { |m| m.key == "rate" }.value.to_f.to_c
  end
end
