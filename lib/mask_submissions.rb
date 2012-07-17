class String
  def mask_cc_number
    masked = ''

    if self.gsub(/\D+/i, '').match(/^(\d\d)(.+)(\d\d\d\d)$/)
      masked = $1 + $2.length.times.inject('') { |s, i| "#{s}*" } + $3
    end

    masked
  end

  def mask_csv
    self.length.times.inject('') { |s, i| "#{s}*" }
  end
end
