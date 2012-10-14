require 'thor'

module Piggybak
  class CLI < Thor
    include Thor::Actions
  
    desc "install", "install and configure piggybak"
    def install
      inject_devise
      inject_rails_admin
      run('bundle install')
      run('rake piggybak_engine:install:migrations')
      run('rake db:migrate')   
      run('rails generate devise:install')
      run('rails generate devise User') 
      run('rake db:migrate')      
      run('rails g rails_admin:install')
      run('rake db:migrate')      
      mount_piggybak_route
      add_javascript_include_tag
      config_assets_precompile
      welcome
    end

    desc "inject_devise", "add devise"
    def inject_devise
      puts 'add reference to devise in GEMFILE'
      insert_into_file "GEMFILE", "gem 'devise'\n", :after => "source 'https://rubygems.org'\n"
    end

    
    desc "inject_rails_admin", "add rails_admin"
    def inject_rails_admin
      puts 'add reference to rails_admin in GEMFILE'
      insert_into_file "Gemfile", "gem 'rails_admin'\n", :after => "gem 'devise'\n"
    end
  
    desc "mount_piggybak_route", "mount piggbak route"
    def mount_piggybak_route
      insert_into_file "config/routes.rb", "\n  mount Piggybak::Engine => '/checkout', :as => 'piggybak'\n", :after => "Village::Application.routes.draw do\n"
    end
  
    desc "add_javascript_include_tag", "add javascript include tag to application layout"
    def add_javascript_include_tag
      jit_code_block = <<-eos
          \n  <% if "\#{params[:controller]}#\#\{params[:action]\}" == "piggybak/orders#submit" -%>
      <%= javascript_include_tag "piggybak-application" %>\n  <% end -%>
      eos
    
      insert_into_file 'app/views/layouts/application.html.erb', jit_code_block, :after => "<%= javascript_include_tag \"application\" %>"
    
    end
    
    desc "create user class", "Create a user class"
    def create_user_class
      run('rails generate model User')      
    end
    
    desc "config_assets-precompile", "amust add this to your production configuration, in order for this asset to be precompiled"
    def config_assets_precompile
      insert_into_file 'config/environments/production.rb', "\n  config.assets.precompile += %w( piggybak-application.js )", :after => 'Village::Application.configure do'
    end
    
    desc "welcome", "invite to piggybak"
    def welcome
      say ""
      say ""
      say ""
      say "******************************************************************"
      say "******************************************************************"
      say "Piggybak Successfully Installed!"
      say "******************************************************************"
      say ""
      say "Add acts_as_sellable to any model that will be a sellable item."
      say ""
      say "class Product < ActiveRecord::Base"
      say "  acts_as_sellable"
      say "end"
    end
  end
end
