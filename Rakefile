# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "piggybak"
  gem.homepage = "http://github.com/stephskardal/piggybak"
  gem.license = "MIT"
  gem.summary = %Q{Mountable ecommerce}
  gem.description = %Q{Mountable ecommerce}
  gem.email = "steph@endpoint.com"
  gem.authors = ["Steph Skardal", "Brian Buchalter"]

  gem.add_dependency "rails_admin"
  gem.add_dependency "devise"
  gem.add_dependency "activemerchant"
  gem.add_dependency "countries"

  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rspec-rails'
  gem.add_development_dependency 'diff-lcs'
  gem.add_development_dependency 'factory_girl'
  gem.add_development_dependency 'shoulda'

  gem.test_files = Dir['spec/**/*']
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task :test => :spec
