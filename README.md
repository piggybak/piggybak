Piggybak Gem (Engine)
========

Modular / mountable ecommerce gem. Features:

* Configurable tax methods, shipping methods, payment methods

* One page checkout, with AJAX for shipping and tax calculations

* Order processing completed in transaction, minimizing orphan data created 

* Fully defined backend RailsAdmin interface for adding orders on the backend

Installation
========

* First, add to Gemfile (from RubyGems, with version specified, or source) with *one* of the following options:
    
        gem "piggybak"
        gem "piggybak", '0.4.19'
        gem "piggybak", :git => "git://github.com/stephskardal/piggybak.git"
 
* Next, run rake task to copy migrations:

        rake piggybak_engine:install:migrations

* Next, run rake task to run migrations:

        rake db:migrate

* Next, mount in your application by adding:

        mount Piggybak::Engine => '/checkout', :as => 'piggybak'" to config/routes

* You must include jquery_ujs in your application.js file in to get the remove item from cart functionality to work.

        //= require jquery_ujs

* You must add the following to your application layout:

       <% if "#{params[:controller]}##{params[:action]}" == "piggybak/orders#submit" -%>
       <%= javascript_include_tag "piggybak-application" %>
       <% end -%>

More Details
========

Visit the project website [here][project-website] to see more documentation and view a demo.

[project-website]: http://www.piggybak.org/

TODO
========

On order notes functionality, changes in addresses are not recorded. This functionality is broken and needs attention.

Copyright
========

Copyright (c) 2011 End Point & Steph Skardal. See LICENSE.txt for further details.
