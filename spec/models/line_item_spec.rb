require 'spec_helper'

describe Piggybak::LineItem do
  it { should belong_to :order }
end
