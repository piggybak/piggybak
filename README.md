Piggybak Gem (Engine)
========

Modular / mountable ecommerce gem. Features:

* Configurable tax methods, shipping methods, payment methods

* One page checkout, with AJAX for shipping and tax calculations

* Order processing completed in transaction, minimizing orphan data created 

* Fully defined backend RailsAdmin interface for adding orders on the backend


Announcements
========

* Variants were recently changed to sellables, to provide the opportunity for advanced variant support via an extension.

* Significant recent rearchitecture has been applied to the order line items. Stay tuned for the documentation.

* Review the new installation process below.
 

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

(NOTE: If you run into an error saying that piggybak gem is missing, use bundle exec piggybak install)

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

* Ensure that changes in nested addresses are recorded on order notes.

* Add admin side validation to limit 1 payment at a time

* Add/check validation to ensure sufficient inventory

* Add copy from billing above shipping address section button in admin

* Re-add order logging / masking payment parameters

Copyright
========

Copyright (c) 2011 End Point & Steph Skardal. See LICENSE.txt for further details.
