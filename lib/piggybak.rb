require 'piggybak/engine'
require 'piggybak/config'
require 'acts_as_sellable'
require 'acts_as_orderer'
require 'acts_as_changer'
require 'active_merchant'
require 'formatted_changes'
require 'mask_submissions'
require 'rack-ssl-enforcer'

module Piggybak
  def self.config(entity = nil, &block)

    if entity
      Piggybak::Config.model(entity, &block)
    elsif block_given? && ENV['SKIP_RAILS_ADMIN_INITIALIZER'] != "true"
      block.call(Piggybak::Config)
    else
      Piggybak::Config
    end 
  end

  def self.reset
    Piggybak::Config.reset
  end
end
