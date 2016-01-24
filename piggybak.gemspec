$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'piggybak/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'piggybak'
  s.version     = Piggybak::VERSION
  s.authors     = ['Steph Skardal', 'Tim Case', 'Brian Buchalter', 'Patrick Lewis']
  s.email       = ['piggybak@endpoint.com']
  s.homepage    = 'http://www.piggybak.org/'
  s.summary     = 'Mountable Ruby on Rails Ecommerce.'
  s.description = 'Mountable Ruby on Rails Ecommerce.'
  s.license     = 'GPL-2'

  s.files = Dir['{app,bin,config,db,lib,spec}/**/*'] + ['LICENSE', 'Rakefile', 'README.md', 'Gemfile']
  s.executables = s.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  s.test_files = Dir['spec/*']

  s.add_dependency 'countries', '~> 1.2.2'
  s.add_dependency 'activemerchant'
  s.add_dependency 'rack-ssl-enforcer'
  s.add_dependency 'devise'
  s.add_dependency 'rails_admin'
end
