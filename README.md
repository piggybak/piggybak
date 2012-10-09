Piggybak Gem (Engine)
========

Modular / mountable ecommerce gem. Features:

* Configurable tax methods, shipping methods, payment methods

* One page checkout, with AJAX for shipping and tax calculations

* Order processing completed in transaction, minimizing orphan data created 

* Fully defined backend RailsAdmin interface for adding orders on the backend

Installation
========
* First create a new rails project:
        rails new webstore

* Config your database.yml and create the databases
		
* Add to Gemfile:
    
        gem "piggybak"
 
* Next, run bundle install:

        bundle install

* Next, run the piggybak install command:

        piggybak install

* Piggybak is now installed and ready to be added to whatever model class will be sold.

        class Product < ActiveRecord::Base
		  acts_as_sellable
		end

* Piggybak checkout is located at /checkout


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
