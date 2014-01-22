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

* Follow the instructions [here][documentation] to read more about the integration points and product configuration in Piggybak.

[documentation]: http://www.piggybak.org/documentation.html#integration

More Details
========

Visit the project website [here][project-website] to see more documentation and view a demo.

[project-website]: http://www.piggybak.org/

TODO
========

* Ensure that changes in nested addresses are recorded on order notes.

Copyright
========

Copyright (c) 2014 End Point & Steph Skardal. See LICENSE for further details.
