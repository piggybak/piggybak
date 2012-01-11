Piggybak Gem (Engine)
========

Modular / mountable ecommerce gem. Features:

* Configurable tax methods, shipping methods, payment methods

* One page checkout, with AJAX for shipping and tax calculations

* Order processing completed in transaction, minimizing orphan data created 

* Fully defined backend RailsAdmin interface for adding orders on the backend

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

More Details
========

Visit the project website [here][project-website] to see more documentation and view a demo.

[project-website]: http://www.piggybak.org/

Copyright
========

Copyright (c) 2011 End Point & Steph Skardal. See LICENSE.txt for further details.
