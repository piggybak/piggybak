require 'spec_helper'

describe Piggybak::Order do
  it { should belong_to :user }

  it { should validate_presence_of :email } 
  it { should validate_presence_of :phone } 
end
