class Float
  def to_c
    ((self*100).ceil.to_i).to_f/100
  end
end
