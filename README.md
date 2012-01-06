Piggybak Gem (Engine)
========

Modular / mountable ecommerce gem. Features:

* Configurable tax methods, shipping methods, payment methods

* One page checkout, with AJAX for shipping and tax calculations

* Order processing completed in transaction, minimizing orphan data created 

* Fully defined backend RailsAdmin interface for adding orders on the backend

This engine explicitly excludes:

* SSL configuration (to be handled in your parent application)

* Redirects on login / logout (see recipe below)

* Coupons and Gift cerficates (May be added later)

* Per unit inventory tracking

* Downloadable products

This engine is highly dependent on: 

* Rails 3.1 (Assets, Engines)

* RailsAdmin (Admin UI) 

* Devise (User Authentication)

* CanCan (User Authorization)

Installation
========

* First, add to Gemfile:
    
        gem "piggybak", :git => "git://github.com/stephskardal/demo.git"

* Next, run rake task to copy migrations:

        rake piggybak_engine:install:migrations

* Next, run rake task to run migrations:

        rake db:migrate

* Next, mount in your application by adding:

        mount Piggybak::Engine => '/checkout', :as => 'piggybak'" to config/routes

Integration Components
========

* Add acts_as_variant to models that will be sellable
* Add acts_as_orderer to user model (or model that devise hooks into as authenticated user)
* Add <%= cart_form(@some_item) %> to view to display cart form
* Add <%= cart_link %> to display link to cart
* Add <%= orders_link %> to display link to user orders

Recipes
========

* Redirect after login / logout

        before_filter :set_last_page
        def set_last_page
            if !request.xhr? && !request.url.match(/users\/sign_in/) && !request.url.match(/users\/sign_out/)
            session[:return_to] = request.url
            end 
        end 
        def after_sign_in_path_for(resource_or_scope)
            session[:return_to] || root_url
        end 
        def after_sign_out_path_for(resource_or_scope)
            session[:return_to] || root_url
        end

* Cancan access control

        class Ability
            include CanCan::Ability
            def initialize(user)
                if user && user.roles.include?(Role.find_by_name("admin"))
                    can :access, :rails_admin
                    can :manage, [ #Insert your app models here
                                  ::Piggybak::Variant,
                                  ::Piggybak::ShippingMethod,
                                  ::Piggybak::PaymentMethod,
                                  ::Piggybak::TaxMethod,
                                  ::Piggybak::State,
                                  ::Piggybak::Country]
                   can [:download, :email, :read, :create, :update, :history, :export], ::Piggybak::Order
                end
            end
        end


Roadmap / TODOs
========

* Figure out how to make entire payments section read only, except for ability to refund
* Add refunds: Add actionable link under payments
* Handle state options in admin: selected state or free text

* Check accessibility of email, download actions on individual orders
* Test email send functionality
* Test a different mount point (verify no URLs are hardcoded)
* Test a different user model
* Add unit testing

Copyright
========

Copyright (c) 2011 Steph Skardal. See LICENSE.txt for further details.
