class Float
  def to_c
    ((self*100).round.to_i).to_f/100
  end
end
